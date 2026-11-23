// Tag icons on CYLTabBarController's cyl-animated-item (vendored in the library at the pinned commit): the library
// declares the engines as forwarded abstract nodes and links none, cyl-tag-list and cyl-tag-button hand each icon to
// cyl-animated-item and play it through the engine contract, and the example's engine component follows that contract
// (node --test, with a small stand-in of the Mini Program runtime).
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const PACKAGE = path.join(__dirname, '..', 'packages', 'cyl-tag-list-miniprogram');
const DIST = path.join(PACKAGE, 'miniprogram_dist');
const ROOT = path.join(__dirname, '..', 'miniprogram');
// Components that share the registry with the example are loaded as the example loads the package (npm link or tarball).
const INSTALLED = path.dirname(require.resolve('cyl-tag-list-miniprogram/cyl-tag-list/model.js'));
const installed = (file) => path.join(path.dirname(INSTALLED), file);
const GENERICS = ['cyl-lottie-view', 'cyl-pag-view', 'cyl-rive-view', 'cyl-svga-view'];
const COMMIT = 'b3c87fd1b10ca0fe571f6622a2f834baa2030664';

// The example's files are registered with the library, as app.js does.
require('../miniprogram/utils/tag-animations.js');

/** Loads a component definition and makes an instance; `children` answers selectComponent. */
function mount(file, properties = {}, children = {}) {
  let definition;
  global.Component = (def) => { definition = def; };
  global.wx = { nextTick: (callback) => callback(), getWindowInfo: () => ({ pixelRatio: 2 }) };
  delete require.cache[require.resolve(file)];
  require(file);
  const data = { ...(definition.data || {}) };
  for (const [name, spec] of Object.entries(definition.properties || {})) data[name] = spec.value;
  const events = [];
  const patches = [];
  const instance = {
    data,
    setData(patch, callback) {
      patches.push(patch);
      Object.entries(patch).forEach(([keyPath, value]) => {
        const parts = keyPath.replace(/\[(\d+)\]/g, '.$1').split('.');
        let node = this.data;
        parts.slice(0, -1).forEach((part) => { node = node[part]; });
        node[parts[parts.length - 1]] = value;
      });
      if (callback) callback();
    },
    triggerEvent(name, detail) { events.push({ name, detail }); },
    selectComponent(selector) { return children[selector] || null; },
    createSelectorQuery() {
      const api = { select: () => ({ boundingClientRect: () => api }), selectAll: () => ({ boundingClientRect: () => api }), exec: () => {} };
      return api;
    },
    events,
    patches,
    ...definition.methods,
  };
  if (definition.lifetimes && definition.lifetimes.attached) definition.lifetimes.attached.call(instance);
  Object.assign(instance.data, properties);
  return { instance, definition };
}

test('the library ships cyl-animated-item at the pinned commit, with its license, and links no animation engine', () => {
  ['cyl-animated-item', 'cyl-animation-placeholder'].forEach((folder) => {
    assert.equal(fs.readFileSync(path.join(DIST, folder, 'COMMIT'), 'utf8').trim(), COMMIT);
    assert.match(fs.readFileSync(path.join(DIST, folder, 'LICENSE'), 'utf8'), /CYLTabBarController/);
  });
  const manifest = JSON.parse(fs.readFileSync(path.join(PACKAGE, 'package.json'), 'utf8'));
  assert.equal(manifest.dependencies, undefined, 'no dependency at all, so none on Lottie or another engine');
  assert.equal(manifest.peerDependencies, undefined);
  const sources = fs.readdirSync(DIST, { recursive: true }).filter((file) => /\.(js|json)$/.test(file))
    .filter((file) => !file.startsWith('cyl-animated-item') && !file.startsWith('cyl-animation-placeholder'));
  sources.forEach((file) => {
    const text = fs.readFileSync(path.join(DIST, file), 'utf8');
    assert.doesNotMatch(text, /lottie-miniprogram|cyl-lottie\/|cyl-rive\/|cyl-pag\/|libpag|rive\.wasm/, file);
  });
  assert.equal(fs.existsSync(path.join(DIST, 'cyl-animation-icon')), false, 'the old icon slot is gone');
});

