/**
 * The model and controller of a `CYLTagListView`, as iOS `CYLTagListView.swift` without its UIKit views: the data
 * source and delegate, the style, selection, folding, measurement and row layout, the title, the android-tagview tag
 * methods and reordering. It needs no UI to be used or tested; `CYLTagListView` renders it and calls back into it.
 * Lengths are vp.
 */
import { MeasureText } from '@kit.ArkUI';
import { fileIo } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { CYLIndexPath } from './CYLTagListModel';
import { CYLMenuDataSource, CYLMenuDefaults, CYLMenuDelegate, CYLMenuItemType } from '../core/CYLMenuDataSource';
import { CYLMenuFoldControl, CYLMenuFoldControlContent, CYLMenuFoldControlPosition } from '../core/CYLMenuFoldControl';
import { CYLMenuLocalizedString, CYLMenuResources } from '../core/CYLMenuResources';
import { CYLMenuStyle, CYLTagContentAlignment, CYLTagImagePlacement, CYLTagRowAlignment } from '../core/CYLMenuStyle';
import { CYLTag, CYLTagDataSource } from '../core/CYLTag';
import { CYLTagAppearance } from '../core/CYLTagAppearance';
import { CYLTagColors, CYLTagColorTheme } from '../core/CYLTagColors';
import {
  CYLConfiguration, CYLConfigurationValue, CYLMenuConfiguration, CYLMenuConfigurationError,
  CYLMenuConfigurationErrorCode, CYLTagItemKey, CYLTagListKey, CYLTagSectionKey, cylAddingAnimationOptions
} from '../core/CYLTagListConfiguration';
import { CYLColor, CYLControlState, CYLEdgeInsets, CYLFont, CYLImage, CYLSize } from '../core/CYLTypes';

/** How taps select items. */
export enum CYLMenuSelectionMode {
  /** Items behave like buttons: taps are reported, nothing stays selected. */
  none = 0,
  /** At most one selected item per section. */
  single = 1,
  /** Any number of selected items; exclusive items clear the others. */
  multiple = 2
}

/** Where the list's title is: above every section, at the leading edge or centered. */
export enum CYLMenuTitlePosition {
  topLeading = 0,
  topCenter = 1
}

/** The older way of choosing a fold control; `foldControl` gives the position and content separately. */
export enum CYLMenuFoldStyle {
  /** Every row is always visible. */
  none = 0,
  /** A "更多/收起" button at the trailing edge of the section header. */
  headerButton = 1,
  /** A chevron below the section. */
  footerChevron = 2,
  /** Shows only `defaultVisibleRows` rows with no control; the host may still call `setExpanded`. */
  truncate = 3
}

// MARK: - Metrics (CYLTagButton, CYLTagFoldButton, CYLTagCreateCell)

/** The line height of the system font per point of size (as `CYLTagMetrics`). */
const LINE_HEIGHT_RATIO: number = 1.2;
const STATES: number[] = [CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED];
/** `UIFont.TextStyle.footnote` and `.headline` point sizes at the default content size. */
const FOOTNOTE_SIZE: number = 13;
const HEADLINE_SIZE: number = 17;
const FOLD_ICON_SIDE: number = 12;
const FOLD_CONTENT_MARGIN: number = 6;
const FOLD_MINIMUM_HEIGHT: number = 28;
const FOLD_MINIMUM_TOUCH_WIDTH: number = 44;
const FOLD_IMAGE_TITLE_SPACING: number = 3;
const CREATE_ICON_SIDE: number = 14;
const FOOTER_HEIGHT: number = 28;
const TITLE_VERTICAL_INSET: number = 10;
/** Seconds. */
const LONG_PRESS_DURATION: number = 0.5;
/** `UIColor.separator`, `.secondaryLabel`, `.tertiaryLabel`, `.label` in their light appearance. */
const SEPARATOR: string = CYLColor.argb(73, 60, 60, 67);
const SECONDARY_LABEL: string = CYLColor.argb(153, 60, 60, 67);
const TERTIARY_LABEL: string = CYLColor.argb(76, 60, 60, 67);
const LABEL: string = CYLColor.BLACK;

/** Measures a line of text in vp. */
export type CYLTextMeasurer = (text: string, font: CYLFont) => number;

function measureWithArkUI(text: string, font: CYLFont): number {
  if (text.length === 0) {
    return 0;
  }
  try {
    const px = Number(MeasureText.measureText({ textContent: text, fontSize: `${font.size}fp`, fontWeight: font.weight }));
    return px2vp(px);
  } catch (e) {
    // Without a UI context (a unit test): an estimate of half an em per character.
    return Array.from(text).length * font.size * 0.5;
  }
}

/** The measurements of a tag (`CYLTagButton`'s static methods). */
export class CYLTagButtonMetrics {
  /** Replaced in tests that run without a UI context. */
  static textMeasurer: CYLTextMeasurer = measureWithArkUI;

  static lineHeight(font: CYLFont): number {
    return font.size * LINE_HEIGHT_RATIO;
  }

  /** `width(forTitle:image:style:)`. */
  static widthWithImage(title: string | undefined, image: CYLImage | undefined, style: CYLMenuStyle,
    fontScale: number = 1): number {
    return CYLTagButtonMetrics.width(title, CYLTagButtonMetrics.imageIconSize(image, style), false, style, fontScale);
  }

  /** The width a tag needs in every state, before any limit on the available width. */
  static width(title: string | undefined, iconSize: CYLSize, showsDeleteIndicator: boolean, style: CYLMenuStyle,
    fontScale: number = 1): number {
    const displayed = style.displayedTitle(title);
    let width = 0;
    STATES.forEach((state: number) => {
      const appearance = style.appearance(state);
      const font = style.titleFont(state, fontScale);
      const titleWidth = displayed.length === 0 ? 0 : Math.ceil(CYLTagButtonMetrics.textMeasurer(displayed, font));
      let content = titleWidth + iconSize.width;
      if (titleWidth > 0 && iconSize.width > 0) {
        content += style.imageTitleSpacing;
      } else if (titleWidth > 0 && !style.layoutCentered && style.contentAlignment === CYLTagContentAlignment.center) {
        content += style.imageSize.width + style.imageTitleSpacing;
      }
      if (showsDeleteIndicator) {
        content += style.imageTitleSpacing + CYLTagButtonMetrics.deleteIndicatorWidth(state, style, fontScale);
      }
      width = Math.max(width, Math.ceil(content + appearance.contentInsets.left + appearance.contentInsets.right));
    });
    return width;
  }

  /** The icon slot of an image, or of an animated icon when `animated`. */
  static iconSize(image: CYLImage | undefined, animated: boolean, style: CYLMenuStyle): CYLSize {
    if (animated) {
      const size = style.animationSize;
      return size.width === 0 && size.height === 0 ? style.imageSize : size;
    }
    return CYLTagButtonMetrics.imageIconSize(image, style);
  }

  private static imageIconSize(image: CYLImage | undefined, style: CYLMenuStyle): CYLSize {
    if (image === undefined) {
      return CYLSize.ZERO;
    }
    const size = style.imageSize;
    if (size.width !== 0 || size.height !== 0) {
      return size;
    }
    // iOS uses the image's own size, which ArkUI knows only once the image has loaded: the icon then sizes itself.
    return CYLSize.ZERO;
  }

  /** `style.itemHeight`, or more when a line of the title font plus the content insets needs it. */
  static height(style: CYLMenuStyle, fontScale: number = 1): number {
    let height = style.itemHeight;
    STATES.forEach((state: number) => {
      const insets = style.appearance(state).contentInsets;
      const font = style.titleFont(state, fontScale);
      height = Math.max(height, Math.ceil(CYLTagButtonMetrics.lineHeight(font)) + insets.top + insets.bottom);
    });
    return height;
  }

  static deleteIndicatorWidth(state: number, style: CYLMenuStyle, fontScale: number = 1): number {
    if (style.deleteIndicatorWidth > 0) {
      return style.deleteIndicatorWidth;
    }
    const font = style.deleteIndicatorFontFor(state, fontScale);
    if (style.deleteIndicatorLineWidth > 0) {
      return Math.ceil(CYLTagButtonMetrics.lineHeight(font) * 0.75) + 2 * style.deleteIndicatorPadding;
    }
    return Math.ceil(CYLTagButtonMetrics.textMeasurer(style.deleteIndicatorTitle, font));
  }
}

/** The looks and sizes of the fold controls (`CYLTagFoldButton`). */
export class CYLTagFoldMetrics {
  /** A borderless tag: no background, the title then the icon, in `color`. */
  static style(control: CYLMenuFoldControl, color?: string): CYLMenuStyle {
    const style = new CYLMenuStyle();
    const font = control.font ?? CYLFont.systemFont(FOOTNOTE_SIZE);
    const tint = control.color ?? color ?? SECONDARY_LABEL;
    STATES.forEach((state: number) => {
      const appearance = style.appearance(state);
      appearance.backgroundColor = CYLColor.CLEAR;
      appearance.borderWidth = 0;
      appearance.borderColor = undefined;
      appearance.margin = FOLD_CONTENT_MARGIN;
      appearance.font = font;
      appearance.textColor = tint;
      style.setIconColor(tint, state);
    });
    style.imagePlacement = CYLTagImagePlacement.trailing;
    style.imageSize = new CYLSize(FOLD_ICON_SIDE, FOLD_ICON_SIDE);
    style.imageTitleSpacing = FOLD_IMAGE_TITLE_SPACING;
    style.layoutCentered = true;
    style.adjustsFontForContentSizeCategory = control.font === undefined;
    style.itemHeight = FOLD_MINIMUM_HEIGHT;
    return style;
  }

  /** The inline control: the tags' normal look in every state, the icon after the title. */
  static inlineStyle(control: CYLMenuFoldControl, itemStyle: CYLMenuStyle): CYLMenuStyle {
    const style = itemStyle.copy();
    const normal = itemStyle.normalAppearance;
    const tint = control.color ?? itemStyle.foldControlColor;
    [CYLControlState.SELECTED, CYLControlState.DISABLED].forEach((state: number) => {
      const appearance = style.appearance(state);
      appearance.backgroundColor = normal.backgroundColor;
      appearance.borderColor = normal.borderColor;
      appearance.borderWidth = normal.borderWidth;
      appearance.cornerRadius = normal.cornerRadius;
      appearance.margin = normal.margin;
      appearance.font = normal.font;
      appearance.textColor = normal.textColor;
    });
    STATES.forEach((state: number) => style.setIconColor(tint, state));
    const font = control.font;
    if (font !== undefined) {
      [style.normalAppearance, style.selectedAppearance, style.disabledAppearance].forEach(
        (appearance: CYLTagAppearance) => appearance.font = font);
    }
    style.imagePlacement = CYLTagImagePlacement.trailing;
    style.imageSize = new CYLSize(FOLD_ICON_SIDE + 4, FOLD_ICON_SIDE + 4);
    style.imageTitleSpacing = FOLD_IMAGE_TITLE_SPACING;
    style.layoutCentered = true;
    return style;
  }

