#!/usr/bin/env node
/**
 * Installs CYLTabBarController's Mini Program packages (not on npm) for the example, as the React Native example
 * installs `react-native-cyltabbar` (`react-native/react-native-cyl-tag-list/scripts/fetch-cyltabbar.sh`):
 *
 *   1. checks out CYLTabBarController at COMMIT into .deps/CYLTabBarController (git-ignored), only the packages' folders;
 *   2. copies each package's mini program folder (its "miniprogram" field, else miniprogram_dist) to
 *      miniprogram/cyl_components/<name>/, or miniprogram/<root>/<name>/ for a subpackage (git-ignored);
 *   3. copies the PAG files of the demos (fetched by scripts/fetch-animation-resources.py PAGResources) to
 *      miniprogram/engines/pag/*.pag.bin (git-ignored);
 *   4. vendors CYLTabBarController's shared icon + title component, cyl-animated-item (and the default of its abstract
 *      nodes, cyl-animation-placeholder), into the library package cyl-tag-list-miniprogram (committed: the library
 *      ships it, docs/Animated-Item.md at COMMIT: "the mini program ... copies src/cyl-animated-item"), each folder with
 *      the component's LICENSE and a COMMIT file, and its model tests into test/ with the require path rewritten.
 *
 * The packages are copied outside miniprogram_npm because WeChat DevTools' "Build npm" rewrites that folder.
 *
 *   node scripts/fetch-cyltabbar.js           install
 *   node scripts/fetch-cyltabbar.js --check   exit 1 when an installed or vendored copy differs from the pinned commit
 */
const { execFileSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// CYL_TAB_BAR: the same commit as the React Native example (fetch-cyltabbar.sh, example/ios/Podfile).
const COMMIT = 'ee750a4636ef7cefb577ad70477649d43cf94bf9';
const REPOSITORY = 'https://github.com/ChenYilong/CYLTabBarController.git';
const ROOT = path.resolve(__dirname, '..');
const CHECKOUT = path.join(ROOT, '.deps', 'CYLTabBarController');

/**
 * The packages, by their folder in CYLTabBarController: the tab bar (custom-tab-bar, the search page's category bar),
 * CYLTabBarController's fork of lottie-miniprogram (cyl-lottie-miniprogram, which draws the base64 image assets the npm
 * lottie-miniprogram 1.0.12 never drew), cyl-rive (the Rive runtime and its 573 KB WebAssembly), and cyl-pag (libpag
 * 4.5.85, about 0.96 MB with its WebAssembly), which does not fit the 2 MB main package next to Rive: it goes to the
 * "engines" subpackage, which the icon component loads asynchronously (componentPlaceholder). cyl-svga (an SVGA 2.x
 * player for the 2D canvas, about 75 KB) goes there too, next to the example's .svga.bin files
 * (scripts/export-animations.py), so the main package stays as it is.
 */
const PACKAGES = [
  { name: 'cyl-tabbar-miniprogram', folder: 'CrossPlatform/wechat-miniprogram-cyltabbar' },
  { name: 'cyl-lottie-miniprogram', folder: 'CrossPlatform/lottie-miniprogram' },
  { name: 'cyl-rive-miniprogram', folder: 'CrossPlatform/rive-miniprogram' },
  { name: 'cyl-pag-miniprogram', folder: 'CrossPlatform/pag-miniprogram', root: 'engines' },
  { name: 'cyl-svga-miniprogram', folder: 'CrossPlatform/svga-miniprogram', root: 'engines' },
];

/**
 * The PAG files of the demos: fetched as iOS fetches them (pinned and checked by SHA-256, not kept in the repository)
 * and copied to the engines subpackage as *.pag.bin (a code package leaves out .pag files).
 */
const PAG_SOURCE = path.resolve(ROOT, '..', '..', 'Example-Shared', 'PAGResources', 'pag-ios');
const PAG_TARGET = path.join(ROOT, 'miniprogram', 'engines', 'pag');
const PAG_HINT = 'run python3 scripts/fetch-animation-resources.py PAGResources from the repository root';

/**
 * cyl-animated-item, vendored into the library: the library draws every tag icon (static image or animation) through it
 * and links no animation engine; the app gives the engines through the abstract nodes cyl-lottie-view, cyl-pag-view,
 * cyl-rive-view and cyl-svga-view (GIF is drawn by <image>). Unpublished upstream, so it is taken by commit.
 */
const LIBRARY = path.join(ROOT, 'packages', 'cyl-tag-list-miniprogram', 'miniprogram_dist');
const VENDORED_SOURCE = 'CrossPlatform/wechat-miniprogram-cyltabbar';
// cyl-dealloc-block-executor: required by cyl-animated-item since CYLTabBarController edeb11e6 (the moment bus).
const VENDORED = ['cyl-animated-item', 'cyl-animation-placeholder', 'cyl-dealloc-block-executor'];
const VENDORED_TEST = {
  from: 'test/cyl_animated_item.test.js',
  to: path.join(ROOT, 'test', 'cyl-animated-item.upstream.test.js'),
  rewrite: (text) => text.split("'../src/cyl-animated-item/").join("'../packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-animated-item/"),
};

/** Every vendored file: {target path, expected content}. */
function vendoredFiles() {
  const base = path.join(CHECKOUT, VENDORED_SOURCE);
  const license = fs.readFileSync(path.join(base, 'src', 'LICENSE'));
  const entries = VENDORED.flatMap((folder) => {
    const source = path.join(base, 'src', folder);
    return files(source).filter((file) => file !== 'LICENSE').map((file) => ({ target: path.join(LIBRARY, folder, file), content: fs.readFileSync(path.join(source, file)) }))
      .concat([
        { target: path.join(LIBRARY, folder, 'LICENSE'), content: license },
        { target: path.join(LIBRARY, folder, 'COMMIT'), content: Buffer.from(`${COMMIT}\n`) },
      ]);
  });
  const test = fs.readFileSync(path.join(base, VENDORED_TEST.from), 'utf8');
  return entries.concat([{ target: VENDORED_TEST.to, content: Buffer.from(VENDORED_TEST.rewrite(test)) }]);
}

function vendoredDifferences() {
  const expected = vendoredFiles();
  const stale = expected.filter((entry) => !fs.existsSync(entry.target) || !fs.readFileSync(entry.target).equals(entry.content))
    .map((entry) => entry.target);
  const targets = expected.map((entry) => entry.target);
  const extra = VENDORED.flatMap((folder) => {
    const folderPath = path.join(LIBRARY, folder);
    return fs.existsSync(folderPath) ? files(folderPath).map((file) => path.join(folderPath, file)) : [];
  }).filter((file) => !targets.includes(file));
  return stale.concat(extra).map((file) => path.relative(ROOT, file));
}

function vendor() {
  VENDORED.forEach((folder) => fs.rmSync(path.join(LIBRARY, folder), { recursive: true, force: true }));
  const entries = vendoredFiles();
  entries.forEach((entry) => {
    fs.mkdirSync(path.dirname(entry.target), { recursive: true });
    fs.writeFileSync(entry.target, entry.content);
  });
  console.log(`${VENDORED.join(', ')} at ${COMMIT.slice(0, 8)} -> ${path.relative(ROOT, LIBRARY)} (${entries.length} files)`);
}

function target(pkg) {
  return path.join(ROOT, 'miniprogram', pkg.root || 'cyl_components', pkg.name);
}

function git(...args) {
  return execFileSync('git', ['-C', CHECKOUT, ...args], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'inherit'] }).trim();
}

function checkout() {
  if (!fs.existsSync(path.join(CHECKOUT, '.git'))) {
    fs.mkdirSync(path.dirname(CHECKOUT), { recursive: true });
    execFileSync('git', ['clone', '--filter=blob:none', '--no-checkout', '--sparse', REPOSITORY, CHECKOUT], { stdio: 'inherit' });
  }
  git('sparse-checkout', 'set', ...PACKAGES.map((pkg) => pkg.folder));
  try {
    git('cat-file', '-e', `${COMMIT}^{commit}`);
  } catch (error) {
    git('fetch', '-q', 'origin');
  }
  git('-c', 'advice.detachedHead=false', 'checkout', '-q', COMMIT);
}

