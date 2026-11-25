/**
 * The data and rules of the search page (scenario 2), 1:1 with the iOS example's CYLSearchCategoryViewController,
 * without `wx` calls (node --test): the four categories of the category tab bar (找人, 动态, 八卦, 职位) with their
 * tags, the search bar's placeholder per category, the job categories of the 职位 sidebar with their keywords, the
 * industries of the header button, the Maimai look (`maimaiStyle()`), and the category tab bar's configuration in
 * CYLTabBarController's keys.
 */
const { t } = require('../../utils/i18n.js');

/** The Maimai tag lists sit on the page itself (the page draws their headers), not in a card: the list's `plain` section style. */
const PLAIN_SECTION_STYLE = 'plain';

/** CYLSearchCategory: people = 0, feeds, gossip, jobs. */
const CATEGORIES = ['people', 'feeds', 'gossip', 'jobs'];

/** The category tabs: titles (localized) and the SF Symbols they stand in for (person.2, …, their .fill when selected). */
const TAB_TITLES = ['找人', '动态', '八卦', '职位'];
const TAB_IMAGES = ['tab-people', 'tab-feeds', 'tab-gossip', 'tab-jobs'];

const JOB_CATEGORIES = ['开发', '测试', '运维/DBA', '硬件', '产品', '运营', '设计', '编辑/记者', '游戏', '市场BD'];

const INDUSTRIES = ['IT互联网', '金融', '教育培训', '医疗健康', '房地产'];

const JOB_KEYWORDS = {
  '开发': ['后端开发', 'PHP', 'Java', 'Python', '.NET', 'C#', 'C/C++', 'Ruby', 'Hadoop', 'Node.js',
    'Perl', '搜索算法', '推荐算法', '数据挖掘', '机器学习', '信息检索', 'NLP', '语音算法',
    '视频算法', '图像算法', '全栈', 'Linux', '广告算法', 'GO', 'ASP', 'Shell', 'VB',
    'Delphi', '前端开发', 'Web前端', 'Flash'],
  '测试': ['测试工程师', '自动化测试', '性能测试', '测试开发', '白盒测试', '游戏测试', '手机测试'],
  '运维/DBA': ['运维工程师', 'DBA', '系统管理员', '网络工程师', 'IT支持', 'SRE'],
  '硬件': ['嵌入式', '单片机', '电路设计', 'FPGA', '驱动开发', '射频工程师'],
  '产品': ['产品经理', '产品助理', '产品总监', '数据产品', '游戏策划', '移动产品'],
  '运营': ['内容运营', '用户运营', '活动运营', '新媒体', '社区运营', '数据运营', 'SEO'],
  '设计': ['UI设计', '交互设计', '视觉设计', '平面设计', '用户研究', '动效设计'],
  '编辑/记者': ['编辑', '记者', '文案', '主编', '撰稿人'],
  '游戏': ['游戏开发', '游戏策划', '游戏美术', 'Unity3D', 'Cocos2d-x'],
  '市场BD': ['市场推广', '商务拓展', '品牌', '公关', '渠道', '大客户'],
};

/** The placeholder keys per category (placeholder(for:)). */
const PLACEHOLDERS = ['搜人名,职位,公司...', '搜动态', '搜八卦', '搜职位'];

/** The category index of a name or index ("gossip" or 2 -> 2), clamped to the four categories. */
function categoryIndex(value) {
  const byName = CATEGORIES.indexOf(value);
  if (byName >= 0) return byName;
  const n = Number(value);
  return Number.isInteger(n) && n >= 0 && n < CATEGORIES.length ? n : 0;
}

function placeholder(category) {
  return t(PLACEHOLDERS[categoryIndex(category)]);
}

/**
 * The sections of a category (sections(for:)): titles localized, tags as they are (the iOS example does not
 * translate them). The 职位 tab's one section comes from jobSection().
 * @returns {{title: string, titles: string[]}[]}
 */
function sections(category) {
  switch (CATEGORIES[categoryIndex(category)]) {
    case 'people':
      return [
        { title: t('认识同行'), titles: ['百度研发', '腾讯工程师', '搜狗开发', '腾讯开发', '搜狗研究员'] },
        { title: t('找投资'), titles: ['创投', 'IDG资本', '晨兴资本', '合伙人', '投资经理'] },
        { title: t('谈合作'), titles: ['CEO', '副总裁', 'VP', '总经理', '总监'] },
        { title: t('挖人才'), titles: ['Java', 'Android', 'JS', 'C++', 'HTML/CSS', 'iOS', 'PHP', '前端'] },
      ];
    case 'feeds':
      return [{ title: t('热门动态关键词'),
        titles: ['投资', '创业', 'o2o', '社交', '招聘', '运营', '线下聚会', '脉脉', '融资', '在线教育', '硬件', '电商', '产品经理'] }];
    case 'gossip':
      return [
        { title: t('热门词'),
          titles: ['百度', '新浪', '程序猿', '离职', '阿里', '360', '创业', '工资', '跳槽', '小三', '裁员', '加班', '女同事', '产品经理', '投资人', '老板'] },
        { title: t('我关注的标签'), titles: ['社交', '移动', '程序猿'] },
      ];
    default:
      return [];
  }
}