  /** The size the control needs in that state (at least a 44 vp wide touch target). */
  static size(control: CYLMenuFoldControl, expanded: boolean, fontScale: number = 1): CYLSize {
    const borderless = CYLTagFoldMetrics.style(control);
    const icon = control.showsImage(expanded) ? control.image : undefined;
    const width = CYLTagButtonMetrics.widthWithImage(control.titleWhenExpanded(expanded), icon, borderless, fontScale);
    return new CYLSize(Math.max(FOLD_MINIMUM_TOUCH_WIDTH, Math.ceil(width)),
      Math.max(FOLD_MINIMUM_HEIGHT, CYLTagButtonMetrics.height(borderless, fontScale)));
  }

  /** The inline control's size: the tags' height, and at least as wide as it is high. */
  static inlineSize(control: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: boolean,
    fontScale: number = 1): CYLSize {
    const inline = CYLTagFoldMetrics.inlineStyle(control, itemStyle);
    const icon = control.showsImage(expanded) ? control.image : undefined;
    const side = CYLTagButtonMetrics.height(inline, fontScale);
    const width = CYLTagButtonMetrics.widthWithImage(control.titleWhenExpanded(expanded), icon, inline, fontScale);
    return new CYLSize(Math.max(side, Math.ceil(width)), side);
  }
}

/** "+ 新建标签" (`CYLTagCreateCell`). */
export class CYLTagCreateItem {
  static get plusImage(): CYLImage {
    return CYLMenuResources.image('cyl_tag_plus') as Resource;
  }

  /** "新建标签" for an empty name, "新建标签：<name>" otherwise. */
  static title(name?: string): string {
    if (name === undefined || name.length === 0) {
      return CYLMenuLocalizedString('CYLMenuNewTag');
    }
    return CYLMenuLocalizedString('CYLMenuNewTagNamed').replace('%@', name);
  }

  /** The outlined look of the item: the list's background, a hairline border and secondary text. */
  static outlinedStyle(style: CYLMenuStyle): CYLMenuStyle {
    const outlined = style.copy();
    const normal = outlined.normalAppearance;
    normal.backgroundColor = style.backgroundColor;
    normal.borderColor = SEPARATOR;
    normal.borderWidth = 1;
    normal.textColor = SECONDARY_LABEL;
    outlined.setIconColor(TERTIARY_LABEL, CYLControlState.NORMAL);
    normal.resetFont();
    outlined.imagePlacement = CYLTagImagePlacement.leading;
    if (outlined.imageSize.width === 0 && outlined.imageSize.height === 0) {
      outlined.imageSize = new CYLSize(CREATE_ICON_SIDE, CREATE_ICON_SIDE);
    }
    return outlined;
  }
}

// MARK: - Layout

/** Where an item (or the inline fold control) is, in the list's content (below the title). */
export class CYLTagListItemFrame {
  section: number = 0;
  item: number = 0;
  x: number = 0;
  y: number = 0;
  width: number = 0;
  height: number = 0;
  /** The inline fold control (`CYLMenuFoldControlPosition.tail`), after the visible items. */
  isFoldCell: boolean = false;
}

/** A section as laid out: its header, items and footer. */
export class CYLTagListSectionFrame {
  section: number = 0;
  /** The section's top, in the list's content (below the title). */
  y: number = 0;
  headerHeight: number = 0;
  footerHeight: number = 0;
  height: number = 0;
  foldable: boolean = false;
  expanded: boolean = false;
  items: CYLTagListItemFrame[] = [];
}

function key(section: number, item: number): string {
  return `${section}-${item}`;
}

function makePath(section: number, item: number): CYLIndexPath {
  const p: CYLIndexPath = { section: section, item: item };
  return p;
}

function comparePaths(a: CYLIndexPath, b: CYLIndexPath): number {
  return a.section !== b.section ? a.section - b.section : a.item - b.item;
}

class CYLStyleCacheEntry {
  base: CYLMenuStyle;
  style: CYLMenuStyle;

  constructor(base: CYLMenuStyle, style: CYLMenuStyle) {
    this.base = base;
    this.style = style;
  }
}

// MARK: - Tag list

export class CYLTagListState {
  /** The sections and items. */
  menuDataSource?: CYLMenuDataSource;
  /** Receives taps, selection changes, folding and size changes. */
  menuDelegate?: CYLMenuDelegate;
  /** When false, a tap never removes the last selected item of a section. */
  allowsEmptySelection: boolean = true;
  /** False ignores taps on tags (tag_clickable); long presses still work. */
  allowsTapping: boolean = true;
  /** The icon of every item without one of its own (setDefaultImageDrawableID). */
  defaultTagImage?: CYLImage;
  /** False makes a tap on a delete indicator only report it; the host removes the item. */
  removesItemsOnDelete: boolean = true;
  /** Every accepted tap on one of `tags`, after the menu delegate. */
  tagClickHandler?: (index: number, tag: CYLTag) => void;
  /** A tap on a tag's delete indicator removed it, after the menu delegate. */
  tagDeleteHandler?: (index: number, tag: CYLTag) => void;
  /** One of `tags` moved (after `menuDidMoveItem`). */
  tagMoveHandler?: (from: number, to: number) => void;
  /** A selected tag started moving, after `menuDidBeginDraggingSelectedItem`. */
  selectedTagDragHandler?: (index: number, tag: CYLTag) => void;
  /** The system font scale the tags are measured at (Dynamic Type). */
  fontScale: number = 1;

  private styleStorage: CYLMenuStyle = new CYLMenuStyle();
  private titleStyleStorage: CYLMenuStyle = CYLTagListState.defaultTitleStyle();
  private foldControlStorage: CYLMenuFoldControl = new CYLMenuFoldControl();
  private foldStyleStorage: CYLMenuFoldStyle = CYLMenuFoldStyle.none;
  private selectionModeStorage: CYLMenuSelectionMode = CYLMenuSelectionMode.single;
  private showsSectionHeadersStorage: boolean = true;
  private defaultVisibleRowsStorage: number = 1;
  private titleStorage?: string;
  private titleImageStorage?: CYLImage;
  private titlePositionStorage: CYLMenuTitlePosition = CYLMenuTitlePosition.topLeading;
  private scrollEnabledStorage: boolean = true;
  private contentHeightStorage: number = 0;
  private animationSpeedStorage?: number;
  private animationLoopsStorage: boolean = false;
  private containerBorderWidthStorage: number = 0;
  private containerBorderColorStorage?: string;
  private containerCornerRadiusStorage: number = 0;
  private colorThemeStorage: CYLTagColorTheme = CYLTagColorTheme.none;
  private tagLongPressHandlerStorage?: (index: number, tag: CYLTag) => void;
  private longPressActionNameStorage?: string;
  private allowsReorderingStorage: boolean = false;
  private reorderingSensitivityStorage: number = 1;
  private isReorderingStorage: boolean = false;

  private titles: string[][] = [];
  private itemWidths: number[][] = [];
  private itemHeights: number[][] = [];
  private rows: number[][] = [];
  private selection: Map<string, CYLIndexPath> = new Map<string, CYLIndexPath>();
  private expandedSections: Set<number> = new Set<number>();
  private layoutWidth: number = 0;
  private measuredWidth: number = -1;
  private viewportHeight: number = 0;
  private tagDataSourceStorage?: CYLTagDataSource;
  private configurationDataSourceStorage?: CYLMenuDataSource;
  private themeStyles: Map<string, CYLStyleCacheEntry> = new Map<string, CYLStyleCacheEntry>();
  private createItemStyle?: CYLStyleCacheEntry;
  private pressedIndexPath?: CYLIndexPath;
  private changeListener?: () => void;
  private scrollHandler?: (offset: number, animated: boolean) => void;
  private playTokenStorage: number = 0;
  private itemPlayCounts: Map<string, number> = new Map<string, number>();

  /**
   * `init(foldControl:)` and `init(foldControl:title:titleImage:titlePosition:)`: a tag list with its fold control
   * (undefined: none), title and title icon.
   */
  constructor(foldControl?: CYLMenuFoldControl, title?: string, titleImage?: CYLImage,
    titlePosition: CYLMenuTitlePosition = CYLMenuTitlePosition.topLeading) {
    if (foldControl !== undefined) {
      this.foldControl = foldControl;
    }
    this.titlePositionStorage = titlePosition;
    this.titleImageStorage = titleImage;
    this.titleStorage = title;
  }

  /** `init(foldPosition:content:)`: a tag list with a fold control at this position showing this content. */
  static withFoldPosition(position: CYLMenuFoldControlPosition, content: CYLMenuFoldControlContent): CYLTagListState {
    return new CYLTagListState(new CYLMenuFoldControl(position, content));
  }

  // MARK: View plumbing

  /** Called by the view that renders the list: `listener` runs whenever it must render again. */
  attach(listener: () => void, scrollHandler?: (offset: number, animated: boolean) => void): void {
    this.changeListener = listener;
    this.scrollHandler = scrollHandler;
  }

  detach(): void {
    this.changeListener = undefined;
    this.scrollHandler = undefined;
  }

  /** The view's width; a new width lays the tags out again. */
  setLayoutWidth(width: number): void {
    if (width === this.layoutWidth) {
      return;
    }
    this.layoutWidth = width;
    this.reloadLayout();
  }

  get width(): number {
    return this.layoutWidth;
  }

  /** The height of the area the list scrolls in. */
  setViewportHeight(height: number): void {
    this.viewportHeight = height;
  }

  /** Changes each time `playAllAnimations()` is called. */
  get playToken(): number {
    return this.playTokenStorage;
  }

  /** Changes each time the item's animated icon must play from its start (a tap, `playAllAnimations()`). */
  playTokenForItem(indexPath: CYLIndexPath): number {
    return this.playTokenStorage + (this.itemPlayCounts.get(key(indexPath.section, indexPath.item)) ?? 0);
  }

  private setNeedsDisplay(): void {
    this.changeListener?.();
  }

  // MARK: Appearance

  /** Appearance. Setting copies the style; set it again after changing it. */
  get style(): CYLMenuStyle {
    return this.styleStorage;
  }

  set style(value: CYLMenuStyle) {
    this.styleStorage = value.copy();
    if (this.tagDataSourceStorage !== undefined) {
      this.tagDataSourceStorage.baseStyle = this.styleStorage;
    }
    this.themeStyles.clear();
    this.invalidateMeasurements();
  }

  /** How taps select items; `.single` by default. */
  get selectionMode(): CYLMenuSelectionMode {
    return this.selectionModeStorage;
  }

  set selectionMode(value: CYLMenuSelectionMode) {
    this.selectionModeStorage = value;
    if (value === CYLMenuSelectionMode.none) {
      this.selection.clear();
    } else if (value === CYLMenuSelectionMode.single) {
      const seen = new Set<number>();
      this.selectedIndexPaths.forEach((p: CYLIndexPath) => {
        if (seen.has(p.section)) {
          this.selection.delete(key(p.section, p.item));
        }
        seen.add(p.section);
      });
    }
    this.setNeedsDisplay();
  }

  /** True by default. When false, sections are laid out back to back without titles. */
  get showsSectionHeaders(): boolean {
    return this.showsSectionHeadersStorage;
  }