test('cyl-tag-list and cyl-tag-button use cyl-animated-item and forward its four engine nodes', () => {
  ['cyl-tag-list', 'cyl-tag-button'].forEach((name) => {
    const json = JSON.parse(fs.readFileSync(path.join(DIST, name, `${name}.json`), 'utf8'));
    assert.equal(json.usingComponents['cyl-animated-item'], '../cyl-animated-item/index');
    assert.deepEqual(Object.keys(json.componentGenerics).sort(), GENERICS.slice().sort());
    Object.values(json.componentGenerics).forEach((generic) => assert.equal(generic.default, '../cyl-animation-placeholder/index'));
    const wxml = fs.readFileSync(path.join(DIST, name, `${name}.wxml`), 'utf8');
    GENERICS.forEach((generic) => assert.ok(wxml.includes(`generic:${generic}="${generic}"`), `${name} forwards ${generic}`));
    assert.match(wxml, /<cyl-animated-item [^>]*animation-url=/);
    assert.match(wxml, /aria-hidden="true">\s*<cyl-animated-item/, 'the icon is decorative: the tag carries the label');
  });
});

test('cyl-tag-list: view data for cyl-animated-item, a tap and Play all play through its playAnimation()', () => {
  const played = [];
  // cyl-animated-item's playAnimation() plays the engine from progress 0 or the GIF from its first frame (its own tests).
  const lottieItem = { data: { animationUrl: 'Lottie/tab_home_animate.json' }, playAnimation: () => played.push('lottie') };
  const gifItem = { data: { animationUrl: '/data/animations/gif/tab_star.gif' }, playAnimation: () => played.push('gif') };
  const { instance } = mount(installed('cyl-tag-list/cyl-tag-list.js'), {
    configuration: {
      selectionMode: 'single',
      sections: [{ title: 'A', items: [
        { title: 'Home', image: '/images/home.png', animation: 'CYLMenuExample.bundle/Animations/Lottie/tab_home_animate.json' },
        { title: 'Star', animation: '../Animations/GIF/tab_star.gif' },
        { title: 'Plain', image: '/images/plain.png' },
        { title: 'Missing', image: '/images/m.png', animation: 'GIF/missing.gif' },
      ] }],
    },
  }, { '#anim-0-0': lottieItem, '#anim-0-1': gifItem });
  instance.rebuild();
  const items = instance.data.sections[0].items;
  assert.equal(items[0].iconKind, 'animation');
  assert.equal(items[0].animationUrl, 'Lottie/tab_home_animate.json');
  assert.equal(items[0].iconSrc, '/images/home.png', 'the static image shows until the engine is ready');
  assert.equal(items[1].animationUrl, '/data/animations/gif/tab_star.gif');
  assert.deepEqual([items[2].iconKind, items[2].animationUrl, items[2].iconSrc], ['image', '', '/images/plain.png']);
  assert.deepEqual([items[3].iconKind, items[3].animationUrl], ['image', ''], 'no file: the image');
  assert.ok(items[0].iconSize > 0);

  instance.onItemTap({ currentTarget: { dataset: { key: '0-0' } } });
  assert.deepEqual(played, ['lottie']);
  assert.equal(instance.events.find((event) => event.name === 'tagtap').detail.title, 'Home');

  instance.playAll();
  assert.deepEqual(played, ['lottie', 'lottie', 'gif'], 'Play all plays the GIF too (one pass when it has stills)');
});

test('cyl-tag-button: the icon through cyl-animated-item and playAnimation through its playAnimation()', () => {
  const played = [];
  const { instance } = mount(installed('cyl-tag-button/cyl-tag-button.js'), {
    title: 'House', image: '/images/house.png', animationURL: 'CYLMenuExample.bundle/Animations/Rive/house.riv',
    animationOptions: { stateMachine: 'State Machine' },
  }, { '#cyl-tag-button-animation': { playAnimation: () => played.push(1) } });
  instance.render();
  assert.equal(instance.data.view.animationUrl, '/data/animations/rive/house.riv.bin#stateMachine=State%20Machine');
  assert.equal(instance.data.view.iconSrc, '/images/house.png');
  instance.playAnimation();
  assert.deepEqual(played, [1]);
});

