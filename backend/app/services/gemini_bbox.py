import json
import re
from typing import Any

import google.generativeai as genai
from google.generativeai import protos
from PIL import Image

# Bbox JSON is tiny; 2.5 models may reserve output budget for "thinking" — keep headroom.
_MAX_OUT = 8192

BBOX_JSON_INSTRUCTION = """
You see a meal photo. A Taiwan 10 NTD coin is placed next to the food as a scale reference.
Identify:
1) "food" — tight axis-aligned box around the main food item (one primary dish).
2) "coin" — tight axis-aligned box around the entire visible 10 NTD coin.

Return ONLY a JSON object (no markdown, no code fences, no extra text) with this exact shape:
{"food":{"x1":0,"y1":0,"x2":0,"y2":0},"coin":{"x1":0,"y1":0,"x2":0,"y2":0}}

Rules:
- x1,y1 = top-left corner; x2,y2 = bottom-right corner.
- All values are normalized floats in [0,1]: x coordinates divided by image width, y by image height.
- Ensure x1 < x2 and y1 < y2.
"""


def strip_json_fence(text: str) -> str:
    t = text.strip()
    m = re.match(r"^```(?:json)?\s*\n?(.*?)\n?```\s*$", t, re.DOTALL | re.IGNORECASE)
    if m:
        return m.group(1).strip()
    return t


def extract_json_object(text: str) -> str:
    """If the model wraps JSON in prose or fences, pull the first balanced {...} substring."""
    t = strip_json_fence(text.strip())
    if not t:
        return ""
    try:
        json.loads(t)
        return t
    except json.JSONDecodeError:
        pass
    start = t.find("{")
    if start < 0:
        return ""
    depth = 0
    for i in range(start, len(t)):
        if t[i] == "{":
            depth += 1
        elif t[i] == "}":
            depth -= 1
            if depth == 0:
                return t[start : i + 1]
    return ""


def _text_from_response(resp: Any) -> str:
    """Aggregate text parts; Gemini sometimes leaves resp.text empty."""
    t = (getattr(resp, "text", None) or "").strip()
    if t:
        return t
    cands = getattr(resp, "candidates", None) or []
    if not cands:
        return ""
    parts: list[str] = []
    for cand in cands:
        content = getattr(cand, "content", None)
        if not content:
            continue
        for p in getattr(content, "parts", None) or []:
            txt = getattr(p, "text", None)
            if txt:
                parts.append(txt)
    return "".join(parts).strip()


def parse_bbox_response(text: str) -> dict:
    raw = extract_json_object(text)
    if not raw:
        raise ValueError(f"no JSON object in model output (first 240 chars): {text[:240]!r}")
    try:
        data = json.loads(raw)
    except json.JSONDecodeError as e:
        raise ValueError(
            f"model JSON incomplete or invalid (len={len(raw)}): {raw[:400]!r}... err={e}"
        ) from e
    if not isinstance(data, dict):
        raise ValueError("root must be object")
    for key in ("food", "coin"):
        if key not in data or not isinstance(data[key], dict):
            raise ValueError(f"missing '{key}' object")
        box = data[key]
        for c in ("x1", "y1", "x2", "y2"):
            if c not in box:
                raise ValueError(f"missing {key}.{c}")
            float(box[c])
    return data


def _raise_if_bad_finish(resp: Any, text: str) -> None:
    c0 = resp.candidates[0]
    fr = getattr(c0, "finish_reason", None)
    if fr == protos.Candidate.FinishReason.MAX_TOKENS:
        raise RuntimeError(
            "Gemini stopped with MAX_TOKENS (output truncated before JSON completed). "
            f"Received {len(text)} characters; start of output: {text[:320]!r}"
        )
    if fr == protos.Candidate.FinishReason.SAFETY:
        raise RuntimeError("Gemini blocked the response for safety reasons (try a different photo).")
    if fr == protos.Candidate.FinishReason.PROHIBITED_CONTENT:
        raise RuntimeError("Gemini blocked the response (prohibited content).")


def run_bbox_detection(api_key: str, model_name: str, image: Image.Image) -> dict:
    genai.configure(api_key=api_key)
    model = genai.GenerativeModel(model_name)

    gen_cfg = genai.types.GenerationConfig(
        temperature=0.1,
        max_output_tokens=_MAX_OUT,
        response_mime_type="application/json",
    )

    try:
        resp = model.generate_content(
            [BBOX_JSON_INSTRUCTION, image],
            generation_config=gen_cfg,
        )
    except Exception as e:
        # Some models / API versions reject response_mime_type; retry without JSON mode.
        em = str(e).lower()
        if any(x in em for x in ("json", "mime", "response_schema", "invalid argument", "unsupported")):
            resp = model.generate_content(
                [BBOX_JSON_INSTRUCTION, image],
                generation_config=genai.types.GenerationConfig(
                    temperature=0.1,
                    max_output_tokens=_MAX_OUT,
                ),
            )
        else:
            raise

    if resp.prompt_feedback and getattr(resp.prompt_feedback, "block_reason", None):
        raise RuntimeError(f"Prompt blocked: {resp.prompt_feedback.block_reason}")
    if not resp.candidates:
        raise RuntimeError("no candidates from Gemini")

    text = _text_from_response(resp)
    if not text:
        c0 = resp.candidates[0]
        fr = getattr(c0, "finish_reason", None)
        raise RuntimeError(f"empty model text (finish_reason={fr!r})")

    try:
        return parse_bbox_response(text)
    except (ValueError, json.JSONDecodeError) as e:
        _raise_if_bad_finish(resp, text)
        raise e
