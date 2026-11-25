/**
 * The look of a tag list, as iOS `CYLMenuStyle`: the tags in each state (`CYLTagAppearance`), the delete indicator,
 * the touch ripple, titles, rows, icons, layout spacing, section headers, fold controls and the More button. Lengths
 * are vp, font sizes fp, colors '#AARRGGBB'. `copy()` is NSCopying.
 */
import { CYLAnimatedItemCornerRadiusCapsule, CYLLiquidGlass } from 'cylanimateditem';
import { CYLTagAppearance } from './CYLTagAppearance';
import { CYLColor, CYLControlState, CYLEdgeInsets, CYLFont, CYLImage, CYLOffset, CYLSize } from './CYLTypes';
import { CYLMenuColorLuminance } from './CYLMenuColor';
import { CYLMenuLocalizedString, CYLMenuResources } from './CYLMenuResources';
import { CYLTagMetrics } from './CYLTagMetrics';

/**
 * The icon before or after the title, or above (`top`) or below (`bottom`) it, both centered.
 */
export enum CYLTagImagePlacement {
  leading = 0,
  trailing = 1,
  top = 2,
  bottom = 3
}

/**
 * True for `top` and `bottom`: the icon and the title are stacked.
 */
export function CYLTagImagePlacementIsVertical(placement: CYLTagImagePlacement): boolean {
  return placement === CYLTagImagePlacement.top || placement === CYLTagImagePlacement.bottom;
}

/**
 * The icon and title centered in the tag, or at its leading edge.
 */
export enum CYLTagContentAlignment {
  center = 0,
  leading = 1
}

/**
 * What a tag's background is made of: the solid color of each state's appearance (`flat`, the default), or a Liquid Glass
 * background (`liquidGlass`: the blur imitation of CYLTabBarController's glass, tinted with the state's background color).
 */
export enum CYLTagBackgroundStyle {
  flat = 0,
  liquidGlass = 1
}

/**
 * Where a row of tags sits in the list's width.
 */
export enum CYLTagRowAlignment {
  leading = 0,
  center = 1,
  trailing = 2
}

/**
 * The delete indicator after or before the title.
 */
export enum CYLTagDeleteIndicatorPlacement {
  trailing = 0,
  leading = 1
}

/**
 * The font and text color of a state (`titleTextAttributes(for:)`).
 */
export interface CYLTitleTextAttributes {
  font: CYLFont;
  textColor: ResourceColor;
}

/**
 * How a section's tags sit in the list: `insetGrouped` (the default) inside a rounded card (UITableView's inset grouped look),
 * the header above it; `plain` (the opt-out) on the list's background.
 */
export enum CYLSectionStyle {
  plain = 0,
  insetGrouped = 1
}

/**
 * The line at the bottom of a section header: `none` (the default) or a `line`.
 */
export enum CYLHeaderSeparatorStyle {
  none = 0,
  line = 1
}

/**
 * The named lengths of the section style, vp.
 */
export class CYLSectionStyleMetrics {
  /** The corner radius of a section card. */
  static readonly cardCornerRadius: number = 10;
  /** The padding between a section card and its tags. */
  static readonly cardPadding: number = 12;
  /** The padding between a header band and its title, leading and trailing. */
  static readonly headerBandPadding: number = 12;
  /** The thickness of the header divider: one hairline. */
  static readonly separatorThickness: number = 0.5;
}

/**
 * The relative luminance (WCAG, 0...1) above which a background counts as light, so that the default tint on it is black:
 * 0.179 is where black and white have the same contrast ratio against it.
 */
export const CYLTintLuminanceThreshold: number = 0.179;

/**
 * The colors of the section style: each one follows the color mode (`resources/base` and `resources/dark`). A style whose
 * color is undefined resolves to them; an app can also set one itself, for example `headerBand` on `headerBackgroundColor`.
 */
export class CYLSectionStyleColors {
  /** The system's primary font color (`sys.color.font_primary`): black in light mode, white in dark mode. */
  static readonly systemTint: ResourceColor = $r('sys.color.font_primary');
  /** The section card: white; #1C1C1E in dark mode. */
  static readonly card: ResourceColor = $r('app.color.cyl_section_card');
  /** The header band: #EFEFF4; #2C2C2E in dark mode. */
  static readonly headerBand: ResourceColor = $r('app.color.cyl_section_header_band');
  /** The list background of a list whose `backgroundColor` was never set: the system background, white; black in dark mode. */
  static readonly listBackground: ResourceColor = $r('app.color.cyl_list_background');
  /** The list background under `insetGrouped`: #F2F2F7; black in dark mode. */
  static readonly groupedBackground: ResourceColor = $r('app.color.cyl_section_grouped_background');
  /** The header divider: the system separator color. */
  static readonly separator: ResourceColor = $r('app.color.cyl_section_separator');
  /** The tint of a Liquid Glass card with no `sectionBackgroundColor`: translucent white; translucent #1C1C1E in dark mode. */
  static readonly glassTint: ResourceColor = $r('app.color.cyl_section_glass_tint');
}

/**
 * A tag border of one physical pixel (iOS: 1 / screen scale).
 */
const HAIRLINE: number = 0.5;

/**
 * The line limits of a tag's title (`CYLMenuStyle.titleMaxLines`): named values, never a literal in a call site.
 */
export class CYLTagTitleMaxLines {
  /** One line, the default: a title too wide for its tag is truncated. */
  static readonly single: number = 1;
  /** No limit: a title wraps onto as many lines as it needs (the MAX of the line counts). */
  static readonly unlimited: number = Number.MAX_SAFE_INTEGER;
}

