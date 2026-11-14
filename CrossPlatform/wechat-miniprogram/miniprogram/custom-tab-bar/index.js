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
    selectedIdentifier: 'tags',
  },

  methods: {
    onSelect(event) {
      const { pageIdentifier, identifier } = event.detail;
      wx.switchTab({ url: pagePath(pageIdentifier || identifier) });
    },

    /** Hides or shows the bar (CYLTabBarController's `cyl_setTabBarHidden`), e.g. under a sheet. */
    setHidden(hidden) {
      const tabBar = this.selectComponent('#cyl-tab-bar');
      if (tabBar) tabBar.cyl_setTabBarHidden(Boolean(hidden));
    },

    /** Selects the tab of the page shown (called from the pages' onShow). */
    syncWithRoute(route) {
      const identifier = identifierForRoute(route);
      if (identifier && identifier !== this.data.selectedIdentifier) this.setData({ selectedIdentifier: identifier });
    },
  },
});
