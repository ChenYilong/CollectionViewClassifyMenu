#!/usr/bin/env node
/**
 * Installs CYLTabBarController's Mini Program tab bar (`cyl-tabbar-miniprogram`, CYLTabBarController's
 * `CrossPlatform/wechat-miniprogram-cyltabbar`, not on npm) for the example's custom tab bar, as the React Native
 * example installs `react-native-cyltabbar` (`react-native/react-native-cyl-tag-list/scripts/fetch-cyltabbar.sh`):
 *
 *   1. checks out CYLTabBarController at COMMIT into .deps/CYLTabBarController (git-ignored), only the component's folder;
 *   2. copies the package's mini program folder (its "miniprogram" field: src/) to
 *      miniprogram/cyl_components/cyl-tabbar-miniprogram/ (git-ignored), which custom-tab-bar/index.json names.
 *
 * The component is copied outside miniprogram_npm because WeChat DevTools' "Build npm" rewrites that folder.
 *
 *   node scripts/fetch-cyltabbar.js           install
 *   node scripts/fetch-cyltabbar.js --check   exit 1 when the installed copy differs from the pinned commit
 */
const { execFileSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// CYL_TAB_BAR: the same commit as the React Native example (fetch-cyltabbar.sh, example/ios/Podfile).
const COMMIT = '460ed89f192db37d5b347cf72b5ee63ecdc11854';
const REPOSITORY = 'https://github.com/ChenYilong/CYLTabBarController.git';
const PACKAGE = 'CrossPlatform/wechat-miniprogram-cyltabbar';
const ROOT = path.resolve(__dirname, '..');
const CHECKOUT = path.join(ROOT, '.deps', 'CYLTabBarController');
const TARGET = path.join(ROOT, 'miniprogram', 'cyl_components', 'cyl-tabbar-miniprogram');

function git(...args) {
  return execFileSync('git', ['-C', CHECKOUT, ...args], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'inherit'] }).trim();
}

function checkout() {
  if (!fs.existsSync(path.join(CHECKOUT, '.git'))) {
    fs.mkdirSync(path.dirname(CHECKOUT), { recursive: true });
    execFileSync('git', ['clone', '--filter=blob:none', '--no-checkout', '--sparse', REPOSITORY, CHECKOUT], { stdio: 'inherit' });
  }
  git('sparse-checkout', 'set', PACKAGE);
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

function sourceFolder() {
  const packageFolder = path.join(CHECKOUT, PACKAGE);
  const manifest = JSON.parse(fs.readFileSync(path.join(packageFolder, 'package.json'), 'utf8'));
  return path.join(packageFolder, manifest.miniprogram || 'miniprogram_dist');
}

function differences(source) {
  const expected = files(source);
  const actual = fs.existsSync(TARGET) ? files(TARGET) : [];
  const stale = expected.filter((file) => !actual.includes(file)
    || !fs.readFileSync(path.join(source, file)).equals(fs.readFileSync(path.join(TARGET, file))));
  const extra = actual.filter((file) => !expected.includes(file) && file !== 'COMMIT');
  return stale.concat(extra);
}

function main() {
  const check = process.argv.includes('--check');
  if (check) {
    if (!fs.existsSync(path.join(CHECKOUT, '.git')) || git('rev-parse', 'HEAD') !== COMMIT) {
      console.error(`cyl-tabbar-miniprogram is not checked out at ${COMMIT.slice(0, 8)}: run node scripts/fetch-cyltabbar.js`);
      process.exit(1);
    }
    const stale = differences(sourceFolder());
    if (stale.length) {
      console.error(`Out of date: ${stale.join(', ')} (run node scripts/fetch-cyltabbar.js)`);
      process.exit(1);
    }
    console.log(`OK: cyl-tabbar-miniprogram at ${COMMIT.slice(0, 8)}`);
    return;
  }
  checkout();
  const source = sourceFolder();
  fs.rmSync(TARGET, { recursive: true, force: true });
  files(source).forEach((file) => {
    fs.mkdirSync(path.dirname(path.join(TARGET, file)), { recursive: true });
    fs.copyFileSync(path.join(source, file), path.join(TARGET, file));
  });
  fs.writeFileSync(path.join(TARGET, 'COMMIT'), `${COMMIT}\n`);
  console.log(`cyl-tabbar-miniprogram at ${git('rev-parse', '--short', 'HEAD')} -> ${path.relative(ROOT, TARGET)}`);
}

main();
