/**
 * The look of a tag list, as iOS `CYLMenuStyle`: the tags in each state (`CYLTagAppearance`), the delete indicator,
 * the touch ripple, titles, rows, icons, layout spacing, section headers, fold controls and the More button. Lengths
 * are vp, font sizes fp, colors '#AARRGGBB'. `copy()` is NSCopying.
 */
import { CYLTagAppearance, CYLTagCornerRadiusSquare } from './CYLTagAppearance';
import { CYLColor, CYLControlState, CYLEdgeInsets, CYLFont, CYLOffset, CYLSize } from './CYLTypes';
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
 * A tag border of one physical pixel (iOS: 1 / screen scale).
 */
const HAIRLINE: number = 0.5;

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
  layoutCentered: boolean = true;
  contentAlignment: CYLTagContentAlignment = CYLTagContentAlignment.center;
  animationSize: CYLSize = CYLSize.ZERO;
  animationSpeed: number = 1;
  adjustsFontForContentSizeCategory: boolean = true;
  itemHeight: number = 30;
  numberOfItemsPerRow: number = 0;

  // Layout
  interitemSpacing: number = 10;
  lineSpacing: number = 10;
  sectionInsets: CYLEdgeInsets = new CYLEdgeInsets(10, 16, 10, 16);
  backgroundColor: string = CYLColor.WHITE;

  // Section headers
  headerHeight: number = 36;
  headerFont: CYLFont = CYLFont.systemFont(14);
  headerTextColor: string = CYLColor.GRAY;
  headerHorizontalInset: number = 16;

  // Fold controls
  foldControlColor: string = CYLColor.GRAY;
  expandTitle: string = CYLMenuLocalizedString('CYLMenuExpand');
  foldChevronImage?: ResourceStr;
  collapseTitle: string = CYLMenuLocalizedString('CYLMenuCollapse');

  // The More button
  moreButtonImage?: ResourceStr;
  /**
   * `UIColor.secondaryLabel` in its light appearance.
   */
  moreButtonColor: string = CYLColor.argb(153, 60, 60, 67);

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
  iconColor(state: number): ResourceColor {
    const appearance = this.appearance(state);
    return appearance.iconColor ?? appearance.textColor;
  }

  /**
   * The title as the tag shows it: at most `maximumTitleLength` characters then "...", and reversed character by
   * character when `reversesTitleCharacters`. Characters are Unicode code points (iOS counts grapheme clusters).
   */
  displayedTitle(title: string | undefined): string {
    let text = title ?? '';
    const characters = Array.from(text);
    if (this.maximumTitleLength > 0 && characters.length > this.maximumTitleLength) {
      text = characters.slice(0, this.maximumTitleLength).join('') + '...';
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
    c.imageTitleSpacing = this.imageTitleSpacing;
    c.imageSize = this.imageSize;
    c.imageInsets = this.imageInsets;
    c.titlePositionAdjustment = this.titlePositionAdjustment;
    c.imagePositionAdjustment = this.imagePositionAdjustment;
    c.imagePlacement = this.imagePlacement;
    c.layoutCentered = this.layoutCentered;
    c.contentAlignment = this.contentAlignment;
    c.animationSize = this.animationSize;
    c.animationSpeed = this.animationSpeed;
    c.adjustsFontForContentSizeCategory = this.adjustsFontForContentSizeCategory;
    c.itemHeight = this.itemHeight;
    c.numberOfItemsPerRow = this.numberOfItemsPerRow;
    c.interitemSpacing = this.interitemSpacing;
    c.lineSpacing = this.lineSpacing;
    c.sectionInsets = this.sectionInsets;
    c.backgroundColor = this.backgroundColor;
    c.headerHeight = this.headerHeight;
    c.headerFont = this.headerFont;
    c.headerTextColor = this.headerTextColor;
    c.headerHorizontalInset = this.headerHorizontalInset;
    c.foldControlColor = this.foldControlColor;
    c.expandTitle = this.expandTitle;
    c.foldChevronImage = this.foldChevronImage;
    c.collapseTitle = this.collapseTitle;
    c.moreButtonImage = this.moreButtonImage;
    c.moreButtonColor = this.moreButtonColor;
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
      appearance.cornerRadius = CYLTagCornerRadiusSquare;
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
      appearance.cornerRadius = CYLTagCornerRadiusSquare;
      appearance.textColor = textColor;
      appearance.font = CYLFont.systemFont(fontSize);
      appearance.contentInsets = new CYLEdgeInsets(0, leadingInset, 0, 0);
    });
    style.contentAlignment = CYLTagContentAlignment.leading;
    style.imageSize = new CYLSize(16, 16);
    style.imageTitleSpacing = 4;
    style.itemHeight = 0;
    style.backgroundColor = CYLColor.CLEAR;
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
      appearance.cornerRadius = 0;
      appearance.font = CYLFont.systemFont(14);
    });
    style.storedDisabled.backgroundColor = CYLColor.withAlpha(blue, 0.4);
    style.highlightedBackgroundColor = CYLColor.argb(0x88, 0x36, 0x36, 0x36);
    style.tagContentInsets = new CYLEdgeInsets(5, 8, 5, 8);
    style.interitemSpacing = 5;
    style.lineSpacing = 5;
    style.itemHeight = 0;
    style.backgroundColor = CYLColor.CLEAR;
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
    return style;
  }
}
