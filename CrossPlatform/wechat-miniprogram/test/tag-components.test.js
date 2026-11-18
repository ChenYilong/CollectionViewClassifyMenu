// The components and pages of the tag cloud / sample area run in a small stand-in of the Mini Program runtime
// (Component, Page, setData, triggerEvent, selector queries, wx): taps, deletions, long presses, reordering, the
// image tag layout and the pages' handlers (node --test).
const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');
const i18n = require('../miniprogram/utils/i18n.js');

const ROOT = path.join(__dirname, '..', 'miniprogram');
// The tag list library (cyl-tag-list-miniprogram), as WeChat DevTools' Build npm installs it.
const PACKAGE = path.join(__dirname, '..', 'packages', 'cyl-tag-list-miniprogram', 'miniprogram_dist');

/** Sets `path` ("a.b[2].c") in `target`, as setData does. */
function setPath(target, keyPath, value) {
  const parts = keyPath.replace(/\[(\d+)\]/g, '.$1').split('.');
  let node = target;
  for (let i = 0; i < parts.length - 1; i += 1) {
    if (node[parts[i]] == null) node[parts[i]] = /^\d+$/.test(parts[i + 1]) ? [] : {};
    node = node[parts[i]];
  }
  node[parts[parts.length - 1]] = value;
}

/** A stand-in selector query answering boundingClientRect with `rects(selector)`. */
function query(rects) {
  const calls = [];
  const api = {
    in() { return api; },
    select(selector) { return { boundingClientRect(cb) { calls.push([selector, cb, false]); return api; } }; },
    selectAll(selector) { return { boundingClientRect(cb) { calls.push([selector, cb, true]); return api; } }; },
    exec() { calls.splice(0).forEach(([selector, cb]) => cb(rects(selector))); },
  };
  return api;
}

/** Loads a component definition and makes an instance with `properties`. */
function mountComponent(file, properties = {}, rects = () => null) {
  let definition;
  global.Component = (def) => { definition = def; };
  delete require.cache[require.resolve(file)];
  require(file);
  const data = { ...(definition.data || {}) };
  for (const [key, spec] of Object.entries(definition.properties || {})) data[key] = spec.value;
  const events = [];
  const instance = {
    data,
    setData(patch, callback) {
      const changed = Object.keys(patch);
      for (const [key, value] of Object.entries(patch)) setPath(this.data, key, value);
      for (const [names, observer] of Object.entries(definition.observers || {})) {
        const keys = names.split(',').map((name) => name.trim());
        if (keys.some((key) => changed.includes(key) && key in (definition.properties || {}))) {
          observer.apply(this, keys.map((key) => this.data[key]));
        }
      }
      if (callback) callback();
    },
    triggerEvent(name, detail) { events.push({ name, detail }); },
    createSelectorQuery() { return query(rects); },
    events,
    ...definition.methods,
  };
  if (definition.lifetimes && definition.lifetimes.created) definition.lifetimes.created.call(instance);
  if (definition.lifetimes && definition.lifetimes.attached) definition.lifetimes.attached.call(instance);
  instance.setData(properties);
  if (definition.lifetimes && definition.lifetimes.ready) definition.lifetimes.ready.call(instance);
  return instance;
}

function tap(index, extra = {}) {
  return { currentTarget: { dataset: { index, ...extra } }, touches: [{ clientX: 10, clientY: 10 }] };
}

test('cyl-tag-cloud: taps, deletions and the tag methods', () => {
  i18n.setLanguage('zh_CN');
  const model = require('cyl-tag-list-miniprogram/cyl-tag-cloud/model.js');
  const list = mountComponent(path.join(PACKAGE, 'cyl-tag-cloud/cyl-tag-cloud.js'), {
    tags: [model.makeTag('A'), model.makeTag('B', { isDeletable: true }), model.makeTag('C')],
    listStyle: model.tagCloudStyle(),
  });
  assert.equal(list.data.items.length, 3);
  assert.equal(list.data.deleteLabel, '删除');
  list.onTap(tap(2));
  assert.deepEqual(list.events.pop(), { name: 'tagtap', detail: { position: 2, tag: { identifier: 0, title: 'C', isEnabled: true, isDeletable: false } } });
  list.onDelete(tap(1));
  assert.equal(list.events.pop().name, 'tagdelete');
  assert.deepEqual(list.getTags().map((tag) => tag.title), ['A', 'C']);
  list.addTag(model.makeTag('D'));
  list.insertTag(model.makeTag('Z'), 0);
  assert.deepEqual(list.getTags().map((tag) => tag.title), ['Z', 'A', 'C', 'D']);
  list.removeTag(9);
  list.removeTag(0);
  assert.equal(list.data.items.length, 3);
  // Not tappable: no event.
  list.setData({ allowsTapping: false });
  list.onTap(tap(0));
  assert.notEqual(list.events[list.events.length - 1].name, 'tagtap');
});

