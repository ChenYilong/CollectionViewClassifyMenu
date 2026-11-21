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
const COMMIT = '618ac11a2b467666c8783683af29617988377956';

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
  assert.equal(instance.data.view.animationUrl, 'Rive/house.riv#stateMachine=State%20Machine');
  assert.equal(instance.data.view.iconSrc, '/images/house.png');
  instance.playAnimation();
  assert.deepEqual(played, [1]);
});

test('the example\'s engine component follows the engine contract of cyl-animated-item', () => {
  const file = path.join(ROOT, 'components', 'cyl-tag-animation-view', 'cyl-tag-animation-view.js');
  const placeholder = mount(path.join(DIST, 'cyl-animation-placeholder', 'index.js')).definition;
  const { definition } = mount(file);
  ['path', 'loop', 'speed', 'autoplay', 'restingFrame'].forEach((name) => assert.ok(definition.properties[name], name));
  Object.keys(placeholder.methods).forEach((name) => assert.equal(typeof definition.methods[name], 'function', name));

  // An unknown file: `error`, so cyl-animated-item shows the image.
  const missing = mount(file, { path: 'Lottie/missing.json' }).instance;
  missing.load();
  assert.equal(missing.events[0].name, 'error');

  // A Lottie file: loads its data, rests on the selected tag's last frame, then `ready` and autoplay.
  const calls = [];
  const lottie = {
    cyl_animation: () => ({ totalFrames: 31 }),
    cyl_goToAndStop: (frame) => calls.push(['stop', frame]),
    cyl_playFromStart: () => calls.push(['play']),
  };
  const view = mount(file, { path: 'Lottie/tab_home_animate.json', restingFrame: 'last' }, { '#lottie': lottie }).instance;
  view.load();
  assert.equal(view.data.engine, 'lottie');
  assert.ok(view.data.lottieData && view.data.lottieData.layers);
  view.onEngineReady();
  assert.deepEqual(calls, [['stop', 30], ['play']]);
  assert.deepEqual(view.events.map((event) => event.name), ['ready']);

  // Rive: the tag's options go to cyl-rive's path; a resting progress rests there while not selected.
  const progress = [];
  const rive = mount(file, { path: 'Rive/house.riv#stateMachine=State%20Machine&restingProgress=0.5', autoplay: false },
    { '#rive': { cyl_setProgress: (value) => progress.push(value) } }).instance;
  rive.load();
  assert.equal(rive.data.rivePath, '/data/animations/rive/house.riv.bin#stateMachine=State%20Machine');
  rive.onEngineReady();
  assert.deepEqual(progress, [0.5]);
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
    lists.forEach((list) => ['cyl-lottie-view', 'cyl-rive-view', 'cyl-pag-view'].forEach((generic) => {
      assert.ok(list.includes(`generic:${generic}="cyl-tag-animation-view"`), `${page}: ${generic}`);
    }));
    const json = JSON.parse(fs.readFileSync(path.join(ROOT, 'pages', page, `${page}.json`), 'utf8'));
    assert.equal(json.usingComponents['cyl-tag-animation-view'], '/components/cyl-tag-animation-view/cyl-tag-animation-view');
  });
});
