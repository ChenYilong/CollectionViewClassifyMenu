/**
 * 标签容器示例, 1:1 with the iOS example's `CYLTagContainerSampleViewController` (whilu/AndroidTagView's MainActivity
 * and content_main.xml): five tag containers with the attributes of the sample's XML, and 添加 (a tag with the typed
 * text in the first container). Pushed from the Styles tab.
 *
 * 1: drag to reorder, taps toast, a long press asks to delete, the cross toasts. 2: drag, random colors.
 * 3: right-aligned, reversed titles; a tap toasts (or deselects all), a long press selects. 4: centered, a black
 * ripple. 5: custom colors per tag.
 */
const { t } = require('../../utils/i18n.js');
const { COLORS } = require('../../utils/android-sample.js');
const model = require('cyl-tag-list-miniprogram/cyl-tag-cloud/model.js');
const data = require('./data.js');

/** The cyl-tag-cloud options a container leaves unset, so the component never receives undefined (XML defaults). */
const DEFAULT_OPTIONS = {
  colorTheme: 'none', defaultTagImage: '', containerBorderWidth: 0, containerBorderColor: '', containerCornerRadius: 0,
};

function withDefaultOptions(container) {
  return { ...container, tags: container.tags || [], style: container.style || {}, options: { ...DEFAULT_OPTIONS, ...(container.options || {}) } };
}

Page({
  data: { containers: [], text: '', fieldLabel: '', addTitle: '', gray: COLORS.systemGray, reordering: false },

  onLoad() {
    wx.setNavigationBarTitle({ title: t('标签容器示例') });
    this.setData({
      containers: data.containers().map(withDefaultOptions),
      fieldLabel: t('新标签'),
      addTitle: t('添加'),
    });
  },

  container(index) {
    return this.selectComponent(`#container-${index}`);
  },

  toast(text) {
    this.selectComponent('#toast').show(text);
  },

  onInput(event) {
    this.setData({ text: event.detail.value });
  },

  /** addTag(withTitle:) on the first container, with the typed text (also an empty one, as the sample). */
  addTag() {
    this.container(0).addTag(model.makeTag(this.data.text));
  },

  /** The scroll view stops while a tag is dragged. */
  onReorderingChange(event) {
    this.setData({ reordering: event.detail.reordering });
  },

  // MARK: The first container

  onFirstTap(event) {
    const { position, tag } = event.detail;
    this.toast(t('点击位置：%ld，文字：%@', position, tag.title));
  },

  /** onTagLongClick: "You will delete this tag!" with 删除 (destructive) and 取消. */
  onFirstLongPress(event) {
    const { position } = event.detail;
    wx.showModal({
      title: t('长按'),
      content: t('将删除这个标签！'),
      confirmText: t('删除'),
      confirmColor: '#FF3B30',
      cancelText: t('取消'),
      success: (result) => {
        if (!result.confirm) return;
        const first = this.container(0);
        if (position < first.getTags().length) first.removeTag(position);
      },
    });
  },

  /** onTagCrossClick: the cross only reports (removesItemsOnDelete is false). */
  onFirstDelete(event) {
    this.toast(t('点了标签的叉！位置 = %ld', event.detail.position));
  },

  // MARK: The third container

  /** Deselect all when an unselected tag is tapped while others are selected; otherwise the toast. */
  onThirdTap(event) {
    const { position, tag } = event.detail;
    const third = this.container(2);
    const selected = third.selectedIndexes();
    if (selected.length === 0 || selected.includes(position)) {
      this.toast(t('点击位置：%ld，文字：%@', position, tag.title));
    } else {
      third.deselectAll();
    }
  },

  /** A long press selects or deselects the tag, then toasts the selected positions. */
  onThirdLongPress(event) {
    const third = this.container(2);
    third.toggleSelection(event.detail.position);
    this.toast(t('已选位置：%@', third.selectedIndexes().map(String).join(', ')));
  },

  onThirdSelectedDrag(event) {
    this.toast(t('拖动：%@', event.detail.tag.title));
  },

  // MARK: The fourth container

  onFourthTap(event) {
    const { position, tag } = event.detail;
    this.toast(t('点击位置：%ld，文字：%@', position, tag.title));
  },
});
