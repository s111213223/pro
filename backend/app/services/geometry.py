"""Normalized bbox (0–1) → pixel rects and mm from coin scale."""

# 新臺幣「拾圓」流通硬幣：中央銀行規格直徑 26 mm（勿與伍圓 22 mm 混淆）。
# https://www.cbc.gov.tw/public/data/issue/money/a1/10-1.htm
COIN_DIAMETER_MM = 26.0


def _sort_xy(x1: float, y1: float, x2: float, y2: float) -> tuple[float, float, float, float]:
    xa, xb = (x1, x2) if x1 <= x2 else (x2, x1)
    ya, yb = (y1, y2) if y1 <= y2 else (y2, y1)
    return xa, ya, xb, yb


def norm_bbox_to_px(
    x1: float,
    y1: float,
    x2: float,
    y2: float,
    img_w: int,
    img_h: int,
) -> tuple[int, int, int, int, int, int]:
    xa, ya, xb, yb = _sort_xy(x1, y1, x2, y2)
    xa = max(0.0, min(1.0, xa))
    ya = max(0.0, min(1.0, ya))
    xb = max(0.0, min(1.0, xb))
    yb = max(0.0, min(1.0, yb))
    if xb <= xa:
        xb = min(1.0, xa + 1e-6)
    if yb <= ya:
        yb = min(1.0, ya + 1e-6)

    x1p = int(round(xa * (img_w - 1)))
    y1p = int(round(ya * (img_h - 1)))
    x2p = int(round(xb * (img_w - 1)))
    y2p = int(round(yb * (img_h - 1)))
    x1p = max(0, min(img_w - 1, x1p))
    y1p = max(0, min(img_h - 1, y1p))
    x2p = max(0, min(img_w - 1, x2p))
    y2p = max(0, min(img_h - 1, y2p))
    if x2p < x1p:
        x1p, x2p = x2p, x1p
    if y2p < y1p:
        y1p, y2p = y2p, y1p
    wpx = max(1, x2p - x1p + 1)
    hpx = max(1, y2p - y1p + 1)
    return x1p, y1p, x2p, y2p, wpx, hpx


def coin_diameter_px_from_bbox(width_px: int, height_px: int) -> float:
    """Axis-aligned box around a face-on coin: both sides ≈ diameter."""
    return float(max(1, width_px) + max(1, height_px)) / 2.0


def px_to_mm(value_px: float, coin_diameter_px: float, coin_mm: float = COIN_DIAMETER_MM) -> float:
    if coin_diameter_px <= 0:
        return 0.0
    return value_px * (coin_mm / coin_diameter_px)
