/**
 * One animated icon of a tag, the counterpart of the view CYLTabBarController's `CYLTabBarItemAnimationFactory` makes
 * on iOS and of its player (`play`, `showLastFrame`, `stop`, `animationSpeed`, `progress`):
 *
 * - a Lottie file plays on a 2d canvas through lottie-miniprogram (the Mini Program build of lottie-web);
 * - a GIF shows in an <image>: its first frame (a PNG still) at rest, its last frame while selected, and the GIF
 *   itself while it plays (one pass, then the last frame; with `loops`, until looping is turned off).
 *
 * As `CYLTagButton.updateAnimationState()`: selected shows the last frame, otherwise the first frame or
 * `restingProgress`. It takes the playback controls of docs/example-demo-rules.md: `speed`, `loops` and `play()`
 * (from progress 0), acting at once on an animation that is playing. A GIF in an <image> has no playback speed.
 */
// CYLTabBarController's fork of lottie-miniprogram (installed by scripts/fetch-cyltabbar.js): it draws image assets.
const lottie = require('../../cyl_components/cyl-lottie-miniprogram/index.js');
const animations = require('../cyl-tag-list/animations.js');

Component({
  properties: {
    /** "Lottie/tab_home_animate.json", "GIF/tab_star.gif" (data/animations/index.js), or "asset:<name>" (data/lottie-registry.js). */
    animation: { type: String, value: '', observer: 'reload' },
    /** Width of the icon slot; `height` 0 makes it square. */
    size: { type: Number, value: 18, observer: 'reload' },
    height: { type: Number, value: 0, observer: 'reload' },
    /** Playback speed, 1 = the file's own. */
    speed: { type: Number, value: 1, observer: 'applyPlayback' },
    loops: { type: Boolean, value: false, observer: 'onLoopsChange' },
    /** A selected tag shows the last frame (a selected tab's icon). */
    selected: { type: Boolean, value: false, observer: 'onSelectedChange' },
    /** The frame (0...1) shown while not selected (`animationRestingProgress`). */
    restingProgress: { type: Number, value: 0, observer: 'rest' },
    /** A disabled tag draws its animation at 40 % opacity. */
    disabled: { type: Boolean, value: false },
  },

  data: { engine: '', gifSrc: '', boxHeight: 18 },

  lifetimes: {
    ready() {
      this.isReady = true;
      this.load();
    },
    detached() {
      this.isReady = false;
      this.destroy();
    },
  },

  methods: {
    reload() {
      if (this.isReady) this.load();
    },

    destroy() {
      clearTimeout(this.gifTimer);
      if (this.player) this.player.destroy();
      this.player = null;
    },

    load() {
      this.destroy();
      const resolved = animations.resolve(this.data.animation);
      this.entry = resolved ? resolved.entry : null;
      const engine = resolved ? resolved.engine : '';
      const boxHeight = this.data.height > 0 ? this.data.height : this.data.size;
      this.loaded = false;
      this.setData({ engine, boxHeight }, () => {
        if (engine === 'lottie') {
          this.loadLottie();
          return;
        }
        if (engine !== 'gif') return;
        this.loaded = true;
        this.rest();
        if (this.pendingPlay) this.play();
      });
    },

    loadLottie() {
      const token = (this.token = (this.token || 0) + 1);
      this.createSelectorQuery()
        .select('.cyl-lottie-canvas')
        .fields({ node: true, size: true })
        .exec(([result]) => {
          if (token !== this.token || !this.isReady || !result || !result.node) return;
          const canvas = result.node;
          const dpr = wx.getWindowInfo ? wx.getWindowInfo().pixelRatio : wx.getSystemInfoSync().pixelRatio;
          canvas.width = result.width * dpr;
          canvas.height = result.height * dpr;
          const context = canvas.getContext('2d');
          context.scale(dpr, dpr);
          lottie.setup(canvas);
          this.player = lottie.loadAnimation({
            loop: this.data.loops,
            autoplay: false,
            // lottie-web keeps a reference and changes it while playing, so every icon gets its own copy.
            animationData: JSON.parse(JSON.stringify(this.entry.data())),
            rendererSettings: { context },
          });
          this.player.addEventListener('complete', () => { this.playing = false; });
          // A file with image assets (base64 PNGs) draws its first frame before the images have loaded, so the
          // resting frame is drawn again once they have (iOS shows it with its images).
          this.player.addEventListener('loaded_images', () => {
            if (token === this.token && !this.playing) this.rest();
          });
          this.loaded = true;
          this.applyPlayback();
          this.rest();
          if (this.pendingPlay) this.play();
        });
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
      const player = this.player;
      if (!player) return;
      const last = Math.max(0, (player.totalFrames || 1) - 1);
      const progress = this.data.selected ? 1 : Math.min(1, Math.max(0, this.data.restingProgress));
      player.goToAndStop(Math.round(last * progress), true);
    },

    onSelectedChange() {
      // A change of selection stops the animation and shows the state's frame (updateAnimationState).
      this.rest();
    },

    onLoopsChange() {
      this.applyPlayback();
      if (this.data.engine !== 'gif' || !this.playing) return;
      // Turning the loop off lets the pass in progress finish; turning it on keeps the GIF playing.
      clearTimeout(this.gifTimer);
      if (!this.data.loops) this.scheduleGifEnd();
    },

    applyPlayback() {
      const player = this.player;
      if (!player) return;
      player.setSpeed(this.data.speed > 0 ? this.data.speed : 1);
      player.loop = this.data.loops;
      // Turning the loop on keeps a finished animation going; turning it off lets the current cycle end.
      if (this.data.loops && this.playing && player.isPaused) player.play();
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
      if (!this.player) return;
      this.applyPlayback();
      this.playing = true;
      this.player.goToAndPlay(0, true);
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
