/**
 * The animation engines of the tag list, the counterpart of the animators registered with CYLTabBarController's
 * `CYLTabBarItemAnimationFactory` on iOS. The library links no engine: the app registers its animation files and the
 * engines it ships with `configure()`, and gives cyl-tag-list the icon component that plays them as the abstract node
 * `cyl-animation-icon` (generic:cyl-animation-icon="…"). Without an engine a tag shows its symbol or image instead.
 *
 *   configure({
 *     registry: { lottie: {key: {data()}}, gif: {...}, rive: {...}, pag: {...} },   // the app's animation files
 *     assets: { name: {data()} },                                                    // "asset:<name>" Lottie files
 *     engines: { lottie: true, gif: true, rive: true, pag: true },                   // the engines the app ships
 *   });
 *
 * `isAnimationEngineAvailable` is `CYLTagButton.isAnimationEngineAvailable`: true when any engine is registered.
 */
const model = require('./model.js');

const state = { registry: {}, assets: {}, engines: {} };

function configure(options = {}) {
  if (options.registry) state.registry = options.registry;
  if (options.assets) state.assets = options.assets;
  if (options.engines) state.engines = { ...options.engines };
  return module.exports;
}

/** The animation a tag plays ({engine, key, entry}), or null (model.resolveAnimation with the registered files). */
function resolve(animation) {
  return model.resolveAnimation(animation, state.registry, state.engines, state.assets);
}

module.exports = {
  configure,
  resolve,
  get ENGINES() { return state.engines; },
  get registry() { return state.registry; },
  get isAnimationEngineAvailable() { return Object.keys(state.engines).some((name) => state.engines[name]); },
};
