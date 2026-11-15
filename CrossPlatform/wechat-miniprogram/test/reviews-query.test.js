// The review filter's store and queries (CYLReviewStore.swift, CYLReviewQuery.swift), without wx (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const store = require('../miniprogram/pages/reviews/store.js');
const q = require('../miniprogram/pages/reviews/query.js');

const f = (...indexes) => indexes.map((i) => store.filters[i]);
const ids = (reviews) => reviews.map((r) => r.id);

function fetch(query, filters) {
  let result = null;
  query.fetchReviewsMatching(filters, (reviews) => { result = reviews; });
  return result;
}

test('the filters and their titles are those of CYLReviewStore', () => {
  assert.equal(store.reviews.length, 10);
  assert.deepEqual(store.filters.map((x) => x.identifier), [
    'all', 'good', 'neutral', 'bad', 'photo', 'followup',
    'keyword:手机套不错', 'keyword:质量不错', 'keyword:态度不错', 'keyword:划算', 'keyword:颜色不错', 'keyword:背面细节一般',
  ]);
  assert.deepEqual(store.filters.map(store.title), [
    '全部', '好评(9)', '中评(1)', '差评(0)', '有图(4)', '追加(3)',
    '手机套不错(3)', '质量不错(5)', '态度不错(3)', '划算(3)', '颜色不错(2)', '背面细节一般(2)',
  ]);
  assert.deepEqual(store.filters.filter((x) => x.image).map((x) => x.symbol),
    ['hand.thumbsup.fill', 'hand.raised.fill', 'hand.thumbsdown.fill']);
});

// The rows of the shared SQLite database for each statement (checked with sqlite3 on cyl_places.sqlite).
const CASES = [
  { filters: [], sql: 'SELECT r.id FROM reviews r ORDER BY r.id', ids: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] },
  { filters: [1], sql: 'SELECT r.id FROM reviews r WHERE r.rating = ? ORDER BY r.id', args: [0], ids: [0, 1, 2, 3, 4, 6, 7, 8, 9] },
  { filters: [2], args: [1], ids: [5] },
  { filters: [3], args: [2], ids: [] },
  { filters: [4], sql: 'SELECT r.id FROM reviews r WHERE r.has_photo = 1 ORDER BY r.id', ids: [0, 3, 4, 7] },
  { filters: [5], sql: 'SELECT r.id FROM reviews r WHERE r.has_follow_up = 1 ORDER BY r.id', ids: [2, 4, 8] },
  { filters: [1, 4], sql: 'SELECT r.id FROM reviews r WHERE r.rating = ? AND r.has_photo = 1 ORDER BY r.id', args: [0], ids: [0, 3, 4, 7] },
  {
    filters: [6, 7],
    sql: 'SELECT r.id FROM reviews r WHERE EXISTS (SELECT 1 FROM review_keywords k WHERE k.review_id = r.id AND k.keyword = ?) '
      + 'AND EXISTS (SELECT 1 FROM review_keywords k WHERE k.review_id = r.id AND k.keyword = ?) ORDER BY r.id',
    args: ['手机套不错', '质量不错'],
    ids: [0],
  },
  { filters: [5, 8], ids: [8] },
  { filters: [2, 11], args: [1, '背面细节一般'], ids: [5] },
  { filters: [1, 4, 5], ids: [4] },
  { filters: [9, 10], ids: [] },
];

test('database: the same statement and rows as CYLDatabaseReviewQuery', () => {
  CASES.forEach((c) => {
    const query = q.databaseQuery(f(...c.filters));
    if (c.sql) assert.equal(query.sql, c.sql);
    if (c.args) assert.deepEqual(query.arguments, c.args);
    assert.deepEqual(q.runStatement(query).map((row) => row.id), c.ids, `filters ${c.filters}`);
    const database = new q.DatabaseReviewQuery();
    assert.deepEqual(ids(fetch(database, f(...c.filters))), c.ids);
    assert.equal(database.lastQuery.sql, query.sql);
    assert.equal(database.isLoading, false);
  });
});

test('database: the displayed statement fills in the arguments', () => {
  assert.equal(q.databaseQuery(f(1, 4)).displayString(),
    'SELECT r.id FROM reviews r WHERE r.rating = 0 AND r.has_photo = 1 ORDER BY r.id');
  assert.equal(q.displayString('a = ? AND b = ? AND c = ?', ["it's", 3]), "a = 'it''s' AND b = 3 AND c = NULL");
  assert.throws(() => q.runStatement({ conditions: ['r.unknown = 1'], arguments: [] }));
});

