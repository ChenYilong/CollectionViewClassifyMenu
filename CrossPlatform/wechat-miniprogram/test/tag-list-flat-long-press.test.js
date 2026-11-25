/**
 * cyl-tag-list's flat tags as one section of the list: the long press goes through the list's long-press actions
 * (docs/tag-long-press-action.md; "reorder" begins a drag only where the tags can move), the subtitle callout works on a
 * flat tag, and `selectedItems()` / `setSelectedItems()` use the keys "0-<index>" (node --test).
 */
const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');

const PACKAGE = path.join(__dirname, '..', 'packages', 'cyl-tag-list-miniprogram', 'miniprogram_dist');
const model = require(path.join(PACKAGE, 'cyl-tag-list', 'model.js'));
const tagModel = require(path.join(PACKAGE, 'cyl-tag-list', 'tag-model.js'));

/** The frames the stand-in selector query answers: a tag 100 x 30 at (40, 200), the list from (0, 100). */
const LIST_RECT = { left: 0, top: 100, width: 390, height: 300 };
const TAG_RECT = { left: 40, right: 140, top: 200, bottom: 230, width: 100, height: 30 };

function setPath(target, keyPath, value) {
  const parts = keyPath.replace(/\[(\d+)\]/g, '.$1').split('.');
  let node = target;
  for (let i = 0; i < parts.length - 1; i += 1) {
    if (node[parts[i]] == null) node[parts[i]] = {};
    node = node[parts[i]];
  }
  node[parts[parts.length - 1]] = value;
}

function mount(properties) {
  let definition;
  global.Component = (def) => { definition = def; };
  const file = path.join(PACKAGE, 'cyl-tag-list', 'cyl-tag-list.js');
  delete require.cache[require.resolve(file)];
  require(file);
  delete global.Component;
  const data = { ...(definition.data || {}) };
  for (const [key, spec] of Object.entries(definition.properties || {})) data[key] = spec.value;
  const events = [];
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
    triggerEvent(name, detail) { events.push({ name, detail }); },
    createSelectorQuery() {
      const asked = [];
      const api = {
        select(selector) { return { boundingClientRect(cb) { asked.push([selector, cb]); return api; } }; },
        selectAll(selector) { return { boundingClientRect(cb) { asked.push([selector, cb]); return api; } }; },
        exec(callback) {
          const results = asked.splice(0).map(([selector, cb]) => {
            const rect = selector === '.cyl-tag-list' ? LIST_RECT : TAG_RECT;
            const answer = selector.startsWith('.cyl-tc-item') ? [TAG_RECT] : rect;
            if (cb) cb(answer);
            return answer;
          });
          if (callback) callback(results);
        },
      };
      return api;
    },
    selectComponent() { return null; },
    ...definition.methods,
  };
  definition.lifetimes.created.call(instance);
  definition.lifetimes.attached.call(instance);
  instance.setData(properties);
  return instance;
}

const pressAt = (index) => ({ currentTarget: { dataset: { index } }, touches: [{ clientX: 50, clientY: 210 }] });

test('longPressDecision: "reorder" begins only where the items can move, the documented default of flat tags', () => {
  const flatDefault = model.longPressActions(model.LONG_PRESS_ACTION.reorder);
  assert.deepEqual(flatDefault, ['reorder', 'report']);
  assert.equal(model.longPressDecision(flatDefault, false, true), 'reorder');
  assert.equal(model.longPressDecision(flatDefault, false, false), 'report');
  assert.equal(model.longPressDecision(['callout', 'reorder'], true, true), 'callout', 'the first that can begin wins');
});

test('flat tags: a long press without reordering reports {position, tag}; with "callout" a subtitle shows the callout', () => {
  const list = mount({
    tags: [tagModel.makeTag('Java', { subtitle: 'A language' }), tagModel.makeTag('Go')],
    listStyle: tagModel.tagCloudStyle(),
  });
  assert.equal(list.data.flat, true, 'no sections: the flat tags are shown');
  assert.equal(list.data.items[0].listKey, '0-0', 'the element id of a flat tag is its key in section 0');
  list.onItemLongPress(pressAt(0));
  assert.equal(list.data.callout, null, 'no callout by default');
  assert.deepEqual(list.events.pop(), { name: 'taglongpress', detail: { position: 0, tag: list.getTags()[0] } });
  list.setData({ longPressAction: 'callout' });
  list.onItemLongPress(pressAt(0));
  assert.equal(list.data.callout.text, 'A language');
  assert.equal(list.events.pop().name, 'taglongpress');
  list.onTap(pressAt(1));
  assert.equal(list.data.callout, null, 'a tap hides the callout');
  list.events.length = 0;
  list.setData({ longPressAction: 'none' });
  list.onItemLongPress(pressAt(0));
  assert.equal(list.events.length, 0, '"none" does nothing');
});

test('flat tags: "reorder" picks the tag up through the phases; a property action without "reorder" does not drag', () => {
  const list = mount({ tags: ['a', 'b'].map((title) => tagModel.makeTag(title)), allowsReordering: true });
  list.onTouchStart(pressAt(0));
  list.onItemLongPress(pressAt(0));
  assert.deepEqual(list.events.pop(), { name: 'reorderingchange', detail: { reordering: true } });
  list.onTouchEnd();
  assert.equal(list.events.pop().name, 'taglongpress', 'a drag that did not move is a long press');
  list.setData({ longPressAction: 'report' });
  list.onItemLongPress(pressAt(1));
  assert.equal(list.events.pop().name, 'taglongpress');
  assert.equal(list.data.scrollLocked, false, 'no drag began');
});

test('flat tags: selectedItems and setSelectedItems use the keys of section 0', () => {
  const list = mount({ tags: ['a', 'b', 'c'].map((title) => tagModel.makeTag(title)), selectionMode: 'multiple' });
  list.setSelectedItems(['0-2', '0-0', '0-9', '1-0']);
  assert.deepEqual(list.selectedIndexes(), [0, 2], 'keys that address no tag are dropped');
  assert.deepEqual(list.selectedItems(), ['0-0', '0-2']);
  list.setExpanded(0, true);
  assert.equal(list.isSectionExpanded(0), true, 'the section API reaches the flat tags too');
});

test('a configured list keeps its sections: flat tag properties do not make it reorder', () => {
  global.wx = { getWindowInfo: () => ({ pixelRatio: 2 }), nextTick: (fn) => fn() };
  try {
    const list = mount({ configuration: { sections: [{ title: 'S', items: ['a', 'b'] }] }, allowsReordering: true });
    // The property's own observer ('rebuild'), which the stand-in does not run.
    list.rebuild();
    assert.equal(list.data.flat, false);
    list.onItemLongPress({ currentTarget: { dataset: { key: '0-1' } } });
    assert.deepEqual(list.events.pop(), { name: 'taglongpress', detail: { section: 0, item: 1, title: 'b', subtitle: '' } });
  } finally {
    delete global.wx;
  }
});
