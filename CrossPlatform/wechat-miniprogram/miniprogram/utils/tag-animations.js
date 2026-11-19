/**
 * The example's animation files, registered with the tag list library (cyl-tag-list-miniprogram), and the engines the
 * example ships. The library draws every tag icon with CYLTabBarController's cyl-animated-item and links no engine:
 *
 * - **lottie**: CYLTabBarController's cyl-lottie (its lottie-miniprogram fork, in cyl_components);
 * - **gif**: drawn by cyl-animated-item's <image> from the entry's `src` (a GIF plays on its own);
 * - **rive**: CYLTabBarController's cyl-rive-miniprogram (the Rive runtime, 103 KB, and its WebAssembly, 573 KB, in
 *   cyl_components), playing the .riv.bin files of data/animations/rive with the tags' animationOptions;
 * - **pag**: CYLTabBarController's cyl-pag-miniprogram (libpag 4.5.85, about 0.96 MB) and the fetched PAG files, in the
 *   "engines" subpackage (the main package's 2 MB would not hold it next to Rive), loaded asynchronously by the icon
 *   component (componentPlaceholder) and preloaded for the 动效 and 样式 tabs (app.json preloadRule);
 * - **svga**: CYLTabBarController's cyl-svga-miniprogram (an SVGA 2.x player for the 2D canvas, about 75 KB) and the
 *   .svga.bin files of engines/svga, in the same subpackage.
 *
 * components/cyl-tag-animation-view plays Lottie, Rive, PAG and SVGA; the pages hand it to cyl-tag-list as the abstract
 * nodes generic:cyl-lottie-view, generic:cyl-rive-view, generic:cyl-pag-view and generic:cyl-svga-view. Required by app.js, so the files are
 * registered before any page shows a tag.
 */
const animations = require('cyl-tag-list-miniprogram/cyl-tag-list/animations.js');
const registry = require('../data/animations/index.js');
const assets = require('../data/lottie-registry.js');

animations.configure({ registry, assets });

/** The engines the example ships (components/cyl-tag-animation-view, and <image> for GIF). */
const ENGINES = Object.freeze({ lottie: true, gif: true, pag: true, rive: true, svga: true });

module.exports = {
  resolve: animations.resolve,
  url: animations.url,
  parameters: animations.parameters,
  get registry() { return animations.registry; },
  ENGINES,
  /** `CYLTagButton.isAnimationEngineAvailable` for the example: true, it ships engines. */
  isAnimationEngineAvailable: Object.keys(ENGINES).some((name) => ENGINES[name]),
};
