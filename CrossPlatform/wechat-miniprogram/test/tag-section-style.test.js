// The section style of cyl-tag-list (docs/tag-section-style.md): a card around a section's tags (insetGrouped), a header band
// and a header divider, all independent and off by default. The HarmonyOS component is the reference; the mini program lays
// tags out in CSS, so the geometry is two distances from the list's edges (model.js contentColumn / tagColumn) and the
// rows are counted by a flow of fixed tag widths at the width those distances leave.
const test = require('node:test')
const assert = require('node:assert/strict')
const model = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/model.js')

const LIST_WIDTH = 320
const TAG_WIDTHS = [85, 85, 85, 70, 60, 90, 60, 70, 90]
const CARD_PADDING = 12
const CARD_RADIUS = 10
const BAND_PADDING = 12
const HAIRLINE = 0.5
const TITLE = 'Section'
const LIGHT = { card: '#FFFFFF', headerBand: '#EFEFF4', groupedBackground: '#F2F2F7' }
const DARK = { card: '#1C1C1E', headerBand: '#2C2C2E', groupedBackground: '#000000' }
const CUSTOM_BACKGROUND = '#123456'
const CUSTOM_COLOR = '#FF0000'
const FOLD_ROWS = 2

function styleOf(style = {}, options = { pixelRatio: 2 }) {
  const configuration = { style, sections: [{ title: TITLE, items: ['a'] }] }
  return model.normalize(configuration, options).sections[0].style
}

/** Greedy flow of fixed tag widths in a column of `width`, the CSS flex-wrap of the list: the tops of the rows and the x of each tag. */
function flow(style, widths, listWidth = LIST_WIDTH) {
  const column = model.columnAt(model.tagColumn(style), listWidth)
  const tops = []
  const xs = []
  let x = 0
  let row = 0
  widths.forEach((w) => {
    if (x > 0 && x + w > column.width) {
      row += 1
      x = 0
    }
    tops.push(row * (style.itemHeight + style.lineSpacing))
    xs.push(column.x + x)
    x += w + style.interitemSpacing
  })
  return { tops, xs, column }
}

/** The CSS pixels of `property: Npx ...` inside a style string (the first number after it). */
function px(css, property) {
  const match = new RegExp(`${property}: (-?[\\d.]+)px`).exec(css)
  return match ? Number(match[1]) : null
}

test('the default style is plain with no band and no divider', () => {
  const style = styleOf()
  const layout = model.sectionLayout(style)
  assert.equal(style.sectionStyle, 'plain')
  assert.equal(style.headerBackgroundColor, null)
  assert.equal(style.headerSeparatorStyle, 'none')
  assert.equal(layout.cardStyle, undefined)
  assert.equal(layout.headerLineStyle, undefined)
  assert.deepEqual(model.tagColumn(style), model.contentColumn(style))
  assert.equal(model.headerEdges(style).left, style.headerHorizontalInset)
})

test('the named constants: radius 10, padding 12, band padding 12, hairline 0.5', () => {
  const style = styleOf()
  assert.equal(style.sectionCornerRadius, CARD_RADIUS)
  assert.deepEqual(style.sectionContentInsets, { top: CARD_PADDING, left: CARD_PADDING, bottom: CARD_PADDING, right: CARD_PADDING })
  assert.deepEqual(style.headerContentInsets, { top: 0, left: BAND_PADDING, bottom: 0, right: BAND_PADDING })
  assert.equal(style.headerSeparatorThickness, HAIRLINE)
  assert.equal(style.headerSeparatorInsets, null)
  assert.equal(style.headerCornerRadius, 0)
})

test('the card frame contains every tag', () => {
  const style = styleOf({ sectionStyle: 'insetGrouped' })
  const card = model.columnAt(model.contentColumn(style), LIST_WIDTH)
  const { xs, column } = flow(style, TAG_WIDTHS)
  assert.equal(card.width, LIST_WIDTH - style.sectionInsets.left - style.sectionInsets.right)
  xs.forEach((x, i) => {
    assert.ok(x >= card.x + CARD_PADDING, `tag ${i} starts inside the card padding`)
    assert.ok(x + TAG_WIDTHS[i] <= card.x + card.width - CARD_PADDING, `tag ${i} ends inside the card padding`)
  })
  assert.equal(column.width, card.width - 2 * CARD_PADDING)
  const css = model.sectionLayout(style)
  assert.match(css.cardStyle, new RegExp(`padding: ${CARD_PADDING}px ${CARD_PADDING}px ${CARD_PADDING}px ${CARD_PADDING}px`))
  assert.equal(px(css.cardStyle, 'border-radius'), CARD_RADIUS)
})