test('the engines are bound directly: the library gives cyl-animated-item the file, the Lottie data and the WebAssembly paths', () => {
  const animations = require('cyl-tag-list-miniprogram/cyl-tag-list/animations.js');
  require('../miniprogram/utils/tag-animations.js');
  // Lottie: the registered key is the path and the JSON comes as animation-data.
  assert.equal(animations.url('Lottie/tab_home_animate.json'), 'Lottie/tab_home_animate.json');
  assert.ok(animations.data('Lottie/tab_home_animate.json').layers);
  // Rive, with the tag's options and a resting progress after "#": the registered src.
  assert.equal(animations.url('Rive/house.riv', { stateMachine: 'State Machine' }, 0.5),
    '/data/animations/rive/house.riv.bin#stateMachine=State%20Machine&restingProgress=0.5');
  assert.equal(animations.data('Rive/house.riv'), null);
  assert.equal(animations.url('Nothing/missing.json'), '');
  assert.deepEqual(animations.wasm(), {
    riveWasmPath: '/cyl_components/cyl-rive-miniprogram/rive/rive.wasm.br',
    pagWasmPath: '/engines/cyl-pag-miniprogram/libpag/libpag.wasm.br',
  });
  assert.equal(fs.existsSync(path.join(ROOT, 'components', 'cyl-tag-animation-view')), false, 'the example own engine component is gone');
  // What stays is the stand-in for the PAG and SVGA engines of the async subpackage, with the engine contract of the placeholder.
  const file = path.join(ROOT, 'components', 'cyl-async-engine-view', 'cyl-async-engine-view.js');
  const placeholder = mount(path.join(DIST, 'cyl-animation-placeholder', 'index.js')).definition;
  const { definition } = mount(file);
  ['path', 'loop', 'speed', 'autoplay', 'restingFrame', 'wasmPath'].forEach((name) => assert.ok(definition.properties[name], name));
  Object.keys(placeholder.methods).forEach((name) => assert.equal(typeof definition.methods[name], 'function', name));
  const svga = mount(file, { path: '/engines/svga/tab_home.svga.bin' }).instance;
  svga.load();
  assert.equal(svga.data.engine, 'svga');
  const pag = mount(file, { path: '/engines/pag/tab_home.pag.bin#restingProgress=0.5' }, { '#engine': { cyl_setProgress: (value) => pag.progress = value } }).instance;
  pag.load();
  assert.equal(pag.data.engine, 'pag');
  pag.onEngineReady();
  assert.equal(pag.progress, 0.5);
  const other = mount(file, { path: 'Lottie/x.json' }).instance;
  other.load();
  assert.equal(other.events[0].name, 'error');
});


test('every page that shows a tag list gives it the example\'s engines as the abstract nodes', () => {
  const pages = fs.readdirSync(path.join(ROOT, 'pages'));
  const users = pages.filter((page) => {
    const wxml = path.join(ROOT, 'pages', page, `${page}.wxml`);
    return fs.existsSync(wxml) && fs.readFileSync(wxml, 'utf8').includes('<cyl-tag-list');
  });
  assert.ok(users.length >= 6);
  users.forEach((page) => {
    const wxml = fs.readFileSync(path.join(ROOT, 'pages', page, `${page}.wxml`), 'utf8');
    const lists = wxml.match(/<cyl-tag-list[^>]*>/g);
    lists.forEach((list) => [['cyl-lottie-view', 'cyl-lottie'], ['cyl-rive-view', 'cyl-rive'], ['cyl-pag-view', 'cyl-async-engine-view'], ['cyl-svga-view', 'cyl-async-engine-view']].forEach(([generic, engine]) => {
      assert.ok(list.includes(`generic:${generic}="${engine}"`), `${page}: ${generic}`);
    }));
    const json = JSON.parse(fs.readFileSync(path.join(ROOT, 'pages', page, `${page}.json`), 'utf8'));
    ['cyl-lottie', 'cyl-rive', 'cyl-async-engine-view'].forEach((name) => assert.ok(json.usingComponents[name], `${page}: ${name}`));
    assert.equal(json.usingComponents['cyl-tag-animation-view'], undefined);
  });
});
