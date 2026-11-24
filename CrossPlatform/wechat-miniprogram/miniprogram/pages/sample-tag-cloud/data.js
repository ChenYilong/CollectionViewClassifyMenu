/**
 * kaedea/android-tagview's sample data and styles, as CYLTagCloudSample.swift (CYLTagCloudSampleData and the
 * screens' configuration): MainActivity's tags, the list rows, the RecyclerView rows and the YY hot search. No `wx`
 * calls.
 */
const { t } = require('../../utils/i18n.js');
const model = require('cyl-tag-list-miniprogram/cyl-tag-cloud/model.js');

/** res/values/arrays.xml. */
const CONTINENTS = ['AFRICA', 'EUROPE', 'ASIA', 'NORTH AMERICA', 'SOUTH AMERICA', 'ANTARCTICA', 'AUSTRALIA'];
const COLORS = ['#00BFFF', '#E91E63', '#F44336', '#9C27B0', '#673AB7'];

function color(index) {
  return model.color(COLORS[index]);
}

/** bg_tag: a white rounded rectangle, stretched (the tag's capsule clips it). */
const CUSTOM_BACKGROUND = 'linear-gradient(#FFFFFF, #FFFFFF)';

/** The tags of MainActivity's onCreate, in order. Corner radii are android pixels divided by 3 (xxhdpi points). */
function mainTags() {
  const tags = CONTINENTS.map((title) => model.makeTag(title));
  for (let index = 1; index < COLORS.length; index += 1) {
    tags.push(model.makeTag(t('彩色文字'), { textColor: color(index) }));
  }
  for (let index = 0; index < COLORS.length; index += 1) {
    tags.push(model.makeTag(t('彩色背景'), { backgroundColor: color(index) }));
  }
  for (const [width, borderColor] of [[1, null], [2, color(1)], [3, color(3)]]) {
    tags.push(model.makeTag(t('边框'), { borderWidth: width, borderColor }));
  }
  for (const radius of [0, 20 / 3, 60 / 3]) {
    tags.push(model.makeTag(t('圆角'), { cornerRadius: radius }));
  }
  tags.push(model.makeTag(t('可删除'), { isDeletable: true }));
  tags.push(model.makeTag(t('自定义背景'), { textColor: color(0), backgroundImage: CUSTOM_BACKGROUND }));
  tags.push(model.makeTag(t('详情标签'), {
    textColor: '#FFFFFF',
    backgroundColor: model.color('#DDDDDD'),
    highlightedBackgroundColor: model.color('#555555'),
    cornerRadius: 20 / 3,
    textSize: 14,
    borderWidth: 1,
    borderColor: '#FFFFFF',
    isDeletable: true,
  }));
  tags.forEach((tag, index) => { tag.identifier = index; });
  return tags;
}

/** activity_main.xml and item_list_tag.xml: `.tagCloud()`, lineMargin 5, tagMargin 3, textPadding 10 × 3. */
function cloudStyle() {
  const style = model.tagCloudStyle();
  style.lineSpacing = 5;
  style.interitemSpacing = 3;
  model.setTagContentInsets(style, { top: 3, left: 10, bottom: 3, right: 10 });
  return style;
}

/**
 * tv_add: the typed text or "ADD A TAG", deletable half the time, one of the five colors; its id is the number of
 * tags. `random(n)` gives a number below n.
 */
function newTag(text, count, random) {
  return model.makeTag(text ? text : t('添加标签'), {
    isDeletable: random(2) === 0,
    backgroundColor: color(random(5)),
    identifier: count,
  });
}

/** ListViewActivity: three tags of the row's text. */
function tagsForRow(row) {
  return ['#F06292', '#90CAF9', '#80DEEA'].map((hex) => model.makeTag(t('条目 %ld', row), { backgroundColor: model.color(hex) }));
}

/** ListViewActivity's rows. */
const LIST_ROW_COUNT = 51;

/** RecyclerViewActivity: 21 text rows, then a footer row with two tags. */
function recyclerTexts() {
  return Array.from({ length: 21 }, () => t('文本'));
}

function footerTags() {
  return [1, 2].map((n) => model.makeTag(t('页脚 %ld', n)));
}

// MARK: - The hot search (YY)

const ORANGE = model.rgba(0.95, 0.56, 0.2);
const BLUE = model.rgba(0.29, 0.64, 0.94);
const RED = model.rgba(0.9, 0.31, 0.29);

/** (title, badge): 'song' is 神 (blue), 'trending' is 热 (red); the titles are sample data, as in the screenshot. */
const HOT_SEARCHES = [
  // NOLOCALIZE-BEGIN: sample data: hot searches (song and singer names), as iOS
  ['入戏太深混合串烧版', 'song'], ['他和她', 'song'], ['妤宸', null], ['赛菲尔', null], ['小西瓜', 'trending'],
  ['入戏太深', 'song'], ['小虾米', null], ['羽冰', null], ['梦梦', null], ['神曲不跳转呀呀呀56567', 'song'],
  // NOLOCALIZE-END
];

function hotTags() {
  return HOT_SEARCHES.map(([title, badge]) => {
    const tag = model.makeTag(title);
    if (badge) {
      tag.badgeText = t(badge === 'song' ? '神' : '热');
      tag.badgeAccessibilityLabel = t(badge === 'song' ? '神曲' : '热门');
      tag.textColor = badge === 'song' ? BLUE : RED;
    }
    return tag;
  });
}

/** White capsules with a light gray border, 16 pt titles, 18 pt badges, an orange bar before 热门搜索. */
function hotStyle() {
  const style = model.defaultStyle();
  for (const state of ['normal', 'selected']) {
    Object.assign(style[state], {
      backgroundColor: '#FFFFFF',
      borderColor: model.white(0.88),
      borderWidth: 1,
      textColor: model.white(0.13),
      cornerRadius: 1000, // a capsule
      fontSize: 16,
    });
  }
  model.setTagContentInsets(style, { top: 9, left: 16, bottom: 9, right: 16 });
  style.imageSize = 18;
  style.imageTitleSpacing = 6;
  style.interitemSpacing = 8;
  style.lineSpacing = 10;
  style.highlightedBackgroundColor = model.white(0.94);
  style.headerIndicatorColor = ORANGE;
  style.headerFontSize = 18;
  style.headerTextColor = model.white(0.13);
  style.headerHeight = 48;
  style.backgroundColor = '#FFFFFF';
  return style;
}

module.exports = {
  CONTINENTS,
  COLORS,
  color,
  mainTags,
  cloudStyle,
  newTag,
  tagsForRow,
  LIST_ROW_COUNT,
  recyclerTexts,
  footerTags,
  ORANGE,
  BLUE,
  RED,
  HOT_SEARCHES,
  hotTags,
  hotStyle,
};