function files(folder, prefix = '') {
  return fs.readdirSync(path.join(folder, prefix), { withFileTypes: true })
    .filter((entry) => !entry.name.startsWith('._') && entry.name !== '.DS_Store')
    .flatMap((entry) => {
      const relative = path.join(prefix, entry.name);
      return entry.isDirectory() ? files(folder, relative) : [relative];
    })
    .sort();
}

/** The package's mini program folder: its "miniprogram" field, else miniprogram_dist. */
function sourceFolder(pkg) {
  const packageFolder = path.join(CHECKOUT, pkg.folder);
  const manifest = JSON.parse(fs.readFileSync(path.join(packageFolder, 'package.json'), 'utf8'));
  return path.join(packageFolder, manifest.miniprogram || 'miniprogram_dist');
}

function differences(pkg) {
  const source = sourceFolder(pkg);
  const expected = files(source);
  const actual = fs.existsSync(target(pkg)) ? files(target(pkg)) : [];
  const stale = expected.filter((file) => !actual.includes(file)
    || !fs.readFileSync(path.join(source, file)).equals(fs.readFileSync(path.join(target(pkg), file))));
  const extra = actual.filter((file) => !expected.includes(file) && file !== 'COMMIT');
  return stale.concat(extra).map((file) => `${pkg.name}/${file}`);
}

function pagFiles() {
  return fs.existsSync(PAG_SOURCE) ? fs.readdirSync(PAG_SOURCE).filter((name) => name.endsWith('.pag')).sort() : [];
}

function pagDifferences() {
  const names = pagFiles();
  if (!names.length) return [`the PAG files (${PAG_HINT})`];
  return names.filter((name) => {
    const copy = path.join(PAG_TARGET, `${name}.bin`);
    return !fs.existsSync(copy) || !fs.readFileSync(copy).equals(fs.readFileSync(path.join(PAG_SOURCE, name)));
  }).map((name) => `engines/pag/${name}.bin`);
}

function copyPagFiles() {
  const names = pagFiles();
  if (!names.length) {
    console.warn(`No PAG files: ${PAG_HINT}, then run this again.`);
    return;
  }
  fs.mkdirSync(PAG_TARGET, { recursive: true });
  names.forEach((name) => fs.copyFileSync(path.join(PAG_SOURCE, name), path.join(PAG_TARGET, `${name}.bin`)));
  console.log(`${names.length} PAG files -> ${path.relative(ROOT, PAG_TARGET)}`);
}

function main() {
  const check = process.argv.includes('--check');
  if (check) {
    if (!fs.existsSync(path.join(CHECKOUT, '.git')) || git('rev-parse', 'HEAD') !== COMMIT) {
      console.error(`CYLTabBarController is not checked out at ${COMMIT.slice(0, 8)}: run node scripts/fetch-cyltabbar.js`);
      process.exit(1);
    }
    const stale = PACKAGES.flatMap(differences).concat(vendoredDifferences(), pagDifferences());
    if (stale.length) {
      console.error(`Out of date: ${stale.join(', ')} (run node scripts/fetch-cyltabbar.js)`);
      process.exit(1);
    }
    console.log(`OK: ${PACKAGES.map((pkg) => pkg.name).join(', ')} and the vendored ${VENDORED.join(', ')} at ${COMMIT.slice(0, 8)}, and the PAG files`);
    return;
  }
  checkout();
  PACKAGES.forEach((pkg) => {
    const source = sourceFolder(pkg);
    fs.rmSync(target(pkg), { recursive: true, force: true });
    files(source).forEach((file) => {
      fs.mkdirSync(path.dirname(path.join(target(pkg), file)), { recursive: true });
      fs.copyFileSync(path.join(source, file), path.join(target(pkg), file));
    });
    fs.writeFileSync(path.join(target(pkg), 'COMMIT'), `${COMMIT}\n`);
    console.log(`${pkg.name} at ${git('rev-parse', '--short', 'HEAD')} -> ${path.relative(ROOT, target(pkg))}`);
  });
  vendor();
  copyPagFiles();
}

main();
