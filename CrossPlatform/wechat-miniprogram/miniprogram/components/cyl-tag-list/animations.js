/**
 * The animation engines of the Mini Program tag list, the counterpart of the animators registered with
 * CYLTabBarController's `CYLTabBarItemAnimationFactory` on iOS:
 *
 * - **lottie**: lottie-miniprogram (npm, built into miniprogram_npm), on a 2d canvas (cyl-lottie-icon);
 * - **gif**: an <image> (a GIF plays on its own; the first and last frames are PNG stills for the resting and the
 *   selected state, exported by scripts/export-animations.py);
 * - **rive**: CYLTabBarController's cyl-rive-miniprogram (the Rive runtime, 103 KB, and its WebAssembly, 573 KB, in
 *   cyl_components), playing the .riv.bin files of data/animations/rive with the tags' animationOptions;
 * - **pag**: not linked: libpag (352 KB of JavaScript + a 471 KB WebAssembly) would not fit the 2 MB main package next
 *   to Rive. A PAG tag shows its image (or only its title), as on iOS when the app does not link that subspec.
 *
 * `isAnimationEngineAvailable` is `CYLTagButton.isAnimationEngineAvailable`: true when any engine is linked.
 */
const registry = require('../../data/animations/index.js');
const assets = require('../../data/lottie-registry.js');
const model = require('./model.js');

const ENGINES = { lottie: true, gif: true, pag: false, rive: true };

const isAnimationEngineAvailable = Object.keys(ENGINES).some((name) => ENGINES[name]);

/** The animation a tag plays ({engine, key, entry}), or null (model.resolveAnimation with the package's files). */
function resolve(animation) {
  return model.resolveAnimation(animation, registry, ENGINES, assets);
}

module.exports = { ENGINES, isAnimationEngineAvailable, resolve, registry };
