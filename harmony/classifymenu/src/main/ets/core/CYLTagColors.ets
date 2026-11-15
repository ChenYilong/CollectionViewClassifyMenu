/**
 * The four colors of a tag (background, border, text, selected background), as iOS `CYLTagColors`: AndroidTagView's
 * ColorFactory, from a theme, a random palette color, or your own.
 */
import { CYLMenuStyle } from './CYLMenuStyle';
import { CYLColor } from './CYLTypes';

/** AndroidTagView's `tag_theme`. */
export enum CYLTagColorTheme {
  none = -1,
  random = 0,
  pureCyan = 1,
  pureTeal = 2
}

const PALETTE: string[] = ['F44336', '03A9F4', 'FFC107', 'FF9800', 'FFEB3B', 'CDDC39', '2196F3', '3F51B5', '8BC34A',
  '9E9E9E', '673AB7', '009688', '00BCD4'];
const PALETTE_NAMES: string[] = ['RED', 'LIGHTBLUE', 'AMBER', 'ORANGE', 'YELLOW', 'LIME', 'BLUE', 'INDIGO',
  'LIGHTGREEN', 'GREY', 'DEEPPURPLE', 'TEAL', 'CYAN'];

export class CYLTagColors {
  /** 0x33 / 255. */
  static readonly backgroundAlpha: number = 0x33 / 255;
  /** 0x88 / 255. */
  static readonly borderAlpha: number = 0x88 / 255;
  /** ColorFactory's colors by name. */
  static readonly paletteHexByName: Map<string, string> = new Map<string, string>(
    PALETTE_NAMES.map((name: string, index: number): [string, string] => [name, PALETTE[index]]));
  static readonly gray666666: string = '#FF666666';
  static readonly gray727272: string = '#FF727272';

  backgroundColor?: string;
  borderColor?: string;
  textColor?: string;
  selectedBackgroundColor?: string;

  constructor(backgroundColor?: string, borderColor?: string, textColor?: string, selectedBackgroundColor?: string) {
    this.backgroundColor = backgroundColor;
    this.borderColor = borderColor;
    this.textColor = textColor;
    this.selectedBackgroundColor = selectedBackgroundColor;
  }

  /** `hex` at 0x33 (background) and 0x88 (border). */
  static fromPaletteHex(hex: string, textColor: string, selectedBackgroundColor: string): CYLTagColors {
    return new CYLTagColors(CYLColor.fromHex(hex, CYLTagColors.backgroundAlpha),
      CYLColor.fromHex(hex, CYLTagColors.borderAlpha), textColor, selectedBackgroundColor);
  }

  /** The theme's colors (random: the palette color `seed`); undefined for none. */
  static fromTheme(theme: CYLTagColorTheme, seed: number): CYLTagColors | undefined {
    switch (theme) {
      case CYLTagColorTheme.random: {
        const count = PALETTE.length;
        return CYLTagColors.fromPaletteHex(PALETTE[((seed % count) + count) % count], CYLTagColors.gray666666,
          CYLTagColors.gray727272);
      }
      case CYLTagColorTheme.pureCyan:
        return CYLTagColors.fromPaletteHex('00BCD4', CYLTagColors.gray727272, CYLTagColors.gray666666);
      case CYLTagColorTheme.pureTeal:
        return CYLTagColors.fromPaletteHex('009688', CYLTagColors.gray727272, CYLTagColors.gray666666);
      default:
        return undefined;
    }
  }

  /** A random palette color. */
  static random(): CYLTagColors {
    return CYLTagColors.fromTheme(CYLTagColorTheme.random, Math.floor(Math.random() * PALETTE.length)) as CYLTagColors;
  }

  /** A copy of `style` (the default style when undefined) with these colors; a border gets 1 vp when it had none. */
  styleByApplying(style?: CYLMenuStyle): CYLMenuStyle {
    const result = (style ?? CYLMenuStyle.defaultStyle()).copy();
    const normal = result.normalAppearance;
    const selected = result.selectedAppearance;
    if (this.backgroundColor !== undefined) {
      normal.backgroundColor = this.backgroundColor;
    }
    if (this.textColor !== undefined) {
      normal.textColor = this.textColor;
      selected.textColor = this.textColor;
    }
    if (this.borderColor !== undefined) {
      normal.borderColor = this.borderColor;
      selected.borderColor = this.borderColor;
      if (normal.borderWidth <= 0) {
        normal.borderWidth = 1;
      }
    }
    if (this.selectedBackgroundColor !== undefined) {
      selected.backgroundColor = this.selectedBackgroundColor;
    }
    return result;
  }
}
