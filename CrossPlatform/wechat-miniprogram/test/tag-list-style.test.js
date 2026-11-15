// The cyl-tag-list model's style, icons, animations and tag layout: the keys and defaults of the core's
// CYLMenuStyle / CYLTagAppearance / CYLTagButton (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const model = require('../miniprogram/components/cyl-tag-list/model.js');
const symbols = require('../miniprogram/components/cyl-tag-list/symbols.js');
const animations = require('../miniprogram/components/cyl-tag-list/animations.js');

test('the default style is CYLMenuStyle(): hairline gray borders, green selection with white titles, gray disabled tags', () => {
  const s = model.normalize({}, { pixelRatio: 3 }).style;
  assert.equal(s.normal.textColor, '#404040');
  assert.equal(s.normal.borderColor, '#D1D1D1');
  assert.equal(s.normal.borderWidth, 1 / 3);
  assert.equal(s.normal.cornerRadius, 3);
  assert.deepEqual([s.selected.backgroundColor, s.selected.textColor], ['#2AB9A0', '#FFFFFF']);
  assert.equal(s.disabled.textColor, '#B3B3B3');
  assert.equal(s.layoutCentered, true);
  assert.equal(s.animationSpeed, 1);
  assert.equal(s.headerTextColor, '#808080');
  assert.equal(model.normalize({}).style.normal.borderWidth, 0.5);
});

test('values are read like CYLConfigurationValue: colors, sizes, offsets, insets, fonts and booleans from strings', () => {
  assert.equal(model.color('#abc'), '#AABBCC');
  assert.equal(model.color('#FF950026'), 'rgba(255, 149, 0, 0.149)');
  assert.equal(model.color('systemIndigo'), '#5856D6');
  assert.equal(model.color('systemBlueColor'), '#007AFF');
  assert.equal(model.color('nonsense'), null);
  assert.deepEqual(model.sizeValue('{20, 22}'), { width: 20, height: 22 });
  assert.deepEqual(model.sizeValue(16), { width: 16, height: 16 });
  assert.deepEqual(model.offsetValue('{0, -4}'), { horizontal: 0, vertical: -4 });
  assert.deepEqual(model.insetsValue([3, 3, 3, 3]), { top: 3, left: 3, bottom: 3, right: 3 });
  assert.deepEqual(model.fontValue({ size: 14, weight: 'Semibold' }), { size: 14, weight: 'semibold', italic: false, name: '' });
  assert.equal(model.fontName({ size: 15, weight: 'regular', italic: true }), '.SFUI-RegularItalic');
  assert.equal(model.boolValue('yes'), true);
  assert.equal(model.normalize({ allowsEmptySelection: 'false' }).allowsEmptySelection, false);
});

test('mergeStyle applies the appearances, then the style keys, then tagContentInsets, as applyConfiguration does', () => {
  const s = model.mergeStyle({
    normal: { iconColor: 'systemBlue', margin: 12, cornerRadius: 0, font: { size: 14, weight: 'medium' } },
    selected: { backgroundColor: '#FF6A00', textColor: '#FFFFFF', borderColor: '#FF6A00', borderWidth: 1 },
    imageSize: '{22, 22}', imageInsets: '{3, 3, 3, 3}', titlePositionAdjustment: '{4, 0}',
    imagePositionAdjustment: [0, -4], layoutCentered: 'NO', animationSpeed: '0.5', headerTextColor: '#8E8E93',
  });
  assert.equal(s.normal.iconColor, '#007AFF');
  assert.deepEqual(s.normal.contentInsets, { top: 5, left: 12, bottom: 5, right: 12 });
  assert.equal(s.normal.font.weight, 'medium');
  assert.equal(s.selected.backgroundColor, '#FF6A00');
  assert.deepEqual([s.imageSize, s.imageHeight], [22, 22]);
  assert.deepEqual(s.imageInsets, { top: 3, left: 3, bottom: 3, right: 3 });
  assert.deepEqual(s.titlePositionAdjustment, { horizontal: 4, vertical: 0 });
  assert.deepEqual(s.imagePositionAdjustment, { horizontal: 0, vertical: -4 });
  assert.equal(s.layoutCentered, false);
  assert.equal(s.animationSpeed, 0.5);
  assert.equal(s.headerTextColor, '#8E8E93');
  const insets = model.mergeStyle({ normal: { margin: 20 }, tagContentInsets: [2, 6, 2, 6] });
  assert.deepEqual(insets.normal.contentInsets, { top: 2, left: 6, bottom: 2, right: 6 });
  assert.deepEqual(insets.disabled.contentInsets, { top: 2, left: 6, bottom: 2, right: 6 });
});

