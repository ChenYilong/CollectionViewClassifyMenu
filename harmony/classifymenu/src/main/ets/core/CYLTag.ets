import { CYLUIContext } from './CYLUIContext';
/**
 * A tag of a tag list built from models, as iOS `CYLTag.swift`: `CYLTag` (a title with its own look) and
 * `CYLTagDataSource` (a one-section data source of tags, caching each tag's style over its `baseStyle`).
 */
import { CYLIndexPath } from '../components/CYLTagListModel';
import { CYLMenuDataSource } from './CYLMenuDataSource';
import { CYLMenuStyle } from './CYLMenuStyle';
import { CYLTagColors } from './CYLTagColors';
import { CYLMenuColorFromString } from './CYLMenuColor';
import { CYLFont, CYLImage } from './CYLTypes';
import { image } from '@kit.ImageKit';

function validValue(value: number | undefined): number | undefined {
  return value !== undefined && Number.isFinite(value) && value >= 0 ? value : undefined;
}

/** `UIColor.systemBlue`, the badge color when the tag has neither a badge nor a text color. */
const SYSTEM_BLUE: string = '#FF007AFF';
/** `UIColor.systemRed`, the badge dot's color when the tag has no badge color (`CYLTagBadgeDefaultColor`). */
const SYSTEM_RED: string = '#FFFF3B30';
/** The diameter of a badge dot, vp. */
const BADGE_DOT_DIAMETER: number = 8;
/** The side padding of a badge image's text, vp. */
const BADGE_IMAGE_TEXT_PADDING: number = 4;
/** The badge text's font size as a share of the badge diameter. */
const BADGE_IMAGE_FONT_RATIO: number = 0.6;
/** The badge diameter when the style's image size is zero, vp. */
const BADGE_DEFAULT_DIAMETER: number = 16;

export class CYLTag {
  identifier: number;
  title: string;
  /** A longer description, shown in a callout on a long press (`CYLTagLongPressActions.callout`). */
  subtitle?: string;
  image?: CYLImage;
  selectedImage?: CYLImage;
  /** A Lottie animation: `asset:<rawfile path>` or the JSON text. */
  animationURL?: string;
  isEnabled: boolean = true;
  isDeletable: boolean = false;
  /** A badge drawn as the tag's image when it has none (a count, "hot"). */
  badgeText?: string;
  badgeColor?: string;
  badgeAccessibilityLabel?: string;
  userInfo?: Object;
  private styleStorage?: CYLMenuStyle;
  textColor?: string;
  font?: CYLFont;
  textSize?: number;
  backgroundColor?: string;
  highlightedBackgroundColor?: string;
  selectedBackgroundColor?: string;
  backgroundImage?: ResourceStr;
  cornerRadius?: number;
  borderWidth?: number;
  borderColor?: string;
  deleteIndicatorTitle?: string;
  deleteIndicatorColor?: string;
  deleteIndicatorSize?: number;

  constructor(identifier: number = 0, title: string = '', backgroundColor?: string) {
    this.identifier = identifier;
    this.title = title;
    this.backgroundColor = backgroundColor;
  }

  /** `init(identifier:title:backgroundColorHex:)`: the background from "#RRGGBB" or a UIColor name. */
  static withHex(identifier: number, title: string, backgroundColorHex: string | undefined): CYLTag {
    return new CYLTag(identifier, title, CYLMenuColorFromString(backgroundColorHex));
  }

  /** The tag's own style (copied when set); undefined for the list's. */
  get style(): CYLMenuStyle | undefined {
    return this.styleStorage;
  }

  set style(value: CYLMenuStyle | undefined) {
    this.styleStorage = value?.copy();
  }

  /** The four colors of the tag; setting it sets them. */
  get colors(): CYLTagColors {
    return new CYLTagColors(this.backgroundColor, this.borderColor, this.textColor, this.selectedBackgroundColor);
  }

  /** `resetColors()`: the colors back to their defaults (the style's). */
  resetColors(): void {
    this.colors = new CYLTagColors();
  }

  set colors(value: CYLTagColors) {
    this.backgroundColor = value.backgroundColor;
    this.borderColor = value.borderColor;
    this.textColor = value.textColor;
    this.selectedBackgroundColor = value.selectedBackgroundColor;
  }

