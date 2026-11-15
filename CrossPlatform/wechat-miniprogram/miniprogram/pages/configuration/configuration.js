// Pushed: the configuration file demo, CYLTagConfigurationDemoViewController. Placeholder of the 1:1 port of the iOS example (see docs/cross-platform.md, the Mini Program example).
const { t } = require('../../utils/i18n.js');

Page({
  data: { title: '' },
  onLoad() {
    const title = t('配置文件');
    this.setData({ title });
    wx.setNavigationBarTitle({ title });
  },
  onShow() {
    if (typeof this.getTabBar === 'function' && this.getTabBar()) this.getTabBar().syncWithRoute(this.route);
  },
});