test('a section style applies over the list style; plain values are item titles; selectedItems accept pairs', () => {
  const m = model.normalize({
    style: { itemHeight: 44, selected: { textColor: '#FF6A00' } },
    selectedItems: [[1, 0], '0-1'],
    sections: [
      { title: 'A', items: ['Text only', { title: 'b', enabled: 'false', animationRestingProgress: 2 }] },
      { title: 'B', style: { normal: { backgroundColor: '#17203A' } }, items: [{ title: 'c' }] },
    ],
  });
  assert.equal(m.sections[0].items[0].title, 'Text only');
  assert.equal(m.sections[0].items[1].enabled, false);
  assert.equal(m.sections[0].items[1].animationRestingProgress, 1);
  assert.equal(m.sections[1].style.normal.backgroundColor, '#17203A');
  assert.equal(m.sections[1].style.itemHeight, 44);
  assert.equal(m.sections[1].style.selected.textColor, '#FF6A00');
  assert.equal(m.sections[0].style.normal.backgroundColor, '#F2F2F7');
  assert.deepEqual(m.selectedItems, ['1-0', '0-1']);
  assert.equal(m.showsSectionHeaders, true);
  assert.equal(model.normalize({ showsSectionHeaders: false }).showsSectionHeaders, false);
});

test('the fold control reads a dictionary or a position alone, as CYLMenuFoldControl(configuration:)', () => {
  assert.deepEqual(model.foldControlValue({ position: 'footer', content: 'iconAndTitle' }).position, 'footer');
  assert.equal(model.foldControlValue({ position: 'footer', content: 'iconAndTitle' }).content, 'iconAndTitle');
  assert.equal(model.foldControlValue('footer').content, 'icon');
  assert.equal(model.foldControlValue('headerRight').position, 'headerTrailing');
  assert.equal(model.foldControlValue('headerRight').content, 'iconAndTitle');
});

test('a disabled tag uses the disabled appearance; the icon color is iconColor, else the text color', () => {
  const style = model.mergeStyle({ normal: { iconColor: 'systemBlue' } });
  assert.equal(model.stateOf({ enabled: false }, true), 'disabled');
  assert.equal(model.stateOf({ enabled: true }, true), 'selected');
  assert.equal(model.iconColor(style, 'normal'), '#007AFF');
  assert.equal(model.iconColor(style, 'disabled'), '#B3B3B3');
});

test('icons: the selected image while selected, SF Symbols tinted as SVG, emoji for names without a drawing', () => {
  const style = model.mergeStyle({ normal: { iconColor: '#007AFF' }, selected: { iconColor: '#FFFFFF' } });
  const item = { image: 'system:house', selectedImage: 'system:house.fill' };
  const normal = model.iconContent(item, 'normal', style, null);
  assert.equal(normal.kind, 'image');
  assert.equal(normal.src, symbols.symbolURI('house', '#007AFF'));
  assert.equal(model.iconContent(item, 'selected', style, null).src, symbols.symbolURI('house.fill', '#FFFFFF'));
  assert.equal(model.iconContent({ image: 'system:gearshape' }, 'normal', style, null).glyph, '⚙️');
  assert.equal(model.iconContent({ image: '/images/a.png' }, 'normal', style, null).src, '/images/a.png');
  assert.equal(model.iconContent({ image: 'system:house' }, 'normal', style, { engine: 'lottie' }).kind, 'animation');
  assert.equal(model.iconContent({}, 'normal', style, null).kind, 'none');
  const svg = Buffer.from(symbols.symbolURI('star', '#FF9500').split(',')[1], 'base64').toString('ascii');
  assert.match(svg, /stroke="#FF9500"/);
  assert.equal(symbols.base64('ab'), Buffer.from('ab').toString('base64'));
});

test('animations resolve by engine and file, and a missing engine or file falls back to the image (reloadAnimationView)', () => {
  assert.equal(model.animationEngine('pag-ios/0.pag'), 'pag');
  assert.equal(model.animationEngine('x/house.riv#artboard=A'), 'rive');
  assert.equal(model.animationKey('../Animations/Lottie/tab_home_animate.json'), 'Lottie/tab_home_animate.json');
  assert.equal(model.animationKey('CYLMenuExample.bundle/Animations/GIF/tab_star.gif'), 'GIF/tab_star.gif');
  const registry = { 'GIF/a.gif': { engine: 'gif' }, 'Rive/b.riv': { engine: 'rive' } };
  assert.equal(model.resolveAnimation('Animations/GIF/a.gif', registry, { gif: true }).engine, 'gif');
  assert.equal(model.resolveAnimation('Rive/b.riv', registry, { gif: true, rive: false }), null);
  assert.equal(model.resolveAnimation('GIF/missing.gif', registry, { gif: true }), null);
  assert.equal(model.resolveAnimation('asset:home', {}, { lottie: true }, { home: {} }).engine, 'lottie');
  // The package's engines: Lottie, GIF, Rive and PAG (in the engines subpackage) linked.
  assert.equal(animations.isAnimationEngineAvailable, true);
  assert.equal(animations.resolve('CYLMenuExample.bundle/Animations/Lottie/green_lottie_tab_home.json').engine, 'lottie');
  assert.equal(animations.resolve('../Animations/GIF/tab_star.gif').entry.last, '/data/animations/gif/tab_star.last.png');
  assert.equal(animations.resolve('pag-ios/0.pag').entry.src, '/engines/pag/0.pag.bin');
  assert.equal(animations.resolve('CYLMenuExample.bundle/Animations/Rive/house.riv').entry.src, '/data/animations/rive/house.riv.bin');
  const gray = animations.resolve('Lottie/gray_tabbar_home_animation.json').entry.data();
  assert.ok(gray.assets.filter((a) => a.p).every((a) => a.e === 1 && a.p.startsWith('data:image/png;base64,')));
});