  /** Whether the tag changes anything of the list's style. */
  get hasCustomStyle(): boolean {
    return this.styleStorage !== undefined || this.textColor !== undefined || this.font !== undefined ||
      validValue(this.textSize) !== undefined || this.backgroundColor !== undefined ||
      this.highlightedBackgroundColor !== undefined || this.selectedBackgroundColor !== undefined ||
      this.backgroundImage !== undefined || validValue(this.cornerRadius) !== undefined ||
      validValue(this.borderWidth) !== undefined || this.borderColor !== undefined ||
      this.deleteIndicatorTitle !== undefined || this.deleteIndicatorColor !== undefined ||
      validValue(this.deleteIndicatorSize) !== undefined;
  }

  /** The tag's look over `baseStyle` (over its own `style` when set). */
  styleBasedOn(baseStyle: CYLMenuStyle): CYLMenuStyle {
    const style = (this.styleStorage ?? baseStyle).copy();
    const normal = style.normalAppearance;
    const cornerRadius = validValue(this.cornerRadius);
    const borderWidth = validValue(this.borderWidth);
    if (this.textColor !== undefined) {
      normal.textColor = this.textColor;
    }
    if (this.backgroundColor !== undefined) {
      normal.backgroundColor = this.backgroundColor;
    }
    if (this.backgroundImage !== undefined) {
      normal.backgroundImage = this.backgroundImage;
    }
    if (this.borderColor !== undefined) {
      normal.borderColor = this.borderColor;
      if (borderWidth === undefined && normal.borderWidth <= 0) {
        normal.borderWidth = 1;
      }
    }
    const size = validValue(this.textSize);
    const font: CYLFont | undefined = this.font ?? (size !== undefined && size > 0 ? CYLFont.systemFont(size) : undefined);
    [normal, style.selectedAppearance, style.disabledAppearance].forEach((appearance) => {
      if (font !== undefined) {
        appearance.font = font;
      }
      if (cornerRadius !== undefined) {
        appearance.cornerRadius = cornerRadius;
      }
      if (borderWidth !== undefined) {
        appearance.borderWidth = borderWidth;
      }
    });
    if (this.highlightedBackgroundColor !== undefined) {
      style.highlightedBackgroundColor = this.highlightedBackgroundColor;
    }
    if (this.selectedBackgroundColor !== undefined) {
      style.selectedAppearance.backgroundColor = this.selectedBackgroundColor;
    }
    if (this.deleteIndicatorTitle !== undefined) {
      style.deleteIndicatorTitle = this.deleteIndicatorTitle;
    }
    if (this.deleteIndicatorColor !== undefined) {
      style.deleteIndicatorColor = this.deleteIndicatorColor;
    }
    const indicator = validValue(this.deleteIndicatorSize);
    if (indicator !== undefined && indicator > 0) {
      style.deleteIndicatorFont = CYLFont.systemFont(indicator);
    }
    return style;
  }

  /** NSCopying. */
  copy(): CYLTag {
    const c = new CYLTag(this.identifier, this.title, this.backgroundColor);
    c.image = this.image;
    c.selectedImage = this.selectedImage;
    c.animationURL = this.animationURL;
    c.isEnabled = this.isEnabled;
    c.isDeletable = this.isDeletable;
    c.userInfo = this.userInfo;
    c.styleStorage = this.styleStorage;
    c.textColor = this.textColor;
    c.font = this.font;
    c.textSize = this.textSize;
    c.highlightedBackgroundColor = this.highlightedBackgroundColor;
    c.selectedBackgroundColor = this.selectedBackgroundColor;
    c.badgeText = this.badgeText;
    c.badgeColor = this.badgeColor;
    c.badgeAccessibilityLabel = this.badgeAccessibilityLabel;
    c.backgroundImage = this.backgroundImage;
    c.cornerRadius = this.cornerRadius;
    c.borderWidth = this.borderWidth;
    c.borderColor = this.borderColor;
    c.deleteIndicatorTitle = this.deleteIndicatorTitle;
    c.deleteIndicatorColor = this.deleteIndicatorColor;
    c.deleteIndicatorSize = this.deleteIndicatorSize;
    return c;
  }

  /** The diameter of a badge dot, vp: 8, as `CYLTagButton`'s dot (iOS `badgeDotDiameter`). */
  static readonly badgeDotDiameter: number = BADGE_DOT_DIAMETER;
  /** The side padding of a badge image's text, vp: 4, as `CYLTagButton`'s corner badge (iOS `badgeImageTextPadding`). */
  static readonly badgeImageTextPadding: number = BADGE_IMAGE_TEXT_PADDING;

