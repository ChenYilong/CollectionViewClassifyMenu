// The data of the tag cloud demo and the Android sample ports (pages/tag-cloud, pages/sample-tag-cloud,
// pages/sample-tag-container), the shared sample helpers and the core strings (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const i18n = require('../miniprogram/utils/i18n.js');
const model = require('cyl-tag-list-miniprogram/cyl-tag-cloud/model.js');
const demo = require('../miniprogram/pages/tag-cloud/data.js');
const cloud = require('../miniprogram/pages/sample-tag-cloud/data.js');
const container = require('../miniprogram/pages/sample-tag-container/data.js');
const sample = require('../miniprogram/utils/android-sample.js');
const { coreString, joinList } = require('cyl-tag-list-miniprogram/core-strings.js');

const ROOT = path.join(__dirname, '..', 'miniprogram');
const PACKAGE = path.join(__dirname, '..', 'packages', 'cyl-tag-list-miniprogram', 'miniprogram_dist');
const NPM_NAME = 'cyl-tag-list-miniprogram/';

/** A usingComponents path: the library's from its package, the example's from miniprogram/. */
function componentFile(component) {
  if (component.startsWith(NPM_NAME)) return path.join(PACKAGE, `${component.slice(NPM_NAME.length)}.js`);
  return path.join(ROOT, `${component}.js`);
}

test('the tag cloud demo: seven continents, the detailed tag and four styled tags; the map list', () => {
  i18n.setLanguage('zh_CN');
  const code = demo.codeList();
  assert.equal(code.tags.length, 12);
  assert.deepEqual(code.tags.slice(0, 7).map((tag) => tag.title), demo.CONTINENTS);
  assert.equal(code.tags[7].title, 'Tag Text');
  assert.equal(code.tags[7].identifier, 7);
  assert.deepEqual(code.tags.slice(8).map((tag) => tag.title), ['可删除', '大字号', '背景图', '自定义删除']);
  assert.equal(code.tags[11].deleteIndicatorTitle, '⊗');
  assert.equal(code.style.lineSpacing, 5);
  assert.equal(code.style.interitemSpacing, 3);
  assert.equal(code.style.normal.cornerRadius, 3, 'CYLMenuStyle(), not tagCloud()');
  const map = demo.mapList();
  assert.deepEqual(map.tags.map((tag) => tag.title), ['Asia', 'Europe', 'Africa', 'Australia']);
  assert.equal(map.tags[2].identifier, 3);
  assert.equal(map.tags[2].isDeletable, true);
  assert.equal(map.tags[2].style.highlightedBackgroundColor, 'rgba(136, 54, 54, 0.212)');
  assert.equal(map.tags[3].image, '/images/samples/globe.png');
  assert.equal(model.tagHeight(model.tagStyle(code.tags[9], code.style)), 33, 'the 22 pt tag is taller');
});

test('MainActivity\'s tags, in order, with their ids', () => {
  i18n.setLanguage('en');
  const tags = cloud.mainTags();
  assert.equal(tags.length, 25);
  assert.deepEqual(tags.map((tag) => tag.identifier), Array.from({ length: 25 }, (_, i) => i));
  assert.equal(tags[7].title, 'Colorful Text');
  assert.equal(tags[7].textColor, 'rgb(233, 30, 99)');
  assert.equal(tags[11].backgroundColor, 'rgb(0, 191, 255)');
  assert.equal(tags[17].borderColor, 'rgb(233, 30, 99)');
  assert.equal(tags[19].cornerRadius, model.CORNER_RADIUS_SQUARE);
  assert.equal(tags[22].title, 'Deletable');
  assert.equal(tags[24].title, 'Detail Tag');
  assert.equal(tags[24].isDeletable, true);
  i18n.setLanguage('zh_CN');
});

test('添加标签 adds the typed text or ADD A TAG, deletable half the time, one of the five colors', () => {
  i18n.setLanguage('zh_CN');
  const zeros = cloud.newTag('', 25, () => 0);
  assert.equal(zeros.title, '添加标签');
  assert.equal(zeros.isDeletable, true);
  assert.equal(zeros.backgroundColor, 'rgb(0, 191, 255)');
  assert.equal(zeros.identifier, 25);
  const typed = cloud.newTag('Hi', 3, (n) => n - 1);
  assert.equal(typed.title, 'Hi');
  assert.equal(typed.isDeletable, false);
  assert.equal(typed.backgroundColor, 'rgb(103, 58, 183)');
});

