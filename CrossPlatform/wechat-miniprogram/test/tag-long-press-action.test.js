// The long-press action of the tag list (docs/tag-long-press-action.md): the pure rules of model.js and the cyl-tag-list
// component running in a small stand-in of the Mini Program runtime (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');

const PACKAGE = path.join(__dirname, '..', 'packages', 'cyl-tag-list-miniprogram', 'miniprogram_dist');
const model = require(path.join(PACKAGE, 'cyl-tag-list', 'model.js'));

/** A selector query whose exec answers [item rect, list rect] in the order the component asked. */
function queryFor(rects) {
  const asked = [];
  const api = {
    select(selector) {
      asked.push(selector);
      return { boundingClientRect() { return api; } };
    },
    selectAll(selector) {
      asked.push(selector);
      return { boundingClientRect() { return api; } };
    },
    exec(callback) { callback(asked.splice(0).map((selector) => rects(selector))); },
  };
  return api;
}

function mount(properties, rects = () => null) {
  let definition;
  global.Component = (def) => { definition = def; };
  global.wx = { getWindowInfo: () => ({ pixelRatio: 2 }), nextTick: (fn) => fn() };
  const file = path.join(PACKAGE, 'cyl-tag-list', 'cyl-tag-list.js');
  delete require.cache[require.resolve(file)];
  require(file);
  const data = { ...(definition.data || {}) };
  for (const [key, spec] of Object.entries(definition.properties || {})) data[key] = spec.value;
  const events = [];
  const instance = {
    data,
    setData(patch, callback) {
      Object.assign(this.data, patch);
      if (callback) callback();
    },
    triggerEvent(name, detail) { events.push({ name, detail }); },
    createSelectorQuery() { return queryFor(rects); },
    events,
    selectComponent() { return null; },
    ...definition.methods,
  };
  instance.data.configuration = properties.configuration;
  if (properties.longPressAction !== undefined) instance.data.longPressAction = properties.longPressAction;
  definition.lifetimes.attached.call(instance);
  return instance;
}

const configuration = (extra = {}) => ({
  sections: [{ title: 'S', items: [{ title: 'a', subtitle: 'about a' }, 'b'] }],
  ...extra,
});

const pressOf = (key) => ({ currentTarget: { dataset: { key } } });

test('longPressActions reads a name or an array and reports where nothing takes the press', () => {
  assert.equal(model.longPressActions(undefined), null);
  assert.equal(model.longPressActions('nonsense'), null);
  assert.deepEqual(model.longPressActions('callout'), ['callout', 'report']);
  assert.deepEqual(model.longPressActions(['reorder', 'callout']), ['reorder', 'callout', 'report']);
  assert.deepEqual(model.longPressActions('none'), ['none']);
  assert.deepEqual(model.longPressActions(['callout', 'none']), ['callout', 'none']);
});

test('longPressDecision: the first action that can begin wins', () => {
  assert.equal(model.longPressDecision(null, false), 'report');
  assert.equal(model.longPressDecision(['callout', 'report'], true), 'callout');
  assert.equal(model.longPressDecision(['callout', 'report'], false), 'report');
  // This list does not reorder: reorder does not begin, the next action takes the press.
  assert.equal(model.longPressDecision(['reorder', 'callout', 'report'], true), 'callout');
  assert.equal(model.longPressDecision(['none'], true), 'none');
});

test('normalize keeps the subtitle of an item and the long-press actions of the configuration', () => {
  const built = model.normalize(configuration({ longPressAction: 'callout' }));
  assert.equal(built.sections[0].items[0].subtitle, 'about a');
  assert.equal(built.sections[0].items[1].subtitle, '');
  assert.deepEqual(built.longPressActions, ['callout', 'report']);
});

test('cyl-tag-list: a long press shows the callout and reports; an item without a subtitle only reports', () => {
  const rects = (selector) => (selector === '.cyl-tag-list'
    ? { left: 0, top: 100, width: 390, height: 300 }
    : { left: 40, right: 140, top: 200, bottom: 230, width: 100, height: 30 });
  const list = mount({ configuration: configuration({ longPressAction: 'callout' }) }, rects);
  list.onItemLongPress(pressOf('0-0'));
  assert.equal(list.data.callout.text, 'about a');
  assert.equal(list.data.callout.below, false);
  assert.equal(list.data.callout.top, 100);
  assert.deepEqual(list.events.pop(), { name: 'taglongpress', detail: { section: 0, item: 0, title: 'a', subtitle: 'about a' } });
  // Another item without a subtitle: no callout (the old one is hidden) and the long press is still reported.
  list.onItemLongPress(pressOf('0-1'));
  assert.equal(list.data.callout, null);
  assert.deepEqual(list.events.pop(), { name: 'taglongpress', detail: { section: 0, item: 1, title: 'b', subtitle: '' } });
});

