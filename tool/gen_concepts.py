"""Render three distinct Vera icon concepts side-by-side for review.

Outputs:
  tool/concepts/01_orbit.png      Saturn-like sphere + tilted ring
  tool/concepts/02_crescent.png   Crescent moon + gold dot (Apple Music vibe, finance/AI)
  tool/concepts/03_chevrons.png   Three ascending chevrons (abstract growth)
  tool/concepts/grid.png          Combined preview grid
"""
from __future__ import annotations
import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "tool" / "concepts"
OUT.mkdir(parents=True, exist_ok=True)

SIZE = 1024
SS = 4

CREAM     = (242, 238, 228, 255)
PLUM_SOFT = ( 90,  58, 101, 255)
PLUM      = ( 61,  38,  69, 255)
PLUM_DEEP = ( 26,  19,  37, 255)
GOLD      = (214, 178, 112, 255)
UMA_GREEN = ( 46, 171, 126, 255)

def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(len(a)))

def radial_bg(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size))
    px = img.load()
    cx, cy = size * 0.40, size * 0.32
    max_d = math.hypot(size, size)
    for y in range(size):
        for x in range(size):
            d = math.hypot(x - cx, y - cy) / max_d
            d = min(1.0, d * 1.45)
            if d < 0.42:
                c = lerp(PLUM_SOFT, PLUM, d / 0.42)
            else:
                c = lerp(PLUM, PLUM_DEEP, (d - 0.42) / 0.58)
            px[x, y] = (c[0], c[1], c[2], 255)
    return img