test('rows are counted at the reduced width, so tags wrap earlier inside a padded card', () => {
  const rowsOf = (style) => model.rowsFromTops(flow(style, TAG_WIDTHS).tops)
  const plain = rowsOf(styleOf())
  const grouped = rowsOf(styleOf({ sectionStyle: 'insetGrouped' }))
  const rowCount = (rows) => rows[rows.length - 1] + 1
  assert.equal(rowCount(plain), 3)
  assert.equal(rowCount(grouped), 4)
  // A card without padding wraps exactly as plain does.
  const flush = styleOf({ sectionStyle: 'insetGrouped', sectionContentInsets: [0, 0, 0, 0] })
  assert.deepEqual(rowsOf(flush), plain)
})

test('the card padding adds top and bottom to the section and the tags keep the line spacing inside the card', () => {
  const plain = styleOf()
  const grouped = styleOf({ sectionStyle: 'insetGrouped' })
  const plainCss = model.sectionLayout(plain)
  const groupedCss = model.sectionLayout(grouped)
  // Plain: the last line's spacing is taken off the list's bottom padding. Grouped: the card absorbs it.
  assert.match(plainCss.listStyle, /padding: 10px 16px 0px 16px/)
  assert.match(groupedCss.listStyle, /padding: 10px 16px 10px 16px/)
  assert.equal(px(groupedCss.itemsStyle, 'margin-bottom'), -grouped.lineSpacing)
  assert.equal(model.cardInsets(grouped).top + model.cardInsets(grouped).bottom, 2 * CARD_PADDING)
  assert.equal(model.cardInsets(plain).top + model.cardInsets(plain).bottom, 0)
})

test('the header title x equals the tags leading x under insetGrouped', () => {
  const style = styleOf({ sectionStyle: 'insetGrouped' })
  const edges = model.headerEdges(style)
  assert.equal(edges.left, model.tagColumn(style).left)
  assert.equal(edges.right, model.tagColumn(style).right)
  assert.equal(edges.left, flow(style, TAG_WIDTHS).xs[0])
  // The header element spans the column: its margin plus padding is that x.
  const css = model.sectionLayout(style).headerStyle
  assert.match(css, new RegExp(`margin: 0 ${style.sectionInsets.right}px 0 ${style.sectionInsets.left}px`))
  const paddingLeft = Number(/padding: 0 [\d.]+px 0 ([\d.]+)px/.exec(css)[1])
  assert.equal(style.sectionInsets.left + paddingLeft, edges.left)
})

