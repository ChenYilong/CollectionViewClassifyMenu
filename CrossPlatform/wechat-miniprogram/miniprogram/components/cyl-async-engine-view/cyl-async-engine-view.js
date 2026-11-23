/**
 * The only animation component this example still owns: the stand-in for CYLTabBarController's PAG and SVGA engines, which
 * live in the "engines" subpackage to keep the main package under 2 MB. A page cannot bind an async subpackage component
 * to an abstract node directly (WeChat falls back to the placeholder), so the pages give this component to
 * `generic:cyl-pag-view` and `generic:cyl-svga-view`; it uses the engine in the subpackage, behind a componentPlaceholder.
 * Lottie and Rive are bound directly (generic:cyl-lottie-view="cyl-lottie", generic:cyl-rive-view="cyl-rive").
 *
 * The file arrives as a loadable `path` (cyl-tag-list resolves it, utils/tag-animations.js registers the files); this
 * component only picks PAG or SVGA by its extension, rests on the resting frame once the file is drawn, plays a request
 * that came while it was loading, and forwards the engine's methods. Members: the engine contract of
 * cyl-animated-item (its default, cyl-animation-placeholder, has the same ones).
 *
 * TODO (CYLTabBarController): when the engines can be bound from an async subpackage, or ship a component for it,
 * delete this component (docs/animated-item-migration.md).
 */
Component({
  properties: {
    path: { type: String, value: '', observer: 'reload' },
    loop: { type: Boolean, value: false },
    speed: { type: Number, value: 1 },
    autoplay: { type: Boolean, value: true },
    restingFrame: { type: String, value: 'first', observer: 'rest' },
    wasmPath: { type: String, value: '' },
    colors: { type: Object, value: null },
    label: { type: String, value: '' },
  },

  /** `filePath`: the file without the "#" options, which cyl-pag and cyl-svga would read as part of its name. */
  data: { engine: '', filePath: '' },

  lifetimes: {
    ready() {
      this.isReady = true;
      this.load();
    },
    detached() {
      this.isReady = false;
    },
  },

  methods: {
    reload() {
      if (this.isReady) this.load();
    },

    load() {
      const file = String(this.data.path || '').split('#')[0];
      const engine = /\.svga(\.bin)?$/i.test(file) ? 'svga' : (/\.pag(\.bin)?$/i.test(file) ? 'pag' : '');
      this.loaded = false;
      this.setData({ engine, filePath: engine ? file : '' });
      if (!engine) this.triggerEvent('error', { message: `cyl-async-engine-view: not a PAG or SVGA file '${this.data.path}'` });
    },

    onEngineError(event) {
      this.triggerEvent('error', { message: (event && event.detail && event.detail.message) || 'cyl-async-engine-view: the engine failed' });
    },

    /** The engine drew the file: the resting frame, then autoplay (or a play asked for while loading). */
    onEngineReady() {
      this.loaded = true;
      this.rest();
      this.triggerEvent('ready', {});
      if (this.data.autoplay || this.pendingPlay) this.cyl_playFromStart();
    },

    player() {
      return this.data.engine ? this.selectComponent('#engine') : null;
    },

    /** The resting frame: the last while selected ('last'), else the tag's restingProgress after "#" (0 by default). */
    rest() {
      if (!this.loaded) return;
      const player = this.player();
      if (!player || typeof player.cyl_setProgress !== 'function') return;
      const hash = String(this.data.path || '').split('#')[1] || '';
      const match = /(?:^|&)restingProgress=([0-9.]+)/.exec(hash);
      const resting = match ? Number(match[1]) || 0 : 0;
      player.cyl_setProgress(this.data.restingFrame === 'last' ? 1 : Math.min(1, Math.max(0, resting)));
    },

    /** Plays from progress 0 (Play all, or a tapped tag); with `loop`, until it is turned off. */
    cyl_playFromStart() {
      if (!this.loaded) {
        this.pendingPlay = true;
        return;
      }
      this.pendingPlay = false;
      const player = this.player();
      if (player && typeof player.cyl_playFromStart === 'function') player.cyl_playFromStart();
    },

    cyl_play() {
      this.cyl_playFromStart();
    },

    cyl_pause() {
      this.forward('cyl_pause');
    },

    cyl_stop() {
      this.pendingPlay = false;
      this.rest();
    },

    cyl_goToAndStop(...args) {
      this.forward('cyl_goToAndStop', args);
    },

    cyl_goToAndPlay(...args) {
      this.forward('cyl_goToAndPlay', args);
    },

    cyl_setProgress(...args) {
      this.forward('cyl_setProgress', args);
    },

    cyl_setSpeed(...args) {
      this.forward('cyl_setSpeed', args);
    },

    cyl_animation() {
      const player = this.player();
      return player && typeof player.cyl_animation === 'function' ? player.cyl_animation() : null;
    },

    forward(method, args = []) {
      const player = this.loaded ? this.player() : null;
      if (player && typeof player[method] === 'function') player[method](...args);
    },
  },
});
