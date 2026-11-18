/**
 * cyl-tag-cloud's editing mode and cache, and the sixth container's options (iOS d6a94ce9 and 00760142; Android
 * CYLTagListEditingTest; HarmonyOS TagListEditing.test.ets): the store of every policy (in memory without `wx`, as in
 * node), delete indicators on every enabled tag while editing, the cross image, the elevation and wrapping titles.
 */
const test = require('node:test');
const assert = require('node:assert');
const model = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-cloud/model.js');
const { CYLTagListStore } = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-cloud/cache.js');

test('every cache policy saves, reads back from a new store, keeps an emptied section and removes all', () => {
  for (const policy of ['database', 'userDefaults', 'sandboxFile']) {
    const name = `tag-cloud-editing.${policy}`;
    new CYLTagListStore(policy, name).removeAllTitles();
    const store = CYLTagListStore.cache(policy, name);
    assert.equal(store.cachedTitles('0'), undefined, `nothing saved yet, ${policy}`);
    store.saveTitles(['Clients', 'Family', 'Friends'], '0');
    // A new store of the same policy and name reads it back, as after a relaunch.
    const reopened = new CYLTagListStore(policy, name);
    assert.deepEqual(reopened.cachedTitles('0'), ['Clients', 'Family', 'Friends'], policy);
    reopened.saveTitles([], '0');
    assert.deepEqual(reopened.cachedTitles('0'), [], 'an emptied section differs from none');
    reopened.removeTitles('0');
    assert.equal(reopened.cachedTitles('0'), undefined);
    reopened.saveTitles(['A'], '1');
    reopened.removeAllTitles();
    assert.equal(reopened.cachedTitles('1'), undefined);
  }
  assert.equal(CYLTagListStore.cache('none', 'x'), null);
  assert.equal(new CYLTagListStore('database', '').name, 'CYLTagListView');
  // The policies keep separate entries.
  new CYLTagListStore('database', 'same').saveTitles(['db'], '0');
  new CYLTagListStore('userDefaults', 'same').saveTitles(['defaults'], '0');
  assert.deepEqual(new CYLTagListStore('database', 'same').cachedTitles('0'), ['db']);
});

test('editing shows the delete indicator on every enabled tag, not on a disabled one', () => {
  const style = model.tagCloudStyle();
  const tag = model.makeTag('Family');
  assert.equal(model.renderTag(tag, 0, { listStyle: style }).deleteIndicator, null, 'not deletable outside editing');
  assert.ok(model.renderTag(tag, 0, { listStyle: style, editing: true }).deleteIndicator, 'deletable while editing');
  const disabled = model.makeTag('Off', { isEnabled: false });
  assert.equal(model.renderTag(disabled, 0, { listStyle: style, editing: true }).deleteIndicator, null);
});

test('a cross image keeps the line height and takes the padding only beside it', () => {
  const style = model.tagCloudStyle();
  style.deleteIndicatorImage = '/images/cross.png';
  style.deleteIndicatorPadding = 4;
  const tag = model.makeTag('End', { isDeletable: true });
  const indicator = model.renderTag(tag, 0, { listStyle: style }).deleteIndicator;
  assert.equal(indicator.image, '/images/cross.png');
  const side = Math.ceil(model.lineHeight(style.normal.fontSize));
  assert.match(indicator.imageStyle, new RegExp(`width: ${side}px; height: ${side}px`));
  assert.match(indicator.boxStyle, new RegExp(`width: ${side + 8}px`));
  assert.equal(indicator.cross, false);
});

test('elevation draws a shadow and stops clipping; titleWraps lets the title wrap and the tag grow', () => {
  const style = model.tagCloudStyle();
  style.elevation = 4;
  style.titleWraps = true;
  const tag = model.renderTag(model.makeTag('A long tag that wraps onto a second line'), 0, { listStyle: style });
  assert.match(tag.style, /box-shadow: [^;]*0 2px 4px rgba\(0, 0, 0, 0\.25\)/);
  assert.match(tag.style, /overflow: visible/);
  assert.match(tag.style, /min-height: \d+px; height: auto/);
  assert.match(tag.style, /white-space: normal/);
  assert.match(tag.titleStyle, /white-space: normal/);
  const plain = model.renderTag(model.makeTag('Short'), 0, { listStyle: model.tagCloudStyle() });
  assert.doesNotMatch(plain.style, /overflow: visible|height: auto/);
  const d = model.defaultStyle();
  assert.deepEqual([d.titleWraps, d.elevation, d.deleteIndicatorImage], [false, 0, null]);
});
