// The search history and discover screen (CYLSearchDiscoverViewController, CYLSearchDiscoverData): the JSON data,
// the seeded random selection (the Swift generators), searching, and the folded recent searches (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const i18n = require('../miniprogram/utils/i18n.js');
const model = require('../miniprogram/pages/search-discover/discover-model.js');

test.beforeEach(() => i18n.setLanguage('zh_CN'));

// References with BigInt (Node has it; the Mini Program code does not use it).
const MASK = (1n << 64n) - 1n;
function splitMix64Reference(seed) {
  let state = BigInt(seed) & MASK;
  return () => {
    state = (state + 0x9E3779B97F4A7C15n) & MASK;
    let z = state;
    z = ((z ^ (z >> 30n)) * 0xBF58476D1CE4E5B9n) & MASK;
    z = ((z ^ (z >> 27n)) * 0x94D049BB133111EBn) & MASK;
    return z ^ (z >> 31n);
  };
}
function nextBelowReference(next, upperBound) {
  const bound = BigInt(upperBound);
  let m = next() * bound;
  if ((m & MASK) < bound) {
    const t = ((1n << 64n) - bound) % bound;
    while ((m & MASK) < t) m = next() * bound;
  }
  return Number(m >> 64n);
}

test('the data comes from the JSON file of the language, else the Simplified Chinese one', () => {
  const data = model.bundled('zh-Hans');
  assert.equal(data.recentSearches.length, 10);
  assert.equal(data.discover.length, 24);
  assert.equal(data.discoverCount, 6);
  assert.deepEqual(model.initialTopics(data), data.discover.slice(0, 6));
  assert.ok(data.discover.some((topic) => topic.icon === 'hot'), 'Some topics have the 热 icon');
  for (const language of ['en', 'zh-Hant']) {
    const other = model.bundled(language);
    assert.equal(other.recentSearches.length, 10, language);
    assert.deepEqual(other.discover.map((topic) => topic.icon || null), data.discover.map((topic) => topic.icon || null),
      `${language}: the same topics in the same order`);
  }
  assert.equal(model.bundled('en').discover[0].title, 'Spring camping gear checklist');
  assert.deepEqual(model.bundled('fr'), data);
  assert.equal(model.hotIcon('en').src, '/images/search/discover-hot-en.png');
  assert.equal(model.hotIcon('en').width, 30);
  assert.equal(model.hotIcon('zh-Hant').width, 18);
});

test('CYLSeededRandomNumberGenerator is SplitMix64', () => {
  // The published first output of SplitMix64 seeded with 0.
  assert.equal(model.u64Hex(new model.SeededRandomNumberGenerator(0).next()), '0xe220a8397b1dcdaf');
  for (const seed of [0, 1, 7, 123456789, 2 ** 40 + 3]) {
    const generator = new model.SeededRandomNumberGenerator(seed);
    const reference = splitMix64Reference(seed);
    for (let i = 0; i < 50; i += 1) {
      assert.equal(model.u64Hex(generator.next()), `0x${reference().toString(16).padStart(16, '0')}`, `seed ${seed} #${i}`);
    }
  }
});

test('next(upperBound:) and shuffled(using:) are those of the Swift standard library', () => {
  for (const seed of [1, 7, 99]) {
    const generator = new model.SeededRandomNumberGenerator(seed);
    const reference = splitMix64Reference(seed);
    for (const bound of [1, 2, 3, 6, 7, 18, 24, 1000, 2 ** 31 + 11]) {
      assert.equal(model.nextBelow(generator, bound), nextBelowReference(reference, bound), `seed ${seed} bound ${bound}`);
    }
  }
  // Fisher-Yates from the front, as Array.shuffle(using:).
  const reference = splitMix64Reference(7);
  const expected = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  for (let amount = expected.length, current = 0; amount > 1; amount -= 1, current += 1) {
    const other = current + nextBelowReference(reference, amount);
    [expected[current], expected[other]] = [expected[other], expected[current]];
  }
  assert.deepEqual(model.shuffled([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], new model.SeededRandomNumberGenerator(7)), expected);
  assert.throws(() => model.nextBelow(new model.SeededRandomNumberGenerator(1), 0), RangeError);
});