/**
 * The line limits of a section header's title (`CYLMenuStyle.headerMaxLines`): named values, never a literal in a call site.
 */
export class CYLHeaderTitleMaxLines {
  /** One line, the default: a title too wide for its header is truncated. */
  static readonly single: number = 1;
  /** No limit: a title wraps onto as many lines as it needs. */
  static readonly unlimited: number = Number.MAX_SAFE_INTEGER;
}

/**
 * The layout direction of a list: `ltr` (the default) or `rtl`, which mirrors the section header (title, icon, fold /
 * More control), the section insets, the header band, divider and card insets, and starts the rows of tags at the
 * trailing edge.
 */
export enum CYLLayoutDirection {
  ltr = 0,
  rtl = 1
}

export class CYLMenuStyle {
  private storedNormal: CYLTagAppearance = new CYLTagAppearance();
  private storedSelected: CYLTagAppearance = new CYLTagAppearance();
  private storedDisabled: CYLTagAppearance = new CYLTagAppearance();
  private storedDeleteIndicatorTitle: string = '×';

  highlightedBackgroundColor?: ResourceColor;

  // The delete indicator
  deleteIndicatorColor?: ResourceColor;
  deleteIndicatorFont?: CYLFont;
  deleteIndicatorLineWidth: number = 0;
  deleteIndicatorWidth: number = 0;
  deleteIndicatorPadding: number = 0;
  deleteIndicatorPlacement: CYLTagDeleteIndicatorPlacement = CYLTagDeleteIndicatorPlacement.trailing;

  // The touch ripple
  rippleColor?: string;
  rippleAlpha: number = 0.2;
  /**
   * Seconds.
   */
  rippleDuration: number = 1;

  // Titles
  maximumTitleLength: number = 0;
  reversesTitleCharacters: boolean = false;

  // Rows and section headers
  rowAlignment: CYLTagRowAlignment = CYLTagRowAlignment.leading;
  headerIndicatorColor?: string;
  headerIndicatorSize: CYLSize = new CYLSize(3, 16);
  imageCornerRadius: number = 0;

  // Title and icon
  imageTitleSpacing: number = 4;
  imageSize: CYLSize = new CYLSize(14, 14);
  imageInsets: CYLEdgeInsets = CYLEdgeInsets.ZERO;
  titlePositionAdjustment: CYLOffset = CYLOffset.ZERO;
  imagePositionAdjustment: CYLOffset = CYLOffset.ZERO;
  imagePlacement: CYLTagImagePlacement = CYLTagImagePlacement.leading;
  /**
   * True: a leading image (or animated icon) is a circle as tall as the tag, at its leading edge, and the title follows
   * it (`imageSize`, `imageInsets` and the leading content inset do not apply to it); AndroidTagView's avatar. Default
   * false.
   */
  imageFillsTagHeight: boolean = false;
  /**
   * The space between the two editing icons of a renamable tag in editing mode (the edit icon and the delete icon,
   * `CYLTagButton.editingIndicatorsView`), vp. 10 by default; a negative value is 0.
   */
  editingIndicatorSpacing: number = 10;
  /**
   * The margins around the two editing icons as a whole: left from the title, right to the tag's padding, top and
   * bottom within the tag, vp. Left 4 and right 0 by default; negative values are 0.
   */
  editingIndicatorInsets: CYLEdgeInsets = new CYLEdgeInsets(0, 4, 0, 0);
  /** The image of a section header's clear button; undefined: the core's trash icon ("cyl_trash"). */
  clearButtonImage?: CYLImage = undefined;
  /** The color of the clear button; undefined: `headerTextColor`. */
  clearButtonColor?: ResourceColor = undefined;
  private titleMaxLinesValue: number = CYLTagTitleMaxLines.single;

  /**
   * The most lines a title may take: a title too wide for its tag wraps onto more lines, up to this number, and the tag
   * grows taller; beyond it the title is truncated. Default `CYLTagTitleMaxLines.single` (1, one line, truncated).
   * `CYLTagTitleMaxLines.unlimited` shows every line. The list measures the taller tag at the width it gets. The number
   * is the app's choice; a value that is not a whole number of 1 or more is 1.
   */
  get titleMaxLines(): number {
    return this.titleMaxLinesValue;
  }

  set titleMaxLines(value: number) {
    this.titleMaxLinesValue = Number.isFinite(value) || value === CYLTagTitleMaxLines.unlimited ?
      Math.max(CYLTagTitleMaxLines.single, Math.floor(value)) : CYLTagTitleMaxLines.single;
  }

  /**
   * True: a title wraps onto as many lines as it needs (AndroidTagView's tag_text_wrap), the same as `titleMaxLines` =
   * `CYLTagTitleMaxLines.unlimited`; false: one line. Default false.
   */
  get titleWraps(): boolean {
    return this.titleMaxLinesValue !== CYLTagTitleMaxLines.single;
  }

