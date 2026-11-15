/**
 * 标签视图示例, 1:1 with the iOS example's `CYLTagCloudSampleViewController` (android-tagview's MainActivity): the
 * sample's tags (taps and deletions toast their id and position), a text field, 添加标签, 页面返回结果 (a sub-page
 * whose button adds a tag here), 列表视图, 回收视图 and YY 热门搜索. Pushed from the Styles tab.
 */
const { t } = require('../../utils/i18n.js');
const { COLORS } = require('../../utils/android-sample.js');
const data = require('./data.js');
const model = require('../../components/cyl-tag-cloud/model.js');

const GITHUB_URL = 'https://github.com/kaedea/';

Page({
  data: {
    tags: [],
    style: null,
    text: '',
    placeholder: '',
    fieldLabel: '',
    githubLabel: '',
    scrollTop: 0,
    blue: model.color(data.COLORS[0]),
    orange: COLORS.systemOrange,
    titles: {},
  },

  /** Random numbers below the given bound; replaced in tests. */
  random(bound) {
    return Math.floor(Math.random() * bound);
  },

  onLoad() {
    wx.setNavigationBarTitle({ title: t('标签视图示例') });
    this.setData({
      tags: data.mainTags(),
      style: data.cloudStyle(),
      placeholder: t('输入标签文字'),
      fieldLabel: t('标签文字'),
      githubLabel: t('在 GitHub 上查看'),
      titles: {
        addTag: t('添加标签'),
        activityResult: t('页面返回结果'),
        listView: t('列表视图'),
        recyclerView: t('回收视图'),
        hotSearch: t('YY 热门搜索'),
      },
    });
  },

  list() {
    return this.selectComponent('#tag-list');
  },

  toast(text) {
    this.selectComponent('#toast').show(text);
  },

  onTagTap(event) {
    const { position, tag } = event.detail;
    this.toast(t('点击标签 id = %ld，位置 = %ld', tag.identifier, position));
  },

  onTagDelete(event) {
    const { position, tag } = event.detail;
    this.toast(t('删除标签 id = %ld，位置 = %ld', tag.identifier, position));
  },

  onInput(event) {
    this.setData({ text: event.detail.value });
  },

  /** tv_add: the typed text or "ADD A TAG", deletable half the time, one of the five colors; then the last tag shows. */
  addTag() {
    const list = this.list();
    list.addTag(data.newTag(this.data.text, list.getTags().length, (n) => this.random(n)));
    this.setData({ scrollTop: this.data.scrollTop + 100000 });
  },

  /** startActivityForResult(SubActivity): its button adds a tag here. */
  openActivityResult() {
    wx.navigateTo({
      url: '/pages/sample-tag-cloud-sub/sample-tag-cloud-sub',
      events: {
        result: () => this.list().addTag(model.makeTag(t('返回结果后添加'))),
      },
    });
  },

  openListView() {
    wx.navigateTo({ url: '/pages/sample-tag-cloud-list/sample-tag-cloud-list' });
  },

  openRecyclerView() {
    wx.navigateTo({ url: '/pages/sample-tag-cloud-recycler/sample-tag-cloud-recycler' });
  },

  openHotSearch() {
    wx.navigateTo({ url: '/pages/sample-tag-cloud-hot-search/sample-tag-cloud-hot-search' });
  },

  /** The bar button: a Mini Program cannot open a web page outside its domains, so the link is copied. */
  openGitHub() {
    wx.setClipboardData({ data: GITHUB_URL });
  },
});
