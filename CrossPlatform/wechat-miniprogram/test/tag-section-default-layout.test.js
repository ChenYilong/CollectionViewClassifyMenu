// Snapshot of the default model output of cyl-tag-list (three sections), taken from the code BEFORE the section style
// (docs/tag-section-style.md) existed. The opt-out `sectionStyle: 'plain'` (the card is the default look now) must still give
// exactly these strings: the card, header band and header divider are off, so no CSS of the sections or of a tag moves.
const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const model = require('../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-tag-list/model.js')

const SNAPSHOT_FILE = path.join(__dirname, 'fixtures', 'tag-section-default-layout.json')
const LIGHT_OPTIONS = { pixelRatio: 2 }
const DARK_OPTIONS = { pixelRatio: 3, dark: true }
const NORMAL_STATE = 'normal'
const NO_ICON = { kind: 'none' }
const PLAIN_SECTION_STYLE = 'plain'

/** Three sections: tags of different lengths (so rows break at different places), the last without a header title. */
const CONFIGURATION = {
  sections: [
    { title: 'Fruit', items: ['Apple', 'Banana', 'Cherry', 'Durian', 'Elderberry', 'Fig', 'Grape', 'Honeydew'] },
    { title: 'Short', items: ['One', 'Two', 'Three'] },
    { title: '', items: ['A much longer tag title', 'Short', 'Another quite long title', 'Mid', 'Tiny', 'X'] },
  ],
}

/** The same list with the opt-out of the default card: the look of before the section style, which the fixture holds. */
const PLAIN_CONFIGURATION = { ...CONFIGURATION, style: { sectionStyle: PLAIN_SECTION_STYLE } }

/** The section CSS and every tag's cell CSS of one normalized model. */
function snapshot(options, configuration = PLAIN_CONFIGURATION) {
  return model.normalize(configuration, options).sections.map((section) => ({
    layout: model.sectionLayout(section.style),
    cells: section.items.map((item) => model.tagLayout(section.style, item, NORMAL_STATE, NO_ICON,
      section.style.interitemSpacing, section.style.lineSpacing).cellStyle),
  }))
}

test('sectionStyle plain gives the section layout of before the section style', () => {
  const expected = JSON.parse(fs.readFileSync(SNAPSHOT_FILE, 'utf8'))
  assert.deepEqual(JSON.parse(JSON.stringify(snapshot(LIGHT_OPTIONS))), expected.light)
  assert.deepEqual(JSON.parse(JSON.stringify(snapshot(DARK_OPTIONS))), expected.dark)
})

test('the new default (nothing set) is the card: every section has a card and the grouped background, the tags are the same', () => {
  const expected = JSON.parse(fs.readFileSync(SNAPSHOT_FILE, 'utf8'))
  const groupedBackground = { light: 'background-color: #F2F2F7', dark: 'background-color: #000000' }
  const modes = [['light', LIGHT_OPTIONS], ['dark', DARK_OPTIONS]]
  modes.forEach(([mode, options]) => {
    const sections = snapshot(options, CONFIGURATION)
    sections.forEach((section, i) => {
      assert.ok(section.layout.cardStyle, `${mode} section ${i} has a card`)
      assert.equal(section.layout.backgroundStyle, groupedBackground[mode])
      assert.notEqual(section.layout.listStyle, expected[mode][i].layout.listStyle)
      // A tag's own CSS does not depend on the section style.
      assert.deepEqual(section.cells, expected[mode][i].cells)
    })
  })
})
