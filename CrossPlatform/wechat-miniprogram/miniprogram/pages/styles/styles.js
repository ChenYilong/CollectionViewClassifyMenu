/**
 * 样式 (tab): CYLTagStyleDemoViewController, 1:1. At the top the tag preview (CYLTagListView, multiple selection, no
 * section header, not scrolling), a hairline, then an inset grouped table in which every row changes one style
 * parameter (or opens another screen) and shows its current value; a tap applies it at once. The actions and their
 * values are in demo.js.
 */
const { t } = require('../../utils/i18n.js');
const demo = require('./demo.js');

function pixelRatio() {
  try {
    return (wx.getWindowInfo ? wx.getWindowInfo() : wx.getSystemInfoSync()).pixelRatio || 2;
  } catch (error) {
    return 2;
  }
}

Page({
  data: { configuration: {}, sections: [] },

  onLoad() {
    // navigationItem.title: the tab keeps its own title (样式).
    wx.setNavigationBarTitle({ title: t('标签样式') });
    this.options = { pixelRatio: pixelRatio() };
    this.state = demo.createState();
    this.apply();
  },

  onShow() {
    if (typeof this.getTabBar === 'function' && this.getTabBar()) this.getTabBar().syncWithRoute(this.route);
  },

  /** reloadItems + applyStyle: the preview and the table's values. */
  apply(callback) {
    this.setData({
      configuration: demo.configuration(this.state, t),
      sections: demo.table(this.state, t, this.options),
    }, callback);
  },

  onSelectionChange(event) {
    this.state.selection = event.detail.keys;
  },

  onRowTap(event) {
    const identifier = event.currentTarget.dataset.identifier;
    const result = demo.performAction(this.state, identifier);
    if (result.navigate) {
      wx.navigateTo({ url: result.navigate });
      return;
    }
    this.apply(() => {
      if (!result.play) return;
      // Show the animations: play the selected tags' icons once they are loaded.
      const list = this.selectComponent('#preview');
      if (list) setTimeout(() => list.playItems(this.state.selection), 50);
    });
  },
});
