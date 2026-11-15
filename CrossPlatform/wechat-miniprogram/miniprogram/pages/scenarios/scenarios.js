/**
 * 查询筛选: the plus button's page, 1:1 with the iOS example's `CYLQueryScenariosViewController` (an inset grouped
 * table): the filter demos by scenario, then the database's tables with their row counts. A row opens its demo,
 * pushed without the tab bar.
 */
const { t } = require('../../utils/i18n.js');
const db = require('../../utils/places-db.js');
const reviews = require('../../data/reviews.js');
const selections = require('../../utils/selections.js');

/** The demos (CYLQueryScenario), their titles, SF Symbol stand-ins and pages. */
const SCENARIOS = {
  reviewsDatabase: { title: '评价筛选 · 数据库（SQLite）', image: 'cylinder', url: '/pages/reviews/reviews?mode=database' },
  reviewsMemory: { title: '评价筛选 · 内存', image: 'memorychip', url: '/pages/reviews/reviews?mode=memory' },
  reviewsNetwork: { title: '评价筛选 · 网络', image: 'network', url: '/pages/reviews/reviews?mode=network' },
  menuLinkage: { title: '分类菜单 + 多选筛选 · 数据库联动', image: 'grid3x2', url: '/pages/classify/classify' },
  searchDiscover: { title: '最近搜索 + 发现', image: 'magnifyingglass', url: '/pages/search-discover/search-discover' },
};

const SECTIONS = [
  {
    header: '场景：查询参数设置（多选）',
    footer: '淘宝评价默认显示全部；条件太多时，由用户多选输入筛选条件，标签列表就是为此而做。每次选择后按全部条件（AND）刷新列表。',
    scenarios: ['reviewsDatabase', 'reviewsMemory', 'reviewsNetwork'],
  },
  {
    header: '场景：菜单选择（移植原 Demo）',
    footer: '原 Demo 只实现了筛选界面，没有筛选数据；现在每次选择都会生成 SQL、查询数据库并显示结果，选择也保存在数据库中。',
    scenarios: ['menuLinkage'],
  },
  {
    header: '场景：搜索历史与发现',
    footer: '最近搜索折叠为两行，箭头是最后一个标签；发现每行两个，超出部分显示省略号，右上角的更多按钮随机刷新。数据来自本地 JSON。',
    scenarios: ['searchDiscover'],
  },
];

/** The rows of a table: reviews and places from the shared database, selections from the saved scenarios. */
function rowCount(table) {
  if (table === 'reviews') return reviews.length;
  if (table === 'places') return db.ROWS.length;
  return selections.savedScenarios().length;
}

Page({
  data: { sections: [], database: { header: '', footer: '', tables: [] } },

  onLoad() {
    wx.setNavigationBarTitle({ title: t('查询筛选') });
  },

  onShow() {
    if (typeof this.getTabBar === 'function' && this.getTabBar()) this.getTabBar().syncWithRoute(this.route);
    // The selections saved by the demos change the database section (viewWillAppear reloads the table).
    this.setData({
      sections: SECTIONS.map((section) => ({
        header: t(section.header),
        footer: t(section.footer),
        rows: section.scenarios.map((key) => ({
          key,
          title: t(SCENARIOS[key].title),
          image: `/images/symbols/${SCENARIOS[key].image}.png`,
        })),
      })),
      database: {
        header: t('数据库（SQLite）'),
        footer: t('每次启动时由 App 内的数据重新生成，selections 表保留各演示最后确认的条件。'),
        tables: ['reviews', 'places', 'selections'].map((table) => ({ table, count: t('%ld 行', rowCount(table)) })),
      },
    });
  },

  open(event) {
    wx.navigateTo({ url: SCENARIOS[event.currentTarget.dataset.key].url });
  },
});
