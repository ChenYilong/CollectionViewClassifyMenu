'use strict';

// The tag background style (flat, liquidGlass) and minimumTagSize in the mini program core, in the shape of the iOS
// CYLMenuStyle.backgroundStyle / minimumTagSize; the rule comes from CYLTabBarController's cyl-animated-item.
const test = require('node:test');
const assert = require('node:assert/strict');
const model = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/model.js');
const glass = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-animated-item/cyl_animated_item_model.js');

test.afterEach(() => glass.cylAnimatedItemLiquidGlassSetActiveOverride(undefined));

test('backgroundStyle and minimumTagSize are read from the style configuration', () => {
  assert.equal(model.mergeStyle({}).backgroundStyle, 'flat', 'flat is the default');
  assert.equal(model.mergeStyle({ backgroundStyle: 'liquidGlass' }).backgroundStyle, 'liquidGlass');
  assert.equal(model.mergeStyle({ backgroundStyle: 'LiquidGlass' }).backgroundStyle, 'liquidGlass', 'case-insensitive');
  assert.equal(model.mergeStyle({ backgroundStyle: 1 }).backgroundStyle, 'liquidGlass', 'the raw value');
  assert.equal(model.mergeStyle({ backgroundStyle: 'frosted' }).backgroundStyle, 'flat', 'unknown is flat');
  assert.deepEqual(model.mergeStyle({ minimumTagSize: '{69, 29}' }).minimumTagSizeWH, { width: 69, height: 29 });
  assert.deepEqual(model.mergeStyle({}).minimumTagSizeWH, { width: 0, height: 0 });
});

test('a tag draws glass only where the cyl-animated-item rule is active, flat otherwise', () => {
  const props = { title: 'Tag', tagStyle: { backgroundStyle: 'liquidGlass' } };
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const withGlass = model.tagButtonView(props, '', 2);
  assert.equal(withGlass.glass, true);
  assert.match(withGlass.cellStyle, /backdrop-filter:blur\(16px\) saturate\(180%\)/, 'the state color tints the blur');

  glass.cylAnimatedItemLiquidGlassSetActiveOverride(false);
  const flat = model.tagButtonView(props, '', 2);
  assert.equal(flat.glass, false);
  assert.doesNotMatch(flat.cellStyle, /backdrop-filter/);

  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
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

test('the default radius is the capsule constant in every style; a set radius customizes it', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const height = model.tagHeight(model.mergeStyle({}));
  assert.equal(model.mergeStyle({}).normal.cornerRadius, model.cylAnimatedItemCornerRadiusCapsule);
  for (const backgroundStyle of ['liquidGlass', 'flat']) {
    const view = model.tagButtonView({ title: 'Tag', tagStyle: { backgroundStyle } }, '', 2);
    assert.match(view.cellStyle, new RegExp(`border-radius:${model.cylAnimatedItemCornerRadiusCapsule}px`), `${backgroundStyle}: the capsule constant, handled by cyl-animated-item`);
  }
  const set = model.tagButtonView({ title: 'Tag', tagStyle: { backgroundStyle: 'liquidGlass', normal: { cornerRadius: 6 } } }, '', 2);
  assert.match(set.cellStyle, /border-radius:6px/);
  const square = model.tagButtonView({ title: 'Tag', tagStyle: { backgroundStyle: 'liquidGlass', normal: { cornerRadius: 0 } } }, '', 2);
  assert.match(square.cellStyle, /border-radius:0px/);
});
