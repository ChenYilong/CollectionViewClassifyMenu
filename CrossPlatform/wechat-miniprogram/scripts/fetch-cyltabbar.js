#!/usr/bin/env node
/**
 * Installs CYLTabBarController's Mini Program packages (not on npm) for the example, as the React Native example
 * installs `react-native-cyltabbar` (`react-native/react-native-cyl-tag-list/scripts/fetch-cyltabbar.sh`):
 *
 *   1. checks out CYLTabBarController at COMMIT into .deps/CYLTabBarController (git-ignored), only the packages' folders;
 *   2. copies each package's mini program folder (its "miniprogram" field, else miniprogram_dist) to
 *      miniprogram/cyl_components/<name>/ (git-ignored).
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
const COMMIT = '117be52cfc28109465d52544820f10cc3f00ba89';
const REPOSITORY = 'https://github.com/ChenYilong/CYLTabBarController.git';
const ROOT = path.resolve(__dirname, '..');
const CHECKOUT = path.join(ROOT, '.deps', 'CYLTabBarController');

/**
 * The packages, by their folder in CYLTabBarController: the tab bar (custom-tab-bar, the search page's category bar),
 * and CYLTabBarController's fork of lottie-miniprogram (cyl-lottie-miniprogram), which draws the base64 image assets
 * of Lottie files that the npm lottie-miniprogram 1.0.12 loads but never draws (its upstream issues #4, #10, #29,
 * #30, #36).
 */
const PACKAGES = [
  { name: 'cyl-tabbar-miniprogram', folder: 'CrossPlatform/wechat-miniprogram-cyltabbar' },
  { name: 'cyl-lottie-miniprogram', folder: 'CrossPlatform/lottie-miniprogram' },
];

function target(pkg) {
  return path.join(ROOT, 'miniprogram', 'cyl_components', pkg.name);
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

function main() {
  const check = process.argv.includes('--check');
  if (check) {
    if (!fs.existsSync(path.join(CHECKOUT, '.git')) || git('rev-parse', 'HEAD') !== COMMIT) {
      console.error(`CYLTabBarController is not checked out at ${COMMIT.slice(0, 8)}: run node scripts/fetch-cyltabbar.js`);
      process.exit(1);
    }
    const stale = PACKAGES.flatMap(differences);
    if (stale.length) {
      console.error(`Out of date: ${stale.join(', ')} (run node scripts/fetch-cyltabbar.js)`);
      process.exit(1);
    }
    console.log(`OK: ${PACKAGES.map((pkg) => pkg.name).join(', ')} at ${COMMIT.slice(0, 8)}`);
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
}

main();
