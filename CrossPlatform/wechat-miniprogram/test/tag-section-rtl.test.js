// Right to left, long section headers and the capped fold control of cyl-tag-list (docs/tag-section-style.md): the style key
// `direction` mirrors the section views, `headerMaxLines` lets a header title wrap, and the fold / More control's font has a
// cap. Static strings only: the CSS the model hands to the component (node --test).
const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const model = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/model.js')

const COMPONENT_DIR = path.join(__dirname, '..', 'packages', 'cyl-tag-list-miniprogram', 'miniprogram_dist', 'cyl-tag-list')
const TITLE = 'Section'
const HEADER_LINES = 3
const DEFAULT_HEADER_HEIGHT = 36
// Asymmetric distances (top, left, bottom, right) so that a mirror is visible: the left value is the leading one.
const LEADING_SMALL = 16
const TRAILING_LARGE = 24
const SECTION_INSETS = [10, LEADING_SMALL, 10, TRAILING_LARGE]
const CARD_LEADING = 4
const CARD_TRAILING = 20
const CARD_INSETS = [12, CARD_LEADING, 12, CARD_TRAILING]
const DIVIDER_LEADING_INSET = 20
const TAG_LEADING = 4
const TAG_TRAILING = 12
const BORDER = 0.5

function styleOf(style = {}, options = { pixelRatio: 2 }) {
  const configuration = { style, sections: [{ title: TITLE, items: ['a'] }] }
  return model.normalize(configuration, options).sections[0].style
}

const rtlOf = (style = {}) => styleOf({ direction: 'rtl', ...style })
const plainOf = (style = {}) => styleOf({ sectionStyle: 'plain', ...style })
const plainRtlOf = (style = {}) => plainOf({ direction: 'rtl', ...style })
const tagOf = (style) => model.tagLayout(style, { title: 'a' }, 'normal', { kind: 'image' }, 10, 10)

test('the direction key defaults to ltr and parses ltr, rtl and auto', () => {
  assert.equal(styleOf().direction, model.DEFAULT_DIRECTION)
  assert.equal(styleOf().direction, 'ltr')
  assert.equal(styleOf({ direction: 'rtl' }).direction, 'rtl')
  assert.equal(styleOf({ direction: 'RTL' }).direction, 'rtl')
  assert.equal(styleOf({ direction: 'auto' }).direction, 'auto')
  assert.equal(styleOf({ direction: 'ltr' }).direction, 'ltr')
  // Anything else keeps the style's value.
  assert.equal(styleOf({ direction: 'sideways' }).direction, 'ltr')
  assert.equal(styleOf({ direction: 5 }).direction, 'ltr')
})

test('auto is ltr: the component has no language-direction helper', () => {
  assert.equal(model.isRtl(styleOf({ direction: 'auto' })), false)
  assert.equal(model.isRtl(rtlOf()), true)
  assert.deepEqual(model.sectionLayout(styleOf({ direction: 'auto' })), model.sectionLayout(styleOf()))
})

test('ltr output is unchanged: the default and an explicit ltr give the same CSS and the list has no direction', () => {
  assert.deepEqual(model.sectionLayout(styleOf({ direction: 'ltr' })), model.sectionLayout(styleOf()))
  assert.deepEqual(model.sectionLayout(plainOf({ direction: 'ltr' })), model.sectionLayout(plainOf()))
  assert.equal(model.directionCSS(styleOf()), '')
  assert.equal(model.directionCSS(rtlOf()), '; direction: rtl')
  const css = model.sectionLayout(plainOf({ sectionInsets: SECTION_INSETS }))
  assert.equal(css.listStyle, `padding: 10px ${TRAILING_LARGE}px 0px ${LEADING_SMALL}px`)
  assert.equal(css.itemsStyle, 'margin-right: -10px')
  assert.equal(css.headerStyle.startsWith(`height: ${DEFAULT_HEADER_HEIGHT}px; padding: 0 16px;`), true)
})

test('rtl mirrors the section insets, the negative margin and the tags spacing', () => {
  const css = model.sectionLayout(plainRtlOf({ sectionInsets: SECTION_INSETS }))
  assert.equal(css.listStyle, `padding: 10px ${LEADING_SMALL}px 0px ${TRAILING_LARGE}px`)
  assert.equal(css.itemsStyle, 'margin-left: -10px')
  assert.deepEqual(model.contentColumn(plainRtlOf({ sectionInsets: SECTION_INSETS })), { left: TRAILING_LARGE, right: LEADING_SMALL })
  const ltrTag = tagOf(plainOf())
  const rtlTag = tagOf(plainRtlOf())
  assert.match(ltrTag.cellStyle, /margin: 0 10px 10px 0;/)
  assert.match(rtlTag.cellStyle, /margin: 0 0 10px 10px;/)
  assert.match(ltrTag.slotStyle, /margin-right: 4px/)
  assert.match(rtlTag.slotStyle, /margin-left: 4px/)
})