test('tag layout: capsule for corner radius 0, insets with the border inside, imageInsets shrink the icon from the top left', () => {
  const style = model.mergeStyle({
    itemHeight: 44, imageSize: '{28, 28}', imageTitleSpacing: 6, imageInsets: [3, 3, 3, 3],
    normal: { cornerRadius: 0, margin: 12, borderColor: '#D1D1D6', borderWidth: 1 },
    selected: { cornerRadius: 0, margin: 12, borderWidth: 1 },
    titlePositionAdjustment: '{4, -2}',
  });
  const item = { title: '首页', enabled: true };
  const tag = model.tagLayout(style, item, 'normal', { kind: 'image' }, 10, 10);
  assert.match(tag.cellStyle, /border-radius: 22px/);
  assert.match(tag.cellStyle, /padding: 0 11px 0 11px/);
  assert.match(tag.cellStyle, /height: 44px/);
  assert.match(tag.slotStyle, /width: 28px; height: 28px; margin-right: 6px/);
  assert.equal(tag.iconStyle, 'width: 22px; height: 22px');
  assert.equal(tag.titleStyle, 'left: 4px; top: -2px');
  assert.equal(model.cornerRadius(8, 36), 8);
  assert.equal(model.cornerRadius(0.001, 36), 0);
  assert.equal(model.cornerRadius(40, 36), 18);
});

test('a lone title keeps its place after an empty icon slot unless layoutCentered; the widest state sets the width', () => {
  const off = model.mergeStyle({ layoutCentered: false, imageSize: 16, imageTitleSpacing: 4 });
  const lone = model.tagLayout(off, { title: 'a', enabled: true }, 'normal', { kind: 'none' }, 10, 10);
  assert.equal(lone.spacerStyle, 'width: 20px');
  assert.match(lone.cellStyle, /justify-content: flex-start/);
  const on = model.tagLayout(model.mergeStyle({}), { title: 'a', enabled: true }, 'normal', { kind: 'none' }, 10, 10);
  assert.equal(on.spacerStyle, '');
  assert.match(on.cellStyle, /justify-content: center/);
  const wide = model.mergeStyle({ normal: { margin: 4 }, selected: { margin: 18 } });
  assert.match(model.tagLayout(wide, { title: 'a', enabled: true }, 'normal', { kind: 'none' }, 10, 10).cellStyle,
    /padding: 0 17.5px 0 17.5px/);
  const fonts = model.mergeStyle({ normal: { font: { size: 14, weight: 'medium' } }, selected: { font: { size: 14, weight: 'semibold' } } });
  assert.equal(model.sizerFonts(fonts, 'normal').length, 2);
  assert.equal(model.sizerFonts(model.mergeStyle({}), 'normal').length, 0);
});

test('coderString writes sizes, offsets and insets as NSCoder.string(for:)', () => {
  assert.equal(model.coderString({ width: 16, height: 16 }), '{16, 16}');
  assert.equal(model.coderString({ horizontal: 0, vertical: -4 }), '{0, -4}');
  assert.equal(model.coderString({ top: 0, left: 0, bottom: 0, right: 0 }), '{0, 0, 0, 0}');
});

test('a tag background is never transparent: the default is systemGray6, and clear falls back to it', () => {
  assert.equal(model.normalize({}).style.normal.backgroundColor, '#F2F2F7');
  assert.equal(model.normalize({}).style.disabled.backgroundColor, '#F2F2F7');
  for (const clear of ['clear', 'transparent', '#00000000', 'clearColor']) {
    assert.equal(model.mergeStyle({ normal: { backgroundColor: clear } }).normal.backgroundColor, '#F2F2F7', clear);
  }
  assert.equal(model.mergeStyle({ normal: { backgroundColor: '#FF0000' } }).normal.backgroundColor, '#FF0000');
});
