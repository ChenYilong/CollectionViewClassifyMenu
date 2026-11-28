/**
 * The configuration of the native tag list (CollectionViewClassifyMenu's CYLTagListView), as the native views read it.
 * Every key is optional; a key this type does not name is passed through to the native list unchanged.
 */

/** The names of the long-press actions the core has built in. */
export const CylTagLongPressActionName = {
  /** Drag to reorder (where the list can reorder), else report. */
  reorder: 'reorder',
  /** Report the press (`onTagLongPress`). */
  report: 'report',
  /** Show the tag's subtitle in a small callout with an arrow. */
  callout: 'callout',
  /** Do nothing. */
  none: 'none',
} as const;

export type CylTagLongPressActionName = (typeof CylTagLongPressActionName)[keyof typeof CylTagLongPressActionName];

/** The line limit of a tag title: a whole number of 1 or more, or this word for every line. */
export const CylTagTitleMaxLinesUnlimited = 'unlimited' as const;
export type CylTagTitleMaxLines = number | typeof CylTagTitleMaxLinesUnlimited;

/**
 * How a section's tags sit in the list. `insetGrouped` (the DEFAULT) draws them on a rounded card, and the list background is
 * the grouped background when `backgroundColor` was never set; `plain` removes the card (the look before the default changed).
 */
export const CylSectionStyle = {
  plain: 'plain',
  insetGrouped: 'insetGrouped',
} as const;

export type CylSectionStyle = (typeof CylSectionStyle)[keyof typeof CylSectionStyle];

/**
 * What a fold control (More / Less) shows. `iconAndTitle`: "More v" folded, only the chevron turned 180 degrees expanded.
 * `title`: "More" folded, "Less" expanded. `icon`: the chevron only. `titleAndIconAlways`: the title and the chevron in both
 * states, "More v" folded and "Less ^" expanded. (The older names `iconAndTitle` / `titleAndIcon` in lower case still mean
 * `iconAndTitle`.)
 */
export const CylFoldControlContent = {
  iconAndTitle: 'iconAndTitle',
  title: 'title',
  icon: 'icon',
  titleAndIconAlways: 'titleAndIconAlways',
} as const;

export type CylFoldControlContent = (typeof CylFoldControlContent)[keyof typeof CylFoldControlContent];

/** Where the fold control is drawn. */
export type CylFoldControlPosition = 'none' | 'footer' | 'headerTrailing' | 'headerLeading' | 'tail';

/**
 * The fold control of More / Less. `content` left out in the object shape: the icon only, at every position. A bare position
 * string (`foldControl: 'headerTrailing'`) picks the content that suits the position: the footer shows the icon only (the tail
 * too on Android), a header shows `iconAndTitle`. A control in a section header shows only on a section that can fold (no space
 * is kept on one that cannot), its font is capped and its width is at most 40% of the header, where the section title truncates
 * at the tail.
 */
export type CylFoldControl = {
  position?: CylFoldControlPosition;
  content?: CylFoldControlContent;
  /** The folded title; defaults to the localized "More". */
  title?: string;
  /** The expanded title; defaults to the localized "Less" ("Collapse"). */
  collapseTitle?: string;
  color?: CylColorString;
  /** The icon, pointing down while folded; left out: the core's chevron, drawn in `color`. */
  image?: string;
  /** The title font as the native parser reads it; left out: the footnote text style (capped in a header). */
  font?: unknown;
  /** The icon turns 180 degrees when expanded; default true. */
  rotatesImageWhenExpanded?: boolean;
};

/** The card's background: `flat` (the DEFAULT) is the solid card color; `liquidGlass` is the glass material, flat where unsupported. */
export const CylSectionBackgroundStyle = {
  flat: 'flat',
  liquidGlass: 'liquidGlass',
} as const;

export type CylSectionBackgroundStyle = (typeof CylSectionBackgroundStyle)[keyof typeof CylSectionBackgroundStyle];

/** The header divider: `none` (the DEFAULT, it is opt-in) or a `line` along the bottom of the section header. */
export const CylHeaderSeparatorStyle = {
  none: 'none',
  line: 'line',
} as const;

export type CylHeaderSeparatorStyle = (typeof CylHeaderSeparatorStyle)[keyof typeof CylHeaderSeparatorStyle];

