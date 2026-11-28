/**
 * The example's engine component for the tags: given to cyl-tag-list (and cyl-tag-button) as the abstract nodes
 * `cyl-lottie-view`, `cyl-rive-view`, `cyl-pag-view` and `cyl-svga-view`, which the library forwards to CYLTabBarController's
 * cyl-animated-item, the component that draws every tag icon. The library links no engine; this component plays:
 *
 * - a Lottie file in CYLTabBarController's `cyl-lottie` (its lottie-miniprogram fork: image assets, a canvas per
 *   animation, and in WeChat DevTools an <image> of the canvas, so the icon stays in its tag while the list scrolls);
 * - a Rive file in CYLTabBarController's `cyl-rive`, with the tag's animationOptions;
 * - a PAG file in CYLTabBarController's `cyl-pag` (the "engines" subpackage, loaded asynchronously);
 * - an SVGA file in CYLTabBarController's `cyl-svga` (also in the "engines" subpackage).
 *
 * A GIF never comes here: cyl-animated-item draws it with <image>.
 *
 * The engine contract of cyl-animated-item (its default, cyl-animation-placeholder, has the same members): `path` (the
 * file the library registered, "Lottie/tab_home_animate.json", "Rive/house.riv#stateMachine=…", found with the library's
 * animations.resolve), `loop`, `speed`, `autoplay`, `resting-frame` ('last' while the tag is selected, else 'first' or
 * the tag's restingProgress after "#"); `ready` once the file is drawn, `error` when it cannot be (cyl-animated-item then
 * shows the tag's image); `cylPlayFromStart()` and its siblings, used by the library's playItems() / playAll() (a tapped
 * tag, Play all) with the playback controls of docs/example-demo-rules.md.
 */
const animations = require('../../utils/tag-animations.js');

/** CYLTabBarController's cyl-rive (installed by scripts/fetch-cyltabbar.js) loads its WebAssembly from here. */
const RIVE_WASM = '/cyl_components/cyl-rive-miniprogram/rive/rive.wasm.br';

/** cyl-pag (in the "engines" subpackage, scripts/fetch-cyltabbar.js) loads libpag's WebAssembly from here. */
const PAG_WASM = '/engines/cyl-pag-miniprogram/libpag/libpag.wasm.br';

/** The options cyl-rive reads from the path's fragment ("#stateMachine=…&input=…"); iOS's "legacy" plays the default. */
// Every option cyl-rive reads from the fragment, from cyl-rive itself (CYLTabBarController), so a new one is never dropped.
const { CYL_RIVE_OPTION_NAMES: RIVE_OPTIONS } = require('../../cyl_components/cyl-rive-miniprogram/cyl-rive/cyl_rive_options.js');

function rivePath(src, parameters) {
  const pairs = RIVE_OPTIONS.filter((key) => parameters[key] != null && parameters[key] !== '')
    .map((key) => `${key}=${encodeURIComponent(parameters[key])}`);
  return pairs.length ? `${src}#${pairs.join('&')}` : src;
}

const ENGINES = ['lottie', 'rive', 'pag', 'svga'];

/**
 * An engine component's method as a bound function: `cyl<Name>` (the engine contract of cyl-animated-item since
 * CYLTabBarController 370d5eb5), else `cyl_<legacy>` (the engine packages of the same commit still spell it that way).
 */
function engineMethod(player, name, legacy) {
  const method = player[`cyl${name}`] || player[`cyl_${legacy}`];
  return typeof method === 'function' ? method.bind(player) : null;
}

