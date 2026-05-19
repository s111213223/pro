from pydantic import BaseModel


class BBoxNorm(BaseModel):
    """Normalized 0–1 (may be clamped before building)."""

    x1: float
    y1: float
    x2: float
    y2: float


class BBoxPx(BaseModel):
    x1: int
    y1: int
    x2: int
    y2: int
    width_px: int
    height_px: int


class VisionMeasureResponse(BaseModel):
    image_width_px: int
    image_height_px: int
    food_bbox_norm: BBoxNorm
    coin_bbox_norm: BBoxNorm
    food_bbox_px: BBoxPx
    coin_bbox_px: BBoxPx
    coin_diameter_px: float
    coin_diameter_mm: float = 26.0
    food_width_mm: float
    food_height_mm: float
    food_radius_mm: float
    food_area_mm2: float
