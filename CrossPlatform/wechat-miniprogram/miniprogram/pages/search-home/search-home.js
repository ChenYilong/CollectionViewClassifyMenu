/**
 * 场景二：搜索分类 (tab): the search home, 1:1 with the iOS example's CYLSearchHomeViewController: the title 脉脉搜索,
 * a gray capsule search button (magnifier, 搜人名,职位,公司...) and the footnote hint below it; the button pushes the
 * search page (pages/search-category) without the root tab bar.
 */
const { t } = require('../../utils/i18n.js');

Page({
  data: { searchTitle: '', hint: '' },

  onLoad() {
    // navigationItem.title, not the tab's title.
    wx.setNavigationBarTitle({ title: t('脉脉搜索') });
    this.setData({
      searchTitle: t('搜人名,职位,公司...'),
      hint: t('按分类浏览热门标签：找人、动态、八卦、职位'),
    });
  },

  onShow() {
    if (typeof this.getTabBar === 'function' && this.getTabBar()) this.getTabBar().syncWithRoute(this.route);
  },

  /** openSearch(): pushes the search page (hidesBottomBarWhenPushed: a pushed page has no tab bar). */
  openSearch() {
    wx.navigateTo({ url: '/pages/search-category/search-category' });
  },
});
