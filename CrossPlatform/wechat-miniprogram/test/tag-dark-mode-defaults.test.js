// Dark mode defaults of the tag list, as iOS's dynamic defaults: the tag fill and title and the one tint of the header and
// the fold controls follow dark mode; light mode keeps the tag colors; a configured color wins in both modes.
const test = require('node:test')
const assert = require('node:assert/strict')
const model = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/model.js')

test('light mode keeps the tag fill and title, and the tint of the list is black', () => {
  const style = model.defaultStyle(2, false)
  assert.equal(style.normal.backgroundColor, model.DEFAULT_TAG_BACKGROUND)
  assert.equal(style.normal.textColor, '#404040')
  assert.equal(style.headerTextColor, '#000000')
  assert.equal(style.foldControlColor, '#000000')
})

test('dark mode: the secondary system background, a white title and a white tint', () => {
  const style = model.defaultStyle(2, true)
  assert.equal(style.normal.backgroundColor, '#1C1C1E')
  assert.equal(style.normal.textColor, '#FFFFFF')
  assert.equal(style.disabled.backgroundColor, '#1C1C1E')
  assert.equal(style.headerTextColor, '#FFFFFF')
  assert.equal(style.foldControlColor, '#FFFFFF')
  // The selected tag keeps its tint and white title in both modes.
  assert.equal(style.selected.textColor, '#FFFFFF')
})

test('normalize follows options.dark and a configured color wins', () => {
  const configuration = { style: { headerTextColor: '#FF0000' }, sections: [{ title: 'S', items: ['a'] }] }
  const dark = model.normalize(configuration, { pixelRatio: 2, dark: true })
  assert.equal(dark.style.headerTextColor, '#FF0000')
  assert.equal(dark.style.foldControlColor, '#FFFFFF')
  assert.equal(dark.style.normal.backgroundColor, '#1C1C1E')
  const light = model.normalize({ sections: [] }, { pixelRatio: 2 })
  assert.equal(light.style.headerTextColor, '#000000')
})

test('tagButtonView follows the dark flag', () => {
  const dark = model.tagButtonView({ title: 'x' }, '', 2, true)
  const light = model.tagButtonView({ title: 'x' }, '', 2, false)
  assert.notEqual(dark.cellStyle, light.cellStyle)
})
