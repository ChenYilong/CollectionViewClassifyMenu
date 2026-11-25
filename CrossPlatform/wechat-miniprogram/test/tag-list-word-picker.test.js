/**
 * cyl-tag-list's flat tags: word picker (iOS 选词填入, cf5d9f7e / 251131c5): one cell per character, 9 equal cells per row, the
 * picked text in order, and a smear driven by touch events (the touched-down tag anchors it).
 */
const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');

const PACKAGE = path.join(__dirname, '..', 'packages', 'cyl-tag-list-miniprogram', 'miniprogram_dist');
const model = require(path.join(PACKAGE, 'cyl-tag-list/tag-model.js'));
const MESSAGE = "Hi, I'm Alex from Design 👋";

test('characters, the word picker style and the smear range', () => {
  const cells = model.characters(MESSAGE);
  assert.equal(cells.join(''), MESSAGE);
  assert.ok(cells.includes('👋'), 'an emoji is one cell');
  assert.deepEqual(model.characters('👍🏽 é'), ['👍🏽', ' ', 'é'], 'a skin tone and a mark stay with their character');
  const style = model.wordPickerStyle();
  assert.equal(style.numberOfItemsPerRow, 9);
  const item = model.renderTag(model.makeTag('A'), 0, { listStyle: style });
  assert.match(item.style, /width: calc\(\(100% - 48px\) \/ 9\)/, 'equal cells: 8 spaces of 6');
  assert.match(item.titleStyle, /font-size: 18px.*font-weight: 500/);
  const tags = 'ABCDE'.split('').map((t) => model.makeTag(t));
  tags[2].isEnabled = false;
  assert.deepEqual(model.smearSelection([], 4, 0, true, tags), [0, 1, 3, 4], 'either order, disabled skipped');
  assert.deepEqual(model.smearSelection([0, 1, 3, 4], 1, 3, false, tags), [0, 4]);
});

function setPath(target, keyPath, value) {
  const parts = keyPath.replace(/\[(\d+)\]/g, '.$1').split('.');
  let node = target;
  for (let i = 0; i < parts.length - 1; i += 1) {
    if (node[parts[i]] == null) node[parts[i]] = {};
    node = node[parts[i]];
  }
  node[parts[parts.length - 1]] = value;
}

/** cyl-tag-list (flat tags) with a stand-in layout: 40 x 40 cells, 9 per row, 46 px apart. */
function mountCloud(properties) {
  let definition;
  global.Component = (def) => { definition = def; };
  const file = path.join(PACKAGE, 'cyl-tag-list/cyl-tag-list.js');
  delete require.cache[require.resolve(file)];
  require(file);
  delete global.Component;
  const data = { ...(definition.data || {}) };
  for (const [key, spec] of Object.entries(definition.properties || {})) data[key] = spec.value;
  const events = [];
  const rect = (i) => ({ left: (i % 9) * 46, right: (i % 9) * 46 + 40, top: Math.floor(i / 9) * 50, bottom: Math.floor(i / 9) * 50 + 40 });
  const instance = {
    data,
    events,
    setData(patch, callback) {
      const changed = Object.keys(patch);
      for (const [key, value] of Object.entries(patch)) setPath(this.data, key, value);
      for (const [names, observer] of Object.entries(definition.observers || {})) {
        const keys = names.split(',').map((name) => name.trim());
        if (keys.some((key) => changed.includes(key) && key in definition.properties)) {
          observer.apply(this, keys.map((key) => this.data[key]));
        }
      }
      if (callback) callback();
    },
    triggerEvent(name, detail, options) { events.push({ name, detail, options }); },
    createSelectorQuery() {
      const calls = [];
      const api = {
        selectAll(selector) { return { boundingClientRect(cb) { calls.push(cb); return api; } }; },
        select() { return { boundingClientRect(cb) { calls.push(cb); return api; } }; },
        exec(cb) {
          const results = calls.map(() => instance.data.items.map((_, i) => rect(i)));
          calls.forEach((c, i) => c && c(results[i]));
          if (cb) cb(results);
        },
      };
      return api;
    },
    ...definition.methods,
  };
  instance.rect = rect;
  definition.lifetimes.created.call(instance);
  definition.lifetimes.attached.call(instance);
  instance.setData(properties);
  return instance;
}

function touchAt(cloud, item) {
  const r = cloud.rect(item);
  return { clientX: r.left + 20, clientY: r.top + 20 };
}

