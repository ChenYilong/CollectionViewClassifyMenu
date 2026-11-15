/**
 * The box and text of a tag in one state (normal, selected, disabled), as iOS `CYLTagAppearance`. Negative or
 * non-finite lengths become 0. The colors and the font are null_resettable: `reset…()` restores their default.
 */
import { CYLColor, CYLEdgeInsets, CYLFont } from './CYLTypes';

/** A corner radius that draws square corners (0 means "the list's value"). */
export const CYLTagCornerRadiusSquare: number = 0.001;

function sanitized(value: number): number {
  return Number.isFinite(value) && value > 0 ? value : 0;
}

export class CYLTagAppearance {
  static readonly defaultBackgroundColor: string = CYLColor.WHITE;
  static readonly defaultTextColor: string = CYLColor.white(0.25);
  static readonly defaultFont: CYLFont = CYLFont.systemFont(14);

  private storedBackgroundColor?: string;
  private storedTextColor?: string;
  private storedFont?: CYLFont;
  private storedCornerRadius: number = 3;
  private storedBorderWidth: number = 0;
  private storedContentInsets: CYLEdgeInsets = new CYLEdgeInsets(5, 10, 5, 10);
  iconColor?: string;
  borderColor?: string;
  backgroundImage?: ResourceStr;

  get backgroundColor(): string {
    return this.storedBackgroundColor ?? CYLTagAppearance.defaultBackgroundColor;
  }

  set backgroundColor(value: string) {
    this.storedBackgroundColor = value;
  }

  get textColor(): string {
    return this.storedTextColor ?? CYLTagAppearance.defaultTextColor;
  }

  set textColor(value: string) {
    this.storedTextColor = value;
  }

  get font(): CYLFont {
    return this.storedFont ?? CYLTagAppearance.defaultFont;
  }

  set font(value: CYLFont) {
    this.storedFont = value;
  }

  resetBackgroundColor(): void {
    this.storedBackgroundColor = undefined;
  }

  resetTextColor(): void {
    this.storedTextColor = undefined;
  }

  resetFont(): void {
    this.storedFont = undefined;
  }

  get cornerRadius(): number {
    return this.storedCornerRadius;
  }

  set cornerRadius(value: number) {
    this.storedCornerRadius = sanitized(value);
  }

  get borderWidth(): number {
    return this.storedBorderWidth;
  }

  set borderWidth(value: number) {
    this.storedBorderWidth = sanitized(value);
  }

  get contentInsets(): CYLEdgeInsets {
    return this.storedContentInsets;
  }

  set contentInsets(value: CYLEdgeInsets) {
    this.storedContentInsets = new CYLEdgeInsets(sanitized(value.top), sanitized(value.left),
      sanitized(value.bottom), sanitized(value.right));
  }

  /** The larger of the left and right content insets; setting it sets both. */
  get margin(): number {
    return Math.max(this.storedContentInsets.left, this.storedContentInsets.right);
  }

  set margin(value: number) {
    const m = sanitized(value);
    const insets = this.storedContentInsets;
    this.storedContentInsets = new CYLEdgeInsets(insets.top, m, insets.bottom, m);
  }

  /** Restores every value to its default. */
  reset(): void {
    this.storedBackgroundColor = undefined;
    this.storedTextColor = undefined;
    this.storedFont = undefined;
    this.iconColor = undefined;
    this.storedCornerRadius = 3;
    this.borderColor = undefined;
    this.storedBorderWidth = 0;
    this.storedContentInsets = new CYLEdgeInsets(5, 10, 5, 10);
    this.backgroundImage = undefined;
  }

  /** NSCopying. */
  copy(): CYLTagAppearance {
    const result = new CYLTagAppearance();
    result.storedBackgroundColor = this.storedBackgroundColor;
    result.storedTextColor = this.storedTextColor;
    result.storedFont = this.storedFont;
    result.iconColor = this.iconColor;
    result.storedCornerRadius = this.storedCornerRadius;
    result.borderColor = this.borderColor;
    result.storedBorderWidth = this.storedBorderWidth;
    result.storedContentInsets = this.storedContentInsets;
    result.backgroundImage = this.backgroundImage;
    return result;
  }
}
