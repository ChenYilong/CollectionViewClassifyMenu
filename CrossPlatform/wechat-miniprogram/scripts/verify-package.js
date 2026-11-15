#!/usr/bin/env node
/**
 * Checks the tag list library (packages/cyl-tag-list-miniprogram) as npm publishes it:
 *
 *   1. `npm pack` writes the tarball to .deps/ (git-ignored);
 *   2. the tarball holds package.json, README.md and every file of miniprogram_dist, and nothing else;
 *   3. `npm install --no-save` installs the tarball into node_modules (a copy, not the file: link), and every installed
 *      file equals its source, so WeChat DevTools' "Build npm" builds miniprogram_npm from what users get.
 *
 *   node scripts/verify-package.js           pack, check and install the tarball
 *   node scripts/verify-package.js --restore afterwards: install the file: link again (npm install)
 */
const { execFileSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const PACKAGE = path.join(ROOT, 'packages', 'cyl-tag-list-miniprogram');
const OUT = path.join(ROOT, '.deps');
const NPM = process.platform === 'win32' ? 'npm.cmd' : 'npm';

function npm(args, cwd) {
  return execFileSync(NPM, args, { cwd, encoding: 'utf8', shell: process.platform === 'win32', stdio: ['ignore', 'pipe', 'inherit'] });
}

function filesUnder(dir, base = dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const full = path.join(dir, entry.name);
    return entry.isDirectory() ? filesUnder(full, base) : [path.relative(base, full).split(path.sep).join('/')];
  });
}

function fail(message) {
  console.error(`verify-package: ${message}`);
  process.exit(1);
}

if (process.argv.includes('--restore')) {
  npm(['install', '--no-audit', '--no-fund'], ROOT);
  console.log('verify-package: node_modules/cyl-tag-list-miniprogram links to packages/ again.');
  process.exit(0);
}

fs.mkdirSync(OUT, { recursive: true });
const [packed] = JSON.parse(npm(['pack', '--json', '--pack-destination', OUT], PACKAGE));
const tarball = path.join(OUT, packed.filename);

const expected = ['package.json', 'README.md', ...filesUnder(path.join(PACKAGE, 'miniprogram_dist')).map((f) => `miniprogram_dist/${f}`)].sort();
const actual = packed.files.map((f) => f.path).sort();
const missing = expected.filter((f) => !actual.includes(f));
const extra = actual.filter((f) => !expected.includes(f));
if (missing.length || extra.length) fail(`tarball differs: missing ${missing.join(', ') || '-'}; extra ${extra.join(', ') || '-'}`);

npm(['install', '--no-save', '--no-audit', '--no-fund', tarball], ROOT);
const installed = path.join(ROOT, 'node_modules', 'cyl-tag-list-miniprogram');
if (fs.lstatSync(installed).isSymbolicLink()) fail('node_modules/cyl-tag-list-miniprogram is still a link');
for (const file of expected) {
  const a = fs.readFileSync(path.join(PACKAGE, file));
  const b = fs.readFileSync(path.join(installed, file));
  if (!a.equals(b)) fail(`installed ${file} differs from its source`);
}
console.log(`verify-package: ${packed.filename}, ${packed.files.length} files, ${packed.size} bytes packed; installed into node_modules.`);
console.log('Now run WeChat DevTools "Build npm" (工具 → 构建 npm); `node scripts/verify-package.js --restore` relinks afterwards.');