test('rtl swaps the tag content insets: the leading inset is on the right', () => {
  const tagContentInsets = [0, TAG_LEADING, 0, TAG_TRAILING]
  const ltr = tagOf(plainOf({ tagContentInsets })).cellStyle
  const rtl = tagOf(plainRtlOf({ tagContentInsets })).cellStyle
  assert.match(ltr, new RegExp(`padding: 0 ${TAG_TRAILING - BORDER}px 0 ${TAG_LEADING - BORDER}px;`))
  assert.match(rtl, new RegExp(`padding: 0 ${TAG_LEADING - BORDER}px 0 ${TAG_TRAILING - BORDER}px;`))
})

test('rtl mirrors the header title inset and the card padding inside the card', () => {
  const sectionContentInsets = CARD_INSETS
  const ltr = model.sectionLayout(styleOf({ sectionContentInsets }))
  const rtl = model.sectionLayout(rtlOf({ sectionContentInsets }))
  assert.match(ltr.headerStyle, new RegExp(`padding: 0 ${CARD_TRAILING}px 0 ${CARD_LEADING}px;`))
  assert.match(rtl.headerStyle, new RegExp(`padding: 0 ${CARD_LEADING}px 0 ${CARD_TRAILING}px;`))
  assert.match(ltr.cardStyle, new RegExp(`padding: 12px ${CARD_TRAILING}px 12px ${CARD_LEADING}px;`))
  assert.match(rtl.cardStyle, new RegExp(`padding: 12px ${CARD_LEADING}px 12px ${CARD_TRAILING}px;`))
})

test('rtl mirrors the header band inset of a plain header', () => {
  const headerContentInsets = [0, CARD_LEADING, 0, CARD_TRAILING]
  const style = { headerBackgroundColor: '#EFEFF4', headerContentInsets }
  assert.match(model.sectionLayout(plainOf(style)).headerStyle, new RegExp(`padding: 0 ${CARD_TRAILING}px 0 ${CARD_LEADING}px;`))
  assert.match(model.sectionLayout(plainRtlOf(style)).headerStyle, new RegExp(`padding: 0 ${CARD_LEADING}px 0 ${CARD_TRAILING}px;`))
})

test('rtl swaps the sides of the divider insets', () => {
  const style = { headerSeparatorStyle: 'line', headerSeparatorInsets: [0, DIVIDER_LEADING_INSET, 0, 0] }
  const ltr = model.sectionLayout(plainOf(style)).headerLineStyle
  const rtl = model.sectionLayout(plainRtlOf(style)).headerLineStyle
  // The plain header's box is the whole list, so the distances are the column's (16) plus the divider's own inset.
  assert.match(ltr, new RegExp(`^left: ${16 + DIVIDER_LEADING_INSET}px; right: 16px;`))
  assert.match(rtl, new RegExp(`^left: 16px; right: ${16 + DIVIDER_LEADING_INSET}px;`))
})

test('the card and the band are symmetric: their CSS other than the sides is the same in rtl', () => {
  const style = { headerBackgroundColor: '#EFEFF4' }
  const ltr = model.sectionLayout(styleOf(style))
  const rtl = model.sectionLayout(rtlOf(style))
  // The list's items margin that absorbs the last tag's spacing is mirrored (left in rtl), which is the only difference.
  const withoutItemsMargin = ({ itemsStyle, ...rest }) => rest
  assert.deepEqual(withoutItemsMargin(rtl), withoutItemsMargin(ltr))
  assert.notEqual(rtl.itemsStyle, ltr.itemsStyle)
})

test('the component puts direction: rtl on the list, selects the mirrored rules and keeps ltr as it was', () => {
  const source = fs.readFileSync(path.join(COMPONENT_DIR, 'cyl-tag-list.js'), 'utf8')
  assert.match(source, /background-color: \$\{model\.resolvedBackgroundColor\(m\.style\)\}\$\{model\.directionCSS\(m\.style\)\}/)
  assert.match(source, /rtl: model\.isRtl\(m\.style\)/)
  const wxml = fs.readFileSync(path.join(COMPONENT_DIR, 'cyl-tag-list.wxml'), 'utf8')
  assert.match(wxml, /class="cyl-tag-list \{\{rtl \? 'cyl-rtl' : ''\}\}"/)
  const wxss = fs.readFileSync(path.join(COMPONENT_DIR, 'cyl-tag-list.wxss'), 'utf8')
  assert.match(wxss, /\.cyl-rtl \.cyl-fold-header \{ padding: 4px 12px 4px 0; \}/)
  assert.match(wxss, /\.cyl-rtl \.cyl-fold-arrow \{ margin-left: 0; margin-right: 2px; \}/)
})

