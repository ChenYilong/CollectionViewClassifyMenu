/**
 * 标签列表, 1:1 with the iOS example's `CYLImageTagListViewController` (TagViewGroup's TagListActivity): 30 square
 * pictures (the three sample pictures in turn), each with one group of the repository; a tap on a picture shows or
 * hides its tags; the dot, a long press and the tags toast.
 */
const { t } = require('../../utils/i18n.js');
const sample = require('../../utils/android-sample.js');
const data = require('../sample-image-tag/data.js');

Page({
  data: { rows: [], hint: '' },

  onLoad() {
    wx.setNavigationBarTitle({ title: t('标签列表') });
    const groups = data.getTagGroups();
    this.setData({
      hint: t('轻点两下显示或隐藏标签'),
      rows: Array.from({ length: data.LIST_ROW_COUNT }, (_, row) => ({
        row,
        picture: sample.picture(row % 3),
        groups: data.groupsForRow(row, groups),
      })),
    });
  },

  toast(text) {
    this.selectComponent('#toast').show(text);
  },

  /** The cell's imageTapHandler: toggleTagGroups(animated: true). */
  onImageTap(event) {
    this.selectComponent(`#tag-image-${event.currentTarget.dataset.row}`).toggleTagGroups(true);
  },

  onCircleTap() {
    this.toast(t('点击中心圆'));
  },

  onLongPress() {
    this.toast(t('点击中心圆'));
  },

  onTagTap(event) {
    this.toast(t('点击标签：%@', event.detail.tag.title));
  },
});
