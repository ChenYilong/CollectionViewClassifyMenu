/**
 * The configuration keys and value readers of a tag list, as iOS `CYLTagListView+CYLConfiguration.swift`: a tag list
 * (and its style, fold control and tags) made from one dictionary, a JSON object. In code, values have their usual
 * types (a `CYLMenuStyle`, a `CYLMenuFoldControl`); in a file, strings work for every key (colors "#RRGGBB", insets
 * "{top, left, bottom, right}" or arrays, enum names...). The tag list part (`applyConfiguration`) is in
 * components/CYLTagListState.ets.
 */
import { CYLMenuColorFromString } from './CYLMenuColor';
import { CYLMenuFoldControl, CYLMenuFoldControlContent, CYLMenuFoldControlPosition } from './CYLMenuFoldControl';
import { CYLMenuResources } from './CYLMenuResources';
import {
  CYLHeaderSeparatorStyle, CYLMenuStyle, CYLSectionStyle, CYLTagBackgroundStyle, CYLTagContentAlignment,
  CYLTagImagePlacement, CYLTagTitleMaxLines
} from './CYLMenuStyle';
import { CYLTag } from './CYLTag';
import { CYLTagAppearance } from './CYLTagAppearance';
import { CYLEdgeInsets, CYLFont, CYLImage, CYLOffset, CYLSize } from './CYLTypes';

/** A configuration dictionary: a parsed JSON object, or values of their own types set in code. */
export type CYLConfiguration = Record<string, Object>;

// MARK: - Keys

/** The keys of a tag list configuration. */
export class CYLTagListKey {
  /** An array of section dictionaries (`CYLTagSectionKey`). */
  static readonly sections: string = 'sections';
  /** A `CYLMenuStyle`, or a dictionary of `CYLMenuStyleKey` keys. */
  static readonly style: string = 'style';
  /** A `CYLMenuSelectionMode` raw value, or "none", "single", "multiple". */
  static readonly selectionMode: string = 'selectionMode';
  /** A `CYLMenuFoldStyle` raw value, or "none", "headerButton", "footerChevron", "truncate". */
  static readonly foldStyle: string = 'foldStyle';
  static readonly allowsEmptySelection: string = 'allowsEmptySelection';
  static readonly showsSectionHeaders: string = 'showsSectionHeaders';
  /** What a long press does: "reorder", "callout", "report" or "none", or an array of them (the first that can begin wins). */
  static readonly longPressAction: string = 'longPressAction';
  static readonly scrollEnabled: string = 'scrollEnabled';
  static readonly defaultVisibleRows: string = 'defaultVisibleRows';
  /** An array of index paths ({section, item}), "section-item" strings or [section, item] arrays. */
  static readonly selectedItems: string = 'selectedItems';
  /** A `CYLMenuFoldControl`, a position name, or a dictionary of `CYLMenuFoldControlKey` keys. */
  static readonly foldControl: string = 'foldControl';
  static readonly title: string = 'title';
  /** A `CYLMenuTitlePosition` raw value, or "topLeading" ("leading", "left"), "topCenter" ("center"). */
  static readonly titlePosition: string = 'titlePosition';
  static readonly titleImage: string = 'titleImage';
  /** A `CYLMenuStyle`, or a dictionary applied over `CYLTagListState.defaultTitleStyle()`. */
  static readonly titleStyle: string = 'titleStyle';
  /** An array of tags: strings (titles) or dictionaries of `CYLTagItemKey` keys. */
  static readonly tags: string = 'tags';
}

/** The keys of a fold control configuration. */
export class CYLMenuFoldControlKey {
  static readonly position: string = 'position';
  static readonly content: string = 'content';
  static readonly title: string = 'title';
  static readonly collapseTitle: string = 'collapseTitle';
  static readonly image: string = 'image';
  static readonly color: string = 'color';
  static readonly font: string = 'font';
  static readonly rotatesImage: string = 'rotatesImageWhenExpanded';
}

/** The keys of a section dictionary. */
export class CYLTagSectionKey {
  static readonly title: string = 'title';
  static readonly image: string = 'image';
  /** An array of item dictionaries, or of strings (titles). */
  static readonly items: string = 'items';
  /** A `CYLMenuStyle`, or a dictionary applied over the list's style. */
  static readonly style: string = 'style';
}

/** The keys of an item dictionary. */
export class CYLTagItemKey {
  static readonly title: string = 'title';
  /** A longer description, shown in a callout on a long press (`longPressAction` "callout"). */
  static readonly subtitle: string = 'subtitle';
  static readonly image: string = 'image';
  static readonly selectedImage: string = 'selectedImage';
  /** A Lottie animation: `asset:<rawfile path>`, or the JSON text. */
  static readonly animation: string = 'animation';
  /** A dictionary of strings written into the animation URL (`cylAddingAnimationOptions`). */
  static readonly animationOptions: string = 'animationOptions';
  static readonly animationRestingProgress: string = 'animationRestingProgress';
  static readonly enabled: string = 'enabled';
  static readonly exclusive: string = 'exclusive';
  /** A `CYLMenuItemType` raw value, or "tag" (default), "create" ("new"). */
  static readonly type: string = 'type';
  static readonly deletable: string = 'deletable';
  static readonly identifier: string = 'id';
  static readonly style: string = 'style';
}

