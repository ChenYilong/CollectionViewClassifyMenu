/**
 * The ArkTS forms of the UIKit value types the iOS API uses. Lengths are vp and font sizes fp, as points on iOS.
 * Colors are '#AARRGGBB' strings, which ArkUI takes as a ResourceColor.
 */

/** `UIEdgeInsets`. */
export class CYLEdgeInsets {
  static readonly ZERO: CYLEdgeInsets = new CYLEdgeInsets(0, 0, 0, 0);
  readonly top: number;
  readonly left: number;
  readonly bottom: number;
  readonly right: number;

  constructor(top: number = 0, left: number = 0, bottom: number = 0, right: number = 0) {
    this.top = top;
    this.left = left;
    this.bottom = bottom;
    this.right = right;
  }

  equals(other: CYLEdgeInsets): boolean {
    return this.top === other.top && this.left === other.left && this.bottom === other.bottom &&
      this.right === other.right;
  }
}

/** `CGSize`. */
export class CYLSize {
  static readonly ZERO: CYLSize = new CYLSize(0, 0);
  readonly width: number;
  readonly height: number;

  constructor(width: number = 0, height: number = 0) {
    this.width = width;
    this.height = height;
  }
}

/** `UIOffset`. */
export class CYLOffset {
  static readonly ZERO: CYLOffset = new CYLOffset(0, 0);
  readonly horizontal: number;
  readonly vertical: number;

  constructor(horizontal: number = 0, vertical: number = 0) {
    this.horizontal = horizontal;
    this.vertical = vertical;
  }
}

/** `CGPoint`. */
export class CYLPoint {
  readonly x: number;
  readonly y: number;

  constructor(x: number = 0, y: number = 0) {
    this.x = x;
    this.y = y;
  }
}

/** `CGRect`. */
export class CYLRect {
  readonly x: number;
  readonly y: number;
  readonly width: number;
  readonly height: number;

  constructor(x: number = 0, y: number = 0, width: number = 0, height: number = 0) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }

  get maxX(): number {
    return this.x + this.width;
  }

  get maxY(): number {
    return this.y + this.height;
  }

  intersects(other: CYLRect): boolean {
    return this.x < other.maxX && other.x < this.maxX && this.y < other.maxY && other.y < this.maxY;
  }
}

/** `UIFont`: a size in fp and a weight. */
export class CYLFont {
  readonly size: number;
  readonly weight: FontWeight;

  constructor(size: number, weight: FontWeight = FontWeight.Normal) {
    this.size = size;
    this.weight = weight;
  }

  get isBold(): boolean {
    return this.weight === FontWeight.Bold || this.weight === FontWeight.Bolder;
  }

  /** The same font in bold (Bold Text). */
  bold(): CYLFont {
    return this.isBold ? this : new CYLFont(this.size, FontWeight.Bold);
  }

  withSize(size: number): CYLFont {
    return new CYLFont(size, this.weight);
  }

  /** `UIFont.systemFont(ofSize:)`. */
  static systemFont(size: number): CYLFont {
    return new CYLFont(size, FontWeight.Normal);
  }

  /** `UIFont.boldSystemFont(ofSize:)`. */
  static boldSystemFont(size: number): CYLFont {
    return new CYLFont(size, FontWeight.Bold);
  }
}

/** `UIControl.State`: bit flags, `NORMAL` being none of them. */
export class CYLControlState {
  static readonly NORMAL: number = 0;
  static readonly HIGHLIGHTED: number = 1;
  static readonly DISABLED: number = 2;
  static readonly SELECTED: number = 4;
}

function hexByte(value: number): string {
  const v = Math.min(255, Math.max(0, Math.round(value)));
  return (v < 16 ? '0' : '') + v.toString(16).toUpperCase();
}

function channel(value: number): string {
  return hexByte(Math.min(1, Math.max(0, value)) * 255);
}

/** Colors as '#AARRGGBB', the ArkTS form of `UIColor`. */
export class CYLColor {
  /** `CYLAppTintColor` (42, 185, 160). */
  static readonly APP_TINT: string = '#FF2AB9A0';
  static readonly CLEAR: string = '#00000000';
  static readonly WHITE: string = '#FFFFFFFF';
  static readonly BLACK: string = '#FF000000';
  static readonly GRAY: string = '#FF808080';

  /** `UIColor(white:alpha:)`. */
  static white(white: number, alpha: number = 1): string {
    return '#' + channel(alpha) + channel(white) + channel(white) + channel(white);
  }

  /** `UIColor(red:green:blue:alpha:)` with components 0...1. */
  static rgb(red: number, green: number, blue: number, alpha: number = 1): string {
    return '#' + channel(alpha) + channel(red) + channel(green) + channel(blue);
  }

  /** Bytes 0...255. */
  static argb(alpha: number, red: number, green: number, blue: number): string {
    return '#' + hexByte(alpha) + hexByte(red) + hexByte(green) + hexByte(blue);
  }

  /** `withAlphaComponent(_:)` of a '#AARRGGBB' or '#RRGGBB' color. */
  static withAlpha(color: string, alpha: number): string {
    const hex = color.replace('#', '');
    return '#' + channel(alpha) + hex.substring(hex.length - 6).toUpperCase();
  }

  /** A "RRGGBB" or "#RRGGBB" hex string with `alpha`, or undefined when it does not parse. */
  static fromHex(hex: string | undefined, alpha: number = 1): string | undefined {
    if (hex === undefined) {
      return undefined;
    }
    const digits = hex.trim().replace('#', '');
    if (!new RegExp('^[0-9a-fA-F]{6}$').test(digits)) {
      return undefined;
    }
    return '#' + channel(alpha) + digits.toUpperCase();
  }
}