/** A color the native list parses: '#RRGGBB', '#RRGGBBAA' (alpha last) or '#RGB'; the native side also knows names such as 'systemBlue'. */
export type CylColorString = string;

/**
 * Insets as the native parser reads them: `[top, left, bottom, right]`, `{ top, left, bottom, right }` (a missing side is 0) or
 * a string '{top, left, bottom, right}'. Points on iOS, dp on Android, vp on HarmonyOS, a pixel-independent unit in the mini program.
 */
export type CylInsets =
  | [number, number, number, number]
  | { top?: number; left?: number; bottom?: number; right?: number }
  | string;

/**
 * The section card, header band and header divider keys of a style (docs/tag-section-style.md). Every color adapts to light and
 * dark mode by itself unless you set it, and a color you set wins in both modes.
 */
export type CylSectionStyleKeys = {
  /** `insetGrouped` by default: a rounded card behind each section's tags. `plain` removes it. */
  sectionStyle?: CylSectionStyle;
  /** The card's color; left out: the system card color (white; #1C1C1E in dark mode). With `liquidGlass` it tints the glass. */
  sectionBackgroundColor?: CylColorString;
  /** `flat` by default; `liquidGlass` draws the glass material and falls back to flat where the platform cannot. */
  sectionBackgroundStyle?: CylSectionBackgroundStyle;
  /** The card's corner radius; default 10. */
  sectionCornerRadius?: number;
  /** The padding inside the card; default 12 on every side. */
  sectionContentInsets?: CylInsets;
  /** The header band's color; left out (the default): no band. */
  headerBackgroundColor?: CylColorString;
  /** The header band's corner radius; default 0. */
  headerCornerRadius?: number;
  /** The band's padding, leading and trailing (top and bottom are 0); default 12. */
  headerContentInsets?: CylInsets;
  /**
   * How far the board (the card, the header band and the divider) extends beyond the tag column on the leading and trailing
   * sides, one value for both. 0: the board's edges coincide with the tags' edges. Left out: the leading and trailing parts of
   * `sectionContentInsets` (12), so the board spans the section column as before. A set value (0 included) replaces those two
   * parts; a negative value is 0. The tags and the header title always share the tag column, so this never changes the tag width.
   */
  sectionBoardInset?: number;
  /** The header's text color; left out: `tintColor`, else black or white, whichever is legible on the background. */
  headerTextColor?: CylColorString;
  /** The header title font as the native parser reads it. */
  headerFont?: unknown;
  /** The More / Less control's color; left out: `tintColor` (a `foldControl.color` wins over both). */
  foldControlColor?: CylColorString;
  /**
   * The line limit of a section header title; default single (1: one line, truncated, and the header is exactly `headerHeight`
   * high). A larger number or `CylTagTitleMaxLinesUnlimited` wraps the title and the header grows taller than `headerHeight`.
   */
  headerMaxLines?: CylTagTitleMaxLines;
  /**
   * The header's height; default 36. On a card (`insetGrouped`) with no header divider and no `headerHeight` set, the header is
   * sized to its text; a `headerHeight` you set is then the minimum, and the divider or `plain` keep it as the minimum always.
   */
  headerHeight?: number;
  /** `none` by default: no divider. `line` shows it under each section header, across the card's and the band's edges. */
  headerSeparatorStyle?: CylHeaderSeparatorStyle;
  /** The divider's color; left out: the system separator color (light and dark). */
  headerSeparatorColor?: CylColorString;
  /** The divider's thickness; default 0.5 (a hairline). */
  headerSeparatorThickness?: number;
  /** The divider's leading and trailing insets; default 0, so it has the same edges as the card and the band. */
  headerSeparatorInsets?: CylInsets;
  /**
   * The one color of the built-in views that are not tags (header title, section icon, More / Less control). Left out: black or
   * white, whichever is legible on the background behind them.
   */
  tintColor?: CylColorString;
};

/** How a tag's background is drawn: `flat` (the DEFAULT) or the `liquidGlass` material (flat where the platform cannot draw it). */
export const CylTagBackgroundStyle = {
  flat: 'flat',
  liquidGlass: 'liquidGlass',
} as const;

export type CylTagBackgroundStyle = (typeof CylTagBackgroundStyle)[keyof typeof CylTagBackgroundStyle];

