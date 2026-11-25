// A tag's title wraps up to style.titleMaxLines lines: 1 by default, a number of the app's choice, or "unlimited"
// (the named value TITLE_MAX_LINES.unlimited, never a literal at a call site) (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const model = require('cyl-tag-list-miniprogram/cyl-tag-list/model.js');

const layout = (style) => model.tagLayout(style, { title: 'a long title that does not fit' }, 'normal', { kind: 'none' }, 10, 10);

test('the default is one line: a fixed height and no wrapping styles', () => {
  const style = model.normalize({}).style;
  assert.equal(style.titleMaxLines, model.TITLE_MAX_LINES.single);
  const tag = layout(style);
  assert.match(tag.cellStyle, /(^|; )height: \d+(\.\d+)?px/);
  assert.doesNotMatch(tag.cellStyle, /min-height/);
  assert.equal(tag.titleTextStyle, '');
});

test('a configured number clamps the title and lets the tag grow', () => {
  const style = model.normalize({ style: { titleMaxLines: 3 } }).style;
  assert.equal(style.titleMaxLines, 3);
  const tag = layout(style);
  assert.match(tag.cellStyle, /min-height: \d+(\.\d+)?px/);
  assert.match(tag.cellStyle, /white-space: normal/);
  assert.match(tag.titleTextStyle, /-webkit-line-clamp: 3/);
});

test('unlimited shows every line and has no clamp', () => {
  const style = model.normalize({ style: { titleMaxLines: 'unlimited' } }).style;
  assert.equal(style.titleMaxLines, model.TITLE_MAX_LINES.unlimited);
  const tag = layout(style);
  assert.doesNotMatch(tag.titleTextStyle, /line-clamp/);
  assert.match(tag.titleTextStyle, /white-space: normal/);
});

test('a value that is not a whole number of 1 or more is one line', () => {
  for (const bad of [0, -2, 'many', null]) {
    assert.equal(model.normalize({ style: { titleMaxLines: bad } }).style.titleMaxLines, model.TITLE_MAX_LINES.single, String(bad));
  }
  assert.equal(model.normalize({ style: { titleMaxLines: 2.7 } }).style.titleMaxLines, 2);
});
