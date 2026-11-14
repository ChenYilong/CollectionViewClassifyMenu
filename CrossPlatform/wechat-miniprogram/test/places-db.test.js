// The places module: the rows of the shared database and the iOS example's statement (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const db = require('../miniprogram/utils/places-db.js');

test('the module holds the 83 places of cyl_places.sqlite in database order', () => {
  assert.equal(db.ROWS.length, 83);
  assert.deepEqual(db.ROWS.map((r) => r.id), db.ROWS.map((_, i) => db.ROWS[0].id + i));
});

test('the categories are 吃喝玩逛 in the order of their first place', () => {
  assert.deepEqual(db.categories().map((c) => c.title), ['吃', '喝', '玩', '逛']);
  // GROUP BY category, tag: a tag of two categories is listed in both (31 entries, 28 distinct tags).
  const tags = db.categories().flatMap((c) => c.tags);
  assert.equal(tags.length, 31);
  assert.deepEqual([...new Set(tags)].sort(), [...db.tags()].sort());
  assert.equal(db.tags().length, 28);
});

test('every place, best rated first, then by id (日式拉面 · 北京 first, as on iOS and Android)', () => {
  const places = db.places();
  assert.equal(places.length, 83);
  assert.equal(places[0].name, '日式拉面 · 北京');
  assert.equal(places[0].rating, 5);
  assert.equal(places[0].price, 93);
  for (let i = 1; i < places.length; i += 1) {
    const [a, b] = [places[i - 1], places[i]];
    assert.ok(a.rating > b.rating || (a.rating === b.rating && a.id < b.id));
  }
});

test('the statement is the iOS example\'s, with one placeholder per value', () => {
  assert.equal(db.statement().sql, 'SELECT name, region, rating, price FROM places ORDER BY rating DESC, id');
  const { sql, args } = db.statement({ tag: '川菜', regions: ['上海', '广州'], dishes: ['川菜'] });
  assert.equal(sql, 'SELECT name, region, rating, price FROM places WHERE tag = ? AND region IN (?, ?) AND tag IN (?) '
    + 'ORDER BY rating DESC, id');
  assert.deepEqual(args, ['川菜', '上海', '广州', '川菜']);
});

test('a tag, regions and dishes are ANDed', () => {
  const tag = db.tags()[1];
  const byTag = db.places({ tag });
  assert.ok(byTag.length > 0 && byTag.length < 83);
  const inGuangzhou = db.places({ tag, regions: ['广州'] });
  assert.ok(inGuangzhou.every((p) => p.region === '广州'));
  assert.deepEqual(db.places({ tag, dishes: [db.tags()[0]] }), []);
});