  set showsSectionHeaders(value: boolean) {
    this.showsSectionHeadersStorage = value;
    this.reloadLayout();
  }

  /**
   * The fold control of a foldable section. Setting copies it and also sets `foldStyle` (footer: `.footerChevron`,
   * header: `.headerButton`, none: `.none`, or `.truncate` when `foldStyle` was `.truncate`).
   */
  get foldControl(): CYLMenuFoldControl {
    return this.foldControlStorage;
  }

  set foldControl(value: CYLMenuFoldControl) {
    this.foldControlStorage = value.copy();
    switch (this.foldControlStorage.position) {
      case CYLMenuFoldControlPosition.footer:
        this.foldStyleStorage = CYLMenuFoldStyle.footerChevron;
        break;
      case CYLMenuFoldControlPosition.headerTrailing:
      case CYLMenuFoldControlPosition.headerLeading:
        this.foldStyleStorage = CYLMenuFoldStyle.headerButton;
        break;
      case CYLMenuFoldControlPosition.none:
        if (this.foldStyleStorage !== CYLMenuFoldStyle.truncate) {
          this.foldStyleStorage = CYLMenuFoldStyle.none;
        }
        break;
      default:
        this.foldStyleStorage = CYLMenuFoldStyle.none;
        break;
    }
    this.reloadLayout();
  }

  /** `.none` by default. Setting it also sets `foldControl`. */
  get foldStyle(): CYLMenuFoldStyle {
    return this.foldStyleStorage;
  }

  set foldStyle(value: CYLMenuFoldStyle) {
    this.foldStyleStorage = value;
    if (value === CYLMenuFoldStyle.headerButton) {
      this.foldControlStorage = new CYLMenuFoldControl(CYLMenuFoldControlPosition.headerTrailing,
        CYLMenuFoldControlContent.title);
    } else if (value === CYLMenuFoldStyle.footerChevron) {
      this.foldControlStorage = new CYLMenuFoldControl(CYLMenuFoldControlPosition.footer,
        CYLMenuFoldControlContent.icon);
    } else {
      this.foldControlStorage = new CYLMenuFoldControl();
    }
    this.reloadLayout();
  }

  /** Rows shown while a foldable section is collapsed. 0 shows every row. 1 by default. */
  get defaultVisibleRows(): number {
    return this.defaultVisibleRowsStorage;
  }

  set defaultVisibleRows(value: number) {
    this.defaultVisibleRowsStorage = Math.max(0, Math.trunc(value));
    this.reloadLayout();
  }

  // MARK: Title

  /** A title above every section (undefined, the default, for none). */
  get title(): string | undefined {
    return this.titleStorage;
  }

  set title(value: string | undefined) {
    this.titleStorage = value;
    this.titleDidChange();
  }

  /** The title's icon; undefined for none. */
  get titleImage(): CYLImage | undefined {
    return this.titleImageStorage;
  }

  set titleImage(value: CYLImage | undefined) {
    this.titleImageStorage = value;
    this.titleDidChange();
  }

  get titlePosition(): CYLMenuTitlePosition {
    return this.titlePositionStorage;
  }

  set titlePosition(value: CYLMenuTitlePosition) {
    this.titlePositionStorage = value;
    this.setNeedsDisplay();
  }

  /** The title's look; default `defaultTitleStyle()`. Setting copies the style. */
  get titleStyle(): CYLMenuStyle {
    return this.titleStyleStorage;
  }

  set titleStyle(value: CYLMenuStyle) {
    this.titleStyleStorage = value.copy();
    this.titleDidChange();
  }

  /** The default title look: the headline font in the label color, an 18 vp icon, no background or border. */
  static defaultTitleStyle(): CYLMenuStyle {
    const style = new CYLMenuStyle();
    const font = new CYLFont(HEADLINE_SIZE, FontWeight.Bold);
    STATES.forEach((state: number) => {
      const appearance = style.appearance(state);
      appearance.backgroundColor = CYLColor.CLEAR;
      appearance.borderWidth = 0;
      appearance.borderColor = undefined;
      appearance.margin = 0;
      appearance.font = font;
      appearance.textColor = LABEL;
      style.setIconColor(LABEL, state);
    });
    style.imageSize = new CYLSize(18, 18);
    style.imageTitleSpacing = 6;
    style.layoutCentered = true;
    style.adjustsFontForContentSizeCategory = true;
    style.itemHeight = 24;
    return style;
  }

  get hasTitle(): boolean {
    return (this.titleStorage ?? '').length > 0 || this.titleImageStorage !== undefined;
  }

  private titleDidChange(): void {
    this.updateContentHeight();
    this.setNeedsDisplay();
  }

  /** The height of the title area, 0 without a title or an icon. */
  titleHeight(): number {
    if (!this.hasTitle) {
      return 0;
    }
    return Math.ceil(CYLTagButtonMetrics.height(this.titleStyleStorage, this.fontScale)) + 2 * TITLE_VERTICAL_INSET;
  }

  /** The title's frame: as wide as its content (no wider than the list), at the leading edge or centered. */
  titleFrame(): CYLTagListItemFrame {
    const frame = new CYLTagListItemFrame();
    const height = this.titleHeight();
    if (height <= 0) {
      return frame;
    }
    const width = this.layoutWidth;
    const inset = this.styleStorage.sectionInsets.left;
    const available = Math.max(0, width - 2 * inset);
    frame.width = Math.min(available, Math.ceil(CYLTagButtonMetrics.widthWithImage(this.titleStorage,
      this.titleImageStorage, this.titleStyleStorage, this.fontScale)));
    frame.x = this.titlePositionStorage === CYLMenuTitlePosition.topCenter ? Math.floor((width - frame.width) / 2) :
      inset;
    frame.y = TITLE_VERTICAL_INSET;
    frame.height = height - 2 * TITLE_VERTICAL_INSET;
    return frame;
  }

  // MARK: Size

  /** False to embed the list in another scroll view and size it with `contentHeight`. True by default. */
  get isScrollEnabled(): boolean {
    return this.scrollEnabledStorage;
  }

  set isScrollEnabled(value: boolean) {
    this.scrollEnabledStorage = value;
    this.setNeedsDisplay();
  }

  /** The height the current content needs at the current width (also reported by `menuDidChangeContentHeight`). */
  get contentHeight(): number {
    return this.contentHeightStorage;
  }

  // MARK: Spacing

  /** The space between rows (`style.lineSpacing`). */
  get lineSpacing(): number {
    return this.styleStorage.lineSpacing;
  }

  set lineSpacing(value: number) {
    const copy = this.styleStorage.copy();
    copy.lineSpacing = value;
    this.style = copy;
  }

  /** The space between tags in a row (`style.interitemSpacing`). */
  get interitemSpacing(): number {
    return this.styleStorage.interitemSpacing;
  }

  set interitemSpacing(value: number) {
    const copy = this.styleStorage.copy();
    copy.interitemSpacing = value;
    this.style = copy;
  }

  /** The space inside every tag (`style.tagContentInsets`). */
  get tagContentInsets(): CYLEdgeInsets {
    return this.styleStorage.tagContentInsets;
  }

  set tagContentInsets(value: CYLEdgeInsets) {
    const copy = this.styleStorage.copy();
    copy.tagContentInsets = value;
    this.style = copy;
  }

  get tagContentInsetTop(): number {
    return this.tagContentInsets.top;
  }

  set tagContentInsetTop(value: number) {
    const i = this.tagContentInsets;
    this.tagContentInsets = new CYLEdgeInsets(value, i.left, i.bottom, i.right);
  }

  get tagContentInsetLeft(): number {
    return this.tagContentInsets.left;
  }

  set tagContentInsetLeft(value: number) {
    const i = this.tagContentInsets;
    this.tagContentInsets = new CYLEdgeInsets(i.top, value, i.bottom, i.right);
  }

  get tagContentInsetBottom(): number {
    return this.tagContentInsets.bottom;
  }

  set tagContentInsetBottom(value: number) {
    const i = this.tagContentInsets;
    this.tagContentInsets = new CYLEdgeInsets(i.top, i.left, value, i.right);
  }

  get tagContentInsetRight(): number {
    return this.tagContentInsets.right;
  }

  set tagContentInsetRight(value: number) {
    const i = this.tagContentInsets;
    this.tagContentInsets = new CYLEdgeInsets(i.top, i.left, i.bottom, value);
  }

  // MARK: Animated icons

  /** The playback speed of every animated icon; undefined (the default) uses each item's `style.animationSpeed`. */
  get animationSpeed(): number | undefined {
    return this.animationSpeedStorage;
  }

  set animationSpeed(value: number | undefined) {
    this.animationSpeedStorage = value;
    this.setNeedsDisplay();
  }

  /** True repeats the animated icons after they start playing; false (the default) plays them once. */
  get animationLoops(): boolean {
    return this.animationLoopsStorage;
  }

  set animationLoops(value: boolean) {
    this.animationLoopsStorage = value;
    this.setNeedsDisplay();
  }

  /** Plays the animated icon of every tag on screen from its start. */
  playAllAnimations(): void {
    this.playTokenStorage += 1;
    this.setNeedsDisplay();
  }

  /** The speed an item's animated icon plays at. */
  animationSpeedForItem(indexPath: CYLIndexPath): number {
    return this.animationSpeedStorage ?? this.styleForItem(indexPath).animationSpeed;
  }

  // MARK: Container

  /** The list's own border width (container_border_width); 0 by default. */
  get containerBorderWidth(): number {
    return this.containerBorderWidthStorage;
  }

  set containerBorderWidth(value: number) {
    this.containerBorderWidthStorage = Math.max(0, value);
    this.setNeedsDisplay();
  }

  get containerBorderColor(): string | undefined {
    return this.containerBorderColorStorage;
  }

  set containerBorderColor(value: string | undefined) {
    this.containerBorderColorStorage = value;
    this.setNeedsDisplay();
  }

  get containerCornerRadius(): number {
    return this.containerCornerRadiusStorage;
  }

  set containerCornerRadius(value: number) {
    this.containerCornerRadiusStorage = Math.max(0, value);
    this.setNeedsDisplay();
  }

  /** At most this many rows of each section (container_max_lines); 0 shows every row. Sets `.truncate`. */
  get maximumNumberOfRows(): number {
    return this.foldStyleStorage === CYLMenuFoldStyle.truncate ? this.defaultVisibleRowsStorage : 0;
  }

  set maximumNumberOfRows(value: number) {
    if (value > 0) {
      this.foldStyle = CYLMenuFoldStyle.truncate;
      this.defaultVisibleRows = value;
    } else if (this.foldStyleStorage === CYLMenuFoldStyle.truncate) {
      this.foldStyle = CYLMenuFoldStyle.none;
    }
  }

  /** Colors every item without a look of its own from a theme (tag_theme); `.none` by default. */
  get colorTheme(): CYLTagColorTheme {
    return this.colorThemeStorage;
  }

  set colorTheme(value: CYLTagColorTheme) {
    this.colorThemeStorage = value;
    this.themeStyles.clear();
    this.invalidateMeasurements();
  }

  // MARK: Long press and reordering

