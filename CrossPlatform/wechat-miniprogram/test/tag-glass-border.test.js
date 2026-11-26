'use strict';

// Under drawn Liquid Glass a tag's built-in default border (normal / disabled gray hairline, selected app tint) is not handed to the
// glass, so the shared glass rim shows; an EXPLICIT border (configuration key, preset) is kept. Flat tags keep the default border.
// Written statically, not yet run.
const test = require('node:test');
const assert = require('node:assert/strict');
const model = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/model.js');
const glass = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-animated-item/cyl_animated_item_model.js');

const PIXEL_RATIO = 2;
const HAIRLINE = 1 / PIXEL_RATIO;
const GLASS_STYLE = { backgroundStyle: 'liquidGlass' };
const EXPLICIT_BORDER = { borderColor: '#0000FF', borderWidth: 2 };
const NO_BORDER = /border-width: 0px; border-color: transparent/;
const DEFAULT_NORMAL_BORDER = new RegExp(`border-width: ${HAIRLINE}px; border-color: #D1D1D1`);
const DEFAULT_DISABLED_BORDER = new RegExp(`border-width: ${HAIRLINE}px; border-color: #E0E0E0`);
const DEFAULT_SELECTED_BORDER = new RegExp(`border-width: ${HAIRLINE}px; border-color: #2AB9A0`);
const EXPLICIT_CSS = /border-width: 2px; border-color: #0000FF/;

test.afterEach(() => glass.cylAnimatedItemLiquidGlassSetActiveOverride(undefined));

const cellOf = (tagStyle, extra = {}) => model.tagButtonView({ title: 'Tag', tagStyle, ...extra }, '', PIXEL_RATIO).cellStyle;
const tailOf = (config) => {
  const style = model.mergeStyle(config, model.defaultStyle(PIXEL_RATIO, false));
  return model.tagLayout(style, { title: 'x', enabled: true }, 'normal', { kind: 'none' }, style.interitemSpacing, style.lineSpacing).cellStyle;
};

test('glass and an unset border hand no border in any state', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  assert.match(cellOf(GLASS_STYLE), NO_BORDER);
  assert.match(cellOf(GLASS_STYLE, { enabled: false }), NO_BORDER);
  assert.match(cellOf(GLASS_STYLE, { selected: true }), NO_BORDER, 'the selected app-tint border is dropped too');
  assert.doesNotMatch(cellOf(GLASS_STYLE), /D1D1D1|solid/i);
  // A style that sets only other keys of the state keeps the border unset.
  assert.match(cellOf({ ...GLASS_STYLE, normal: { textColor: '#112233' } }), NO_BORDER);
});

test('glass and an explicit border (color and width) keep it exactly', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  assert.match(cellOf({ ...GLASS_STYLE, normal: EXPLICIT_BORDER }), EXPLICIT_CSS);
  assert.match(cellOf({ ...GLASS_STYLE, selected: EXPLICIT_BORDER }, { selected: true }), EXPLICIT_CSS);
  assert.match(cellOf({ ...GLASS_STYLE, disabled: EXPLICIT_BORDER }, { enabled: false }), EXPLICIT_CSS);
  // Only the color or only the width set: the unset half is none, so nothing is drawn (a border needs both).
  assert.match(cellOf({ ...GLASS_STYLE, normal: { borderColor: '#0000FF' } }), NO_BORDER);
  assert.match(cellOf({ ...GLASS_STYLE, normal: { borderWidth: 2 } }), NO_BORDER);
});

test('flat tags are unchanged: the default border is still drawn', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  assert.match(cellOf({}), DEFAULT_NORMAL_BORDER);
  assert.match(cellOf({}, { enabled: false }), DEFAULT_DISABLED_BORDER);
  assert.match(cellOf({}, { selected: true }), DEFAULT_SELECTED_BORDER);
  assert.match(cellOf({ normal: EXPLICIT_BORDER }), EXPLICIT_CSS);
});

test('glass that is not drawn is flat: the default border is drawn as before', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(false);
  assert.match(cellOf(GLASS_STYLE), DEFAULT_NORMAL_BORDER);
  assert.match(cellOf(GLASS_STYLE, { selected: true }), DEFAULT_SELECTED_BORDER);
});

test('the effective default stays readable and only the configuration marks the border explicit', () => {
  [false, true].forEach((dark) => {
    const style = model.mergeStyle({ normal: { textColor: '#112233' } }, model.defaultStyle(PIXEL_RATIO, dark));
    ['normal', 'selected', 'disabled'].forEach((state) => {
      assert.equal(style[state].borderColorExplicit, false, state);
      assert.equal(style[state].borderWidthExplicit, false, state);
    });
    assert.equal(style.normal.borderColor, '#D1D1D1');
    assert.equal(style.normal.borderWidth, HAIRLINE);
    assert.equal(model.normalize({}, { pixelRatio: PIXEL_RATIO, dark }).style.normal.borderColorExplicit, false);
  });
  const set = model.mergeStyle({ normal: EXPLICIT_BORDER });
  assert.equal(set.normal.borderColorExplicit, true);
  assert.equal(set.normal.borderWidthExplicit, true);
  assert.equal(set.selected.borderColorExplicit, false);
  assert.equal(model.mergeStyle({ normal: { borderWidth: 0 } }).normal.borderWidthExplicit, true, 'width 0 is the app\'s explicit choice');
  assert.equal(model.mergeStyle({ normal: { borderColor: 'nonsense' } }).normal.borderColorExplicit, false);
});

test('merging a later configuration (copy) keeps the flag', () => {
  const first = model.mergeStyle({ normal: EXPLICIT_BORDER });
  const second = model.mergeStyle({ normal: { textColor: '#112233' } }, first);
  assert.equal(second.normal.borderColorExplicit, true);
  assert.equal(second.normal.borderWidthExplicit, true);
  assert.equal(first.normal.textColor === second.normal.textColor, false);
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  assert.match(cellOf({ ...GLASS_STYLE, normal: { borderColor: '#0000FF', borderWidth: 2, textColor: '#112233' } }), EXPLICIT_CSS);
});

test('the tail cell equals a plain tag in both glass and flat', () => {
  const shape = (css) => css.split(';').map((d) => d.trim()).filter((d) => /^border/.test(d)).sort();
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  [GLASS_STYLE, { ...GLASS_STYLE, normal: EXPLICIT_BORDER }, {}, { normal: EXPLICIT_BORDER }].forEach((config) => {
    assert.deepEqual(shape(tailOf(config)), shape(cellOf(config)));
  });
  assert.match(tailOf(GLASS_STYLE), NO_BORDER);
  assert.match(tailOf({}), DEFAULT_NORMAL_BORDER);
});

test('a list tag takes the same rule through tagLayout', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const item = { title: 'x', enabled: true };
  const layout = (config) => model.tagLayout(model.mergeStyle(config), item, 'normal', { kind: 'none' }, 0, 0).cellStyle;
  assert.match(layout(GLASS_STYLE), NO_BORDER);
  assert.match(layout({ ...GLASS_STYLE, normal: EXPLICIT_BORDER }), EXPLICIT_CSS);
});
