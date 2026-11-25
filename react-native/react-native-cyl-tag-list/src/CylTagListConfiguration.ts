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
 * The fold control of More / Less. `content` left out: the tail and the footer show the icon only, the header shows
 * `iconAndTitle`. A control in a section header shows only on a section that can fold (no space is kept on one that cannot),
 * its font is capped and its width is at most 40% of the header, where the section title truncates at the tail.
 */
export type CylFoldControl = {
  position?: CylFoldControlPosition;
  content?: CylFoldControlContent;
  /** The folded title; defaults to the localized "More". */
  title?: string;
  /** The expanded title; defaults to the localized "Less" ("Collapse"). */
  collapseTitle?: string;
  color?: CylColorString;
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

export type CylTagListItem = {
  title?: string;
  /** Shown by the `callout` long-press action, and read by an accessibility service as the hint. */
  subtitle?: string;
  image?: string;
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
  style?: CylSectionStyleKeys & {
    titleMaxLines?: CylTagTitleMaxLines;
    itemsPerRow?: number;
    [key: string]: unknown;
  };
  [key: string]: unknown;
};
