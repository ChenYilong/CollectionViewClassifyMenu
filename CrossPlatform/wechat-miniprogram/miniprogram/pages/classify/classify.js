/**
 * 分类菜单 + 多选筛选 · 数据库联动 (pushed from 查询筛选), 1:1 with the iOS example's `CYLMenuLinkageViewController`
 * (a CYLClassifyMenuViewController): the header hint, the classify menu (single choice, two rows per section, 更多 /
 * 收起), the footer with the conditions, the SQL, the count and the rows; the left bar button opens the multiple
 * filter (CYLMultipleFilterController, a panel from the left with 返回默认 / 确认筛选), 重置 clears every condition.
 * Both selections are saved (scenarios menu.classify, menu.filter) and restored on the next visit.
 */
const { t, tc } = require('../../utils/i18n.js');
const selections = require('../../utils/selections.js');
const state = require('./menu-linkage.js');
const { rowsFromTops } = require('../../components/cyl-tag-list/model.js');

const VISIBLE_ROWS = 2; // defaultVisibleRows

Page({
  data: {
    nav: { statusBar: 20, height: 44, sideInset: 8, rightInset: 96 },
    title: '',
    resetTitle: '',
    hint: [],
    filterLabel: '',
    filterValue: '',
    filterModified: false,
    sections: [],
    status: '',
    rows: [],
    empty: null,
    panelVisible: false,
    panelShown: false,
    panelSections: [],
    resetPanel: '',
    confirmPanel: '',
  },

  onLoad(options) {
    this.layoutNavigationBar();
    this.expanded = {};
    this.rowsBySection = null;
    // `?select=0-1&filter=0-2,0-4,1-2,1-3` selects at launch, like iOS's `-CYLExampleScreen plus-menu-filtered`.
    const decode = (value) => (value ? decodeURIComponent(value) : '');
    const launchSelect = decode(options && options.select);
    const launchFilter = decode(options && options.filter);
    this.setData({
      title: t('菜单选择 · 数据库联动'),
      resetTitle: t('重置'),
      hint: [t('点按分类标签（单选），左上角按钮多选地区与菜品'), t('每次选择 → 生成 SQL → SQLite 查询 → 刷新下方结果')],
      filterLabel: t('多选筛选'),
      resetPanel: tc('CYLFilterReset'),
      confirmPanel: tc('CYLFilterConfirm'),
    });
    this.restoreSavedSelection(launchSelect, launchFilter);
    this.runQuery();
  },

  /** A bar like UINavigationBar under the status bar, its trailing item left of WeChat's capsule menu. */
  layoutNavigationBar() {
    try {
      const info = wx.getWindowInfo ? wx.getWindowInfo() : wx.getSystemInfoSync();
      const capsule = wx.getMenuButtonBoundingClientRect();
      const statusBar = info.statusBarHeight || 20;
      const height = capsule && capsule.height ? (capsule.top - statusBar) * 2 + capsule.height : 44;
      const rightInset = capsule && capsule.left ? info.windowWidth - capsule.left + 8 : 96;
      this.setData({ nav: { statusBar, height, sideInset: 8, rightInset } });
    } catch (error) {
      // Defaults above.
    }
  },

  /** The selections saved by the last visit, if they still fit the menus (restoreSavedSelection()). */
  restoreSavedSelection(launchSelect, launchFilter) {
    const classify = launchSelect ? [launchSelect] : (selections.load(selections.CLASSIFY_SCENARIO) || []);
    this.selected = classify[0] && state.contains(classify[0], state.CLASSIFY) ? classify[0] : null;
    let filter = launchFilter ? launchFilter.split(',') : (selections.load(selections.FILTER_SCENARIO) || []);
    filter = filter.filter((key) => state.contains(key, state.FILTER));
    if (!filter.length || !state.isValidFilterSelection(filter)) filter = state.DEFAULT_FILTER.slice();
    this.filterSelection = state.selectionOf(filter);
    this.applyFilterSelection(state.keysOf(this.filterSelection), Boolean(launchFilter));
  },

  applyFilterSelection(keys, save) {
    const { regions, dishes } = state.conditionsOf(keys);
    this.regions = regions;
    this.dishes = dishes;
    if (save) selections.save(selections.FILTER_SCENARIO, keys);
  },

  runQuery() {
    const tag = state.classifyTitle(this.selected);
    const result = state.results(t, tag, this.regions, this.dishes);
    const modified = this.regions.length > 0 || this.dishes.length > 0;
    this.setData({
      status: result.status,
      rows: result.rows,
      empty: result.empty,
      filterModified: modified,
      filterValue: modified ? t('已修改') : '',
    });
    this.renderMenu(!this.rowsBySection);
  },

  /** The classify sections; with `measure`, every tag is shown once to find the rows (as cellsInPerRow does). */
  renderMenu(measure) {
    const sections = state.CLASSIFY.map((section, s) => {
      const rows = this.rowsBySection && this.rowsBySection[s];
      const rowCount = rows && rows.length ? rows[rows.length - 1] + 1 : 0;
      const canFold = !measure && rowCount > VISIBLE_ROWS;
      const expanded = Boolean(this.expanded[s]);
      return {
        index: s,
        title: section.title,
        canFold,
        expanded,
        moreTitle: tc(expanded ? 'CYLMenuCollapse' : 'CYLMenuExpand'),
        items: section.items.map((item, i) => ({
          key: `${s}-${i}`,
          title: item.title,
          picture: item.picture,
          selected: this.selected === `${s}-${i}`,
          hidden: canFold && !expanded && rows[i] >= VISIBLE_ROWS,
        })),
      };
    });
    this.setData({ sections }, () => {
      if (!measure) return;
      const query = this.createSelectorQuery();
      sections.forEach((section) => query.selectAll(`.cell-s${section.index}`).boundingClientRect());
      query.exec((results) => {
        this.rowsBySection = results.map((rects) => rowsFromTops((rects || []).map((rect) => rect.top)));
        this.renderMenu(false);
      });
    });
  },

  onResize() {
    this.rowsBySection = null;
    this.renderMenu(true);
  },

  onCellTap(event) {
    this.selected = state.toggleClassify(this.selected, event.currentTarget.dataset.key);
    selections.save(selections.CLASSIFY_SCENARIO, this.selected ? [this.selected] : []);
    this.runQuery();
  },

  onMoreTap(event) {
    const section = Number(event.currentTarget.dataset.section);
    this.expanded[section] = !this.expanded[section];
    this.renderMenu(false);
  },

  /** 重置: every tag, every region and dish (resetConditions()). */
  resetConditions() {
    this.selected = null;
    selections.save(selections.CLASSIFY_SCENARIO, []);
    this.filterSelection = state.selectionOf(state.DEFAULT_FILTER);
    this.applyFilterSelection(state.DEFAULT_FILTER, true);
    this.runQuery();
  },

  // The multiple filter panel.

  renderPanel() {
    this.setData({
      panelSections: state.FILTER.map((section, s) => ({
        index: s,
        title: section.title,
        items: section.items.map((title, i) => ({ key: `${s}-${i}`, title, selected: this.filterSelection[s][i] })),
      })),
    });
  },

  showFilter() {
    this.renderPanel();
    this.setData({ panelVisible: true }, () => {
      setTimeout(() => this.setData({ panelShown: true }), 20);
    });
  },

  hidePanel() {
    this.setData({ panelShown: false });
    setTimeout(() => this.setData({ panelVisible: false }), 300);
  },

  onPanelTap(event) {
    const { section, item } = event.currentTarget.dataset;
    this.filterSelection = state.tapFilter(this.filterSelection, Number(section), Number(item));
    this.renderPanel();
  },

  /** 确认筛选 (didConfirmSelectedItems). */
  confirmFilter() {
    const keys = state.keysOf(this.filterSelection);
    this.applyFilterSelection(keys, true);
    this.hidePanel();
    this.runQuery();
  },

  /** 返回默认: 全部 in every section, then confirm (restoreButtonClicked). */
  resetFilter() {
    this.filterSelection = state.selectionOf(state.DEFAULT_FILTER);
    this.renderPanel();
    this.confirmFilter();
  },

  noop() {},
});
