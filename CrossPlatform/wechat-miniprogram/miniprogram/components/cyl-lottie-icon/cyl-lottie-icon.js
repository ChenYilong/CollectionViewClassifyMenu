/**
 * One animated icon of a tag, the counterpart of the view CYLTabBarController's `CYLTabBarItemAnimationFactory` makes
 * on iOS and of its player (`play`, `showLastFrame`, `stop`, `animationSpeed`, `progress`):
 *
 * - a Lottie file plays in CYLTabBarController's `cyl-lottie` (its lottie-miniprogram fork: image assets, a canvas per
 *   animation, and in WeChat DevTools an <image> of the canvas, so the icon stays in its tag while the list scrolls);
 * - a Rive file plays in CYLTabBarController's `cyl-rive`, with the tag's animationOptions;
 * - a GIF shows in an <image>: its first frame (a PNG still) at rest, its last frame while selected, and the GIF
 *   itself while it plays (one pass, then the last frame; with `loops`, until looping is turned off).
 *
 * As `CYLTagButton.updateAnimationState()`: selected shows the last frame, otherwise the first frame or
 * `restingProgress`. It takes the playback controls of docs/example-demo-rules.md: `speed`, `loops` and `play()`
 * (from progress 0), acting at once on an animation that is playing. A GIF in an <image> has no playback speed.
 */
const animations = require('../../utils/tag-animations.js');

/** CYLTabBarController's cyl-rive (installed by scripts/fetch-cyltabbar.js) loads its WebAssembly from here. */
const RIVE_WASM = '/cyl_components/cyl-rive-miniprogram/rive/rive.wasm.br';

/** cyl-pag (in the "engines" subpackage, scripts/fetch-cyltabbar.js) loads libpag's WebAssembly from here. */
const PAG_WASM = '/engines/cyl-pag-miniprogram/libpag/libpag.wasm.br';

/** The options cyl-rive reads from the path's fragment ("#stateMachine=…&input=…"); iOS's "legacy" plays the default. */
const RIVE_OPTIONS = ['artboard', 'stateMachine', 'animation', 'input', 'triggerInput', 'active', 'trigger', 'duration', 'color'];

function rivePath(src, options) {
  const pairs = RIVE_OPTIONS.filter((key) => options && options[key] != null && options[key] !== '')
    .map((key) => `${key}=${encodeURIComponent(options[key])}`);
  return pairs.length ? `${src}#${pairs.join('&')}` : src;
}

