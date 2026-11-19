// The example's strings (the iOS example's CYLMenuExample.bundle) and t() (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const i18n = require('../miniprogram/utils/i18n.js');

test('the language follows WeChat\'s names', () => {
  assert.equal(i18n.tableFor('en'), 'en');
  assert.equal(i18n.tableFor('en_US'), 'en');
  assert.equal(i18n.tableFor('zh_TW'), 'zh-Hant');
  assert.equal(i18n.tableFor('zh-Hant-HK'), 'zh-Hant');
  assert.equal(i18n.tableFor('zh_CN'), 'zh-Hans');
  assert.equal(i18n.tableFor(''), 'zh-Hans');
});

test('a key is its Chinese text, translated with its format filled', () => {
  i18n.setLanguage('zh_CN');
  assert.equal(i18n.t('宝贝评价(%lu)', 10), '宝贝评价(10)');
  i18n.setLanguage('en');
  assert.equal(i18n.t('场景一：评价筛选'), 'Reviews');
  assert.equal(i18n.t('宝贝评价(%lu)', 10), 'Reviews (10)');
  assert.equal(i18n.t('没有这个键'), '没有这个键');
  i18n.setLanguage('zh_TW');
  assert.equal(i18n.t('查询筛选'), '查詢篩選');
  i18n.setLanguage('zh_CN');
});

test('format fills positional and percent specifiers', () => {
  assert.equal(i18n.format('%2$@ %1$@', ['a', 'b']), 'b a');
  assert.equal(i18n.format('%d%% %.1f', [5, 1.25]), '5% 1.3');
});
