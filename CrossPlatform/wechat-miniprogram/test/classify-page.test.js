// The classify page's state and saved selections, without wx (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const state = require('../miniprogram/pages/classify/filter.js');
const selections = require('../miniprogram/utils/selections.js');
const db = require('../miniprogram/utils/places-db.js');

test('no selection lists every place', () => {
  const result = state.query([], state.DEFAULT_FILTER);
  assert.equal(result.places.length, 83);
  assert.equal(result.summary, '全部 · 全部 · 全部 · 83');
  assert.equal(result.filtered, false);
});

test('a classify tag and a filter region build the iOS example\'s statement', () => {
  const categories = db.categories();
  const tag = categories[0].tags[1];
  const result = state.query(['0-1'], ['0-3', '1-0']);
  assert.equal(result.tag, tag);
  assert.deepEqual(result.regions, ['广州']);
  assert.deepEqual(result.dishes, []);
  assert.equal(result.sql, 'SELECT name, region, rating, price FROM places WHERE tag = ? AND region IN (?) ORDER BY rating DESC, id');
  assert.ok(result.places.every((p) => p.region === '广州'));
  assert.equal(result.summary, `${tag} · 广州 · 全部 · ${result.places.length}`);
  assert.equal(result.filtered, true);
});

test('a filter that matches nothing lists no place', () => {
  const tags = db.tags();
  const result = state.query(['0-0'], ['0-0', `1-${tags.length}`]);
  assert.equal(result.places.length, 0);
});

test('tapping the selected classify tag again clears it; another tag replaces it across categories', () => {
  assert.deepEqual(state.toggleClassify([], 0, 1), ['0-1']);
  assert.deepEqual(state.toggleClassify(['0-1'], 0, 1), []);
  assert.deepEqual(state.toggleClassify(['0-1'], 2, 0), ['2-0']);
});

test('the filter configuration leads each section with an exclusive 全部', () => {
  const config = state.filterConfiguration(db.tags(), state.DEFAULT_FILTER);
  assert.deepEqual(config.sections.map((s) => s.title), ['地区过滤', '菜品过滤']);
  config.sections.forEach((s) => assert.deepEqual(s.items[0], { title: '全部', exclusive: true }));
  assert.equal(config.sections[0].items.length, db.REGIONS.length + 1);
});

test('selections are saved per scenario and restored, an empty selection included', () => {
  const store = new Map();
  const storage = { get: (k) => store.get(k), set: (k, v) => store.set(k, v) };
  assert.equal(selections.load(selections.CLASSIFY_SCENARIO, storage), null);
  selections.save(selections.CLASSIFY_SCENARIO, ['0-1'], storage);
  selections.save(selections.FILTER_SCENARIO, [], storage);
  assert.deepEqual(selections.load(selections.CLASSIFY_SCENARIO, storage), ['0-1']);
  assert.deepEqual(selections.load(selections.FILTER_SCENARIO, storage), []);
});
