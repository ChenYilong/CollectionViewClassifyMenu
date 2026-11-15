/**
 * 标签云（android-tagview）, 1:1 with the iOS example's `CYLTagCloudDemoViewController`: a list created the
 * android-tagview way (init, spacing, then addTags(withTitles:) / addTag(_:)), the same kinds of tags from a
 * configuration dictionary, and a caption that reports taps and deletions. Pushed from the Styles tab.
 */
const { t } = require('../../utils/i18n.js');
const data = require('./data.js');

Page({
  data: {
    codeCaption: '',
    mapCaption: '',
    event: '',
    codeTags: [],
    codeStyle: null,
    mapTags: [],
    mapStyle: null,
  },

  onLoad() {
    wx.setNavigationBarTitle({ title: t('标签云（android-tagview）') });
    const code = data.codeList();
    const map = data.mapList();
    this.setData({
      codeCaption: t('代码初始化：addTags(withTitles:)、addTag(_:)'),
      mapCaption: t('字典初始化：CYLTagListKey.tags'),
      event: t('点击标签，或点 × 删除'),
      codeTags: code.tags,
      codeStyle: code.style,
      mapTags: map.tags,
      mapStyle: map.style,
    });
  },

  /** tagClickHandler of the upper list (the lower list has none). */
  onCodeTap(event) {
    const { position, tag } = event.detail;
    this.setData({ event: t('点击第 %ld 个「%@」', position, tag.title) });
  },

  /** tagDeleteHandler of both lists. */
  onDelete(event) {
    const { position, tag } = event.detail;
    this.setData({ event: t('删除第 %ld 个「%@」', position, tag.title) });
  },
});