test('a plain header with a band insets its title from the band, the band spans the column', () => {
  const style = styleOf({ headerBackgroundColor: LIGHT.headerBand })
  const edges = model.headerEdges(style)
  assert.equal(edges.left, style.sectionInsets.left + BAND_PADDING)
  assert.equal(edges.right, style.sectionInsets.right + BAND_PADDING)
  const css = model.sectionLayout(style).headerStyle
  assert.match(css, /margin: 0 16px 0 16px/)
  assert.match(css, /padding: 0 12px 0 12px/)
  assert.match(css, /background-color: #EFEFF4; border-radius: 0px/)
  // The tags are not narrowed: the band alone does not change the tag column.
  assert.deepEqual(model.tagColumn(style), model.contentColumn(style))
  assert.equal(model.sectionLayout(styleOf({ headerBackgroundColor: LIGHT.headerBand, headerCornerRadius: 6 })).headerStyle
    .includes('border-radius: 6px'), true)
})

test('the divider sits at the header bottom and adds no height', () => {
  const without = styleOf()
  const withLine = styleOf({ headerSeparatorStyle: 'line' })
  const css = model.sectionLayout(withLine)
  // The header's height is unchanged; the line is absolute inside it, at the bottom.
  assert.equal(px(css.headerStyle, 'height'), px(model.sectionLayout(without).headerStyle, 'height'))
  assert.equal(css.headerStyle, model.sectionLayout(without).headerStyle)
  assert.equal(css.listStyle, model.sectionLayout(without).listStyle)
  const line = model.headerSeparator(withLine)
  assert.equal(line.thickness, HAIRLINE)
  // The column's edges, the same as the card and the band (the header spans the whole list: its box starts at 0).
  assert.equal(line.left, withLine.sectionInsets.left)
  assert.equal(line.right, withLine.sectionInsets.right)
  assert.deepEqual({ left: line.left, right: line.right }, model.contentColumn(withLine))
  assert.match(css.headerLineStyle, new RegExp(`left: ${line.left}px; right: ${line.right}px; height: ${HAIRLINE}px`))
  // Never taller than the header, and absent with thickness 0.
  assert.equal(model.headerSeparator(styleOf({ headerSeparatorStyle: 'line', headerSeparatorThickness: 1000 })).thickness,
    px(css.headerStyle, 'height'))
  assert.equal(model.headerSeparator(styleOf({ headerSeparatorStyle: 'line', headerSeparatorThickness: 0 })), null)
})

test('the divider insets are from the column, and it has the card and band edges under every style', () => {
  const own = styleOf({ headerSeparatorStyle: 'line', headerSeparatorInsets: [0, 5, 0, 7] })
  assert.equal(model.headerSeparator(own).left, own.sectionInsets.left + 5)
  assert.equal(model.headerSeparator(own).right, own.sectionInsets.right + 7)
  const grouped = styleOf({ sectionStyle: 'insetGrouped', headerSeparatorStyle: 'line' })
  const line = model.headerSeparator(grouped)
  assert.equal(line.left, model.contentColumn(grouped).left)
  assert.equal(line.right, model.contentColumn(grouped).right)
  // Not the title's x: the title is inside the card padding.
  assert.notEqual(line.left, model.headerEdges(grouped).left)
  // The header element sits in the column, so the CSS left and right are 0 (the column's edges).
  assert.match(model.sectionLayout(grouped).headerLineStyle, /left: 0px; right: 0px/)
  const banded = styleOf({ headerSeparatorStyle: 'line', headerBackgroundColor: LIGHT.headerBand })
  assert.match(model.sectionLayout(banded).headerLineStyle, /left: 0px; right: 0px/)
  assert.equal(model.headerSeparator(banded).left, model.contentColumn(banded).left)
})

test('the tags fold at the reduced width', () => {
  const foldable = (style) => {
    const rows = model.rowsFromTops(flow(style, TAG_WIDTHS).tops)
    return model.foldState({ defaultVisibleRows: FOLD_ROWS }, rows, false)
  }
  const plain = foldable(styleOf())
  const grouped = foldable(styleOf({ sectionStyle: 'insetGrouped' }))
  assert.equal(plain.canFold, true)
  assert.equal(plain.visible.filter(Boolean).length, 6)
  assert.equal(grouped.canFold, true)
  // Wrapping earlier leaves fewer tags in the first rows.
  assert.ok(grouped.visible.filter(Boolean).length < plain.visible.filter(Boolean).length)
  // Three rows at the full width fit the limit of three, four rows at the reduced width do not.
  const threeRows = (style) => model.foldState({ defaultVisibleRows: 3 }, model.rowsFromTops(flow(style, TAG_WIDTHS).tops), false)
  assert.equal(threeRows(styleOf()).canFold, false)
  assert.equal(threeRows(styleOf({ sectionStyle: 'insetGrouped' })).canFold, true)
})

test('unset colors resolve to the light and dark defaults', () => {
  const light = styleOf({ sectionStyle: 'insetGrouped' }, { pixelRatio: 2, dark: false })
  const dark = styleOf({ sectionStyle: 'insetGrouped' }, { pixelRatio: 2, dark: true })
  assert.equal(model.resolvedSectionBackgroundColor(light), LIGHT.card)
  assert.equal(model.resolvedSectionBackgroundColor(dark), DARK.card)
  assert.equal(model.resolvedHeaderSeparatorColor(light), model.NAMED_COLORS.separator)
  assert.equal(model.resolvedHeaderSeparatorColor(dark), model.SECTION_COLORS.dark.separator)
  assert.equal(light.sectionPalette.headerBand, LIGHT.headerBand)
  assert.equal(dark.sectionPalette.headerBand, DARK.headerBand)
  assert.equal(model.SECTION_COLORS.light.card, LIGHT.card)
  assert.equal(model.SECTION_COLORS.dark.groupedBackground, DARK.groupedBackground)
  // A color the configuration sets wins in both modes.
  const set = styleOf({ sectionStyle: 'insetGrouped', sectionBackgroundColor: CUSTOM_COLOR, headerSeparatorColor: CUSTOM_COLOR },
    { pixelRatio: 2, dark: true })
  assert.equal(model.resolvedSectionBackgroundColor(set), CUSTOM_COLOR)
  assert.equal(model.resolvedHeaderSeparatorColor(set), CUSTOM_COLOR)
  assert.match(model.sectionLayout(dark).cardStyle, /background-color: #1C1C1E/)
})

test('insetGrouped uses the grouped background only when the app never set one', () => {
  const dark = { pixelRatio: 2, dark: true }
  assert.equal(model.resolvedBackgroundColor(styleOf()), '#FFFFFF')
  assert.equal(model.resolvedBackgroundColor(styleOf({ sectionStyle: 'insetGrouped' })), LIGHT.groupedBackground)
  assert.equal(model.resolvedBackgroundColor(styleOf({ sectionStyle: 'insetGrouped' }, dark)), DARK.groupedBackground)
  assert.equal(model.resolvedBackgroundColor(styleOf({ sectionStyle: 'insetGrouped', backgroundColor: CUSTOM_BACKGROUND })),
    CUSTOM_BACKGROUND)
  // Setting white itself counts as set; plain never changes the background.
  assert.equal(model.resolvedBackgroundColor(styleOf({ sectionStyle: 'insetGrouped', backgroundColor: '#FFFFFF' })), '#FFFFFF')
  assert.equal(model.resolvedBackgroundColor(styleOf({ backgroundColor: CUSTOM_BACKGROUND })), CUSTOM_BACKGROUND)
  assert.equal(model.sectionLayout(styleOf({ sectionStyle: 'insetGrouped' })).backgroundStyle, 'background-color: #F2F2F7')
})

test('every option is independent: nothing changes a color or another option by itself', () => {
  const style = styleOf({ sectionStyle: 'insetGrouped', headerSeparatorStyle: 'line', backgroundStyle: 'liquidGlass' })
  assert.equal(style.sectionBackgroundColor, null)
  assert.equal(style.headerBackgroundColor, null)
  assert.equal(style.backgroundStyle, 'liquidGlass')
  assert.equal(model.resolvedSectionBackgroundColor(style), LIGHT.card)
  // A divider under an insetGrouped header is allowed, with or without a band.
  assert.ok(model.headerSeparator(style))
  assert.ok(model.headerSeparator({ ...style, headerBackgroundColor: LIGHT.headerBand }))
})

test('the style keys parse', () => {
  const style = styleOf({
    sectionStyle: 'InsetGrouped',
    sectionBackgroundColor: '#112233',
    sectionCornerRadius: '14',
    sectionContentInsets: '{1, 2, 3, 4}',
    headerBackgroundColor: '#445566',
    headerCornerRadius: 6,
    headerContentInsets: [0, 20, 0, 22],
    headerSeparatorStyle: 'LINE',
    headerSeparatorColor: '#778899',
    headerSeparatorThickness: '2',
    headerSeparatorInsets: { top: 0, left: 3, bottom: 0, right: 4 },
  })
  assert.equal(style.sectionStyle, 'insetGrouped')
  assert.equal(style.sectionBackgroundColor, '#112233')
  assert.equal(style.sectionCornerRadius, 14)
  assert.deepEqual(style.sectionContentInsets, { top: 1, left: 2, bottom: 3, right: 4 })
  assert.equal(style.headerBackgroundColor, '#445566')
  assert.equal(style.headerCornerRadius, 6)
  assert.deepEqual(style.headerContentInsets, { top: 0, left: 20, bottom: 0, right: 22 })
  assert.equal(style.headerSeparatorStyle, 'line')
  assert.equal(style.headerSeparatorColor, '#778899')
  assert.equal(style.headerSeparatorThickness, 2)
  assert.deepEqual(style.headerSeparatorInsets, { top: 0, left: 3, bottom: 0, right: 4 })
  // The raw values 0 and 1, negative lengths clamped, unknown names ignored.
  assert.equal(styleOf({ sectionStyle: 1, headerSeparatorStyle: 1 }).sectionStyle, 'insetGrouped')
  assert.equal(styleOf({ sectionStyle: 1, headerSeparatorStyle: 1 }).headerSeparatorStyle, 'line')
  assert.equal(styleOf({ sectionStyle: 0 }).sectionStyle, 'plain')
  assert.equal(styleOf({ sectionStyle: 'grid', headerSeparatorStyle: 'dashed' }).sectionStyle, 'plain')
  assert.equal(styleOf({ sectionCornerRadius: -3, headerCornerRadius: -1, headerSeparatorThickness: -1 }).sectionCornerRadius, 0)
  assert.equal(styleOf({ headerSeparatorThickness: -1 }).headerSeparatorThickness, 0)
})

test('a section style dictionary applies over the list style', () => {
  const configuration = {
    style: { sectionStyle: 'insetGrouped' },
    sections: [{ title: 'A', items: ['a'] }, { title: 'B', items: ['b'], style: { sectionStyle: 'plain', headerSeparatorStyle: 'line' } }],
  }
  const sections = model.normalize(configuration, { pixelRatio: 2 }).sections
  assert.equal(sections[0].style.sectionStyle, 'insetGrouped')
  assert.equal(sections[1].style.sectionStyle, 'plain')
  assert.equal(sections[1].style.headerSeparatorStyle, 'line')
})
