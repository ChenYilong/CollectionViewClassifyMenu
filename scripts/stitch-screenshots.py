#!/usr/bin/env python3
"""Stitches labeled screenshots by the rules of AGENTS.md ("CI/CD and Example screenshots"), on any host.

The cross-platform twin of scripts/stitch-screenshots.swift (macOS only), with the same arguments:

    python3 scripts/stitch-screenshots.py --out docs/assets/<name>.png [--columns auto|1|2] [--crop x,y,w,h] \
      --header "Purpose: ..." --header "Platform: ... | Host: ... | IDE: ..." \
      --footer "Result: ..." --footer "Versions: ..." --footer "Taken: ... | Stitched by scripts/stitch-screenshots.py" \
      "1. <caption>::<image>" "2. <caption>::<image>" ...

Layout: one column first, panels top to bottom; two columns (left to right, then top to bottom) when the one-column
image would be taller than one phone screen (height > 19.5 / 9 x width); never more than two. A header band above the
panels, a footer band below them and a caption band above every panel; no text is drawn on a screenshot. The panels
keep their original pixels (no scaling); --crop cuts the same rectangle out of every image (crop to whole elements).

The label is required, not optional: the tool stops when the header lacks "Purpose:", "Platform:", "Host:" or "IDE:",
when the footer lacks "Result:", "Versions:" or "Taken:", or when a panel has no caption. It writes the header and
footer into the PNG (text chunk "Description", starting with "cyl-stitch-screenshots"), which
scripts/check-screenshots.py checks before a commit.
"""
import argparse
import sys

from PIL import Image, ImageDraw, ImageFont
from PIL.PngImagePlugin import PngInfo

MARKER = 'cyl-stitch-screenshots'
HEADER_FIELDS = ('Purpose:', 'Platform:', 'Host:', 'IDE:')
FOOTER_FIELDS = ('Result:', 'Versions:', 'Taken:')
RED = (255, 59, 48)  # #FF3B30, iOS system red
DARK_GRAY = (85, 85, 85)
RULE = (200, 200, 200)
MARGIN, GAP, PHONE_SCREEN = 24, 24, 19.5 / 9
BOLD_FONTS = ('arialbd.ttf', 'Arial Bold.ttf', 'DejaVuSans-Bold.ttf', 'Helvetica-Bold.ttf', 'LiberationSans-Bold.ttf')
REGULAR_FONTS = ('arial.ttf', 'Arial.ttf', 'DejaVuSans.ttf', 'Helvetica.ttf', 'LiberationSans-Regular.ttf')


def missing_fields(lines, fields):
    text = '\n'.join(lines)
    return [field for field in fields if field not in text]


def font(names, size):
    for name in names:
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default(size)


def wrap(draw, text, face, width):
    """Lines of `text` that fit `width` pixels (explicit newlines kept)."""
    lines = []
    for paragraph in text.split('\n'):
        line = ''
        for word in paragraph.split(' '):
            candidate = word if not line else f'{line} {word}'
            if draw.textlength(candidate, font=face) <= width or not line:
                line = candidate
            else:
                lines.append(line)
                line = word
        lines.append(line)
    return lines


def text_height(draw, lines, face):
    ascent, descent = face.getmetrics()
    return len(lines) * (ascent + descent + 4)


