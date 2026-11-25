/**
 * cyl-tag-list (flat tags) folding (iOS `defaultVisibleRows` + `CYLMenuFoldControl` tail): the fold control is the last tag of
 * the last visible row, the items that leave it no room are hidden, a tap unfolds, editing shows every tag.
 */
const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');

const PACKAGE = path.join(__dirname, '..', 'packages', 'cyl-tag-list-miniprogram', 'miniprogram_dist');
const model = require(path.join(PACKAGE, 'cyl-tag-list/tag-model.js'));

/** Frames of `widths` laid out in rows of `rowWidth` with `spacing`, as flex wrap does. */
function layOut(widths, rowWidth, spacing) {
  const rects = [];
  let x = 0;
  let top = 0;
  widths.forEach((width) => {
    if (x > 0 && x + width > rowWidth) {
      x = 0;
      top += 40;
    }
    rects.push({ left: x, top, right: x + width, width, height: 30 });
    x += width + spacing;
  });
  return rects;
}

test('foldVisibility keeps the rows up to the limit and makes room for the fold control in the last one', () => {
  // Rows of 300: [100, 100, 80] [100, 120] [90, 90, 60]
  const rects = layOut([100, 100, 80, 100, 120, 90, 90, 60], 300, 10);
  assert.deepEqual(model.rowsFromTops(rects.map((r) => r.top)), [0, 0, 0, 1, 1, 2, 2, 2]);
  const folded = model.foldVisibility({ rects, containerRight: 300, tailWidth: 44, spacing: 10, limit: 2 });
  assert.equal(folded.canFold, true);
  // Row 1 ends at 230: 230 + 10 + 44 = 284 fits, so nothing more is hidden.
  assert.deepEqual(folded.visible, [true, true, true, true, true, false, false, false]);
  const tight = model.foldVisibility({ rects, containerRight: 300, tailWidth: 80, spacing: 10, limit: 2 });
  // 230 + 10 + 80 = 320 does not fit: the 120 tag goes, the control takes its place.
  assert.deepEqual(tight.visible, [true, true, true, true, false, false, false, false]);
  const expanded = model.foldVisibility({ rects, containerRight: 300, tailWidth: 44, spacing: 10, limit: 2, expanded: true });
  assert.ok(expanded.visible.every(Boolean));
  assert.equal(model.foldVisibility({ rects, containerRight: 300, tailWidth: 44, spacing: 10, limit: 4 }).canFold, false);
  assert.equal(model.foldVisibility({ rects, containerRight: 300, tailWidth: 44, spacing: 10, limit: 0 }).canFold, false);
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

/** cyl-tag-list (flat tags) with a stand-in layout: each tag `widths[i]` wide in rows of 300 px, the control 44 px. */
function mountCloud(properties, widths) {
  let definition;
  global.Component = (def) => { definition = def; };
  const file = path.join(PACKAGE, 'cyl-tag-list/cyl-tag-list.js');
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
      const calls = [];
      const api = {
        selectAll(selector) { return { boundingClientRect() { calls.push(selector); return api; } }; },
        select(selector) { return { boundingClientRect() { calls.push(selector); return api; } }; },
        exec(callback) {
          callback(calls.map((selector) => {
            if (selector === '.cyl-tc-item') return layOut(widths.slice(0, instance.data.items.length), 300, 10);
            if (selector === '.cyl-tc-items') return { left: 0, right: 300 };
            return { width: 44 };
          }));
        },
      };
      return api;
    },
    ...definition.methods,
  };
  definition.lifetimes.created.call(instance);
  definition.lifetimes.attached.call(instance);
  instance.setData(properties);
  return instance;
}

test('cyl-tag-list (flat tags) folds to defaultVisibleRows with the control as the last tag, unfolds and shows all while editing', () => {
  const widths = [100, 100, 80, 100, 120, 90, 90, 60];
  const cloud = mountCloud({
    tags: widths.map((w, i) => model.makeTag(`T${i}`)),
    listStyle: model.tagCloudStyle(),
    defaultVisibleRows: 2,
  }, widths);
  assert.equal(cloud.data.canFold, true);
  assert.deepEqual(cloud.data.items.map((item) => item.hidden), [false, false, false, false, false, true, true, true]);
  assert.deepEqual(cloud.events.filter((e) => e.name === 'foldchange').pop().detail, { canFold: true, expanded: false });
  // The chevron is a drawn icon as large as an editing icon (cap height x 1.25), not a text glyph.
  const side = model.editingIconSide(model.tagCloudStyle().normal.fontSize);
  assert.match(cloud.data.foldChevron, /^data:image\/svg\+xml;base64,/);
  assert.equal(cloud.data.foldChevronStyle, `width: ${side}px; height: ${side}px`);
  cloud.onFoldTap();
  assert.equal(cloud.isExpanded(), true);
  assert.ok(cloud.data.items.every((item) => !item.hidden), 'unfolded: every tag');
  assert.equal(cloud.data.canFold, true, 'the control stays, to fold again');
  cloud.setExpanded(false);
  assert.equal(cloud.data.items[7].hidden, true);
  cloud.setEditing(true);
  assert.ok(cloud.data.items.every((item) => !item.hidden), 'editing shows every tag');
  assert.equal(cloud.data.canFold, false, 'no fold control while editing');
  cloud.setEditing(false);
  assert.equal(cloud.data.items[7].hidden, true, 'folded again after editing');
});
