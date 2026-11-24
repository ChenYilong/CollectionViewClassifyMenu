/**
 * 选词填入, 1:1 with the iOS example's `CYLWordPickerDemoViewController`: a remark field, the sender's message and a
 * "选词填入" link that opens a sheet where the message is one cell per character (`cyl-tag-cloud` with
 * `model.wordPickerStyle()`, smear selection); "填入" (off until something is selected) puts the selected characters,
 * in text order, into the field. The message is localized (a greeting with a name to pick, an emoji and a space).
 */
const { t } = require('../../utils/i18n.js');
const model = require('cyl-tag-list-miniprogram/cyl-tag-cloud/model.js');

/** The sender, and the name the message lets you pick (the same in every language). */
const SENDER = 'Alex';
const MESSAGE_KEY = '你好，我是设计部的 Alex 👋';

Page({
  data: {
    sender: SENDER,
    message: '',
    remark: '',
    sheetShown: false,
    canFill: false,
    pickerStyle: Object.assign(model.wordPickerStyle(), { backgroundStyle: 'liquidGlass' }),
    labels: {},
  },

  onLoad(query) {
    wx.setNavigationBarTitle({ title: t('选词填入') });
    this.setData({
      message: t(MESSAGE_KEY),
      labels: {
        remark: t('备注'), placeholder: t('添加备注'), pick: t('选词填入'), hint: t('涂抹选择填入词'),
        cancel: t('取消'), fill: t('填入'),
      },
    });
    if (query && query.open === '1') this.showPicker();
  },

  onRemarkInput(event) {
    this.setData({ remark: event.detail.value });
  },

  /** Opens the sheet with the message as cells. */
  showPicker() {
    this.setData({ sheetShown: true, canFill: false }, () => {
      const picker = this.selectComponent('#word-picker');
      if (picker) picker.setTagsWithCharactersOfText(this.data.message);
    });
  },

  hidePicker() {
    this.setData({ sheetShown: false });
  },

  /** "填入" is on only while something is selected. */
  onSelectionChange() {
    const picker = this.selectComponent('#word-picker');
    this.setData({ canFill: !!picker && picker.selectedIndexes().length > 0 });
  },

  onCellTap() {
    this.onSelectionChange();
  },

  /** Puts the picked characters, in text order, into the field and closes the sheet. */
  fill() {
    const picker = this.selectComponent('#word-picker');
    const picked = picker ? picker.selectedText() : '';
    if (!picked) return;
    this.setData({ remark: picked, sheetShown: false });
  },

  noop() {},
});
