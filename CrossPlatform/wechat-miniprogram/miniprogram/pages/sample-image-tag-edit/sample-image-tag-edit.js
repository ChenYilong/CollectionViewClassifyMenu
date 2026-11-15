/**
 * 创建标签, 1:1 with the iOS example's `CYLImageTagEditViewController` (TagViewGroup's TagEditActivity): the picture in
 * edit mode (drag a group, a tap on a tag turns it, the dot toasts, a long press asks to delete the group), the
 * instructions, 创建 (an alert with three tag fields: up to three tags at the center) and 保存 (stores the groups and
 * goes back; the opener shows them).
 */
const { t } = require('../../utils/i18n.js');
const sample = require('../../utils/android-sample.js');
const data = require('../sample-image-tag/data.js');

Page({
  data: {
    picture: {},
    info: '',
    pink: sample.COLORS.systemPink,
    createTitle: '',
    saveTitle: '',
    dialog: null,
  },

  onLoad() {
    wx.setNavigationBarTitle({ title: t('创建标签') });
    this.setData({
      picture: sample.picture(0),
      info: t('1. 点击创建按钮开始创建标签组\n2. 按住标签组滑动，调整位置\n3. 点击单个标签，调整该标签的方向\n4. 点击中心圆弹出提示\n5. 长按标签组删除'),
      createTitle: t('创建'),
      saveTitle: t('保存'),
    });
  },

  tagImage() {
    return this.selectComponent('#tag-image');
  },

  toast(text) {
    this.selectComponent('#toast').show(text);
  },

  onCircleTap() {
    this.toast(t('点击中心圆'));
  },

  /** longPressHandler: 删除标签组 / 你确定要删除该标签组吗？ with 取消 and a destructive 确定. */
  onLongPress(event) {
    const { index } = event.detail;
    wx.showModal({
      title: t('删除标签组'),
      content: t('你确定要删除该标签组吗？'),
      cancelText: t('取消'),
      confirmText: t('确定'),
      confirmColor: '#FF3B30',
      success: (result) => {
        if (result.confirm) this.tagImage().removeTagGroup(index);
      },
    });
  },

  /** 创建: the alert with three fields 标签 1…3 (TagEditDialog). */
  showCreateDialog() {
    this.setData({
      dialog: {
        title: t('创建标签'),
        cancel: t('取消'),
        ok: t('确定'),
        fields: [1, 2, 3].map((index) => ({ index, placeholder: t('标签 %ld', index), value: '' })),
      },
    });
  },

  onDialogInput(event) {
    const index = Number(event.currentTarget.dataset.index);
    this.setData({ [`dialog.fields[${index}].value`]: event.detail.value });
  },

  onDialogCancel() {
    this.setData({ dialog: null });
  },

  onDialogConfirm() {
    const names = this.data.dialog.fields.map((field) => field.value);
    this.setData({ dialog: null });
    this.createGroup(names);
  },

  /** createGroup(withNames:): a group of the non-empty names, when there is one. */
  createGroup(names) {
    const group = data.groupWithNames(names);
    if (group.tags.length) this.tagImage().addTagGroup(group);
  },

  /** 保存: the repository keeps the groups; back to the picture, which shows them. */
  save() {
    data.setTagGroups(this.tagImage().getTagGroups());
    wx.navigateBack();
  },

  noop() {},
});