/** The keys of a style dictionary. */
export class CYLMenuStyleKey {
  static readonly normal: string = 'normal';
  static readonly selected: string = 'selected';
  static readonly disabled: string = 'disabled';
  static readonly imageTitleSpacing: string = 'imageTitleSpacing';
  static readonly itemHeight: string = 'itemHeight';
  /** The most lines a title may take: a whole number, or "unlimited". Default 1. */
  static readonly titleMaxLines: string = 'titleMaxLines';
  static readonly numberOfItemsPerRow: string = 'itemsPerRow';
  static readonly interitemSpacing: string = 'interitemSpacing';
  static readonly lineSpacing: string = 'lineSpacing';
  static readonly headerHeight: string = 'headerHeight';
  static readonly animationSpeed: string = 'animationSpeed';
  static readonly imageSize: string = 'imageSize';
  static readonly animationSize: string = 'animationSize';
  static readonly imageInsets: string = 'imageInsets';
  static readonly sectionInsets: string = 'sectionInsets';
  static readonly titlePositionAdjustment: string = 'titlePositionAdjustment';
  static readonly imagePositionAdjustment: string = 'imagePositionAdjustment';
  static readonly layoutCentered: string = 'layoutCentered';
  static readonly imagePlacement: string = 'imagePlacement';
  static readonly contentAlignment: string = 'contentAlignment';
  /**
   * A `CYLTagBackgroundStyle` raw value, or 'flat' / 'liquidGlass' (case-insensitive); anything else is flat.
   */
  static readonly backgroundStyle: string = 'backgroundStyle';
  /**
   * A size '{width, height}' in vp, or { width: 69, height: 29 }: `CYLMenuStyle.minimumTagSize`.
   */
  static readonly minimumTagSize: string = 'minimumTagSize';
  static readonly adjustsFontForContentSizeCategory: string = 'adjustsFontForContentSizeCategory';
  static readonly backgroundColor: string = 'backgroundColor';
  static readonly headerTextColor: string = 'headerTextColor';
  static readonly foldControlColor: string = 'foldControlColor';
  /** The one color of the built-in views that are not tags (title, icon, fold / More control): `CYLMenuStyle.tintColor`. */
  static readonly tintColor: string = 'tintColor';
  static readonly headerFont: string = 'headerFont';
  static readonly highlightedBackgroundColor: string = 'highlightedBackgroundColor';
  static readonly tagContentInsets: string = 'tagContentInsets';
  static readonly deleteIndicatorTitle: string = 'deleteIndicatorTitle';
  static readonly deleteIndicatorColor: string = 'deleteIndicatorColor';
  static readonly deleteIndicatorFont: string = 'deleteIndicatorFont';
  /** The section card: "plain" or "insetGrouped" (case-insensitive), or a `CYLSectionStyle` raw value. */
  static readonly sectionStyle: string = 'sectionStyle';
  static readonly sectionBackgroundColor: string = 'sectionBackgroundColor';
  /** The card's background, as `backgroundStyle`: 'flat' or 'liquidGlass'; anything else is flat. */
  static readonly sectionBackgroundStyle: string = 'sectionBackgroundStyle';
  static readonly sectionCornerRadius: string = 'sectionCornerRadius';
  static readonly sectionContentInsets: string = 'sectionContentInsets';
  /** The header band's color; absent: no band. */
  static readonly headerBackgroundColor: string = 'headerBackgroundColor';
  static readonly headerCornerRadius: string = 'headerCornerRadius';
  static readonly headerContentInsets: string = 'headerContentInsets';
  /** The header divider: "none" or "line" (case-insensitive), or a `CYLHeaderSeparatorStyle` raw value. */
  static readonly headerSeparatorStyle: string = 'headerSeparatorStyle';
  static readonly headerSeparatorColor: string = 'headerSeparatorColor';
  static readonly headerSeparatorThickness: string = 'headerSeparatorThickness';
  static readonly headerSeparatorInsets: string = 'headerSeparatorInsets';
}

/** The keys of an appearance dictionary. */
export class CYLTagAppearanceKey {
  static readonly backgroundColor: string = 'backgroundColor';
  static readonly textColor: string = 'textColor';
  static readonly font: string = 'font';
  static readonly iconColor: string = 'iconColor';
  static readonly cornerRadius: string = 'cornerRadius';
  static readonly borderColor: string = 'borderColor';
  static readonly borderWidth: string = 'borderWidth';
  static readonly margin: string = 'margin';
  static readonly contentInsets: string = 'contentInsets';
  static readonly backgroundImage: string = 'backgroundImage';
}

// MARK: - Errors

/** Why a configuration file could not be read. */
export enum CYLMenuConfigurationErrorCode {
  /** No file at the path. */
  fileNotFound = 1,
  /** The file does not hold a dictionary. */
  invalidContents = 2,
  /** The format is not JSON. */
  unsupportedFormat = 3
}

export class CYLMenuConfigurationError extends Error {
  static readonly errorDomain: string = 'CYLMenuConfigurationErrorDomain';
  readonly code: CYLMenuConfigurationErrorCode;

