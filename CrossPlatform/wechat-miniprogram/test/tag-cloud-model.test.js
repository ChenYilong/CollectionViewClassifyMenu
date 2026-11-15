// The tag cloud model (components/cyl-tag-cloud/model.js): the core's CYLMenuStyle presets, CYLTag, CYLTagColors,
// CYLTagButton metrics and CYLTagListView's rows and selection (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const model = require('cyl-tag-list-miniprogram/cyl-tag-cloud/model.js');

test('colors are read as UIColor.cylMenuColor(from:) reads them (#RRGGBBAA is red, green, blue, alpha)', () => {
  assert.equal(model.color('#00BFFF'), 'rgb(0, 191, 255)');
  assert.equal(model.color('#fff'), 'rgb(255, 255, 255)');
  assert.equal(model.color('#88363636'), 'rgba(136, 54, 54, 0.212)');
  assert.equal(model.color('systemOrange'), '#FF9500');
  assert.equal(model.color('systemPinkColor'), '#FF2D55');
  assert.equal(model.color('#12'), null);
  assert.equal(model.color(''), null);
});

test('CYLMenuStyle() has gray bordered tags, a green selection, 30 pt tags', () => {
  const style = model.defaultStyle();
  assert.equal(style.normal.backgroundColor, '#F2F2F7');
  assert.equal(style.normal.textColor, 'rgb(64, 64, 64)');
  assert.equal(style.normal.cornerRadius, 3);
  assert.equal(style.selected.backgroundColor, 'rgb(42, 185, 160)');
  assert.deepEqual(style.normal.contentInsets, { top: 5, left: 10, bottom: 5, right: 10 });
  assert.equal(style.itemHeight, 30);
  assert.equal(style.highlightedBackgroundColor, null);
  assert.equal(style.deleteIndicatorTitle, '×');
});

test('the tagCloud() and tagContainer() presets are android-tagview\'s and AndroidTagView\'s defaults', () => {
  const cloud = model.tagCloudStyle();
  assert.equal(cloud.normal.backgroundColor, 'rgb(0, 191, 255)');
  assert.equal(cloud.normal.cornerRadius, 0);
  assert.equal(cloud.normal.borderWidth, 0);
  assert.equal(cloud.highlightedBackgroundColor, 'rgba(54, 54, 54, 0.533)');
  assert.equal(cloud.interitemSpacing, 5);
  assert.equal(cloud.itemHeight, 0);
  const container = model.tagContainerStyle();
  assert.equal(container.normal.backgroundColor, 'rgba(244, 67, 54, 0.2)');
  assert.equal(container.normal.cornerRadius, 15);
  assert.equal(container.maximumTitleLength, 23);
  assert.equal(container.deleteIndicatorLineWidth, 1);
  assert.equal(container.deleteIndicatorPadding, 10);
  assert.equal(container.rippleColor, 'rgb(238, 238, 238)');
  assert.deepEqual(container.normal.contentInsets, { top: 8, left: 10, bottom: 8, right: 10 });
});

test('a style dictionary applies over CYLMenuStyle()', () => {
  const style = model.styleFromConfiguration({
    normal: { backgroundColor: '#00BFFF', textColor: '#FFFFFF', borderWidth: 0, cornerRadius: 0 },
    highlightedBackgroundColor: '#88363636',
    lineSpacing: 5,
    tagContentInsets: '{3, 10, 3, 10}',
  });
  assert.equal(style.normal.backgroundColor, 'rgb(0, 191, 255)');
  assert.equal(style.normal.cornerRadius, 0);
  assert.equal(style.selected.backgroundColor, 'rgb(42, 185, 160)');
  assert.equal(style.lineSpacing, 5);
  assert.deepEqual(style.disabled.contentInsets, { top: 3, left: 10, bottom: 3, right: 10 });
});

test('CYLTag(configuration:) reads the title, id, deletable, image and style', () => {
  assert.deepEqual(model.tagFromConfiguration('Asia'), { identifier: 0, title: 'Asia', isEnabled: true, isDeletable: false });
  const africa = model.tagFromConfiguration({ title: 'Africa', id: 3, deletable: true, style: { normal: { cornerRadius: 0 } } });
  assert.equal(africa.identifier, 3);
  assert.equal(africa.isDeletable, true);
  assert.equal(africa.style.normal.cornerRadius, 0);
  assert.equal(model.hasCustomStyle(africa), true);
  assert.equal(model.hasCustomStyle(model.makeTag('Asia')), false);
});

test('CYLTag.style(basedOn:) puts the colors on the normal state, the font, radius and border on every state', () => {
  const base = model.tagCloudStyle();
  const tag = model.makeTag('边框', { borderColor: 'red', textColor: 'blue', textSize: 22, cornerRadius: 4 });
  const style = model.tagStyle(tag, base);
  assert.equal(style.normal.borderColor, 'red');
  assert.equal(style.normal.borderWidth, 1, 'a border color alone gets a 1 pt border');
  assert.equal(style.normal.textColor, 'blue');
  assert.equal(style.selected.textColor, '#FFFFFF');
  assert.equal(style.selected.fontSize, 22);
  assert.equal(style.disabled.cornerRadius, 4);
  assert.equal(base.normal.fontSize, 14, 'the base style is not changed');
  const width = model.tagStyle(model.makeTag('边框', { borderWidth: 0, borderColor: 'red' }), base);
  assert.equal(width.normal.borderWidth, 0);
});