  set titleWraps(value: boolean) {
    this.titleMaxLinesValue = value ? CYLTagTitleMaxLines.unlimited : CYLTagTitleMaxLines.single;
  }
  /**
   * A shadow under each tag, as Android's elevation in vp (AndroidTagView's tag_elevation): offset down by half of it
   * and blurred by it. Default 0, no shadow.
   */
  elevation: number = 0;
  /**
   * An image drawn as the delete indicator instead of `deleteIndicatorTitle` or the drawn cross (AndroidTagView's
   * tag_cross drawable): a square as tall as a line of the indicator font, plus `deleteIndicatorPadding` on each side.
   * Default undefined.
   */
  deleteIndicatorImage?: CYLImage = undefined;
  layoutCentered: boolean = true;
  contentAlignment: CYLTagContentAlignment = CYLTagContentAlignment.center;
  /**
   * The tag background: `flat` (the default) is the solid color of each state's appearance; `liquidGlass` draws a glass
   * background behind the content, tinted with the state's `backgroundColor` and clipped to the corner
   * radius. Where the device draws no Liquid Glass the style is ignored (`resolvedBackgroundStyle()`).
   */
  backgroundStyle: CYLTagBackgroundStyle = CYLTagBackgroundStyle.flat;
  /**
   * The smallest size of a tag, vp: a tag narrower or shorter than it grows to it, its content staying where
   * `contentAlignment` puts it. `CYLSize.ZERO` (the default) keeps the tag as large as its content and `itemHeight` make it.
   */
  minimumTagSize: CYLSize = CYLSize.ZERO;

  /**
   * The background style a tag really draws: `backgroundStyle`, flat where `CYLLiquidGlass.isActive()` (the rule of
   * CYLTabBarController's `cylanimateditem`) is false; every other parameter is kept.
   */
  resolvedBackgroundStyle(): CYLTagBackgroundStyle {
    return this.backgroundStyle === CYLTagBackgroundStyle.liquidGlass && CYLLiquidGlass.isActive() ? CYLTagBackgroundStyle.liquidGlass :
    CYLTagBackgroundStyle.flat;
  }
  animationSize: CYLSize = CYLSize.ZERO;
  animationSpeed: number = 1;
  adjustsFontForContentSizeCategory: boolean = true;
  itemHeight: number = 30;
  numberOfItemsPerRow: number = 0;

  // Layout
  interitemSpacing: number = 10;
  lineSpacing: number = 10;
  sectionInsets: CYLEdgeInsets = new CYLEdgeInsets(10, 16, 10, 16);
  private backgroundColorValue?: ResourceColor = undefined;

  /**
   * The list's background color: the system background by default (`CYLSectionStyleColors.listBackground`, a resource: white
   * in light mode, black in dark mode). Under `insetGrouped` a list whose background the app never set shows the grouped
   * background instead (`resolvedBackgroundColor()`). A color the app sets, a clear one included, wins in both modes.
   */
  get backgroundColor(): ResourceColor {
    return this.backgroundColorValue ?? CYLSectionStyleColors.listBackground;
  }

  set backgroundColor(value: ResourceColor) {
    this.backgroundColorValue = value;
  }

  /** True when the app set `backgroundColor` (a clear color counts); false while the mode-following default applies. */
  get isBackgroundColorSet(): boolean {
    return this.backgroundColorValue !== undefined;
  }

  // The section card, the header band and the header divider (the contract is docs/tag-section-style.md)
  /** `insetGrouped` (the default: the section's tags inside a rounded card) or `plain` (the opt-out: no card). */
  sectionStyle: CYLSectionStyle = CYLSectionStyle.insetGrouped;
  /** The card's color; undefined resolves to `CYLSectionStyleColors.card`. */
  sectionBackgroundColor?: ResourceColor = undefined;
  /**
   * The card's background: `flat` (the default) is the solid color; `liquidGlass` is the core's Liquid Glass material
   * (the tags' drawing) with the card's corners, tinted with `sectionBackgroundColor`, else `CYLSectionStyleColors.glassTint`.
   * Where the device draws no glass the card is flat (`resolvedSectionBackgroundStyle()`); the frames never change.
   */
  sectionBackgroundStyle: CYLTagBackgroundStyle = CYLTagBackgroundStyle.flat;
  sectionCornerRadius: number = CYLSectionStyleMetrics.cardCornerRadius;
  /** The padding inside the card around the tags (`insetGrouped`), vp. */
  sectionContentInsets: CYLEdgeInsets = new CYLEdgeInsets(CYLSectionStyleMetrics.cardPadding,
    CYLSectionStyleMetrics.cardPadding, CYLSectionStyleMetrics.cardPadding, CYLSectionStyleMetrics.cardPadding);
  /** The header band's color; undefined: no band (today's look). `CYLSectionStyleColors.headerBand` is the usual one. */
  headerBackgroundColor?: ResourceColor = undefined;
  headerCornerRadius: number = 0;
  /** A plain header's title and fold control inset from the band's edges (left and right), vp. */
  headerContentInsets: CYLEdgeInsets = new CYLEdgeInsets(0, CYLSectionStyleMetrics.headerBandPadding, 0,
    CYLSectionStyleMetrics.headerBandPadding);
  headerSeparatorStyle: CYLHeaderSeparatorStyle = CYLHeaderSeparatorStyle.none;
  /** The divider's color; undefined resolves to `CYLSectionStyleColors.separator`. */
  headerSeparatorColor?: ResourceColor = undefined;
  headerSeparatorThickness: number = CYLSectionStyleMetrics.separatorThickness;
  /**
   * The divider's leading (left) and trailing (right) inset from the column's edges, vp; undefined: it starts at the
   * column's leading edge (the card's and the band's edge) and ends at its trailing edge: all three share the same left and right.
   */
  headerSeparatorInsets?: CYLEdgeInsets = undefined;

  // Section headers
  headerHeight: number = 36;
  private headerMaxLinesValue: number = CYLHeaderTitleMaxLines.single;