  constructor(code: CYLMenuConfigurationErrorCode, message: string) {
    super(message);
    this.name = CYLMenuConfigurationError.errorDomain;
    this.code = code;
  }

  get errorCode(): number {
    return this.code;
  }

  get errorDescription(): string {
    return this.message;
  }

  /** `NSLocalizedDescriptionKey`: the message. */
  get errorUserInfo(): Record<string, string> {
    const info: Record<string, string> = { 'NSLocalizedDescription': this.message };
    return info;
  }
}

// MARK: - Values

/** Reads configuration values: the types of code, or the strings of a file. */
/** SF Symbols of the shared configurations and their nearest HarmonyOS system icons. */
const SF_SYMBOL_IMAGES: Map<string, Resource> = new Map<string, Resource>([
  // HarmonyOS has no heart icon: the library's own, drawn as the SF Symbols (outline and filled, tinted like any icon).
  ['heart', $r('app.media.cyl_symbol_heart')],
  ['heart.fill', $r('app.media.cyl_symbol_heart_fill')],
  ['globe', $r('sys.media.ohos_ic_public_web')],
  ['location', $r('sys.media.ohos_ic_public_location')],
  ['checkmark', $r('sys.media.ohos_ic_public_ok')],
  ['xmark', $r('sys.media.ohos_ic_public_cancel')],
]);

export class CYLConfigurationValue {
  static number(value: Object | undefined | null): number | undefined {
    if (typeof value === 'number') {
      return value as number;
    }
    if (typeof value === 'boolean') {
      return (value as boolean) ? 1 : 0;
    }
    if (typeof value !== 'string') {
      return undefined;
    }
    const s = (value as string).trim().toLowerCase();
    if (s === 'true' || s === 'yes' || s === 'on') {
      return 1;
    }
    if (s === 'false' || s === 'no' || s === 'off') {
      return 0;
    }
    if (s.length === 0) {
      return undefined;
    }
    const n = Number(s);
    return Number.isNaN(n) ? undefined : n;
  }

  static bool(value: Object | undefined | null): boolean | undefined {
    const n = CYLConfigurationValue.number(value);
    return n === undefined ? undefined : n !== 0;
  }

  static numbers(value: Object | undefined | null, count: number): number[] | undefined {
    let parts: Object[];
    if (Array.isArray(value)) {
      parts = value as Object[];
    } else if (typeof value === 'string') {
      const trimmed = Array.from(value as string).filter((c: string) => '{}[]'.indexOf(c) < 0).join('');
      parts = trimmed.split(',');
    } else {
      return undefined;
    }
    if (parts.length !== count) {
      return undefined;
    }
    const result: number[] = [];
    for (const part of parts) {
      const n = CYLConfigurationValue.number(part);
      if (n === undefined) {
        return undefined;
      }
      result.push(n);
    }
    return result;
  }

  static dictionary(value: Object | undefined | null): CYLConfiguration | undefined {
    if (value === undefined || value === null || typeof value !== 'object' || Array.isArray(value) ||
      value instanceof CYLMenuStyle || value instanceof CYLMenuFoldControl || value instanceof CYLEdgeInsets ||
      value instanceof CYLSize || value instanceof CYLOffset || value instanceof CYLFont) {
      return undefined;
    }
    return value as CYLConfiguration;
  }

  static insets(value: Object | undefined | null): CYLEdgeInsets | undefined {
    if (value instanceof CYLEdgeInsets) {
      return value as CYLEdgeInsets;
    }
    const d = CYLConfigurationValue.dictionary(value);
    if (d !== undefined) {
      return new CYLEdgeInsets(CYLConfigurationValue.number(d['top']) ?? 0, CYLConfigurationValue.number(d['left']) ?? 0,
        CYLConfigurationValue.number(d['bottom']) ?? 0, CYLConfigurationValue.number(d['right']) ?? 0);
    }
    const n = CYLConfigurationValue.numbers(value, 4);
    return n === undefined ? undefined : new CYLEdgeInsets(n[0], n[1], n[2], n[3]);
  }

  static size(value: Object | undefined | null): CYLSize | undefined {
    if (value instanceof CYLSize) {
      return value as CYLSize;
    }
    const d = CYLConfigurationValue.dictionary(value);
    if (d !== undefined) {
      return new CYLSize(CYLConfigurationValue.number(d['width']) ?? 0, CYLConfigurationValue.number(d['height']) ?? 0);
    }
    const side = CYLConfigurationValue.number(value);
    if (side !== undefined) {
      return new CYLSize(side, side);
    }
    const n = CYLConfigurationValue.numbers(value, 2);
    return n === undefined ? undefined : new CYLSize(n[0], n[1]);
  }

  static offset(value: Object | undefined | null): CYLOffset | undefined {
    if (value instanceof CYLOffset) {
      return value as CYLOffset;
    }
    const d = CYLConfigurationValue.dictionary(value);
    if (d !== undefined) {
      return new CYLOffset(CYLConfigurationValue.number(d['horizontal']) ?? 0,
        CYLConfigurationValue.number(d['vertical']) ?? 0);
    }
    const n = CYLConfigurationValue.numbers(value, 2);
    return n === undefined ? undefined : new CYLOffset(n[0], n[1]);
  }

