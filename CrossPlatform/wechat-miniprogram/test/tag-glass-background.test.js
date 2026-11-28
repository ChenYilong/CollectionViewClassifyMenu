'use strict';

// Under Liquid Glass an unset tag background is ignored (docs/tag-liquid-glass.md): the tag hands the glass only an EXPLICIT
// background color (the selected tint, a preset's or an app's color); an unset normal / disabled background hands none, so the
// glass component's default frosted tint applies and a colorful backdrop shows through. Flat tags are unchanged.
const test = require('node:test');
const assert = require('node:assert/strict');
const model = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/model.js');
const glass = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-animated-item/cyl_animated_item_model.js');

const GLASS_STYLE = { backgroundStyle: 'liquidGlass' };
const DEFAULT_FROSTED_TINT = /background-color:rgba\(225,222,220,0\.10\)/;
const EXPLICIT_RED = '#FF0000';
const RED_AT_GLASS_ALPHA = /background-color:rgba\(255,0,0,0\.75\)/;
const SELECTED_TINT = /background-color:rgba\(42,185,160,1\)/;
const FLAT_DEFAULT = /background-color:#F2F2F7/;

test.afterEach(() => glass.cylAnimatedItemLiquidGlassSetActiveOverride(undefined));

const cellOf = (tagStyle, extra = {}) => model.tagButtonView({ title: 'Tag', tagStyle, ...extra }, '', 2).cellStyle;

test('glass and an unset normal background hand no color: the default frosted tint applies', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const cell = cellOf(GLASS_STYLE);
  assert.match(cell, DEFAULT_FROSTED_TINT);
  assert.doesNotMatch(cell, /242,242,247|F2F2F7/i, 'the default fill is not passed to the glass');
  assert.match(cellOf(GLASS_STYLE, { enabled: false }), DEFAULT_FROSTED_TINT, 'an unset disabled background neither');
  // A style that sets only other keys of the state is still unset.
  assert.match(cellOf({ ...GLASS_STYLE, normal: { textColor: '#112233' } }), DEFAULT_FROSTED_TINT);
});

test('glass and an explicit background hand it over with the alpha x 0.75 rule', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  assert.match(cellOf({ ...GLASS_STYLE, normal: { backgroundColor: EXPLICIT_RED } }), RED_AT_GLASS_ALPHA);
  assert.match(cellOf({ ...GLASS_STYLE, disabled: { backgroundColor: EXPLICIT_RED } }, { enabled: false }), RED_AT_GLASS_ALPHA);
  assert.match(cellOf({ ...GLASS_STYLE, normal: { backgroundColor: 'rgba(255, 0, 0, 0.4)' } }), /background-color:rgba\(255,0,0,0\.3\)/);
  // Setting the default fill itself is the app's explicit choice.
  assert.match(cellOf({ ...GLASS_STYLE, normal: { backgroundColor: model.DEFAULT_TAG_BACKGROUND } }), /background-color:rgba\(242,242,247,0\.75\)/);
});

test('the selected tint is explicit and keeps alpha 1', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  assert.match(cellOf(GLASS_STYLE, { selected: true }), SELECTED_TINT, 'the default selected tint');
  assert.match(cellOf({ ...GLASS_STYLE, selected: { backgroundColor: EXPLICIT_RED } }, { selected: true }), /background-color:rgba\(255,0,0,1\)/);
});

test('a transparent or invalid background is never explicit', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  ['transparent', 'clear', '#FF000000', 'nonsense', ''].forEach((value) => {
    const style = model.mergeStyle({ normal: { backgroundColor: value } });
    assert.equal(style.normal.backgroundExplicit, false, value);
    assert.match(cellOf({ ...GLASS_STYLE, normal: { backgroundColor: value } }), DEFAULT_FROSTED_TINT, value);
  });
});

test('flat tags are unchanged: the default fill and an explicit color are drawn as before', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  assert.match(cellOf({}), FLAT_DEFAULT);
  assert.match(cellOf({ backgroundStyle: 'flat', normal: { backgroundColor: EXPLICIT_RED } }), /background-color:#FF0000/);
  assert.match(cellOf({}, { selected: true }), /background-color:#2AB9A0/);
});

test('glass that is not active is flat: the default fill is drawn as before', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(false);
  const cell = cellOf(GLASS_STYLE);
  assert.match(cell, FLAT_DEFAULT);
  assert.doesNotMatch(cell, /backdrop-filter/);
  assert.match(cellOf({ ...GLASS_STYLE, normal: { backgroundColor: EXPLICIT_RED } }), /background-color:#FF0000/);
});

test('a configuration without a background never writes the default as explicit', () => {
  [false, true].forEach((dark) => {
    const style = model.mergeStyle({ normal: { textColor: '#112233' } }, model.defaultStyle(2, dark));
    assert.equal(style.normal.backgroundExplicit, false);
    assert.equal(style.disabled.backgroundExplicit, false);
    assert.equal(style.selected.backgroundExplicit, true, 'the selected tint is explicit');
    assert.equal(model.normalize({}, { pixelRatio: 2, dark }).style.normal.backgroundExplicit, false);
  });
  assert.equal(model.mergeStyle({ normal: { backgroundColor: EXPLICIT_RED } }).normal.backgroundExplicit, true);
});

test('the dark default fill is not handed to the glass either', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const cell = model.tagButtonView({ title: 'Tag', tagStyle: GLASS_STYLE }, '', 2, true).cellStyle;
  assert.match(cell, /background-color:rgba\(255,255,255,0\.04\)/, 'the glass component picks its dark default tint');
  assert.doesNotMatch(cell, /28,28,30|1C1C1E/i);
});

test('a list tag takes the same rule through tagLayout', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const item = { title: 'x', enabled: true };
  const unset = model.mergeStyle(GLASS_STYLE);
  assert.match(model.tagLayout(unset, item, 'normal', { kind: 'none' }, 0, 0).cellStyle, DEFAULT_FROSTED_TINT);
  const set = model.mergeStyle({ ...GLASS_STYLE, normal: { backgroundColor: EXPLICIT_RED } });
  assert.match(model.tagLayout(set, item, 'normal', { kind: 'none' }, 0, 0).cellStyle, RED_AT_GLASS_ALPHA);
});

// (The dark glass adaptation of an explicit icon / title colour is the shared cyl-animated-item's function, which the tag calls:
// tested in tag-glass-contrast.test.js.)
