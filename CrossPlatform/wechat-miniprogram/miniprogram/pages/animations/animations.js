/**
 * 动效 (tab): CYLTagAnimationDemoViewController, 1:1. The engine status, the playback controls of
 * docs/example-demo-rules.md (a speed slider from 0.25× to 4× in steps of 0.25 with its value, a loop switch and
 * Play all; they combine and act at once on animations that are playing), then the tag list made from one
 * configuration (map): one section per animation library (Lottie, PAG, Rive, GIF) and CYLTabBarController's static
 * tab images, single choice per section, the first tag of each selected. A tapped tag plays its icon and the status
 * shows 点击「section · title」. Every icon is CYLTabBarController's cyl-animated-item (inside cyl-tag-list); the engines
 * are components/cyl-tag-animation-view, given as the abstract nodes cyl-lottie-view, cyl-rive-view and cyl-pag-view.
 */
const i18n = require('../../utils/i18n.js');
const animations = require('../../utils/tag-animations.js');
const symbols = require('cyl-tag-list-miniprogram/cyl-tag-list/symbols.js');
const demo = require('./demo.js');

const { t } = i18n;

Page({
  data: {
    status: '',
    configuration: {},
    minSpeed: demo.SPEED_RANGE[0],
    maxSpeed: demo.SPEED_RANGE[1],
    speedStep: demo.SPEED_STEP,
    speedTitle: '',
    loopTitle: '',
    playAllTitle: '',
    playAllHint: '',
    playIcon: '',
    controls: {},
  },

  onLoad(options) {
    // navigationItem.title: the tab keeps its own title (动效).
    wx.setNavigationBarTitle({ title: t('动效图标') });
    this.setData({
      status: animations.isAnimationEngineAvailable
        ? t('动效引擎：CYLTabBarItemAnimationFactory 已链接')
        : t('动效引擎未链接：显示静态图标'),
      configuration: demo.configuration(t),
      speedTitle: t('倍速'),
      loopTitle: t('循环播放'),
      playAllTitle: t('全部播放'),
      playAllHint: t('从头播放屏幕上的全部动效'),
      playIcon: symbols.symbolURI('play.fill', '#FFFFFF'),
      controls: this.controls(1, false),
    });
    // `?autoplay=1` (a compile condition) applies 2x and loop (which plays all) after a second, for screenshots.
    if (options && options.autoplay) {
      setTimeout(() => {
        this.setSpeed(2);
        this.setLoops(true);
      }, 1000);
    }
  },

  onShow() {
    if (typeof this.getTabBar === 'function' && this.getTabBar()) this.getTabBar().syncWithRoute(this.route);
  },

  controls(speed, loops) {
    return demo.controls(speed, loops, t, i18n.language());
  },

  /** Sets the speed as the slider does (clamped, in steps): every animated icon changes at once. */
  setSpeed(value) {
    this.setData({ controls: this.controls(demo.snapSpeed(value), this.data.controls.loops) });
  },

  /** On: the icons start playing and repeat. Off: the pass in progress finishes and they stop. */
  setLoops(loops) {
    this.setData({ controls: this.controls(this.data.controls.speed, loops) }, () => {
      if (loops) this.playAll();
    });
  },

  onSpeedChanging(event) {
    this.setSpeed(event.detail.value);
  },

  onLoopChange(event) {
    this.setLoops(!!event.detail.value);
  },

  /** Plays every animated icon from progress 0 (全部播放); with the loop switch on, they repeat until it is turned off. */
  playAll() {
    const list = this.selectComponent('#tags');
    if (list) list.playAll();
  },

  onTagTap(event) {
    const { sectionTitle, title, selected } = event.detail;
    // menu(_:didSelectItemAt:): only a selection updates the status.
    if (selected) this.setData({ status: t('点击「%@」', `${sectionTitle} · ${title}`) });
  },
});