test('memory: the same reviews as the database, synchronously', () => {
  CASES.forEach((c) => {
    const memory = new q.MemoryReviewQuery();
    assert.deepEqual(ids(fetch(memory, f(...c.filters))), c.ids);
    assert.equal(memory.isLoading, false);
  });
});

test('network: the request URL and the simulated server', () => {
  assert.equal(q.requestURL([]), 'https://api.example.com/reviews');
  assert.equal(q.requestURL(f(1, 4)), 'https://api.example.com/reviews?filter=good&filter=photo');
  const keyword = q.requestURL(f(9));
  assert.equal(keyword, `https://api.example.com/reviews?filter=keyword:${encodeURIComponent('划算')}`);
  assert.equal(q.requestDisplay(keyword), 'GET /reviews?filter=keyword:划算');
  assert.equal(q.requestDisplay(q.requestURL([])), 'GET /reviews');
  CASES.forEach((c) => {
    assert.deepEqual(ids(q.reviewsForRequestURL(q.requestURL(f(...c.filters)))), c.ids);
  });
});

test('network: loading after 0.6 s, older responses dropped', () => {
  const pending = [];
  const network = new q.NetworkReviewQuery((fn, ms) => pending.push({ fn, ms }));
  const results = [];
  network.fetchReviewsMatching(f(1), (reviews) => results.push(ids(reviews)));
  assert.equal(network.isLoading, true);
  network.fetchReviewsMatching(f(1, 4), (reviews) => results.push(ids(reviews)));
  assert.equal(network.requestCount, 2);
  assert.equal(network.lastRequestURL, 'https://api.example.com/reviews?filter=good&filter=photo');
  assert.deepEqual(pending.map((p) => p.ms), [600, 600]);
  pending[0].fn();
  assert.equal(network.droppedResponseCount, 1);
  assert.equal(network.isLoading, true);
  assert.deepEqual(results, []);
  pending[1].fn();
  assert.equal(network.isLoading, false);
  assert.deepEqual(results, [[0, 3, 4, 7]]);
  // A cancelled query (replaced, or its page closed) calls nothing.
  network.fetchReviewsMatching([], () => results.push('late'));
  network.cancel();
  pending[2].fn();
  assert.equal(results.length, 1);
});

test('modes: names, raw values and the query for each', () => {
  assert.deepEqual(q.MODES, ['memory', 'network', 'database']);
  assert.equal(q.parseMode(undefined), 'memory');
  assert.equal(q.parseMode('database'), 'database');
  assert.equal(q.parseMode('1'), 'network');
  assert.equal(q.parseMode('other'), 'memory');
  assert.equal(q.modeIndex('database'), 2);
  assert.ok(q.queryFor('network') instanceof q.NetworkReviewQuery);
  assert.ok(q.queryFor('database') instanceof q.DatabaseReviewQuery);
  assert.ok(q.queryFor('memory') instanceof q.MemoryReviewQuery);
});

test('status: the lines of updateStatus() in each mode', () => {
  const memory = q.statusLines({ mode: 'memory', lastEvent: '点击「划算(3)」', selectedFilters: f(9), count: 3 });
  assert.deepEqual(memory, ['点击「划算(3)」 · 已选：划算', '内存筛选：在已加载的评价中立即匹配 · 匹配 3 条']);

  const database = new q.DatabaseReviewQuery();
  fetch(database, f(1, 4));
  assert.deepEqual(q.statusLines({ mode: 'database', query: database, lastEvent: '点击「有图(4)」', selectedFilters: f(1, 4), count: 4 }), [
    '点击「有图(4)」 · 已选：好评、有图',
    '数据库筛选：条件生成 SQL，在 SQLite 中查询 · 匹配 4 条',
    'SELECT r.id FROM reviews r WHERE r.rating = 0 AND r.has_photo = 1 ORDER BY r.id',
  ]);

  const pending = [];
  const network = new q.NetworkReviewQuery((fn) => pending.push(fn));
  network.fetchReviewsMatching(f(1, 4), () => {});
  const loading = q.statusLines({ mode: 'network', query: network, lastEvent: '点击「有图(4)」', selectedFilters: f(1, 4), count: 0 });
  assert.deepEqual(loading.slice(1), ['网络筛选：向服务器发送条件 · GET /reviews?filter=good&filter=photo', '加载中…']);
  pending[0]();
  const done = q.statusLines({ mode: 'network', query: network, lastEvent: '', selectedFilters: [], count: 4 });
  assert.deepEqual(done, [' · 已选：全部', '网络筛选：向服务器发送条件 · GET /reviews?filter=good&filter=photo', '服务器返回 4 条']);
});
