/**
 * `CYLIconContrast` (iOS `CYLIconContrast.swift`): the dark Liquid Glass icon lift. An EXPLICIT, static icon color that is
 * too dark for the dark glass behind it is lifted (HSL lightness, hue and saturation kept) until it reaches a 3:1 WCAG
 * contrast against the glass over black. Everything else is unchanged: a color that already passes, a resource (a theme
 * color is dynamic: it follows the mode itself). The caller applies it only where glass is drawn and the mode is dark
 * (`CYLTagButton`, docs/tag-liquid-glass.md "Dark glass icon lift"). Pure: no platform state is read.
 */
import { CYLColor } from './CYLTypes';
import { CYLMenuRelativeLuminance } from './CYLMenuColor';

const BYTE_MAX: number = 255;
const RGB_DIGITS: number = 6;
const ARGB_DIGITS: number = 8;
const HEX_RADIX: number = 16;
const HEX_PATTERN: string = '^[0-9a-fA-F]+$';
/** The lightness step of the lift (0...1). */
const LIGHTNESS_STEP: number = 0.005;
/** The luminance contrast ratio bounds: (lighter + offset) / (darker + offset). */
const LUMINANCE_OFFSET: number = 0.05;
const HUE_SECTORS: number = 6;
const SECTOR_PAIR: number = 2;

/** The sRGB components 0...1 and the alpha 0...1 of a color. */
export class CYLRGBA {
  red: number = 0;
  green: number = 0;
  blue: number = 0;
  alpha: number = 1;

  constructor(red: number, green: number, blue: number, alpha: number) {
    this.red = red;
    this.green = green;
    this.blue = blue;
    this.alpha = alpha;
  }
}

/** Hue, saturation and lightness, all 0...1. */
export class CYLHSL {
  hue: number = 0;
  saturation: number = 0;
  lightness: number = 0;

  constructor(hue: number, saturation: number, lightness: number) {
    this.hue = hue;
    this.saturation = saturation;
    this.lightness = lightness;
  }
}

export class CYLIconContrast {
  /** The least WCAG contrast ratio (3:1, the floor for graphics and large text) an icon keeps against the glass. */
  static readonly minimumContrastRatio: number = 3;
  /** The white share of the default frosted glass in dark mode (white at 0.14); over black it is about #242424. */
  static readonly frostedGlassWhiteAlpha: number = 0.14;
  /** The share of an explicit glass tint's alpha that tints the glass when no tint alpha is given. */
  static readonly defaultGlassTintShare: number = 0.75;
  /** The lightness step of the lift. */
  static readonly lightnessStep: number = LIGHTNESS_STEP;

  /** The WCAG contrast ratio of two relative luminances, 1 to 21. */
  static contrastRatio(first: number, second: number): number {
    return (Math.max(first, second) + LUMINANCE_OFFSET) / (Math.min(first, second) + LUMINANCE_OFFSET);
  }

  /**
   * The components of a static color given as '#RRGGBB' or '#AARRGGBB'; undefined for anything else (a resource, a `Color`
   * constant, a number: dynamic or ambiguous, so never lifted).
   */
  static components(color: ResourceColor | undefined): CYLRGBA | undefined {
    if (typeof color !== 'string') {
      return undefined;
    }
    const hex = (color as string).trim().replace('#', '');
    if ((hex.length !== RGB_DIGITS && hex.length !== ARGB_DIGITS) || !new RegExp(HEX_PATTERN).test(hex)) {
      return undefined;
    }
    const argb = hex.length === RGB_DIGITS ? 'FF' + hex : hex;
    const byteAt = (index: number): number => parseInt(argb.substring(index * 2, index * 2 + 2), HEX_RADIX) / BYTE_MAX;
    return new CYLRGBA(byteAt(1), byteAt(2), byteAt(3), byteAt(0));
  }

  /**
   * The reference luminance the icon is judged against, with the glass over a black backdrop: the default frosted glass
   * (`glassTint` undefined, not a static color, or fully transparent) is white at `frostedGlassWhiteAlpha`; an explicit tint is
   * its color times its alpha times `tintAlpha` (`defaultGlassTintShare` when undefined or negative).
   */
  static glassReferenceLuminance(glassTint: ResourceColor | undefined, tintAlpha: number | undefined): number {
    const tint = CYLIconContrast.components(glassTint);
    if (tint === undefined || tint.alpha <= 0) {
      const white = CYLIconContrast.frostedGlassWhiteAlpha;
      return CYLMenuRelativeLuminance(white, white, white);
    }
    const share = tint.alpha * (tintAlpha === undefined || tintAlpha < 0 ? CYLIconContrast.defaultGlassTintShare : tintAlpha);
    return CYLMenuRelativeLuminance(tint.red * share, tint.green * share, tint.blue * share);
  }