  /** A badge dot: a filled `color` circle `badgeDotDiameter` vp wide (at most `canvas`), centered in a `canvas` square. */
  static badgeDotImage(color: string, canvas: number): image.PixelMap {
    const side = Math.max(1, canvas);
    const dot = Math.min(CYLTag.badgeDotDiameter, side);
    const pixels = Math.max(1, Math.round(CYLUIContext.vp2px(side)));
    const surface = new OffscreenCanvas(pixels, pixels);
    const context = surface.getContext('2d');
    context.fillStyle = color;
    context.beginPath();
    const center = pixels / 2;
    context.arc(center, center, CYLUIContext.vp2px(dot) / 2, 0, Math.PI * 2);
    context.fill();
    return context.getPixelMap(0, 0, pixels, pixels);
  }

  /**
   * The width of a badge image: the diameter (a circle) for a short text, or `textWidth` and `badgeImageTextPadding` on
   * both sides when that is more (a capsule; iOS `badgeImageWidth`: max(diameter, text + 2 * padding)). Pure, so that
   * the math is testable without a canvas.
   */
  static badgeImageWidthForText(textWidth: number, diameter: number,
    padding: number = BADGE_IMAGE_TEXT_PADDING): number {
    const side = Math.max(1, diameter);
    return Math.max(side, Math.ceil(Math.max(0, textWidth)) + 2 * padding);
  }

  /** The font of a badge image's text: bold, 60 % of the diameter, in vp (the canvas' default unit). */
  private static badgeImageFont(diameter: number): string {
    return `bold ${Math.round(diameter * BADGE_IMAGE_FONT_RATIO)}vp sans-serif`;
  }

  /** A capsule of `color`, `diameter` vp high, with `text` in bold white at 60 % of the diameter (a circle when short). */
  static badgeImage(text: string, color: string, diameter: number): image.PixelMap {
    // The canvas is drawn in px (as before the capsule), the font in vp (see below); the width math runs in px.
    const pixelHeight = Math.max(1, Math.round(CYLUIContext.vp2px(Math.max(1, diameter))));
    const font = CYLTag.badgeImageFont(pixelHeight);
    const probe = new OffscreenCanvas(1, 1).getContext('2d');
    probe.font = font;
    const pixelWidth = Math.max(1, Math.round(CYLTag.badgeImageWidthForText(probe.measureText(text).width,
      pixelHeight, CYLUIContext.vp2px(CYLTag.badgeImageTextPadding))));
    const canvas = new OffscreenCanvas(pixelWidth, pixelHeight);
    const context = canvas.getContext('2d');
    context.fillStyle = color;
    const radius = pixelHeight / 2;
    context.beginPath();
    context.moveTo(radius, 0);
    context.lineTo(pixelWidth - radius, 0);
    context.arc(pixelWidth - radius, radius, radius, -Math.PI / 2, Math.PI / 2);
    context.lineTo(radius, pixelHeight);
    context.arc(radius, radius, radius, Math.PI / 2, Math.PI * 1.5);
    context.closePath();
    context.fill();
    context.fillStyle = '#FFFFFFFF';
    // Canvas coordinates are vp (its default unit), so the font is too: a px font drew the glyph a density-fraction
    // of the circle (unreadable "神" / "热" in the hot-search badges).
    context.font = font;
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    context.fillText(text, pixelWidth / 2, pixelHeight / 2);
    return context.getPixelMap(0, 0, pixelWidth, pixelHeight);
  }

  get description(): string {
    return `<CYLTag: identifier = ${this.identifier}; title = ${this.title}>`;
  }
}

/** A one-section data source of tags; each tag's style over `baseStyle` is cached until `invalidateStyles()`. */
export class CYLTagDataSource implements CYLMenuDataSource {
  sectionTitle?: string;
  private storedTags: CYLTag[];
  private baseStyleStorage: CYLMenuStyle = new CYLMenuStyle();
  private styles: Map<CYLTag, CYLMenuStyle> = new Map<CYLTag, CYLMenuStyle>();

  constructor(tags: CYLTag[] = []) {
    this.storedTags = tags.slice();
  }

  get tags(): CYLTag[] {
    return this.storedTags;
  }

  set tags(value: CYLTag[]) {
    this.storedTags = value.slice();
    this.invalidateStyles();
  }

  /** The style the tags' own looks apply over (copied when set). */
  get baseStyle(): CYLMenuStyle {
    return this.baseStyleStorage;
  }

