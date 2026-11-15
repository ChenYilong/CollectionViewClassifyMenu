/**
 * The animation engines of the Mini Program tag list, the counterpart of the animators registered with
 * CYLTabBarController's `CYLTabBarItemAnimationFactory` on iOS:
 *
 * - **lottie**: CYLTabBarController's cyl-lottie (its lottie-miniprogram fork, in cyl_components);
 * - **gif**: an <image> (a GIF plays on its own; the first and last frames are PNG stills for the resting and the
 *   selected state, exported by scripts/export-animations.py);
 * - **rive**: CYLTabBarController's cyl-rive-miniprogram (the Rive runtime, 103 KB, and its WebAssembly, 573 KB, in
 *   cyl_components), playing the .riv.bin files of data/animations/rive with the tags' animationOptions;
 * - **pag**: CYLTabBarController's cyl-pag-miniprogram (libpag 4.5.85, about 0.96 MB) and the fetched PAG files, in the
 *   "engines" subpackage (the main package's 2 MB would not hold it next to Rive), loaded asynchronously by the icon
 *   component (componentPlaceholder) and preloaded for the 动效 and 样式 tabs (app.json preloadRule).
 *
 * `isAnimationEngineAvailable` is `CYLTagButton.isAnimationEngineAvailable`: true when any engine is linked.
 */
const registry = require('../../data/animations/index.js');
const assets = require('../../data/lottie-registry.js');
const model = require('./model.js');

const ENGINES = { lottie: true, gif: true, pag: true, rive: true };

const isAnimationEngineAvailable = Object.keys(ENGINES).some((name) => ENGINES[name]);

/** The animation a tag plays ({engine, key, entry}), or null (model.resolveAnimation with the package's files). */
function resolve(animation) {
  return model.resolveAnimation(animation, registry, ENGINES, assets);
}

module.exports = { ENGINES, isAnimationEngineAvailable, resolve, registry };
