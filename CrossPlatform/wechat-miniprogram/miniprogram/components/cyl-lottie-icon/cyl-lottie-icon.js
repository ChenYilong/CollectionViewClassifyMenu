/**
 * One animated icon of a tag: a Lottie file played on a 2d canvas by lottie-miniprogram (the Mini Program build of
 * lottie-web), the counterpart of the core's animation player (CYLTabBarController's `CYLTabBarItemAnimationFactory`
 * on iOS and Android). It takes the playback controls of docs/example-demo-rules.md: `speed`, `loops` and `play()`
 * (from progress 0), and they act at once on an animation that is playing.
 */
const lottie = require('lottie-miniprogram');
const registry = require('../../data/lottie-registry.js');

Component({
  properties: {
    /** "asset:<name>" (a file of data/lottie-registry.js) or "<name>". */
    animation: { type: String, value: '' },
    size: { type: Number, value: 18 },
    /** Playback speed, 1 = the file's own. */
    speed: { type: Number, value: 1, observer: 'applyPlayback' },
    loops: { type: Boolean, value: false, observer: 'applyPlayback' },
  },

  lifetimes: {
    ready() {
      this.load();
    },
    detached() {
      if (this.player) this.player.destroy();
      this.player = null;
    },
  },

  methods: {
    load() {
      const name = this.data.animation.replace(/^asset:/, '');
      const animationData = registry[name];
      if (!animationData) return;
      this.createSelectorQuery()
        .select('.cyl-lottie-canvas')
        .fields({ node: true, size: true })
        .exec(([result]) => {
          if (!result || !result.node) return;
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
            animationData: JSON.parse(JSON.stringify(animationData)),
            rendererSettings: { context },
          });
          this.applyPlayback();
          // The resting frame: the first one, as the tab icons show before they are tapped.
          this.player.goToAndStop(0, true);
        });
    },

    applyPlayback() {
      if (!this.player) return;
      this.player.setSpeed(this.data.speed > 0 ? this.data.speed : 1);
      this.player.loop = this.data.loops;
      // Turning the loop on keeps a finished animation going; turning it off lets the current cycle end.
      if (this.data.loops && this.player.isPaused) this.player.play();
    },

    /** Plays from progress 0 (Play all, or a tapped tag). */
    play() {
      if (!this.player) return;
      this.applyPlayback();
      this.player.goToAndPlay(0, true);
    },
  },
});