test('the More button picks another selection; seeded, it is repeatable', () => {
  const data = model.bundled('zh-Hans');
  const initial = model.initialTopics(data);
  const refreshed = model.randomTopics(data, initial, new model.SeededRandomNumberGenerator(7));
  assert.equal(refreshed.length, 6);
  assert.equal(new Set(refreshed.map((topic) => topic.title)).size, 6, 'No topic twice');
  assert.ok(refreshed.every((topic) => !initial.some((shown) => model.sameTopic(shown, topic))), 'Another selection');
  assert.deepEqual(model.randomTopics(data, initial, new model.SeededRandomNumberGenerator(7)), refreshed, 'Seeded: repeatable');
  assert.notDeepEqual(model.randomTopics(data, initial, new model.SeededRandomNumberGenerator(1)), initial);
  // A small pool fills up with topics shown now.
  const small = { ...data, discover: data.discover.slice(0, 8) };
  const filled = model.randomTopics(small, model.initialTopics(small), new model.SeededRandomNumberGenerator(3));
  assert.equal(filled.length, 6);
  assert.equal(new Set(filled.map((topic) => topic.title)).size, 6);
  assert.ok(filled.some((topic) => topic.title === data.discover[6].title) && filled.some((topic) => topic.title === data.discover[7].title),
    'Both topics that were not shown come first');
  assert.deepEqual(model.randomTopics(model.EMPTY, [], new model.SeededRandomNumberGenerator(1)), []);
});

test('a search moves the trimmed query to the front of the recent searches', () => {
  const searches = ['a', 'b', 'c'];
  assert.deepEqual(model.search(searches, '  c '), { query: 'c', searches: ['c', 'a', 'b'] });
  assert.deepEqual(model.search(searches, 'new'), { query: 'new', searches: ['new', 'a', 'b', 'c'] });
  assert.equal(model.search(searches, '   '), null);
  assert.equal(model.searchText('', '春季露营装备清单'), '春季露营装备清单', 'The placeholder topic when the field is empty');
  assert.equal(model.searchText('typed', '春季露营装备清单'), 'typed');
  assert.equal(model.placeholder(model.initialTopics(model.bundled('zh-Hans'))), '春季露营装备清单');
  assert.equal(model.placeholder([]), '搜索');
});

test('recent searches fold to two rows with the chevron as the last tag', () => {
  const contentWidth = 343;
  const widths = [120, 150, 200, 110, 160, 170, 140, 180, 130, 300];
  const folded = model.recentLayout(widths, { contentWidth });
  assert.equal(folded.canFold, true);
  assert.equal(folded.rows.length, 2, 'Two rows');
  const last = folded.rows[1][folded.rows[1].length - 1];
  assert.deepEqual(last, { fold: true }, 'The fold cell ends the second row');
  assert.ok(folded.visibleCount < widths.length);
  const foldWidth = model.foldCellWidth();
  assert.equal(foldWidth, 44);
  folded.rows.forEach((row) => {
    const used = row.reduce((sum, cell, i) => sum + (i ? 12 : 0) + (cell.fold ? foldWidth : widths[cell.item]), 0);
    assert.ok(used <= contentWidth, `row fits: ${used}`);
  });
  // 120 + 150 fill row 1; row 2 has 200 then 110 would not leave room for the chevron: 200 + chevron.
  assert.deepEqual(folded.rows, [[{ item: 0 }, { item: 1 }], [{ item: 2 }, { fold: true }]]);
  assert.equal(folded.visibleCount, 3);

  const expanded = model.recentLayout(widths, { contentWidth, expanded: true });
  assert.equal(expanded.visibleCount, widths.length);
  const cells = expanded.rows.flat();
  assert.deepEqual(cells[cells.length - 1], { fold: true }, 'Expanded, the chevron follows the last tag');
  assert.equal(cells.filter((cell) => !cell.fold).length, widths.length);

  const short = model.recentLayout([80, 90], { contentWidth, expanded: true });
  assert.equal(short.canFold, false, 'No fold control when everything fits in two rows');
  assert.deepEqual(short.rows, [[{ item: 0 }, { item: 1 }]]);

  // A tag wider than the content is cut to it; one per row keeps at least one tag in the last visible row.
  const wide = model.recentLayout([500, 500, 500], { contentWidth });
  assert.equal(wide.visibleCount, 2);
  assert.deepEqual(wide.rows, [[{ item: 0 }], [{ item: 1 }], [{ fold: true }]]);
  assert.deepEqual(model.recentLayout([], { contentWidth }).rows, []);
  assert.equal(model.foldTitle(false, 'zh-Hans'), '更多');
  assert.equal(model.foldTitle(true, 'en'), 'Less');
});

test('the discover grid has two titles per row, each as wide as the other', () => {
  assert.equal(model.gridItemWidth(375 - 32), 159);
  const topics = model.initialTopics(model.bundled('zh-Hans'));
  const rows = model.gridRows(topics);
  assert.equal(rows.length, 3);
  assert.ok(rows.every((row) => row.length === 2));
  assert.deepEqual(rows[0][0], { index: 0, title: '春季露营装备清单', hot: true });
  assert.equal(rows[0][1].hot, false);
});