test('the list, RecyclerView and hot search data', () => {
  i18n.setLanguage('zh_CN');
  assert.equal(cloud.LIST_ROW_COUNT, 51);
  assert.deepEqual(cloud.tagsForRow(4).map((tag) => tag.title), ['条目 4', '条目 4', '条目 4']);
  assert.equal(cloud.recyclerTexts().length, 21);
  assert.deepEqual(cloud.footerTags().map((tag) => tag.title), ['页脚 1', '页脚 2']);
  const hot = cloud.hotTags();
  assert.equal(hot.length, 10);
  assert.equal(hot[0].badgeText, '神');
  assert.equal(hot[0].badgeAccessibilityLabel, '神曲');
  assert.equal(hot[4].badgeText, '热');
  assert.equal(hot[2].badgeText, undefined);
  const style = cloud.hotStyle();
  assert.equal(model.tagHeight(style), 38);
  assert.equal(style.normal.cornerRadius, 0);
});

test('the five containers have the attributes of content_main.xml', () => {
  const [first, second, third, fourth, fifth] = container.containers();
  assert.equal(first.tags.length, 9);
  assert.ok(first.tags.every((tag) => tag.isDeletable));
  assert.equal(first.options.allowsReordering, true);
  assert.equal(first.options.removesItemsOnDelete, false);
  assert.equal(first.options.colorTheme, 'pureTeal');
  assert.equal(first.options.defaultTagImage, '/images/samples/avatar.png');
  assert.equal(first.style.imageSize, 24);
  assert.equal(second.options.colorTheme, 'random');
  assert.equal(second.options.containerBorderWidth, 4);
  assert.equal(second.options.allowsTapping, false);
  assert.equal(third.style.rowAlignment, 'trailing');
  assert.equal(third.style.deleteIndicatorPlacement, 'leading');
  assert.equal(model.displayedTitle(third.style, 'Persian'), 'naisreP');
  assert.equal(model.tagHeight(third.style), 37);
  assert.equal(fourth.style.rippleDuration, 2);
  assert.equal(fourth.style.rowAlignment, 'center');
  assert.equal(fifth.tags[0].backgroundColor, 'rgb(255, 0, 0)');
  assert.equal(fifth.tags[1].selectedBackgroundColor, 'rgb(153, 153, 153)');
  const red = model.renderTag(fifth.tags[0], 0, { listStyle: fifth.style, theme: fifth.options.colorTheme });
  assert.match(red.style, /background-color: rgb\(255, 0, 0\)/);
});

test('the sample pictures and images exist and are small', () => {
  i18n.setLanguage('zh_CN');
  assert.deepEqual(sample.picture(4), { src: '/images/samples/picture-1.jpg', label: '包图片' });
  let total = 0;
  for (const file of ['picture-0.jpg', 'picture-1.jpg', 'picture-2.jpg', 'avatar.png', 'globe.png']) {
    const size = fs.statSync(path.join(ROOT, 'images', 'samples', file)).size;
    total += size;
  }
  assert.ok(total < 100 * 1024, `${total} bytes`);
});

test('the core strings follow the language', () => {
  i18n.setLanguage('zh_CN');
  assert.equal(coreString('CYLMenuDeleteTag'), '删除');
  assert.equal(coreString('CYLImageTagGroup', joinList(['头层牛皮', 'PLAYBOY'])), '标签组：头层牛皮和PLAYBOY');
  i18n.setLanguage('en');
  assert.equal(coreString('CYLImageTagGroup', joinList(['a', 'b', 'c'])), 'Tag group: a, b, and c');
  assert.equal(coreString('CYLImageTagPicture'), 'Picture');
  i18n.setLanguage('zh_CN');
});

test('every page of the area has its four files and uses t() for its title', () => {
  const pages = ['tag-cloud', 'sample-tag-cloud', 'sample-tag-cloud-sub', 'sample-tag-cloud-list',
    'sample-tag-cloud-recycler', 'sample-tag-cloud-hot-search', 'sample-image-tag', 'sample-image-tag-edit',
    'sample-image-tag-list', 'sample-tag-container'];
  for (const page of pages) {
    for (const ext of ['js', 'json', 'wxml', 'wxss']) {
      assert.ok(fs.existsSync(path.join(ROOT, 'pages', page, `${page}.${ext}`)), `${page}.${ext}`);
    }
    const json = JSON.parse(fs.readFileSync(path.join(ROOT, 'pages', page, `${page}.json`), 'utf8'));
    for (const component of Object.values(json.usingComponents || {})) {
      assert.ok(fs.existsSync(componentFile(component)), component);
    }
  }
});
