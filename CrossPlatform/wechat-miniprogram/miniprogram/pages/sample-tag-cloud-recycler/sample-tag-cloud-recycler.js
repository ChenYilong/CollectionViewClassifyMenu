/**
 * RecyclerView 示例, 1:1 with the iOS example's `CYLTagCloudRecyclerViewController` (android-tagview's
 * RecyclerViewActivity): 21 text rows and a footer row with two tags.
 */
const { t } = require('../../utils/i18n.js');
const data = require('../sample-tag-cloud/data.js');

Page({
  data: { texts: [], footerTags: [], style: null },

  onLoad() {
    wx.setNavigationBarTitle({ title: t('RecyclerView 示例') });
    this.setData({ texts: data.recyclerTexts(), footerTags: data.footerTags(), style: data.cloudStyle() });
  },
});
