#!/usr/bin/env python3
"""Draw the app icon (same spectrum design as the Android app) with Pillow.

Writes App/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png (opaque RGB, as App Store
Connect requires) and assets/wifi-spectrum.png for the README.
"""
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
S = 1024
SCALE = 4  # supersample, then downscale for smooth edges
BG = (11, 15, 20)


def cubic(p0, p1, p2, p3, steps=200):
    out = []
    for i in range(steps + 1):
        t = i / steps
        u = 1 - t
        out.append((u**3 * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t**3 * p3[0],
                    u**3 * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t**3 * p3[1]))
    return out


def stroke(d, points, radius, color):
    """Round-brush stroke: stamp discs along the path so thick curves have smooth edges."""
    step = max(1.0, radius / 4)
    for (x0, y0), (x1, y1) in zip(points, points[1:]):
        n = max(1, int(((x1 - x0) ** 2 + (y1 - y0) ** 2) ** 0.5 / step))
        for i in range(n + 1):
            x, y = x0 + (x1 - x0) * i / n, y0 + (y1 - y0) * i / n
            d.ellipse([x - radius, y - radius, x + radius, y + radius], fill=color)


def draw() -> Image.Image:
    size = S * SCALE
    img = Image.new('RGB', (size, size), BG)
    layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    k = size / 108 * 1.45
    off_x = size / 2 - 54 * k
    off_y = size / 2 - 54 * k + 30 * SCALE

    def pt(x, y):
        return (off_x + x * k, off_y + y * k)

    stroke(d, [pt(28, 72), pt(80, 72)], 0.75 * k, (58, 71, 87, 255))
    curves = [
        ((255, 79, 163), [(50, 72), (55, 36), (75, 36), (80, 72)]),
        ((60, 227, 138), [(28, 72), (33, 26), (53, 26), (58, 72)]),
        ((43, 196, 255), [(38, 72), (43, 48), (57, 48), (62, 72)]),
    ]
    for color, ctrl in curves:
        poly = cubic(*[pt(*c) for c in ctrl])
        fill = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        ImageDraw.Draw(fill).polygon(poly, fill=color + (60,))
        layer = Image.alpha_composite(layer, fill)
        d = ImageDraw.Draw(layer)
        stroke(d, poly + [poly[0]], 1.5 * k, color + (255,))
    img.paste(layer, (0, 0), layer)
    return img.resize((S, S), Image.LANCZOS)


def main():
    icon = draw()
    out = ROOT / 'App' / 'Assets.xcassets' / 'AppIcon.appiconset' / 'AppIcon-1024.png'
    icon.save(out, optimize=True)
    icon.resize((512, 512), Image.LANCZOS).save(ROOT / 'assets' / 'wifi-spectrum.png', optimize=True)
    print('wrote', out)


if __name__ == '__main__':
    main()
