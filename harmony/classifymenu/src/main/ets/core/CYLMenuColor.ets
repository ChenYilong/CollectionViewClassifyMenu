/**
 * `CYLMenuColorFromString`: "#RGB", "#RRGGBB", "#RRGGBBAA" (alpha last, as on iOS), or the name of a UIColor class
 * property ("systemBlue", "systemBlueColor", "red"...), as '#AARRGGBB'; undefined when it is none of them.
 */
import { CYLColor } from './CYLTypes';

/** The UIColor class properties a configuration may name, in their light appearance. */
const UI_COLOR_NAMES: Map<string, string> = new Map<string, string>([
  ['black', CYLColor.BLACK], ['white', CYLColor.WHITE], ['clear', CYLColor.CLEAR],
  ['darkGray', CYLColor.white(1 / 3)], ['lightGray', CYLColor.white(2 / 3)], ['gray', CYLColor.white(0.5)],
  ['red', '#FFFF0000'], ['green', '#FF00FF00'], ['blue', '#FF0000FF'], ['cyan', '#FF00FFFF'],
  ['yellow', '#FFFFFF00'], ['magenta', '#FFFF00FF'], ['orange', CYLColor.rgb(1, 0.5, 0)],
  ['purple', CYLColor.rgb(0.5, 0, 0.5)], ['brown', CYLColor.rgb(0.6, 0.4, 0.2)],
  ['systemRed', CYLColor.argb(255, 255, 59, 48)], ['systemOrange', CYLColor.argb(255, 255, 149, 0)],
  ['systemYellow', CYLColor.argb(255, 255, 204, 0)], ['systemGreen', CYLColor.argb(255, 52, 199, 89)],
  ['systemMint', CYLColor.argb(255, 0, 199, 190)], ['systemTeal', CYLColor.argb(255, 48, 176, 199)],
  ['systemCyan', CYLColor.argb(255, 50, 173, 230)], ['systemBlue', CYLColor.argb(255, 0, 122, 255)],
  ['systemIndigo', CYLColor.argb(255, 88, 86, 214)], ['systemPurple', CYLColor.argb(255, 175, 82, 222)],
  ['systemPink', CYLColor.argb(255, 255, 45, 85)], ['systemBrown', CYLColor.argb(255, 162, 132, 94)],
  ['systemGray', CYLColor.argb(255, 142, 142, 147)], ['systemGray2', CYLColor.argb(255, 174, 174, 178)],
  ['systemGray3', CYLColor.argb(255, 199, 199, 204)], ['systemGray4', CYLColor.argb(255, 209, 209, 214)],
  ['systemGray5', CYLColor.argb(255, 229, 229, 234)], ['systemGray6', CYLColor.argb(255, 242, 242, 247)],
  ['label', CYLColor.BLACK], ['secondaryLabel', CYLColor.argb(153, 60, 60, 67)],
  ['tertiaryLabel', CYLColor.argb(76, 60, 60, 67)], ['quaternaryLabel', CYLColor.argb(46, 60, 60, 67)],
  ['systemBackground', CYLColor.WHITE], ['secondarySystemBackground', CYLColor.argb(255, 242, 242, 247)],
  ['tertiarySystemBackground', CYLColor.WHITE], ['separator', CYLColor.argb(73, 60, 60, 67)],
  ['link', CYLColor.argb(255, 0, 122, 255)], ['tint', CYLColor.argb(255, 0, 122, 255)]
]);

export function CYLMenuColorFromString(value: string | undefined): string | undefined {
  if (value === undefined) {
    return undefined;
  }
  const text = value.trim();
  if (text.startsWith('#')) {
    let hex = text.substring(1);
    if (hex.length === 3) {
      hex = Array.from(hex).map((c: string) => c + c).join('');
    }
    if ((hex.length !== 6 && hex.length !== 8) || !new RegExp('^[0-9a-fA-F]+$').test(hex)) {
      return undefined;
    }
    const rgb = hex.substring(0, 6).toUpperCase();
    const alpha = hex.length === 8 ? hex.substring(6, 8).toUpperCase() : 'FF';
    return '#' + alpha + rgb;
  }
  const name = text.endsWith('Color') ? text.substring(0, text.length - 'Color'.length) : text;
  return UI_COLOR_NAMES.get(name);
}

/** The channel bytes of a '#AARRGGBB' or '#RRGGBB' color. */
const ARGB_DIGITS: number = 8;
const RGB_DIGITS: number = 6;
const BYTE_MAX: number = 255;
/** Linearization of an sRGB channel (WCAG 2.x). */
const SRGB_LINEAR_CUTOFF: number = 0.03928;
const SRGB_LINEAR_SLOPE: number = 12.92;
const SRGB_OFFSET: number = 0.055;
const SRGB_SCALE: number = 1.055;
const SRGB_GAMMA: number = 2.4;
const LUMA_RED: number = 0.2126;
const LUMA_GREEN: number = 0.7152;
const LUMA_BLUE: number = 0.0722;

function linearChannel(byte: number): number {
  const c = byte / BYTE_MAX;
  return c <= SRGB_LINEAR_CUTOFF ? c / SRGB_LINEAR_SLOPE : Math.pow((c + SRGB_OFFSET) / SRGB_SCALE, SRGB_GAMMA);
}

/**
 * The WCAG relative luminance (0 black ... 1 white) of sRGB components 0...1 (iOS `CYLTintContrast.relativeLuminance`).
 */
export function CYLMenuRelativeLuminance(red: number, green: number, blue: number): number {
  return LUMA_RED * linearChannel(red * BYTE_MAX) + LUMA_GREEN * linearChannel(green * BYTE_MAX) +
    LUMA_BLUE * linearChannel(blue * BYTE_MAX);
}

/**
 * The WCAG relative luminance (0 black ... 1 white) of an opaque color given as '#AARRGGBB', '#RRGGBB' or a number
 * (0xRRGGBB, or 0xAARRGGBB above 0xFFFFFF). Undefined when the color cannot be read as an opaque color: no color, a
 * transparent or translucent one, or a resource. A resource (`$r(...)`, such as the library's palette) is not resolved: a
 * system resource has no value that a host test or the style can read, only the drawing sees it; the callers use the
 * system mode for it (the library's palette flips with the mode as the system tint does).
 */
export function CYLMenuColorLuminance(color: ResourceColor | undefined): number | undefined {
  let argb: number;
  if (typeof color === 'string') {
    const hex = (color as string).trim().replace('#', '');
    if ((hex.length !== ARGB_DIGITS && hex.length !== RGB_DIGITS) || !new RegExp('^[0-9a-fA-F]+$').test(hex)) {
      return undefined;
    }
    argb = parseInt(hex.length === RGB_DIGITS ? 'FF' + hex : hex, 16);
  } else if (typeof color === 'number') {
    const value = color as number;
    argb = value <= 0xFFFFFF ? 0xFF000000 + value : value;
  } else {
    return undefined;
  }
  const alpha = Math.floor(argb / 0x1000000) % 0x100;
  if (alpha !== BYTE_MAX) {
    return undefined;
  }
  const red = Math.floor(argb / 0x10000) % 0x100;
  const green = Math.floor(argb / 0x100) % 0x100;
  const blue = argb % 0x100;
  return LUMA_RED * linearChannel(red) + LUMA_GREEN * linearChannel(green) + LUMA_BLUE * linearChannel(blue);
}