  /**
   * The most lines a section header's title may take: default `CYLHeaderTitleMaxLines.single` (1, one line, truncated,
   * as before). With more, a long title wraps and the header grows taller than `headerHeight` to hold the wrapped
   * lines (`CYLHeaderTitleMaxLines.unlimited`: every line). A value that is not a whole number of 1 or more is 1.
   */
  get headerMaxLines(): number {
    return this.headerMaxLinesValue;
  }

  set headerMaxLines(value: number) {
    this.headerMaxLinesValue = Number.isFinite(value) || value === CYLHeaderTitleMaxLines.unlimited ?
      Math.max(CYLHeaderTitleMaxLines.single, Math.floor(value)) : CYLHeaderTitleMaxLines.single;
  }

  headerFont: CYLFont = CYLFont.systemFont(14);
  /**
   * The one color of every built-in view that is not a tag (header title, section icon, fold / More control); undefined:
   * black or white by the luminance of the background it is drawn on (`resolvedTintColor`). A color set on the title,
   * the fold control or the More button itself wins over it for that view.
   */
  tintColor?: ResourceColor = undefined;
  private headerTextColorValue?: ResourceColor = undefined;
  private foldControlColorValue?: ResourceColor = undefined;
  private moreButtonColorValue?: ResourceColor = undefined;

  /**
   * The section title's color: the system's primary font color (`sys.color.font_primary`, which follows dark mode, as
   * `UIColor.label` does on iOS) until the app sets one; the color drawn by default is `resolvedHeaderTextColor`.
   */
  get headerTextColor(): ResourceColor {
    return this.headerTextColorValue ?? CYLSectionStyleColors.systemTint;
  }

  set headerTextColor(value: ResourceColor) {
    this.headerTextColorValue = value;
  }
  headerHorizontalInset: number = 16;

  // Fold controls
  /** The fold controls' color: the list's one tint by default (see `headerTextColor`); a control's own color wins. */
  get foldControlColor(): ResourceColor {
    return this.foldControlColorValue ?? CYLSectionStyleColors.systemTint;
  }

  set foldControlColor(value: ResourceColor) {
    this.foldControlColorValue = value;
  }
  expandTitle: string = CYLMenuLocalizedString('CYLMenuExpand');
  foldChevronImage?: ResourceStr;
  collapseTitle: string = CYLMenuLocalizedString('CYLMenuCollapse');

  // The More button
  moreButtonImage?: ResourceStr;
  /** The More button's color: the list's one tint by default (see `headerTextColor`). */
  get moreButtonColor(): ResourceColor {
    return this.moreButtonColorValue ?? CYLSectionStyleColors.systemTint;
  }

  set moreButtonColor(value: ResourceColor) {
    this.moreButtonColorValue = value;
  }

  constructor() {
    this.storedNormal.borderColor = CYLColor.white(0.82);
    this.storedNormal.borderWidth = HAIRLINE;
    this.storedSelected.backgroundColor = CYLColor.APP_TINT;
    this.storedSelected.textColor = CYLColor.WHITE;
    this.storedSelected.borderColor = CYLColor.APP_TINT;
    this.storedSelected.borderWidth = HAIRLINE;
    this.storedDisabled.textColor = CYLColor.white(0.7);
    this.storedDisabled.borderColor = CYLColor.white(0.88);
    this.storedDisabled.borderWidth = HAIRLINE;
  }

  get normalAppearance(): CYLTagAppearance {
    return this.storedNormal;
  }

  get selectedAppearance(): CYLTagAppearance {
    return this.storedSelected;
  }

  get disabledAppearance(): CYLTagAppearance {
    return this.storedDisabled;
  }

  /**
   * The text of the delete indicator; an empty string restores "×".
   */
  get deleteIndicatorTitle(): string {
    return this.storedDeleteIndicatorTitle;
  }

  set deleteIndicatorTitle(value: string) {
    this.storedDeleteIndicatorTitle = value.length > 0 ? value : '×';
  }

  /**
   * The content insets of every state; reads the normal state's.
   */
  get tagContentInsets(): CYLEdgeInsets {
    return this.storedNormal.contentInsets;
  }

  set tagContentInsets(value: CYLEdgeInsets) {
    this.appearances().forEach((appearance: CYLTagAppearance) => appearance.contentInsets = value);
  }

  private appearances(): CYLTagAppearance[] {
    return [this.storedNormal, this.storedSelected, this.storedDisabled];
  }

  /**
   * The appearance of `state`: disabled wins over selected, which wins over normal.
   */
  appearance(state: number): CYLTagAppearance {
    if ((state & CYLControlState.DISABLED) !== 0) {
      return this.storedDisabled;
    }
    if ((state & CYLControlState.SELECTED) !== 0) {
      return this.storedSelected;
    }
    return this.storedNormal;
  }

  /**
   * Sets the font and text color of `state`; undefined restores the default.
   */
  setTitleTextAttributes(font: CYLFont | undefined, textColor: ResourceColor | undefined, state: number): void {
    const appearance = this.appearance(state);
    if (font !== undefined) {
      appearance.font = font;
    } else {
      appearance.resetFont();
    }
    if (textColor !== undefined) {
      appearance.textColor = textColor;
    } else {
      appearance.resetTextColor();
    }
  }

  /**
   * The font and text color of `state`.
   */
  titleTextAttributes(state: number): CYLTitleTextAttributes {
    const appearance = this.appearance(state);
    const attributes: CYLTitleTextAttributes = { font: appearance.font, textColor: appearance.textColor };
    return attributes;
  }

