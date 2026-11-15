// 分类菜单 + 多选筛选 · 数据库联动, 1:1 with the iOS example's CYLMenuLinkageViewController (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const m = require('../miniprogram/pages/classify/menu-linkage.js');
const i18n = require('../miniprogram/utils/i18n.js');

test('the classify menu is data.json and the filter is regions and every tag, each led by 全部', () => {
  assert.deepEqual(m.CLASSIFY.map((s) => s.title), ['吃', '喝', '玩', '逛']);
  assert.equal(m.CLASSIFY[0].items[0].title, '云南味道 扩展文字😀✨');
  assert.equal(m.CLASSIFY[0].items[0].picture, true);
  assert.deepEqual(m.FILTER.map((s) => s.title), ['地区过滤', '菜品过滤']);
  assert.deepEqual(m.FILTER[0].items, ['全部', '北京 🏙️ 扩展文字', '上海', '广州', '深圳']);
  assert.equal(m.FILTER[1].items.length, m.ALL_TAGS.length + 1);
  assert.equal(new Set(m.ALL_TAGS).size, m.ALL_TAGS.length);
});

test('the filter taps follow CYLMultipleFilterController', () => {
  let s = m.selectionOf(m.DEFAULT_FILTER);
  s = m.tapFilter(s, 0, 2); // 上海
  assert.deepEqual(m.keysOf(s), ['0-2', '1-0']);
  s = m.tapFilter(s, 0, 4); // 深圳
  assert.deepEqual(m.keysOf(s), ['0-2', '0-4', '1-0']);
  s = m.tapFilter(s, 0, 2);
  s = m.tapFilter(s, 0, 4); // nothing left: back to 全部
  assert.deepEqual(m.keysOf(s), ['0-0', '1-0']);
  s = m.tapFilter(m.tapFilter(s, 1, 3), 1, 0); // 全部 alone again
  assert.deepEqual(m.keysOf(s), ['0-0', '1-0']);
  assert.equal(m.isValidFilterSelection(['0-0', '0-1']), false);
  assert.equal(m.isValidFilterSelection(['0-1', '0-2', '1-0']), true);
});

test('plus-menu-filtered: 吃 · 川菜, in 上海 or 深圳, dishes 川菜 or 特色火锅 (the iOS screenshot)', () => {
  const tag = m.classifyTitle('0-1');
  const { regions, dishes } = m.conditionsOf(['0-2', '0-4', '1-2', '1-3']);
  assert.equal(tag, '川菜 扩展文字😀✨');
  assert.deepEqual(regions, ['上海', '深圳']);
  assert.deepEqual(dishes, ['川菜 扩展文字😀✨', '特色火锅 扩展文字😀✨']);
  i18n.setLanguage('en');
  const r = m.results(i18n.t, tag, regions, dishes);
  assert.equal(r.status.split('\n')[0], 'Category: 川菜 · Regions: 上海, 深圳 · Dishes: 川菜, 特色火锅');
  assert.equal(r.status.split('\n')[1], "SELECT name, category, tag, region, rating, price FROM places WHERE tag = '川菜 扩展文字😀✨' "
    + "AND region IN ('上海', '深圳') AND tag IN ('川菜 扩展文字😀✨', '特色火锅 扩展文字😀✨') ORDER BY rating DESC, id");
  assert.equal(r.status.split('\n')[2], 'SQLite returned 1 (of 83 places)');
  assert.deepEqual(r.rows, [{ id: r.rows[0].id, title: '川菜 · 深圳', detail: '吃 · 川菜 · 深圳 · ★3.5 · ¥226' }]);
  i18n.setLanguage('zh_CN');
});

test('no condition lists all 83, and no match says 没有符合条件的商家', () => {
  i18n.setLanguage('zh_CN');
  const all = m.results(i18n.t, null, [], []);
  assert.equal(all.rows.length, 83);
  assert.equal(all.status.split('\n')[0], '分类：全部 · 地区：全部 · 菜品：全部');
  assert.equal(all.empty, null);
  const none = m.results(i18n.t, m.classifyTitle('0-0'), [], [m.ALL_TAGS[1]]);
  assert.equal(none.rows.length, 0);
  assert.equal(none.empty, '没有符合条件的商家');
});

test('displayString quotes strings and doubles quotes', () => {
  assert.equal(m.displayString({ sql: 'a = ? AND b = ? AND c = ?', args: ["it's", 3] }), "a = 'it''s' AND b = 3 AND c = NULL");
  assert.equal(m.toggleClassify('0-1', '0-1'), null);
  assert.equal(m.toggleClassify('0-1', '2-0'), '2-0');
  assert.equal(m.shortTitle('北京 🏙️ 扩展文字'), '北京');
});
