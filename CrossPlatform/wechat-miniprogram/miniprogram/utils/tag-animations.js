/**
 * The example's animation files and engines, registered with the tag list library (cyl-tag-list-miniprogram):
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
 * components/cyl-lottie-icon plays them; the pages hand it to cyl-tag-list as generic:cyl-animation-icon.
 * Required by app.js, so the files are registered before any page shows a tag.
 */
const animations = require('cyl-tag-list-miniprogram/cyl-tag-list/animations.js');
const registry = require('../data/animations/index.js');
const assets = require('../data/lottie-registry.js');

animations.configure({ registry, assets, engines: { lottie: true, gif: true, pag: true, rive: true } });

module.exports = animations;