  /** A long press on an item without moving it: `menuDidLongPressItem`, then this (onTagLongClick). */
  get tagLongPressHandler(): ((index: number, tag: CYLTag) => void) | undefined {
    return this.tagLongPressHandlerStorage;
  }

  set tagLongPressHandler(value: ((index: number, tag: CYLTag) => void) | undefined) {
    this.tagLongPressHandlerStorage = value;
    this.setNeedsDisplay();
  }

  /** The name of the long-press action for assistive technologies; undefined: "长按" (`CYLMenuLongPress`). */
  get longPressAccessibilityActionName(): string | undefined {
    return this.longPressActionNameStorage;
  }

  set longPressAccessibilityActionName(value: string | undefined) {
    this.longPressActionNameStorage = value;
    this.setNeedsDisplay();
  }

  /** A long press and a move reorders the items of a section; needs a data source with `menuMoveItem`. */
  get allowsReordering(): boolean {
    return this.allowsReorderingStorage;
  }

  set allowsReordering(value: boolean) {
    this.allowsReorderingStorage = value;
    this.setNeedsDisplay();
  }

  /** How quickly a press starts reordering: the press lasts 0.5 s divided by it; not positive is 1. */
  get reorderingSensitivity(): number {
    return this.reorderingSensitivityStorage;
  }

  set reorderingSensitivity(value: number) {
    this.reorderingSensitivityStorage = value <= 0 ? 1 : value;
    this.setNeedsDisplay();
  }

  /** Whether an item is being moved (getTagViewState). */
  get isReordering(): boolean {
    return this.isReorderingStorage;
  }

  /** The long press duration in milliseconds. */
  get longPressDuration(): number {
    const seconds = this.allowsReorderingStorage ? LONG_PRESS_DURATION / this.reorderingSensitivityStorage :
      LONG_PRESS_DURATION;
    return Math.round(seconds * 1000);
  }

  // MARK: Data

  /** Reads everything from the data source again; selections and expanded sections still in range are kept. */
  reloadMenuData(): void {
    const source = this.menuDataSource;
    if (this.tagDataSourceStorage !== undefined && source === this.tagDataSourceStorage) {
      this.tagDataSourceStorage.invalidateStyles();
    }
    const sections = source !== undefined ? Math.max(0, source.numberOfSectionsInMenu()) : 0;
    const titles: string[][] = [];
    for (let section = 0; section < sections; section++) {
      const count = source !== undefined ? Math.max(0, source.menuNumberOfItemsInSection(section)) : 0;
      const items: string[] = [];
      for (let item = 0; item < count; item++) {
        const p = makePath(section, item);
        const title = source !== undefined ? source.menuTitleForItem(p) : '';
        items.push(this.itemType(p) === CYLMenuItemType.create ? CYLTagCreateItem.title(title) : title);
      }
      titles.push(items);
    }
    this.titles = titles;
    const kept = new Map<string, CYLIndexPath>();
    this.selection.forEach((p: CYLIndexPath, k: string) => {
      if (this.isValid(p)) {
        kept.set(k, p);
      }
    });
    this.selection = kept;
    const expanded = new Set<number>();
    this.expandedSections.forEach((s: number) => {
      if (s < sections) {
        expanded.add(s);
      }
    });
    this.expandedSections = expanded;
    this.themeStyles.clear();
    this.invalidateMeasurements();
  }

  /** The height the content needs at `width` with the current data and fold state. */
  heightThatFitsWidth(width: number): number {
    const available = this.contentWidth(width);
    const measured = width === this.measuredWidth;
    const sectionWidths = measured ? this.itemWidths : this.widths(available);
    const sectionRows = measured ? this.rows : this.rowsFor(sectionWidths, available);
    const sectionHeights = measured ? this.itemHeights : this.measureItemHeights();
    const header = this.headerHeight();
    const insets = this.styleStorage.sectionInsets;
    let height = 0;
    for (let section = 0; section < sectionRows.length; section++) {
      let rowCount = sectionRows[section].length;
      const foldable = this.canFold(rowCount);
      if (foldable && !this.expandedSections.has(section)) {
        rowCount = this.defaultVisibleRowsStorage;
      } else if (foldable && this.foldControlIsInline) {
        const withFold = sectionWidths[section].concat([this.inlineFoldSize(section, true).width]);
        const r = this.rowsFor([withFold], available);
        rowCount = r.length > 0 ? r[0].length : 0;
      }
      height += header + insets.top + insets.bottom;
      height += this.heightOfRows(rowCount, sectionRows[section],
        section < sectionHeights.length ? sectionHeights[section] : []);
      if (foldable && this.foldControlIsInFooter) {
        height += this.footerHeight;
      }
    }
    return Math.ceil(height) + this.titleHeight();
  }

  // MARK: Tags

  /** The list's own tags; the first tag method makes it the data source, hides headers and sets `.none`. */
  get tagDataSource(): CYLTagDataSource {
    if (this.tagDataSourceStorage !== undefined) {
      return this.tagDataSourceStorage;
    }
    const source = new CYLTagDataSource();
    source.baseStyle = this.styleStorage;
    this.tagDataSourceStorage = source;
    return source;
  }

  /** The tags of `tagDataSource`, in order (getTags()). */
  get tags(): CYLTag[] {
    return this.tagDataSourceStorage?.tags ?? [];
  }

  addTag(tag: CYLTag): void {
    this.showTags().addTag(tag);
    this.reloadMenuData();
  }

  addTags(tags: CYLTag[]): void {
    this.showTags().addTags(tags);
    this.reloadMenuData();
  }

  addTagsWithTitles(titles: string[]): void {
    this.addTags(titles.map((title: string) => new CYLTag(0, title)));
  }

  addTagWithTitle(title: string): void {
    this.addTag(new CYLTag(0, title));
  }

  /** Inserts a tag; selections at or after it move down. An index past the end adds it at the end. */
  insertTag(tag: CYLTag, index: number): void {
    const source = this.showTags();
    const position = Math.min(Math.max(0, index), source.tags.length);
    source.insertTag(tag, position);
    this.shiftSelection(0, position, 1);
    this.reloadMenuData();
  }

  insertTagWithTitle(title: string, index: number): void {
    this.insertTag(new CYLTag(0, title), index);
  }

  /** Removes a tag; selections after it move up. Out-of-range indexes are ignored. */
  removeTag(index: number): void {
    const source = this.showTags();
    if (index < 0 || index >= source.tags.length) {
      return;
    }
    source.removeTag(index);
    this.removeSelection(makePath(0, index));
    this.reloadMenuData();
  }

  /** Removes several tags (removeConsecutiveTags). */
  removeTags(indexes: number[]): void {
    const source = this.showTags();
    const sorted = Array.from(new Set<number>(indexes)).sort((a: number, b: number) => b - a);
    sorted.forEach((index: number) => {
      if (index >= 0 && index < source.tags.length) {
        source.removeTag(index);
        this.removeSelection(makePath(0, index));
      }
    });
    this.reloadMenuData();
  }

  removeAllTags(): void {
    this.showTags().removeAllTags();
    this.selection.clear();
    this.reloadMenuData();
  }

  /** Replaces the tags (setTags). */
  replaceTags(tags: CYLTag[]): void {
    this.showTags().tags = tags;
    this.selection.clear();
    this.reloadMenuData();
  }

  /** Replaces the tags with tags of these titles, and colors per tag, in order. */
  setTagsWithTitles(titles: string[], colors: CYLTagColors[] = []): void {
    this.replaceTags(titles.map((title: string, index: number): CYLTag => {
      const tag = new CYLTag(0, title);
      if (index < colors.length) {
        tag.colors = colors[index];
      }
      return tag;
    }));
  }

  /** Deletes a deletable, enabled item as a tap on its delete indicator does. */
  deleteItem(indexPath: CYLIndexPath): void {
    if (!this.isValid(indexPath) || !this.isDeletable(indexPath) || !this.isEnabled(indexPath)) {
      return;
    }
    const deletedTag = this.tagAt(indexPath);
    const source = this.menuDataSource;
    if (this.removesItemsOnDelete && source !== undefined && source.menuRemoveItem !== undefined) {
      source.menuRemoveItem(indexPath);
      this.removeSelection(indexPath);
      this.reloadMenuData();
    }
    this.menuDelegate?.menuDidDeleteItem?.(this, indexPath);
    if (deletedTag !== undefined) {
      this.tagDeleteHandler?.(indexPath.item, deletedTag);
    }
  }

  // MARK: Selection

  /** Selected items in ascending order. Setting applies the selection rules; an item outside the menu throws. */
  get selectedIndexPaths(): CYLIndexPath[] {
    return Array.from(this.selection.values()).sort(comparePaths);
  }

  set selectedIndexPaths(value: CYLIndexPath[]) {
    this.selection.clear();
    if (this.selectionModeStorage !== CYLMenuSelectionMode.none) {
      for (const p of value) {
        if (!this.isValid(p)) {
          this.setNeedsDisplay();
          throw new RangeError(`Invalid menu selection: [${p.section}, ${p.item}]`);
        }
        if (this.isSelectable(p)) {
          this.applySelection(p);
        }
      }
    }
    this.setNeedsDisplay();
  }

  /** The titles of the selected items, in order (getSelectedTagViewText). */
  get selectedTitles(): string[] {
    return this.selectedIndexPaths.map((p: CYLIndexPath) => this.menuDataSource?.menuTitleForItem(p) ?? '');
  }

  isSelected(indexPath: CYLIndexPath): boolean {
    return this.selection.has(key(indexPath.section, indexPath.item));
  }

  /** Applies the selection rules without calling the delegate. */
  selectItem(indexPath: CYLIndexPath): void {
    if (this.selectionModeStorage === CYLMenuSelectionMode.none || !this.isValid(indexPath) ||
      !this.isSelectable(indexPath)) {
      return;
    }
    this.applySelection(indexPath);
    this.setNeedsDisplay();
  }

  deselectItem(indexPath: CYLIndexPath): void {
    this.selection.delete(key(indexPath.section, indexPath.item));
    this.setNeedsDisplay();
  }

  deselectAllItems(): void {
    this.selection.clear();
    this.setNeedsDisplay();
  }

  /** Selects or deselects an item; in `.none` mode it still selects (any number of items). */
  toggleSelection(indexPath: CYLIndexPath): void {
    if (this.isSelected(indexPath)) {
      this.deselectItem(indexPath);
    } else if (this.selectionModeStorage === CYLMenuSelectionMode.none) {
      if (this.isValid(indexPath) && this.isSelectable(indexPath)) {
        this.applySelection(indexPath);
        this.setNeedsDisplay();
      }
    } else {
      this.selectItem(indexPath);
    }
  }

  // MARK: Folding

  isSectionExpanded(section: number): boolean {
    return section >= 0 && this.expandedSections.has(section);
  }

  /** Expands or collapses a section and calls `menuDidChangeExpanded`. */
  setExpanded(expanded: boolean, section: number, animated: boolean = false): void {
    if (section < 0 || section >= this.titles.length || expanded === this.isSectionExpanded(section)) {
      return;
    }
    if (expanded) {
      this.expandedSections.add(section);
    } else {
      this.expandedSections.delete(section);
    }
    this.updateContentHeight();
    this.setNeedsDisplay();
    this.menuDelegate?.menuDidChangeExpanded?.(this, expanded, section);
  }

