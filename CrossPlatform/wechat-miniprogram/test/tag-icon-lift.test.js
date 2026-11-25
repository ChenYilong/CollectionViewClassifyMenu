'use strict';

// The dark glass icon lift (docs/tag-liquid-glass.md "Dark glass icon lift"; the iOS CYLIconContrast): an explicit icon color too
// dark for dark Liquid Glass is lifted to 3:1 in lightness, hue and alpha kept; everything else is unchanged.
const test = require('node:test');
const assert = require('node:assert/strict');
const model = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/model.js');
const glass = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-animated-item/cyl_animated_item_model.js');

const RGB_MAX = 255;
const CONTRAST_TOLERANCE = 0.01;
const HUE_TOLERANCE = 0.01;
const LUMINANCE_TOLERANCE = 0.002;
const REFERENCE_GREY = 36; // white at 0.14 over black is about #242424
const SYSTEM_TEAL = '#30B0C7';
const SYSTEM_RED = '#FF3B30';
const SYSTEM_BLUE = '#007AFF';
const DARK_TEAL = '#004040';
const TAG_DARK_TEAL = '#004D4D';
const BRIGHT = '#99E6FF';
const WHITE = '#FFFFFF';
const BLACK = '#000000';
const EXPLICIT_TINT = 'rgba(51, 153, 255, 0.8)';
const TINT_ALPHA_FULL = 1;
const TINT_ALPHA_DEFAULT_SHARE = 0.75;

test.afterEach(() => glass.cylAnimatedItemLiquidGlassSetActiveOverride(undefined));

/** The {red, green, blue, alpha} (0..1) of a '#RRGGBB' or rgba() text. */
function unit(text) {
  const hex = /^#([0-9A-F]{6})$/i.exec(text);
  if (hex) {
    const n = parseInt(hex[1], 16);
    return { red: Math.floor(n / 65536) / RGB_MAX, green: (Math.floor(n / 256) % 256) / RGB_MAX, blue: (n % 256) / RGB_MAX, alpha: 1 };
  }
  const v = /^rgba\(([^)]*)\)$/.exec(text)[1].split(',').map(Number);
  return { red: v[0] / RGB_MAX, green: v[1] / RGB_MAX, blue: v[2] / RGB_MAX, alpha: v[3] };
}

const luminance = (text) => {
  const c = unit(text);
  return model.relativeLuminance(c.red, c.green, c.blue);
};
const contrast = (text, tint, tintAlpha) => model.contrastRatio(luminance(text), model.glassReferenceLuminance(tint, tintAlpha));
const hue = (text) => {
  const c = unit(text);
  return model.hslFromRgb(c.red, c.green, c.blue).hue;
};
const lightness = (text) => {
  const c = unit(text);
  return model.hslFromRgb(c.red, c.green, c.blue).lightness;
};
const lift = (text, tint, tintAlpha) => model.liftedIconColor(text, tint, tintAlpha);

test('the constants and the frosted reference', () => {
  assert.equal(model.MINIMUM_CONTRAST_RATIO, 3);
  assert.equal(model.FROSTED_GLASS_WHITE_ALPHA, 0.14);
  assert.equal(model.DEFAULT_GLASS_TINT_SHARE, 0.75);
  const reference = model.glassReferenceLuminance(null, null);
  const grey = REFERENCE_GREY / RGB_MAX;
  assert.ok(Math.abs(reference - model.relativeLuminance(grey, grey, grey)) < LUMINANCE_TOLERANCE);
  assert.equal(model.glassReferenceLuminance('rgba(0, 0, 0, 0)', null), reference, 'alpha 0 is the frosted default');
  assert.equal(model.glassReferenceLuminance('', undefined), reference);
});

test('static teal, red and blue reach 3:1 on the frosted reference with their hue', () => {
  for (const icon of [SYSTEM_TEAL, SYSTEM_RED, SYSTEM_BLUE]) {
    const lifted = lift(icon, null, null);
    assert.ok(contrast(lifted) >= model.MINIMUM_CONTRAST_RATIO - CONTRAST_TOLERANCE, `${icon} -> ${lifted}`);
    assert.ok(Math.abs(hue(lifted) - hue(icon)) <= HUE_TOLERANCE, `hue kept: ${icon}`);
    assert.ok(lightness(lifted) <= 1);
    assert.ok(lightness(lifted) >= lightness(icon), 'only lifted');
  }
});

test('a dark color is lifted and never above white; black becomes a grey', () => {
  const lifted = lift(DARK_TEAL, null, null);
  assert.ok(contrast(DARK_TEAL) < model.MINIMUM_CONTRAST_RATIO);
  assert.ok(contrast(lifted) >= model.MINIMUM_CONTRAST_RATIO - CONTRAST_TOLERANCE);
  assert.ok(Math.abs(hue(lifted) - hue(DARK_TEAL)) <= HUE_TOLERANCE);
  const black = lift(BLACK, null, null);
  assert.ok(contrast(black) >= model.MINIMUM_CONTRAST_RATIO - CONTRAST_TOLERANCE);
  const c = unit(black);
  for (const part of [c.red, c.green, c.blue]) assert.ok(part <= 1);
  // The alpha is kept.
  const translucent = lift('rgba(0, 64, 64, 0.5)', null, null);
  assert.equal(unit(translucent).alpha, 0.5);
});

