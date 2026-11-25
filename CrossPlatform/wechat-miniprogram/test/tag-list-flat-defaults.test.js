/**
 * cyl-tag-list after the merge of the flat tags: a list whose configuration is still empty draws nothing (no flat
 * block), the flat tags' default style follows dark mode as the section list's does, and `titleMaxLines` wraps and
 * clamps a flat tag's title (node --test).
 */
const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');

const PACKAGE = path.join(__dirname, '..', 'packages', 'cyl-tag-list-miniprogram', 'miniprogram_dist');
const model = require(path.join(PACKAGE, 'cyl-tag-list', 'model.js'));
const tagModel = require(path.join(PACKAGE, 'cyl-tag-list', 'tag-model.js'));

/** The number of lines of the clamped title in the test. */
const CLAMPED_LINES = 2;

/** Loads cyl-tag-list in a stand-in with no selector query: nothing may be measured. */
function mount() {
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
      Object.assign(this.data, patch);
      if (callback) callback();
    },
    triggerEvent(name, detail) { events.push({ name, detail }); },
    ...definition.methods,
  };
  definition.lifetimes.created.call(instance);
  definition.lifetimes.attached.call(instance);
  return instance;
}

test('an empty configuration draws nothing and measures nothing; a tag method turns the flat tags on', () => {
  const list = mount();
  assert.equal(list.data.flat, false, 'no flat block for a list whose configuration is not set yet');
  assert.deepEqual(list.data.sections, []);
  assert.equal(list.events.length, 0);
  list.addTag(tagModel.makeTag('A'));
  assert.equal(list.data.flat, true);
  assert.equal(list.data.items.length, 1);
});

test('the flat default style follows dark mode; the light one is unchanged', () => {
  const light = tagModel.defaultStyle();
  assert.equal(light.normal.backgroundColor, '#F2F2F7');
  const dark = tagModel.defaultStyle(true);
  assert.equal(dark.normal.backgroundColor, model.DARK_TAG_BACKGROUND);
  assert.equal(dark.normal.textColor, model.DARK_TEXT_COLOR);
  assert.equal(dark.headerTextColor, model.DARK_TEXT_COLOR);
  assert.equal(dark.selected.backgroundColor, light.selected.backgroundColor, 'the selection keeps its tint');
});

test('titleMaxLines wraps a flat title and clamps it; unlimited and titleWraps do not clamp', () => {
  const style = tagModel.tagCloudStyle();
  assert.equal(style.titleMaxLines, model.TITLE_MAX_LINES.single);
  const plain = tagModel.renderTag(tagModel.makeTag('A long title'), 0, { listStyle: style });
  assert.doesNotMatch(plain.titleStyle, /line-clamp/);
  style.titleMaxLines = CLAMPED_LINES;
  const clamped = tagModel.renderTag(tagModel.makeTag('A long title'), 0, { listStyle: style });
  assert.match(clamped.style, /min-height: \d+(\.\d+)?px; height: auto/);
  assert.match(clamped.titleStyle, new RegExp(`-webkit-line-clamp: ${CLAMPED_LINES}`));
  style.titleMaxLines = model.TITLE_MAX_LINES.unlimited;
  const unlimited = tagModel.renderTag(tagModel.makeTag('A long title'), 0, { listStyle: style });
  assert.match(unlimited.titleStyle, /white-space: normal/);
  assert.doesNotMatch(unlimited.titleStyle, /line-clamp/);
});