  /** A '#AARRGGBB' color from a color string (`CYLMenuColorFromString`). */
  static color(value: Object | undefined | null): string | undefined {
    return typeof value === 'string' ? CYLMenuColorFromString(value as string) : undefined;
  }

  /** A font from a `CYLFont`, a size, or {size:, weight:} (weights map to the nearest ArkUI `FontWeight`). */
  static font(value: Object | undefined | null): CYLFont | undefined {
    if (value instanceof CYLFont) {
      return value as CYLFont;
    }
    const size = CYLConfigurationValue.number(value);
    if (size !== undefined) {
      return CYLFont.systemFont(size);
    }
    const d = CYLConfigurationValue.dictionary(value);
    if (d === undefined) {
      return undefined;
    }
    const s = CYLConfigurationValue.number(d['size']);
    const pointSize = s !== undefined && s !== 0 ? s : 14;
    const name = typeof d['weight'] === 'string' ? (d['weight'] as string).toLowerCase() : 'regular';
    let weight = FontWeight.Normal;
    if (name === 'ultralight' || name === 'thin' || name === 'light') {
      weight = FontWeight.Lighter;
    } else if (name === 'medium') {
      weight = FontWeight.Medium;
    } else if (name === 'semibold' || name === 'bold') {
      weight = FontWeight.Bold;
    } else if (name === 'heavy' || name === 'black') {
      weight = FontWeight.Bolder;
    }
    return new CYLFont(pointSize, weight);
  }

  /**
   * An image: a `CYLImage` value, a core image name ("cyl_more"), or any other string as a path, a URL or a
   * resource string. "system:<SF Symbol>": the nearest HarmonyOS system icon for the symbols the examples use
   * (an icon-only item would otherwise be an empty chip), undefined for the others.
   */
  static image(value: Object | undefined | null): CYLImage | undefined {
    if (value === undefined || value === null) {
      return undefined;
    }
    if (typeof value !== 'string') {
      return typeof value === 'object' && CYLConfigurationValue.dictionary(value) === undefined ?
        value as CYLImage : undefined;
    }
    const s = value as string;
    if (s.length === 0) {
      return undefined;
    }
    if (s.startsWith('system:')) {
      return SF_SYMBOL_IMAGES.get(s.substring('system:'.length));
    }
    return CYLMenuResources.image(s) ?? s;
  }

  /** An enum's raw value from a number or one of `names` (lowercased); undefined when it is neither. */
  static rawValue(value: Object | undefined | null, names: Map<string, number>): number | undefined {
    if (typeof value === 'number') {
      return Math.trunc(value as number);
    }
    if (typeof value !== 'string') {
      return undefined;
    }
    const named = names.get((value as string).toLowerCase());
    if (named !== undefined) {
      return named;
    }
    const n = CYLConfigurationValue.number(value);
    return n === undefined ? undefined : Math.trunc(n);
  }

  /** A string value, or a number written as text. */
  static text(value: Object | undefined | null): string | undefined {
    if (typeof value === 'string') {
      return value as string;
    }
    if (typeof value === 'number' || typeof value === 'boolean') {
      return `${value}`;
    }
    return undefined;
  }
}

/**
 * `URL.cylAddingAnimationOptions(_:)`: the animation with options in its fragment ("name=value&…", percent-encoded
 * and sorted by name), as CYLTabBarController's CYLTabBarAnimationURLWithOptions(); the animation itself without
 * options.
 */
export function cylAddingAnimationOptions(animation: string, options: CYLConfiguration): string {
  const items: string[] = Object.keys(options).filter((name: string) => name.length > 0).sort()
    .map((name: string): string => {
      const v = CYLConfigurationValue.text(options[name]) ?? '';
      const encodedName = encodeURIComponent(name);
      const encodedValue = encodeURIComponent(v);
      return encodedName.length > 0 && encodedValue.length > 0 ? `${encodedName}=${encodedValue}` : '';
    })
    .filter((item: string) => item.length > 0);
  if (items.length === 0) {
    return animation;
  }
  const hash = animation.indexOf('#');
  const base = hash >= 0 ? animation.substring(0, hash) : animation;
  return `${base}#${items.join('&')}`;
}

// MARK: - Fold control, appearance, style, tag

/** Position names of a fold control. */
const FOLD_POSITIONS: Map<string, number> = new Map<string, number>([
  ['none', CYLMenuFoldControlPosition.none], ['footer', CYLMenuFoldControlPosition.footer],
  ['headertrailing', CYLMenuFoldControlPosition.headerTrailing],
  ['headerright', CYLMenuFoldControlPosition.headerTrailing],
  ['headerleading', CYLMenuFoldControlPosition.headerLeading],
  ['headerleft', CYLMenuFoldControlPosition.headerLeading], ['tail', CYLMenuFoldControlPosition.tail]
]);

const FOLD_CONTENTS: Map<string, number> = new Map<string, number>([
  ['iconandtitle', CYLMenuFoldControlContent.iconAndTitle], ['titleandicon', CYLMenuFoldControlContent.iconAndTitle],
  ['title', CYLMenuFoldControlContent.title], ['icon', CYLMenuFoldControlContent.icon]
]);