  setIconColor(iconColor: ResourceColor | undefined, state: number): void {
    this.appearance(state).iconColor = iconColor;
  }

  /**
   * The icon color of `state`, else its text color.
   */
  /** Whether an icon of this size is drawn by `imageFillsTagHeight` (a leading icon beside the title). */
  fillsTagHeight(iconSize: CYLSize): boolean {
    return this.imageFillsTagHeight && this.imagePlacement === CYLTagImagePlacement.leading &&
      (iconSize.width !== 0 || iconSize.height !== 0);
  }

  iconColor(state: number): ResourceColor {
    const appearance = this.appearance(state);
    return appearance.iconColor ?? appearance.textColor;
  }

  /**
   * The title as the tag shows it: cut to `maximumTitleLength` characters, the last three being "..." (AndroidTagView's
   * tag_max_length: 23 gives "Welcome to use Andro..."), and reversed character by
   * character when `reversesTitleCharacters`. Characters are Unicode code points (iOS counts grapheme clusters).
   */
  displayedTitle(title: string | undefined): string {
    let text = title ?? '';
    const characters = Array.from(text);
    if (this.maximumTitleLength > 0 && characters.length > this.maximumTitleLength) {
      text = characters.slice(0, Math.max(0, this.maximumTitleLength - 3)).join('') + '...';
    }
    if (this.reversesTitleCharacters && text.length > 1) {
      text = Array.from(text).reverse().join('');
    }
    return text;
  }

  /**
   * `font` as the views draw it: bold with Bold Text, scaled by `fontScale` when adjusting for the font size.
   */
  private scaledFont(font: CYLFont, fontScale: number, boldText: boolean): CYLFont {
    const result = boldText ? font.bold() : font;
    if (!this.adjustsFontForContentSizeCategory) {
      return result;
    }
    return result.withSize(result.size * Math.min(Math.max(fontScale, 0), CYLTagMetrics.maximumFontScale));
  }

  /**
   * The title font of `state` at the system font scale `fontScale` (the trait collection on iOS).
   */
  titleFont(state: number, fontScale: number = 1, boldText: boolean = false): CYLFont {
    return this.scaledFont(this.appearance(state).font, fontScale, boldText);
  }

  /**
   * `deleteIndicatorFont`, else the title font.
   */
  deleteIndicatorFontFor(state: number, fontScale: number = 1, boldText: boolean = false): CYLFont {
    return this.deleteIndicatorFont !== undefined ? this.scaledFont(this.deleteIndicatorFont, fontScale, boldText) :
    this.titleFont(state, fontScale, boldText);
  }

  /**
   * The header font at `fontScale`.
   */
  headerFontFor(fontScale: number = 1, boldText: boolean = false): CYLFont {
    return this.scaledFont(this.headerFont, fontScale, boldText);
  }

  /** True when the section style draws the cards. */
  get isInsetGrouped(): boolean {
    return this.sectionStyle === CYLSectionStyle.insetGrouped;
  }

  /**
   * The list background as drawn: the color the app set, else the grouped background under `insetGrouped`, else the system
   * background (a resource that follows the mode).
   */
  resolvedBackgroundColor(): ResourceColor {
    if (this.backgroundColorValue !== undefined) {
      return this.backgroundColorValue;
    }
    return this.isInsetGrouped ? CYLSectionStyleColors.groupedBackground : CYLSectionStyleColors.listBackground;
  }

  /**
   * The default tint (`tintColor` unset) of a built-in view drawn on `background`: black on a light one, white on a dark
   * one (`CYLTintLuminanceThreshold`); the system mode (`systemTint`: black in light, white in dark) when the background
   * is not known as a color: transparent, or a resource (the library's palette follows the mode as the system tint does).
   */
  static tintOn(background: ResourceColor | undefined): ResourceColor {
    const luminance = CYLMenuColorLuminance(background);
    if (luminance === undefined) {
      return CYLSectionStyleColors.systemTint;
    }
    return luminance > CYLTintLuminanceThreshold ? CYLColor.BLACK : CYLColor.WHITE;
  }

  /**
   * The tint of the built-in views as drawn: `tintColor`, else the default against what is behind them: the band color
   * when `onBand` (a header with a band) and a band is set, else the opaque background the list paints itself
   * (`resolvedBackgroundColor()`: the app's `backgroundColor`, the grouped background under `insetGrouped`).
   */
  resolvedTintColor(onBand: boolean = false): ResourceColor {
    if (this.tintColor !== undefined) {
      return this.tintColor;
    }
    return CYLMenuStyle.tintOn(onBand && this.headerBackgroundColor !== undefined ? this.headerBackgroundColor :
    this.resolvedBackgroundColor());
  }

  /** The section title's color as drawn: the one the app set, else the tint. */
  resolvedHeaderTextColor(onBand: boolean = false): ResourceColor {
    return this.headerTextColorValue ?? this.resolvedTintColor(onBand);
  }

  /** The clear button's color as drawn: the one the app set, else the section title's color. */
  resolvedClearButtonColor(onBand: boolean = false): ResourceColor {
    return this.clearButtonColor ?? this.resolvedHeaderTextColor(onBand);
  }

  /** The fold controls' color as drawn (a control's own color still wins): the one the app set, else the tint. */
  resolvedFoldControlColor(onBand: boolean = false): ResourceColor {
    return this.foldControlColorValue ?? this.resolvedTintColor(onBand);
  }

