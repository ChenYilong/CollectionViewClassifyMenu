// Scenario 2, the search page (CYLSearchCategoryViewController): categories, tags, the job sidebar, the industry
// button and the category tab bar's configuration (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const i18n = require('../miniprogram/utils/i18n.js');
const model = require('../miniprogram/pages/search-category/search-category-model.js');
const tagModel = require('../miniprogram/components/cyl-tag-list/model.js');

test.beforeEach(() => i18n.setLanguage('zh_CN'));

test('the category tab bar has 找人, 动态, 八卦 and 职位 in CYLTabBarController keys', () => {
  const configuration = model.tabBarConfiguration();
  const items = configuration.CYLTabBarControllerTabBarItemsAttributes;
  assert.deepEqual(items.map((item) => item.CYLTabBarItemTitle), ['找人', '动态', '八卦', '职位']);
  assert.deepEqual(items.map((item) => item.CYLTabBarItemIdentifier), ['people', 'feeds', 'gossip', 'jobs']);
  assert.equal(items[0].CYLTabBarItemImage, 'search/tab-people.svg');
  assert.equal(items[0].CYLTabBarItemSelectedImage, 'search/tab-people-fill.svg');
  assert.equal(configuration.CYLTabBarControllerPlusButton, undefined, 'No plus button on the category tab bar');
  i18n.setLanguage('en');
  assert.deepEqual(model.tabBarConfiguration().CYLTabBarControllerTabBarItemsAttributes.map((item) => item.CYLTabBarItemTitle),
    ['People', 'Posts', 'Gossip', 'Jobs']);
});

test('each category has its sections and its placeholder', () => {
  assert.deepEqual(model.sections('people').map((section) => section.title), ['认识同行', '找投资', '谈合作', '挖人才']);
  assert.equal(model.sections('people')[1].titles[1], 'IDG资本');
  assert.equal(model.sections('feeds').length, 1);
  assert.equal(model.sections('feeds')[0].titles.length, 13);
  assert.deepEqual(model.sections('gossip').map((section) => section.title), ['热门词', '我关注的标签']);
  assert.equal(model.sections('gossip')[0].titles[2], '程序猿');
  assert.deepEqual(model.sections('jobs'), []);
  assert.deepEqual([0, 1, 2, 3].map(model.placeholder), ['搜人名,职位,公司...', '搜动态', '搜八卦', '搜职位']);
  assert.equal(model.categoryIndex('gossip'), 2);
  assert.equal(model.categoryIndex('3'), 3);
  assert.equal(model.categoryIndex('unknown'), 0);
  i18n.setLanguage('en');
  assert.equal(model.placeholder(1), 'Search posts');
  assert.equal(model.sections('people')[0].title, 'Meet peers');
  assert.equal(model.sections('people')[0].titles[0], '百度研发', 'Tags are not translated, as on iOS');
});

test('the job sidebar has ten categories; a row shows its keywords under 热搜职位关键词:', () => {
  assert.equal(model.JOB_CATEGORIES.length, 10);
  assert.equal(model.jobSection(0).title, '热搜职位关键词:');
  assert.equal(model.jobSection(0).titles.length, 31);
  assert.equal(model.jobSection(1).titles.length, 7);
  assert.equal(model.jobSection(1).titles[0], '测试工程师');
  assert.equal(model.clampJobCategory(-3), 0);
  assert.equal(model.clampJobCategory(42), 9);
  model.JOB_CATEGORIES.forEach((name) => assert.ok(model.JOB_KEYWORDS[name].length > 0, name));
});

test('the industry button names the industry, without the ▾ for screen readers, and checks it in its menu', () => {
  const button = model.industryButton('金融');
  assert.equal(button.title, '行业: 金融 ▾');
  assert.equal(button.accessibilityLabel, '行业 金融');
  assert.equal(button.accessibilityHint, '选择行业');
  assert.equal(button.menuTitle, '行业');
  assert.deepEqual(button.actions.map((action) => action.title), ['IT互联网', '金融', '教育培训', '医疗健康', '房地产']);
  assert.deepEqual(button.actions.filter((action) => action.on).map((action) => action.industry), ['金融']);
  i18n.setLanguage('en');
  assert.equal(model.industryButton('IT互联网').title, 'Industry: Internet ▾');
});

test('a section is a cyl-tag-list in the Maimai look whose taps select nothing', () => {
  const section = model.sections('people')[1];
  const configuration = model.tagListConfiguration(section);
  // maimaiStyle() in the keys of CYLTagListView(configuration:).
  const style = configuration.style;
  assert.equal(style.itemHeight, 32);
  assert.equal(style.font, 14);
  assert.equal(style.interitemSpacing, 14);
  assert.equal(style.lineSpacing, 14);
  assert.deepEqual(style.sectionInsets, { top: 4, left: 24, bottom: 14, right: 16 });
  assert.deepEqual(style.tagContentInsets, { top: 5, left: 14, bottom: 5, right: 14 });
  assert.equal(style.normal.cornerRadius, 2);
  assert.equal(style.normal.borderColor, '#CCCCCC');
  assert.equal(style.normal.textColor, '#595959');
  assert.deepEqual(model.MAIMAI_HEADER, { height: 32, fontSize: 13, color: '#999999', horizontalInset: 16 });
  const list = tagModel.normalize(configuration);
  assert.equal(list.selectionMode, 'none');
  assert.equal(list.sections.length, 1);
  assert.equal(list.sections[0].title, '', 'The page draws the header');
  assert.deepEqual(list.sections[0].items.map((item) => item.title), section.titles);
  const tap = tagModel.tap(list, [], '0-1');
  assert.equal(tap.changed, false);
  assert.deepEqual(tap.selectedItems, []);
  assert.equal(list.sections[0].items[1].title, 'IDG资本', 'The tapped title fills the search bar');
});
