// The standalone cyl-tag-button (the core's CYLTagButton on its own): the icon above or below the title, no room for a
// missing icon or title, the badge, and the view data the component draws (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const model = require('cyl-tag-list-miniprogram/cyl-tag-list/model.js');
const locale = require('cyl-tag-list-miniprogram/locale.js');

test('imagePlacement top and bottom stack the icon and the title (raw values 2 and 3)', () => {
  assert.equal(model.mergeStyle({ imagePlacement: 'top' }).imagePlacement, 'top');
  assert.equal(model.mergeStyle({ imagePlacement: 2 }).imagePlacement, 'top');
  assert.equal(model.mergeStyle({ imagePlacement: 'bottom' }).imagePlacement, 'bottom');
  assert.equal(model.mergeStyle({ imagePlacement: 3 }).imagePlacement, 'bottom');
  assert.equal(model.mergeStyle({ imagePlacement: 1 }).imagePlacement, 'trailing', 'existing values keep their meaning');
  const top = model.mergeStyle({ imagePlacement: 'top', imageSize: '{24, 24}', imageTitleSpacing: 4 });
  const side = model.mergeStyle({ imageSize: '{24, 24}', imageTitleSpacing: 4 });
  assert.equal(model.tagHeight(top), model.tagHeight(side) - 30 + Math.max(30, 17 + 24 + 4 + 10),
    'the icon slot and the spacing are part of the height');
  const tag = model.tagLayout(top, { title: '消息', enabled: true }, 'normal', { kind: 'image' }, 0, 0);
  assert.match(tag.cellStyle, /flex-direction: column;/);
  assert.match(tag.cellStyle, /align-items: center/);
  assert.match(tag.cellStyle, /justify-content: center/);
  assert.match(tag.slotStyle, /margin-bottom: 4px/);
  const bottom = model.mergeStyle({ imagePlacement: 'bottom', imageTitleSpacing: 4 });
  const below = model.tagLayout(bottom, { title: '消息', enabled: true }, 'normal', { kind: 'image' }, 0, 0);
  assert.match(below.cellStyle, /flex-direction: column-reverse/);
  assert.match(below.slotStyle, /margin-top: 4px/);
});

test('an icon-only or title-only tag reserves no spacing for the missing part', () => {
  const top = model.mergeStyle({ imagePlacement: 'top', imageSize: '{24, 24}', imageTitleSpacing: 4 });
  const style = model.mergeStyle({});
  assert.equal(model.tagHeightForTitle(top, '首页', null), model.tagHeightForTitle(style, '首页', null),
    'no icon slot for a lone title');
  assert.equal(model.tagHeightForTitle(top, '', { width: 24, height: 24 }), Math.max(30, 24 + 10),
    'no title line for a lone icon');
  const lone = model.tagLayout(top, { title: '', enabled: true }, 'normal', { kind: 'image' }, 0, 0);
  assert.match(lone.slotStyle, /margin-bottom: 0px/);
});

test('the badge: null hides it, an empty string is a dot, other text a capsule in badgeColor', () => {
  assert.equal(model.badgeLayout(null).showsBadge, false);
  assert.equal(model.badgeLayout(undefined).showsBadge, false);
  locale.setLanguage('en');
  const dot = model.badgeLayout('');
  assert.equal(dot.showsBadge, true);
  assert.equal(dot.badgeText, '');
  assert.match(dot.badgeStyle, /width: 8px; height: 8px/);
  assert.match(dot.badgeStyle, /background-color: #FF3B30/, 'system red by default');
  assert.match(dot.badgeStyle, /left: calc\(100% - 4px\); top: -4px/, 'on the top trailing corner');
  assert.equal(dot.badgeAccessibilityValue, 'New');
  const capsule = model.badgeLayout('99+', '#0000FF');
  assert.equal(capsule.badgeText, '99+');
  assert.match(capsule.badgeStyle, /min-width: 16px; height: 16px; padding: 0 4px/);
  assert.match(capsule.badgeStyle, /background-color: #0000FF/);
  assert.equal(capsule.badgeAccessibilityValue, '99+');
  locale.setLanguage('zh-Hans');
  assert.equal(model.badgeLayout('').badgeAccessibilityValue, '新');
});

test('tagButtonView: the tag at its own height, the badge and a label that reads the title, then the badge', () => {
  locale.setLanguage('en');
  const view = model.tagButtonView({ title: 'Messages', image: '/icons/message.png', badgeValue: '3', selected: true,
    enabled: true, tagStyle: { imagePlacement: 'top', imageSize: '{24, 24}' } }, null);
  assert.equal(view.iconKind, 'image');
  assert.equal(view.iconSrc, '/icons/message.png');
  assert.equal(view.showsBadge, true);
  assert.equal(view.accessibilityLabel, 'Messages, 3');
  assert.match(view.cellStyle, /flex-direction: column/);
  assert.equal(view.height, model.tagHeightForTitle(model.mergeStyle({ imagePlacement: 'top', imageSize: '{24, 24}' }),
    'Messages', { width: 24, height: 24 }));
  const iconOnly = model.tagButtonView({ image: '/icons/house.png', badgeValue: null, enabled: false }, null);
  assert.equal(iconOnly.showsTitle, false);
  assert.equal(iconOnly.showsBadge, false);
  assert.equal(iconOnly.height, 30);
  assert.match(iconOnly.cellStyle, /color: #B3B3B3/, 'disabled');
  locale.setLanguage('zh-Hans');
});

test('allowsTransparentBackground keeps a transparent tag (a search bar item); a tag list keeps its opaque fill', () => {
  const list = model.mergeStyle({ normal: { backgroundColor: 'transparent' }, selected: { backgroundColor: '#FFFFFF00' } });
  assert.equal(list.allowsTransparentBackground, false);
  assert.equal(list.normal.backgroundColor, model.DEFAULT_TAG_BACKGROUND, 'the tag list default is unchanged');
  assert.equal(list.selected.backgroundColor, model.DEFAULT_TAG_BACKGROUND);
  const clear = model.mergeStyle({
    allowsTransparentBackground: true,
    normal: { backgroundColor: 'transparent', borderWidth: 0 },
    selected: { backgroundColor: 'clear' },
    disabled: { backgroundColor: '#FF000000' },
  });
  assert.equal(clear.allowsTransparentBackground, true);
  assert.equal(clear.normal.backgroundColor, 'transparent');
  assert.equal(clear.selected.backgroundColor, 'transparent');
  assert.equal(clear.disabled.backgroundColor, 'transparent', 'zero alpha is transparent');
  assert.equal(model.mergeStyle({ allowsTransparentBackground: true, normal: { backgroundColor: '#E5E5EA' } })
    .normal.backgroundColor, '#E5E5EA', 'an opaque color is kept');
  assert.equal(model.mergeStyle({ allowsTransparentBackground: true, normal: { backgroundColor: 'nope' } })
    .normal.backgroundColor, model.DEFAULT_TAG_BACKGROUND, 'an invalid color is still the default fill');
  const view = model.tagButtonView({
    title: 'Search', tagStyle: { allowsTransparentBackground: 'true', normal: { backgroundColor: 'transparent', borderWidth: 0 } },
  }, null, 2);
  assert.match(view.cellStyle, /background-color: transparent/);
});
