// The review list's and the product page's state (CYLReviewListViewController, CYLProductViewController), without wx.
const test = require('node:test');
const assert = require('node:assert/strict');
const list = require('../miniprogram/pages/reviews/list.js');
const preview = require('../miniprogram/pages/product/preview.js');
const model = require('cyl-tag-list-miniprogram/cyl-tag-list/model.js');

test('the filter configuration: multiple choice, 全部 exclusive, empty filters disabled, two rows', () => {
  const configuration = list.filterConfiguration(['0-0'], false);
  assert.equal(configuration.selectionMode, 'multiple');
  assert.equal(configuration.defaultVisibleRows, 2);
  assert.equal(configuration.foldControl.position, 'footer');
  const items = configuration.sections[0].items;
  assert.equal(items.length, 12);
  assert.deepEqual(items.filter((i) => i.exclusive).map((i) => i.title), ['全部']);
  assert.deepEqual(items.filter((i) => !i.enabled).map((i) => i.title), ['差评(0)']);
  assert.equal(items[1].image, '/images/reviews/hand-thumbsup-fill.png');
  const style = model.normalize(configuration).style;
  assert.equal(style.itemHeight, 28);
  assert.equal(style.fontSize, 12);
  assert.deepEqual(style.sectionInsets, { top: 10, left: 12, bottom: 6, right: 12 });
  assert.deepEqual(style.contentInsets, { top: 5, left: 8, bottom: 5, right: 8 });
  assert.equal(style.selected.backgroundColor, '#FF4F00');
});

test('taps follow CYLTagListView: a filter replaces 全部, 全部 replaces every filter', () => {
  const m = model.normalize(list.filterConfiguration(['0-0'], false));
  let result = model.tap(m, ['0-0'], '0-4');
  assert.deepEqual(result.selectedItems, ['0-4']);
  result = model.tap(m, result.selectedItems, '0-1');
  assert.deepEqual(result.selectedItems, ['0-4', '0-1']);
  assert.deepEqual(model.tap(m, result.selectedItems, '0-0').selectedItems, ['0-0']);
  // Deselecting the last filter leaves nothing selected; the page then selects 全部.
  assert.deepEqual(model.tap(m, ['0-4'], '0-4').selectedItems, []);
  assert.equal(model.tap(m, ['0-0'], '0-3').changed, false);
});

test('selectFilterIndexes selects like selectItem(at:), filters in ascending order', () => {
  let selection = ['0-0'];
  [4, 1].forEach((i) => { selection = list.selectItem(selection, i); });
  assert.deepEqual(selection, ['0-4', '0-1']);
  assert.deepEqual(list.sortedSelection(selection), ['0-1', '0-4']);
  assert.deepEqual(list.selectedFilters(selection).map((f) => f.identifier), ['good', 'photo']);
  assert.deepEqual(list.selectItem(selection, 0), ['0-0']);
  assert.deepEqual(list.selectItem(selection, 99), selection);
  assert.deepEqual(list.selectedFilters(['0-0']), []);
});

test('launch options', () => {
  assert.equal(list.initialIndex(undefined), 0);
  assert.equal(list.initialIndex('9'), 9);
  assert.equal(list.initialIndex('40'), 11);
  assert.equal(list.initialIndex('-2'), 0);
  assert.deepEqual(list.parseIndexes('1%2C4'), [1, 4]);
  assert.deepEqual(list.parseIndexes(''), []);
});

test('a review cell and the fold control label', () => {
  const row = list.reviewRow({ id: 3, user: 'u', text: 'x', date: '2015-06-13', sku: 's' });
  assert.deepEqual(row, { id: 3, user: 'u', secondary: 'x\n2015-06-13 s', label: 'u, x\n2015-06-13 s' });
  assert.equal(list.foldAccessibilityLabel(false, 'zh-Hans'), '评价 更多');
  assert.equal(list.foldAccessibilityLabel(true, 'zh-Hans'), '评价 收起');
});

test('the product page previews the keywords and opens the review page with the tapped one', () => {
  assert.deepEqual(preview.previewFilterIndexes(), [6, 7, 8, 9, 10, 11]);
  const configuration = preview.previewConfiguration();
  assert.equal(configuration.selectionMode, 'none');
  assert.equal(configuration.defaultVisibleRows, 2);
  assert.equal(configuration.foldControl.position, 'none');
  assert.deepEqual(configuration.style.sectionInsets, { top: 4, left: 0, bottom: 12, right: 0 });
  assert.deepEqual(configuration.sections[0].items.map((i) => i.title),
    ['手机套不错(3)', '质量不错(5)', '态度不错(3)', '划算(3)', '颜色不错(2)', '背面细节一般(2)']);
  assert.deepEqual(preview.previewReviews().map((r) => r.text.split('\n')[0]), ['1**1', '雨**4']);
  assert.equal(preview.reviewsURL(9), '/pages/reviews/reviews?filter=9');
});