const IMAGE_PLACEMENTS: Map<string, number> = new Map<string, number>([
  ['leading', CYLTagImagePlacement.leading], ['left', CYLTagImagePlacement.leading],
  ['trailing', CYLTagImagePlacement.trailing], ['right', CYLTagImagePlacement.trailing],
  ['top', CYLTagImagePlacement.top], ['bottom', CYLTagImagePlacement.bottom]
]);

const BACKGROUND_STYLES: Map<string, number> = new Map<string, number>([
  ['flat', CYLTagBackgroundStyle.flat], ['liquidglass', CYLTagBackgroundStyle.liquidGlass]
]);

const SECTION_STYLES: Map<string, number> = new Map<string, number>([
  ['plain', CYLSectionStyle.plain], ['insetgrouped', CYLSectionStyle.insetGrouped]
]);

const HEADER_SEPARATOR_STYLES: Map<string, number> = new Map<string, number>([
  ['none', CYLHeaderSeparatorStyle.none], ['line', CYLHeaderSeparatorStyle.line]
]);

const CONTENT_ALIGNMENTS: Map<string, number> = new Map<string, number>([
  ['center', CYLTagContentAlignment.center], ['leading', CYLTagContentAlignment.leading],
  ['left', CYLTagContentAlignment.leading]
]);

export class CYLMenuConfiguration {
  /** `CYLMenuFoldControl.applyConfiguration(_:)`: missing keys keep their values. */
  static applyToFoldControl(control: CYLMenuFoldControl, configuration: CYLConfiguration): void {
    const position = CYLConfigurationValue.rawValue(configuration[CYLMenuFoldControlKey.position], FOLD_POSITIONS);
    if (position !== undefined && position >= CYLMenuFoldControlPosition.none &&
      position <= CYLMenuFoldControlPosition.tail) {
      control.position = position as CYLMenuFoldControlPosition;
    }
    const content = CYLConfigurationValue.rawValue(configuration[CYLMenuFoldControlKey.content], FOLD_CONTENTS);
    if (content !== undefined && content >= CYLMenuFoldControlContent.iconAndTitle &&
      content <= CYLMenuFoldControlContent.icon) {
      control.content = content as CYLMenuFoldControlContent;
    }
    const title = configuration[CYLMenuFoldControlKey.title];
    if (typeof title === 'string') {
      control.title = title as string;
    }
    const collapseTitle = configuration[CYLMenuFoldControlKey.collapseTitle];
    if (typeof collapseTitle === 'string') {
      control.collapseTitle = collapseTitle as string;
    }
    const image = CYLConfigurationValue.image(configuration[CYLMenuFoldControlKey.image]);
    if (image !== undefined) {
      control.image = image;
    }
    const color = CYLConfigurationValue.color(configuration[CYLMenuFoldControlKey.color]);
    if (color !== undefined) {
      control.color = color;
    }
    const font = CYLConfigurationValue.font(configuration[CYLMenuFoldControlKey.font]);
    if (font !== undefined) {
      control.font = font;
    }
    const rotates = CYLConfigurationValue.bool(configuration[CYLMenuFoldControlKey.rotatesImage]);
    if (rotates !== undefined) {
      control.rotatesImageWhenExpanded = rotates;
    }
  }

  /**
   * `CYLMenuFoldControl.init?(configuration:)`: from a dictionary, or from a position name or raw value alone (an icon
   * in the footer, an icon and a title elsewhere); undefined for anything else.
   */
  static foldControl(configuration: Object | undefined | null): CYLMenuFoldControl | undefined {
    if (configuration instanceof CYLMenuFoldControl) {
      return (configuration as CYLMenuFoldControl).copy();
    }
    const control = new CYLMenuFoldControl();
    const d = CYLConfigurationValue.dictionary(configuration);
    if (d !== undefined) {
      CYLMenuConfiguration.applyToFoldControl(control, d);
      return control;
    }
    if (typeof configuration !== 'string' && typeof configuration !== 'number') {
      return undefined;
    }
    const single: CYLConfiguration = {};
    single[CYLMenuFoldControlKey.position] = configuration as Object;
    CYLMenuConfiguration.applyToFoldControl(control, single);
    control.content = control.position === CYLMenuFoldControlPosition.footer ? CYLMenuFoldControlContent.icon :
    CYLMenuFoldControlContent.iconAndTitle;
    return control;
  }

