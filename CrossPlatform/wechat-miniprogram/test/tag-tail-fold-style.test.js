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