  /** The fold control's action. */
  toggleSection(section: number): void {
    this.setExpanded(!this.isSectionExpanded(section), section, true);
  }

  /** Whether the section has more rows than `defaultVisibleRows` and can fold. */
  canFoldSection(section: number): boolean {
    this.measureIfNeeded();
    return section >= 0 && section < this.rows.length && this.canFold(this.rows[section].length);
  }

  /** Number of rows the section's items occupy at the current width. */
  numberOfRows(section: number): number {
    this.measureIfNeeded();
    return section >= 0 && section < this.rows.length ? this.rows[section].length : 0;
  }

  /** Number of items currently shown in the section (fewer while collapsed). */
  numberOfVisibleItems(section: number): number {
    this.measureIfNeeded();
    if (section < 0 || section >= this.titles.length) {
      return 0;
    }
    const total = this.titles[section].length;
    if (section >= this.rows.length || !this.canFoldSection(section) || this.isSectionExpanded(section)) {
      return total;
    }
    let visible = 0;
    let lastRowCount = 0;
    this.rows[section].slice(0, this.defaultVisibleRowsStorage).forEach((count: number) => {
      lastRowCount = count;
      visible += count;
    });
    visible = Math.min(visible, total);
    if (this.foldControlIsInline && lastRowCount > 0 && section < this.itemWidths.length) {
      const widths = this.itemWidths[section];
      const spacing = this.styleStorage.interitemSpacing;
      const available = this.contentWidth(this.measuredWidth);
      const foldWidth = this.inlineFoldSize(section, false).width;
      let used = 0;
      for (let item = visible - lastRowCount; item < visible; item++) {
        used += (item > visible - lastRowCount ? spacing : 0) + widths[item];
      }
      while (lastRowCount > 1 && used + spacing + foldWidth > available) {
        used -= widths[visible - 1] + spacing;
        lastRowCount -= 1;
        visible -= 1;
      }
    }
    return visible;
  }

  /** Whether a section shows the inline fold control. */
  showsInlineFoldCell(section: number): boolean {
    return this.foldControlIsInline && this.canFoldSection(section);
  }

  /** Whether the section's header shows the fold control. */
  showsHeaderFoldControl(section: number): boolean {
    return this.foldControlIsInHeader && this.canFoldSection(section);
  }

  /** Whether the section's footer shows the fold control. */
  showsFooterFoldControl(section: number): boolean {
    return this.foldControlIsInFooter && this.canFoldSection(section);
  }

  /** "<section title> <expand or collapse title>", so a fold control says which section it changes. */
  foldAccessibilityLabel(section: number): string {
    const titled = this.foldControlStorage.position !== CYLMenuFoldControlPosition.none;
    let action: string;
    if (this.isSectionExpanded(section)) {
      action = titled ? this.foldControlStorage.collapseTitle : this.styleStorage.collapseTitle;
    } else {
      action = titled ? this.foldControlStorage.title : this.styleStorage.expandTitle;
    }
    const title = this.menuDataSource?.menuTitleForSection(section) ?? '';
    return title.length === 0 ? action : `${title} ${action}`;
  }

  /** The fold control as shown: `CYLMenuStyle.foldChevronImage` replaces the default chevron. */
  get displayedFoldControl(): CYLMenuFoldControl {
    const chevron = this.styleStorage.foldChevronImage;
    if (chevron === undefined || !this.foldControlStorage.usesDefaultImage) {
      return this.foldControlStorage;
    }
    const control = this.foldControlStorage.copy();
    control.image = chevron;
    return control;
  }

  // MARK: Scrolling

  /** Scrolls so that the section (its header, or its first row) is at the top, as far as the content allows. */
  scrollToSection(section: number, animated: boolean = true): void {
    const frames = this.layoutSections();
    if (section < 0 || section >= frames.length) {
      return;
    }
    const frame = frames[section];
    let top: number;
    if (frame.headerHeight > 0) {
      top = frame.y;
    } else if (frame.items.length > 0) {
      top = frame.items[0].y - this.styleStorage.sectionInsets.top;
    } else {
      return;
    }
    this.requestScroll(top + this.titleHeight(), animated);
  }

  /** Scrolls so that the item is centered vertically, as far as the content allows. */
  scrollToItem(indexPath: CYLIndexPath, animated: boolean = true): void {
    if (!this.isValid(indexPath) || indexPath.item >= this.numberOfVisibleItems(indexPath.section)) {
      return;
    }
    const frames = this.layoutSections();
    const item = frames[indexPath.section].items.find((f: CYLTagListItemFrame) =>
    !f.isFoldCell && f.item === indexPath.item);
    if (item === undefined) {
      return;
    }
    this.requestScroll(item.y + item.height / 2 - this.viewportHeight / 2 + this.titleHeight(), animated);
  }

  private requestScroll(offset: number, animated: boolean): void {
    const maxOffset = Math.max(0, this.contentHeightStorage - this.viewportHeight);
    this.scrollHandler?.(Math.min(Math.max(offset, 0), maxOffset), animated);
  }

  // MARK: Taps, long presses and moves (the collection view delegate's work)

  /** A tap on an item (`collectionView(_:didSelectItemAt:)`): the inline fold control folds, a tag is handled. */
  tapItem(indexPath: CYLIndexPath): void {
    if (this.isInlineFoldCell(indexPath)) {
      this.toggleSection(indexPath.section);
      return;
    }
    if (this.allowsTapping) {
      this.handleTap(indexPath);
    }
  }

  /** The section header's More button. */
  tapMoreButton(section: number): void {
    this.menuDelegate?.menuDidTapMoreButtonInSection?.(this, section);
  }

  /** Whether an item highlights when pressed. */
  shouldHighlightItem(indexPath: CYLIndexPath): boolean {
    return this.allowsTapping || this.isInlineFoldCell(indexPath);
  }

  private handleTap(indexPath: CYLIndexPath): void {
    if (!this.isEnabled(indexPath)) {
      return;
    }
    const delegate = this.menuDelegate;
    if (delegate?.menuShouldSelectItem !== undefined && !delegate.menuShouldSelectItem(this, indexPath)) {
      return;
    }
    if (this.itemType(indexPath) === CYLMenuItemType.create && delegate?.menuDidRequestNewItemWithName !== undefined) {
      const name = this.menuDataSource?.menuTitleForItem(indexPath) ?? '';
      delegate.menuDidRequestNewItemWithName(this, name, indexPath);
      return;
    }
    let removed: CYLIndexPath[] = [];
    let selected = false;
    const selectable = this.isSelectable(indexPath);
    const mode = selectable ? this.selectionModeStorage : CYLMenuSelectionMode.none;
    if (mode === CYLMenuSelectionMode.none) {
      selected = true;
    } else if (this.isSelected(indexPath)) {
      if (this.allowsEmptySelection || this.selectedCount(indexPath.section) > 1) {
        this.selection.delete(key(indexPath.section, indexPath.item));
        removed.push(indexPath);
      }
    } else {
      removed = this.applySelection(indexPath);
      selected = true;
    }
    if (selected) {
      // A tapped tag plays its animated icon, as a tapped tab does.
      const k = key(indexPath.section, indexPath.item);
      this.itemPlayCounts.set(k, (this.itemPlayCounts.get(k) ?? 0) + 1);
    }
    this.setNeedsDisplay();
    removed.forEach((p: CYLIndexPath) => delegate?.menuDidDeselectItem?.(this, p));
    if (selected) {
      delegate?.menuDidSelectItem?.(this, indexPath);
    }
    if (removed.length > 0 || (selected && selectable && this.selectionModeStorage !== CYLMenuSelectionMode.none)) {
      delegate?.menuDidChangeSelectedItems?.(this, this.selectedIndexPaths);
    }
    const tag = this.tagAt(indexPath);
    if (tag !== undefined) {
      this.tagClickHandler?.(indexPath.item, tag);
    }
  }

  /** Whether items can be reordered: `allowsReordering` and a data source that moves items. */
  get canReorder(): boolean {
    return this.allowsReorderingStorage && this.menuDataSource !== undefined &&
    CYLMenuDefaults.supportsMovingItems(this.menuDataSource);
  }

  canMoveItem(indexPath: CYLIndexPath): boolean {
    return this.canReorder && this.isValid(indexPath) && !this.isInlineFoldCell(indexPath);
  }

  /**
   * A long press began on an item: it starts reordering (reporting a selected item's drag) when the list can
   * reorder, else it is reported as a long press. Returns whether reordering started.
   */
  beginLongPress(indexPath: CYLIndexPath): boolean {
    if (!this.isValid(indexPath) || this.isInlineFoldCell(indexPath)) {
      this.pressedIndexPath = undefined;
      return false;
    }
    this.pressedIndexPath = indexPath;
    if (this.canReorder) {
      this.isReorderingStorage = true;
      if (this.isSelected(indexPath)) {
        this.reportSelectedDrag(indexPath);
      }
      this.setNeedsDisplay();
      return true;
    }
    this.reportLongPress(indexPath);
    this.pressedIndexPath = undefined;
    return false;
  }

  /** The press ended: moved onto `destination`, or a press that did not move (reported as a long press). */
  endLongPress(destination: CYLIndexPath | undefined, moved: boolean): void {
    const pressed = this.pressedIndexPath;
    this.pressedIndexPath = undefined;
    if (!this.isReorderingStorage) {
      return;
    }
    this.isReorderingStorage = false;
    if (pressed !== undefined && moved && destination !== undefined) {
      this.moveItem(pressed, this.targetIndexPathForMove(pressed, destination));
    } else if (pressed !== undefined && !moved) {
      this.reportLongPress(pressed);
    }
    this.setNeedsDisplay();
  }

  cancelLongPress(): void {
    this.pressedIndexPath = undefined;
    if (this.isReorderingStorage) {
      this.isReorderingStorage = false;
      this.setNeedsDisplay();
    }
  }

  /** Where a moved item may go: within its section, among the shown items (not onto the inline fold control). */
  targetIndexPathForMove(original: CYLIndexPath, proposed: CYLIndexPath): CYLIndexPath {
    const last = Math.max(0, this.numberOfVisibleItems(original.section) - 1);
    let item: number;
    if (proposed.section === original.section) {
      item = Math.min(proposed.item, last);
    } else {
      item = proposed.section < original.section ? 0 : last;
    }
    return makePath(original.section, item);
  }

  /** `collectionView(_:moveItemAt:to:)`: the data source moves the item; the selection moves with it. */
  moveItem(source: CYLIndexPath, destination: CYLIndexPath): void {
    if ((source.section === destination.section && source.item === destination.item) || !this.canReorder) {
      return;
    }
    this.menuDataSource?.menuMoveItem?.(source, destination);
    const from = source.item;
    const to = destination.item;
    const moved = new Map<string, CYLIndexPath>();
    this.selection.forEach((p: CYLIndexPath) => {
      let item = p.item;
      if (p.section === source.section) {
        if (item === from) {
          item = to;
        } else if (from < to && item > from && item <= to) {
          item -= 1;
        } else if (from > to && item >= to && item < from) {
          item += 1;
        }
      }
      moved.set(key(p.section, item), makePath(p.section, item));
    });
    this.selection = moved;
    this.menuDelegate?.menuDidMoveItem?.(this, source, destination);
    if (this.tagMoveHandler !== undefined && this.tagDataSourceStorage !== undefined &&
      this.menuDataSource === this.tagDataSourceStorage) {
      this.tagMoveHandler(from, to);
    }
    this.reloadMenuData();
  }

