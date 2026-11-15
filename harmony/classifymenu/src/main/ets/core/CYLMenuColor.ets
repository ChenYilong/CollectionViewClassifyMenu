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
