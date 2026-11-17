/**
 * The animation files of the tag list. The library plays nothing itself and links no engine: every tag icon is drawn by
 * CYLTabBarController's shared component cyl-animated-item (vendored at a pinned commit in ../cyl-animated-item), which
 * plays a file through the engine components the app gives as the abstract nodes `cyl-lottie-view`, `cyl-pag-view`,
 * `cyl-rive-view` and `cyl-svga-view` (generic:cyl-lottie-view="…" on cyl-tag-list or cyl-tag-button) and draws a GIF
 * with `<image>`. Without an engine (or when it fails) a tag shows its image, as on iOS and Android.
 *
 * The app registers where its files are, so that a configuration can name them as the iOS example does
 * ("CYLMenuExample.bundle/Animations/Lottie/x.json"):
 *
 *   configure({
 *     registry: { "Lottie/x.json": {engine: 'lottie', data()}, "GIF/y.gif": {engine: 'gif', src, first, last, duration}, ... },
 *     assets: { name: data },                                                  // "asset:<name>" Lottie files
 *   });
 *
 * `url(animation, options, restingProgress)` is the `animation-url` cyl-animated-item gets (model.animationURL): the
 * registered path, which the app's engine component resolves with `resolve()`, a GIF's own `src`, or an absolute path
 * or URL as it is. A registered GIF's `first` / `last` stills (PNG) and `duration` (ms) are a tag's defaults (`gif()`):
 * the tag rests on the still and plays one pass on Play all, as the other engines do.
 */
const model = require('./model.js');

const state = { registry: {}, assets: {} };

function configure(options = {}) {
  if (options.registry) state.registry = options.registry;
  if (options.assets) state.assets = options.assets;
  return module.exports;
}

/** The registered file of an animation or of an `animation-url` ({engine, key, entry}), or null. */
function resolve(animation) {
  return model.resolveAnimation(animation, state.registry, state.assets);
}

/** The `animation-url` of a tag's animation for cyl-animated-item, or '' (model.animationURL). */
function url(animation, options, restingProgress) {
  return model.animationURL(animation, state.registry, state.assets, options, restingProgress);
}

/** A registered GIF's stills and the length of one pass: {gifFirstFrame, gifLastFrame, gifDuration}, '' / 0 when unknown. */
function gif(animation) {
  const resolved = resolve(animation);
  const entry = resolved && resolved.engine === 'gif' ? resolved.entry : {};
  return {
    gifFirstFrame: typeof entry.first === 'string' ? entry.first : '',
    gifLastFrame: typeof entry.last === 'string' ? entry.last : '',
    gifDuration: Number(entry.duration) > 0 ? Number(entry.duration) : 0,
  };
}

/** A tag's GIF options: its own values, else the registered GIF's (`gif()`). */
function gifOptions(animation, own = {}) {
  const registered = gif(animation);
  return {
    gifFirstFrame: own.gifFirstFrame || registered.gifFirstFrame,
    gifLastFrame: own.gifLastFrame || registered.gifLastFrame,
    gifDuration: Number(own.gifDuration) > 0 ? Number(own.gifDuration) : registered.gifDuration,
  };
}

module.exports = {
  configure,
  resolve,
  url,
  gif,
  gifOptions,
  parameters: model.animationParameters,
  get registry() { return state.registry; },
};
