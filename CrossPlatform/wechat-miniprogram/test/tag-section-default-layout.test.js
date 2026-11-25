// Snapshot of the default model output of cyl-tag-list (three sections), taken from the code BEFORE the section style
// (docs/tag-section-style.md) existed. A default style must still give exactly these strings: the card, header band and
// header divider are off, so no CSS of the sections or of a tag moves.
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

/** Three sections: tags of different lengths (so rows break at different places), the last without a header title. */
const CONFIGURATION = {
  sections: [
    { title: 'Fruit', items: ['Apple', 'Banana', 'Cherry', 'Durian', 'Elderberry', 'Fig', 'Grape', 'Honeydew'] },
    { title: 'Short', items: ['One', 'Two', 'Three'] },
    { title: '', items: ['A much longer tag title', 'Short', 'Another quite long title', 'Mid', 'Tiny', 'X'] },
  ],
}

/** The section CSS and every tag's cell CSS of one normalized model. */
function snapshot(options) {
  return model.normalize(CONFIGURATION, options).sections.map((section) => ({
    layout: model.sectionLayout(section.style),
    cells: section.items.map((item) => model.tagLayout(section.style, item, NORMAL_STATE, NO_ICON,
      section.style.interitemSpacing, section.style.lineSpacing).cellStyle),
  }))
}

test('the default style gives the section layout of before the section style', () => {
  const expected = JSON.parse(fs.readFileSync(SNAPSHOT_FILE, 'utf8'))
  assert.deepEqual(JSON.parse(JSON.stringify(snapshot(LIGHT_OPTIONS))), expected.light)
  assert.deepEqual(JSON.parse(JSON.stringify(snapshot(DARK_OPTIONS))), expected.dark)
})
