#!/usr/bin/env node
/**
 * Installs CYLTabBarController's Mini Program packages (not on npm) for the example, as the React Native example
 * installs `react-native-cyltabbar` (`react-native/react-native-cyl-tag-list/scripts/fetch-cyltabbar.sh`):
 *
 *   1. checks out CYLTabBarController at COMMIT into .deps/CYLTabBarController (git-ignored), only the packages' folders;
 *   2. copies each package's mini program folder (its "miniprogram" field, else miniprogram_dist) to
 *      miniprogram/cyl_components/<name>/, or miniprogram/<root>/<name>/ for a subpackage (git-ignored);
 *   3. copies the PAG files of the demos (fetched by scripts/fetch-animation-resources.py PAGResources) to
 *      miniprogram/engines/pag/*.pag.bin (git-ignored).
 *
 * The packages are copied outside miniprogram_npm because WeChat DevTools' "Build npm" rewrites that folder.
 *
 *   node scripts/fetch-cyltabbar.js           install
 *   node scripts/fetch-cyltabbar.js --check   exit 1 when an installed copy differs from the pinned commit
 */
const { execFileSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// CYL_TAB_BAR: the same commit as the React Native example (fetch-cyltabbar.sh, example/ios/Podfile).
const COMMIT = '0a63bed5aab7d65551d7ef1f0c4f1708b541ddf7';
const REPOSITORY = 'https://github.com/ChenYilong/CYLTabBarController.git';
const ROOT = path.resolve(__dirname, '..');
const CHECKOUT = path.join(ROOT, '.deps', 'CYLTabBarController');

/**
 * The packages, by their folder in CYLTabBarController: the tab bar (custom-tab-bar, the search page's category bar),
 * CYLTabBarController's fork of lottie-miniprogram (cyl-lottie-miniprogram, which draws the base64 image assets the npm
 * lottie-miniprogram 1.0.12 never drew), cyl-rive (the Rive runtime and its 573 KB WebAssembly), and cyl-pag (libpag
 * 4.5.85, about 0.96 MB with its WebAssembly), which does not fit the 2 MB main package next to Rive: it goes to the
 * "engines" subpackage, which the icon component loads asynchronously (componentPlaceholder).
 */
const PACKAGES = [
  { name: 'cyl-tabbar-miniprogram', folder: 'CrossPlatform/wechat-miniprogram-cyltabbar' },
  { name: 'cyl-lottie-miniprogram', folder: 'CrossPlatform/lottie-miniprogram' },
  { name: 'cyl-rive-miniprogram', folder: 'CrossPlatform/rive-miniprogram' },
  { name: 'cyl-pag-miniprogram', folder: 'CrossPlatform/pag-miniprogram', root: 'engines' },
];

/**
 * The PAG files of the demos: fetched as iOS fetches them (pinned and checked by SHA-256, not kept in the repository)
 * and copied to the engines subpackage as *.pag.bin (a code package leaves out .pag files).
 */
const PAG_SOURCE = path.resolve(ROOT, '..', '..', 'Example-Shared', 'PAGResources', 'pag-ios');
const PAG_TARGET = path.join(ROOT, 'miniprogram', 'engines', 'pag');
const PAG_HINT = 'run python3 scripts/fetch-animation-resources.py PAGResources from the repository root';

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
    const stale = PACKAGES.flatMap(differences).concat(pagDifferences());
    if (stale.length) {
      console.error(`Out of date: ${stale.join(', ')} (run node scripts/fetch-cyltabbar.js)`);
      process.exit(1);
    }
    console.log(`OK: ${PACKAGES.map((pkg) => pkg.name).join(', ')} at ${COMMIT.slice(0, 8)}, and the PAG files`);
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
  copyPagFiles();
}

main();