/** selectJobCategory(at:) clamps the row. */
function clampJobCategory(index) {
  const n = Math.trunc(Number(index)) || 0;
  return Math.min(Math.max(n, 0), JOB_CATEGORIES.length - 1);
}

/** The 职位 tab's section: 热搜职位关键词: and the keywords of the selected job category. */
function jobSection(jobCategoryIndex) {
  const name = JOB_CATEGORIES[clampJobCategory(jobCategoryIndex)];
  return { title: t('热搜职位关键词:'), titles: JOB_KEYWORDS[name] || [] };
}

/** The industry button (updateIndustryButton()): its title, its VoiceOver label and hint, and its menu. */
function industryButton(industry) {
  const name = t(industry);
  return {
    title: t('行业: %@ ▾', name),
    // Without the "▾" glyph, which a screen reader would read aloud.
    accessibilityLabel: t('行业 %@', name),
    accessibilityHint: t('选择行业'),
    menuTitle: t('行业'),
    actions: INDUSTRIES.map((value) => ({ industry: value, title: t(value), on: value === industry })),
  };
}

/**
 * maimaiStyle() in the keys of CYLTagListView(configuration:): 14 pt titles in white 0.35, a 1 pt white 0.8 border
 * with 2 pt corners, 14 pt margins, 32 pt tags, 14 pt spacing, section insets {4, 24, 14, 16}, 32 pt headers in
 * 13 pt white 0.6 (the headers are drawn by the page: see the page's notes).
 */
function maimaiStyle() {
  const look = { cornerRadius: 2, borderColor: '#CCCCCC', borderWidth: 1, textColor: '#595959', backgroundColor: '#F2F2F7' };
  return {
    sectionStyle: PLAIN_SECTION_STYLE,
    backgroundStyle: 'liquidGlass',
    font: 14,
    itemHeight: 32,
    interitemSpacing: 14,
    lineSpacing: 14,
    sectionInsets: { top: 4, left: 24, bottom: 14, right: 16 },
    tagContentInsets: { top: 5, left: 14, bottom: 5, right: 14 },
    headerHeight: 32,
    headerFont: 13,
    normal: look,
    // selectionMode none: never selected; the same look.
    selected: look,
  };
}

/** The header of a section, as CYLMenuStyle draws it for maimaiStyle(): headerHeight, headerFont, headerTextColor. */
const MAIMAI_HEADER = { height: 32, fontSize: 13, color: '#999999', horizontalInset: 16 };

/**
 * The configuration of one cyl-tag-list for one section (makeTagListView(): maimaiStyle, selectionMode none). The
 * section title is left out: the page draws the header (the component has no header text color or accessory view).
 */
function tagListConfiguration(section) {
  return {
    selectionMode: 'none',
    style: maimaiStyle(),
    sections: [{ title: '', items: section.titles.map((title) => ({ title })) }],
  };
}

/**
 * The category tab bar (CYLTabBarController(viewControllers:tabBarItemsAttributes:)) in CYLTabBarController's keys,
 * images relative to /images, UIKit's tab colors.
 */
function tabBarConfiguration() {
  return {
    CYLTabBarControllerContext: 'CYLSearchCategory',
    CYLTabBarControllerThemeIdentifier: 'light',
    CYLTabBarControllerThemes: {
      light: { CYLTabBarItemSelectedTitleColor: '#007AFF', CYLTabBarItemTitleColor: '#8E8E93' },
    },
    CYLTabBarControllerTabBarItemsAttributes: TAB_TITLES.map((title, index) => ({
      CYLTabBarItemTitle: t(title),
      CYLTabBarItemImage: `search/${TAB_IMAGES[index]}.svg`,
      CYLTabBarItemSelectedImage: `search/${TAB_IMAGES[index]}-fill.svg`,
      CYLTabBarItemIdentifier: CATEGORIES[index],
    })),
  };
}

module.exports = {
  CATEGORIES, TAB_TITLES, JOB_CATEGORIES, INDUSTRIES, JOB_KEYWORDS, PLACEHOLDERS, MAIMAI_HEADER,
  categoryIndex, placeholder, sections, clampJobCategory, jobSection, industryButton, maimaiStyle,
  tagListConfiguration, tabBarConfiguration,
};
