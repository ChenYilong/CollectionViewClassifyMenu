"""Draws the sample pictures of CYLAndroidSample.picture(_:) (a diagonal gradient and a large white symbol at 0.55),
the yellow avatar of CYLTagContainerSampleData.avatar() and a globe icon (SF Symbol "globe" stand-in)."""
import math
import os
import sys

from PIL import Image, ImageDraw

OUT = sys.argv[1]
os.makedirs(OUT, exist_ok=True)
S = 600  # pictures: 600 x 600 JPEG (the iOS pictures are 750 x 750 points)
SS = 3   # supersampling for the shapes


def rgb(r, g, b):
    return (round(r * 255), round(g * 255), round(b * 255))


PALETTES = [
    (rgb(0.55, 0.42, 0.33), rgb(0.85, 0.76, 0.66), 'shoes'),
    (rgb(0.25, 0.35, 0.5), rgb(0.7, 0.8, 0.9), 'bag'),
    (rgb(0.3, 0.45, 0.35), rgb(0.78, 0.88, 0.75), 'shirt'),
]


def gradient(light, dark, size):
    img = Image.new('RGB', (size, size))
    px = img.load()
    for y in range(size):
        for x in range(size):
            # CGContext.drawLinearGradient from (0, 0) to (w, h): t is the projection on the diagonal.
            t = (x + y) / (2 * (size - 1))
            px[x, y] = tuple(round(light[i] + (dark[i] - light[i]) * t) for i in range(3))
    return img


def symbol(kind, size):
    """A white silhouette on a transparent layer, about 0.42 of the picture (the symbol's point size)."""
    big = size * SS
    layer = Image.new('L', (big, big), 0)
    d = ImageDraw.Draw(layer)
    c = big / 2
    u = big * 0.42 / 2  # half the symbol size
    if kind == 'shoes':
        # shoeprints.fill: two soles, one higher than the other, slightly turned.
        for dx, dy, angle in ((-0.45, 0.25, -8), (0.45, -0.25, 8)):
            sole = Image.new('L', (big, big), 0)
            sd = ImageDraw.Draw(sole)
            w, h = u * 0.62, u * 1.25
            cx, cy = c + dx * u, c + dy * u
            sd.ellipse([cx - w / 2, cy - h / 2 - h * 0.12, cx + w / 2, cy + h / 2 * 0.55], fill=255)
            sd.ellipse([cx - w * 0.4, cy + h * 0.32, cx + w * 0.4, cy + h * 0.62], fill=255)
            sole = sole.rotate(angle, center=(cx, cy), resample=Image.BICUBIC)
            layer = Image.composite(Image.new('L', (big, big), 255), layer, sole)
    elif kind == 'bag':
        # handbag.fill: a trapezoid body and a handle.
        d = ImageDraw.Draw(layer)
        top, bottom = c - u * 0.35, c + u * 0.95
        d.polygon([(c - u * 0.8, top), (c + u * 0.8, top), (c + u, bottom), (c - u, bottom)], fill=255)
        d.rounded_rectangle([c - u, bottom - u * 0.2, c + u, bottom], radius=u * 0.1, fill=255)
        lw = max(1, round(u * 0.14))
        d.arc([c - u * 0.5, c - u * 1.0, c + u * 0.5, c + u * 0.1], 180, 360, fill=255, width=lw)
    else:
        # tshirt.fill
        d = ImageDraw.Draw(layer)
        pts = [(-0.35, -0.85), (-0.15, -0.85), (0, -0.65), (0.15, -0.85), (0.35, -0.85), (1.0, -0.45), (0.8, 0.0),
               (0.55, -0.15), (0.55, 0.9), (-0.55, 0.9), (-0.55, -0.15), (-0.8, 0.0), (-1.0, -0.45)]
        d.polygon([(c + x * u, c + y * u) for x, y in pts], fill=255)
    return layer.resize((size, size), Image.LANCZOS)


for index, (dark, light, kind) in enumerate(PALETTES):
    img = gradient(light, dark, S).convert('RGBA')
    mask = symbol(kind, S).point(lambda v: round(v * 0.55))
    white = Image.new('RGBA', (S, S), (255, 255, 255, 255))
    white.putalpha(mask)
    img = Image.alpha_composite(img, white).convert('RGB')
    img.save(os.path.join(OUT, f'picture-{index}.jpg'), quality=82, optimize=True)

# The avatar: 48 pt at 3x.
A = 144
big = A * SS
k = big / 48
img = Image.new('RGBA', (big, big), (0, 0, 0, 0))
d = ImageDraw.Draw(img)
yellow = (255, 204, 0, 255)  # systemYellow
brown = (153, 102, 51, 255)  # UIColor.brown
d.ellipse([0, 0, big - 1, big - 1], fill=yellow)
d.ellipse([14 * k, 16 * k, 20 * k, 22 * k], fill=brown)
d.ellipse([28 * k, 16 * k, 34 * k, 22 * k], fill=brown)
r = 11 * k
d.arc([24 * k - r, 26 * k - r, 24 * k + r, 26 * k + r], 0.2 * 180, 0.8 * 180, fill=brown, width=round(3 * k))
img.resize((A, A), Image.LANCZOS).save(os.path.join(OUT, 'avatar.png'), optimize=True)

# The globe: 14 pt at 3x, in the default tag title color (white 0.25).
G = 42
big = G * SS
img = Image.new('RGBA', (big, big), (0, 0, 0, 0))
d = ImageDraw.Draw(img)
gray = (64, 64, 64, 255)
lw = round(big * 0.07)
m = lw
d.ellipse([m, m, big - m, big - m], outline=gray, width=lw)
d.ellipse([big * 0.3, m, big * 0.7, big - m], outline=gray, width=lw)
d.line([big / 2, m, big / 2, big - m], fill=gray, width=lw)
d.line([m, big / 2, big - m, big / 2], fill=gray, width=lw)
for y in (0.27, 0.73):
    half = math.sqrt(max(0, 0.25 - (y - 0.5) ** 2)) * (big - 2 * m)
    d.line([big / 2 - half, big * y, big / 2 + half, big * y], fill=gray, width=lw)
img.resize((G, G), Image.LANCZOS).save(os.path.join(OUT, 'globe.png'), optimize=True)
print('ok')
