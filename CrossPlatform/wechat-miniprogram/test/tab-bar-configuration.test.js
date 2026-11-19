// The example's root tab bar (1:1 with the iOS example's makeRootTabBarController), read by CYLTabBarController's own
// configuration reader when it is installed (node scripts/fetch-cyltabbar.js); the page mapping always (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');
const { CONFIGURATION, pagePath, identifierForRoute } = require('../miniprogram/custom-tab-bar/configuration.js');
const app = require('../miniprogram/app.json');

test('the four tabs and the plus button\'s page are the tab bar list of app.json', () => {
  const list = app.tabBar.list.map((entry) => `/${entry.pagePath}`);
  const identifiers = CONFIGURATION.CYLTabBarControllerTabBarItemsAttributes.map((item) => item.CYLTabBarItemIdentifier);
  assert.deepEqual(identifiers, ['product', 'search-home', 'styles', 'animations']);
  const plus = CONFIGURATION.CYLTabBarControllerPlusButton;
  assert.equal(plus.CYLTabBarItemPageIdentifier, 'scenarios');
  assert.equal(plus.CYLPlusButtonIndexInTabBar, 2);
  assert.equal(plus.CYLTabBarItemTitle, undefined, 'the iOS plus button has an image only');
  identifiers.concat('scenarios').forEach((identifier) => assert.ok(list.includes(pagePath(identifier)), identifier));
  assert.equal(app.tabBar.custom, true);
  app.pages.forEach((page) => assert.ok(fs.existsSync(path.join(__dirname, '..', 'miniprogram', `${page}.js`)), page));
});

test('the tab titles are the iOS example\'s strings', () => {
  const titles = CONFIGURATION.CYLTabBarControllerTabBarItemsAttributes.map((item) => item.CYLTabBarItemTitle);
  assert.deepEqual(titles, ['场景一：评价筛选', '场景二：搜索分类', '样式', '动效']);
});

test('a page route maps back to its tab; the scenario list is the plus button\'s', () => {
  assert.equal(identifierForRoute('pages/search-home/search-home'), 'search-home');
  assert.equal(identifierForRoute('/pages/scenarios/scenarios'), 'plus');
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

test('CYLTabBarController\'s reader shows the four tabs and the plus button with its page', { skip: !fs.existsSync(reader) && 'run node scripts/fetch-cyltabbar.js' }, () => {
  const { cylReadConfiguration } = require(reader);
  const model = cylReadConfiguration(CONFIGURATION, { imageBasePath: '/images' });
  assert.deepEqual(model.items.map((item) => item.identifier), ['product', 'search-home', 'styles', 'animations']);
  assert.equal(model.items[0].image, '/images/tab/cart.png');
  assert.equal(model.plusButton.identifier, 'plus');
  assert.equal(model.plusButton.pageIdentifier, 'scenarios');
  assert.equal(model.plusButton.hasPage, true);
});