  /**
   * `CYLTagAppearance.applyConfiguration(_:)`: missing keys keep their values; a key whose value is not a color, font
   * or image restores the default (or clears an optional one).
   */
  static applyToAppearance(appearance: CYLTagAppearance, configuration: CYLConfiguration): void {
    if (configuration[CYLTagAppearanceKey.backgroundColor] !== undefined) {
      const configuredBackground = CYLConfigurationValue.color(configuration[CYLTagAppearanceKey.backgroundColor]);
      if (configuredBackground !== undefined) {
        appearance.backgroundColor = configuredBackground;
      } else {
        // Not a color: back to "unset", never the built-in default stored as if the app had set it.
        appearance.resetBackgroundColor();
      }
    }
    if (configuration[CYLTagAppearanceKey.textColor] !== undefined) {
      appearance.textColor = CYLConfigurationValue.color(configuration[CYLTagAppearanceKey.textColor]) ??
      CYLTagAppearance.defaultTextColor;
    }
    if (configuration[CYLTagAppearanceKey.font] !== undefined) {
      appearance.font = CYLConfigurationValue.font(configuration[CYLTagAppearanceKey.font]) ?? CYLTagAppearance.defaultFont;
    }
    if (configuration[CYLTagAppearanceKey.iconColor] !== undefined) {
      appearance.iconColor = CYLConfigurationValue.color(configuration[CYLTagAppearanceKey.iconColor]);
    }
    if (configuration[CYLTagAppearanceKey.borderColor] !== undefined) {
      appearance.borderColor = CYLConfigurationValue.color(configuration[CYLTagAppearanceKey.borderColor]);
    }
    const cornerRadius = CYLConfigurationValue.number(configuration[CYLTagAppearanceKey.cornerRadius]);
    if (cornerRadius !== undefined) {
      appearance.cornerRadius = cornerRadius;
    }
    const borderWidth = CYLConfigurationValue.number(configuration[CYLTagAppearanceKey.borderWidth]);
    if (borderWidth !== undefined) {
      appearance.borderWidth = borderWidth;
    }
    const margin = CYLConfigurationValue.number(configuration[CYLTagAppearanceKey.margin]);
    if (margin !== undefined) {
      appearance.margin = margin;
    }
    const insets = CYLConfigurationValue.insets(configuration[CYLTagAppearanceKey.contentInsets]);
    if (insets !== undefined) {
      appearance.contentInsets = insets;
    }
    if (configuration[CYLTagAppearanceKey.backgroundImage] !== undefined) {
      // A background image is a resource or a path (a pixel map is not a background image of a tag).
      appearance.backgroundImage = CYLConfigurationValue.image(configuration[CYLTagAppearanceKey.backgroundImage]) as ResourceStr | undefined;
    }
  }

  /** `CYLMenuStyle.init(configuration:)`: a default style with the configuration's values. */
  static style(configuration: CYLConfiguration): CYLMenuStyle {
    const style = new CYLMenuStyle();
    CYLMenuConfiguration.applyToStyle(style, configuration);
    return style;
  }

