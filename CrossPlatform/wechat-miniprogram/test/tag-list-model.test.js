// The cyl-tag-list model: configuration, selection rules of CYLTagListView.handleTap(at:) and folding (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const model = require('../miniprogram/components/cyl-tag-list/model.js');

function configuration(selectionMode, extra = {}) {
  return {
    selectionMode,
    sections: [
      { title: 'A', items: [{ title: '全部', exclusive: true }, { title: 'a1' }, { title: 'a2' }] },
      { title: 'B', items: [{ title: 'b0' }, { title: 'b1' }] },
    ],
    ...extra,
  };
}

test('normalize applies the core defaults and drops selected keys that address no item', () => {
  const m = model.normalize({ ...configuration('single'), selectedItems: ['0-1', '9-9', 'x', '0-1'] });
  assert.equal(m.allowsEmptySelection, true);
  assert.equal(m.defaultVisibleRows, 0);
  assert.equal(m.foldControl.position, 'none');
  assert.deepEqual(m.selectedItems, ['0-1']);
  assert.equal(model.normalize({ style: { imageSize: '{18, 18}' } }).style.imageSize, 18);
});

test('single selection replaces the other item of the same section only', () => {
  const m = model.normalize(configuration('single'));
  let s = model.tap(m, [], '0-1').selectedItems;
  s = model.tap(m, s, '1-0').selectedItems;
  s = model.tap(m, s, '0-2').selectedItems;
  assert.deepEqual(s, ['1-0', '0-2']);
});

test('tapping a selected item deselects it unless empty selection is off and it is the last one', () => {
  const allowed = model.normalize(configuration('single'));
  assert.deepEqual(model.tap(allowed, ['0-1'], '0-1').selectedItems, []);
  const required = model.normalize(configuration('single', { allowsEmptySelection: false }));
  const result = model.tap(required, ['0-1'], '0-1');
  assert.deepEqual(result.selectedItems, ['0-1']);
  assert.equal(result.changed, false);
});

test('in multiple mode an exclusive item clears its section, and any other item clears the exclusive one', () => {
  const m = model.normalize(configuration('multiple'));
  let s = ['0-0', '1-0'];
  s = model.tap(m, s, '0-1').selectedItems;
  assert.deepEqual(s, ['1-0', '0-1']);
  s = model.tap(m, s, '0-2').selectedItems;
  assert.deepEqual(s, ['1-0', '0-1', '0-2']);
  s = model.tap(m, s, '0-0').selectedItems;
  assert.deepEqual(s, ['1-0', '0-0']);
});

test('selection mode none and disabled items do not change the selection', () => {
  const none = model.normalize(configuration('none'));
  assert.deepEqual(model.tap(none, [], '0-1'), { selectedItems: [], selected: true, changed: false });
  const disabled = model.normalize({ selectionMode: 'multiple', sections: [{ items: [{ title: 'x', enabled: false }] }] });
  assert.equal(model.tap(disabled, [], '0-0').changed, false);
});

test('rows come from the measured tops, and a section folds only when it needs more than defaultVisibleRows', () => {
  const rows = model.rowsFromTops([10, 10, 10.5, 52, 52, 94]);
  assert.deepEqual(rows, [0, 0, 0, 1, 1, 2]);
  const m = model.normalize({ defaultVisibleRows: 2 });
  assert.deepEqual(model.foldState(m, rows, false), { canFold: true, visible: [true, true, true, true, true, false] });
  assert.equal(model.foldState(m, rows, true).visible.every(Boolean), true);
  assert.equal(model.foldState(m, [0, 0, 1], false).canFold, false);
  assert.equal(model.foldState(model.normalize({}), rows, false).canFold, false);
  assert.equal(model.foldTitle(false), '更多');
  assert.equal(model.foldTitle(true), '收起');
});

test('the style falls back to the core defaults (CYLMenuStyle, CYLTagAppearance) and reads the same keys', () => {
  const d = model.normalize({}).style;
  assert.deepEqual(
    [d.itemHeight, d.imageSize, d.imageTitleSpacing, d.interitemSpacing, d.lineSpacing, d.headerHeight, d.fontSize],
    [30, 14, 4, 10, 10, 36, 14],
  );
  assert.deepEqual(d.sectionInsets, { top: 10, left: 16, bottom: 10, right: 16 });
  assert.deepEqual(d.contentInsets, { top: 5, left: 10, bottom: 5, right: 10 });
  const s = model.normalize({ style: {
    itemHeight: 36, imageSize: '{18, 18}', imageTitleSpacing: 6, sectionInsets: '{0, 8, 4, 8}',
    tagContentInsets: [2, 12, 2, 12], font: { size: 15 },
  } }).style;
  assert.deepEqual([s.itemHeight, s.imageSize, s.imageTitleSpacing, s.fontSize], [36, 18, 6, 15]);
  assert.deepEqual(s.sectionInsets, { top: 0, left: 8, bottom: 4, right: 8 });
  assert.deepEqual(s.contentInsets, { top: 2, left: 12, bottom: 2, right: 12 });
});
