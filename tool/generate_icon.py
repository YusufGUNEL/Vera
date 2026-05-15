"""Generate Vera app icon & splash assets."""
import os
import math
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS_DIR = os.path.join(ROOT, "assets", "branding")
os.makedirs(ASSETS_DIR, exist_ok=True)


def hex_to_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))


# Vera brand palette aligned with app_tokens uma palette
UMA = hex_to_rgb("#7C3AED")        # deep purple
UMA_LIGHT = hex_to_rgb("#C4B5FD")  # light purple highlight
DEEP_BG = hex_to_rgb("#1A1325")    # deep brand background
WHITE = (255, 255, 255)


def draw_radial(size, center, inner_color, outer_color, radius):
    img = Image.new("RGBA", (size, size), outer_color + (255,))
    px = img.load()
    cx, cy = center
    for y in range(size):
        for x in range(size):
            dx = x - cx
            dy = y - cy
            d = math.sqrt(dx * dx + dy * dy) / radius
            d = min(1.0, d)
            r = int(inner_color[0] * (1 - d) + outer_color[0] * d)
            g = int(inner_color[1] * (1 - d) + outer_color[1] * d)
            b = int(inner_color[2] * (1 - d) + outer_color[2] * d)
            px[x, y] = (r, g, b, 255)
    return img


def make_sparkle(size, color, scale=0.55):
    """Draw a sparkle (4-pointed star) similar to auto_awesome icon."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx = cy = size // 2
    half = int(size * scale / 2)
    thin = int(half * 0.18)

    # main vertical/horizontal diamond
    points_main = [
        (cx, cy - half),
        (cx + thin, cy - thin),
        (cx + half, cy),
        (cx + thin, cy + thin),
        (cx, cy + half),
        (cx - thin, cy + thin),
        (cx - half, cy),
        (cx - thin, cy - thin),
    ]
    d.polygon(points_main, fill=color)

    # smaller diagonal sparkle for depth
    small = int(half * 0.32)
    small_thin = int(small * 0.22)
    offset = int(half * 0.85)
    for dx, dy in [(offset, -offset), (-offset, offset)]:
        cxs, cys = cx + dx, cy + dy
        diag_points = [
            (cxs, cys - small),
            (cxs + small_thin, cys - small_thin),
            (cxs + small, cys),
            (cxs + small_thin, cys + small_thin),
            (cxs, cys + small),
            (cxs - small_thin, cys + small_thin),
            (cxs - small, cys),
            (cxs - small_thin, cys - small_thin),
        ]
        d.polygon(diag_points, fill=color)

    return img


def generate_icon(size=1024):
    # background: radial gradient highlight at top-left
    inner = UMA_LIGHT
    outer = UMA
    base = draw_radial(size, (int(size * 0.32), int(size * 0.30)), inner, outer, size * 0.95)

    # subtle deep shadow on bottom-right for premium feel
    shadow_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow_layer)
    sd.ellipse(
        [
            int(size * 0.55),
            int(size * 0.55),
            int(size * 1.05),
            int(size * 1.05),
        ],
        fill=DEEP_BG + (90,),
    )
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(radius=size * 0.04))
    base = Image.alpha_composite(base, shadow_layer)

    # sparkle overlay
    sparkle = make_sparkle(size, WHITE + (245,), scale=0.62)
    base = Image.alpha_composite(base, sparkle)

    return base


def main():
    icon = generate_icon(1024)
    icon.save(os.path.join(ASSETS_DIR, "icon.png"))

    # Adaptive icon foreground: same sparkle on transparent bg, padded
    fg = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    sparkle = make_sparkle(1024, WHITE + (255,), scale=0.42)
    fg = Image.alpha_composite(fg, sparkle)
    fg.save(os.path.join(ASSETS_DIR, "icon_foreground.png"))

    # Background image for adaptive icon
    bg = draw_radial(1024, (int(1024 * 0.32), int(1024 * 0.30)), UMA_LIGHT, UMA, 1024 * 0.95)
    bg.save(os.path.join(ASSETS_DIR, "icon_background.png"))

    # Splash centerpiece: sparkle on transparent background, smaller
    splash_logo = Image.new("RGBA", (768, 768), (0, 0, 0, 0))
    sparkle_splash = make_sparkle(768, UMA + (255,), scale=0.60)
    splash_logo = Image.alpha_composite(splash_logo, sparkle_splash)
    splash_logo.save(os.path.join(ASSETS_DIR, "splash_logo.png"))

    print("Generated:")
    for fname in ("icon.png", "icon_foreground.png", "icon_background.png", "splash_logo.png"):
        p = os.path.join(ASSETS_DIR, fname)
        print(" ", p, os.path.getsize(p), "bytes")


if __name__ == "__main__":
    main()
