/**
 * The model of the Mini Program `cyl-tag-list` component: the configuration dictionary of the core's
 * `CYLTagListView(configuration:)` (the same keys as the Flutter plugin and the React Native component), the
 * selection rules of `CYLTagListView.handleTap(at:)` / `applySelection(of:)` and the folding of
 * `defaultVisibleRows`. It has no `wx` calls, so it runs under Node in the tests.
 *
 * An item is addressed by its key "<section>-<item>", the format of `selectedItems` on every platform.
 */

const DEFAULT_STYLE = {
  itemHeight: 32,
  imageSize: 18,
  normal: { cornerRadius: 16, borderColor: '#D1D1D6', borderWidth: 1, textColor: '#333333', backgroundColor: '#FFFFFF' },
  selected: { cornerRadius: 16, borderColor: '#2AB9A0', borderWidth: 1, textColor: '#2AB9A0', backgroundColor: '#E6F8F5' },
};

/** The fold control's titles, the core's localized `CYLMenuExpand` / `CYLMenuCollapse`. */
const EXPAND_TITLE = '更多';
const COLLAPSE_TITLE = '收起';

function key(section, item) {
  return `${section}-${item}`;
}

function parseKey(value) {
  const parts = String(value).split('-').map(Number);
  if (parts.length !== 2 || parts.some((n) => !Number.isInteger(n) || n < 0)) return null;
  return { section: parts[0], item: parts[1] };
}

/** "{18, 18}" (the core's CGSize string) or 18 → 18. */
function imageSize(value) {
  if (typeof value === 'number') return value;
  const match = /\{\s*([\d.]+)/.exec(String(value || ''));
  return match ? Number(match[1]) : DEFAULT_STYLE.imageSize;
}

function mergeStyle(style = {}) {
  return {
    itemHeight: style.itemHeight || DEFAULT_STYLE.itemHeight,
    imageSize: imageSize(style.imageSize),
    normal: { ...DEFAULT_STYLE.normal, ...(style.normal || {}) },
    selected: { ...DEFAULT_STYLE.selected, ...(style.selected || {}) },
  };
}

/**
 * The configuration with defaults: selectionMode ("none" | "single" | "multiple"), allowsEmptySelection (true, as in
 * the core), defaultVisibleRows (0 = never fold), foldControl ({position: "none" | "headerTrailing" | "tail",
 * content: "title" | "icon" | "iconAndTitle"}), style and sections ([{title, items: [{title, image, animation,
 * exclusive, enabled}]}]).
 */
function normalize(configuration = {}) {
  const sections = (configuration.sections || []).map((section, s) => ({
    index: s,
    title: section.title || '',
    items: (section.items || []).map((item, i) => ({
      key: key(s, i),
      section: s,
      item: i,
      title: item.title || '',
      image: item.image || '',
      animation: item.animation || '',
      exclusive: item.exclusive === true,
      enabled: item.enabled !== false,
    })),
  }));
  const foldControl = { position: 'none', content: 'title', ...(configuration.foldControl || {}) };
  return {
    selectionMode: configuration.selectionMode || 'none',
    allowsEmptySelection: configuration.allowsEmptySelection !== false,
    defaultVisibleRows: Number(configuration.defaultVisibleRows) || 0,
    foldControl,
    style: mergeStyle(configuration.style),
    sections,
    selectedItems: sanitizeSelection(configuration.selectedItems || [], sections),
  };
}

/** Drops keys that address no item, and duplicates; keeps the order. */
function sanitizeSelection(items, sections) {
  const result = [];
  items.forEach((value) => {
    const parsed = parseKey(value);
    if (!parsed) return;
    const section = sections[parsed.section];
    if (!section || !section.items[parsed.item]) return;
    const k = key(parsed.section, parsed.item);
    if (!result.includes(k)) result.push(k);
  });
  return result;
}

function itemAt(model, k) {
  const parsed = parseKey(k);
  if (!parsed) return null;
  const section = model.sections[parsed.section];
  return section ? section.items[parsed.item] || null : null;
}

/**
 * The selection after tapping item `k` (`CYLTagListView.handleTap(at:)`): selecting an item removes, in its section,
 * every other item in single mode, every other item when it is exclusive, and the exclusive items otherwise; tapping
 * a selected item deselects it when empty selection is allowed or its section keeps another selected item.
 * @returns {{selectedItems: string[], selected: boolean, changed: boolean}}
 */
function tap(model, selectedItems, k) {
  const target = itemAt(model, k);
  if (!target || !target.enabled) return { selectedItems, selected: false, changed: false };
  if (model.selectionMode === 'none') return { selectedItems, selected: true, changed: false };
  const sameSection = (other) => itemAt(model, other) && itemAt(model, other).section === target.section;
  if (selectedItems.includes(k)) {
    const inSection = selectedItems.filter(sameSection).length;
    if (model.allowsEmptySelection || inSection > 1) {
      return { selectedItems: selectedItems.filter((x) => x !== k), selected: false, changed: true };
    }
    return { selectedItems, selected: false, changed: false };
  }
  const kept = selectedItems.filter((other) => {
    if (!sameSection(other)) return true;
    return !(model.selectionMode === 'single' || target.exclusive || itemAt(model, other).exclusive);
  });
  return { selectedItems: [...kept, k], selected: true, changed: true };
}

/**
 * The rows of a section from the measured top of each item (in item order): items with the same top share a row.
 * @param {number[]} tops
 * @returns {number[]} the row index of each item
 */
function rowsFromTops(tops) {
  const rows = [];
  let row = -1;
  let lastTop = null;
  tops.forEach((top) => {
    if (lastTop === null || Math.abs(top - lastTop) > 1) {
      row += 1;
      lastTop = top;
    }
    rows.push(row);
  });
  return rows;
}

/**
 * Whether a section can fold (`canFoldRowCount`: it needs more rows than defaultVisibleRows) and which items stay
 * visible while it is folded.
 * @param {number[]} rows the row index of each item, from rowsFromTops
 * @returns {{canFold: boolean, visible: boolean[]}}
 */
function foldState(model, rows, expanded) {
  const limit = model.defaultVisibleRows;
  const rowCount = rows.length ? rows[rows.length - 1] + 1 : 0;
  const canFold = limit > 0 && rowCount > limit;
  const visible = rows.map((row) => !canFold || expanded || row < limit);
  return { canFold, visible };
}

function foldTitle(expanded) {
  return expanded ? COLLAPSE_TITLE : EXPAND_TITLE;
}

module.exports = {
  DEFAULT_STYLE, EXPAND_TITLE, COLLAPSE_TITLE,
  key, parseKey, imageSize, normalize, sanitizeSelection, itemAt, tap, rowsFromTops, foldState, foldTitle,
};
