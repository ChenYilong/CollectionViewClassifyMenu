/**
 * 最近搜索 + 发现 (pushed from 查询筛选), 1:1 with the iOS example's CYLSearchDiscoverViewController: a search app's
 * search page whose search bar replaces the navigation bar (back, the field whose placeholder is the first discover
 * topic, the camera and 搜索 inside it); "最近搜索" folded to two rows with the chevron as the last tag (it expands and
 * collapses the list), the trash in its header clears it; "发现" two plain titles per row, long titles truncated, the
 * hot icon after a hot title, the More button at the header's trailing edge refreshing the topics at random; at the
 * bottom the hint and the hold-to-ask mic button on a light curved area. The data comes from the iOS bundle's
 * search-discover.json (data/search/search-discover.js); this page only shows it and handles the taps.
 *
 * Launch query (for screenshots and checks): seed=<integer> picks the refreshed topics with
 * CYLSeededRandomNumberGenerator (a fixed order), expanded=1 shows every recent search.
 */
const { t, language } = require('../../utils/i18n.js');
const model = require('./discover-model.js');

const HOLD_DURATION = 200; // UILongPressGestureRecognizer.minimumPressDuration = 0.2

Page({
  data: {
    top: { statusBar: 20, rightInset: 96 },
    labels: {},
    fieldText: '',
    placeholder: '',
    searches: [],
    recentExpanded: false,
    recentRows: [],
    foldTitle: '',
    contentWidth: 343,
    topics: [],
    discoverRows: [],
    gridItemWidth: 159,
    hot: {},
    hint: '',
    hintLabel: '',
  },

  onLoad(query = {}) {
    this.layoutTopBar();
    /** Picks the refreshed topics; a seeded generator for a fixed order (randomGenerator in the Swift code). */
    this.randomGenerator = query.seed != null && query.seed !== ''
      ? new model.SeededRandomNumberGenerator(Number(query.seed))
      : new model.SystemRandomNumberGenerator();
    this.discoverData = model.bundled(language());
    this.setData({
      labels: {
        back: t('返回'),
        search: t('搜索'),
        camera: t('以图搜索'),
        recentTitle: t('最近搜索'),
        clear: t('清空最近搜索'),
        discoverTitle: t('发现'),
        refresh: t('换一批'),
        hotValue: t('热门'),
        tagHint: t('轻点两下搜索'),
        mic: t('按住提问'),
        micHint: t('按住说出问题，松开发送'),
      },
      searches: this.discoverData.recentSearches,
      topics: model.initialTopics(this.discoverData),
      recentExpanded: query.expanded === '1',
      hot: model.hotIcon(language()),
    });
    this.showHint(t('按住提问，有问必答'));
    this.reloadLists();
  },

  onUnload() {
    clearTimeout(this.holdTimer);
  },

  /** The search bar under the status bar (safe area top + 8), its trailing edge left of WeChat's capsule menu. */
  layoutTopBar() {
    try {
      const info = wx.getWindowInfo ? wx.getWindowInfo() : wx.getSystemInfoSync();
      const capsule = wx.getMenuButtonBoundingClientRect();
      const statusBar = info.statusBarHeight || 20;
      const rightInset = capsule && capsule.left ? info.windowWidth - capsule.left + 8 : 96;
      const contentWidth = info.windowWidth - model.RECENT_STYLE.sectionInsets.left - model.RECENT_STYLE.sectionInsets.right;
      this.setData({
        top: { statusBar, rightInset },
        contentWidth,
        gridItemWidth: model.gridItemWidth(info.windowWidth - model.DISCOVER_STYLE.sectionInsets.left - model.DISCOVER_STYLE.sectionInsets.right),
      });
    } catch (error) {
      // Defaults above.
    }
  },

  // MARK: Data

  /** reloadLists(): the placeholder is the first discover topic; both lists show the current data. */
  reloadLists() {
    const topics = this.data.topics;
    this.setData({
      placeholder: model.placeholder(topics),
      discoverRows: model.gridRows(topics).map((cells, r) => ({ key: `row-${r}`, cells })),
      foldTitle: model.foldTitle(this.data.recentExpanded, language()),
    }, () => this.measureRecent());
  },

  /** Measures every recent search's tag (title + margins) and lays the rows out as the core does. */
  measureRecent() {
    if (!this.data.searches.length) {
      this.setData({ recentRows: [] });
      return;
    }
    wx.createSelectorQuery().in(this).selectAll('.recent-measure-tag').boundingClientRect().exec(([rects]) => {
      this.recentWidths = (rects || []).map((rect) => Math.ceil(rect.width));
      this.layOutRecent();
    });
  },

  layOutRecent() {
    const searches = this.data.searches;
    if (!this.recentWidths || this.recentWidths.length !== searches.length) return;
    const layout = model.recentLayout(this.recentWidths, {
      contentWidth: this.data.contentWidth,
      expanded: this.data.recentExpanded,
    });
    this.setData({
      recentRows: layout.rows.map((row, r) => ({
        key: `row-${r}`,
        cells: row.map((cell) => (cell.fold
          ? { key: 'fold', fold: true }
          : { key: searches[cell.item], item: cell.item, title: searches[cell.item] })),
      })),
      foldTitle: model.foldTitle(layout.expanded, language()),
    });
  },

  /** The inline fold cell expands or collapses the recent searches. */
  toggleRecent() {
    this.setData({ recentExpanded: !this.data.recentExpanded }, () => this.layOutRecent());
  },

  /** refreshDiscover(), the More button's action: another random selection of topics. */
  refreshDiscover() {
    this.setData({ topics: model.randomTopics(this.discoverData, this.data.topics, this.randomGenerator) });
    this.reloadLists();
  },

  /** search(for:): shows the query in the field and moves it to the front of the recent searches. */
  search(text) {
    const result = model.search(this.data.searches, text);
    if (!result) return;
    this.setData({ fieldText: result.query, searches: result.searches });
    this.reloadLists();
  },

  /** The 搜索 button and the keyboard's search key: the typed text, else the placeholder topic. */
  searchTapped() {
    this.search(model.searchText(this.data.fieldText, this.data.placeholder));
  },

  onSearchConfirm() {
    this.searchTapped();
    wx.hideKeyboard({ fail: () => {} });
  },

  onFieldInput(event) {
    this.setData({ fieldText: event.detail.value });
  },

  clearRecentSearches() {
    this.setData({ searches: [] });
    this.reloadLists();
  },

  /** A recent search or a discover topic is searched again (CYLMenuDelegate didSelectItemAt). */
  onRecentTap(event) {
    this.search(this.data.searches[Number(event.currentTarget.dataset.item)]);
  },

  onTopicTap(event) {
    const topic = this.data.topics[Number(event.currentTarget.dataset.index)];
    if (topic) this.search(topic.title);
  },

  /** The camera button: not part of this demo, which says so instead of ignoring the tap. */
  searchByImage() {
    wx.showModal({
      title: t('以图搜索'),
      content: t('演示中暂不支持以图搜索。'),
      showCancel: false,
      confirmText: t('好'),
    });
  },

  goBack() {
    wx.navigateBack({ fail: () => wx.switchTab({ url: '/pages/scenarios/scenarios' }) });
  },

  // MARK: Ask

  /** The hint above the mic button; the sparkles are decoration, so a screen reader reads the text only. */
  showHint(text) {
    this.setData({ hint: `${text} ✨`, hintLabel: text });
  },

  /** holdToAsk(_:): held for 0.2 s, it listens until released. */
  onMicTouchStart() {
    clearTimeout(this.holdTimer);
    this.holdTimer = setTimeout(() => {
      this.listening = true;
      this.showHint(t('正在聆听…'));
    }, HOLD_DURATION);
  },

  onMicTouchEnd() {
    clearTimeout(this.holdTimer);
    if (!this.listening) return;
    this.listening = false;
    this.showHint(t('按住提问，有问必答'));
  },
});