  /** `CYLMenuStyle.applyConfiguration(_:)`: missing keys keep their values. */
  static applyToStyle(style: CYLMenuStyle, configuration: CYLConfiguration): void {
    const normal = CYLConfigurationValue.dictionary(configuration[CYLMenuStyleKey.normal]);
    if (normal !== undefined) {
      CYLMenuConfiguration.applyToAppearance(style.normalAppearance, normal);
    }
    const selected = CYLConfigurationValue.dictionary(configuration[CYLMenuStyleKey.selected]);
    if (selected !== undefined) {
      CYLMenuConfiguration.applyToAppearance(style.selectedAppearance, selected);
    }
    const disabled = CYLConfigurationValue.dictionary(configuration[CYLMenuStyleKey.disabled]);
    if (disabled !== undefined) {
      CYLMenuConfiguration.applyToAppearance(style.disabledAppearance, disabled);
    }
    const imageTitleSpacing = CYLConfigurationValue.number(configuration[CYLMenuStyleKey.imageTitleSpacing]);
    if (imageTitleSpacing !== undefined) {
      style.imageTitleSpacing = imageTitleSpacing;
    }
    const maxLinesValue = configuration[CYLMenuStyleKey.titleMaxLines];
    if (maxLinesValue === 'unlimited') {
      style.titleMaxLines = CYLTagTitleMaxLines.unlimited;
    } else {
      const maxLines = CYLConfigurationValue.number(maxLinesValue);
      if (maxLines !== undefined) {
        style.titleMaxLines = maxLines;
      }
    }
    const itemHeight = CYLConfigurationValue.number(configuration[CYLMenuStyleKey.itemHeight]);
    if (itemHeight !== undefined) {
      style.itemHeight = itemHeight;
    }
    const perRow = CYLConfigurationValue.number(configuration[CYLMenuStyleKey.numberOfItemsPerRow]);
    if (perRow !== undefined) {
      style.numberOfItemsPerRow = Math.max(0, Math.trunc(perRow));
    }
    const interitemSpacing = CYLConfigurationValue.number(configuration[CYLMenuStyleKey.interitemSpacing]);
    if (interitemSpacing !== undefined) {
      style.interitemSpacing = interitemSpacing;
    }
    const lineSpacing = CYLConfigurationValue.number(configuration[CYLMenuStyleKey.lineSpacing]);
    if (lineSpacing !== undefined) {
      style.lineSpacing = lineSpacing;
    }
    const headerHeight = CYLConfigurationValue.number(configuration[CYLMenuStyleKey.headerHeight]);
    if (headerHeight !== undefined) {
      style.headerHeight = headerHeight;
    }
    const animationSpeed = CYLConfigurationValue.number(configuration[CYLMenuStyleKey.animationSpeed]);
    if (animationSpeed !== undefined) {
      style.animationSpeed = animationSpeed;
    }
    const layoutCentered = CYLConfigurationValue.bool(configuration[CYLMenuStyleKey.layoutCentered]);
    if (layoutCentered !== undefined) {
      style.layoutCentered = layoutCentered;
    }
    const placement = CYLConfigurationValue.rawValue(configuration[CYLMenuStyleKey.imagePlacement], IMAGE_PLACEMENTS);
    if (placement === CYLTagImagePlacement.leading || placement === CYLTagImagePlacement.trailing ||
      placement === CYLTagImagePlacement.top || placement === CYLTagImagePlacement.bottom) {
      style.imagePlacement = placement as CYLTagImagePlacement;
    }
    const alignment = CYLConfigurationValue.rawValue(configuration[CYLMenuStyleKey.contentAlignment], CONTENT_ALIGNMENTS);
    if (alignment === CYLTagContentAlignment.center || alignment === CYLTagContentAlignment.leading) {
      style.contentAlignment = alignment as CYLTagContentAlignment;
    }
    const backgroundStyle = CYLConfigurationValue.rawValue(configuration[CYLMenuStyleKey.backgroundStyle], BACKGROUND_STYLES);
    if (backgroundStyle === CYLTagBackgroundStyle.flat || backgroundStyle === CYLTagBackgroundStyle.liquidGlass) {
      style.backgroundStyle = backgroundStyle as CYLTagBackgroundStyle;
    }
    const minimumTagSize = CYLConfigurationValue.size(configuration[CYLMenuStyleKey.minimumTagSize]);
    if (minimumTagSize !== undefined) {
      style.minimumTagSize = minimumTagSize;
    }
    const adjusts = CYLConfigurationValue.bool(configuration[CYLMenuStyleKey.adjustsFontForContentSizeCategory]);
    if (adjusts !== undefined) {
      style.adjustsFontForContentSizeCategory = adjusts;
    }
    const imageSize = CYLConfigurationValue.size(configuration[CYLMenuStyleKey.imageSize]);
    if (imageSize !== undefined) {
      style.imageSize = imageSize;
    }
    const animationSize = CYLConfigurationValue.size(configuration[CYLMenuStyleKey.animationSize]);
    if (animationSize !== undefined) {
      style.animationSize = animationSize;
    }
    const imageInsets = CYLConfigurationValue.insets(configuration[CYLMenuStyleKey.imageInsets]);
    if (imageInsets !== undefined) {
      style.imageInsets = imageInsets;
    }
    const sectionInsets = CYLConfigurationValue.insets(configuration[CYLMenuStyleKey.sectionInsets]);
    if (sectionInsets !== undefined) {
      style.sectionInsets = sectionInsets;
    }
    const titleAdjustment = CYLConfigurationValue.offset(configuration[CYLMenuStyleKey.titlePositionAdjustment]);
    if (titleAdjustment !== undefined) {
      style.titlePositionAdjustment = titleAdjustment;
    }
    const imageAdjustment = CYLConfigurationValue.offset(configuration[CYLMenuStyleKey.imagePositionAdjustment]);
    if (imageAdjustment !== undefined) {
      style.imagePositionAdjustment = imageAdjustment;
    }
    const backgroundColor = CYLConfigurationValue.color(configuration[CYLMenuStyleKey.backgroundColor]);
    if (backgroundColor !== undefined) {
      style.backgroundColor = backgroundColor;
    }
    const headerTextColor = CYLConfigurationValue.color(configuration[CYLMenuStyleKey.headerTextColor]);
    if (headerTextColor !== undefined) {
      style.headerTextColor = headerTextColor;
    }
    const foldControlColor = CYLConfigurationValue.color(configuration[CYLMenuStyleKey.foldControlColor]);
    if (foldControlColor !== undefined) {
      style.foldControlColor = foldControlColor;
    }
    const tintColor = CYLConfigurationValue.color(configuration[CYLMenuStyleKey.tintColor]);
    if (tintColor !== undefined) {
      style.tintColor = tintColor;
    }
    const headerFont = CYLConfigurationValue.font(configuration[CYLMenuStyleKey.headerFont]);
    if (headerFont !== undefined) {
      style.headerFont = headerFont;
    }
    if (configuration[CYLMenuStyleKey.highlightedBackgroundColor] !== undefined) {
      style.highlightedBackgroundColor = CYLConfigurationValue.color(configuration[CYLMenuStyleKey.highlightedBackgroundColor]);
    }
    const tagContentInsets = CYLConfigurationValue.insets(configuration[CYLMenuStyleKey.tagContentInsets]);
    if (tagContentInsets !== undefined) {
      style.tagContentInsets = tagContentInsets;
    }
    const indicatorTitle = configuration[CYLMenuStyleKey.deleteIndicatorTitle];
    if (typeof indicatorTitle === 'string') {
      style.deleteIndicatorTitle = indicatorTitle as string;
    }
    if (configuration[CYLMenuStyleKey.deleteIndicatorColor] !== undefined) {
      style.deleteIndicatorColor = CYLConfigurationValue.color(configuration[CYLMenuStyleKey.deleteIndicatorColor]);
    }
    if (configuration[CYLMenuStyleKey.deleteIndicatorFont] !== undefined) {
      style.deleteIndicatorFont = CYLConfigurationValue.font(configuration[CYLMenuStyleKey.deleteIndicatorFont]);
    }
    CYLMenuConfiguration.applySectionStyle(style, configuration);
  }

