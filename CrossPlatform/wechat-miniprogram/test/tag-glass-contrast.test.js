'use strict';

// The tag routes its EXPLICIT title colour and icon colour through the shared dark-glass adaptation of cyl-animated-item
// (cylAnimatedItemAdaptedColor): only when Liquid Glass is really drawn, the mode is dark and the colour is explicit; title text
// minimum contrast 4.5, icon tint 3. Unset / built-in, flat, light colours are unchanged; the tail fold cell equals a plain tag.
const test = require('node:test');
const assert = require('node:assert/strict');
const model = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/model.js');
const glass = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-animated-item/cyl_animated_item_model.js');
const contrast = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-animated-item/cyl_animated_item_contrast.js');

const GLASS_STYLE = { backgroundStyle: 'liquidGlass' };
const DARK_TEXT = '#3C3C43';
const DARK_ICON = '#2C2C2E';
const SYMBOL = 'house';
const PIXEL_RATIO = 2;
const RGB_MAX = 255;
const HEX_RADIX = 16;

test.afterEach(() => glass.cylAnimatedItemLiquidGlassSetActiveOverride(undefined));

const viewOf = (tagStyle, dark, extra = {}) => model.tagButtonView({ title: 'Tag', tagStyle, ...extra }, '', PIXEL_RATIO, dark);
const textColorOf = (view) => /(?:^|; )color: ([^;]+)/.exec(view.cellStyle)[1];
const symbolColorOf = (view) => {
  const svg = Buffer.from(view.iconSrc.replace('data:image/svg+xml;base64,', ''), 'base64').toString('utf8');
  return /stroke="([^"]+)"/.exec(svg)[1];
};
const ratioOf = (hex, glassColor = '', tintAlpha = -1) => {
  const channel = (i) => Number.parseInt(hex.slice(1 + i * 2, 3 + i * 2), HEX_RADIX) / RGB_MAX;
  const text = (c) => (c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4);
  const luminance = 0.2126 * text(channel(0)) + 0.7152 * text(channel(1)) + 0.0722 * text(channel(2));
  const reference = contrast.cylAnimatedItemGlassReferenceLuminance(glassColor, tintAlpha);
  return (Math.max(luminance, reference) + 0.05) / (Math.min(luminance, reference) + 0.05);
};

test('dark glass and an explicit dark title colour: the title is lifted to 4.5 against the glass', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const drawn = textColorOf(viewOf({ ...GLASS_STYLE, normal: { textColor: DARK_TEXT } }, true));
  assert.notEqual(drawn.toUpperCase(), DARK_TEXT);
  assert.ok(ratioOf(drawn) >= contrast.CYL_TITLE_MINIMUM_CONTRAST, drawn);
});

test('an unset or built-in title colour is unchanged on dark glass', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  assert.equal(textColorOf(viewOf(GLASS_STYLE, true)), '#FFFFFF');
  assert.equal(textColorOf(viewOf(GLASS_STYLE, true, { enabled: false })), '#B3B3B3');
  assert.equal(textColorOf(viewOf(GLASS_STYLE, true, { selected: true })), '#FFFFFF');
  // An invalid colour restores the built-in default, which is not explicit.
  assert.equal(model.mergeStyle({ normal: { textColor: 'nonsense' } }).normal.textColorExplicit, false);
  assert.equal(model.mergeStyle({ normal: { textColor: DARK_TEXT } }).normal.textColorExplicit, true);
});

test('flat, light and glass that is not drawn keep an explicit title colour', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const explicit = { normal: { textColor: DARK_TEXT } };
  assert.equal(textColorOf(viewOf(explicit, true)), DARK_TEXT, 'flat, dark');
  assert.equal(textColorOf(viewOf({ ...GLASS_STYLE, ...explicit }, false)), DARK_TEXT, 'glass, light');
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(false);
  assert.equal(textColorOf(viewOf({ ...GLASS_STYLE, ...explicit }, true)), DARK_TEXT, 'glass not drawn, dark');
});

test('an explicit dark icon colour baked into a system symbol is lifted to 3 on dark glass', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const drawn = symbolColorOf(viewOf({ ...GLASS_STYLE, normal: { iconColor: DARK_ICON } }, true, { image: `system:${SYMBOL}` }));
  assert.notEqual(drawn.toUpperCase(), DARK_ICON);
  assert.ok(ratioOf(drawn) >= contrast.CYL_ICON_MINIMUM_CONTRAST, drawn);
  // Without an icon colour the symbol follows an explicit title colour, adapted as an icon.
  const followed = symbolColorOf(viewOf({ ...GLASS_STYLE, normal: { textColor: DARK_TEXT } }, true, { image: `system:${SYMBOL}` }));
  assert.ok(ratioOf(followed) >= contrast.CYL_ICON_MINIMUM_CONTRAST, followed);
});

test('a plain icon is unchanged: built-in tint, flat, light', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const image = `system:${SYMBOL}`;
  assert.equal(symbolColorOf(viewOf(GLASS_STYLE, true, { image })), '#FFFFFF', 'built-in tint');
  assert.equal(symbolColorOf(viewOf({ normal: { iconColor: DARK_ICON } }, true, { image })), DARK_ICON, 'flat');
  assert.equal(symbolColorOf(viewOf({ ...GLASS_STYLE, normal: { iconColor: DARK_ICON } }, false, { image })), DARK_ICON, 'light');
  const plain = { image: '/images/pin.png' };
  assert.equal(viewOf({ ...GLASS_STYLE, normal: { iconColor: DARK_ICON } }, true, plain).iconSrc, plain.image, 'a plain image is not baked');
});

test('the tail fold cell equals a plain tag', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const style = model.mergeStyle({ ...GLASS_STYLE, normal: { textColor: DARK_TEXT } }, model.defaultStyle(PIXEL_RATIO, true));
  const tail = model.tagLayout(style, { title: 'x', enabled: true }, 'normal', { kind: 'none' }, style.interitemSpacing, style.lineSpacing).cellStyle;
  const plain = model.tagLayout(style, { title: 'Tag', enabled: true }, 'normal', { kind: 'none' }, style.interitemSpacing, style.lineSpacing).cellStyle;
  assert.equal(tail, plain);
});
