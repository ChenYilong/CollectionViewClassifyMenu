/**
 * 评价 (pushed), 1:1 with the iOS example's CYLReviewListViewController: the mode control (内存筛选 / 网络筛选 /
 * 数据库筛选) in the navigation bar, the multiple-choice filter (全部 exclusive, folded to two rows behind a chevron
 * that turns when it expands), the status (last tap, selection, mode, count, request or SQL) and the reviews matching
 * every selected filter (AND), or 没有匹配的评价.
 *
 * Launch options: `filter=<index>` (CYLReviewListViewController(selectedFilterIndex:), 0 = 全部), `mode=memory |
 * network | database` (or 0 / 1 / 2), `select=1,4` (selectFilterIndexes, after loading) and `expanded=1`
 * (filterView.setExpanded(true…), the screen "reviews-expanded").
 */
const { t } = require('../../utils/i18n.js');
const store = require('./store.js');
const queries = require('./query.js');
const list = require('./list.js');

/** The navigation bar's height without a capsule (iOS's 44 pt). */
const NAV_BAR_HEIGHT = 44;

Page({
  data: {
    statusBarHeight: 20,
    navBarHeight: NAV_BAR_HEIGHT,
    navRight: 96,
    segments: [],
    modeIndex: 0,
    configuration: {},
    canFold: false,
    expanded: false,
    foldLabel: '',
    foldColor: list.FOLD_CONTROL_COLOR,
    status: '',
    loading: false,
    rows: [],
    empty: false,
    emptyText: '',
    backLabel: '',
  },

  onLoad(options = {}) {
    // A pushed screen, not a tab's root: its title can be set (the mode control is shown in its place).
    wx.setNavigationBarTitle({ title: t('评价(%lu)', store.reviews.length) });
    this.layoutNavigationBar();
    this.mode = queries.parseMode(options.mode);
    this.query = queries.queryFor(this.mode);
    // The filter is measured folded first (so the page knows whether it needs the chevron), then expanded when
    // `expanded=1` asks for it or the preselected chip is folded away.
    this.expanded = false;
    this.launchExpanded = options.expanded === '1' || options.expanded === 'true';
    this.foldMeasured = false;
    this.canFold = false;
    this.initialFilterIndex = list.initialIndex(options.filter);
    this.selection = [`0-${this.initialFilterIndex}`];
    this.selectedFilters = [];
    this.visibleReviews = [];
    this.lastEvent = t('点击「%@」', store.title(store.filters[this.initialFilterIndex]));
    this.setData({
      segments: [t('内存筛选'), t('网络筛选'), t('数据库筛选')],
      modeIndex: queries.modeIndex(this.mode),
      emptyText: t('没有匹配的评价'),
      backLabel: this.backLabel(),
      expanded: false,
      foldLabel: list.foldAccessibilityLabel(false),
    });
    this.applyConfiguration(false);
    this.refreshReviews();
    const indexes = list.parseIndexes(options.select);
    if (indexes.length) this.selectFilterIndexes(indexes);
  },

  onUnload() {
    // The iOS query goes away with its view controller ([weak self]): a pending response refreshes nothing.
    if (this.query && this.query.cancel) this.query.cancel();
  },

  /** The custom navigation bar (navigationStyle custom): status bar, then a bar as high as WeChat's capsule row. */
  layoutNavigationBar() {
    let statusBarHeight = 20;
    let windowWidth = 375;
    try {
      const info = wx.getWindowInfo ? wx.getWindowInfo() : wx.getSystemInfoSync();
      statusBarHeight = info.statusBarHeight || statusBarHeight;
      windowWidth = info.windowWidth || windowWidth;
    } catch (error) { /* defaults */ }
    let navBarHeight = NAV_BAR_HEIGHT;
    let navRight = 96;
    try {
      const capsule = wx.getMenuButtonBoundingClientRect();
      if (capsule && capsule.height) {
        navBarHeight = (capsule.top - statusBarHeight) * 2 + capsule.height;
        navRight = windowWidth - capsule.left + 8;
      }
    } catch (error) { /* defaults */ }
    this.setData({ statusBarHeight, navBarHeight, navRight });
  },

  /** The back button's label: the previous screen's title, as UIKit's back button. */
  backLabel() {
    const pages = getCurrentPages();
    const previous = pages.length > 1 ? pages[pages.length - 2].route : 'pages/product/product';
    return previous === 'pages/scenarios/scenarios' ? t('查询筛选') : t('宝贝详情');
  },

  goBack() {
    if (getCurrentPages().length > 1) wx.navigateBack();
    else wx.switchTab({ url: '/pages/product/product' });
  },

  // MARK: Fold

  /** Sets the filter's configuration with the current selection (cyl-tag-list rebuilds from it). */
  applyConfiguration(expanded) {
    this.setData({ configuration: list.filterConfiguration(this.selection, expanded) });
  },

  onContentHeightChange() {
    if (this.expanded) return;
    const component = this.selectComponent('#review-filter');
    const section = component && component.data.sections && component.data.sections[0];
    if (!section) return;
    // Read while folded (defaultVisibleRows 2): the component's measurement says whether it needs more rows.
    this.canFold = !!section.canFold;
    if (this.data.canFold !== this.canFold) this.setData({ canFold: this.canFold });
    if (!this.foldMeasured) {
      this.foldMeasured = true;
      const item = section.items[this.initialFilterIndex];
      // A preselected chip hidden by folding would be confusing, so show it.
      if (this.canFold && (this.launchExpanded || (item && item.hidden))) this.setExpanded(true);
    }
  },

  setExpanded(expanded) {
    this.expanded = expanded;
    this.setData({ expanded, foldLabel: list.foldAccessibilityLabel(expanded), canFold: this.canFold || expanded });
    this.applyConfiguration(expanded);
  },

  onFoldTap() {
    this.setExpanded(!this.expanded);
  },

  // MARK: Mode

  onModeTap(event) {
    const index = Number(event.currentTarget.dataset.index);
    if (index === this.data.modeIndex) return;
    this.setMode(queries.MODES[index]);
  },

  setMode(mode) {
    this.mode = mode;
    if (this.query && this.query.cancel) this.query.cancel();
    this.query = queries.queryFor(mode);
    this.setData({ modeIndex: queries.modeIndex(mode) });
    this.refreshReviews();
  },

  // MARK: Filtering

  /** Selects filters by index (as if tapped one after another) and refreshes the list. */
  selectFilterIndexes(indexes) {
    indexes.forEach((index) => {
      if (!Number.isInteger(index) || index < 0 || index >= store.filters.length) return;
      this.selection = list.selectItem(this.selection, index);
      this.lastEvent = t('点击「%@」', store.title(store.filters[index]));
    });
    this.applyConfiguration(this.expanded);
    this.refreshReviews();
  },

  onTagTap(event) {
    const { item, selected } = event.detail;
    const filter = store.filters[item];
    // A disabled tag (no matching review) does nothing on iOS (handleTap returns before the delegate).
    if (!filter || store.reviewsMatching(filter).length === 0) return;
    this.lastEvent = t(selected ? '点击「%@」' : '取消「%@」', store.title(filter));
  },

  /** Every tap that changes the selection refreshes the list once. */
  onSelectionChange(event) {
    this.selection = event.detail.keys.slice();
    if (!this.selection.length) {
      // Nothing selected means no condition: show "全部" as selected.
      this.selection = list.selectItem([], 0);
      this.applyConfiguration(this.expanded);
    }
    this.refreshReviews();
  },

  refreshReviews() {
    this.selectedFilters = list.selectedFilters(this.selection);
    const query = this.query;
    query.fetchReviewsMatching(this.selectedFilters, (reviews) => {
      if (query === this.query) this.show(reviews);
    });
    if (query.isLoading) {
      this.setData({ loading: true });
      this.updateStatus();
    }
  },

  show(reviews) {
    this.visibleReviews = reviews;
    this.setData({ loading: false, rows: reviews.map(list.reviewRow), empty: reviews.length === 0 });
    this.updateStatus();
  },

  updateStatus() {
    const lines = queries.statusLines({
      mode: this.mode,
      query: this.query,
      lastEvent: this.lastEvent,
      selectedFilters: this.selectedFilters,
      count: this.visibleReviews.length,
    });
    this.setData({ status: lines.join('\n') });
  },
});