test('several smears add up; one from a selected cell removes its range (owner check, iOS testSeveralSmearsAddUp)', () => {
  const cloud = mountCloud({ listStyle: model.wordPickerStyle(), selectionMode: 'multiple', allowsSmearSelection: true });
  cloud.setTagsWithCharactersOfText(MESSAGE);
  const cellOf = (index) => model.characters(MESSAGE.slice(0, index)).length;
  function smear(from, to) {
    cloud.onTouchStart({ currentTarget: { dataset: { index: from } }, touches: [touchAt(cloud, from)] });
    cloud.onTouchMove({ touches: [touchAt(cloud, Math.floor((from + to) / 2))] });
    cloud.onTouchMove({ touches: [touchAt(cloud, to)] });
    cloud.onTouchEnd();
  }
  const alex = cellOf(MESSAGE.indexOf('Alex'));
  smear(alex, alex + 3);
  assert.equal(cloud.selectedText(), 'Alex');
  const design = cellOf(MESSAGE.indexOf(' Design'));
  smear(design, design + 6);
  assert.equal(cloud.selectedText(), 'Alex Design', 'the second starts on the space before the word');
  smear(alex, alex + 3);
  assert.equal(cloud.selectedText(), ' Design');
  // Each smear tells the host to hold its scroller, then to let it go (a catch binding does not stop native scrolling).
  const smearing = cloud.events.filter((e) => e.name === 'smearingchange').map((e) => e.detail.smearing);
  assert.deepEqual(smearing, [true, false, true, false, true, false]);
});

test('reorderingchange and smearingchange bubble and are composed, so an ancestor container hears them', () => {
  const cloud = mountCloud({ listStyle: model.wordPickerStyle(), selectionMode: 'multiple', allowsSmearSelection: true,
    allowsReordering: true });
  cloud.setTagsWithCharactersOfText('ABCDEFGHIJ');
  // A smear.
  cloud.onTouchStart({ currentTarget: { dataset: { index: 0 } }, touches: [touchAt(cloud, 0)] });
  cloud.onTouchMove({ touches: [touchAt(cloud, 3)] });
  cloud.onTouchEnd();
  // A drag (long press, then the end), and a cancelled one.
  cloud.setData({ allowsSmearSelection: false });
  cloud.onTouchStart({ currentTarget: { dataset: { index: 1 } }, touches: [touchAt(cloud, 1)] });
  cloud.onItemLongPress({ currentTarget: { dataset: { index: 1 } } });
  cloud.onTouchEnd();
  cloud.onTouchStart({ currentTarget: { dataset: { index: 2 } }, touches: [touchAt(cloud, 2)] });
  cloud.onItemLongPress({ currentTarget: { dataset: { index: 2 } } });
  cloud.onTouchCancel();
  const gestures = cloud.events.filter((e) => e.name === 'reorderingchange' || e.name === 'smearingchange');
  assert.deepEqual(gestures.map((e) => `${e.name} ${e.detail.reordering ?? e.detail.smearing}`),
    ['smearingchange true', 'smearingchange false', 'reorderingchange true', 'reorderingchange false',
      'reorderingchange true', 'reorderingchange false']);
  for (const event of gestures) assert.deepEqual(event.options, { bubbles: true, composed: true }, event.name);
});

test('a smear from a tag selects the tags it crosses, deselects from a selected one, a tap still toggles', () => {
  const cloud = mountCloud({ listStyle: model.wordPickerStyle(), selectionMode: 'multiple', allowsSmearSelection: true });
  cloud.setTagsWithCharactersOfText('ABCDEFGHIJKL');
  assert.equal(cloud.data.selectionMode, 'multiple', 'keeps the selection mode');
  function smear(from, ...through) {
    const down = { currentTarget: { dataset: { index: from } }, touches: [touchAt(cloud, from)] };
    cloud.onTouchStart(down);
    through.forEach((item) => cloud.onTouchMove({ touches: [touchAt(cloud, item)] }));
    cloud.onTouchEnd();
  }
  smear(2, 4, 10);
  assert.equal(cloud.selectedText(), 'CDEFGHIJK', 'across the row break');
  assert.ok(cloud.events.filter((e) => e.name === 'selectionchange').length >= 2);
  smear(0, 1);
  assert.equal(cloud.selectedText(), 'ABCDEFGHIJK');
  smear(5, 7);
  assert.equal(cloud.selectedText(), 'ABCDEIJK', 'starting on a selected tag deselects');
  cloud.onTap({ currentTarget: { dataset: { index: 11 } } });
  assert.equal(cloud.selectedText(), 'ABCDEIJKL', 'a tap still toggles');
  cloud.deselectAll();
  // The name of the message, wherever it stands.
  cloud.setTagsWithCharactersOfText(MESSAGE);
  const start = model.characters(MESSAGE.slice(0, MESSAGE.indexOf('Alex'))).length;
  cloud.selectItemsFrom(start + 3, start);
  assert.equal(cloud.selectedText(), 'Alex');
  // Only in multiple selection.
  cloud.setData({ selectionMode: 'single' });
  cloud.deselectAll();
  smear(0, 3);
  assert.ok(cloud.selectedIndexes().length <= 1);
});