test('the color themes are ColorFactory\'s: random by position, pure cyan, pure teal', () => {
  assert.equal(model.themeColors('none', 0), null);
  const random = model.themeColors('random', 14);
  assert.equal(random.backgroundColor, 'rgba(3, 169, 244, 0.2)');
  assert.equal(random.borderColor, 'rgba(3, 169, 244, 0.533)');
  assert.equal(random.textColor, 'rgb(102, 102, 102)');
  assert.equal(model.themeColors('pureTeal', 3).backgroundColor, 'rgba(0, 150, 136, 0.2)');
  const style = model.applyColors(model.themeColors('pureCyan', 0), model.tagContainerStyle());
  assert.equal(style.normal.backgroundColor, 'rgba(0, 188, 212, 0.2)');
  assert.equal(style.selected.textColor, 'rgb(114, 114, 114)');
  assert.equal(style.selected.backgroundColor, 'rgb(102, 102, 102)');
  // A tag with its own colors ignores the theme.
  const own = model.setTagColors(model.makeTag('Custom Red Color'), { backgroundColor: 'rgb(255, 0, 0)', borderColor: '#000000' });
  assert.equal(model.styleForItem(own, 0, model.tagContainerStyle(), 'random').normal.backgroundColor, 'rgb(255, 0, 0)');
});

test('displayedTitle cuts after maximumTitleLength with "..." and reverses the characters', () => {
  const style = model.tagContainerStyle();
  assert.equal(model.displayedTitle(style, 'Welcome to use AndroidTagView!'), 'Welcome to use AndroidT...');
  assert.equal(model.displayedTitle(style, 'Java'), 'Java');
  style.maximumTitleLength = 18;
  style.reversesTitleCharacters = true;
  assert.equal(model.displayedTitle(style, 'Persian'), 'naisreP');
  assert.equal(model.displayedTitle(style, '你好'), '好你');
});

test('a tag is as tall as itemHeight or a line of its font plus its insets; 0 is a capsule', () => {
  assert.equal(model.tagHeight(model.defaultStyle()), 30);
  const cloud = model.setTagContentInsets(model.tagCloudStyle(), { top: 3, left: 10, bottom: 3, right: 10 });
  assert.equal(model.tagHeight(cloud), 23);
  assert.equal(model.tagHeight(model.tagContainerStyle()), 33);
  assert.equal(model.cornerRadius(0, 23), 11.5);
  assert.equal(model.cornerRadius(model.CORNER_RADIUS_SQUARE, 23), 0);
  assert.equal(model.cornerRadius(20, 30), 15);
  assert.equal(model.cornerRadius(3, 30), 3);
  assert.equal(model.crossIndicatorWidth(model.tagContainerStyle()), 33);
});

test('rows are filled in a single pass', () => {
  assert.deepEqual(model.rows([50, 50, 50], 120, 10), [2, 1]);
  assert.deepEqual(model.rows([200, 10], 120, 10), [1, 1]);
  assert.deepEqual(model.rows([], 120, 10), []);
});

test('selections follow inserted, removed and moved tags', () => {
  assert.deepEqual(model.shiftSelection([0, 2, 3], 2, 1), [0, 3, 4]);
  assert.deepEqual(model.removeSelection([0, 2, 3], 2), [0, 2]);
  assert.deepEqual(model.moveSelection([0, 1, 4], 0, 2), [2, 0, 4]);
  assert.deepEqual(model.moveItem(['a', 'b', 'c'], 0, 2), ['b', 'c', 'a']);
  assert.deepEqual(model.moveItem(['a', 'b'], 0, 5), ['a', 'b']);
  assert.deepEqual(model.toggleSelection([1], 3), [1, 3], 'a long press adds in none mode');
  assert.deepEqual(model.toggleSelection([1, 3], 1), [3]);
  assert.deepEqual(model.tapSelection([1], 2, 'none'), [1]);
  assert.deepEqual(model.tapSelection([1], 2, 'single'), [2]);
  assert.deepEqual(model.tapSelection([2], 2, 'single', false), [2]);
});

test('renderTag draws the box, the title, the icon and the delete indicator', () => {
  const style = model.tagContainerStyle();
  style.imageSize = 24;
  style.imageCornerRadius = 12;
  const item = model.renderTag(model.makeTag('Java', { isDeletable: true }), 0, {
    listStyle: style, theme: 'pureTeal', defaultTagImage: '/images/samples/avatar.png',
  });
  assert.equal(item.title, 'Java');
  assert.match(item.style, /height: 33px/);
  assert.match(item.style, /border-radius: 15px/);
  assert.match(item.style, /background-color: rgba\(0, 150, 136, 0.2\)/);
  assert.match(item.style, /box-shadow: inset 0 0 0 0.5px rgba\(0, 150, 136, 0.533\)/);
  assert.equal(item.icon.image, '/images/samples/avatar.png');
  assert.equal(item.icon.mode, 'aspectFill');
  assert.equal(item.deleteIndicator.cross, true);
  assert.equal(item.deleteFirst, false);
  assert.equal(item.rippleColor, 'rgba(238, 238, 238, 0.502)');
  const pressed = model.renderTag(model.makeTag('A'), 0, { listStyle: model.tagCloudStyle(), pressed: 0 });
  assert.match(pressed.style, /background-color: rgba\(54, 54, 54, 0.533\)/);
  const badge = model.renderTag(model.makeTag('他和她', { badgeText: '神', badgeAccessibilityLabel: '神曲', textColor: 'blue' }), 1,
    { listStyle: model.defaultStyle() });
  assert.equal(badge.icon.badge, '神');
  assert.equal(badge.accessibilityLabel, '他和她, 神曲');
  const list = model.renderList(model.tagCloudStyle(), { containerBorderWidth: 4, containerBorderColor: 'green' });
  assert.match(list.rootStyle, /border: 4px solid green/);
  assert.match(list.itemsStyle, /gap: 5px 5px/);
});
