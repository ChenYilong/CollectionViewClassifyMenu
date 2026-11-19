/**
 * 图片标签, 1:1 with the iOS example's `CYLImageTagSampleViewController` (shellljx/TagViewGroup's MainActivity): a
 * picture with two tag groups (a tap on the picture shows or hides them; the dot and the tags toast), 创建标签 (the
 * edit screen; 保存 there updates this picture) and 标签列表 (30 pictures). Pushed from the Styles tab.
 */
const { t } = require('../../utils/i18n.js');
const sample = require('../../utils/android-sample.js');
const data = require('./data.js');

Page({
  data: { picture: {}, groups: [], hint: '', pink: sample.COLORS.systemPink, createTitle: '', listTitle: '' },

  onLoad() {
    wx.setNavigationBarTitle({ title: t('图片标签') });
    this.setData({
      picture: sample.picture(0),
      hint: t('轻点两下显示或隐藏标签'),
      createTitle: t('创建标签'),
      listTitle: t('标签列表'),
    });
  },

  onShow() {
    // onSave: the picture shows the repository's groups (also after 保存 on the edit screen).
    const groups = data.getTagGroups();
    if (JSON.stringify(groups) !== JSON.stringify(this._shown)) {
      this._shown = groups;
      this.setData({ groups });
    }
  },

  toast(text) {
    this.selectComponent('#toast').show(text);
  },

  /** imageTapHandler: toggleTagGroups(animated: true). */
  onImageTap() {
    this.selectComponent('#tag-image').toggleTagGroups(true);
  },

  onCircleTap() {
    this.toast(t('点击中心圆'));
  },

  onTagTap(event) {
    this.toast(t('点击标签：%@', event.detail.tag.title));
  },

  /** longPressHandler: the same toast as the dot. */
  onLongPress() {
    this.toast(t('点击中心圆'));
  },

  openEdit() {
    wx.navigateTo({ url: '/pages/sample-image-tag-edit/sample-image-tag-edit' });
  },

  openList() {
    wx.navigateTo({ url: '/pages/sample-image-tag-list/sample-image-tag-list' });
  },
});
