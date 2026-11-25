/**
 * The query scenarios screen as one cyl-tag-list configuration (docs/instructions/examples.md "Sectioned lists in demos
 * use the tag list"), without `wx` calls (node tests): one section per group, each tag shows the scenario's title and
 * icon, a long press shows the group's description (the old section footer) in the list's callout, a tap opens the demo.
 * The database tables are the last section: a tag has the table name and, on a long press, its row count; a tap does
 * nothing, as the old rows did.
 */

/** The demos (CYLQueryScenario), their titles, SF Symbol stand-ins and pages. */
const SCENARIOS = {
  reviewsDatabase: { title: '评价筛选 · 数据库（SQLite）', image: 'cylinder', url: '/pages/reviews/reviews?mode=database' },
  reviewsMemory: { title: '评价筛选 · 内存', image: 'memorychip', url: '/pages/reviews/reviews?mode=memory' },
  reviewsNetwork: { title: '评价筛选 · 网络', image: 'network', url: '/pages/reviews/reviews?mode=network' },
  menuLinkage: { title: '分类菜单 + 多选筛选 · 数据库联动', image: 'grid3x2', url: '/pages/classify/classify' },
  searchDiscover: { title: '最近搜索 + 发现', image: 'magnifyingglass', url: '/pages/search-discover/search-discover' },
};

/** The scenario groups: a title for the section header, a description for the long press, the scenarios. */
const SECTIONS = [
  {
    header: '场景：查询参数设置（多选）',
    footer: '淘宝评价默认显示全部；条件太多时，由用户多选输入筛选条件，标签列表就是为此而做。每次选择后按全部条件（AND）刷新列表。',
    scenarios: ['reviewsDatabase', 'reviewsMemory', 'reviewsNetwork'],
  },
  {
    header: '场景：菜单选择（移植原 Demo）',
    footer: '原 Demo 只实现了筛选界面，没有筛选数据；现在每次选择都会生成 SQL、查询数据库并显示结果，选择也保存在数据库中。',
    scenarios: ['menuLinkage'],
  },
  {
    header: '场景：搜索历史与发现',
    footer: '最近搜索折叠为两行，箭头是最后一个标签；发现每行两个，超出部分显示省略号，右上角的更多按钮随机刷新。数据来自本地 JSON。',
    scenarios: ['searchDiscover'],
  },
];

/** The database section: its header and the tables (the name is the tag's title, the row count its long press text). */
const DATABASE = {
  header: '数据库（SQLite）',
  tables: ['reviews', 'places', 'selections'],
};

/** A section with more rows than this folds behind More / Less (the old rows were never folded; this is the rule). */
const DEFAULT_VISIBLE_ROWS = 2;
/** A title that does not fit one line wraps up to this many lines (the placeholder example uses 3 as well). */
const TITLE_MAX_LINES = 3;
const SELECTION_NONE = 'none';
const LONG_PRESS_CALLOUT = 'callout';
const FOLD_HEADER_TRAILING = 'headerTrailing';
const FOLD_CONTENT_ICON = 'icon';
/** The format of a table's row count, a key of the strings table. */
const ROW_COUNT_FORMAT = '%ld 行';
/** The folder of the icons (the SF Symbol stand-ins). */
const SYMBOL_FOLDER = '/images/symbols/';
const SYMBOL_EXTENSION = '.png';

/**
 * The tag list's configuration.
 * @param {(key: string, ...args: any[]) => string} t the string lookup (utils/i18n.js)
 * @param {{[table: string]: number}} counts the rows of each database table
 */
function configuration(t, counts) {
  const scenarioSections = SECTIONS.map((section) => ({
    title: t(section.header),
    items: section.scenarios.map((key) => ({
      title: t(SCENARIOS[key].title),
      image: `${SYMBOL_FOLDER}${SCENARIOS[key].image}${SYMBOL_EXTENSION}`,
      subtitle: t(section.footer),
    })),
  }));
  const databaseSection = {
    title: t(DATABASE.header),
    items: DATABASE.tables.map((table) => ({ title: table, subtitle: t(ROW_COUNT_FORMAT, counts[table] || 0) })),
  };
  return {
    selectionMode: SELECTION_NONE,
    defaultVisibleRows: DEFAULT_VISIBLE_ROWS,
    foldControl: { position: FOLD_HEADER_TRAILING, content: FOLD_CONTENT_ICON },
    longPressAction: LONG_PRESS_CALLOUT,
    style: { titleMaxLines: TITLE_MAX_LINES },
    sections: scenarioSections.concat([databaseSection]),
  };
}

/** The page a tag opens, or null (the database tables open nothing). */
function urlFor(section, item) {
  const group = SECTIONS[section];
  if (!group || !group.scenarios[item]) return null;
  return SCENARIOS[group.scenarios[item]].url;
}

module.exports = {
  SCENARIOS, SECTIONS, DATABASE, DEFAULT_VISIBLE_ROWS, TITLE_MAX_LINES, configuration, urlFor,
};