  /** The More button's color as drawn: the one the app set, else the tint. */
  resolvedMoreButtonColor(onBand: boolean = false): ResourceColor {
    return this.moreButtonColorValue ?? this.resolvedTintColor(onBand);
  }

  /** The card's background style as drawn: `sectionBackgroundStyle`, flat where `CYLLiquidGlass.isActive()` is false. */
  resolvedSectionBackgroundStyle(): CYLTagBackgroundStyle {
    return this.sectionBackgroundStyle === CYLTagBackgroundStyle.liquidGlass && CYLLiquidGlass.isActive() ?
    CYLTagBackgroundStyle.liquidGlass : CYLTagBackgroundStyle.flat;
  }

  /** The card's color as drawn: the glass tint for the drawn glass (the app's color wins), else the solid color. */
  resolvedSectionBackgroundColor(): ResourceColor {
    const fallback = this.resolvedSectionBackgroundStyle() === CYLTagBackgroundStyle.liquidGlass ?
    CYLSectionStyleColors.glassTint : CYLSectionStyleColors.card;
    return this.sectionBackgroundColor ?? fallback;
  }

  /** The divider's color as drawn. */
  resolvedHeaderSeparatorColor(): ResourceColor {
    return this.headerSeparatorColor ?? CYLSectionStyleColors.separator;
  }

  /**
   * NSCopying.
   */
  copy(): CYLMenuStyle {
    const c = new CYLMenuStyle();
    c.storedNormal = this.storedNormal.copy();
    c.storedSelected = this.storedSelected.copy();
    c.storedDisabled = this.storedDisabled.copy();
    c.storedDeleteIndicatorTitle = this.storedDeleteIndicatorTitle;
    c.highlightedBackgroundColor = this.highlightedBackgroundColor;
    c.deleteIndicatorColor = this.deleteIndicatorColor;
    c.deleteIndicatorFont = this.deleteIndicatorFont;
    c.deleteIndicatorLineWidth = this.deleteIndicatorLineWidth;
    c.deleteIndicatorWidth = this.deleteIndicatorWidth;
    c.deleteIndicatorPadding = this.deleteIndicatorPadding;
    c.deleteIndicatorPlacement = this.deleteIndicatorPlacement;
    c.rippleColor = this.rippleColor;
    c.rippleAlpha = this.rippleAlpha;
    c.rippleDuration = this.rippleDuration;
    c.maximumTitleLength = this.maximumTitleLength;
    c.reversesTitleCharacters = this.reversesTitleCharacters;
    c.rowAlignment = this.rowAlignment;
    c.headerIndicatorColor = this.headerIndicatorColor;
    c.headerIndicatorSize = this.headerIndicatorSize;
    c.imageCornerRadius = this.imageCornerRadius;
    c.imageFillsTagHeight = this.imageFillsTagHeight;
    c.editingIndicatorSpacing = this.editingIndicatorSpacing;
    c.editingIndicatorInsets = this.editingIndicatorInsets;
    c.clearButtonImage = this.clearButtonImage;
    c.clearButtonColor = this.clearButtonColor;
    c.titleMaxLines = this.titleMaxLines;
    c.elevation = this.elevation;
    c.deleteIndicatorImage = this.deleteIndicatorImage;
    c.imageTitleSpacing = this.imageTitleSpacing;
    c.imageSize = this.imageSize;
    c.imageInsets = this.imageInsets;
    c.titlePositionAdjustment = this.titlePositionAdjustment;
    c.imagePositionAdjustment = this.imagePositionAdjustment;
    c.imagePlacement = this.imagePlacement;
    c.layoutCentered = this.layoutCentered;
    c.contentAlignment = this.contentAlignment;
    c.backgroundStyle = this.backgroundStyle;
    c.minimumTagSize = this.minimumTagSize;
    c.animationSize = this.animationSize;
    c.animationSpeed = this.animationSpeed;
    c.adjustsFontForContentSizeCategory = this.adjustsFontForContentSizeCategory;
    c.itemHeight = this.itemHeight;
    c.numberOfItemsPerRow = this.numberOfItemsPerRow;
    c.interitemSpacing = this.interitemSpacing;
    c.lineSpacing = this.lineSpacing;
    c.sectionInsets = this.sectionInsets;
    c.backgroundColorValue = this.backgroundColorValue;
    c.sectionStyle = this.sectionStyle;
    c.sectionBackgroundColor = this.sectionBackgroundColor;
    c.sectionBackgroundStyle = this.sectionBackgroundStyle;
    c.sectionCornerRadius = this.sectionCornerRadius;
    c.sectionContentInsets = this.sectionContentInsets;
    c.headerBackgroundColor = this.headerBackgroundColor;
    c.headerCornerRadius = this.headerCornerRadius;
    c.headerContentInsets = this.headerContentInsets;
    c.headerSeparatorStyle = this.headerSeparatorStyle;
    c.headerSeparatorColor = this.headerSeparatorColor;
    c.headerSeparatorThickness = this.headerSeparatorThickness;
    c.headerSeparatorInsets = this.headerSeparatorInsets;
    c.headerHeight = this.headerHeight;
    c.headerMaxLines = this.headerMaxLines;
    c.headerFont = this.headerFont;
    c.tintColor = this.tintColor;
    c.headerTextColorValue = this.headerTextColorValue;
    c.headerHorizontalInset = this.headerHorizontalInset;
    c.foldControlColorValue = this.foldControlColorValue;
    c.expandTitle = this.expandTitle;
    c.foldChevronImage = this.foldChevronImage;
    c.collapseTitle = this.collapseTitle;
    c.moreButtonImage = this.moreButtonImage;
    c.moreButtonColorValue = this.moreButtonColorValue;
    return c;
  }

