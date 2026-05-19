"""Regenerate Vera launcher icons + splash logo.

Concept: 'Mark V' — a thick geometric V, no ornamentation.
  - Stripe / Vercel / Linear visual language: one form, full stop.
  - Cream V (#F2EEE4, same colour as the app's body text) on a deep plum
    radial gradient. No sparkles, no dots, no accent colours.
  - Subtle inner highlight on the V for premium depth, nothing more.

Colours pulled from lib/core/theme/palette.dart ('plum' is the default palette).
"""
from __future__ import annotations
import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "branding"
OUT.mkdir(parents=True, exist_ok=True)

SIZE = 1024
SS = 4

CREAM      = (242, 238, 228, 255)   # #F2EEE4  brandFG
CREAM_SOFT = (220, 213, 199, 255)   # darker cream for inner highlight
PLUM_SOFT  = ( 90,  58, 101, 255)   # #5A3A65  brandSoft
PLUM       = ( 61,  38,  69, 255)   # #3D2645  brand
PLUM_DEEP  = ( 26,  19,  37, 255)   # #1A1325  splash bg

def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(len(a)))

def radial_gradient(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size))
    px = img.load()
    cx, cy = size * 0.38, size * 0.30
    max_d = math.hypot(size, size)
    for y in range(size):
        for x in range(size):
            d = math.hypot(x - cx, y - cy) / max_d
            d = min(1.0, d * 1.45)
            if d < 0.40:
                c = lerp(PLUM_SOFT, PLUM, d / 0.40)
            else:
                c = lerp(PLUM, PLUM_DEEP, (d - 0.40) / 0.60)
            px[x, y] = (c[0], c[1], c[2], 255)
    return img

def aa_polygon(canvas: Image.Image, points, color):
    """4x supersampled antialiased polygon."""
    w, h = canvas.size
    mask = Image.new("L", (w * SS, h * SS), 0)
    md = ImageDraw.Draw(mask)
    md.polygon([(p[0] * SS, p[1] * SS) for p in points], fill=255)
    mask = mask.resize((w, h), Image.LANCZOS)
    fill_alpha = color[3] if len(color) == 4 else 255
    solid = Image.new("RGBA", (w, h), (color[0], color[1], color[2], fill_alpha))
    transparent = Image.new("RGBA", (w, h), (color[0], color[1], color[2], 0))
    canvas.alpha_composite(Image.composite(solid, transparent, mask))

def v_polygon(cx: float, cy: float, span: float, height: float, thick: float):
    """Build the thick geometric V as a single closed polygon.

    span    – outer width of the V at the top
    height  – vertical extent (top edge → bottom tip)
    thick   – stroke thickness of each leg
    """
    top_y    = cy - height / 2
    bot_y    = cy + height / 2
    left_x   = cx - span / 2
    right_x  = cx + span / 2

    # The inner notch sits a tiny bit above the bottom tip so the inside of
    # the V doesn't bottom out before the outside.
    inner_dy = thick * 1.05

    return [
        (left_x,          top_y),                  # top-left outer
        (left_x + thick,  top_y),                  # top-left inner
        (cx,              bot_y - inner_dy),       # inner notch
        (right_x - thick, top_y),                  # top-right inner
        (right_x,         top_y),                  # top-right outer
        (cx,              bot_y),                  # bottom tip
    ]

def compose_v(canvas: Image.Image, scale: float = 1.0, *, with_shadow: bool):
    """Draw the V mark dead-centre."""
    w = canvas.size[0]
    cx, cy = w / 2, w / 2

    # Geometric V proportions — Stripe-thick but still readable at 48dp.
    span   = w * 0.62 * scale
    height = w * 0.56 * scale
    thick  = w * 0.165 * scale     # noticeably chunkier than the previous V

    poly = v_polygon(cx, cy, span, height, thick)

    if with_shadow:
        shadow = Image.new("RGBA", (w, w), (0, 0, 0, 0))
        sh_poly = [(x, y + w * 0.018) for (x, y) in poly]
        aa_polygon(shadow, sh_poly, (0, 0, 0, 110))
        shadow = shadow.filter(ImageFilter.GaussianBlur(radius=w * 0.014))
        canvas.alpha_composite(shadow)

    aa_polygon(canvas, poly, CREAM)

    # Very subtle inner top-highlight — a thin band of slightly brighter
    # cream along the top edge, gives a hint of depth without ornament.
    # Implemented as a 6%-tall stripe near the top of each leg, clipped to
    # the V via mask reuse.
    hl_layer = Image.new("RGBA", (w, w), (0, 0, 0, 0))
    hl_draw = ImageDraw.Draw(hl_layer)
    top_y    = cy - height / 2
    left_x   = cx - span / 2
    right_x  = cx + span / 2
    hl_h     = thick * 0.18
    hl_draw.rectangle([left_x, top_y, left_x + thick, top_y + hl_h], fill=(255, 255, 255, 60))
    hl_draw.rectangle([right_x - thick, top_y, right_x, top_y + hl_h], fill=(255, 255, 255, 60))
    # Mask the highlight to the V polygon.
    v_mask = Image.new("L", (w * SS, h_full := w * SS), 0)
    vm = ImageDraw.Draw(v_mask)
    vm.polygon([(p[0] * SS, p[1] * SS) for p in poly], fill=255)
    v_mask = v_mask.resize((w, w), Image.LANCZOS)
    clipped = Image.composite(hl_layer, Image.new("RGBA", (w, w), (0, 0, 0, 0)), v_mask)
    canvas.alpha_composite(clipped)

# ─── outputs ─────────────────────────────────────────────────────────────
bg = radial_gradient(SIZE)
bg.save(OUT / "icon_background.png")
print("wrote icon_background.png")

# Adaptive foreground — fits within the 66% safe zone.
fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
compose_v(fg, scale=0.95, with_shadow=True)
fg.save(OUT / "icon_foreground.png")
print("wrote icon_foreground.png")

# Legacy composite icon.
legacy = bg.copy()
# Soft vignette in bottom-right for depth.
vignette = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
vd = ImageDraw.Draw(vignette)
vd.ellipse([SIZE * 0.30, SIZE * 0.35, SIZE * 1.25, SIZE * 1.25],
           fill=(PLUM_DEEP[0], PLUM_DEEP[1], PLUM_DEEP[2], 110))
vignette = vignette.filter(ImageFilter.GaussianBlur(radius=SIZE * 0.10))
legacy.alpha_composite(vignette)
compose_v(legacy, scale=0.95, with_shadow=True)
legacy.save(OUT / "icon.png")
print("wrote icon.png")

# Splash logo — transparent, on dark #1A1325 splash bg.
splash = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
compose_v(splash, scale=1.00, with_shadow=False)
splash.save(OUT / "splash_logo.png")
print("wrote splash_logo.png")

print("done")
