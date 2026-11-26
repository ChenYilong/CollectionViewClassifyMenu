/**
 * The box and text of a tag in one state (normal, selected, disabled), as iOS `CYLTagAppearance`. Negative or
 * non-finite lengths become 0. The colors and the font are null_resettable: `reset…()` restores their default.
 */
import { CYLAnimatedItemCornerRadiusCapsule } from 'cylanimateditem';
import { CYLColor, CYLEdgeInsets, CYLFont } from './CYLTypes';

function sanitized(value: number): number {
  return Number.isFinite(value) && value > 0 ? value : 0;
}
export class CYLTagAppearance {
  /** White in light mode, the secondary system background (#1C1C1E) in dark mode (a resource with a dark variant), as on iOS. */
  static readonly defaultBackgroundColor: ResourceColor = $r('app.color.cyl_tag_background');
  /** Dark gray in light mode, white (the primary label) in dark mode. */
  static readonly defaultTextColor: ResourceColor = $r('app.color.cyl_tag_text');
  static readonly defaultFont: CYLFont = CYLFont.systemFont(14);

  private storedBackgroundColor?: ResourceColor;
  private storedTextColor?: ResourceColor;
  private storedFont?: CYLFont;
  private storedCornerRadius: number = CYLAnimatedItemCornerRadiusCapsule;
  private storedBorderWidth: number = 0;
  private storedBorderColor?: ResourceColor;
  private textColorWasSet: boolean = false;
  private borderColorWasSet: boolean = false;
  private borderWidthWasSet: boolean = false;
  /** The built-in border of the style (`CYLMenuStyle`'s constructor): read as the effective border, never explicit. */
  private defaultBorderColor?: ResourceColor;
  private defaultBorderWidth: number = 0;
  private storedContentInsets: CYLEdgeInsets = new CYLEdgeInsets(5, 10, 5, 10);
  /**
   * The icon tint; undefined uses `textColor`. Any `ResourceColor`, a theme color included.
   */
  iconColor?: ResourceColor;
  backgroundImage?: ResourceStr;

  /**
   * The box; any `ResourceColor` (a '#AARRGGBB' string, a `Color`, a theme resource that follows the color mode).
   */
  get backgroundColor(): ResourceColor {
    return this.storedBackgroundColor ?? CYLTagAppearance.defaultBackgroundColor;
  }

  set backgroundColor(value: ResourceColor) {
    this.storedBackgroundColor = value;
  }

  /**
   * The title; any `ResourceColor`.
   */
  get textColor(): ResourceColor {
    return this.storedTextColor ?? CYLTagAppearance.defaultTextColor;
  }

  set textColor(value: ResourceColor) {
    this.storedTextColor = value;
    this.textColorWasSet = true;
  }

  /**
   * The color set on `textColor` (setter, configuration key, preset); undefined when it was never set, was reset, or is the
   * style's built-in default (`setDefaultTextColor`). On dark Liquid Glass only this color is adapted for contrast.
   */
  get explicitTextColor(): ResourceColor | undefined {
    return this.textColorWasSet ? this.storedTextColor : undefined;
  }

  /** Sets the built-in title color of the style: the effective color until the app sets one, never explicit. */
  setDefaultTextColor(color: ResourceColor): void {
    this.storedTextColor = color;
    this.textColorWasSet = false;
  }

  /** Takes over `source`'s title color exactly: the effective color and whether it is explicit. */
  inheritTextColor(source: CYLTagAppearance): void {
    this.storedTextColor = source.storedTextColor;
    this.textColorWasSet = source.textColorWasSet;
  }

  get font(): CYLFont {
    return this.storedFont ?? CYLTagAppearance.defaultFont;
  }

  set font(value: CYLFont) {
    this.storedFont = value;
  }

  /**
   * The color set on `backgroundColor`; undefined when it was never set or was reset (the built-in default applies, which
   * is never stored). Under Liquid Glass only this color tints the glass: an unset background hands no color, so the
   * glass keeps its frosted default tint (iOS `explicitBackgroundColor`).
   */
  get explicitBackgroundColor(): ResourceColor | undefined {
    return this.storedBackgroundColor;
  }

  /** True when `backgroundColor` was set to a color (and not reset). */
  get isBackgroundColorSet(): boolean {
    return this.storedBackgroundColor !== undefined;
  }

  /**
   * The border; undefined draws none. Any `ResourceColor`. Reads the effective color (the style's built-in default until the
   * app sets one); under Liquid Glass only an explicit one is drawn (`explicitBorderColor`).
   */
  get borderColor(): ResourceColor | undefined {
    return this.borderColorWasSet ? this.storedBorderColor : this.defaultBorderColor;
  }