test('headerMaxLines defaults to one line: the header keeps its height and has no wrapping CSS', () => {
  const style = styleOf()
  assert.equal(style.headerMaxLines, model.HEADER_TITLE_MAX_LINES.single)
  assert.equal(model.HEADER_TITLE_MAX_LINES.single, 1)
  const plain = model.sectionLayout(plainOf())
  assert.equal(plain.headerTitleStyle, undefined)
  assert.match(plain.headerStyle, new RegExp(`^height: ${DEFAULT_HEADER_HEIGHT}px; padding: 0 16px;`))
  const card = model.sectionLayout(style)
  assert.equal(card.headerTitleStyle, undefined)
  assert.match(card.headerStyle, new RegExp(`^height: ${DEFAULT_HEADER_HEIGHT}px; margin: `))
  assert.doesNotMatch(card.headerStyle, /min-height/)
})

test('headerMaxLines 3 clamps the title to three lines and the header height becomes a minimum', () => {
  const style = styleOf({ headerMaxLines: HEADER_LINES })
  assert.equal(style.headerMaxLines, HEADER_LINES)
  const css = model.sectionLayout(style)
  assert.match(css.headerTitleStyle, new RegExp(`-webkit-line-clamp: ${HEADER_LINES}`))
  assert.match(css.headerTitleStyle, /white-space: normal/)
  assert.match(css.headerStyle, new RegExp(`^min-height: ${DEFAULT_HEADER_HEIGHT}px;`))
  assert.doesNotMatch(css.headerStyle, /(^|; )height:/)
  assert.match(css.headerStyle, new RegExp(`padding: ${model.HEADER_WRAP_VERTICAL_PADDING}px `))
  const plain = model.sectionLayout(plainOf({ headerMaxLines: HEADER_LINES }))
  assert.match(plain.headerStyle, new RegExp(`^min-height: ${DEFAULT_HEADER_HEIGHT}px; padding: ${model.HEADER_WRAP_VERTICAL_PADDING}px 16px;`))
})

test('headerMaxLines unlimited shows every line and has no clamp', () => {
  const style = styleOf({ headerMaxLines: 'unlimited' })
  assert.equal(style.headerMaxLines, model.HEADER_TITLE_MAX_LINES.unlimited)
  const css = model.sectionLayout(style)
  assert.doesNotMatch(css.headerTitleStyle, /line-clamp/)
  assert.match(css.headerTitleStyle, /white-space: normal/)
  assert.match(css.headerStyle, /^min-height: /)
})

test('the headerMaxLines key parses: a whole number of 1 or more, or unlimited; anything else is one line', () => {
  assert.equal(styleOf({ headerMaxLines: 2.7 }).headerMaxLines, 2)
  assert.equal(styleOf({ headerMaxLines: '4' }).headerMaxLines, 4)
  assert.equal(styleOf({ headerMaxLines: 0 }).headerMaxLines, 1)
  assert.equal(styleOf({ headerMaxLines: -2 }).headerMaxLines, 1)
  assert.equal(styleOf({ headerMaxLines: 'many' }).headerMaxLines, 1)
  // The tag's title limit is independent.
  assert.equal(styleOf({ headerMaxLines: 3 }).titleMaxLines, model.TITLE_MAX_LINES.single)
})

test('the component gives the header title its wrapping style', () => {
  const wxml = fs.readFileSync(path.join(COMPONENT_DIR, 'cyl-tag-list.wxml'), 'utf8')
  assert.match(wxml, /class="cyl-header-title" style="\{\{section\.headerTitleStyle\}\}"/)
})

test('the fold control font is capped: min(size, cap) with a named cap, unchanged below it', () => {
  assert.equal(model.FOLD_CONTROL_MAX_FONT_SIZE > model.FOLD_CONTROL_FONT_SIZE, true)
  const cap = model.FOLD_CONTROL_MAX_FONT_SIZE
  assert.equal(model.foldControlFontCSS(), `font-size: min(${model.FOLD_CONTROL_FONT_SIZE}px, ${cap}px)`)
  assert.equal(model.foldControlFontCSS(14), `font-size: min(14px, ${cap}px)`)
  assert.equal(model.foldControlFontCSS(40), `font-size: min(40px, ${cap}px)`)
})

test('the component applies the cap to the header, footer and tail fold controls', () => {
  const wxml = fs.readFileSync(path.join(COMPONENT_DIR, 'cyl-tag-list.wxml'), 'utf8')
  assert.match(wxml, /class="cyl-fold-header" style="color: \{\{foldColor\}\}; \{\{foldFontStyle\}\};"/)
  assert.match(wxml, /class="cyl-fold-footer" style="color: \{\{foldColor\}\}; \{\{foldFontStyle\}\};"/)
  const source = fs.readFileSync(path.join(COMPONENT_DIR, 'cyl-tag-list.js'), 'utf8')
  assert.match(source, /foldFontStyle: model\.foldControlFontCSS\(\)/)
  assert.match(source, /model\.foldControlFontCSS\(style\.normal\.font\.size\)/)
})
