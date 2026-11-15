/**
 * The search page of scenario 2 (pushed from 脉脉搜索 without the root tab bar), 1:1 with the iOS example's
 * CYLSearchCategoryViewController: the search bar in the navigation bar (its placeholder follows the category), the
 * category tab bar at the bottom (CYLTabBarController's cyl-tab-bar: 找人, 动态, 八卦, 职位), one page of Maimai tags
 * per category; a tapped tag fills the search bar (selection mode none). The 职位 page has the job category sidebar
 * (90 pt, 50 pt rows) and, at the trailing edge of its header, the industry button with its menu.
 *
 * Launch query (for screenshots): category=people|feeds|gossip|jobs (or 0-3), job=<sidebar row>, industry=<name>.
 */
const { t } = require('../../utils/i18n.js');
const model = require('./search-category-model.js');

Page({
  data: {
    nav: { statusBar: 20, height: 44, rightInset: 96 },
    backLabel: '',
    searchText: '',
    placeholder: '',
    category: 0,
    selectedIdentifier: 'people',
    tabBarConfiguration: {},
    header: model.MAIMAI_HEADER,
    pages: [],
    jobCategories: [],
    jobCategoryIndex: 0,
    jobSection: null,
    industry: model.INDUSTRIES[0],
    industryButton: {},
  },

  onLoad(query = {}) {
    this.layoutNavigationBar();
    // The pages of 找人, 动态 and 八卦; the 职位 page is built from the sidebar's row.
    const pages = [0, 1, 2].map((category) => ({
      index: category,
      sections: model.sections(category).map((section) => ({
        title: section.title,
        configuration: model.tagListConfiguration(section),
      })),
    }));
    const industry = model.INDUSTRIES.includes(query.industry) ? query.industry : model.INDUSTRIES[0];
    this.setData({
      backLabel: t('返回'),
      tabBarConfiguration: model.tabBarConfiguration(),
      pages,
      jobCategories: model.JOB_CATEGORIES.map((name) => t(name)),
      industry,
      industryButton: model.industryButton(industry),
    });
    this.selectJobCategory(query.job != null ? query.job : 0);
    this.select(query.category != null ? query.category : 0);
  },

  /** A bar like UINavigationBar under the status bar, its trailing edge left of WeChat's capsule menu. */
  layoutNavigationBar() {
    try {
      const info = wx.getWindowInfo ? wx.getWindowInfo() : wx.getSystemInfoSync();
      const capsule = wx.getMenuButtonBoundingClientRect();
      const statusBar = info.statusBarHeight || 20;
      const height = capsule && capsule.height ? (capsule.top - statusBar) * 2 + capsule.height : 44;
      const rightInset = capsule && capsule.left ? info.windowWidth - capsule.left + 8 : 96;
      this.setData({ nav: { statusBar, height, rightInset } });
    } catch (error) {
      // Defaults above.
    }
  },

  // MARK: Category

  /** select(_:): the tab bar's selection, then categoryDidChange(_:). */
  select(category) {
    this.categoryDidChange(model.categoryIndex(category));
  },

  /** The tab bar's `select` event (UITabBarControllerDelegate didSelect). */
  onCategorySelect(event) {
    this.categoryDidChange(model.categoryIndex(event.detail.identifier));
  },

  categoryDidChange(index) {
    this.setData({
      category: index,
      selectedIdentifier: model.CATEGORIES[index],
      placeholder: model.placeholder(index),
    });
    if (index === 3) this.selectJobCategory(this.data.jobCategoryIndex);
  },

  /** selectJobCategory(at:): the sidebar row and the 职位 tags (reloadTags(for: .jobs)). */
  selectJobCategory(index) {
    const row = model.clampJobCategory(index);
    const section = model.jobSection(row);
    this.setData({
      jobCategoryIndex: row,
      jobSection: { title: section.title, configuration: model.tagListConfiguration(section) },
    });
  },

  onJobCategoryTap(event) {
    this.selectJobCategory(Number(event.currentTarget.dataset.index));
  },

  // MARK: Industry

  /** The industry button's menu (UIMenu "行业", a check mark on the current industry). */
  showIndustryMenu() {
    const button = this.data.industryButton;
    wx.showActionSheet({
      alertText: button.menuTitle,
      itemList: button.actions.map((action) => (action.on ? `✓ ${action.title}` : action.title)),
      success: (result) => {
        const action = button.actions[result.tapIndex];
        if (action) this.selectIndustry(action.industry);
      },
      fail: () => {},
    });
  },

  selectIndustry(industry) {
    this.setData({ industry, industryButton: model.industryButton(industry) });
  },

  // MARK: Tags and search bar

  /** CYLMenuDelegate didSelectItemAt: the tapped tag's title fills the search bar. */
  onTagTap(event) {
    this.setData({ searchText: event.detail.title });
  },

  onSearchInput(event) {
    this.setData({ searchText: event.detail.value });
  },

  /** searchBarViewSearchButtonClicked: the keyboard goes away. */
  onSearchConfirm() {
    wx.hideKeyboard({ fail: () => {} });
  },

  goBack() {
    wx.navigateBack({ fail: () => wx.switchTab({ url: '/pages/search-home/search-home' }) });
  },
});
