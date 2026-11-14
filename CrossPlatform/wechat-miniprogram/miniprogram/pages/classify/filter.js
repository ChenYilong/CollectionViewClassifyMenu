/**
 * The classify page's state, without `wx`, so the tests can run it: the classify menu's single choice, the multiple
 * filter (regions and dishes, each section led by an exclusive 全部) and the statement they build, as in the Flutter
 * example's `ClassifyMenuPage` and the iOS example's `CYLMenuLinkageViewController`.
 */
const db = require('../../utils/places-db.js');

const DEFAULT_FILTER = ['0-0', '1-0'];

const STYLE = {
  itemHeight: 32,
  normal: { cornerRadius: 16, borderColor: '#D1D1D6', borderWidth: 1 },
  selected: { cornerRadius: 16, backgroundColor: '#E6F8F5', textColor: '#2AB9A0', borderColor: '#2AB9A0' },
};

function parse(value) {
  const parts = String(value || '').split('-').map(Number);
  return parts.length === 2 && parts.every(Number.isInteger) ? parts : null;
}

/** The tag of the classify selection ("<section>-<item>", at most one), or null for every tag. */
function selectedTag(classifyItems, categories) {
  const parts = parse(classifyItems[0]);
  if (!parts) return null;
  const category = categories[parts[0]];
  return (category && category.tags[parts[1]]) || null;
}

/** The titles the filter selects in `section`, without 全部 (item 0). */
function filterTitles(filterItems, section, titles) {
  const result = [];
  filterItems.forEach((value) => {
    const parts = parse(value);
    if (!parts || parts[0] !== section || parts[1] === 0) return;
    const title = titles[parts[1] - 1];
    if (title) result.push(title);
  });
  return result;
}

/** The classify menu's configuration: one section per category, single choice, folded to one row. */
function classifyConfiguration(categories, classifyItems) {
  return {
    selectionMode: 'single',
    allowsEmptySelection: true,
    selectedItems: classifyItems,
    defaultVisibleRows: 1,
    foldControl: { position: 'headerTrailing', content: 'iconAndTitle' },
    style: STYLE,
    sections: categories.map((category) => ({
      title: category.title,
      items: category.tags.map((title) => ({ title })),
    })),
  };
}

/** The multiple filter: 地区过滤 and 菜品过滤, each led by an exclusive 全部. */
function filterConfiguration(tags, filterItems) {
  return {
    selectionMode: 'multiple',
    selectedItems: filterItems,
    defaultVisibleRows: 2,
    foldControl: { position: 'headerTrailing', content: 'iconAndTitle' },
    style: STYLE,
    sections: [['地区过滤', db.REGIONS], ['菜品过滤', tags]].map(([title, titles]) => ({
      title,
      items: [{ title: '全部', exclusive: true }, ...titles.map((t) => ({ title: t }))],
    })),
  };
}

/** Everything the page shows for a classify selection and a filter selection. */
function query(classifyItems, filterItems, categories = db.categories(), tags = db.tags()) {
  const conditions = {
    tag: selectedTag(classifyItems, categories),
    regions: filterTitles(filterItems, 0, db.REGIONS),
    dishes: filterTitles(filterItems, 1, tags),
  };
  const places = db.places(conditions);
  const names = (values) => (values.length ? values.join('、') : '全部');
  return {
    ...conditions,
    places,
    sql: db.statement(conditions).sql,
    filtered: conditions.regions.length > 0 || conditions.dishes.length > 0,
    summary: `${conditions.tag || '全部'} · ${names(conditions.regions)} · ${names(conditions.dishes)} · ${places.length}`,
  };
}

/** The classify selection after a tap: the tapped tag alone, or none when it was the selected one. */
function toggleClassify(classifyItems, section, item) {
  const k = `${section}-${item}`;
  return classifyItems.includes(k) ? [] : [k];
}

module.exports = {
  DEFAULT_FILTER, STYLE, selectedTag, filterTitles, classifyConfiguration, filterConfiguration, query, toggleClassify,
};
