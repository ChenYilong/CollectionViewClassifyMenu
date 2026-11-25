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
  /** The fold control of More / Less: a position name, or a dictionary of the core (position, content). */
  foldControl?: string | Record<string, unknown>;
  /** Style keys; `itemsPerRow` left out (0) makes each tag as wide as its content. */
  style?: {
    titleMaxLines?: CylTagTitleMaxLines;
    itemsPerRow?: number;
    [key: string]: unknown;
  };
  [key: string]: unknown;
};
