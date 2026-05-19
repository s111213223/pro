import io
import json
import os
from typing import Annotated, Optional

import cv2
import numpy as np
from fastapi import APIRouter, File, HTTPException, UploadFile
from PIL import Image

try:
    from google.api_core import exceptions as google_exceptions
except ImportError:  # pragma: no cover
    google_exceptions = None

from app.config import get_gemini_api_key, get_gemini_model
from app.schemas.vision import BBoxNorm, BBoxPx, VisionMeasureResponse
from app.services import gemini_bbox
from app.services.geometry import (
    COIN_DIAMETER_MM,
    coin_diameter_px_from_bbox,
    inscribed_circle_area_mm2,
    norm_bbox_to_px,
    px_to_mm,
)

router = APIRouter(prefix="/api/v1/vision", tags=["vision"])

_ALLOWED_TYPES = frozenset({"image/jpeg", "image/png", "image/webp"})


def _clamp01(v: float) -> float:
    return max(0.0, min(1.0, float(v)))


def _decode_bgr(contents: bytes) -> Optional[np.ndarray]:
    arr = np.frombuffer(contents, dtype=np.uint8)
    return cv2.imdecode(arr, cv2.IMREAD_COLOR)


def _collect_exception_text(exc: BaseException) -> str:
    """grpc / google errors often put details in .args or repr, not str()."""
    chunks: list[str] = []
    seen: set[int] = set()

    def add(e: BaseException | None) -> None:
        if e is None or id(e) in seen:
            return
        seen.add(id(e))
        chunks.append(str(e))
        chunks.append(repr(e))
        if getattr(e, "args", None):
            for a in e.args:
                chunks.append(str(a))
        add(getattr(e, "__cause__", None))
        add(getattr(e, "__context__", None))

    add(exc)
    return "\n".join(chunks)


def _walk_exceptions(exc: BaseException):
    seen: set[int] = set()
    stack: list[BaseException | None] = [exc]
    while stack:
        e = stack.pop()
        if e is None or id(e) in seen:
            continue
        seen.add(id(e))
        yield e
        stack.append(e.__cause__)
        stack.append(e.__context__)


def _gemini_http_exception(exc: Exception) -> HTTPException:
    msg = _collect_exception_text(exc)
    low = msg.lower()
    blob = f"{msg}\n{repr(exc)}".lower()

    if google_exceptions:
        for sub in _walk_exceptions(exc):
            if isinstance(sub, google_exceptions.ResourceExhausted):
                return HTTPException(
                    status_code=429,
                    detail=(
                        "Gemini API quota exceeded for this project/model. "
                        "Set GEMINI_MODEL in backend/.env (e.g. gemini-2.5-flash-lite), wait, or enable billing. "
                        f"Original: {msg}"
                    ),
                )
    if (
        "429" in msg
        or "quota" in low
        or "resource exhausted" in low
        or "resource_exhausted" in blob
        or "generate_content_free_tier" in blob
    ):
        return HTTPException(
            status_code=429,
            detail=(
                "Gemini API quota exceeded or rate-limited. "
                "Set GEMINI_MODEL in backend/.env (try gemini-2.5-flash or gemini-2.5-flash-lite), "
                "or see https://ai.google.dev/gemini-api/docs/rate-limits "
                f"— {msg}"
            ),
        )
    if "403" in msg or "permission" in low or "denied access" in low:
        return HTTPException(
            status_code=403,
            detail=f"Gemini API denied this request. Check API key and project access. — {msg}",
        )
    if "404" in msg or "not found" in low:
        return HTTPException(
            status_code=502,
            detail=(
                f"Gemini model not found or unsupported: {msg}. "
                "Fix GEMINI_MODEL in backend/.env to a model listed in Google AI Studio."
            ),
        )
    return HTTPException(status_code=502, detail=f"Gemini error: {msg}")


