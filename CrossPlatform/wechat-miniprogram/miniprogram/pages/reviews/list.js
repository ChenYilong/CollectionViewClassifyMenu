/**
 * The review list's state without `wx` (node --test): the filter style of CYLReviewListViewController.reviewFilterStyle()
 * as a `cyl-tag-list` configuration, the filter items, the selection rules the page applies itself
 * (`selectItem(at:)`, "nothing selected shows 全部"), the selected filters in the order of
 * `CYLTagListView.selectedIndexPaths` (ascending) and the launch options.
 */
const store = require('./store.js');
const { t, language } = require('../../utils/i18n.js');

const ORANGE = '#FF4F00'; // UIColor(red: 1, green: 0.31, blue: 0)

/**
 * reviewFilterStyle(): 12 pt titles (white 0.3, selected white, disabled white 0.7), 13 × 13 icons 3 from the title,
 * boxes with corner radius 2, margin 8, a 0.5 border (white 0.88) on white 0.96, selected orange; 28 high tags, 8
 * between tags, 10 between lines, section insets {10, 12, 6, 12}.
 */
function reviewFilterStyle(overrides = {}) {
  const box = { cornerRadius: 2, borderWidth: 0.5, borderColor: '#E0E0E0', backgroundColor: '#F5F5F5' };
  return {
    backgroundStyle: 'liquidGlass',
    itemHeight: 28,
    imageSize: 13,
    imageTitleSpacing: 3,
    interitemSpacing: 8,
    lineSpacing: 10,
    font: 12,
    sectionInsets: { top: 10, left: 12, bottom: 6, right: 12 },
    tagContentInsets: { top: 5, left: 8, bottom: 5, right: 8 },
    normal: { ...box, textColor: '#4D4D4D' },
    selected: { ...box, textColor: '#FFFFFF', backgroundColor: ORANGE, borderColor: ORANGE },
    ...overrides,
  };
}

/** foldControlColor: UIColor(white: 0.45). */
const FOLD_CONTROL_COLOR = '#737373';

/** The filter items: title with count, icon, enabled when some review matches, 全部 exclusive. */
function filterItems() {
  return store.filters.map((f) => ({
    title: store.title(f),
    image: f.image,
    enabled: store.reviewsMatching(f).length > 0,
    exclusive: f.identifier === 'all',
  }));
}

/**
 * The filter list's configuration: multiple choice, no section header (showsSectionHeaders = false), folded to two
 * rows; `expanded` shows every row. The fold control (the chevron below the tags, CYLMenuFoldControl(position:
 * .footer, content: .icon)) is the component's footer fold control in FOLD_CONTROL_COLOR; the page expands it with
 * setExpanded() and selects with setSelectedItems(), so the list is built and measured once.
 */
function filterConfiguration(selection) {
  return {
    selectionMode: 'multiple',
    allowsEmptySelection: true,
    selectedItems: selection.slice(),
    defaultVisibleRows: 2,
    foldControl: { position: 'footer', content: 'icon', color: FOLD_CONTROL_COLOR },
    style: reviewFilterStyle(),
    sections: [{ title: '', items: filterItems() }],
  };
}

function itemIndex(key) {
  return Number(String(key).split('-')[1]);
}

/** `CYLTagListView.selectItem(at:)`: selects the item, removing 全部 (exclusive) or, for 全部, every other item. */
function selectItem(selection, index) {
  if (!Number.isInteger(index) || index < 0 || index >= store.filters.length) return selection;
  const key = `0-${index}`;
  const exclusive = store.filters[index].identifier === 'all';
  const kept = selection.filter((other) => other !== key
    && !(exclusive || store.filters[itemIndex(other)].identifier === 'all'));
  return [...kept, key];
}

/** Selected keys in ascending order (selectedIndexPaths). */
function sortedSelection(selection) {
  return selection.slice().sort((a, b) => itemIndex(a) - itemIndex(b));
}

/** The filters of the selection, without 全部 (no condition). */
function selectedFilters(selection) {
  return sortedSelection(selection)
    .map((key) => store.filters[itemIndex(key)])
    .filter((f) => f && f.identifier !== 'all');
}

/** The initial filter index (CYLReviewListViewController(selectedFilterIndex:)), clamped to the filters. */
function initialIndex(value) {
  const n = Number(value);
  const index = Number.isFinite(n) ? Math.trunc(n) : 0;
  return Math.max(0, Math.min(index, store.filters.length - 1));
}

/** `select=1,4` (selectFilterIndexes), URL-encoded or not. */
function parseIndexes(value) {
  if (value == null || value === '') return [];
  return decodeURIComponent(String(value)).split(',').map((s) => Number(s.trim())).filter(Number.isInteger);
}

/** A review cell (UIListContentConfiguration.subtitleCell()): the user, then the text and "date sku". */
function reviewRow(review) {
  const secondary = `${review.text}\n${review.date} ${review.sku}`;
  return { id: review.id, user: review.user, secondary, label: `${review.user}, ${secondary}` };
}

/** The core's CYLMenuExpand / CYLMenuCollapse (CYLClassifyMenu.strings), the fold control's action. */
const CORE_TABLES = require('cyl-tag-list-miniprogram/core-tables.js');
const FOLD_TITLES = Object.fromEntries(Object.entries(CORE_TABLES)
  .map(([lang, table]) => [lang, [table.CYLMenuExpand, table.CYLMenuCollapse]]));

/** The fold control's VoiceOver label (foldAccessibilityLabel): "<section title> <expand or collapse title>". */
function foldAccessibilityLabel(expanded, lang = language()) {
  const titles = FOLD_TITLES[lang] || FOLD_TITLES['zh-Hans'];
  return `${t('评价')} ${titles[expanded ? 1 : 0]}`;
}

module.exports = {
  foldAccessibilityLabel,
  ORANGE, FOLD_CONTROL_COLOR, reviewFilterStyle, filterItems, filterConfiguration, selectItem, sortedSelection,
  selectedFilters, initialIndex, parseIndexes, reviewRow,
};
