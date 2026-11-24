'use strict';

// The tag background style (flat, liquidGlass) and minimumTagSize in the mini program core, in the shape of the iOS
// CYLMenuStyle.backgroundStyle / minimumTagSize; the glass comes from CYLTabBarController's cyl-liquid-glass.
const test = require('node:test');
const assert = require('node:assert/strict');
const model = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/model.js');
const glass = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-liquid-glass/cyl_liquid_glass.js');

test.afterEach(() => glass.cylLiquidGlassSetActiveOverride(undefined));

test('backgroundStyle and minimumTagSize are read from the style configuration', () => {
  assert.equal(model.mergeStyle({}).backgroundStyle, 'flat', 'flat is the default');
  assert.equal(model.mergeStyle({ backgroundStyle: 'liquidGlass' }).backgroundStyle, 'liquidGlass');
  assert.equal(model.mergeStyle({ backgroundStyle: 'LiquidGlass' }).backgroundStyle, 'liquidGlass', 'case-insensitive');
  assert.equal(model.mergeStyle({ backgroundStyle: 1 }).backgroundStyle, 'liquidGlass', 'the raw value');
  assert.equal(model.mergeStyle({ backgroundStyle: 'frosted' }).backgroundStyle, 'flat', 'unknown is flat');
  assert.deepEqual(model.mergeStyle({ minimumTagSize: '{69, 29}' }).minimumTagSizeWH, { width: 69, height: 29 });
  assert.deepEqual(model.mergeStyle({}).minimumTagSizeWH, { width: 0, height: 0 });
});

test('a tag draws glass only where cyl-liquid-glass is active, flat otherwise', () => {
  const props = { title: 'Tag', tagStyle: { backgroundStyle: 'liquidGlass' } };
  glass.cylLiquidGlassSetActiveOverride(true);
  const withGlass = model.tagButtonView(props, '', 2);
  assert.equal(withGlass.glass, true);
  assert.match(withGlass.cellStyle, /background-color: transparent/, 'the flat color is not drawn under the glass');
  assert.equal(typeof withGlass.glassTint, 'string');

  glass.cylLiquidGlassSetActiveOverride(false);
  const flat = model.tagButtonView(props, '', 2);
  assert.equal(flat.glass, false);
  assert.doesNotMatch(flat.cellStyle, /background-color: transparent/);

  glass.cylLiquidGlassSetActiveOverride(true);
  assert.equal(model.tagButtonView({ title: 'Tag' }, '', 2).glass, false, 'the default style is flat');
});

test('a minimum tag size grows a smaller tag, a larger tag is not shrunk', () => {
  const plain = model.mergeStyle({});
  const plainHeight = model.tagHeight(plain);
  const grown = model.mergeStyle({ minimumTagSize: { width: 69, height: plainHeight + 10 } });
  assert.equal(model.tagHeight(grown), plainHeight + 10);
  assert.equal(model.tagHeightForTitle(grown, 'A', { width: 0, height: 0 }) >= plainHeight + 10, true);
  const view = model.tagButtonView({ title: 'A', tagStyle: { minimumTagSize: { width: 69, height: plainHeight + 10 } } }, '', 2);
  assert.match(view.cellStyle, /min-width: 69px/);
  assert.equal(model.tagHeight(model.mergeStyle({ minimumTagSize: { width: 0, height: 1 } })), plainHeight, 'a smaller minimum changes nothing');
});