@router.post(
    "/measure",
    response_model=VisionMeasureResponse,
    responses={
        429: {"description": "Gemini quota / rate limit"},
        502: {"description": "Gemini or model error"},
        503: {"description": "Server missing GEMINI_API_KEY"},
    },
)
async def measure_photo(
    file: Annotated[UploadFile, File(description="Meal photo with a Taiwan 10 NTD coin beside the food")],
) -> VisionMeasureResponse:
    if not file.content_type or file.content_type not in _ALLOWED_TYPES:
        raise HTTPException(
            400,
            detail=f"Unsupported content type {file.content_type!r}. Use jpeg, png, or webp.",
        )

    api_key = get_gemini_api_key()
    if not api_key:
        raise HTTPException(503, detail="GEMINI_API_KEY is not configured on the server.")

    contents = await file.read()
    if not contents:
        raise HTTPException(400, detail="Empty file.")

    bgr = _decode_bgr(contents)
    if bgr is None:
        raise HTTPException(400, detail="Could not decode image bytes.")

    img_h, img_w = bgr.shape[:2]
    if img_w < 32 or img_h < 32:
        raise HTTPException(400, detail="Image is too small.")

    try:
        pil = Image.open(io.BytesIO(contents)).convert("RGB")
    except OSError as e:
        raise HTTPException(400, detail=f"Invalid image: {e}") from e

    model_name = get_gemini_model()
    try:
        raw = gemini_bbox.run_bbox_detection(api_key, model_name, pil)
    except (json.JSONDecodeError, ValueError) as e:
        raise HTTPException(502, detail=f"Gemini bbox JSON parse failed: {e}") from e
    except Exception as e:
        he = _gemini_http_exception(e)
        if isinstance(he.detail, str):
            he = HTTPException(
                status_code=he.status_code,
                detail=f"{he.detail} [model={model_name}]",
            )
        raise he from e

    try:
        food = raw["food"]
        coin = raw["coin"]
        fn = BBoxNorm(
            x1=_clamp01(food["x1"]),
            y1=_clamp01(food["y1"]),
            x2=_clamp01(food["x2"]),
            y2=_clamp01(food["y2"]),
        )
        cn = BBoxNorm(
            x1=_clamp01(coin["x1"]),
            y1=_clamp01(coin["y1"]),
            x2=_clamp01(coin["x2"]),
            y2=_clamp01(coin["y2"]),
        )
    except (KeyError, TypeError, ValueError) as e:
        raise HTTPException(502, detail=f"Invalid bbox structure from model: {e}") from e

    fx1, fy1, fx2, fy2, fw, fh = norm_bbox_to_px(fn.x1, fn.y1, fn.x2, fn.y2, img_w, img_h)
    cx1, cy1, cx2, cy2, cw, ch = norm_bbox_to_px(cn.x1, cn.y1, cn.x2, cn.y2, img_w, img_h)

    coin_d_px = coin_diameter_px_from_bbox(cw, ch)
    if coin_d_px < 4:
        raise HTTPException(422, detail="Coin box too small in pixels; retake closer or sharper photo.")

    food_w_mm = px_to_mm(float(fw), coin_d_px, COIN_DIAMETER_MM)
    food_h_mm = px_to_mm(float(fh), coin_d_px, COIN_DIAMETER_MM)
    food_radius_mm, food_area_mm2 = inscribed_circle_area_mm2(food_w_mm, food_h_mm)

    return VisionMeasureResponse(
        image_width_px=img_w,
        image_height_px=img_h,
        food_bbox_norm=fn,
        coin_bbox_norm=cn,
        food_bbox_px=BBoxPx(
            x1=fx1,
            y1=fy1,
            x2=fx2,
            y2=fy2,
            width_px=fw,
            height_px=fh,
        ),
        coin_bbox_px=BBoxPx(
            x1=cx1,
            y1=cy1,
            x2=cx2,
            y2=cy2,
            width_px=cw,
            height_px=ch,
        ),
        coin_diameter_px=coin_d_px,
        coin_diameter_mm=COIN_DIAMETER_MM,
        food_width_mm=round(food_w_mm, 2),
        food_height_mm=round(food_h_mm, 2),
        food_radius_mm=round(food_radius_mm, 2),
        food_area_mm2=round(food_area_mm2, 2),
    )
