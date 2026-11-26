'use strict';

// The tag hands its colours to the shared item through the colour CHANNELS of cyl-animated-item: an explicit title / icon colour
// through subclass...Color, an unset one through builtIn...Color; cylAnimatedItemResolvedTitleColor / ...IconColor adapt both on
// drawn dark glass (title minimum contrast 4.5, icon tint 3). Flat and light colours are unchanged; the tail fold cell equals a plain tag.
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

test('an unset title colour with a dark built-in default (light-only theme) is readable in night on dark glass', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  // The built-in level of a light-only style is the dark default text; the item adapts it on drawn dark glass.
  const lightOnly = { ...model.defaultStyle(PIXEL_RATIO, false), ...GLASS_STYLE, sectionPalette: { dark: true } };
  assert.equal(lightOnly.normal.textColorExplicit, false);
  const drawn = /(?:^|; )color: ([^;]+)/.exec(model.tagLayout(lightOnly, { title: 'Tag', enabled: true }, 'normal', { kind: 'none' },
    lightOnly.interitemSpacing, lightOnly.lineSpacing).cellStyle)[1];
  assert.notEqual(drawn.toUpperCase(), lightOnly.normal.textColor.toUpperCase());
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

// Icon coverage of the list's non-system images, animations and glyph fallback (the item cannot be given the glass properties
// without drawing a second glass, so the tag hands it the colour already resolved with the tag's glass state).
const fs = require('node:fs');
const path = require('node:path');
const LIST_DIR = path.join(__dirname, '..', 'packages', 'cyl-tag-list-miniprogram', 'miniprogram_dist', 'cyl-tag-list');
const LIST_WXML = fs.readFileSync(path.join(LIST_DIR, 'cyl-tag-list.wxml'), 'utf8');
const PLAIN_IMAGE = '/images/pin.png';
const GLYPH_ONLY_SYMBOL = 'system:gearshape';
const ANIMATION_URL = 'Lottie/c.json';

const styleOf = (config, dark) => model.mergeStyle(config, model.defaultStyle(PIXEL_RATIO, dark));
const dataOf = (config, dark, item, state = 'normal', url = '') => {
  const style = styleOf(config, dark);
  const full = { enabled: true, ...item };
  return model.iconColorData(full, state, style, model.animatedIcon(full, state, style, url));
};

test('dark glass and an explicit dark icon colour: a non-system image gets the lifted colour through the subclass channel', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const data = dataOf({ ...GLASS_STYLE, normal: { iconColor: DARK_ICON } }, true, { image: PLAIN_IMAGE });
  assert.notEqual(data.subclassIconColor.toUpperCase(), DARK_ICON);
  assert.ok(ratioOf(data.subclassIconColor) >= contrast.CYL_ICON_MINIMUM_CONTRAST, data.subclassIconColor);
  assert.equal(data.builtInIconColor, '');
  const selected = dataOf({ ...GLASS_STYLE, selected: { iconColor: DARK_ICON } }, true, { image: PLAIN_IMAGE }, 'selected');
  assert.ok(ratioOf(selected.subclassSelectedIconColor) >= contrast.CYL_ICON_MINIMUM_CONTRAST, selected.subclassSelectedIconColor);
  assert.equal(selected.subclassIconColor, '');
});

test('an animation gets the same adapted channel as a still image', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const data = dataOf({ ...GLASS_STYLE, normal: { iconColor: DARK_ICON } }, true, { image: PLAIN_IMAGE }, 'normal', ANIMATION_URL);
  assert.ok(ratioOf(data.subclassIconColor) >= contrast.CYL_ICON_MINIMUM_CONTRAST, data.subclassIconColor);
});

test('an unset icon colour goes through the built-in channel (never the explicit one)', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const data = dataOf(GLASS_STYLE, true, { image: PLAIN_IMAGE });
  assert.equal(data.subclassIconColor, '');
  assert.equal(data.builtInIconColor, '#FFFFFF');
});

test('flat, light and disabled icon colours are handed unchanged', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const item = { image: PLAIN_IMAGE };
  assert.equal(dataOf({ normal: { iconColor: DARK_ICON } }, true, item).subclassIconColor, DARK_ICON, 'flat');
  assert.equal(dataOf({ ...GLASS_STYLE, normal: { iconColor: DARK_ICON } }, false, item).subclassIconColor, DARK_ICON, 'light');
  const disabled = dataOf(GLASS_STYLE, true, { ...item, enabled: false }, 'disabled');
  assert.equal(disabled.builtInDisabledIconColor, model.iconColor(styleOf(GLASS_STYLE, true), 'disabled'), 'disabled built-in look');
  assert.equal(disabled.builtInIconColor, '');
});

test('a baked system symbol and an empty slot get no channel', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const config = { ...GLASS_STYLE, normal: { iconColor: DARK_ICON } };
  [{ image: `system:${SYMBOL}` }, {}].forEach((item) => {
    const data = dataOf(config, true, item);
    assert.deepEqual(Object.values(data).filter(Boolean), [], JSON.stringify(item));
  });
});

test('a glyph fallback is coloured with the resolved icon colour, lifted on dark glass', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const item = { image: GLYPH_ONLY_SYMBOL };
  const lifted = dataOf({ ...GLASS_STYLE, normal: { iconColor: DARK_ICON } }, true, item);
  assert.ok(ratioOf(lifted.glyphColor) >= contrast.CYL_ICON_MINIMUM_CONTRAST, lifted.glyphColor);
  assert.equal(lifted.subclassIconColor, '', 'the glyph is text: no item channel');
  assert.equal(dataOf({ normal: { iconColor: DARK_ICON } }, true, item).glyphColor, DARK_ICON, 'flat');
  assert.equal(dataOf({ ...GLASS_STYLE, normal: { iconColor: DARK_ICON } }, false, item).glyphColor, DARK_ICON, 'light');
});

test('cyl-tag-list.wxml forwards the icon channels to the item and colours the glyph', () => {
  assert.match(LIST_WXML, /subclass-icon-color="\{\{item\.subclassIconColor\}\}"/);
  assert.match(LIST_WXML, /subclass-selected-icon-color="\{\{item\.subclassSelectedIconColor\}\}"/);
  assert.match(LIST_WXML, /subclass-disabled-icon-color="\{\{item\.subclassDisabledIconColor\}\}"/);
  assert.match(LIST_WXML, /built-in-icon-color="\{\{item\.builtInIconColor\}\}"/);
  assert.match(LIST_WXML, /built-in-selected-icon-color="\{\{item\.builtInSelectedIconColor\}\}"/);
  assert.match(LIST_WXML, /built-in-disabled-icon-color="\{\{item\.builtInDisabledIconColor\}\}"/);
  assert.match(LIST_WXML, /class="cyl-icon cyl-glyph" style="[^"]*color: \{\{item\.glyphColor\}\};"/);
  const js = fs.readFileSync(path.join(LIST_DIR, 'cyl-tag-list.js'), 'utf8');
  assert.match(js, /\.\.\.model\.iconColorData\(item, state, style, icon\)/);
});
