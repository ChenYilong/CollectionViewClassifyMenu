/**
 * Classify menu: the menu linkage screen of the iOS, Android and Flutter examples. A classify menu (one section per
 * category of the shared database, single choice) filters the places listed below it; the filter button opens a
 * sheet with the multiple filter (regions and dishes) and 确定; ↺ (重置筛选条件) clears both. Both selections are saved
 * (scenarios menu.classify and menu.filter) and restored at launch.
 */
const db = require('../../utils/places-db.js');
const selections = require('../../utils/selections.js');
const state = require('./filter.js');

Page({
  data: {
    configuration: {},
    configurationVersion: 0,
    filterConfiguration: {},
    filterVisible: false,
    summary: '',
    sql: '',
    places: [],
    filtered: false,
  },

  onShow() {
    // The custom tab bar (CYLTabBarController's cyl-tab-bar) selects the tab of this page.
    if (typeof this.getTabBar === 'function' && this.getTabBar()) this.getTabBar().syncWithRoute(this.route);
  },

  onLoad(options) {
    this.categories = db.categories();
    this.tags = db.tags();
    // `?select=0-1&filter=0-3,1-0` (a compile condition in WeChat DevTools) selects at launch, for screenshots.
    // WeChat DevTools passes the values URL-encoded ("0-3%2C1-0").
    const launchSelect = options && options.select && decodeURIComponent(options.select);
    const launchFilter = options && options.filter && decodeURIComponent(options.filter);
    this.classifyItems = launchSelect ? [launchSelect]
      : (selections.load(selections.CLASSIFY_SCENARIO) || []);
    const filter = launchFilter ? launchFilter.split(',') : selections.load(selections.FILTER_SCENARIO);
    this.filterItems = filter && filter.length ? filter : state.DEFAULT_FILTER.slice();
    this.pendingFilter = this.filterItems;
    this.setData({ configuration: state.classifyConfiguration(this.categories, this.classifyItems) });
    this.runQuery();
  },

  runQuery() {
    const result = state.query(this.classifyItems, this.filterItems, this.categories, this.tags);
    this.setData({
      summary: result.summary,
      sql: result.sql,
      places: result.places.map((p) => ({ ...p, ratingText: p.rating.toFixed(1) })),
      filtered: result.filtered,
    });
  },

  onTagTap(event) {
    const { section, item } = event.detail;
    this.classifyItems = state.toggleClassify(this.classifyItems, section, item);
    selections.save(selections.CLASSIFY_SCENARIO, this.classifyItems);
    // Single choice across every category: the page owns the selection, so the list shows exactly this one.
    this.setData({ configuration: state.classifyConfiguration(this.categories, this.classifyItems) });
    this.runQuery();
  },

  openFilter() {
    this.pendingFilter = this.filterItems;
    this.setData({
      filterVisible: true,
      filterConfiguration: state.filterConfiguration(this.tags, this.filterItems),
    });
    this.setTabBarHidden(true);
  },

  closeFilter() {
    this.setData({ filterVisible: false });
    this.setTabBarHidden(false);
  },

  /** The sheet covers the tab bar's area, so the bar hides while it is open (its 确定 stays reachable). */
  setTabBarHidden(hidden) {
    if (typeof this.getTabBar === 'function' && this.getTabBar()) this.getTabBar().setHidden(hidden);
  },

  onFilterChange(event) {
    this.pendingFilter = event.detail.keys;
  },

  /** 确定: applies the sheet's selection (the iOS example's `confirmFilterSelection(_:)`). */
  confirmFilter() {
    this.filterItems = this.pendingFilter;
    selections.save(selections.FILTER_SCENARIO, this.filterItems);
    this.setData({ filterVisible: false });
    this.setTabBarHidden(false);
    this.runQuery();
  },

  /** 重置筛选条件: every tag, region and dish. */
  resetConditions() {
    this.classifyItems = [];
    this.filterItems = state.DEFAULT_FILTER.slice();
    selections.save(selections.CLASSIFY_SCENARIO, this.classifyItems);
    selections.save(selections.FILTER_SCENARIO, this.filterItems);
    this.setData({ configuration: state.classifyConfiguration(this.categories, this.classifyItems) });
    this.runQuery();
  },

  noop() {},
});