test('cyl-tag-cloud: a long press selects (in none mode) or reorders, and reports when it did not move', () => {
  const model = require('cyl-tag-list-miniprogram/cyl-tag-cloud/model.js');
  const rects = [0, 1, 2].map((i) => ({ left: i * 100, right: i * 100 + 90, top: 0, bottom: 30, width: 90, height: 30 }));
  const list = mountComponent(path.join(PACKAGE, 'cyl-tag-cloud/cyl-tag-cloud.js'), {
    tags: ['a', 'b', 'c'].map((title) => model.makeTag(title)),
    listStyle: model.tagContainerStyle(),
    allowsReordering: true,
  }, (selector) => (selector === '.cyl-tc-item' ? rects : rects[0]));
  list.onTouchStart(tap(0));
  list.onLongPress(tap(0));
  assert.equal(list.events.pop().name, 'reorderingchange');
  list.onTouchMove({ touches: [{ clientX: 250, clientY: 10 }] });
  assert.deepEqual(list.getTags().map((tag) => tag.title), ['b', 'c', 'a']);
  list.onTouchEnd();
  const names = list.events.map((event) => event.name);
  assert.ok(names.includes('tagmove'));
  assert.deepEqual(list.events.find((event) => event.name === 'tagmove').detail, { from: 0, to: 2 });
  assert.ok(!names.includes('taglongpress'));
  // Without moving: a long press.
  list.events.length = 0;
  list.onLongPress(tap(1));
  list.onTouchEnd();
  assert.deepEqual(list.events.pop(), { name: 'taglongpress', detail: { position: 1, tag: { identifier: 0, title: 'c', isEnabled: true, isDeletable: false } } });
  // The third container: toggleSelection and deselectAll.
  list.toggleSelection(2);
  list.toggleSelection(0);
  assert.deepEqual(list.selectedIndexes(), [0, 2]);
  list.deselectAll();
  assert.deepEqual(list.selectedIndexes(), []);
});

test('cyl-tag-image: measures, lays out, turns tags while editing, drags and toggles', async () => {
  const model = require('cyl-tag-list-miniprogram/cyl-tag-image/model.js');
  const data = require('../miniprogram/pages/sample-image-tag/data.js');
  data.reset();
  const view = mountComponent(path.join(PACKAGE, 'cyl-tag-image/cyl-tag-image.js'), {
    tagGroups: data.getTagGroups(),
    image: '/images/samples/picture-0.jpg',
  }, (selector) => {
    if (selector === '.cyl-it') return { left: 0, top: 0, width: 375, height: 375 };
    if (selector === '.cyl-it-measure-label') return [80, 160, 120, 90].map((width) => ({ width, height: 23 }));
    return null;
  });
  assert.equal(view.data.groups.length, 2);
  assert.equal(view.data.groups[0].tags.length, 3);
  assert.equal(view.data.groups[0].label, '标签组：头层牛皮、英伦加绒青年棕色保暖鞋子。和PLAYBOY/花花公子');
  assert.ok(view.data.groups[0].lines.length >= 5);
  assert.ok(view.data.groups[0].ripple, 'a ripple when not editing');
  view.onTagTap({ currentTarget: { dataset: { group: 0, tag: 0 } } });
  assert.equal(view.events.pop().detail.tag.direction, 'rightTop', 'no turn when not editing');
  view.setData({ editing: true });
  assert.equal(view.data.groups[0].ripple, '');
  view.onTagTap({ currentTarget: { dataset: { group: 0, tag: 0 } } });
  assert.equal(view.events.pop().detail.tag.direction, 'rightTopStraight');
  view.onTouchStart({ currentTarget: { dataset: { group: 1 } }, touches: [{ clientX: 112.5, clientY: 75 }] });
  view.onTouchMove({ touches: [{ clientX: 187.5, clientY: 187.5 }] });
  const drag = view.events.pop();
  assert.equal(drag.name, 'drag');
  assert.equal(drag.detail.index, 1);
  view.addTagGroup(model.makeGroup([model.makeTag('new', 'rightCenter')], { x: 0.5, y: 0.5 }));
  assert.equal(view.getTagGroups().length, 3);
  view.removeTagGroup(0);
  assert.equal(view.getTagGroups().length, 2);
  view.toggleTagGroups(false);
  assert.ok(view.data.groups.every((group) => group.hidden));
  view.toggleTagGroups(true);
  await new Promise((resolve) => setTimeout(resolve, model.SHOW_DURATION + 100));
  assert.ok(view.data.groups.every((group) => !group.hidden));
  assert.match(view.data.groups[0].tags[0].style, /opacity: 1/);
});

