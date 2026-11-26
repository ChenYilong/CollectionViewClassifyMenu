'use strict';

// The tail fold cell uses the SAME style strategy as every other tag (docs/tag-section-style.md): one shared Liquid Glass style and
// one shared flat style from the same configuration. Only the content (icon / title) is the fold control's, and foldControlColor
// tints the icon / text color only. Written statically, not yet run.
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const model = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/model.js');
const glass = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-animated-item/cyl_animated_item_model.js');

const DIR = path.join(__dirname, '..', 'packages', 'cyl-tag-list-miniprogram', 'miniprogram_dist', 'cyl-tag-list');
const JS = fs.readFileSync(path.join(DIR, 'cyl-tag-list.js'), 'utf8');
const WXML = fs.readFileSync(path.join(DIR, 'cyl-tag-list.wxml'), 'utf8');

const PIXEL_RATIO = 2;
const FOLD_COLOR = '#FF00FF';
// The CSS properties that make the shape: background, radius, border, glass blur.
const SHAPE_PROPERTIES = /^(background-color|background-image|border-radius|border|border-width|border-color|backdrop-filter|-webkit-backdrop-filter|box-shadow|overflow|box-sizing)$/;

test.afterEach(() => glass.cylAnimatedItemLiquidGlassSetActiveOverride(undefined));

const styleOf = (config) => model.mergeStyle(config, model.defaultStyle(PIXEL_RATIO, false));

/** The section's tailStyle, as cyl-tag-list.js builds it (model.tagLayout of a normal tag + the fold font). */
const tailCss = (config) => {
  const style = styleOf(config);
  return `${model.tagLayout(style, { title: 'x', enabled: true }, 'normal', { kind: 'none' }, style.interitemSpacing, style.lineSpacing).cellStyle}; ${model.foldControlFontCSS(style.normal.font.size)}`;
};
const tagCss = (config) => model.tagButtonView({ title: 'Tag', tagStyle: config }, '', PIXEL_RATIO).cellStyle;

/** The shape declarations of a style attribute, sorted. */
const shapeOf = (css) => css.split(';').map((d) => d.trim()).filter((d) => SHAPE_PROPERTIES.test(d.split(':')[0].trim())).sort();

const GLASS = { backgroundStyle: 'liquidGlass' };
const GLASS_STYLED = { backgroundStyle: 'liquidGlass', normal: { backgroundColor: '#80FF0000', cornerRadius: 6, borderColor: '#0000FF', borderWidth: 2 } };
const FLAT = {};
const FLAT_STYLED = { normal: { backgroundColor: '#FF0000', cornerRadius: 0, borderColor: '#00FF00', borderWidth: 1 } };

test('in a glass list the tail cell has the tag\'s glass background, radius, border and backdrop-filter', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  [GLASS, GLASS_STYLED].forEach((config) => {
    assert.deepEqual(shapeOf(tailCss(config)), shapeOf(tagCss(config)));
    assert.match(tailCss(config), /backdrop-filter:blur/);
  });
  assert.match(tailCss(GLASS), /background-color:rgba\(225,222,220,0\.10\)/, 'an unset background is the frosted default, not an opaque fill');
  assert.doesNotMatch(tailCss(GLASS), /F2F2F7|242,242,247/i);
});

test('in a flat list the tail cell has the tag\'s flat background, radius and border', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  [FLAT, FLAT_STYLED].forEach((config) => {
    assert.deepEqual(shapeOf(tailCss(config)), shapeOf(tagCss(config)));
    assert.doesNotMatch(tailCss(config), /backdrop-filter/);
  });
  assert.match(tailCss(FLAT_STYLED), /background-color:#FF0000/);
});

test('foldControlColor only changes the icon / text color, never the shape', () => {
  [GLASS_STYLED, FLAT_STYLED].forEach((config) => {
    glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
    const tinted = { ...config, foldControlColor: FOLD_COLOR };
    assert.equal(tailCss(tinted), tailCss(config), 'the cell CSS does not depend on foldControlColor');
    assert.equal(model.resolvedFoldControlColor(styleOf(tinted), false), FOLD_COLOR);
  });
});

test('the component takes tailStyle from model.tagLayout and adds only the fold color to it', () => {
  assert.match(JS, /const tailStyle = model\.tagLayout\(style, /);
  assert.match(WXML, /style="\{\{section\.tailStyle\}\}; color: \{\{foldColor\}\};"/);
});

// The tail fold tag is a drawn glass tag: its title and chevron go through the item's resolvers (explicit fold colour is explicit).
const DARK_FOLD_COLOR = '#2C2C2E';
const darkStyleOf = (config) => model.mergeStyle(config, model.defaultStyle(PIXEL_RATIO, true));
const adapted = (color, kind, style) => glass.cylAnimatedItemAdaptedColor(color, kind, model.itemColorProperties(style, 'normal'));

test('on dark glass an explicit dark fold colour is lifted for the tail title (4.5) and chevron (3)', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const style = darkStyleOf({ backgroundStyle: 'liquidGlass', foldControlColor: DARK_FOLD_COLOR });
  const colors = model.tailFoldColors(style, '');
  assert.equal(colors.titleColor, adapted(DARK_FOLD_COLOR, 'title', style));
  assert.equal(colors.iconColor, adapted(DARK_FOLD_COLOR, 'icon', style));
  assert.notEqual(colors.titleColor.toUpperCase(), DARK_FOLD_COLOR);
  assert.notEqual(colors.iconColor.toUpperCase(), DARK_FOLD_COLOR);
  // The component-level fold colour is explicit too.
  const given = model.tailFoldColors(darkStyleOf({ backgroundStyle: 'liquidGlass' }), DARK_FOLD_COLOR);
  assert.equal(given.titleColor, colors.titleColor);
});

test('flat, light and unset fold colours are unchanged for the tail', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const flat = darkStyleOf({ foldControlColor: DARK_FOLD_COLOR });
  assert.deepEqual(model.tailFoldColors(flat, ''), { titleColor: DARK_FOLD_COLOR, iconColor: DARK_FOLD_COLOR }, 'flat');
  const light = styleOf({ backgroundStyle: 'liquidGlass', foldControlColor: DARK_FOLD_COLOR });
  assert.deepEqual(model.tailFoldColors(light, ''), { titleColor: DARK_FOLD_COLOR, iconColor: DARK_FOLD_COLOR }, 'light');
  const unset = styleOf({ backgroundStyle: 'liquidGlass' });
  const tint = model.resolvedFoldControlColor(unset, false);
  assert.deepEqual(model.tailFoldColors(unset, ''), { titleColor: tint, iconColor: tint }, 'unset, light');
});

test('the tail title and chevron carry their resolved colours; header and footer folds keep foldColor', () => {
  assert.match(JS, /model\.tailFoldColors\(style, m\.foldControl\.color\)/);
  assert.match(WXML, /class="cyl-fold-title" style="color: \{\{section\.tailTitleColor\}\};"/);
  assert.match(WXML, /class="cyl-fold-title-text" style="color: \{\{section\.tailTitleColor\}\};"/);
  assert.match(WXML, /class="cyl-fold-arrow [^"]*" style="color: \{\{section\.tailIconColor\}\};"/);
  assert.match(WXML, /class="cyl-fold-footer" style="color: \{\{foldColor\}\};/);
});