  /** The item at a point of the list's content (below the title), or undefined. */
  indexPathAtPoint(x: number, y: number): CYLIndexPath | undefined {
    for (const section of this.layoutSections()) {
      for (const frame of section.items) {
        if (!frame.isFoldCell && x >= frame.x && x < frame.x + frame.width && y >= frame.y &&
          y < frame.y + frame.height) {
          return makePath(frame.section, frame.item);
        }
      }
    }
    return undefined;
  }

  private reportLongPress(indexPath: CYLIndexPath): void {
    this.menuDelegate?.menuDidLongPressItem?.(this, indexPath);
    const tag = this.tagAt(indexPath);
    if (tag !== undefined) {
      this.tagLongPressHandlerStorage?.(indexPath.item, tag);
    }
  }

  private reportSelectedDrag(indexPath: CYLIndexPath): void {
    this.menuDelegate?.menuDidBeginDraggingSelectedItem?.(this, indexPath);
    const tag = this.tagAt(indexPath);
    if (tag !== undefined) {
      this.selectedTagDragHandler?.(indexPath.item, tag);
    }
  }

  /** Whether a long press is reported for an item (the delegate or `tagLongPressHandler` handles it). */
  reportsLongPress(indexPath: CYLIndexPath): boolean {
    return this.menuDelegate?.menuDidLongPressItem !== undefined ||
      (this.tagLongPressHandlerStorage !== undefined && this.tagAt(indexPath) !== undefined);
  }

  // MARK: Data source queries

  numberOfSections(): number {
    return this.titles.length;
  }

  /** `collectionView(_:numberOfItemsInSection:)`: the visible items and the inline fold control. */
  numberOfDisplayedItems(section: number): number {
    return this.numberOfVisibleItems(section) + (this.showsInlineFoldCell(section) ? 1 : 0);
  }

  /** The title an item shows ("新建标签：<name>" for a create item). */
  titleForItem(indexPath: CYLIndexPath): string {
    return this.isValid(indexPath) ? this.titles[indexPath.section][indexPath.item] : '';
  }

  isValid(indexPath: CYLIndexPath): boolean {
    return indexPath.section >= 0 && indexPath.section < this.titles.length && indexPath.item >= 0 &&
      indexPath.item < this.titles[indexPath.section].length;
  }

  isEnabled(indexPath: CYLIndexPath): boolean {
    return this.menuDataSource === undefined || CYLMenuDefaults.isEnabled(this.menuDataSource, indexPath);
  }

  isDeletable(indexPath: CYLIndexPath): boolean {
    return this.itemType(indexPath) !== CYLMenuItemType.create && this.menuDataSource !== undefined &&
    CYLMenuDefaults.isDeletable(this.menuDataSource, indexPath);
  }

  isExclusive(indexPath: CYLIndexPath): boolean {
    return this.menuDataSource !== undefined && CYLMenuDefaults.isExclusive(this.menuDataSource, indexPath);
  }

  isSelectable(indexPath: CYLIndexPath): boolean {
    return this.itemType(indexPath) !== CYLMenuItemType.create &&
      (this.menuDataSource === undefined || CYLMenuDefaults.isSelectable(this.menuDataSource, indexPath));
  }

  itemType(indexPath: CYLIndexPath): CYLMenuItemType {
    return this.menuDataSource === undefined ? CYLMenuItemType.tag :
    CYLMenuDefaults.itemType(this.menuDataSource, indexPath);
  }

  imageForItem(indexPath: CYLIndexPath): CYLImage | undefined {
    if (this.itemType(indexPath) === CYLMenuItemType.create) {
      return CYLTagCreateItem.plusImage;
    }
    return this.menuDataSource?.menuImageForItem?.(indexPath) ?? this.defaultTagImage;
  }

  selectedImageForItem(indexPath: CYLIndexPath): CYLImage | undefined {
    return this.menuDataSource?.menuSelectedImageForItem?.(indexPath);
  }

  animationURLForItem(indexPath: CYLIndexPath): string | undefined {
    return this.menuDataSource?.menuAnimationURLForItem?.(indexPath);
  }

  animationRestingProgressForItem(indexPath: CYLIndexPath): number {
    return this.menuDataSource?.menuAnimationRestingProgressForItem?.(indexPath) ?? 0;
  }

  accessibilityHintForItem(indexPath: CYLIndexPath): string | undefined {
    return this.menuDataSource?.menuAccessibilityHintForItem?.(indexPath);
  }

  /** The item's own look, or its section's (themed by `colorTheme`; outlined for a create item). */
  styleForItem(indexPath: CYLIndexPath): CYLMenuStyle {
    const own = this.menuDataSource?.menuStyleForItem?.(indexPath);
    if (own !== undefined) {
      return own;
    }
    const sectionStyle = this.styleForSection(indexPath.section);
    if (this.itemType(indexPath) !== CYLMenuItemType.create) {
      return this.themeStyle(indexPath, sectionStyle);
    }
    if (this.createItemStyle !== undefined && this.createItemStyle.base === sectionStyle) {
      return this.createItemStyle.style;
    }
    const outlined = CYLTagCreateItem.outlinedStyle(sectionStyle);
    this.createItemStyle = new CYLStyleCacheEntry(sectionStyle, outlined);
    return outlined;
  }

  /** The section's own look, or the list's style. */
  styleForSection(section: number): CYLMenuStyle {
    return this.menuDataSource?.menuStyleForSection?.(section) ?? this.styleStorage;
  }

  showsMoreButton(section: number): boolean {
    return this.menuDataSource !== undefined && CYLMenuDefaults.showsMoreButton(this.menuDataSource, section);
  }

  /** The More button's label: the data source's, else "<section title> 更多". */
  moreButtonAccessibilityLabel(section: number): string {
    const label = this.menuDataSource?.menuAccessibilityLabelForMoreButtonInSection?.(section) ?? '';
    if (label.length > 0) {
      return label;
    }
    const title = this.menuDataSource?.menuTitleForSection(section) ?? '';
    const more = CYLMenuLocalizedString('CYLMenuMoreActions');
    return title.length === 0 ? more : `${title} ${more}`;
  }

  private themeStyle(indexPath: CYLIndexPath, baseStyle: CYLMenuStyle): CYLMenuStyle {
    if (this.colorThemeStorage === CYLTagColorTheme.none) {
      return baseStyle;
    }
    const k = key(indexPath.section, indexPath.item);
    const cached = this.themeStyles.get(k);
    if (cached !== undefined && cached.base === baseStyle) {
      return cached.style;
    }
    const seed = indexPath.item + indexPath.section * 7;
    const colors = CYLTagColors.fromTheme(this.colorThemeStorage, seed);
    const style = colors !== undefined ? colors.styleByApplying(baseStyle) : baseStyle;
    this.themeStyles.set(k, new CYLStyleCacheEntry(baseStyle, style));
    return style;
  }

  /** One of `tags` when the list shows them. */
  tagAt(indexPath: CYLIndexPath): CYLTag | undefined {
    const source = this.tagDataSourceStorage;
    if (source === undefined || this.menuDataSource !== source || indexPath.section !== 0) {
      return undefined;
    }
    const tags = source.tags;
    return indexPath.item >= 0 && indexPath.item < tags.length ? tags[indexPath.item] : undefined;
  }

  private showTags(): CYLTagDataSource {
    const source = this.tagDataSource;
    if (this.menuDataSource !== source) {
      this.menuDataSource = source;
      this.showsSectionHeadersStorage = false;
      this.selectionMode = CYLMenuSelectionMode.none;
    }
    return source;
  }

  // MARK: Measurement

  get itemHeight(): number {
    return CYLTagButtonMetrics.height(this.styleStorage, this.fontScale);
  }

  private get foldControlIsInHeader(): boolean {
    const p = this.foldControlStorage.position;
    return p === CYLMenuFoldControlPosition.headerTrailing || p === CYLMenuFoldControlPosition.headerLeading;
  }

  private get foldControlIsInFooter(): boolean {
    return this.foldControlStorage.position === CYLMenuFoldControlPosition.footer;
  }

  private get foldControlIsInline(): boolean {
    return this.foldControlStorage.position === CYLMenuFoldControlPosition.tail;
  }

  isInlineFoldCell(indexPath: CYLIndexPath): boolean {
    return this.showsInlineFoldCell(indexPath.section) &&
      indexPath.item === this.numberOfVisibleItems(indexPath.section);
  }

  inlineFoldSize(section: number, expanded: boolean): CYLSize {
    return CYLTagFoldMetrics.inlineSize(this.displayedFoldControl, this.styleForSection(section), expanded,
      this.fontScale);
  }

  foldSize(expanded: boolean): CYLSize {
    return CYLTagFoldMetrics.size(this.foldControlStorage, expanded, this.fontScale);
  }

  get footerHeight(): number {
    return Math.max(FOOTER_HEIGHT, this.foldSize(false).height);
  }

  headerHeight(): number {
    const foldHeight = this.foldControlIsInHeader ? this.foldSize(false).height : 0;
    if (!this.showsSectionHeadersStorage) {
      return foldHeight;
    }
    const font = this.styleStorage.headerFontFor(this.fontScale);
    return Math.max(this.styleStorage.headerHeight, Math.ceil(CYLTagButtonMetrics.lineHeight(font)) + 12, foldHeight);
  }

  private contentWidth(width: number): number {
    const insets = this.styleStorage.sectionInsets;
    return Math.max(0, width - insets.left - insets.right);
  }

  private widths(contentWidth: number): number[][] {
    return this.titles.map((items: string[], section: number): number[] => {
      const perRow = Math.trunc(this.styleForSection(section).numberOfItemsPerRow);
      return items.map((title: string, item: number): number => {
        if (perRow > 0) {
          return Math.min(this.gridItemWidth(contentWidth, perRow), contentWidth);
        }
        const p = makePath(section, item);
        const itemStyle = this.styleForItem(p);
        const iconSize = CYLTagButtonMetrics.iconSize(this.imageForItem(p), this.animationURLForItem(p) !== undefined,
          itemStyle);
        const width = CYLTagButtonMetrics.width(title, iconSize, this.isDeletable(p), itemStyle, this.fontScale);
        return Math.min(width, contentWidth);
      });
    });
  }

  private measureItemHeights(): number[][] {
    const listHeight = this.itemHeight;
    return this.titles.map((items: string[], section: number): number[] => items.map((title: string,
      item: number): number => {
      const itemStyle = this.styleForItem(makePath(section, item));
      return itemStyle === this.styleStorage ? listHeight :
      Math.max(listHeight, CYLTagButtonMetrics.height(itemStyle, this.fontScale));
    }));
  }

