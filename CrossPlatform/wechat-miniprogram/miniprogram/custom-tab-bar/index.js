/**
 * The example's custom tab bar (app.json "tabBar": {"custom": true}): CYLTabBarController's `cyl-tab-bar` component
 * (installed by scripts/fetch-cyltabbar.js), as the iOS, Flutter and React Native examples use CYLTabBarController as
 * their shell. It switches pages on `select` (the plus button has a page, so it sends `select` too); each tab page
 * calls `syncWithRoute` in onShow so the selection follows the page.
 */
const { CONFIGURATION, pagePath, identifierForRoute } = require('./configuration.js');

Component({
  data: {
    configuration: CONFIGURATION,
    selectedIdentifier: 'product',
  },

  methods: {
    onSelect(event) {
      const { pageIdentifier, identifier } = event.detail;
      const fromRoute = this.currentRoute();
      wx.switchTab({
        url: pagePath(pageIdentifier || identifier),
        // A switch that does not happen (a double tap, a page still loading) must not leave the tapped tab selected.
        fail: () => this.syncWithRoute(fromRoute),
      });
    },

    currentRoute() {
      const pages = getCurrentPages();
      return pages.length ? pages[pages.length - 1].route : '';
    },

    /** Hides or shows the bar (CYLTabBarController's `cyl_setTabBarHidden`), e.g. under a sheet. */
    setHidden(hidden) {
      const tabBar = this.selectComponent('#cyl-tab-bar');
      if (tabBar) tabBar.cyl_setTabBarHidden(Boolean(hidden));
    },

    /** Selects the tab of the page shown (called from the pages' onShow). */
    syncWithRoute(route) {
      const identifier = identifierForRoute(route);
      if (!identifier) return;
      // Every tab page has its own tab bar instance, and a tap selects inside cyl-tab-bar without changing this
      // component's data: comparing with `selectedIdentifier` here skipped the update when coming back to a page
      // whose bar had been tapped (the page changed, its tab did not). So the bar is always told which tab to show.
      if (identifier !== this.data.selectedIdentifier) this.setData({ selectedIdentifier: identifier });
      const tabBar = this.selectComponent('#cyl-tab-bar');
      if (tabBar && typeof tabBar.cyl_selectIdentifier === 'function') tabBar.cyl_selectIdentifier(identifier);
    },
  },
});
