/**
 * The sample's DataRepo (CYLImageTagSampleData): the groups in memory, shared by the three screens (图片标签,
 * 创建标签, 标签列表), and TagEditDialog.createTagGroup. No `wx` calls.
 */
const model = require('cyl-tag-list-miniprogram/cyl-tag-image/model.js');

function initialGroups() {
  return [
    model.makeGroup([
      model.makeTag('头层牛皮', 'rightTop', 'http://www.baidu.com'),
      model.makeTag('英伦加绒青年棕色保暖鞋子。', 'rightCenter', 'http://blog.licrafter.com'),
      model.makeTag('PLAYBOY/花花公子', 'rightBottom', 'http://mc.licrafter.com'),
    ], { x: 0.4, y: 0.5 }),
    model.makeGroup([model.makeTag('很不错的鞋子', 'rightCenter', 'http://mc.licrafter.com')], { x: 0.3, y: 0.2 }),
  ];
}

let tagGroups = initialGroups();

/** The groups (copies). */
function getTagGroups() {
  return tagGroups.map(model.copyGroup);
}

/** Stores the groups (保存). */
function setTagGroups(groups) {
  tagGroups = groups.map(model.copyGroup);
}

/** Back to the sample's groups (tests). */
function reset() {
  tagGroups = initialGroups();
}

/** TagEditDialog.createTagGroup: the non-empty names, the sample's directions, at the center. */
function groupWithNames(names) {
  const titles = names.filter((name) => name !== '');
  const directions = model.defaultDirections(titles.length);
  const tags = titles.slice(0, directions.length).map((title, i) => model.makeTag(title, directions[i]));
  return model.makeGroup(tags, { x: 0.5, y: 0.5 });
}

/** TagListActivity: 30 pictures, each with one group of the repository. */
const LIST_ROW_COUNT = 30;

function groupsForRow(row, groups = getTagGroups()) {
  return groups.length ? [groups[row % groups.length]] : [];
}

module.exports = { initialGroups, getTagGroups, setTagGroups, reset, groupWithNames, LIST_ROW_COUNT, groupsForRow };
