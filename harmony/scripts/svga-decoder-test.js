// Checks the example's SVGA decoder (CYLInflate.ets, CYLSVGAMovie.ets: plain TypeScript logic) without a device:
// transpiles both with TypeScript, inflates every example .svga file and compares the result with Node's zlib, then
// checks the decoded movies (frames per sprite, image keys, PNG bitmaps) and stored / fixed-Huffman deflate blocks.
// Usage: node harmony/scripts/svga-decoder-test.js [path to the typescript package]
// (scripts/svga-decoder-test.sh finds DevEco Studio's node and typescript).
const fs = require('fs');
const path = require('path');
const zlib = require('zlib');
const ts = require(process.argv[2] || 'typescript');
const root = path.resolve(__dirname, '..');
const dir = path.join(root, 'entry/src/main/ets/animation/svga');
const samples = path.join(root, 'entry/src/main/resources/rawfile/svga');
const out = fs.mkdtempSync(path.join(require('os').tmpdir(), 'cyl-svga-'));
fs.mkdirSync(out, { recursive: true });
for (const name of ['CYLInflate', 'CYLSVGAMovie']) {
  const src = fs.readFileSync(path.join(dir, name + '.ets'), 'utf8');
  const js = ts.transpileModule(src, { compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2020 } }).outputText;
  fs.writeFileSync(path.join(out, name + '.js'), js);
}
const { cylInflateZlib } = require(path.join(out, 'CYLInflate.js'));
const { CYLSVGAMovie } = require(path.join(out, 'CYLSVGAMovie.js'));
let failures = 0;
for (const f of fs.readdirSync(samples).filter(n => n.endsWith('.svga'))) {
  const file = new Uint8Array(fs.readFileSync(path.join(samples, f)));
  const ours = cylInflateZlib(file);
  const ref = zlib.inflateSync(Buffer.from(file));
  const same = Buffer.compare(Buffer.from(ours), ref) === 0;
  const m = CYLSVGAMovie.decode(file);
  const visible = m.sprites.reduce((n, s) => n + s.frames.filter(fr => fr.alpha > 0).length, 0);
  const pngs = [...m.images.values()].every(b => b[0] === 0x89 && b[1] === 0x50);
  const keysOk = m.sprites.every(s => m.images.has(s.imageKey));
  const framesOk = m.sprites.every(s => s.frames.length === m.frames);
  console.log(`${f}: inflate ${same ? 'OK' : 'DIFFERS'}, version ${m.version}, ${m.viewBoxWidth}x${m.viewBoxHeight}, ` +
    `${m.frames} frames at ${m.fps} fps, ${m.sprites.length} sprites, ${m.images.size} images, ${visible} visible ` +
    `sprite frames, png ${pngs}, keys ${keysOk}, frames per sprite ${framesOk}`);
  if (!same || !pngs || !keysOk || !framesOk) failures++;
}
// Stored and fixed-Huffman blocks too (the sample files use dynamic blocks).
for (const level of [0, 1]) {
  const data = Buffer.from('CYLClassifyMenu SVGA '.repeat(500));
  const z = zlib.deflateSync(data, { level, strategy: level === 1 ? zlib.constants.Z_FIXED : 0 });
  const ok = Buffer.compare(Buffer.from(cylInflateZlib(new Uint8Array(z))), data) === 0;
  console.log(`deflate level ${level}: ${ok ? 'OK' : 'DIFFERS'}`);
  if (!ok) failures++;
}
console.log(failures === 0 ? 'OK: SVGA decoder' : `FAILED: ${failures}`);
process.exit(failures);