  /**
   * The default style.
   */
  static defaultStyle(): CYLMenuStyle {
    return new CYLMenuStyle();
  }

  /**
   * android-tagview's look: blue square tags, white text, 5 vp spacing.
   */
  /** The tags' base look of the classify menu and the filter (iOS `compactTagStyle()`). */
  private static compactTagStyle(): CYLMenuStyle {
    const style = new CYLMenuStyle();
    const font = CYLFont.systemFont(CYLTagMetrics.titleFontSize);
    style.appearances().forEach((appearance: CYLTagAppearance) => {
      appearance.font = font;
      appearance.borderWidth = 0;
      appearance.contentInsets = new CYLEdgeInsets(0, 4, 0, 4);
    });
    style.imageTitleSpacing = 5;
    style.imageSize = new CYLSize(16, 16);
    style.itemHeight = 30;
    style.backgroundColor = CYLColor.CLEAR;
    style.sectionStyle = CYLSectionStyle.plain;
    return style;
  }

  /**
   * `classifyMenuTag(_:)`: a tag of `CYLClassifyMenuViewController` in one of its looks, by the raw value of
   * `CYLCollectionCellButtonStyle` (0 general, 1 home, 2 red, 3 chengNi, the default: a light green capsule that takes the
   * app's tint while selected or pressed).
   */
  static classifyMenuTag(look: number = 3): CYLMenuStyle {
    const style = CYLMenuStyle.compactTagStyle();
    const green = CYLColor.argb(255, 18, 133, 117);
    const selected = style.appearance(CYLControlState.SELECTED);
    if (look === 0) {
      style.appearances().forEach((appearance: CYLTagAppearance) => {
        appearance.cornerRadius = 5;
        appearance.backgroundColor = CYLColor.WHITE;
        appearance.borderWidth = 1;
        appearance.borderColor = CYLColor.BLACK;
      });
    } else if (look === 1) {
      style.appearances().forEach((appearance: CYLTagAppearance) => {
        appearance.textColor = green;
        appearance.borderColor = green;
      });
      selected.textColor = CYLColor.withAlpha(green, 0.7);
      style.highlightedBackgroundColor = green;
    } else if (look === 2) {
      const red = CYLColor.argb(255, 160, 15, 85);
      style.appearances().forEach((appearance: CYLTagAppearance) => {
        appearance.textColor = red;
        appearance.borderColor = red;
      });
      style.highlightedBackgroundColor = green;
    } else {
      style.appearances().forEach((appearance: CYLTagAppearance) => {
        appearance.cornerRadius = 13;
        appearance.backgroundColor = CYLColor.argb(255, 230, 255, 244);
        appearance.textColor = CYLColor.APP_TINT;
      });
      selected.backgroundColor = CYLColor.APP_TINT;
      selected.backgroundImage = CYLMenuResources.image('tag_btn_background_highlighted');
      selected.textColor = CYLColor.WHITE;
      style.highlightedBackgroundColor = CYLColor.APP_TINT;
    }
    return style;
  }

  /**
   * `filterTag()`: a tag of the multiple-choice filter: the filter's slide images as the normal and selected
   * backgrounds, green titles that turn white when selected.
   */
  static filterTag(): CYLMenuStyle {
    const style = CYLMenuStyle.compactTagStyle();
    style.appearances().forEach((appearance: CYLTagAppearance) => {
      appearance.backgroundColor = CYLColor.CLEAR;
      appearance.cornerRadius = 0;
    });
    const normal = style.appearance(CYLControlState.NORMAL);
    normal.backgroundImage = CYLMenuResources.image('btn_slide_normal');
    normal.textColor = CYLColor.argb(255, 96, 147, 130);
    const selected = style.appearance(CYLControlState.SELECTED);
    selected.backgroundImage = CYLMenuResources.image('btn_slide_selected');
    selected.textColor = CYLColor.WHITE;
    return style;
  }

  /**
   * `sectionTitle(fontSize:textColor:leadingInset:)`: a header's section title: no background or border, the content at
   * the leading edge after `leadingInset`, an icon 4 vp before the title.
   */
  static sectionTitle(fontSize: number = 15, textColor: ResourceColor = CYLColor.BLACK, leadingInset: number = 0): CYLMenuStyle {
    const style = new CYLMenuStyle();
    style.appearances().forEach((appearance: CYLTagAppearance) => {
      appearance.backgroundColor = CYLColor.CLEAR;
      appearance.borderWidth = 0;
      appearance.borderColor = undefined;
      appearance.cornerRadius = 0;
      appearance.textColor = textColor;
      appearance.font = CYLFont.systemFont(fontSize);
      appearance.contentInsets = new CYLEdgeInsets(0, leadingInset, 0, 0);
    });
    style.contentAlignment = CYLTagContentAlignment.leading;
    style.imageSize = new CYLSize(16, 16);
    style.imageTitleSpacing = 4;
    style.itemHeight = 0;
    style.backgroundColor = CYLColor.CLEAR;
    style.sectionStyle = CYLSectionStyle.plain;
    return style;
  }

