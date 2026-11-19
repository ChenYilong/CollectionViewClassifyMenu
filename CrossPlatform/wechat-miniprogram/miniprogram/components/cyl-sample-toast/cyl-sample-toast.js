/**
 * The samples' toast (`CYLAndroidSample.toast`, Android's Toast): a message at the bottom of the page, 48 pt above
 * the safe area, for two seconds, then it fades out. A new message replaces the one shown. Method: `show(text)`.
 */
const { TOAST_DURATION, TOAST_FADE } = require('../../utils/android-sample.js');

Component({
  data: { text: '', visible: false, fading: false },

  lifetimes: {
    detached() {
      clearTimeout(this._hide);
      clearTimeout(this._remove);
    },
  },

  methods: {
    show(text) {
      clearTimeout(this._hide);
      clearTimeout(this._remove);
      this.setData({ text, visible: true, fading: false });
      this._hide = setTimeout(() => {
        this.setData({ fading: true });
        this._remove = setTimeout(() => this.setData({ visible: false, fading: false }), TOAST_FADE);
      }, TOAST_DURATION);
    },

    /** The text of the toast shown, or '' (`CYLAndroidSample.toastText(in:)`). */
    text() {
      return this.data.visible ? this.data.text : '';
    },
  },
});