/** The tag layout keys of a style that are common to the native lists (the same names on every platform). */
export type CylTagLayoutKeys = {
  /** The tags' background drawing; `flat` by default. See the glass rules in the README. */
  backgroundStyle?: CylTagBackgroundStyle | string;
  /** The tag's icon size, `{ width, height }` or `[width, height]` as the native parser reads it; default 14 x 14. */
  imageSize?: unknown;
  /** The tag's height; default 30. */
  itemHeight?: number;
  /** The horizontal gap between tags; default 10. */
  interitemSpacing?: number;
  /** The vertical gap between rows of tags. */
  lineSpacing?: number;
  /** The gap between a tag's icon and its title. */
  imageTitleSpacing?: number;
};

/**
 * The keys of one state's appearance (`style.normal`, `style.selected`, `style.disabled`) that this type names; every other
 * appearance key is passed through to the native list unchanged.
 */
export type CylTagStateStyle = {
  /**
   * The icon's explicit color. Left out, the icon takes the title color (the built-in color). On drawn dark glass the shared
   * item adapts explicit and built-in colors: a title below 4.5:1 contrast and an icon below 3:1 are lifted (hue and alpha kept;
   * docs/tag-liquid-glass.md). The tag itself has no contrast code; light mode and flat tags never change.
   */
  iconColor?: CylColorString;
  /** The title color. Explicit colors are adapted on drawn dark glass like `iconColor` (title 4.5:1). */
  textColor?: CylColorString;
  /** The tag's fill. On glass it tints the material; the explicit color decides, there is no default border to fall back to. */
  backgroundColor?: CylColorString;
  /** The border color. A tag has no default border (glass tags included): the border shows only when this or `borderWidth` is set. */
  borderColor?: CylColorString;
  /** The border width; a tag has no border by default. */
  borderWidth?: number;
  /** The corner radius. */
  cornerRadius?: number;
  /** The title font as the native parser reads it. */
  font?: unknown;
  [key: string]: unknown;
};

/** A tag's own style: the appearance of each state, overriding the list's `style` for this tag. */
export type CylTagItemStyle = {
  normal?: CylTagStateStyle;
  selected?: CylTagStateStyle;
  disabled?: CylTagStateStyle;
  [key: string]: unknown;
};

export type CylTagListItem = {
  title?: string;
  /** Shown by the `callout` long-press action, and read by an accessibility service as the hint. */
  subtitle?: string;
  image?: string;
  selectedImage?: string;
  /** An animated icon (a Lottie file and so on); see the animated item's documentation. */
  animation?: string;
  /** The tag's own style: `borderColor`, `borderWidth`, `backgroundColor`, `textColor` ... per state. */
  style?: CylTagItemStyle;
  enabled?: boolean;
  exclusive?: boolean;
  deletable?: boolean;
  id?: string;
  [key: string]: unknown;
};

export type CylTagListSection = {
  /** The section header's title. */
  title: string;
  items: CylTagListItem[];
  [key: string]: unknown;
};

export type CylTagListConfiguration = {
  sections?: CylTagListSection[];
  selectionMode?: 'none' | 'single' | 'multiple' | string;
  /** Rows a section shows before More / Less; a section with fewer rows shows no fold control. */
  defaultVisibleRows?: number;
  /**
   * A long-press action name, or several tried in order (`report` is appended unless listed or `none` is given).
   */
  longPressAction?: CylTagLongPressActionName | CylTagLongPressActionName[];
  /** The fold control of More / Less: a position name, or the typed shape (position, content, title, collapseTitle, color). */
  foldControl?: CylFoldControlPosition | CylFoldControl | string | Record<string, unknown>;
  /**
   * Style keys; `itemsPerRow` left out (0) makes each tag as wide as its content. Without any section key the list shows each
   * section on a rounded card (`sectionStyle: 'insetGrouped'`) and no header divider: set `sectionStyle: 'plain'` to remove the
   * card, `headerSeparatorStyle: 'line'` to show the divider.
   */
  style?: CylSectionStyleKeys & CylTagLayoutKeys & {
    titleMaxLines?: CylTagTitleMaxLines;
    itemsPerRow?: number;
    normal?: CylTagStateStyle;
    selected?: CylTagStateStyle;
    disabled?: CylTagStateStyle;
    [key: string]: unknown;
  };
  [key: string]: unknown;
};
