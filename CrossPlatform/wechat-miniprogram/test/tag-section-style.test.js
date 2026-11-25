// The section style of cyl-tag-list (docs/tag-section-style.md): a card around a section's tags (insetGrouped), a header band
// and a header divider, all independent: the card is the default look (opt out with sectionStyle plain), the band and the
// divider are opt-in. The HarmonyOS component is the reference; the mini program lays tags out in CSS, so the geometry is two distances from the list's edges (model.js contentColumn / tagColumn) and the
// rows are counted by a flow of fixed tag widths at the width those distances leave.
const test = require('node:test')
const assert = require('node:assert/strict')
const model = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/model.js')

const LIST_WIDTH = 320
const TAG_WIDTHS = [85, 85, 85, 70, 60, 90, 60, 70, 90]
const CARD_PADDING = 12
const CARD_RADIUS = 10
const HEADER_FONT_SIZE = 17
const SEMIBOLD_CSS_WEIGHT = 600
// The header is at least its title line plus this much (docs/tag-section-style.md: lineHeight + 12).
const HEADER_VERTICAL_ROOM = 12
// Under the board with no divider: the header is the title's line plus this padding, and the board starts this far below it.
const HEADER_BOARD_TITLE_PADDING = 8
const HEADER_BOARD_SPACING = 4
const FIXED_HEADER_HEIGHT = 36
const SECTION_TOP_INSET = 10
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

const PLAIN = { sectionStyle: 'plain' }