Component({
  properties: {
    /** "Lottie/tab_home_animate.json", "GIF/tab_star.gif", "Rive/house.riv" (data/animations/index.js), or "asset:<name>". */
    animation: { type: String, value: '', observer: 'reload' },
    /** Width of the icon slot; `height` 0 makes it square. */
    size: { type: Number, value: 18, observer: 'reload' },
    height: { type: Number, value: 0, observer: 'reload' },
    /** Playback speed, 1 = the file's own. */
    speed: { type: Number, value: 1 },
    loops: { type: Boolean, value: false, observer: 'onLoopsChange' },
    /** A selected tag shows the last frame (a selected tab's icon). */
    selected: { type: Boolean, value: false, observer: 'rest' },
    /** The frame (0...1) shown while not selected (`animationRestingProgress`). */
    restingProgress: { type: Number, value: 0, observer: 'rest' },
    /** A disabled tag draws its animation at 40 % opacity. */
    disabled: { type: Boolean, value: false },
    /** A Rive tag's animationOptions (stateMachine, input, artboard …), as on iOS. */
    options: { type: null, value: null, observer: 'reload' },
  },

  data: {
    engine: '', gifSrc: '', boxHeight: 18, lottieData: null, rivePath: '', wasmPath: RIVE_WASM,
    pagPath: '', pagWasmPath: PAG_WASM,
  },

  lifetimes: {
    ready() {
      this.isReady = true;
      this.load();
    },
    detached() {
      this.isReady = false;
      clearTimeout(this.gifTimer);
    },
  },

  methods: {
    reload() {
      if (this.isReady) this.load();
    },

    load() {
      clearTimeout(this.gifTimer);
      const resolved = animations.resolve(this.data.animation);
      this.entry = resolved ? resolved.entry : null;
      const engine = resolved ? resolved.engine : '';
      const boxHeight = this.data.height > 0 ? this.data.height : this.data.size;
      this.loaded = false;
      this.playing = false;
      const next = { engine, boxHeight };
      // cyl-lottie keeps a reference to the data and changes it while playing, so every icon gets its own copy.
      if (engine === 'lottie') next.lottieData = JSON.parse(JSON.stringify(this.entry.data()));
      if (engine === 'rive') next.rivePath = rivePath(this.entry.src, this.data.options);
      if (engine === 'pag') next.pagPath = this.entry.src;
      this.setData(next, () => {
        if (engine === 'lottie' || engine === 'pag') return; // ready when cyl-lottie / cyl-pag sends `ready`
        if (engine === 'rive') {
          this.loaded = true;
          if (this.pendingPlay) this.play();
          return;
        }
        if (engine !== 'gif') return;
        this.loaded = true;
        this.rest();
        if (this.pendingPlay) this.play();
      });
    },

    onLottieReady() {
      this.loaded = true;
      this.rest();
      if (this.pendingPlay) this.play();
    },

    onLottieComplete() {
      this.playing = false;
    },

    onPagReady() {
      this.loaded = true;
      this.rest();
      if (this.pendingPlay) this.play();
    },

    /** The frame of the current state: the last one while selected, else the resting progress. */
    rest() {
      this.playing = false;
      clearTimeout(this.gifTimer);
      if (this.data.engine === 'gif' && this.entry) {
        const resting = this.data.selected || this.data.restingProgress >= 1 ? this.entry.last : this.entry.first;
        this.setData({ gifSrc: resting });
        return;
      }
      if (this.data.engine === 'pag' && this.loaded) {
        // cyl-pag shows its resting frame (first / last); a resting progress between them is set as a progress.
        const pag = this.selectComponent('#pag');
        const progress = this.data.selected ? 1 : Math.min(1, Math.max(0, this.data.restingProgress));
        if (pag && typeof pag.cyl_setProgress === 'function') pag.cyl_setProgress(progress);
        return;
      }
      if (this.data.engine !== 'lottie' || !this.loaded) return;
      const lottie = this.selectComponent('#lottie');
      const player = lottie && lottie.cyl_animation();
      if (!player) return;
      const last = Math.max(0, (player.totalFrames || 1) - 1);
      const progress = this.data.selected ? 1 : Math.min(1, Math.max(0, this.data.restingProgress));
      lottie.cyl_goToAndStop(Math.round(last * progress), true);
    },

    onLoopsChange() {
      // cyl-lottie and cyl-rive take `loop` live; a GIF is an <image>, timed here.
      if (this.data.engine !== 'gif' || !this.playing) return;
      // Turning the loop off lets the pass in progress finish; turning it on keeps the GIF playing.
      clearTimeout(this.gifTimer);
      if (!this.data.loops) this.scheduleGifEnd();
    },

    /** Plays from progress 0 (Play all, or a tapped tag); with `loops`, until it is turned off. */
    play() {
      if (!this.loaded) {
        // The file is still loading (or the tag was just created): play when it is ready.
        this.pendingPlay = true;
        return;
      }
      this.pendingPlay = false;
      if (this.data.engine === 'gif') {
        this.playGif();
        return;
      }
      const player = this.selectComponent(`#${this.data.engine}`);
      if (!player) return;
      this.playing = true;
      player.cyl_playFromStart();
    },

    playGif() {
      clearTimeout(this.gifTimer);
      this.playing = true;
      this.gifStartedAt = Date.now();
      // Setting the source again restarts the GIF from its first frame.
      this.setData({ gifSrc: this.entry.first }, () => {
        this.setData({ gifSrc: this.entry.src });
        if (!this.data.loops) this.scheduleGifEnd();
      });
    },

    /** One pass, then the last frame, as the player stops at its end. */
    scheduleGifEnd() {
      const duration = this.entry.duration || 1000;
      const elapsed = Date.now() - (this.gifStartedAt || Date.now());
      const remaining = duration - (elapsed % duration);
      this.gifTimer = setTimeout(() => {
        this.playing = false;
        this.setData({ gifSrc: this.entry.last });
      }, remaining);
    },
  },
});
