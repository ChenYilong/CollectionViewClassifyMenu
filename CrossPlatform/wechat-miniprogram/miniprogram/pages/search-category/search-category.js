// Pushed: the search page with its category tab bar, CYLSearchCategoryViewController. Placeholder of the 1:1 port of the iOS example (see docs/cross-platform.md, the Mini Program example).
const { t } = require('../../utils/i18n.js');

Page({
  data: { title: '' },
  onLoad() {
    const title = t('搜索');
    this.setData({ title });
    wx.setNavigationBarTitle({ title });
  },
  onShow() {
    if (typeof this.getTabBar === 'function' && this.getTabBar()) this.getTabBar().syncWithRoute(this.route);
  },
});
