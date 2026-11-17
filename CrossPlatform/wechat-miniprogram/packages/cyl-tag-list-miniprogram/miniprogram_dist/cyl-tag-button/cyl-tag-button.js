/**
 * `cyl-tag-button`: the Mini Program port of the core's `CYLTagButton` on its own, the one icon + title + animated icon
 * component (a search bar item, a toolbar button, a placeholder's icon): an icon (an image, a "system:<name>" symbol or
 * an animated icon) before, after, above or below a title, in the box of a `CYLMenuStyle` (the `tagStyle` dictionary,
 * the keys of a configuration's style), with an optional badge. The layout is cyl-tag-list's (model.js `tagLayout`),
 * and the icon is drawn by CYLTabBarController's cyl-animated-item (../cyl-animated-item, vendored by commit), so a new
 * animation type is added in one place, that component. Animations play in the engine components the app gives as the
 * abstract nodes `cyl-lottie-view`, `cyl-pag-view`, `cyl-rive-view` and `cyl-svga-view` (generic:cyl-lottie-view="…");
 * a GIF is drawn by `<image>`.
 *
 * Properties (the iOS names): `title`, `image`, `selectedImage`, `animationURL`, `animationOptions`,
 * `animationRestingProgress`, `animationSpeed` (0 uses the style's), `animationLoops`, `badgeValue` (null hides the
 * badge, '' shows a dot), `badgeColor` (system red by default), `accessibilityLabel` (what the screen reader reads first;
 * '' reads the title), `selected`, `enabled`, `gifFirstFrame` / `gifLastFrame` (a GIF's stills, PNG: it rests on them
 * and plays one pass of `gifDuration` ms, 1000 by default), `autoplay` (false: the animation rests until played),
 * `embedded` (cyl-animated-item's layout inside a control), `tagStyle` (with
 * `allowsTransparentBackground: true` a `transparent` background is kept, for a tag on a colored surface).
 * Methods (through `selectComponent`): `playAnimation()`, `intrinsicSize()`.
 * Events: `tagtap` {title, selected}.
 */
const model = require('../cyl-tag-list/model.js');
const animations = require('../cyl-tag-list/animations.js');

function pixelRatio() {
  try {
    return (wx.getWindowInfo ? wx.getWindowInfo() : wx.getSystemInfoSync()).pixelRatio || 2;
  } catch (error) {
    return 2;
  }
}

Component({
  properties: {
    title: { type: String, value: '', observer: 'render' },
    image: { type: String, value: '', observer: 'render' },
    selectedImage: { type: String, value: '', observer: 'render' },
    animationURL: { type: String, value: '', observer: 'render' },
    animationOptions: { type: null, value: null, observer: 'render' },
    animationRestingProgress: { type: Number, value: 0, observer: 'render' },
    // Any type (see cyl-tag-list): undefined or a non-number uses the style's speed, without a type warning.
    animationSpeed: { type: null, value: 0, observer: 'render' },
    animationLoops: { type: Boolean, value: false, observer: 'render' },
    badgeValue: { type: null, value: null, observer: 'render' },
    badgeColor: { type: String, value: '', observer: 'render' },
    accessibilityLabel: { type: String, value: '', observer: 'render' },
    selected: { type: Boolean, value: false, observer: 'render' },
    enabled: { type: Boolean, value: true, observer: 'render' },
    tagStyle: { type: Object, value: {}, observer: 'render' },
    gifFirstFrame: { type: String, value: '', observer: 'render' },
    gifLastFrame: { type: String, value: '', observer: 'render' },
    gifDuration: { type: Number, value: 0, observer: 'render' },
    autoplay: { type: Boolean, value: true, observer: 'render' },
    embedded: { type: Boolean, value: false },
  },

  // No icon until render() has run: an empty view drew cyl-animated-item with undefined properties (type warnings).
  data: { view: { iconKind: 'none' } },

  lifetimes: {
    attached() {
      this.render();
    },
  },

  methods: {
    render() {
      const url = animations.url(this.data.animationURL, this.data.animationOptions, this.data.animationRestingProgress);
      const props = { ...this.data, ...animations.gifOptions(this.data.animationURL, this.data) };
      this.setData({ view: model.tagButtonView(props, url, pixelRatio()) });
    },

    /** Plays the animated icon from progress 0 (`CYLTagButton.playAnimation()`). */
    playAnimation() {
      const url = this.data.view.animationUrl;
      const item = url && this.selectComponent('#cyl-tag-button-animation');
      // cyl-animated-item plays it: the engine from progress 0, a GIF again from its first frame (one pass with stills).
      if (item && typeof item.playAnimation === 'function') item.playAnimation();
    },

    /** `intrinsicContentSize`: {height} (the width follows the content: the tag is an inline flex box). */
    intrinsicSize() {
      return { height: this.data.view.height };
    },

    onTap() {
      if (!this.data.enabled) return;
      this.triggerEvent('tagtap', { title: this.data.title, selected: this.data.selected });
    },
  },
});