test('an explicit glass tint is the reference, times its alpha and the tint alpha rule', () => {
  const blue = lift(SYSTEM_BLUE, EXPLICIT_TINT, null);
  assert.ok(contrast(blue, EXPLICIT_TINT, null) >= model.MINIMUM_CONTRAST_RATIO - CONTRAST_TOLERANCE);
  const selected = lift(SYSTEM_BLUE, EXPLICIT_TINT, TINT_ALPHA_FULL);
  assert.ok(contrast(selected, EXPLICIT_TINT, TINT_ALPHA_FULL) >= model.MINIMUM_CONTRAST_RATIO - CONTRAST_TOLERANCE);
  // (0.2, 0.6, 1) times alpha 0.8 times the default share 0.75 = 0.6.
  const share = 0.8 * TINT_ALPHA_DEFAULT_SHARE;
  const expected = model.relativeLuminance(0.2 * share, 0.6 * share, share);
  assert.ok(Math.abs(model.glassReferenceLuminance(EXPLICIT_TINT, null) - expected) < LUMINANCE_TOLERANCE / 2);
  assert.equal(model.glassReferenceLuminance(EXPLICIT_TINT, undefined), model.glassReferenceLuminance(EXPLICIT_TINT, null));
  // A tint alpha of 1 is a brighter reference than the default share.
  assert.ok(model.glassReferenceLuminance(EXPLICIT_TINT, TINT_ALPHA_FULL) > model.glassReferenceLuminance(EXPLICIT_TINT, null));
});

test('colors that already pass, or are invalid, are returned as they are', () => {
  assert.equal(lift(WHITE, null, null), WHITE);
  assert.ok(contrast(BRIGHT) >= model.MINIMUM_CONTRAST_RATIO);
  assert.equal(lift(BRIGHT, null, null), BRIGHT);
  assert.equal(lift('not a color', null, null), 'not a color');
  // The Mini Program has no per-mode colors, so there is no dynamic case: a static color is judged as it is.
});

test('the function is pure: the same input gives the same output', () => {
  const first = lift(SYSTEM_TEAL, null, null);
  const second = lift(SYSTEM_TEAL, null, null);
  assert.equal(first, second);
  assert.equal(lift(DARK_TEAL, EXPLICIT_TINT, 1), lift(DARK_TEAL, EXPLICIT_TINT, 1));
  // HSL round trip.
  const hsl = model.hslFromRgb(0.2, 0.6, 1);
  const rgb = model.rgbFromHsl(hsl.hue, hsl.saturation, hsl.lightness);
  assert.ok(Math.abs(rgb.red - 0.2) < 1e-9 && Math.abs(rgb.green - 0.6) < 1e-9 && Math.abs(rgb.blue - 1) < 1e-9);
});

// The tag: the symbol icon's SVG carries the drawn color.
const svgOf = (view) => Buffer.from(view.iconSrc.replace(/^data:image\/svg\+xml;base64,/, ''), 'base64').toString('utf8');
const strokeOf = (view) => /stroke="([^"]+)"/.exec(svgOf(view))[1];
const tagView = (tagStyle, { dark = true, selected = false } = {}) => model.tagButtonView(
  { title: 'A', image: 'system:star', selected, tagStyle }, '', 2, dark);
const GLASS = { backgroundStyle: 'liquidGlass' };

test('a dark glass tag with an explicit dark icon color lifts it; flat, light mode and an unset icon color do not', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const explicit = { normal: { iconColor: TAG_DARK_TEAL } };
  const lifted = strokeOf(tagView({ ...GLASS, ...explicit }));
  assert.notEqual(lifted, TAG_DARK_TEAL);
  assert.ok(contrast(lifted) >= model.MINIMUM_CONTRAST_RATIO - CONTRAST_TOLERANCE);
  assert.ok(Math.abs(hue(lifted) - hue(TAG_DARK_TEAL)) <= HUE_TOLERANCE);
  assert.equal(lifted, model.drawnIconColor(model.mergeStyle({ ...GLASS, ...explicit }, model.defaultStyle(2, true)), 'normal'));
  // Light mode and flat tags keep the app's color.
  assert.equal(strokeOf(tagView({ ...GLASS, ...explicit }, { dark: false })), TAG_DARK_TEAL);
  assert.equal(strokeOf(tagView({ backgroundStyle: 'flat', ...explicit })), TAG_DARK_TEAL);
  // Glass that is not drawn (the platform cannot) is flat.
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(false);
  assert.equal(strokeOf(tagView({ ...GLASS, ...explicit })), TAG_DARK_TEAL);
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  // An unset icon color is the built-in one (the title color): never lifted, even a dark title color.
  const darkTitle = '#001414';
  assert.equal(strokeOf(tagView({ ...GLASS, normal: { textColor: darkTitle } })), darkTitle);
  // An already passing explicit color is unchanged.
  assert.equal(strokeOf(tagView({ ...GLASS, normal: { iconColor: BRIGHT } })), BRIGHT);
});

test('a selected glass tag is judged against its own tint at alpha 1', () => {
  glass.cylAnimatedItemLiquidGlassSetActiveOverride(true);
  const tint = '#336699';
  const style = { ...GLASS, selected: { iconColor: SYSTEM_BLUE, backgroundColor: tint } };
  const drawn = strokeOf(tagView(style, { selected: true }));
  assert.notEqual(drawn, SYSTEM_BLUE);
  assert.ok(contrast(drawn, tint, TINT_ALPHA_FULL) >= model.MINIMUM_CONTRAST_RATIO - CONTRAST_TOLERANCE);
});
