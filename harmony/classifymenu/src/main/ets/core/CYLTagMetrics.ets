/**
 * The font scale limit and the tag height of the core, as iOS `CYLTagMetrics`: titles scale with the system font
 * size up to `maximumFontScale`, and a tag is never shorter than its title line plus the vertical padding.
 */
import { CYLFont } from './CYLTypes';

/** The vertical padding of a tag around its title line (iOS `verticalPadding`). */
const VERTICAL_PADDING: number = 10;
/** The line height of the system font per point of size (SF's `lineHeight` / `pointSize`). */
const LINE_HEIGHT_RATIO: number = 1.2;

export class CYLTagMetrics {
  /** The largest font scale a tag title takes. */
  static readonly maximumFontScale: number = 2;
  /** The default title size, fp. */
  static readonly titleFontSize: number = 16;

  /** A system font of `size` scaled by `fontScale` (the system font scale), up to `maximumFontScale`. */
  static scaledSystemFont(size: number, fontScale: number = 1): CYLFont {
    return CYLFont.systemFont(size * Math.min(Math.max(fontScale, 0), CYLTagMetrics.maximumFontScale));
  }

  /** The height of a tag with `font`: its line height plus the vertical padding, at least `minimumHeight`. */
  static tagHeight(font: CYLFont, minimumHeight: number): number {
    return Math.max(minimumHeight, Math.ceil(font.size * LINE_HEIGHT_RATIO) + VERTICAL_PADDING);
  }

  /** The default title font at `fontScale`. */
  static titleFont(fontScale: number = 1): CYLFont {
    return CYLTagMetrics.scaledSystemFont(CYLTagMetrics.titleFontSize, fontScale);
  }
}