  private heightOfRows(rowCount: number, rows: number[], heights: number[]): number {
    let total = 0;
    let item = 0;
    for (let row = 0; row < Math.max(0, rowCount); row++) {
      let rowHeight = this.itemHeight;
      if (row < rows.length) {
        const count = rows[row];
        const end = Math.min(item + count, heights.length);
        for (let i = item; i < end; i++) {
          rowHeight = Math.max(rowHeight, heights[i]);
        }
        item += count;
      }
      total += rowHeight;
    }
    return total + (rowCount > 0 ? (rowCount - 1) * this.styleStorage.lineSpacing : 0);
  }

  private gridItemWidth(contentWidth: number, itemsPerRow: number): number {
    const spacing = this.styleStorage.interitemSpacing;
    return Math.max(1, Math.floor((contentWidth - spacing * (itemsPerRow - 1)) / itemsPerRow));
  }

  /** Items per row, computed in a single pass. */
  private rowsFor(widths: number[][], contentWidth: number): number[][] {
    const spacing = this.styleStorage.interitemSpacing;
    return widths.map((sectionWidths: number[]): number[] => {
      const sectionRows: number[] = [];
      let used = 0;
      let count = 0;
      sectionWidths.forEach((width: number) => {
        if (count > 0 && used + spacing + width > contentWidth) {
          sectionRows.push(count);
          used = 0;
          count = 0;
        }
        used += (count > 0 ? spacing : 0) + width;
        count += 1;
      });
      if (count > 0) {
        sectionRows.push(count);
      }
      return sectionRows;
    });
  }

  private measureIfNeeded(): void {
    const width = this.layoutWidth;
    if (width === this.measuredWidth) {
      return;
    }
    this.measuredWidth = width;
    const available = this.contentWidth(width);
    this.itemWidths = this.widths(available);
    this.itemHeights = this.measureItemHeights();
    this.rows = this.rowsFor(this.itemWidths, available);
  }

  private invalidateMeasurements(): void {
    this.measuredWidth = -1;
    this.reloadLayout();
  }

  private reloadLayout(): void {
    this.measureIfNeeded();
    this.updateContentHeight();
    this.setNeedsDisplay();
  }

  private updateContentHeight(): void {
    let height: number;
    if (this.layoutWidth > 0) {
      const sections = this.layoutSections();
      const last = sections.length > 0 ? sections[sections.length - 1] : undefined;
      height = Math.ceil(last !== undefined ? last.y + last.height : 0) + this.titleHeight();
    } else {
      height = this.heightThatFitsWidth(0);
    }
    if (Math.abs(height - this.contentHeightStorage) < 0.5) {
      return;
    }
    this.contentHeightStorage = height;
    this.menuDelegate?.menuDidChangeContentHeight?.(this, height);
  }

  private canFold(rowCount: number): boolean {
    const folds = this.foldStyleStorage === CYLMenuFoldStyle.truncate ||
      this.foldControlStorage.position !== CYLMenuFoldControlPosition.none;
    return folds && this.defaultVisibleRowsStorage > 0 && rowCount > this.defaultVisibleRowsStorage;
  }

  /**
   * The sections as laid out at the current width (`CYLCollectionViewLeftAlignedLayout`): a header, rows of the
   * visible items (and the inline fold control) aligned by `style.rowAlignment`, each row as tall as its tallest item
   * with its items centered in it, and a footer. Positions are below the title.
   */
  layoutSections(): CYLTagListSectionFrame[] {
    this.measureIfNeeded();
    const style = this.styleStorage;
    const insets = style.sectionInsets;
    const available = this.contentWidth(this.layoutWidth);
    const spacing = style.interitemSpacing;
    const header = this.headerHeight();
    const result: CYLTagListSectionFrame[] = [];
    let y = 0;
    for (let section = 0; section < this.titles.length; section++) {
      const frame = new CYLTagListSectionFrame();
      frame.section = section;
      frame.y = y;
      frame.headerHeight = header;
      frame.foldable = this.canFoldSection(section);
      frame.expanded = this.isSectionExpanded(section);
      const visible = this.numberOfVisibleItems(section);
      const cells: CYLTagListItemFrame[] = [];
      for (let item = 0; item < visible; item++) {
        const cell = new CYLTagListItemFrame();
        cell.section = section;
        cell.item = item;
        cell.width = Math.max(1, this.itemWidths[section]?.[item] ?? 0);
        cell.height = this.itemHeights[section]?.[item] ?? this.itemHeight;
        cells.push(cell);
      }
      if (this.showsInlineFoldCell(section)) {
        const size = this.inlineFoldSize(section, frame.expanded);
        const cell = new CYLTagListItemFrame();
        cell.section = section;
        cell.item = visible;
        cell.width = size.width;
        cell.height = size.height;
        cell.isFoldCell = true;
        cells.push(cell);
      }
      const rows = this.rowsFor([cells.map((c: CYLTagListItemFrame) => c.width)], available)[0] ?? [];
      let rowY = y + header + insets.top;
      let index = 0;
      rows.forEach((count: number, row: number) => {
        const rowCells = cells.slice(index, index + count);
        index += count;
        let rowWidth = 0;
        let rowHeight = 0;
        rowCells.forEach((c: CYLTagListItemFrame, i: number) => {
          rowWidth += (i > 0 ? spacing : 0) + c.width;
          rowHeight = Math.max(rowHeight, c.height);
        });
        let x = insets.left;
        if (style.rowAlignment === CYLTagRowAlignment.center) {
          x += Math.max(0, Math.floor((available - rowWidth) / 2));
        } else if (style.rowAlignment === CYLTagRowAlignment.trailing) {
          x += Math.max(0, available - rowWidth);
        }
        rowCells.forEach((c: CYLTagListItemFrame) => {
          c.x = x;
          c.y = rowY + Math.floor((rowHeight - c.height) / 2);
          x += c.width + spacing;
        });
        rowY += rowHeight + (row < rows.length - 1 ? style.lineSpacing : 0);
      });
      frame.items = cells;
      frame.footerHeight = this.showsFooterFoldControl(section) ? this.footerHeight : 0;
      frame.height = (rowY - y) + insets.bottom + frame.footerHeight;
      result.push(frame);
      y += frame.height;
    }
    return result;
  }

  // MARK: Selection helpers

  /** Adds `indexPath` and removes the items that the selection mode excludes; returns the removed ones. */
  private applySelection(indexPath: CYLIndexPath): CYLIndexPath[] {
    const exclusive = this.isExclusive(indexPath);
    const removed: CYLIndexPath[] = [];
    this.selection.forEach((other: CYLIndexPath) => {
      if (other.section === indexPath.section && other.item !== indexPath.item &&
        (this.selectionModeStorage === CYLMenuSelectionMode.single || exclusive || this.isExclusive(other))) {
        removed.push(other);
      }
    });
    removed.forEach((p: CYLIndexPath) => this.selection.delete(key(p.section, p.item)));
    this.selection.set(key(indexPath.section, indexPath.item), makePath(indexPath.section, indexPath.item));
    return removed;
  }

  private selectedCount(section: number): number {
    let count = 0;
    this.selection.forEach((p: CYLIndexPath) => {
      if (p.section === section) {
        count++;
      }
    });
    return count;
  }

  private shiftSelection(section: number, fromItem: number, offset: number): void {
    const shifted = new Map<string, CYLIndexPath>();
    this.selection.forEach((p: CYLIndexPath) => {
      const item = p.section === section && p.item >= fromItem ? p.item + offset : p.item;
      shifted.set(key(p.section, item), makePath(p.section, item));
    });
    this.selection = shifted;
  }

  private removeSelection(indexPath: CYLIndexPath): void {
    this.selection.delete(key(indexPath.section, indexPath.item));
    this.shiftSelection(indexPath.section, indexPath.item + 1, -1);
  }

  // MARK: Configuration

  /** The data source built from `CYLTagListKey.sections`, or undefined. */
  get configurationDataSource(): CYLMenuDataSource | undefined {
    return this.configurationDataSourceStorage;
  }

  /** `init(configuration:)`: a tag list from one dictionary holding everything (`CYLTagListKey`). */
  static withConfiguration(configuration: CYLConfiguration): CYLTagListState {
    const state = new CYLTagListState();
    state.applyConfiguration(configuration);
    return state;
  }

  /** `init(configurationFile:)`: reads a configuration file and creates a tag list from it. */
  static withConfigurationFile(filePath: string, context?: Context): CYLTagListState {
    return CYLTagListState.withConfiguration(CYLTagListState.configurationContentsOfFile(filePath, context));
  }

  /**
   * Reads a JSON configuration file: an absolute path (a sandbox file), or the name of a rawfile of the app (with
   * `context`). Throws `CYLMenuConfigurationError`.
   */
  static configurationContentsOfFile(filePath: string, context?: Context): CYLConfiguration {
    const lower = filePath.toLowerCase();
    const dot = lower.lastIndexOf('.');
    const ext = dot > lower.lastIndexOf('/') && dot >= 0 ? lower.substring(dot + 1) : '';
    if (ext !== 'json' && ext !== '') {
      throw new CYLMenuConfigurationError(CYLMenuConfigurationErrorCode.unsupportedFormat,
        `Reading .${ext} files is not supported; use JSON.`);
    }
    let text: string | undefined = undefined;
    try {
      if (filePath.startsWith('/')) {
        if (fileIo.accessSync(filePath)) {
          text = fileIo.readTextSync(filePath);
        }
      } else if (context !== undefined) {
        const bytes = context.resourceManager.getRawFileContentSync(filePath);
        text = util.TextDecoder.create('utf-8').decodeToString(bytes);
      }
    } catch (e) {
      text = undefined;
    }
    if (text === undefined) {
      throw new CYLMenuConfigurationError(CYLMenuConfigurationErrorCode.fileNotFound,
        `No configuration file at ${filePath}`);
    }
    let contents: Object | undefined = undefined;
    try {
      contents = JSON.parse(text) as Object;
    } catch (e) {
      contents = undefined;
    }
    const dictionary = CYLConfigurationValue.dictionary(contents);
    if (dictionary === undefined) {
      throw new CYLMenuConfigurationError(CYLMenuConfigurationErrorCode.invalidContents,
        `${filePath} does not hold a dictionary`);
    }
    return dictionary;
  }