def draw_lines(draw, xy, lines, face, fill):
    x, y = xy
    ascent, descent = face.getmetrics()
    for line in lines:
        draw.text((x, y), line, font=face, fill=fill)
        y += ascent + descent + 4


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--out', required=True)
    parser.add_argument('--columns', default='auto', choices=['auto', '1', '2'])
    parser.add_argument('--crop')
    parser.add_argument('--header', action='append', default=[])
    parser.add_argument('--footer', action='append', default=[])
    parser.add_argument('panels', nargs='+', help='"<caption>::<image>"')
    args = parser.parse_args()

    errors = []
    if not args.out.lower().endswith('.png'):
        errors.append('--out must be a .png file')
    missing = missing_fields(args.header, HEADER_FIELDS)
    if missing:
        errors.append(f'the header lacks {", ".join(missing)} (AGENTS.md "Screenshots: header and footer")')
    missing = missing_fields(args.footer, FOOTER_FIELDS)
    if missing:
        errors.append(f'the footer lacks {", ".join(missing)} (AGENTS.md "Screenshots: header and footer")')
    panels = []
    for value in args.panels:
        caption, sep, path = value.partition('::')
        if not sep or not caption.strip():
            errors.append(f'panel "{value}": use "<caption>::<image>" with a caption')
        panels.append((caption.strip(), path))
    if errors:
        sys.exit('stitch-screenshots: ' + '; '.join(errors))

    images = [Image.open(path).convert('RGB') for _, path in panels]
    crop = None
    if args.crop:
        x, y, w, h = (int(float(v)) for v in args.crop.split(','))
        crop = (x, y, x + w, y + h)
        images = [image.crop(crop) for image in images]
    cell_w = max(image.width for image in images)
    cell_h = max(image.height for image in images)
    probe = ImageDraw.Draw(Image.new('RGB', (1, 1)))

    def layout(columns):
        cols = min(columns, len(images))
        rows = (len(images) + cols - 1) // cols
        width = MARGIN * 2 + cell_w * cols + GAP * (cols - 1)
        # Text scales with the image, so it stays readable next to full-resolution panels.
        header_font = font(BOLD_FONTS, max(20, round(width / 55)))
        caption_font = font(BOLD_FONTS, max(18, round(cell_w / 32)))
        footer_font = font(REGULAR_FONTS, max(16, round(width / 70)))
        header = wrap(probe, '\n'.join(args.header), header_font, width - MARGIN * 2)
        footer = wrap(probe, '\n'.join(args.footer), footer_font, width - MARGIN * 2)
        captions = [wrap(probe, caption, caption_font, cell_w) for caption, _ in panels]
        header_h = text_height(probe, header, header_font) + MARGIN * 2
        footer_h = text_height(probe, footer, footer_font) + MARGIN * 2
        caption_h = max(text_height(probe, lines, caption_font) for lines in captions) + 12
        total = header_h + rows * (caption_h + cell_h) + (rows - 1) * GAP + footer_h
        return dict(cols=cols, rows=rows, width=width, total=total, header=header, footer=footer, captions=captions,
                    header_h=header_h, footer_h=footer_h, caption_h=caption_h, header_font=header_font,
                    caption_font=caption_font, footer_font=footer_font)

    one = layout(1)
    if args.columns == 'auto':
        chosen = layout(2) if one['total'] > one['width'] * PHONE_SCREEN else one
    else:
        chosen = layout(int(args.columns))

    canvas = Image.new('RGB', (chosen['width'], chosen['total']), 'white')
    draw = ImageDraw.Draw(canvas)
    draw_lines(draw, (MARGIN, MARGIN), chosen['header'], chosen['header_font'], RED)
    draw.rectangle((0, chosen['header_h'] - 2, chosen['width'], chosen['header_h']), fill=RULE)
    footer_top = chosen['total'] - chosen['footer_h']
    draw.rectangle((0, footer_top, chosen['width'], footer_top + 2), fill=RULE)
    draw_lines(draw, (MARGIN, footer_top + MARGIN), chosen['footer'], chosen['footer_font'], DARK_GRAY)
    row_h = chosen['caption_h'] + cell_h
    for i, image in enumerate(images):
        col, row = i % chosen['cols'], i // chosen['cols']
        x = MARGIN + col * (cell_w + GAP)
        top = chosen['header_h'] + row * (row_h + GAP)
        draw_lines(draw, (x, top + 4), chosen['captions'][i], chosen['caption_font'], RED)
        canvas.paste(image, (x, top + chosen['caption_h']))  # original pixels, no scaling

    info = PngInfo()
    info.add_itxt('Description', '\n'.join([MARKER, *args.header, *args.footer]))
    canvas.save(args.out, pnginfo=info)
    print(f'{args.out}: {chosen["width"]} x {chosen["total"]} px, {chosen["cols"]} columns x {chosen["rows"]} rows')


if __name__ == '__main__':
    main()