  static tagCloud(): CYLMenuStyle {
    const style = new CYLMenuStyle();
    const blue = CYLColor.argb(255, 0, 0xBF, 0xFF);
    style.appearances().forEach((appearance: CYLTagAppearance) => {
      appearance.backgroundColor = blue;
      appearance.textColor = CYLColor.WHITE;
      appearance.borderWidth = 0;
      appearance.borderColor = CYLColor.WHITE;
      appearance.cornerRadius = CYLAnimatedItemCornerRadiusCapsule;
      appearance.font = CYLFont.systemFont(14);
    });
    style.storedDisabled.backgroundColor = CYLColor.withAlpha(blue, 0.4);
    style.highlightedBackgroundColor = CYLColor.argb(0x88, 0x36, 0x36, 0x36);
    style.tagContentInsets = new CYLEdgeInsets(5, 8, 5, 8);
    style.interitemSpacing = 5;
    style.lineSpacing = 5;
    style.itemHeight = 0;
    style.backgroundColor = CYLColor.CLEAR;
    style.sectionStyle = CYLSectionStyle.plain;
    return style;
  }

  /**
   * `wordPicker()` (选词填入, as WeChat's "涂抹选择填入词"): one character per cell, 9 equal cells per row, light gray
   * cells with small corners that turn mint green when selected, the character centered. Use it with
   * `CYLTagListState.setTagsWithCharactersOfText`, multiple selection and `allowsSmearSelection`; the picked text is
   * `selectedText`.
   */
  static wordPicker(): CYLMenuStyle {
    const style = new CYLMenuStyle();
    style.numberOfItemsPerRow = 9;
    const font = new CYLFont(18, FontWeight.Medium);
    style.appearances().forEach((appearance: CYLTagAppearance) => {
      appearance.font = font;
      appearance.cornerRadius = 3;
      appearance.borderWidth = 0;
      appearance.borderColor = undefined;
      appearance.margin = 0;
      appearance.textColor = CYLColor.argb(255, 0x1C, 0x1C, 0x1E);
      appearance.backgroundColor = CYLColor.argb(255, 0xF2, 0xF2, 0xF7);
    });
    // Mint green (iOS 0.70 / 0.92 / 0.81).
    style.storedSelected.backgroundColor = CYLColor.argb(255, 0xB3, 0xEB, 0xCF);
    style.storedDisabled.textColor = CYLColor.argb(0x4C, 0x3C, 0x3C, 0x43);
    style.contentAlignment = CYLTagContentAlignment.center;
    style.layoutCentered = true;
    style.itemHeight = 40;
    style.interitemSpacing = 6;
    style.lineSpacing = 10;
    style.sectionInsets = new CYLEdgeInsets(12, 24, 12, 24);
    style.backgroundColor = CYLColor.CLEAR;
    style.sectionStyle = CYLSectionStyle.plain;
    return style;
  }

  /**
   * AndroidTagView's look: translucent red capsules, gray text, 23 characters at most.
   */
  static tagContainer(): CYLMenuStyle {
    const style = new CYLMenuStyle();
    const gray = CYLColor.argb(255, 0x66, 0x66, 0x66);
    style.appearances().forEach((appearance: CYLTagAppearance) => {
      appearance.backgroundColor = CYLColor.argb(0x33, 0xF4, 0x43, 0x36);
      appearance.borderColor = CYLColor.argb(0x88, 0xF4, 0x43, 0x36);
      appearance.borderWidth = 0.5;
      appearance.textColor = gray;
      appearance.cornerRadius = 15;
      appearance.font = CYLFont.systemFont(14);
    });
    style.storedSelected.backgroundColor = CYLColor.argb(0x33, 0xFF, 0x76, 0x69);
    style.storedDisabled.textColor = CYLColor.withAlpha(gray, 0.5);
    style.tagContentInsets = new CYLEdgeInsets(8, 10, 8, 10);
    style.interitemSpacing = 5;
    style.lineSpacing = 5;
    style.itemHeight = 0;
    style.maximumTitleLength = 23;
    style.deleteIndicatorLineWidth = 1;
    style.deleteIndicatorPadding = 10;
    style.deleteIndicatorColor = CYLColor.BLACK;
    style.rippleColor = CYLColor.argb(255, 0xEE, 0xEE, 0xEE);
    style.rippleAlpha = 128 / 255;
    style.backgroundColor = CYLColor.CLEAR;
    style.sectionStyle = CYLSectionStyle.plain;
    return style;
  }

  /**
   * Borderless items in `itemsPerRow` columns, the icon after the title.
   */
  static gridStyle(itemsPerRow: number): CYLMenuStyle {
    const style = new CYLMenuStyle();
    style.numberOfItemsPerRow = Math.max(1, itemsPerRow);
    const font = CYLFont.systemFont(17);
    style.appearances().forEach((appearance: CYLTagAppearance) => {
      appearance.backgroundColor = CYLColor.CLEAR;
      appearance.borderWidth = 0;
      appearance.borderColor = undefined;
      appearance.margin = 0;
      appearance.font = font;
    });
    style.storedNormal.textColor = CYLColor.BLACK;
    style.storedSelected.textColor = CYLColor.BLACK;
    style.storedDisabled.textColor = CYLColor.white(0.24, 0.3);
    style.contentAlignment = CYLTagContentAlignment.leading;
    style.imagePlacement = CYLTagImagePlacement.trailing;
    style.imageSize = new CYLSize(18, 18);
    style.imageTitleSpacing = 6;
    style.itemHeight = 32;
    style.interitemSpacing = 24;
    style.lineSpacing = 18;
    style.sectionStyle = CYLSectionStyle.plain;
    return style;
  }
}
