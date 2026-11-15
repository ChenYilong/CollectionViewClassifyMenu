/**
 * The animation engines of the Mini Program tag list, the counterpart of the animators registered with
 * CYLTabBarController's `CYLTabBarItemAnimationFactory` on iOS:
 *
 * - **lottie**: lottie-miniprogram (npm, built into miniprogram_npm), on a 2d canvas (cyl-lottie-icon);
 * - **gif**: an <image> (a GIF plays on its own; the first and last frames are PNG stills for the resting and the
 *   selected state, exported by scripts/export-animations.py);
 * - **pag**, **rive**: not linked. CYLTabBarController's Mini Program packages (cyl-pag-miniprogram,
 *   cyl-rive-miniprogram) carry libpag (352 KB of JavaScript + a 471 KB WebAssembly) and the Rive runtime (103 KB +
 *   573 KB); the tab pages live in the main package, whose limit is 2 MB, so neither is in it. A tag whose engine is
 *   missing shows its image (or only its title), as on iOS when the app does not link that library's subspec.
 *
 * `isAnimationEngineAvailable` is `CYLTagButton.isAnimationEngineAvailable`: true when any engine is linked.
 */
const registry = require('../../data/animations/index.js');
const assets = require('../../data/lottie-registry.js');
const model = require('./model.js');

const ENGINES = { lottie: true, gif: true, pag: false, rive: false };

const isAnimationEngineAvailable = Object.keys(ENGINES).some((name) => ENGINES[name]);

/** The animation a tag plays ({engine, key, entry}), or null (model.resolveAnimation with the package's files). */
function resolve(animation) {
  return model.resolveAnimation(animation, registry, ENGINES, assets);
}

module.exports = { ENGINES, isAnimationEngineAvailable, resolve, registry };