def aa_draw(canvas: Image.Image, draw_fn):
    """Render a draw function at 4x then downsample for crisp AA."""
    w, h = canvas.size
    big = Image.new("RGBA", (w * SS, h * SS), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    draw_fn(d, SS)
    small = big.resize((w, h), Image.LANCZOS)
    canvas.alpha_composite(small)

# ─────────────────────────────────────────────────────────────────────
# Concept 1 — Orbit: a tilted ring around a small sphere
# ─────────────────────────────────────────────────────────────────────
def concept_orbit() -> Image.Image:
    canvas = radial_bg(SIZE)
    w = SIZE
    cx, cy = w / 2, w / 2

    # Tilted ring (ellipse stroke). Created by drawing a thick ellipse minus an inner ellipse.
    def ring(d, ss):
        # outer & inner ellipse with rotation
        # We draw axis-aligned, then rotate the whole layer below — but since
        # aa_draw operates on a single big canvas, just draw it rotated mathematically.
        pass

    # Use a separate rotated layer for the ring.
    ring_layer = Image.new("RGBA", (w * SS, w * SS), (0, 0, 0, 0))
    rd = ImageDraw.Draw(ring_layer)
    rx, ry = w * 0.42, w * 0.16  # ring radii
    thick = w * 0.045
    rd.ellipse([(cx - rx) * SS, (cy - ry) * SS, (cx + rx) * SS, (cy + ry) * SS], fill=GOLD)
    rd.ellipse(
        [(cx - rx + thick) * SS, (cy - ry + thick * 0.6) * SS,
         (cx + rx - thick) * SS, (cy + ry - thick * 0.6) * SS],
        fill=(0, 0, 0, 0),
    )
    ring_layer = ring_layer.rotate(-22, resample=Image.BICUBIC, center=(cx * SS, cy * SS))
    ring_layer = ring_layer.resize((w, w), Image.LANCZOS)

    # Sphere with gradient
    sphere_layer = Image.new("RGBA", (w, w), (0, 0, 0, 0))
    sphere_r = w * 0.22
    spx = sphere_layer.load()
    sx, sy = cx - w * 0.04, cy - w * 0.04
    for y in range(w):
        for x in range(w):
            d = math.hypot(x - cx, y - cy)
            if d <= sphere_r:
                hl = math.hypot(x - sx, y - sy) / (sphere_r * 1.4)
                hl = min(1.0, hl)
                col = lerp(CREAM, lerp(CREAM, PLUM, 0.55), hl ** 1.6)
                spx[x, y] = (col[0], col[1], col[2], 255)

    # Composite: back half of ring → sphere → front half of ring
    # Quick approximation: draw ring, then sphere on top, then a "front half" copy
    # of the ring clipped to the lower portion to give depth.
    canvas.alpha_composite(ring_layer)
    canvas.alpha_composite(sphere_layer)

    # Front arc of ring (just lower half of the ring layer, masked)
    front_mask = Image.new("L", (w, w), 0)
    fd = ImageDraw.Draw(front_mask)
    fd.rectangle([0, int(cy + sphere_r * 0.20), w, w], fill=255)
    front_arc = Image.composite(ring_layer, Image.new("RGBA", (w, w), (0, 0, 0, 0)), front_mask)
    canvas.alpha_composite(front_arc)

    # Two tiny gold orbit-dots
    for ang, r in ((35, 0.46), (200, 0.46)):
        ox = cx + math.cos(math.radians(ang)) * w * r * math.cos(math.radians(22))
        oy = cy + math.sin(math.radians(ang)) * w * 0.18
        dot = Image.new("RGBA", (w, w), (0, 0, 0, 0))
        dd = ImageDraw.Draw(dot)
        dr = w * 0.020
        dd.ellipse([ox - dr, oy - dr, ox + dr, oy + dr], fill=GOLD)
        canvas.alpha_composite(dot)
    return canvas

# ─────────────────────────────────────────────────────────────────────
# Concept 2 — Crescent: a fat cream crescent + a small gold dot inside the bowl
# ─────────────────────────────────────────────────────────────────────
def concept_crescent() -> Image.Image:
    canvas = radial_bg(SIZE)
    w = SIZE
    cx, cy = w / 2, w / 2

    # Halo glow
    halo = Image.new("RGBA", (w, w), (0, 0, 0, 0))
    hd = ImageDraw.Draw(halo)
    hd.ellipse([cx - w * 0.38, cy - w * 0.38, cx + w * 0.38, cy + w * 0.38],
               fill=(GOLD[0], GOLD[1], GOLD[2], 50))
    halo = halo.filter(ImageFilter.GaussianBlur(radius=w * 0.07))
    canvas.alpha_composite(halo)

    # Crescent = big cream circle minus an offset circle (the bite)
    moon = Image.new("RGBA", (w * SS, w * SS), (0, 0, 0, 0))
    md = ImageDraw.Draw(moon)
    outer_r = w * 0.34
    bite_dx = w * 0.13     # how far the bite is shifted (smaller = thinner crescent)
    bite_r = outer_r - w * 0.005  # bite size: nearly outer_r gives a thin crescent; smaller is fatter
    md.ellipse([(cx - outer_r) * SS, (cy - outer_r) * SS,
                (cx + outer_r) * SS, (cy + outer_r) * SS], fill=CREAM)
    md.ellipse([(cx - outer_r + bite_dx) * SS, (cy - outer_r + bite_dx * 0.1) * SS,
                (cx + outer_r + bite_dx) * SS, (cy + outer_r + bite_dx * 0.1) * SS],
               fill=(0, 0, 0, 0))
    moon = moon.resize((w, w), Image.LANCZOS)
    # Tilt the crescent 20° so it sits like a bowl, opening to upper-right.
    moon = moon.rotate(35, resample=Image.BICUBIC, center=(cx, cy))
    canvas.alpha_composite(moon)

    # Gold dot in the open bowl of the crescent (offset toward the gap)
    dot = Image.new("RGBA", (w, w), (0, 0, 0, 0))
    dd = ImageDraw.Draw(dot)
    dx_x, dy_y = cx + w * 0.07, cy - w * 0.13
    dr = w * 0.055
    dd.ellipse([dx_x - dr, dy_y - dr, dx_x + dr, dy_y + dr], fill=GOLD)
    canvas.alpha_composite(dot)

    # Tiny green Uma spark above the dot
    spark = Image.new("RGBA", (w, w), (0, 0, 0, 0))
    sd = ImageDraw.Draw(spark)
    sx, sy = cx + w * 0.20, cy - w * 0.27
    sr = w * 0.022
    sd.ellipse([sx - sr, sy - sr, sx + sr, sy + sr], fill=UMA_GREEN)
    canvas.alpha_composite(spark)
    return canvas

# ─────────────────────────────────────────────────────────────────────
# Concept 3 — Chevrons: three ascending chevron-bars (abstract growth)
# ─────────────────────────────────────────────────────────────────────
def concept_chevrons() -> Image.Image:
    canvas = radial_bg(SIZE)
    w = SIZE
    cx, cy = w / 2, w / 2

    # Three ascending rounded bars at 30° tilt — like Adidas mountains but
    # with offset heights (small / medium / large) suggesting growth.
    bars = Image.new("RGBA", (w * SS, w * SS), (0, 0, 0, 0))
    bd = ImageDraw.Draw(bars)

    bar_w = w * 0.085
    base_x = cx - w * 0.22
    base_y = cy + w * 0.20
    gap    = w * 0.115
    heights = [0.22, 0.32, 0.42]
    colors  = [GOLD, CREAM, CREAM]

    for i, (hf, col) in enumerate(zip(heights, colors)):
        bh = w * hf
        x0 = base_x + i * gap
        x1 = x0 + bar_w
        y0 = base_y - bh
        y1 = base_y
        # Rounded rect via rectangle + two circles for caps
        bd.rectangle([x0 * SS, (y0 + bar_w / 2) * SS, x1 * SS, (y1 - bar_w / 2) * SS], fill=col)
        bd.ellipse([x0 * SS, y0 * SS, x1 * SS, (y0 + bar_w) * SS], fill=col)
        bd.ellipse([x0 * SS, (y1 - bar_w) * SS, x1 * SS, y1 * SS], fill=col)

    bars = bars.resize((w, w), Image.LANCZOS)
    canvas.alpha_composite(bars)

    # Small gold sparkle above the tallest bar
    spark = Image.new("RGBA", (w * SS, w * SS), (0, 0, 0, 0))
    sd = ImageDraw.Draw(spark)
    sx, sy = (cx + w * 0.22), (cy - w * 0.30)
    r = w * 0.045
    short = r * 0.20
    pts = [
        (sx, sy - r), (sx + short, sy - short),
        (sx + r, sy), (sx + short, sy + short),
        (sx, sy + r), (sx - short, sy + short),
        (sx - r, sy), (sx - short, sy - short),
    ]
    sd.polygon([(p[0] * SS, p[1] * SS) for p in pts], fill=GOLD)
    spark = spark.resize((w, w), Image.LANCZOS)
    canvas.alpha_composite(spark)
    return canvas

orbit = concept_orbit();      orbit.save(OUT / "01_orbit.png")
crescent = concept_crescent(); crescent.save(OUT / "02_crescent.png")
chevrons = concept_chevrons(); chevrons.save(OUT / "03_chevrons.png")

# Combined grid for side-by-side review
GRID_W = SIZE * 3 + 60
GRID_H = SIZE + 20
grid = Image.new("RGBA", (GRID_W, GRID_H), (0, 0, 0, 255))
for i, im in enumerate((orbit, crescent, chevrons)):
    grid.paste(im, (10 + i * (SIZE + 20), 10))
grid.thumbnail((1800, 600), Image.LANCZOS)
grid.save(OUT / "grid.png")
print("rendered concepts at", OUT)