/** Loads a page with a stand-in `wx`; returns the page instance after onLoad. */
function loadPage(name, components = {}) {
  let definition;
  const calls = [];
  global.Page = (def) => { definition = def; };
  global.wx = new Proxy({}, {
    get: (target, key) => (key in target ? target[key] : (...args) => { calls.push([key, ...args]); return {}; }),
  });
  global.wx.getWindowInfo = () => ({ statusBarHeight: 20 });
  global.wx.getMenuButtonBoundingClientRect = () => ({ bottom: 56 });
  const file = path.join(ROOT, 'pages', name, `${name}.js`);
  delete require.cache[require.resolve(file)];
  require(file);
  const page = {
    ...definition,
    data: JSON.parse(JSON.stringify(definition.data || {})),
    setData(patch) { for (const [key, value] of Object.entries(patch)) setPath(this.data, key, value); },
    selectComponent: (selector) => components[selector],
    getOpenerEventChannel: () => ({ emit: (event) => calls.push(['emit', event]) }),
    calls,
  };
  if (page.onLoad) page.onLoad({});
  if (page.onShow) page.onShow();
  return page;
}

test('the pages load with their titles and react as the iOS screens', () => {
  i18n.setLanguage('zh_CN');
  const toasts = [];
  const toast = { show: (text) => toasts.push(text) };
  const tagCloud = loadPage('tag-cloud');
  assert.deepEqual(tagCloud.calls[0], ['setNavigationBarTitle', { title: '标签云（android-tagview）' }]);
  tagCloud.onCodeTap({ detail: { position: 0, tag: { title: 'Asia' } } });
  assert.equal(tagCloud.data.event, '点击第 0 个「Asia」');

  const added = [];
  const list = { addTag: (tag) => added.push(tag), getTags: () => new Array(25) };
  const cloud = loadPage('sample-tag-cloud', { '#toast': toast, '#tag-list': list });
  cloud.onTagTap({ detail: { position: 3, tag: { identifier: 3 } } });
  assert.equal(toasts.pop(), '点击标签 id = 3，位置 = 3');
  cloud.random = () => 0;
  cloud.addTag();
  assert.equal(added.pop().identifier, 25);
  cloud.openActivityResult();
  const navigate = cloud.calls.find((call) => call[0] === 'navigateTo');
  navigate[1].events.result();
  assert.equal(added.pop().title, '返回结果后添加');

  const sub = loadPage('sample-tag-cloud-sub');
  sub.finish();
  assert.ok(sub.calls.some((call) => call[0] === 'emit' && call[1] === 'result'));
  assert.equal(loadPage('sample-tag-cloud-list').data.rows.length, 51);
  assert.equal(loadPage('sample-tag-cloud-recycler').data.texts.length, 21);
  const hot = loadPage('sample-tag-cloud-hot-search', { '#toast': toast });
  assert.equal(hot.data.top, 60);
  hot.onTagTap({ detail: { tag: { title: '他和她' } } });
  assert.equal(hot.data.text, '他和她');
  assert.equal(toasts.pop(), '搜索「他和她」');

  const image = loadPage('sample-image-tag', { '#toast': toast });
  assert.equal(image.data.groups.length, 2);
  image.onTagTap({ detail: { tag: { title: '头层牛皮' } } });
  assert.equal(toasts.pop(), '点击标签：头层牛皮');
  const groups = [];
  const tagImage = { addTagGroup: (group) => groups.push(group), getTagGroups: () => groups };
  const edit = loadPage('sample-image-tag-edit', { '#toast': toast, '#tag-image': tagImage });
  edit.showCreateDialog();
  assert.equal(edit.data.dialog.fields[2].placeholder, '标签 3');
  edit.onDialogInput({ currentTarget: { dataset: { index: 1 } }, detail: { value: '鞋' } });
  edit.onDialogConfirm();
  assert.equal(groups[0].tags[0].title, '鞋');
  edit.save();
  assert.equal(require('../miniprogram/pages/sample-image-tag/data.js').getTagGroups().length, 1);
  require('../miniprogram/pages/sample-image-tag/data.js').reset();
  assert.equal(loadPage('sample-image-tag-list').data.rows.length, 30);

  let selection = [1];
  const third = {
    selectedIndexes: () => selection,
    deselectAll: () => { selection = []; },
    toggleSelection: (i) => { selection = selection.includes(i) ? selection.filter((x) => x !== i) : selection.concat(i); },
  };
  const container = loadPage('sample-tag-container', { '#toast': toast, '#container-2': third });
  assert.equal(container.data.containers.length, 6);
  assert.equal(container.data.containers[5].style.deleteIndicatorImage, "/images/samples/cross.png");
  container.onThirdTap({ detail: { position: 0, tag: { title: 'Persian' } } });
  assert.deepEqual(selection, [], 'an unselected tag while others are selected deselects all');
  container.onThirdTap({ detail: { position: 0, tag: { title: 'Persian' } } });
  assert.equal(toasts.pop(), '点击位置：0，文字：Persian');
  container.onThirdLongPress({ detail: { position: 2 } });
  container.onThirdLongPress({ detail: { position: 4 } });
  assert.equal(toasts.pop(), '已选位置：2, 4');
  container.onFirstDelete({ detail: { position: 3 } });
  assert.equal(toasts.pop(), '点了标签的叉！位置 = 3');
  delete global.wx;
  delete global.Page;
  delete global.Component;
});
