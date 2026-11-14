// The raised Post button's own page, as in the React Native and CYLTabBarController examples.
Page({
  onShow() {
    if (typeof this.getTabBar === 'function' && this.getTabBar()) this.getTabBar().syncWithRoute(this.route);
  },
});