test('cyl-tag-list: a tap hides the callout, "none" does nothing, the property overrides the configuration', () => {
  const rects = (selector) => (selector === '.cyl-tag-list'
    ? { left: 0, top: 0, width: 390, height: 300 }
    : { left: 40, right: 140, top: 20, bottom: 50, width: 100, height: 30 });
  const list = mount({ configuration: configuration({ longPressAction: 'callout' }) }, rects);
  list.onItemLongPress(pressOf('0-0'));
  // Near the top of the page the callout goes below the tag.
  assert.equal(list.data.callout.below, true);
  list.onItemTap(pressOf('0-1'));
  assert.equal(list.data.callout, null);
  list.events.length = 0;
  list.setData({ longPressAction: 'none' });
  list.onItemLongPress(pressOf('0-0'));
  assert.equal(list.data.callout, null);
  assert.equal(list.events.length, 0);
});

test('cyl-tag-list: with no action configured a long press is only reported', () => {
  const list = mount({ configuration: configuration() });
  list.onItemLongPress(pressOf('0-0'));
  assert.equal(list.data.callout, null);
  assert.equal(list.events.pop().name, 'taglongpress');
});

test('calloutPlacesBelow: above first; below with no room above or when the bubble would cover the header and it fits below', () => {
  const target = { top: 200, bottom: 230 };
  const height = 34;
  // The bubble spans [158, 192] above the tag.
  assert.equal(model.calloutPlacesBelow(target, height, null), false);
  assert.equal(model.calloutPlacesBelow(target, height, { top: 100, bottom: 136 }), false);
  assert.equal(model.calloutPlacesBelow(target, height, { top: 170, bottom: 198 }), true);
  // Empty header: nothing to avoid.
  assert.equal(model.calloutPlacesBelow(target, height, { top: 170, bottom: 170 }), false);
  // Covering the header but no room below: stays above.
  assert.equal(model.calloutPlacesBelow(target, height, { top: 170, bottom: 198 }, 250), false);
  // No room above at all.
  assert.equal(model.calloutPlacesBelow({ top: model.CALLOUT_MIN_ROOM_ABOVE - 1, bottom: 80 }, height, null), true);
});

test('cyl-tag-list: the callout goes below the tag when it would cover the section header', () => {
  const rects = (selector) => {
    if (selector === '.cyl-tag-list') return { left: 0, top: 100, width: 390, height: 300 };
    if (selector === '#cyl-header-s0') return { left: 0, right: 390, top: 170, bottom: 198, width: 390, height: 28 };
    return { left: 40, right: 140, top: 200, bottom: 230, width: 100, height: 30 };
  };
  const list = mount({ configuration: configuration({ longPressAction: 'callout' }) }, rects);
  list.onItemLongPress(pressOf('0-0'));
  assert.equal(list.data.callout.below, true);
  assert.equal(list.data.callout.top, 130);
});

test('cyl-tag-list: a scroll hides the callout', () => {
  const rects = (selector) => (selector === '.cyl-tag-list'
    ? { left: 0, top: 100, width: 390, height: 300 }
    : { left: 40, right: 140, top: 200, bottom: 230, width: 100, height: 30 });
  const list = mount({ configuration: configuration({ longPressAction: 'callout' }) }, rects);
  list.onItemLongPress(pressOf('0-0'));
  assert.ok(list.data.callout);
  list.onScroll();
  assert.equal(list.data.callout, null);
});

test('foldControl rotatesImageWhenExpanded: true by default, false turns the chevron rotation off', () => {
  assert.equal(model.foldControlValue({ position: 'tail' }).rotatesImage, true);
  assert.equal(model.foldControlValue({ position: 'tail', rotatesImageWhenExpanded: false }).rotatesImage, false);
  assert.equal(model.foldControlValue({ position: 'tail', rotatesImageWhenExpanded: true }).rotatesImage, true);
  assert.equal(model.foldControlValue('footer').rotatesImage, true);
  const list = mount({ configuration: configuration({ foldControl: { position: 'footer', rotatesImageWhenExpanded: false } }) });
  assert.equal(list.data.foldRotates, false);
  const wxml = require('node:fs').readFileSync(path.join(PACKAGE, 'cyl-tag-list', 'cyl-tag-list.wxml'), 'utf8');
  assert.equal((wxml.match(/section\.expanded && foldRotates \? 'cyl-up'/g) || []).length, 2);
  assert.ok(wxml.includes("section.expanded && foldRotates ? 'cyl-footer-chevron-up'"));
});

test('the list is the containing block of the absolutely positioned callout', () => {
  const css = require('node:fs').readFileSync(
    require('node:path').join(__dirname, '../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/cyl-tag-list.wxss'), 'utf8');
  const compact = css.replace(new RegExp(String.fromCharCode(92) + 's+', 'g'), ' ');
  assert.ok(compact.includes('.cyl-tag-list { position: relative; }'));
  assert.ok(compact.includes('.cyl-callout { position: absolute;'));
});