/** The style of a list that opted out of the default card: `sectionStyle: 'plain'` is the look of before the card was the default. */
function plainOf(style = {}, options = { pixelRatio: 2 }) {
  return styleOf({ ...PLAIN, ...style }, options)
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

test('the default style is the rounded section card, with no band and no divider', () => {
  const style = styleOf()
  const layout = model.sectionLayout(style)
  assert.equal(style.sectionStyle, 'insetGrouped')
  assert.equal(style.sectionStyle, model.DEFAULT_SECTION_STYLE)
  assert.equal(style.headerBackgroundColor, null)
  assert.equal(style.headerSeparatorStyle, 'none')
  assert.equal(style.sectionBackgroundStyle, 'flat')
  assert.ok(layout.cardStyle, 'the card is in the layout of a list that sets nothing')
  assert.match(layout.cardStyle, new RegExp(`padding: ${CARD_PADDING}px ${CARD_PADDING}px ${CARD_PADDING}px ${CARD_PADDING}px`))
  assert.equal(px(layout.cardStyle, 'border-radius'), CARD_RADIUS)
  assert.match(layout.cardStyle, /background-color: #FFFFFF/)
  assert.equal(layout.headerLineStyle, undefined)
  // Each side of the tag column is narrowed by the card padding.
  assert.equal(model.tagColumn(style).left, model.contentColumn(style).left + CARD_PADDING)
  assert.equal(model.tagColumn(style).right, model.contentColumn(style).right + CARD_PADDING)
  // The header title is aligned with the tags (the tag column), inside the board.
  assert.deepEqual(model.headerEdges(style), model.tagColumn(style))
})

test('the default header divider is none: it shows only when the app asks for it', () => {
  assert.equal(styleOf().headerSeparatorStyle, 'none')
  assert.equal(model.headerSeparator(styleOf()), null)
  assert.equal(model.sectionLayout(styleOf()).headerLineStyle, undefined)
  assert.ok(model.headerSeparator(styleOf({ headerSeparatorStyle: 'line' })))
  assert.ok(model.sectionLayout(styleOf({ headerSeparatorStyle: 'line' })).headerLineStyle)
})

test('sectionStyle plain is the opt-out: no card, the tags span the column, the layout of before', () => {
  const style = plainOf()
  const layout = model.sectionLayout(style)
  assert.equal(style.sectionStyle, 'plain')
  assert.equal(style.headerBackgroundColor, null)
  assert.equal(style.headerSeparatorStyle, 'none')
  // Exactly the four CSS fields the list had before the section style existed (the snapshot test compares their text).
  assert.deepEqual(Object.keys(layout).sort(), ['backgroundStyle', 'headerStyle', 'itemsStyle', 'listStyle'])
  assert.deepEqual(model.tagColumn(style), model.contentColumn(style))
  assert.equal(model.headerEdges(style).left, style.headerHorizontalInset)
  assert.equal(model.resolvedBackgroundColor(style), '#FFFFFF')
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
  const plain = rowsOf(plainOf())
  const grouped = rowsOf(styleOf({ sectionStyle: 'insetGrouped' }))
  const rowCount = (rows) => rows[rows.length - 1] + 1
  assert.equal(rowCount(plain), 3)
  assert.equal(rowCount(grouped), 4)
  // A card without padding wraps exactly as plain does.
  const flush = styleOf({ sectionStyle: 'insetGrouped', sectionContentInsets: [0, 0, 0, 0] })
  assert.deepEqual(rowsOf(flush), plain)
})

test('the card padding adds top and bottom to the section and the tags keep the line spacing inside the card', () => {
  const plain = plainOf()
  const grouped = styleOf({ sectionStyle: 'insetGrouped' })
  const plainCss = model.sectionLayout(plain)
  const groupedCss = model.sectionLayout(grouped)
  // Plain: the last line's spacing is taken off the list's bottom padding. Grouped: the card absorbs it.
  assert.match(plainCss.listStyle, /padding: 10px 16px 0px 16px/)
  // The board starts HEADER_BOARD_SPACING (4) below a header with no divider; the space below the board is the inset (10).
  assert.match(groupedCss.listStyle, /padding: 4px 16px 10px 16px/)
  assert.match(model.sectionLayout(styleOf({ sectionStyle: 'insetGrouped', headerSeparatorStyle: 'line' })).listStyle, /padding: 10px 16px 10px 16px/)
  assert.equal(px(groupedCss.itemsStyle, 'margin-bottom'), -grouped.lineSpacing)
  assert.equal(model.cardInsets(grouped).top + model.cardInsets(grouped).bottom, 2 * CARD_PADDING)
  assert.equal(model.cardInsets(plain).top + model.cardInsets(plain).bottom, 0)
})

test('the header title x equals the first tag x, plain and insetGrouped; the fold control ends at the tags trailing edge', () => {
  for (const style of [styleOf({ sectionStyle: 'insetGrouped' }), plainOf({ headerHorizontalInset: 16 })]) {
    const grouped = model.isInsetGrouped(style)
    const edges = model.headerEdges(style)
    const tags = flow(style, TAG_WIDTHS)
    if (grouped) {
      // The title is at the tags' leading x (the board's left plus the inset) and the control ends at the tags' trailing edge.
      assert.equal(edges.left, tags.xs[0])
      assert.equal(edges.right, model.tagColumn(style).right)
      assert.equal(LIST_WIDTH - edges.right, tags.column.x + tags.column.width)
      assert.equal(edges.left, style.sectionInsets.left + CARD_PADDING)
    } else {
      // Plain: the header inset (16) is the column's edge (16), so the title is still at the first tag's x.
      assert.equal(edges.left, tags.xs[0])
      assert.equal(LIST_WIDTH - edges.right, tags.column.x + tags.column.width)
    }
  }
  const style = styleOf({ sectionStyle: 'insetGrouped' })
  const edges = model.headerEdges(style)
  // The header element spans the board's column; its padding is the inset that reaches the tags' edge.
  const css = model.sectionLayout(style).headerStyle
  assert.match(css, new RegExp(`margin: 0 ${style.sectionInsets.right}px 0 ${style.sectionInsets.left}px`))
  assert.match(css, new RegExp(`padding: 0 ${CARD_PADDING}px 0 ${CARD_PADDING}px`))
  const paddingLeft = Number(/padding: 0 [\d.]+px 0 ([\d.]+)px/.exec(css)[1])
  const paddingRight = Number(/padding: 0 ([\d.]+)px 0 [\d.]+px/.exec(css)[1])
  assert.equal(style.sectionInsets.left + paddingLeft, edges.left)
  assert.equal(style.sectionInsets.right + paddingRight, edges.right)
})

// MARK: - sectionBoardInset: the board adapts to the taglist through one inset (docs/tag-section-style.md)

const BOARD_INSET_SMALL = 5
const BOARD_INSET_LARGE = 20
const FIRST_VERSION_BOARD = { left: 16, right: 304 }
const FIRST_VERSION_CONTENT = { left: 28, right: 292 }
const CUSTOM_TOP = 7
const CUSTOM_BOTTOM = 9

/** The board's and the content's x edges at LIST_WIDTH: the board is the margin column, the content is the tag column. */
function edgesOf(style) {
  const board = model.columnAt(model.contentColumn(style), LIST_WIDTH)
  const content = model.columnAt(model.tagColumn(style), LIST_WIDTH)
  return { board: { left: board.x, right: board.x + board.width }, content: { left: content.x, right: content.x + content.width } }
}

test('sectionBoardInset unset is the default 12: the numbers of the first version (320 list: board 16..304, content 28..292)', () => {
  const style = styleOf()
  assert.equal(style.sectionBoardInset, null)
  assert.deepEqual(model.boardInset(style), { left: CARD_PADDING, right: CARD_PADDING })
  const { board, content } = edgesOf(style)
  assert.deepEqual(board, FIRST_VERSION_BOARD)
  assert.deepEqual(content, FIRST_VERSION_CONTENT)
  // Unset follows the leading / trailing parts of sectionContentInsets as before.
  const own = styleOf({ sectionContentInsets: [CUSTOM_TOP, 3, CUSTOM_BOTTOM, 8] })
  assert.deepEqual(model.boardInset(own), { left: 3, right: 8 })
  assert.equal(edgesOf(own).content.left, style.sectionInsets.left + 3)
  // A set 12 is the same as unset.
  assert.deepEqual(edgesOf(styleOf({ sectionBoardInset: CARD_PADDING })), edgesOf(style))
  assert.deepEqual(model.sectionLayout(styleOf({ sectionBoardInset: CARD_PADDING })), model.sectionLayout(style))
})

test('a set sectionBoardInset overrides the leading and trailing parts of sectionContentInsets on both sides', () => {
  const style = styleOf({ sectionBoardInset: BOARD_INSET_LARGE, sectionContentInsets: [CUSTOM_TOP, 3, CUSTOM_BOTTOM, 8] })
  assert.deepEqual(model.boardInset(style), { left: BOARD_INSET_LARGE, right: BOARD_INSET_LARGE })
  const { board, content } = edgesOf(style)
  // The board is the margin column; the content is the board minus the inset on each side.
  assert.deepEqual(board, FIRST_VERSION_BOARD)
  assert.equal(board.left, content.left - BOARD_INSET_LARGE)
  assert.equal(board.right, content.right + BOARD_INSET_LARGE)
  // The rows are counted at the content width, so the flow follows the inset.
  assert.equal(flow(style, TAG_WIDTHS).column.width, LIST_WIDTH - 2 * (style.sectionInsets.left + BOARD_INSET_LARGE))
  const small = edgesOf(styleOf({ sectionBoardInset: BOARD_INSET_SMALL }))
  assert.equal(small.board.left, small.content.left - BOARD_INSET_SMALL)
  assert.equal(small.board.right, small.content.right + BOARD_INSET_SMALL)
  // The header title and the tags still share the content's x.
  assert.equal(model.headerEdges(style).left, content.left)
  assert.equal(LIST_WIDTH - model.headerEdges(style).right, content.right)
})

test('sectionBoardInset 0 hugs: the content column is the board column, and the card has no horizontal padding', () => {
  const style = styleOf({ sectionBoardInset: 0 })
  assert.equal(style.sectionBoardInset, 0)
  assert.deepEqual(model.boardInset(style), { left: 0, right: 0 })
  const { board, content } = edgesOf(style)
  assert.deepEqual(content, board)
  assert.deepEqual(model.tagColumn(style), model.contentColumn(style))
  assert.deepEqual(model.headerEdges(style), model.contentColumn(style))
  assert.match(model.sectionLayout(style).cardStyle, new RegExp(`padding: ${CARD_PADDING}px 0px ${CARD_PADDING}px 0px`))
  assert.match(model.sectionLayout(style).headerStyle, /padding: 0 0px 0 0px/)
  // 0 overrides sectionContentInsets' left / right too, while the tags wrap exactly as in plain.
  const own = styleOf({ sectionBoardInset: 0, sectionContentInsets: [CARD_PADDING, 30, CARD_PADDING, 30] })
  assert.deepEqual(edgesOf(own).content, edgesOf(own).board)
  assert.deepEqual(model.rowsFromTops(flow(style, TAG_WIDTHS).tops), model.rowsFromTops(flow(plainOf(), TAG_WIDTHS).tops))
})

test('sectionContentInsets top and bottom still apply when sectionBoardInset is set', () => {
  const style = styleOf({ sectionBoardInset: BOARD_INSET_SMALL, sectionContentInsets: [CUSTOM_TOP, 1, CUSTOM_BOTTOM, 2] })
  const insets = model.cardInsets(style)
  assert.equal(insets.top, CUSTOM_TOP)
  assert.equal(insets.bottom, CUSTOM_BOTTOM)
  assert.equal(insets.left, BOARD_INSET_SMALL)
  assert.equal(insets.right, BOARD_INSET_SMALL)
  assert.match(model.sectionLayout(style).cardStyle,
    new RegExp(`padding: ${CUSTOM_TOP}px ${BOARD_INSET_SMALL}px ${CUSTOM_BOTTOM}px ${BOARD_INSET_SMALL}px`))
})

test('the divider and the board keep the margin column whatever the board inset is', () => {
  for (const sectionBoardInset of [0, BOARD_INSET_SMALL, BOARD_INSET_LARGE]) {
    const style = styleOf({ sectionBoardInset, headerSeparatorStyle: 'line' })
    assert.deepEqual({ left: model.headerSeparator(style).left, right: model.headerSeparator(style).right }, model.contentColumn(style))
    assert.match(model.sectionLayout(style).headerLineStyle, /left: 0px; right: 0px/)
  }
})

test('sectionBoardInset parses, a negative value is 0, junk stays unset, a merge over a base keeps it, plain ignores it', () => {
  assert.equal(styleOf({ sectionBoardInset: 8 }).sectionBoardInset, 8)
  assert.equal(styleOf({ sectionBoardInset: '6' }).sectionBoardInset, 6)
  assert.equal(styleOf({ sectionBoardInset: 0 }).sectionBoardInset, 0)
  assert.equal(styleOf({ sectionBoardInset: -4 }).sectionBoardInset, 0)
  assert.equal(styleOf({ sectionBoardInset: 'wide' }).sectionBoardInset, null)
  assert.equal(styleOf({}).sectionBoardInset, null)
  const copy = model.mergeStyle({}, styleOf({ sectionBoardInset: 8 }))
  assert.equal(copy.sectionBoardInset, 8)
  assert.equal(model.mergeStyle({}, styleOf()).sectionBoardInset, null)
  assert.equal(model.mergeStyle({ sectionBoardInset: 3 }).sectionBoardInset, 3)
  // The plain style has no board: the key changes nothing.
  assert.deepEqual(model.boardInset(plainOf({ sectionBoardInset: 8 })), { left: 0, right: 0 })
  assert.deepEqual(model.sectionLayout(plainOf({ sectionBoardInset: 8 })), model.sectionLayout(plainOf()))
})

test('the default section header font is 17 semibold and the header height holds it', () => {
  const style = styleOf()
  assert.deepEqual(style.headerFont, { size: HEADER_FONT_SIZE, weight: 'semibold', italic: false })
  assert.equal(style.headerFontSize, HEADER_FONT_SIZE)
  assert.equal(model.FONT_WEIGHTS[style.headerFont.weight], SEMIBOLD_CSS_WEIGHT)
  for (const css of [model.sectionLayout(style).headerStyle, model.sectionLayout(plainOf()).headerStyle]) {
    assert.match(css, new RegExp(`font-size: ${HEADER_FONT_SIZE}px; font-weight: ${SEMIBOLD_CSS_WEIGHT}; font-style: normal`))
  }
  // The plain header is at least the title's line plus 12 and never below the style's headerHeight.
  const plain = plainOf()
  assert.ok(model.headerHeightOf(plain) >= model.lineHeight(HEADER_FONT_SIZE) + HEADER_VERTICAL_ROOM)
  assert.ok(model.headerHeightOf(plain) >= plain.headerHeight)
  assert.equal(px(model.sectionLayout(plain).headerStyle, 'height'), model.headerHeightOf(plain))
  // The default (board, no divider) header is the line plus 8, a minimum: the fixed 36 does not apply.
  assert.equal(model.headerHeightOf(style), model.lineHeight(HEADER_FONT_SIZE) + HEADER_BOARD_TITLE_PADDING)
  assert.equal(px(model.sectionLayout(style).headerStyle, 'min-height'), model.headerHeightOf(style))
  // A bigger app font grows the header; an app headerFont wins over the default.
  const big = styleOf({ headerFont: { size: 30, weight: 'bold' } })
  assert.equal(big.headerFont.size, 30)
  assert.equal(model.headerHeightOf(big), model.lineHeight(30) + HEADER_BOARD_TITLE_PADDING)
  assert.equal(model.headerHeightOf(plainOf({ headerFont: { size: 30, weight: 'bold' } })), model.lineHeight(30) + HEADER_VERTICAL_ROOM)
  assert.match(model.sectionLayout(big).headerStyle, /font-size: 30px; font-weight: 700/)
})

test('plain keeps the title with the tags at the column edge; only the header font changed', () => {
  const style = plainOf()
  assert.deepEqual(model.headerEdges(style), { left: style.headerHorizontalInset, right: style.headerHorizontalInset })
  assert.match(model.sectionLayout(style).headerStyle, new RegExp(`^height: 36px; padding: 0 16px; font-size: ${HEADER_FONT_SIZE}px; font-weight: ${SEMIBOLD_CSS_WEIGHT};`))
})

test('a plain header with a band insets its title from the band, the band spans the column', () => {
  const style = plainOf({ headerBackgroundColor: LIGHT.headerBand })
  const edges = model.headerEdges(style)
  assert.equal(edges.left, style.sectionInsets.left + BAND_PADDING)
  assert.equal(edges.right, style.sectionInsets.right + BAND_PADDING)
  const css = model.sectionLayout(style).headerStyle
  assert.match(css, /margin: 0 16px 0 16px/)
  assert.match(css, /padding: 0 12px 0 12px/)
  assert.match(css, /background-color: #EFEFF4; border-radius: 0px/)
  // The tags are not narrowed: the band alone does not change the tag column.
  assert.deepEqual(model.tagColumn(style), model.contentColumn(style))
  assert.equal(model.sectionLayout(plainOf({ headerBackgroundColor: LIGHT.headerBand, headerCornerRadius: 6 })).headerStyle
    .includes('border-radius: 6px'), true)
})

test('the divider sits at the header bottom and adds no height', () => {
  const without = plainOf()
  const withLine = plainOf({ headerSeparatorStyle: 'line' })
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
  assert.equal(model.headerSeparator(plainOf({ headerSeparatorStyle: 'line', headerSeparatorThickness: 1000 })).thickness,
    px(css.headerStyle, 'height'))
  assert.equal(model.headerSeparator(plainOf({ headerSeparatorStyle: 'line', headerSeparatorThickness: 0 })), null)
})

test('the divider insets are from the column, and it has the card and band edges under every style', () => {
  const own = plainOf({ headerSeparatorStyle: 'line', headerSeparatorInsets: [0, 5, 0, 7] })
  assert.equal(model.headerSeparator(own).left, own.sectionInsets.left + 5)
  assert.equal(model.headerSeparator(own).right, own.sectionInsets.right + 7)
  const grouped = styleOf({ sectionStyle: 'insetGrouped', headerSeparatorStyle: 'line' })
  const line = model.headerSeparator(grouped)
  assert.equal(line.left, model.contentColumn(grouped).left)
  assert.equal(line.right, model.contentColumn(grouped).right)
  // The divider spans the board's column; the title is at the tags' x, inside it by the board inset.
  assert.equal(line.left + CARD_PADDING, model.headerEdges(grouped).left)
  // The header element sits in the column, so the CSS left and right are 0 (the column's edges).
  assert.match(model.sectionLayout(grouped).headerLineStyle, /left: 0px; right: 0px/)
  const banded = plainOf({ headerSeparatorStyle: 'line', headerBackgroundColor: LIGHT.headerBand })
  assert.match(model.sectionLayout(banded).headerLineStyle, /left: 0px; right: 0px/)
  assert.equal(model.headerSeparator(banded).left, model.contentColumn(banded).left)
})

test('the tags fold at the reduced width', () => {
  const foldable = (style) => {
    const rows = model.rowsFromTops(flow(style, TAG_WIDTHS).tops)
    return model.foldState({ defaultVisibleRows: FOLD_ROWS }, rows, false)
  }
  const plain = foldable(plainOf())
  const grouped = foldable(styleOf({ sectionStyle: 'insetGrouped' }))
  assert.equal(plain.canFold, true)
  assert.equal(plain.visible.filter(Boolean).length, 6)
  assert.equal(grouped.canFold, true)
  // Wrapping earlier leaves fewer tags in the first rows.
  assert.ok(grouped.visible.filter(Boolean).length < plain.visible.filter(Boolean).length)
  // Three rows at the full width fit the limit of three, four rows at the reduced width do not.
  const threeRows = (style) => model.foldState({ defaultVisibleRows: 3 }, model.rowsFromTops(flow(style, TAG_WIDTHS).tops), false)
  assert.equal(threeRows(plainOf()).canFold, false)
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
  assert.equal(model.resolvedBackgroundColor(plainOf()), '#FFFFFF')
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
  // The raw values 0 and 1, negative lengths clamped, unknown names ignored (the style keeps its default: the card, no divider).
  assert.equal(styleOf({ sectionStyle: 1, headerSeparatorStyle: 1 }).sectionStyle, 'insetGrouped')
  assert.equal(styleOf({ sectionStyle: 1, headerSeparatorStyle: 1 }).headerSeparatorStyle, 'line')
  assert.equal(styleOf({ sectionStyle: 0 }).sectionStyle, 'plain')
  assert.equal(styleOf({ sectionStyle: 'grid', headerSeparatorStyle: 'dashed' }).sectionStyle, 'insetGrouped')
  assert.equal(styleOf({ sectionStyle: 'grid', headerSeparatorStyle: 'dashed' }).headerSeparatorStyle, 'none')
  assert.equal(plainOf({ sectionStyle: 'grid' }).sectionStyle, 'insetGrouped', 'an unknown name does not opt out')
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

// MARK: - sectionBackgroundStyle (flat / liquidGlass) and the light / dark audit

const GLASS_TINT = { light: 'rgba(255, 255, 255, 0.5)', dark: 'rgba(28, 28, 30, 0.5)' }
const LIGHT_OPTIONS = { pixelRatio: 2, dark: false }
const DARK_OPTIONS = { pixelRatio: 2, dark: true }
const GLASS = { sectionStyle: 'insetGrouped', sectionBackgroundStyle: 'liquidGlass' }
const glassRule = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-animated-item/cyl_animated_item_model')

test('the card background is flat by default and the key parses', () => {
  assert.equal(styleOf().sectionBackgroundStyle, 'flat')
  assert.equal(model.resolvedSectionBackgroundStyle(styleOf({ sectionStyle: 'insetGrouped' })), 'flat')
  assert.equal(styleOf({ sectionBackgroundStyle: 'LiquidGlass' }).sectionBackgroundStyle, 'liquidGlass')
  assert.equal(styleOf({ sectionBackgroundStyle: 1 }).sectionBackgroundStyle, 'liquidGlass')
  assert.equal(styleOf({ sectionBackgroundStyle: 'flat' }).sectionBackgroundStyle, 'flat')
  assert.equal(styleOf({ sectionBackgroundStyle: 'frosted' }).sectionBackgroundStyle, 'flat')
  assert.doesNotMatch(model.sectionLayout(styleOf({ sectionStyle: 'insetGrouped' })).cardStyle, /backdrop-filter/)
})

test('a glass card has the blur, the tint and the card corners, and the layout does not change', () => {
  const flat = styleOf({ sectionStyle: 'insetGrouped' })
  const glass = styleOf(GLASS)
  const css = model.sectionLayout(glass)
  assert.match(css.cardStyle, /backdrop-filter:blur\(16px\) saturate\(180%\)/)
  assert.match(css.cardStyle, new RegExp(`border-radius: ${CARD_RADIUS}px`))
  assert.doesNotMatch(css.cardStyle, /--cyl-item-inset/)
  assert.match(css.cardStyle, new RegExp(`padding: ${CARD_PADDING}px ${CARD_PADDING}px ${CARD_PADDING}px ${CARD_PADDING}px`))
  // Same geometry: everything but the card's own background is the flat one.
  const flatCss = model.sectionLayout(flat)
  assert.equal(css.listStyle, flatCss.listStyle)
  assert.equal(css.itemsStyle, flatCss.itemsStyle)
  assert.equal(css.headerStyle, flatCss.headerStyle)
  assert.deepEqual(model.tagColumn(glass), model.tagColumn(flat))
  assert.deepEqual(flow(glass, TAG_WIDTHS), flow(flat, TAG_WIDTHS))
})

test('the glass card falls back to flat, with the same layout, where there is no glass', () => {
  glassRule.cylAnimatedItemLiquidGlassSetActiveOverride(false)
  try {
    const glass = styleOf(GLASS)
    assert.equal(model.resolvedSectionBackgroundStyle(glass), 'flat')
    const css = model.sectionLayout(glass)
    assert.doesNotMatch(css.cardStyle, /backdrop-filter/)
    assert.equal(css.cardStyle, model.sectionLayout(styleOf({ sectionStyle: 'insetGrouped' })).cardStyle)
    assert.equal(model.resolvedSectionBackgroundColor(glass), LIGHT.card)
  } finally {
    glassRule.cylAnimatedItemLiquidGlassSetActiveOverride(undefined)
  }
})

test('every unset color is resolved by the color mode: light and dark differ as named', () => {
  const light = (style) => styleOf(style, LIGHT_OPTIONS)
  const dark = (style) => styleOf(style, DARK_OPTIONS)
  assert.equal(model.resolvedSectionBackgroundColor(light({ sectionStyle: 'insetGrouped' })), LIGHT.card)
  assert.equal(model.resolvedSectionBackgroundColor(dark({ sectionStyle: 'insetGrouped' })), DARK.card)
  assert.equal(model.resolvedSectionBackgroundColor(light(GLASS)), GLASS_TINT.light)
  assert.equal(model.resolvedSectionBackgroundColor(dark(GLASS)), GLASS_TINT.dark)
  assert.match(model.sectionLayout(light(GLASS)).cardStyle, /background-color:rgba\(255,255,255,0\.375\)/)
  assert.match(model.sectionLayout(dark(GLASS)).cardStyle, /background-color:rgba\(28,28,30,0\.375\)/)
  assert.match(model.sectionLayout(light(GLASS)).cardStyle, /inset 0 1px 0 rgba\(255,255,255,0\.6\)/)
  assert.match(model.sectionLayout(dark(GLASS)).cardStyle, /inset 0 1px 0 rgba\(255,255,255,0\.18\)/)
  assert.equal(light({}).sectionPalette.headerBand, LIGHT.headerBand)
  assert.equal(dark({}).sectionPalette.headerBand, DARK.headerBand)
  assert.equal(model.resolvedHeaderSeparatorColor(light({})), model.SECTION_COLORS.light.separator)
  assert.equal(model.resolvedHeaderSeparatorColor(dark({})), model.SECTION_COLORS.dark.separator)
  assert.match(model.sectionLayout(dark({ headerSeparatorStyle: 'line' })).headerLineStyle, /background-color: rgba\(84, 84, 88, 0\.6\)/)
  assert.equal(model.resolvedBackgroundColor(light({ sectionStyle: 'insetGrouped' })), LIGHT.groupedBackground)
  assert.equal(model.resolvedBackgroundColor(dark({ sectionStyle: 'insetGrouped' })), DARK.groupedBackground)
  assert.equal(model.sectionLayout(dark({ sectionStyle: 'insetGrouped' })).backgroundStyle, 'background-color: #000000')
})

test('the colors a configuration sets win in light and in dark', () => {
  const set = {
    sectionStyle: 'insetGrouped', backgroundColor: CUSTOM_BACKGROUND, sectionBackgroundColor: '#112233',
    headerBackgroundColor: '#445566', headerSeparatorStyle: 'line', headerSeparatorColor: '#778899',
  }
  const modes = [LIGHT_OPTIONS, DARK_OPTIONS]
  modes.forEach((options) => {
    const style = styleOf(set, options)
    const css = model.sectionLayout(style)
    assert.equal(model.resolvedBackgroundColor(style), CUSTOM_BACKGROUND)
    assert.match(css.backgroundStyle, new RegExp(CUSTOM_BACKGROUND))
    assert.match(css.cardStyle, /background-color: #112233/)
    assert.match(css.headerStyle, /background-color: #445566/)
    assert.match(css.headerLineStyle, /background-color: #778899/)
    // A glass card tinted with the app's color keeps it (made translucent by the glass rule), in both modes.
    const glass = styleOf({ ...set, sectionBackgroundStyle: 'liquidGlass' }, options)
    assert.equal(model.resolvedSectionBackgroundColor(glass), '#112233')
    assert.match(model.sectionLayout(glass).cardStyle, /background-color:rgba\(17,34,51,/)
  })
})

test('the component builds the model again when the system theme changes, so unset colors follow it', () => {
  const fs = require('node:fs')
  const path = require('node:path')
  const dir = path.join(__dirname, '..', 'packages', 'cyl-tag-list-miniprogram', 'miniprogram_dist', 'cyl-tag-list')
  const source = fs.readFileSync(path.join(dir, 'cyl-tag-list.js'), 'utf8')
  // rebuild() normalizes with the current mode, and the theme listener calls rebuild().
  assert.match(source, /normalize\(this\.data\.configuration, \{ pixelRatio: pixelRatio\(\), dark: theme\.isDark\(\) \}\)/)
  assert.match(source, /theme\.onChange\(\(\) => this\.rebuild\(\)\)/)
  // The same configuration gives different unset colors in the two modes.
  const configuration = { style: GLASS, sections: [{ title: TITLE, items: ['a'] }] }
  const layoutIn = (dark) => model.sectionLayout(model.normalize(configuration, { pixelRatio: 2, dark }).sections[0].style)
  assert.notEqual(layoutIn(false).cardStyle, layoutIn(true).cardStyle)
  assert.notEqual(layoutIn(false).backgroundStyle, layoutIn(true).backgroundStyle)
})

// MARK: - tintColor: the built-in non-tag views are legible on what is behind them

const BLACK = '#000000'
const WHITE = '#FFFFFF'
const LIGHT_BACKGROUND = '#F2F2F7'
const DARK_BACKGROUND = '#1C1C1E'
const CLEAR = 'rgba(0, 0, 0, 0)'
const MODES = [LIGHT_OPTIONS, DARK_OPTIONS]

test('tintColor is nullable and the key parses', () => {
  assert.equal(styleOf().tintColor, null)
  assert.equal(styleOf({ tintColor: '#112233' }).tintColor, '#112233')
  assert.equal(styleOf({ tintColor: 'systemBlue' }).tintColor, '#007AFF')
  assert.equal(styleOf({ tintColor: 'not a color' }).tintColor, null)
  assert.ok(model.TINT_LUMINANCE_THRESHOLD > 0 && model.TINT_LUMINANCE_THRESHOLD < 1)
})

test('a light list background gives a dark tint and a dark one a light tint, whatever the system mode', () => {
  MODES.forEach((options) => {
    const light = styleOf({ backgroundColor: LIGHT_BACKGROUND }, options)
    const dark = styleOf({ backgroundColor: DARK_BACKGROUND }, options)
    assert.equal(model.resolvedHeaderTextColor(light), BLACK)
    assert.equal(model.resolvedFoldControlColor(light), BLACK)
    assert.equal(model.resolvedHeaderTextColor(dark), WHITE)
    assert.equal(model.resolvedFoldControlColor(dark), WHITE)
    assert.match(model.sectionLayout(light).headerStyle, /color: #000000/)
    assert.match(model.sectionLayout(dark).headerStyle, /color: #FFFFFF/)
  })
})

test('under insetGrouped the grouped background decides when the app set none', () => {
  // The grouped background is light (#F2F2F7) in light mode and black in dark mode.
  assert.equal(model.resolvedHeaderTextColor(styleOf({ sectionStyle: 'insetGrouped' }, LIGHT_OPTIONS)), BLACK)
  assert.equal(model.resolvedHeaderTextColor(styleOf({ sectionStyle: 'insetGrouped' }, DARK_OPTIONS)), WHITE)
  // An app background wins over the grouped one: a light one in dark mode keeps the text dark.
  assert.equal(model.resolvedHeaderTextColor(styleOf({ sectionStyle: 'insetGrouped', backgroundColor: LIGHT_BACKGROUND }, DARK_OPTIONS)), BLACK)
})

test('unset with a transparent or unset list background follows the system mode', () => {
  assert.equal(model.resolvedHeaderTextColor(plainOf({}, LIGHT_OPTIONS)), BLACK)
  assert.equal(model.resolvedHeaderTextColor(plainOf({}, DARK_OPTIONS)), WHITE)
  assert.equal(model.resolvedFoldControlColor(plainOf({}, DARK_OPTIONS)), WHITE)
  // A translucent background is not opaque: the mode decides.
  assert.equal(model.resolvedHeaderTextColor(styleOf({ backgroundColor: CLEAR }, LIGHT_OPTIONS)), BLACK)
  assert.equal(model.resolvedHeaderTextColor(styleOf({ backgroundColor: CLEAR }, DARK_OPTIONS)), WHITE)
  assert.equal(model.resolvedHeaderTextColor(styleOf({ backgroundColor: 'rgba(0, 0, 0, 0.4)' }, LIGHT_OPTIONS)), BLACK)
  assert.equal(model.resolvedHeaderTextColor(styleOf({ backgroundColor: 'rgba(255, 255, 255, 0.4)' }, DARK_OPTIONS)), WHITE)
})

test('the same transparent configuration differs between light and dark', () => {
  const configuration = { style: { backgroundColor: CLEAR }, sections: [{ title: TITLE, items: ['a'] }] }
  const layoutIn = (dark) => model.sectionLayout(model.normalize(configuration, { pixelRatio: 2, dark }).sections[0].style)
  assert.notEqual(layoutIn(false).headerStyle, layoutIn(true).headerStyle)
  assert.match(layoutIn(false).headerStyle, /color: #000000/)
  assert.match(layoutIn(true).headerStyle, /color: #FFFFFF/)
  // An opaque background gives the same texts in both modes.
  const opaque = { style: { backgroundColor: LIGHT_BACKGROUND }, sections: configuration.sections }
  const opaqueIn = (dark) => model.sectionLayout(model.normalize(opaque, { pixelRatio: 2, dark }).sections[0].style)
  assert.equal(opaqueIn(false).headerStyle, opaqueIn(true).headerStyle)
})

test('a set tintColor wins in both modes, over every background', () => {
  MODES.forEach((options) => {
    ;[{}, { backgroundColor: LIGHT_BACKGROUND }, { backgroundColor: DARK_BACKGROUND }, { sectionStyle: 'insetGrouped' },
      { headerBackgroundColor: LIGHT.headerBand }].forEach((extra) => {
      const style = styleOf({ ...extra, tintColor: CUSTOM_COLOR }, options)
      assert.equal(model.resolvedHeaderTextColor(style), CUSTOM_COLOR)
      assert.equal(model.resolvedFoldControlColor(style, true), CUSTOM_COLOR)
      assert.equal(model.resolveTint(style), CUSTOM_COLOR)
    })
  })
})

test('a header or fold color the app sets itself wins over the tint', () => {
  MODES.forEach((options) => {
    const style = styleOf({ backgroundColor: DARK_BACKGROUND, headerTextColor: '#112233', foldControlColor: '#445566', tintColor: CUSTOM_COLOR }, options)
    assert.equal(model.resolvedHeaderTextColor(style), '#112233')
    assert.equal(model.resolvedFoldControlColor(style), '#445566')
  })
})

test('under a header band the tint is resolved against the band color', () => {
  // A light band on a dark list in dark mode: the title is black; a dark band in light mode: white.
  const lightBand = styleOf({ headerBackgroundColor: LIGHT.headerBand, backgroundColor: DARK_BACKGROUND }, DARK_OPTIONS)
  assert.equal(model.resolvedHeaderTextColor(lightBand), BLACK)
  assert.equal(model.resolvedFoldControlColor(lightBand, true), BLACK)
  // The fold control outside the header sits on the list background.
  assert.equal(model.resolvedFoldControlColor(lightBand, false), WHITE)
  const darkBand = styleOf({ headerBackgroundColor: DARK.headerBand, backgroundColor: LIGHT_BACKGROUND }, LIGHT_OPTIONS)
  assert.equal(model.resolvedHeaderTextColor(darkBand), WHITE)
  assert.match(model.sectionLayout(darkBand).headerStyle, /color: #FFFFFF/)
  // A band that is not opaque falls back to the list background, then the mode.
  const clearBand = plainOf({ headerBackgroundColor: CLEAR }, DARK_OPTIONS)
  assert.equal(model.resolvedHeaderTextColor(clearBand), WHITE)
})

test('the default list resolves its list background and its tint against the grouped background', () => {
  // A list that sets nothing is a card on the grouped background (#F2F2F7 light, black dark), never the old white.
  assert.equal(model.resolvedBackgroundColor(styleOf({}, LIGHT_OPTIONS)), LIGHT.groupedBackground)
  assert.equal(model.resolvedBackgroundColor(styleOf({}, DARK_OPTIONS)), DARK.groupedBackground)
  assert.equal(model.sectionLayout(styleOf({}, LIGHT_OPTIONS)).backgroundStyle, `background-color: ${LIGHT.groupedBackground}`)
  assert.equal(model.resolvedHeaderTextColor(styleOf({}, LIGHT_OPTIONS)), BLACK)
  assert.equal(model.resolvedHeaderTextColor(styleOf({}, DARK_OPTIONS)), WHITE)
  assert.equal(model.resolvedFoldControlColor(styleOf({}, DARK_OPTIONS)), WHITE)
  // The grouped background decides, not the system mode: a dark grouped background in light mode gives a light tint, a light
  // one in dark mode a dark tint (the palette is replaced to tell the two rules apart).
  const withGrouped = (options, groupedBackground) => {
    const style = styleOf({}, options)
    return { ...style, sectionPalette: { ...style.sectionPalette, groupedBackground } }
  }
  assert.equal(model.resolvedHeaderTextColor(withGrouped(LIGHT_OPTIONS, DARK.groupedBackground)), WHITE)
  assert.equal(model.resolvedHeaderTextColor(withGrouped(DARK_OPTIONS, LIGHT.groupedBackground)), BLACK)
  // Opted out (plain) with no background of the app's: nothing is painted, so the system mode decides, as before.
  assert.equal(model.resolvedHeaderTextColor(plainOf({}, LIGHT_OPTIONS)), BLACK)
  assert.equal(model.resolvedHeaderTextColor(plainOf({}, DARK_OPTIONS)), WHITE)
})

test('the component draws the fold control with the resolved tint and re-resolves on a theme change', () => {
  const fs = require('node:fs')
  const path = require('node:path')
  const dir = path.join(__dirname, '..', 'packages', 'cyl-tag-list-miniprogram', 'miniprogram_dist', 'cyl-tag-list')
  const source = fs.readFileSync(path.join(dir, 'cyl-tag-list.js'), 'utf8')
  assert.match(source, /model\.resolvedFoldControlColor\(m\.style, m\.foldControl\.position === 'headerTrailing'\)/)
  assert.match(source, /theme\.onChange\(\(\) => this\.rebuild\(\)\)/)
})

// MARK: - The gap between the header and the board is short when there is no divider

const BOARD = { sectionStyle: 'insetGrouped' }
const WITH_DIVIDER = { sectionStyle: 'insetGrouped', headerSeparatorStyle: 'line' }
const TIGHT_HEADER_HEIGHT = model.lineHeight(HEADER_FONT_SIZE) + HEADER_BOARD_TITLE_PADDING
const COMPONENT_DIR = require('node:path').join(__dirname, '..', 'packages', 'cyl-tag-list-miniprogram', 'miniprogram_dist', 'cyl-tag-list')
const readComponent = (name) => require('node:fs').readFileSync(require('node:path').join(COMPONENT_DIR, name), 'utf8')

test('the named constants: the header padding 8 and the board spacing 4', () => {
  assert.equal(model.HEADER_BOARD_TITLE_PADDING, HEADER_BOARD_TITLE_PADDING)
  assert.equal(model.HEADER_BOARD_SPACING, HEADER_BOARD_SPACING)
  assert.equal(TIGHT_HEADER_HEIGHT, 29)
})

test('under the board with no divider the header is the title line plus 8, a minimum with the title centered, not the fixed 36', () => {
  const style = styleOf(BOARD)
  assert.equal(model.isHeaderTightToBoard(style), true)
  assert.equal(style.headerHeightSet, false)
  assert.equal(model.headerHeightOf(style), TIGHT_HEADER_HEIGHT)
  assert.ok(model.headerHeightOf(style) < FIXED_HEADER_HEIGHT)
  const css = model.sectionLayout(style).headerStyle
  assert.match(css, new RegExp(`^min-height: ${TIGHT_HEADER_HEIGHT}px; margin: 0 16px 0 16px; padding: 0 12px 0 12px; `))
  assert.doesNotMatch(css, /(^|; )height:/)
  // CSS grows the header with the fold / More control (never below it) and centers the title: a flex row with align-items center.
  assert.match(readComponent('cyl-tag-list.wxss'), /\.cyl-header \{[^}]*display: flex; align-items: center;/)
})

test('the board starts 4 below a header with no divider, not at the section top inset', () => {
  const style = styleOf(BOARD)
  assert.equal(model.headerBoardOffset(style), HEADER_BOARD_SPACING)
  assert.notEqual(HEADER_BOARD_SPACING, style.sectionInsets.top)
  const css = model.sectionLayout(style)
  assert.equal(px(css.listStyle, 'padding'), HEADER_BOARD_SPACING)
  assert.equal(css.listStyle, `padding: ${HEADER_BOARD_SPACING}px 16px ${style.sectionInsets.bottom}px 16px`)
  // The space below the board is unchanged, and so is the card's own padding and the items' margins.
  assert.match(css.cardStyle, new RegExp(`^padding: ${CARD_PADDING}px ${CARD_PADDING}px ${CARD_PADDING}px ${CARD_PADDING}px;`))
  assert.equal(css.itemsStyle, `margin-right: -${style.interitemSpacing}px; margin-bottom: -${style.lineSpacing}px`)
  // A section with no header shown keeps the section's top inset above its board.
  assert.equal(model.headerBoardOffset(style, false), SECTION_TOP_INSET)
  assert.equal(model.sectionLayout(style, { hasHeader: false }).listStyle, `padding: ${SECTION_TOP_INSET}px 16px ${style.sectionInsets.bottom}px 16px`)
  assert.equal(model.sectionLayout(style, { hasHeader: false }).headerStyle, css.headerStyle)
})

test('the component tells sectionLayout whether the section shows a header', () => {
  const source = readComponent('cyl-tag-list.js')
  assert.match(source, /model\.sectionLayout\(style, \{ hasHeader \}\)/)
  assert.match(source, /m\.foldControl\.position === 'headerTrailing'/)
})

test('with the divider on the old strings stay: the fixed header height and the section top inset', () => {
  const style = styleOf(WITH_DIVIDER)
  assert.equal(model.isHeaderTightToBoard(style), false)
  assert.equal(model.headerHeightOf(style), FIXED_HEADER_HEIGHT)
  const css = model.sectionLayout(style)
  assert.match(css.headerStyle, new RegExp(`^height: ${FIXED_HEADER_HEIGHT}px; margin: 0 16px 0 16px; padding: 0 12px 0 12px; `))
  assert.equal(css.listStyle, 'padding: 10px 16px 10px 16px')
  assert.equal(model.headerBoardOffset(style), SECTION_TOP_INSET)
  assert.equal(model.headerSeparator(style).thickness, HAIRLINE)
})

test('the plain style keeps the old strings whatever the divider', () => {
  ;[{}, { headerSeparatorStyle: 'line' }].forEach((extra) => {
    const style = plainOf(extra)
    assert.equal(model.isHeaderTightToBoard(style), false)
    assert.equal(model.headerHeightOf(style), FIXED_HEADER_HEIGHT)
    const css = model.sectionLayout(style)
    assert.match(css.headerStyle, new RegExp(`^height: ${FIXED_HEADER_HEIGHT}px; padding: 0 16px; `))
    assert.equal(css.listStyle, 'padding: 10px 16px 0px 16px')
  })
})

test('an explicitly set headerHeight is the minimum of a header with no divider; a smaller one does not shrink it', () => {
  const taller = styleOf({ ...BOARD, headerHeight: 44 })
  assert.equal(taller.headerHeightSet, true)
  assert.equal(model.headerHeightOf(taller), 44)
  assert.match(model.sectionLayout(taller).headerStyle, /^min-height: 44px; margin: /)
  // The same 36 as the default, when the app asks for it, is a minimum again.
  assert.equal(model.headerHeightOf(styleOf({ ...BOARD, headerHeight: FIXED_HEADER_HEIGHT })), FIXED_HEADER_HEIGHT)
  // Below the title's line plus 8 the text decides.
  assert.equal(model.headerHeightOf(styleOf({ ...BOARD, headerHeight: 20 })), TIGHT_HEADER_HEIGHT)
  // The board's offset does not depend on it.
  assert.equal(model.headerBoardOffset(taller), HEADER_BOARD_SPACING)
})

test('the headerHeight key: set only by a number, kept by a section style, never by the default', () => {
  assert.equal(model.DEFAULT_STYLE.headerHeightSet, false)
  assert.equal(model.mergeStyle({}).headerHeightSet, false)
  assert.equal(model.mergeStyle({ headerHeight: 40 }).headerHeightSet, true)
  assert.equal(model.mergeStyle({ headerHeight: 'tall' }).headerHeightSet, false)
  assert.equal(model.mergeStyle({ headerHeight: 'tall' }).headerHeight, FIXED_HEADER_HEIGHT)
  const sections = [{ title: TITLE, items: ['a'], style: { itemHeight: 32 } }]
  assert.equal(model.normalize({ style: { headerHeight: 50 }, sections }, { pixelRatio: 2 }).sections[0].style.headerHeightSet, true)
  assert.equal(model.normalize({ sections }, { pixelRatio: 2 }).sections[0].style.headerHeightSet, false)
  const own = { sections: [{ title: TITLE, items: ['a'], style: { headerHeight: 50 } }] }
  assert.equal(model.normalize(own, { pixelRatio: 2 }).sections[0].style.headerHeightSet, true)
})

test('a header that wraps under the board is the title lines plus 8: min-height line + 8, 4 above and 4 below', () => {
  const half = HEADER_BOARD_TITLE_PADDING / 2
  const css = model.sectionLayout(styleOf({ ...BOARD, headerMaxLines: 3 })).headerStyle
  assert.match(css, new RegExp(`^min-height: ${TIGHT_HEADER_HEIGHT}px; margin: 0 16px 0 16px; padding: ${half}px 12px ${half}px 12px; `))
  // With the divider on the wrapping header is what it was.
  const old = model.sectionLayout(styleOf({ ...WITH_DIVIDER, headerMaxLines: 3 })).headerStyle
  const wrap = model.HEADER_WRAP_VERTICAL_PADDING
  assert.match(old, new RegExp(`^min-height: ${FIXED_HEADER_HEIGHT}px; margin: 0 16px 0 16px; padding: ${wrap}px 12px ${wrap}px 12px; `))
})