  set borderColor(value: ResourceColor | undefined) {
    this.storedBorderColor = value;
    this.borderColorWasSet = true;
  }

  /** The color set on `borderColor`; undefined when it was never set, was reset, or was set to none. */
  get explicitBorderColor(): ResourceColor | undefined {
    return this.borderColorWasSet ? this.storedBorderColor : undefined;
  }

  /** True when `borderColor` was set (setter, configuration key, preset), even to none; false for the built-in default. */
  get isBorderColorSet(): boolean {
    return this.borderColorWasSet;
  }

  /** True when `borderWidth` was set (setter, configuration key, preset); false for the built-in default. */
  get isBorderWidthSet(): boolean {
    return this.borderWidthWasSet;
  }

  /** Sets the built-in border of the style: the effective border until the app sets one, never explicit. */
  setDefaultBorder(color: ResourceColor | undefined, width: number): void {
    this.defaultBorderColor = color;
    this.defaultBorderWidth = sanitized(width);
  }

  /** Takes over `source`'s border exactly: the values, which of them are explicit, and the built-in default. */
  inheritBorder(source: CYLTagAppearance): void {
    this.storedBorderColor = source.storedBorderColor;
    this.borderColorWasSet = source.borderColorWasSet;
    this.storedBorderWidth = source.storedBorderWidth;
    this.borderWidthWasSet = source.borderWidthWasSet;
    this.defaultBorderColor = source.defaultBorderColor;
    this.defaultBorderWidth = source.defaultBorderWidth;
  }

  resetBackgroundColor(): void {
    this.storedBackgroundColor = undefined;
  }

  resetTextColor(): void {
    this.storedTextColor = undefined;
    this.textColorWasSet = false;
  }

  resetFont(): void {
    this.storedFont = undefined;
  }

  /**
   * Corner radius in points: 0 is square corners, and a value of half the tag height or more is a capsule (the radius
   * is limited to half the height, so a large value such as 1000 is a capsule for any tag). Negative or non-finite
   * values are treated as 0. `CYLAnimatedItemCornerRadiusCapsule` by default.
   */
  get cornerRadius(): number {
    return this.storedCornerRadius;
  }

  set cornerRadius(value: number) {
    this.storedCornerRadius = sanitized(value);
  }

  get borderWidth(): number {
    return this.borderWidthWasSet ? this.storedBorderWidth : this.defaultBorderWidth;
  }

  set borderWidth(value: number) {
    this.storedBorderWidth = sanitized(value);
    this.borderWidthWasSet = true;
  }

  get contentInsets(): CYLEdgeInsets {
    return this.storedContentInsets;
  }

  set contentInsets(value: CYLEdgeInsets) {
    this.storedContentInsets = new CYLEdgeInsets(sanitized(value.top), sanitized(value.left),
      sanitized(value.bottom), sanitized(value.right));
  }

  /**
   * The larger of the left and right content insets; setting it sets both.
   */
  get margin(): number {
    return Math.max(this.storedContentInsets.left, this.storedContentInsets.right);
  }

  set margin(value: number) {
    const m = sanitized(value);
    const insets = this.storedContentInsets;
    this.storedContentInsets = new CYLEdgeInsets(insets.top, m, insets.bottom, m);
  }

  /**
   * Restores every value to its default.
   */
  reset(): void {
    this.storedBackgroundColor = undefined;
    this.storedTextColor = undefined;
    this.textColorWasSet = false;
    this.storedFont = undefined;
    this.iconColor = undefined;
    this.storedCornerRadius = CYLAnimatedItemCornerRadiusCapsule;
    this.storedBorderColor = undefined;
    this.borderColorWasSet = false;
    this.defaultBorderColor = undefined;
    this.storedBorderWidth = 0;
    this.borderWidthWasSet = false;
    this.defaultBorderWidth = 0;
    this.storedContentInsets = new CYLEdgeInsets(5, 10, 5, 10);
    this.backgroundImage = undefined;
  }

  /**
   * NSCopying.
   */
  copy(): CYLTagAppearance {
    const result = new CYLTagAppearance();
    result.storedBackgroundColor = this.storedBackgroundColor;
    result.inheritTextColor(this);
    result.storedFont = this.storedFont;
    result.iconColor = this.iconColor;
    result.storedCornerRadius = this.storedCornerRadius;
    result.inheritBorder(this);
    result.storedContentInsets = this.storedContentInsets;
    result.backgroundImage = this.backgroundImage;
    return result;
  }
}
