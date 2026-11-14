// The example's tab bar configuration, read by CYLTabBarController's own configuration reader when it is installed
// (node scripts/fetch-cyltabbar.js); the page mapping always (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');
const { CONFIGURATION, pagePath, identifierForRoute } = require('../miniprogram/custom-tab-bar/configuration.js');
const app = require('../miniprogram/app.json');

test('every tab and the plus button have a page in the tab bar list of app.json', () => {
  const list = app.tabBar.list.map((entry) => `/${entry.pagePath}`);
  const identifiers = CONFIGURATION.CYLTabBarControllerTabBarItemsAttributes.map((item) => item.CYLTabBarItemIdentifier)
    .concat(CONFIGURATION.CYLTabBarControllerPlusButton.CYLTabBarItemPageIdentifier);
  assert.deepEqual(identifiers, ['tags', 'classify', 'post']);
  identifiers.forEach((identifier) => assert.ok(list.includes(pagePath(identifier)), identifier));
  assert.equal(app.tabBar.custom, true);
});

test('a page route maps back to its tab', () => {
  assert.equal(identifierForRoute('pages/classify/classify'), 'classify');
  assert.equal(identifierForRoute('/pages/post/post'), 'post');
  assert.equal(identifierForRoute('other'), '');
});

test('every image of the configuration is in the package', () => {
  const attributes = CONFIGURATION.CYLTabBarControllerTabBarItemsAttributes.concat(CONFIGURATION.CYLTabBarControllerPlusButton);
  attributes.forEach((item) => [item.CYLTabBarItemImage, item.CYLTabBarItemSelectedImage].forEach((image) => {
    assert.ok(fs.existsSync(path.join(__dirname, '..', 'miniprogram', 'images', image)), image);
  }));
});

const reader = path.join(__dirname, '..', 'miniprogram', 'cyl_components', 'cyl-tabbar-miniprogram', 'cyl-tab-bar',
  'cyl_configuration.js');

test('CYLTabBarController\'s reader shows Tags, the raised Post button, then Classify', { skip: !fs.existsSync(reader) && 'run node scripts/fetch-cyltabbar.js' }, () => {
  const cyl = require(reader);
  const read = cyl.cylReadConfiguration || cyl.cylTabBarModel || cyl.cylModel;
  assert.equal(typeof read, 'function', `exports: ${Object.keys(cyl).join(', ')}`);
  const model = read(CONFIGURATION, { imageBasePath: '/images' });
  assert.deepEqual(model.items.map((item) => item.identifier), ['tags', 'classify']);
  assert.equal(model.items[0].image, '/images/tab/tag.png');
  assert.ok(model.plusButton, 'plus button');
  assert.equal(model.plusButton.identifier, 'post');
  assert.equal(model.plusButton.hasPage, true);
});