  set baseStyle(value: CYLMenuStyle) {
    this.baseStyleStorage = value.copy();
    this.invalidateStyles();
  }

  addTag(tag: CYLTag): void {
    this.storedTags.push(tag);
  }

  addTags(tags: CYLTag[]): void {
    tags.forEach((tag: CYLTag) => this.storedTags.push(tag));
  }

  insertTag(tag: CYLTag, index: number): void {
    this.storedTags.splice(Math.min(Math.max(0, index), this.storedTags.length), 0, tag);
  }

  removeTag(index: number): void {
    if (index < 0 || index >= this.storedTags.length) {
      return;
    }
    this.styles.delete(this.storedTags[index]);
    this.storedTags.splice(index, 1);
  }

  removeAllTags(): void {
    this.storedTags = [];
    this.invalidateStyles();
  }

  moveTag(fromIndex: number, toIndex: number): void {
    const count = this.storedTags.length;
    if (fromIndex < 0 || fromIndex >= count || toIndex < 0 || toIndex >= count || fromIndex === toIndex) {
      return;
    }
    const moved = this.storedTags.splice(fromIndex, 1)[0];
    this.storedTags.splice(toIndex, 0, moved);
  }

  invalidateStyles(): void {
    this.styles.clear();
  }

  private tagAt(indexPath: CYLIndexPath): CYLTag | undefined {
    return indexPath.section === 0 && indexPath.item >= 0 && indexPath.item < this.storedTags.length ?
    this.storedTags[indexPath.item] : undefined;
  }

  numberOfSectionsInMenu(): number {
    return 1;
  }

  menuNumberOfItemsInSection(section: number): number {
    return section === 0 ? this.storedTags.length : 0;
  }

  menuTitleForSection(section: number): string {
    return this.sectionTitle ?? '';
  }

  menuTitleForItem(indexPath: CYLIndexPath): string {
    return this.tagAt(indexPath)?.title ?? '';
  }

  /** The tag's image; a tag with a badge and no image gets the badge drawn at the style's image size. */
  menuImageForItem = (indexPath: CYLIndexPath): CYLImage | undefined => {
    const tag = this.tagAt(indexPath);
    if (tag === undefined) {
      return undefined;
    }
    if (tag.image === undefined && tag.badgeText !== undefined) {
      const size = this.baseStyleStorage.imageSize;
      const side = Math.max(size.width, size.height);
      const canvas = side > 0 ? side : BADGE_DEFAULT_DIAMETER;
      // "" is a dot (iOS `badgeDotImage`, red by default); any text is a capsule (blue by default).
      tag.image = tag.badgeText.length === 0
        ? CYLTag.badgeDotImage(tag.badgeColor ?? SYSTEM_RED, canvas)
        : CYLTag.badgeImage(tag.badgeText, tag.badgeColor ?? tag.textColor ?? SYSTEM_BLUE, canvas);
    }
    return tag.image;
  }
  menuSubtitleForItem = (indexPath: CYLIndexPath): string | undefined => this.tagAt(indexPath)?.subtitle;
  menuSelectedImageForItem = (indexPath: CYLIndexPath): CYLImage | undefined => this.tagAt(indexPath)?.selectedImage;
  menuAnimationURLForItem = (indexPath: CYLIndexPath): string | undefined => this.tagAt(indexPath)?.animationURL;
  menuItemIsEnabled = (indexPath: CYLIndexPath): boolean => this.tagAt(indexPath)?.isEnabled ?? true;
  menuItemIsDeletable = (indexPath: CYLIndexPath): boolean => this.tagAt(indexPath)?.isDeletable ?? false;
  menuRemoveItem = (indexPath: CYLIndexPath): void => {
    if (this.tagAt(indexPath) !== undefined) {
      this.removeTag(indexPath.item);
    }
  }
  menuMoveItem = (from: CYLIndexPath, to: CYLIndexPath): void => {
    if (from.section === 0 && to.section === 0) {
      this.moveTag(from.item, to.item);
    }
  }
  /** The cached style of a tag with its own look; undefined for the list's. */
  menuStyleForItem = (indexPath: CYLIndexPath): CYLMenuStyle | undefined => {
    const tag = this.tagAt(indexPath);
    if (tag === undefined || !tag.hasCustomStyle) {
      return undefined;
    }
    let style = this.styles.get(tag);
    if (style === undefined) {
      style = tag.styleBasedOn(this.baseStyleStorage);
      this.styles.set(tag, style);
    }
    return style;
  }
}
