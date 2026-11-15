// The image tag model (components/cyl-tag-image/model.js): the core's CYLImageTagGroupView geometry and animations
// and CYLImageTagView's group separation; the sample's repository (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const model = require('../miniprogram/components/cyl-tag-image/model.js');
const data = require('../miniprogram/pages/sample-image-tag/data.js');

test('a tap turns a tag to the next of the ten line directions', () => {
  assert.equal(model.nextDirection('leftCenter'), 'leftTop');
  assert.equal(model.nextDirection('leftBottomStraight'), 'rightCenter');
  assert.equal(model.nextDirection('rightBottomStraight'), 'leftCenter');
  assert.equal(model.nextDirection('center'), 'leftCenter');
  let direction = 'leftCenter';
  for (let i = 0; i < 10; i += 1) direction = model.nextDirection(direction);
  assert.equal(direction, 'leftCenter');
});

test('new groups get the sample\'s directions', () => {
  assert.deepEqual(model.defaultDirections(0), []);
  assert.deepEqual(model.defaultDirections(1), ['rightCenter']);
  assert.deepEqual(model.defaultDirections(2), ['rightTop', 'rightBottom']);
  assert.deepEqual(model.defaultDirections(3), ['rightTop', 'rightCenter', 'rightBottom']);
  assert.equal(model.defaultDirections(9).length, 6);
});

test('the space used and the origins follow TagGroupUtils', () => {
  const used = model.tagSpaceUsed([{ direction: 'rightTop', width: 80, height: 23 }, { direction: 'leftBottom', width: 50, height: 23 }]);
  assert.deepEqual(used.insets, { top: 51, left: 50, bottom: 28, right: 80 });
  assert.equal(used.verticalDistance, 28);
  // A tag taller than the vertical distance grows both distances.
  const tall = model.tagSpaceUsed([{ direction: 'rightTopStraight', width: 80, height: 40 }]);
  assert.equal(tall.verticalDistance, 40);
  assert.equal(tall.tiltDistance, 32);
  assert.deepEqual(model.originForTag({ width: 80, height: 23 }, 'rightTop', { x: 100, y: 100 }, 28, 20), { x: 100, y: 49 });
  assert.deepEqual(model.originForTag({ width: 80, height: 23 }, 'leftCenter', { x: 100, y: 100 }, 28, 20), { x: 20, y: 77 });
  assert.deepEqual(model.originForTag({ width: 80, height: 20 }, 'center', { x: 100, y: 100 }, 28, 20), { x: 60, y: 90 });
});

test('a group lays out its tags and lines, and its dot moves inward at the edges', () => {
  const group = model.makeGroup([model.makeTag('a', 'rightTop'), model.makeTag('b', 'rightCenter')], { x: 0.4, y: 0.5 });
  const sizes = [{ width: 80, height: 23 }, { width: 100, height: 23 }];
  const layout = model.layoutGroup(group, sizes, 375, 375);
  assert.deepEqual(layout.center, { x: 150, y: 187.5 });
  assert.deepEqual(layout.frames[1], { x: 150, y: 164.5, width: 100, height: 23 });
  assert.deepEqual(layout.lines[0], [{ x: 150, y: 187.5 }, { x: 150, y: 159.5 }, { x: 230, y: 159.5 }]);
  assert.deepEqual(layout.lines[1], [{ x: 150, y: 187.5 }, { x: 250, y: 187.5 }]);
  const edge = model.layoutGroup(model.makeGroup([model.makeTag('a', 'rightCenter')], { x: 1, y: 0 }), [sizes[1]], 375, 375);
  assert.deepEqual(edge.center, { x: 275, y: 28 });
  const offset = model.layoutGroup(group, sizes, 375, 375, { x: 0, y: 10 });
  assert.deepEqual(offset.base, { x: 150, y: 187.5 });
  assert.equal(offset.center.y, 197.5);
});

test('groups that cover each other move apart by the smallest distance, not while editing', () => {
  const frames = [{ x: 0, y: 100, width: 100, height: 50 }, { x: 20, y: 120, width: 100, height: 50 }];
  assert.deepEqual(model.separateGroups(frames, 375), [0, 34]);
  assert.deepEqual(model.separateGroups(frames, 375, { editing: true }), [0, 0]);
  assert.deepEqual(model.separateGroups(frames, 375, { hidden: [false, true] }), [0, 0]);
  assert.deepEqual(model.separateGroups([{ x: 0, y: 0, width: 10, height: 10 }, { x: 0, y: 50, width: 10, height: 10 }], 375), [0, 0]);
});

test('lines are drawn up to a progress', () => {
  const points = [{ x: 0, y: 0 }, { x: 0, y: -30 }, { x: 40, y: -30 }];
  assert.equal(model.linePieces(points, 0).length, 0);
  const half = model.linePieces(points, 3 / 7);
  assert.equal(half.length, 1);
  assert.equal(half[0].length, 30);
  assert.equal(half[0].angle, -90);
  const all = model.linePieces(points, 1);
  assert.equal(all.length, 2);
  assert.equal(all[1].length, 40);
  assert.equal(all[1].angle, 0);
});

test('the animations decelerate through their values', () => {
  assert.equal(model.animatedValue([0, 1], 0), 0);
  assert.equal(model.animatedValue([0, 1], 0.5), 0.75);
  assert.equal(model.animatedValue([0, 1], 1), 1);
  assert.equal(model.animatedValue([5, 11, 8], 1), 8);
  const start = model.showFrame(0);
  assert.equal(start.circleRadius, 5);
  assert.equal(start.linesProgress, 0);
  assert.equal(start.tagAlpha, 0);
  const shown = model.showFrame(model.SHOW_DURATION);
  assert.deepEqual(shown, { circleRadius: 8, circleInnerRadius: 4, linesProgress: 1, tagAlpha: 1 });
  assert.equal(model.hideFrame(200).linesProgress, 1);
  const hidden = model.hideFrame(model.HIDE_DURATION);
  assert.equal(hidden.linesProgress, 0);
  assert.equal(hidden.tagAlpha, 0);
});

test('the sample\'s repository holds two groups; 保存 replaces them; the dialog makes a centered group', () => {
  data.reset();
  const groups = data.getTagGroups();
  assert.equal(groups.length, 2);
  assert.deepEqual(groups[0].tags.map((tag) => tag.direction), ['rightTop', 'rightCenter', 'rightBottom']);
  assert.equal(groups[0].tags[1].title, '英伦加绒青年棕色保暖鞋子。');
  assert.deepEqual(groups[1].percentPosition, { x: 0.3, y: 0.2 });
  groups[0].tags[0].title = 'changed';
  assert.equal(data.getTagGroups()[0].tags[0].title, '头层牛皮', 'copies are returned');
  const created = data.groupWithNames(['A', '', 'C']);
  assert.deepEqual(created.tags, [{ title: 'A', direction: 'rightTop' }, { title: 'C', direction: 'rightBottom' }]);
  assert.deepEqual(created.percentPosition, { x: 0.5, y: 0.5 });
  assert.equal(data.groupWithNames(['', '', '']).tags.length, 0);
  data.setTagGroups([created]);
  assert.equal(data.getTagGroups().length, 1);
  assert.deepEqual(data.groupsForRow(7), [created]);
  assert.deepEqual(data.groupsForRow(0, []), []);
  data.reset();
  assert.equal(data.groupsForRow(3)[0].tags.length, 1);
});
