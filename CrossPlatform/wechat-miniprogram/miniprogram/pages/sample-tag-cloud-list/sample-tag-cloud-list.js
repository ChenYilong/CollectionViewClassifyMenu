/**
 * ListView 示例, 1:1 with the iOS example's `CYLTagCloudListViewController` (android-tagview's ListViewActivity):
 * 51 rows, each a tag list that does not scroll with three tags of the row's text; the row is as tall as its tags.
 */
const { t } = require('../../utils/i18n.js');
const data = require('../sample-tag-cloud/data.js');

Page({
  data: { rows: [], style: null },

  onLoad() {
    wx.setNavigationBarTitle({ title: t('ListView 示例') });
    this.setData({
      style: data.cloudStyle(),
      rows: Array.from({ length: data.LIST_ROW_COUNT }, (_, row) => ({ row, tags: data.tagsForRow(row) })),
    });
  },
});