  /** The section card, header band and header divider keys of `applyToStyle`. */
  private static applySectionStyle(style: CYLMenuStyle, configuration: CYLConfiguration): void {
    const sectionStyle = CYLConfigurationValue.rawValue(configuration[CYLMenuStyleKey.sectionStyle], SECTION_STYLES);
    if (sectionStyle === CYLSectionStyle.plain || sectionStyle === CYLSectionStyle.insetGrouped) {
      style.sectionStyle = sectionStyle as CYLSectionStyle;
    }
    const cardBackground =
      CYLConfigurationValue.rawValue(configuration[CYLMenuStyleKey.sectionBackgroundStyle], BACKGROUND_STYLES);
    if (cardBackground === CYLTagBackgroundStyle.flat || cardBackground === CYLTagBackgroundStyle.liquidGlass) {
      style.sectionBackgroundStyle = cardBackground as CYLTagBackgroundStyle;
    }
    if (configuration[CYLMenuStyleKey.sectionBackgroundColor] !== undefined) {
      style.sectionBackgroundColor = CYLConfigurationValue.color(configuration[CYLMenuStyleKey.sectionBackgroundColor]);
    }
    const cornerRadius = CYLConfigurationValue.number(configuration[CYLMenuStyleKey.sectionCornerRadius]);
    if (cornerRadius !== undefined) {
      style.sectionCornerRadius = Math.max(0, cornerRadius);
    }
    const contentInsets = CYLConfigurationValue.insets(configuration[CYLMenuStyleKey.sectionContentInsets]);
    if (contentInsets !== undefined) {
      style.sectionContentInsets = contentInsets;
    }
    if (configuration[CYLMenuStyleKey.headerBackgroundColor] !== undefined) {
      style.headerBackgroundColor = CYLConfigurationValue.color(configuration[CYLMenuStyleKey.headerBackgroundColor]);
    }
    const headerRadius = CYLConfigurationValue.number(configuration[CYLMenuStyleKey.headerCornerRadius]);
    if (headerRadius !== undefined) {
      style.headerCornerRadius = Math.max(0, headerRadius);
    }
    const headerInsets = CYLConfigurationValue.insets(configuration[CYLMenuStyleKey.headerContentInsets]);
    if (headerInsets !== undefined) {
      style.headerContentInsets = headerInsets;
    }
    const separatorStyle =
      CYLConfigurationValue.rawValue(configuration[CYLMenuStyleKey.headerSeparatorStyle], HEADER_SEPARATOR_STYLES);
    if (separatorStyle === CYLHeaderSeparatorStyle.none || separatorStyle === CYLHeaderSeparatorStyle.line) {
      style.headerSeparatorStyle = separatorStyle as CYLHeaderSeparatorStyle;
    }
    if (configuration[CYLMenuStyleKey.headerSeparatorColor] !== undefined) {
      style.headerSeparatorColor = CYLConfigurationValue.color(configuration[CYLMenuStyleKey.headerSeparatorColor]);
    }
    const thickness = CYLConfigurationValue.number(configuration[CYLMenuStyleKey.headerSeparatorThickness]);
    if (thickness !== undefined) {
      style.headerSeparatorThickness = Math.max(0, thickness);
    }
    const separatorInsets = CYLConfigurationValue.insets(configuration[CYLMenuStyleKey.headerSeparatorInsets]);
    if (separatorInsets !== undefined) {
      style.headerSeparatorInsets = separatorInsets;
    }
  }

  /** `CYLTag.init(configuration:)`: title, image, selectedImage, animation, id, enabled, deletable, style. */
  static tag(configuration: CYLConfiguration): CYLTag {
    const tag = new CYLTag(Math.trunc(CYLConfigurationValue.number(configuration[CYLTagItemKey.identifier]) ?? 0),
      CYLConfigurationValue.text(configuration[CYLTagItemKey.title]) ?? '');
    tag.image = CYLConfigurationValue.image(configuration[CYLTagItemKey.image]);
    tag.selectedImage = CYLConfigurationValue.image(configuration[CYLTagItemKey.selectedImage]);
    const animation = CYLConfigurationValue.text(configuration[CYLTagItemKey.animation]);
    if (animation !== undefined && animation.length > 0) {
      tag.animationURL = cylAddingAnimationOptions(animation,
        CYLConfigurationValue.dictionary(configuration[CYLTagItemKey.animationOptions]) ?? {});
    }
    tag.isEnabled = CYLConfigurationValue.bool(configuration[CYLTagItemKey.enabled]) ?? true;
    tag.isDeletable = CYLConfigurationValue.bool(configuration[CYLTagItemKey.deletable]) ?? false;
    const style = configuration[CYLTagItemKey.style];
    if (style instanceof CYLMenuStyle) {
      tag.style = style as CYLMenuStyle;
    } else {
      const d = CYLConfigurationValue.dictionary(style);
      if (d !== undefined) {
        tag.style = CYLMenuConfiguration.style(d);
      }
    }
    return tag;
  }
}
