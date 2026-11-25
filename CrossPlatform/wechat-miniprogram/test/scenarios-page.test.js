// The query scenarios screen as a cyl-tag-list (miniprogram/pages/scenarios): sections, titles, subtitles, the fold
// limit and what a tap does (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');
const i18n = require('../miniprogram/utils/i18n.js');
const scenarios = require('../miniprogram/pages/scenarios/scenarios-model.js');
const tagModel = require('cyl-tag-list-miniprogram/cyl-tag-list/model.js');

const COUNTS = { reviews: 12, places: 34, selections: 5 };
const PAGE_FILE = path.join(__dirname, '..', 'miniprogram', 'pages', 'scenarios', 'scenarios.js');
const DATABASE_SECTION = 3;

test.beforeEach(() => i18n.setLanguage('zh_CN'));

function configuration() {
  return scenarios.configuration(i18n.t, COUNTS);
}

test('one section per group, each with a title, the scenarios then the database tables', () => {
  const sections = configuration().sections;
  assert.deepEqual(sections.map((section) => section.title),
    ['场景：查询参数设置（多选）', '场景：菜单选择（移植原 Demo）', '场景：搜索历史与发现', '数据库（SQLite）']);
  sections.forEach((section) => assert.ok(section.title.length > 0));
  assert.deepEqual(sections.map((section) => section.items.length), [3, 1, 1, 3]);
  assert.deepEqual(sections[0].items.map((item) => item.title),
    ['评价筛选 · 数据库（SQLite）', '评价筛选 · 内存', '评价筛选 · 网络']);
});

test('a tag has its title and icon; the group description is its long press text', () => {
  const [first, , , database] = configuration().sections;
  assert.equal(first.items[0].image, '/images/symbols/cylinder.png');
  first.items.forEach((item) => assert.equal(item.subtitle, scenarios.SECTIONS[0].footer));
  assert.deepEqual(database.items.map((item) => item.title), ['reviews', 'places', 'selections']);
  assert.deepEqual(database.items.map((item) => item.subtitle), ['12 行', '34 行', '5 行']);
  i18n.setLanguage('en');
  assert.equal(scenarios.configuration(i18n.t, COUNTS).sections[3].items[0].subtitle, '12 rows');
});

test('the list folds sections of more than two rows behind More / Less in the header, wraps titles to 3 lines', () => {
  const normalized = tagModel.normalize(configuration());
  assert.equal(scenarios.DEFAULT_VISIBLE_ROWS, 2);
  assert.equal(normalized.defaultVisibleRows, 2);
  assert.equal(normalized.foldControl.position, 'tail');
  assert.equal(normalized.foldControl.content, 'icon');
  assert.equal(normalized.selectionMode, 'none');
  assert.deepEqual(normalized.longPressActions, ['callout', 'report']);
  assert.equal(normalized.style.titleMaxLines, 3);
  assert.equal(normalized.style.itemsPerRow, 0, 'The tag width is adaptive');
  assert.equal(normalized.sections[0].items[0].subtitle, scenarios.SECTIONS[0].footer);
});

test('a tap opens the scenario of the old row; a database table opens nothing; the tag does not stay selected', () => {
  assert.equal(scenarios.urlFor(0, 0), '/pages/reviews/reviews?mode=database');
  assert.equal(scenarios.urlFor(0, 2), '/pages/reviews/reviews?mode=network');
  assert.equal(scenarios.urlFor(1, 0), '/pages/classify/classify');
  assert.equal(scenarios.urlFor(2, 0), '/pages/search-discover/search-discover');
  assert.equal(scenarios.urlFor(DATABASE_SECTION, 0), null);
  assert.equal(scenarios.urlFor(9, 0), null);
  const normalized = tagModel.normalize(configuration());
  const result = tagModel.tap(normalized, [], '0-0');
  assert.equal(result.changed, false);
  assert.deepEqual(result.selectedItems, []);
});

test('the page navigates on tagtap and builds the configuration on show', () => {
  let definition;
  const navigated = [];
  global.Page = (def) => { definition = def; };
  global.wx = { getStorageInfoSync: () => ({ keys: [] }), getStorageSync: () => '', navigateTo: (options) => navigated.push(options.url), setNavigationBarTitle() {} };
  delete require.cache[require.resolve(PAGE_FILE)];
  require(PAGE_FILE);
  const page = { ...definition, data: { ...definition.data }, setData(patch) { Object.assign(this.data, patch); } };
  page.onShow();
  assert.equal(page.data.configuration.sections.length, 4);
  page.onTagTap({ detail: { section: 1, item: 0 } });
  page.onTagTap({ detail: { section: DATABASE_SECTION, item: 1 } });
  assert.deepEqual(navigated, ['/pages/classify/classify']);
});