Component({
  properties: {
    path: { type: String, value: '', observer: 'reload' },
    loop: { type: Boolean, value: false },
    speed: { type: Number, value: 1 },
    autoplay: { type: Boolean, value: true },
    restingFrame: { type: String, value: 'first', observer: 'rest' },
    colors: { type: Object, value: null },
    label: { type: String, value: '' },
  },

  data: { engine: '', lottieData: null, rivePath: '', wasmPath: RIVE_WASM, pagPath: '', pagWasmPath: PAG_WASM, svgaPath: '' },

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
      const resolved = animations.resolve(this.data.path);
      const engine = resolved && ENGINES.includes(resolved.engine) ? resolved.engine : '';
      this.entry = engine ? resolved.entry : null;
      this.parameters = animations.parameters(this.data.path);
      this.loaded = false;
      if (!engine) {
        this.setData({ engine: '' });
        this.fail(`cyl-tag-animation-view: no registered file for '${this.data.path}'`);
        return;
      }
      const next = { engine };
      // cyl-lottie keeps a reference to the data and changes it while playing, so every icon gets its own copy.
      if (engine === 'lottie') next.lottieData = JSON.parse(JSON.stringify(this.entry.data()));
      if (engine === 'rive') next.rivePath = rivePath(this.entry.src, this.parameters);
      if (engine === 'pag') next.pagPath = this.entry.src;
      if (engine === 'svga') next.svgaPath = this.entry.src;
      this.setData(next);
    },

    fail(message) {
      this.triggerEvent('error', { message });
    },

    onEngineError(event) {
      this.fail((event && event.detail && event.detail.message) || 'cyl-tag-animation-view: the engine failed');
    },

    /** The engine drew the file: the resting frame, then autoplay (or a play asked for while loading). */
    onEngineReady() {
      this.loaded = true;
      this.rest();
      this.triggerEvent('ready', {});
      if (this.data.autoplay || this.pendingPlay) this.cylPlayFromStart();
    },

    player() {
      return this.data.engine ? this.selectComponent(`#${this.data.engine}`) : null;
    },

    /** The resting frame: the last while selected ('last'), else the tag's restingProgress (0 by default). */
    rest() {
      if (!this.loaded) return;
      const player = this.player();
      if (!player) return;
      const resting = Number(this.parameters && this.parameters.restingProgress) || 0;
      const progress = this.data.restingFrame === 'last' ? 1 : Math.min(1, Math.max(0, resting));
      if (this.data.engine === 'lottie') {
        const animation = engineMethod(player, 'LottieAnimation', 'animation');
        const frames = animation && animation();
        if (!frames) return;
        const last = Math.max(0, (frames.totalFrames || 1) - 1);
        engineMethod(player, 'GoToAndStop', 'goToAndStop')(Math.round(last * progress), true);
      } else {
        const setProgress = engineMethod(player, 'SetProgress', 'setProgress');
        if (setProgress) setProgress(progress);
      }
    },

    /** Plays from progress 0 (Play all, or a tapped tag); with `loop`, until it is turned off. */
    cylPlayFromStart() {
      if (!this.loaded) {
        // The file is still loading (or the tag was just created): play when it is ready.
        this.pendingPlay = true;
        return;
      }
      this.pendingPlay = false;
      const player = this.player();
      const play = player && engineMethod(player, 'PlayFromStart', 'playFromStart');
      if (play) play();
    },

    cylPlay() {
      this.cylPlayFromStart();
    },

    cylPause() {
      this.forward('Pause', 'pause');
    },

    cylStop() {
      this.pendingPlay = false;
      this.rest();
    },

    cylGoToAndStop(...args) {
      this.forward('GoToAndStop', 'goToAndStop', args);
    },

    cylGoToAndPlay(...args) {
      this.forward('GoToAndPlay', 'goToAndPlay', args);
    },

    cylSetProgress(...args) {
      this.forward('SetProgress', 'setProgress', args);
    },

    cylSetSpeed(...args) {
      this.forward('SetSpeed', 'setSpeed', args);
    },

    cylLottieAnimation() {
      const player = this.player();
      const animation = player && engineMethod(player, 'LottieAnimation', 'animation');
      return animation ? animation() : null;
    },

    forward(method, legacy, args = []) {
      const player = this.loaded ? this.player() : null;
      const call = player && engineMethod(player, method, legacy);
      if (call) call(...args);
    },
  },
});