  /**
   * The icon color to draw in dark mode on glass: `iconColor` itself when the rule does not apply (not a static color, or
   * it already has 3:1), else the color with its lightness raised in steps of `lightnessStep` (never above white), as
   * '#AARRGGBB' with the alpha kept. The caller calls it only when glass is drawn and the mode is dark.
   */
  static liftedIconColor(iconColor: ResourceColor, glassTint: ResourceColor | undefined,
    tintAlpha: number | undefined): ResourceColor {
    const rgba = CYLIconContrast.components(iconColor);
    if (rgba === undefined) {
      return iconColor;
    }
    const reference = CYLIconContrast.glassReferenceLuminance(glassTint, tintAlpha);
    const hsl = CYLIconContrast.hslFromRGB(rgba.red, rgba.green, rgba.blue);
    if (CYLIconContrast.ratio(hsl, hsl.lightness, reference) >= CYLIconContrast.minimumContrastRatio) {
      return iconColor;
    }
    let lightness = hsl.lightness;
    while (lightness < 1 && CYLIconContrast.ratio(hsl, lightness, reference) < CYLIconContrast.minimumContrastRatio) {
      lightness = Math.min(1, lightness + CYLIconContrast.lightnessStep);
    }
    const lifted = CYLIconContrast.rgbFromHSL(hsl.hue, hsl.saturation, lightness);
    return CYLColor.rgb(lifted.red, lifted.green, lifted.blue, rgba.alpha);
  }

  private static ratio(hsl: CYLHSL, lightness: number, reference: number): number {
    const rgb = CYLIconContrast.rgbFromHSL(hsl.hue, hsl.saturation, lightness);
    return CYLIconContrast.contrastRatio(CYLMenuRelativeLuminance(rgb.red, rgb.green, rgb.blue), reference);
  }

  /** HSL of an sRGB color (components 0...1): hue, saturation and lightness 0...1. */
  static hslFromRGB(red: number, green: number, blue: number): CYLHSL {
    const high = Math.max(red, green, blue);
    const low = Math.min(red, green, blue);
    const lightness = (high + low) / SECTOR_PAIR;
    const delta = high - low;
    if (delta <= 0) {
      return new CYLHSL(0, 0, lightness);
    }
    const saturation = delta / (1 - Math.abs(SECTOR_PAIR * lightness - 1));
    let hue: number;
    if (high === red) {
      hue = (green - blue) / delta;
      if (hue < 0) {
        hue += HUE_SECTORS;
      }
    } else if (high === green) {
      hue = (blue - red) / delta + SECTOR_PAIR;
    } else {
      hue = (red - green) / delta + SECTOR_PAIR * SECTOR_PAIR;
    }
    return new CYLHSL(hue / HUE_SECTORS, saturation, lightness);
  }

  /** The sRGB color (components 0...1) of an HSL triple (all 0...1). */
  static rgbFromHSL(hue: number, saturation: number, lightness: number): CYLRGBA {
    const chroma = (1 - Math.abs(SECTOR_PAIR * lightness - 1)) * saturation;
    const sector = hue * HUE_SECTORS;
    const second = chroma * (1 - Math.abs((sector % SECTOR_PAIR) - 1));
    const base = lightness - chroma / SECTOR_PAIR;
    let red: number;
    let green: number;
    let blue: number;
    switch (Math.floor(sector) % HUE_SECTORS) {
      case 0:
        red = chroma;
        green = second;
        blue = 0;
        break;
      case 1:
        red = second;
        green = chroma;
        blue = 0;
        break;
      case 2:
        red = 0;
        green = chroma;
        blue = second;
        break;
      case 3:
        red = 0;
        green = second;
        blue = chroma;
        break;
      case 4:
        red = second;
        green = 0;
        blue = chroma;
        break;
      default:
        red = chroma;
        green = 0;
        blue = second;
        break;
    }
    return new CYLRGBA(red + base, green + base, blue + base, 1);
  }
}
