'use strict';

// The default list background follows light / dark mode (docs/tag-section-style.md): `backgroundColor` never set is the system
// background (white in light mode, black in dark mode); insetGrouped keeps the grouped background; a set color (even transparent)
// wins in both modes; the default tint resolves against it.
const test = require('node:test');
const assert = require('node:assert/strict');
const model = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/model.js');

const LIGHT = { pixelRatio: 2, dark: false };
const DARK = { pixelRatio: 2, dark: true };
const WHITE = '#FFFFFF';
const BLACK = '#000000';
const CLEAR = 'rgba(0, 0, 0, 0)';

function styleOf(style, options) {
  return model.normalize({ style, sections: [{ title: 'S', items: ['a'] }] }, options).sections[0].style;
}

test('an unset background is white in light mode and black in dark mode (the plain look; the card default is grouped)', () => {
  const plain = { sectionStyle: 'plain' };
  assert.equal(model.resolvedBackgroundColor(styleOf(plain, LIGHT)), WHITE);
  assert.equal(model.resolvedBackgroundColor(styleOf(plain, DARK)), BLACK);
  assert.equal(model.sectionLayout(styleOf(plain, LIGHT)).backgroundStyle, 'background-color: #FFFFFF');
  assert.equal(model.sectionLayout(styleOf(plain, DARK)).backgroundStyle, 'background-color: #000000');
  assert.equal(model.SECTION_COLORS.light.listBackground, WHITE);
  assert.equal(model.SECTION_COLORS.dark.listBackground, BLACK);
});

test('a set background wins in both modes, a transparent one too', () => {
  [LIGHT, DARK].forEach((options) => {
    assert.equal(model.resolvedBackgroundColor(styleOf({ backgroundColor: CLEAR }, options)), CLEAR);
    assert.equal(model.resolvedBackgroundColor(styleOf({ backgroundColor: '#123456' }, options)), '#123456');
    assert.equal(model.resolvedBackgroundColor(styleOf({ backgroundColor: WHITE }, options)), WHITE, 'white itself counts as set');
  });
});

test('insetGrouped keeps the grouped background', () => {
  assert.equal(model.resolvedBackgroundColor(styleOf({ sectionStyle: 'insetGrouped' }, LIGHT)), '#F2F2F7');
  assert.equal(model.resolvedBackgroundColor(styleOf({ sectionStyle: 'insetGrouped' }, DARK)), BLACK);
});

test('the default tint is dark on the default light background and light on the default dark one', () => {
  assert.equal(model.resolvedHeaderTextColor(styleOf({}, LIGHT)), BLACK);
  assert.equal(model.resolvedFoldControlColor(styleOf({}, LIGHT)), BLACK);
  assert.equal(model.resolvedHeaderTextColor(styleOf({}, DARK)), WHITE);
  assert.equal(model.resolvedFoldControlColor(styleOf({}, DARK)), WHITE);
  assert.equal(model.resolveTint(styleOf({}, DARK)), WHITE);
});
