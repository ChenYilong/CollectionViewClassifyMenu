/**
 * 子页面, 1:1 with the iOS example's `CYLTagCloudSubViewController` (android-tagview's SubActivity): 添加标签并返回
 * returns RESULT_OK — the opener (标签视图示例) adds a tag — and goes back.
 */
const { t } = require('../../utils/i18n.js');
const data = require('../sample-tag-cloud/data.js');

Page({
  data: { title: '', color: data.color(0) },

  onLoad() {
    wx.setNavigationBarTitle({ title: t('子页面') });
    this.setData({ title: t('添加标签并返回') });
  },

  finish() {
    const channel = typeof this.getOpenerEventChannel === 'function' ? this.getOpenerEventChannel() : null;
    if (channel && channel.emit) channel.emit('result');
    wx.navigateBack();
  },
});