  /** Applies a configuration to an existing list; keys that are missing keep their values. */
  applyConfiguration(configuration: CYLConfiguration): void {
    const styleValue = configuration[CYLTagListKey.style];
    if (styleValue instanceof CYLMenuStyle) {
      this.style = styleValue as CYLMenuStyle;
    } else {
      const d = CYLConfigurationValue.dictionary(styleValue);
      if (d !== undefined) {
        const copy = this.styleStorage.copy();
        CYLMenuConfiguration.applyToStyle(copy, d);
        this.style = copy;
      }
    }
    const mode = CYLConfigurationValue.rawValue(configuration[CYLTagListKey.selectionMode], new Map<string, number>([
      ['none', CYLMenuSelectionMode.none], ['single', CYLMenuSelectionMode.single],
      ['multiple', CYLMenuSelectionMode.multiple]]));
    if (mode !== undefined && mode >= 0 && mode <= 2) {
      this.selectionMode = mode as CYLMenuSelectionMode;
    }
    const foldStyle = CYLConfigurationValue.rawValue(configuration[CYLTagListKey.foldStyle], new Map<string, number>([
      ['none', CYLMenuFoldStyle.none], ['headerbutton', CYLMenuFoldStyle.headerButton],
      ['footerchevron', CYLMenuFoldStyle.footerChevron], ['truncate', CYLMenuFoldStyle.truncate]]));
    if (foldStyle !== undefined && foldStyle >= 0 && foldStyle <= 3) {
      this.foldStyle = foldStyle as CYLMenuFoldStyle;
    }
    const foldValue = configuration[CYLTagListKey.foldControl];
    if (foldValue !== undefined && foldValue !== null) {
      const control = CYLMenuConfiguration.foldControl(foldValue);
      if (control !== undefined) {
        this.foldControl = control;
      }
    }
    const position = CYLConfigurationValue.rawValue(configuration[CYLTagListKey.titlePosition], new Map<string, number>([
      ['topleading', CYLMenuTitlePosition.topLeading], ['leading', CYLMenuTitlePosition.topLeading],
      ['left', CYLMenuTitlePosition.topLeading], ['topcenter', CYLMenuTitlePosition.topCenter],
      ['center', CYLMenuTitlePosition.topCenter]]));
    if (position === CYLMenuTitlePosition.topLeading || position === CYLMenuTitlePosition.topCenter) {
      this.titlePosition = position as CYLMenuTitlePosition;
    }
    const titleStyleValue = configuration[CYLTagListKey.titleStyle];
    if (titleStyleValue instanceof CYLMenuStyle) {
      this.titleStyle = titleStyleValue as CYLMenuStyle;
    } else {
      const d = CYLConfigurationValue.dictionary(titleStyleValue);
      if (d !== undefined) {
        const style = CYLTagListState.defaultTitleStyle();
        CYLMenuConfiguration.applyToStyle(style, d);
        this.titleStyle = style;
      }
    }
    const titleImage = CYLConfigurationValue.image(configuration[CYLTagListKey.titleImage]);
    if (titleImage !== undefined) {
      this.titleImage = titleImage;
    }
    const title = configuration[CYLTagListKey.title];
    if (typeof title === 'string') {
      this.title = title as string;
    }
    const allowsEmpty = CYLConfigurationValue.bool(configuration[CYLTagListKey.allowsEmptySelection]);
    if (allowsEmpty !== undefined) {
      this.allowsEmptySelection = allowsEmpty;
    }
    const showsHeaders = CYLConfigurationValue.bool(configuration[CYLTagListKey.showsSectionHeaders]);
    if (showsHeaders !== undefined) {
      this.showsSectionHeaders = showsHeaders;
    }
    const scrollEnabled = CYLConfigurationValue.bool(configuration[CYLTagListKey.scrollEnabled]);
    if (scrollEnabled !== undefined) {
      this.isScrollEnabled = scrollEnabled;
    }
    const rows = CYLConfigurationValue.number(configuration[CYLTagListKey.defaultVisibleRows]);
    if (rows !== undefined) {
      this.defaultVisibleRows = Math.max(0, Math.trunc(rows));
    }
    const sections = configuration[CYLTagListKey.sections];
    if (Array.isArray(sections)) {
      const list = (sections as Object[]).map((s: Object): CYLConfiguration => CYLConfigurationValue.dictionary(s) ?? {});
      const source = new CYLTagListConfigurationSource(list, this);
      this.configurationDataSourceStorage = source;
      this.menuDataSource = source;
      this.reloadMenuData();
    }
    const tags = configuration[CYLTagListKey.tags];
    if (Array.isArray(tags)) {
      const made = (tags as Object[]).map((item: Object): CYLTag => {
        const d = CYLConfigurationValue.dictionary(item);
        if (d !== undefined) {
          return CYLMenuConfiguration.tag(d);
        }
        return new CYLTag(0, CYLConfigurationValue.text(item) ?? '');
      });
      this.removeAllTags();
      this.addTags(made);
    }
    const selected = configuration[CYLTagListKey.selectedItems];
    if (Array.isArray(selected)) {
      const paths: CYLIndexPath[] = [];
      (selected as Object[]).forEach((item: Object) => {
        const d = CYLConfigurationValue.dictionary(item);
        if (d !== undefined) {
          const s = CYLConfigurationValue.number(d['section']);
          const i = CYLConfigurationValue.number(d['item']);
          if (s !== undefined && i !== undefined) {
            paths.push(makePath(Math.trunc(s), Math.trunc(i)));
          }
          return;
        }
        const pair = typeof item === 'string' ? CYLConfigurationValue.numbers((item as string).replace('-', ','), 2) : CYLConfigurationValue.numbers(item, 2);
        if (pair !== undefined) {
          paths.push(makePath(Math.trunc(pair[0]), Math.trunc(pair[1])));
        }
      });
      this.selectedIndexPaths = paths;
    }
  }
}

/** The data source of `CYLTagListKey.sections`. */
export class CYLTagListConfigurationSource implements CYLMenuDataSource {
  private storedSections: CYLConfiguration[];
  private owner: CYLTagListState;
  private sectionStyles: Map<number, CYLStyleCacheEntry> = new Map<number, CYLStyleCacheEntry>();
  private itemStyles: Map<string, CYLStyleCacheEntry> = new Map<string, CYLStyleCacheEntry>();

  constructor(sections: CYLConfiguration[], owner: CYLTagListState) {
    this.storedSections = sections;
    this.owner = owner;
  }

  get sections(): CYLConfiguration[] {
    return this.storedSections;
  }

  private items(section: number): Object[] {
    if (section < 0 || section >= this.storedSections.length) {
      return [];
    }
    const items = this.storedSections[section][CYLTagSectionKey.items];
    return Array.isArray(items) ? items as Object[] : [];
  }

  private item(indexPath: CYLIndexPath): CYLConfiguration {
    const items = this.items(indexPath.section);
    if (indexPath.item < 0 || indexPath.item >= items.length) {
      return {};
    }
    const value = items[indexPath.item];
    const d = CYLConfigurationValue.dictionary(value);
    if (d !== undefined) {
      return d;
    }
    const titled: CYLConfiguration = {};
    titled[CYLTagItemKey.title] = CYLConfigurationValue.text(value) ?? '';
    return titled;
  }

  numberOfSectionsInMenu(): number {
    return this.storedSections.length;
  }

  menuNumberOfItemsInSection(section: number): number {
    return this.items(section).length;
  }

  menuTitleForSection(section: number): string {
    if (section < 0 || section >= this.storedSections.length) {
      return '';
    }
    return CYLConfigurationValue.text(this.storedSections[section][CYLTagSectionKey.title]) ?? '';
  }

  menuTitleForItem(indexPath: CYLIndexPath): string {
    return CYLConfigurationValue.text(this.item(indexPath)[CYLTagItemKey.title]) ?? '';
  }

  menuImageForItem = (indexPath: CYLIndexPath): CYLImage | undefined =>
  CYLConfigurationValue.image(this.item(indexPath)[CYLTagItemKey.image]);
  menuSelectedImageForItem = (indexPath: CYLIndexPath): CYLImage | undefined =>
  CYLConfigurationValue.image(this.item(indexPath)[CYLTagItemKey.selectedImage]);
  menuAnimationURLForItem = (indexPath: CYLIndexPath): string | undefined => {
    const item = this.item(indexPath);
    const animation = CYLConfigurationValue.text(item[CYLTagItemKey.animation]);
    if (animation === undefined || animation.length === 0) {
      return undefined;
    }
    return cylAddingAnimationOptions(animation, CYLConfigurationValue.dictionary(item[CYLTagItemKey.animationOptions]) ??
      {});
  }
  menuImageForSection = (section: number): CYLImage | undefined => section >= 0 &&
    section < this.storedSections.length ?
  CYLConfigurationValue.image(this.storedSections[section][CYLTagSectionKey.image]) : undefined;
  menuAnimationRestingProgressForItem = (indexPath: CYLIndexPath): number | undefined =>
  CYLConfigurationValue.number(this.item(indexPath)[CYLTagItemKey.animationRestingProgress]);
  menuStyleForSection = (section: number): CYLMenuStyle | undefined => {
    const value = section >= 0 && section < this.storedSections.length ?
    this.storedSections[section][CYLTagSectionKey.style] : undefined;
    if (value instanceof CYLMenuStyle) {
      return value as CYLMenuStyle;
    }
    const configuration = CYLConfigurationValue.dictionary(value);
    if (configuration === undefined) {
      return undefined;
    }
    const base = this.owner.style;
    const cached = this.sectionStyles.get(section);
    if (cached !== undefined && cached.base === base) {
      return cached.style;
    }
    const style = base.copy();
    CYLMenuConfiguration.applyToStyle(style, configuration);
    this.sectionStyles.set(section, new CYLStyleCacheEntry(base, style));
    return style;
  }
  menuItemIsEnabled = (indexPath: CYLIndexPath): boolean =>
  CYLConfigurationValue.bool(this.item(indexPath)[CYLTagItemKey.enabled]) ?? true;
  menuItemIsExclusive = (indexPath: CYLIndexPath): boolean =>
  CYLConfigurationValue.bool(this.item(indexPath)[CYLTagItemKey.exclusive]) ?? false;
  menuItemIsDeletable = (indexPath: CYLIndexPath): boolean =>
  CYLConfigurationValue.bool(this.item(indexPath)[CYLTagItemKey.deletable]) ?? false;
  menuRemoveItem = (indexPath: CYLIndexPath): void => {
    const items = this.items(indexPath.section);
    if (indexPath.item < 0 || indexPath.item >= items.length) {
      return;
    }
    const remaining = items.slice();
    remaining.splice(indexPath.item, 1);
    this.storedSections[indexPath.section][CYLTagSectionKey.items] = remaining;
    this.itemStyles.clear();
  }
  menuStyleForItem = (indexPath: CYLIndexPath): CYLMenuStyle | undefined => {
    const value = this.item(indexPath)[CYLTagItemKey.style];
    if (value instanceof CYLMenuStyle) {
      return value as CYLMenuStyle;
    }
    const configuration = CYLConfigurationValue.dictionary(value);
    if (configuration === undefined) {
      return undefined;
    }
    const base = this.menuStyleForSection(indexPath.section) ?? this.owner.style;
    const k = key(indexPath.section, indexPath.item);
    const cached = this.itemStyles.get(k);
    if (cached !== undefined && cached.base === base) {
      return cached.style;
    }
    const style = base.copy();
    CYLMenuConfiguration.applyToStyle(style, configuration);
    this.itemStyles.set(k, new CYLStyleCacheEntry(base, style));
    return style;
  }
  menuItemType = (indexPath: CYLIndexPath): CYLMenuItemType => {
    const raw = CYLConfigurationValue.rawValue(this.item(indexPath)[CYLTagItemKey.type], new Map<string, number>([
      ['tag', CYLMenuItemType.tag], ['create', CYLMenuItemType.create], ['new', CYLMenuItemType.create]]));
    return raw === CYLMenuItemType.create ? CYLMenuItemType.create : CYLMenuItemType.tag;
  }
}
