/**
 * The hot search screen of android-tagview's README (YY), 1:1 with the iOS example's `CYLHotSearchViewController`:
 * no navigation bar, an orange search bar with 取消 (goes back), then 热门搜索 tags, some with a 神 or 热 badge; a tag
 * fills the search field and toasts 搜索「…」.
 */
const { t } = require('../../utils/i18n.js');
const data = require('../sample-tag-cloud/data.js');

/** The orange area above the search bar: the status bar and WeChat's menu button (the capsule). */
function topInset() {
  try {
    const info = wx.getWindowInfo ? wx.getWindowInfo() : wx.getSystemInfoSync();
    const menu = wx.getMenuButtonBoundingClientRect ? wx.getMenuButtonBoundingClientRect() : null;
    if (menu && menu.bottom) return menu.bottom + 4;
    return (info.statusBarHeight || 20) + 44;
  } catch (error) {
    return 64;
  }
}

Page({
  data: {
    top: 64,
    orange: data.ORANGE,
    text: '',
    focus: false,
    placeholder: '',
    cancelTitle: '',
    sectionTitle: '',
    tags: [],
    style: null,
  },

  onLoad() {
    // The navigation bar is hidden (navigationStyle custom), as viewWillAppear hides it; its title is not shown.
    this.setData({
      top: topInset(),
      placeholder: t('主播昵称/直播间ID/神曲名'),
      cancelTitle: t('取消'),
      sectionTitle: t('热门搜索'),
      tags: data.hotTags(),
      style: data.hotStyle(),
    });
  },

  onInput(event) {
    this.setData({ text: event.detail.value });
  },

  /** searchBarViewSearchButtonClicked: the keyboard goes away. */
  onConfirm() {
    this.setData({ focus: false });
    wx.hideKeyboard && wx.hideKeyboard();
  },

  /** searchBarViewCancelButtonClicked: back. */
  cancel() {
    wx.navigateBack();
  },

  onTagTap(event) {
    const { tag } = event.detail;
    this.setData({ text: tag.title });
    this.selectComponent('#toast').show(t('搜索「%@」', tag.title));
  },
});
