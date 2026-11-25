/**
 * cyl-tag-list's flat tags: renaming in editing mode, item ids and the header clear button (iOS 990cf115, cea04255, 3af1b7cd;
 * Android CYLTagListRenamingTest; HarmonyOS TagListEditing.test.ets), in a small stand-in of the Mini Program runtime.
 */
const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');
const i18n = require('../miniprogram/utils/i18n.js');

const PACKAGE = path.join(__dirname, '..', 'packages', 'cyl-tag-list-miniprogram', 'miniprogram_dist');
const model = require(path.join(PACKAGE, 'cyl-tag-list/tag-model.js'));
const { CYLTagListStore, loadItems } = require(path.join(PACKAGE, 'cyl-tag-list/cache.js'));
const { iconImage, base64 } = require(path.join(PACKAGE, 'cyl-tag-list/editing-icons.js'));
// The component's own locale: after `verify-package.js` the example's i18n reaches the installed copy in node_modules,
// a separate module, so the language is set on both (and put back after each test).
const packageLocale = require(path.join(PACKAGE, 'locale.js'));

function useLanguage(value) {
  const before = [i18n.language(), packageLocale.language()];
  i18n.setLanguage(value);
  packageLocale.setLanguage(value);
  return () => {
    i18n.setLanguage(before[0]);
    packageLocale.setLanguage(before[1]);
  };
}

function setPath(target, keyPath, value) {
  const parts = keyPath.replace(/\[(\d+)\]/g, '.$1').split('.');
  let node = target;
  for (let i = 0; i < parts.length - 1; i += 1) {
    if (node[parts[i]] == null) node[parts[i]] = {};
    node = node[parts[i]];
  }
  node[parts[parts.length - 1]] = value;
}

/** Loads cyl-tag-list and makes an instance with `properties`. */
function mountCloud(properties) {
  let definition;
  global.Component = (def) => { definition = def; };
  const file = path.join(PACKAGE, 'cyl-tag-list/cyl-tag-list.js');
  delete require.cache[require.resolve(file)];
  require(file);
  delete global.Component;
  const data = { ...(definition.data || {}) };
  for (const [key, spec] of Object.entries(definition.properties || {})) data[key] = spec.value;
  const events = [];
  const instance = {
    data,
    events,
    setData(patch, callback) {
      const changed = Object.keys(patch);
      for (const [key, value] of Object.entries(patch)) setPath(this.data, key, value);
      for (const [names, observer] of Object.entries(definition.observers || {})) {
        const keys = names.split(',').map((name) => name.trim());
        if (keys.some((key) => changed.includes(key) && key in definition.properties)) {
          observer.apply(this, keys.map((key) => this.data[key]));
        }
      }
      if (callback) callback();
    },
    triggerEvent(name, detail) { events.push({ name, detail }); },
    ...definition.methods,
  };
  definition.lifetimes.created.call(instance);
  definition.lifetimes.attached.call(instance);
  instance.setData(properties);
  return instance;
}

function at(index) {
  return { currentTarget: { dataset: { index } } };
}

test('a renamable tag shows the edit icon and the cross with the spacing of iOS 3af1b7cd', () => {
  const style = model.tagCloudStyle();
  assert.equal(style.editingIndicatorSpacing, 10);
  assert.deepEqual(style.editingIndicatorInsets, { top: 0, left: 4, bottom: 0, right: 0 });
  const tag = model.makeTag('Family');
  const plain = model.renderTag(tag, 0, { listStyle: style, editing: true });
  assert.equal(plain.editingIcons, null, 'no edit icon without renaming');
  assert.ok(plain.deleteIndicator);
  const item = model.renderTag(tag, 0, { listStyle: style, editing: true, renamable: true });
  assert.ok(item.editingIcons, 'two icons');
  assert.equal(item.deleteIndicator, null, 'they replace the delete indicator');
  const side = model.editingIconSide(style.normal.fontSize);
  assert.equal(side, Math.ceil(style.normal.fontSize * 0.7 * 1.25));
  assert.match(item.editingIcons.iconStyle, new RegExp(`width: ${side}px; height: ${side}px`));
  const wider = model.tagCloudStyle();
  wider.editingIndicatorSpacing = 20;
  assert.equal(model.renderTag(tag, 0, { listStyle: wider, editing: true, renamable: true }).editingIcons.width
    - item.editingIcons.width, 10, 'editingIndicatorSpacing widens the tag by the extra space');
  assert.match(item.editingIcons.renameImage, /^data:image\/svg\+xml;base64,/);
  assert.equal(Buffer.from(base64('<svg a="#fff"/>'), 'base64').toString(), '<svg a="#fff"/>');
  assert.match(Buffer.from(iconImage('clear', '#123456').split(',')[1], 'base64').toString(), /stroke="#123456"/);
});

test('the store keeps ids with the titles; plain titles are their own ids; loadItems keeps the server ids', () => {
  const store = new CYLTagListStore('sandboxFile', 'tag-cloud-renaming.items');
  store.removeAllTitles();
  store.saveItems([{ identifier: 't1', title: 'Family' }], 'mine');
  assert.deepEqual(store.cachedTitles('mine'), ['Family'], 'the titles follow the items');
  const events = [];
  const server = { mine: [{ identifier: 't2', title: 'Work' }, { identifier: 't1', title: 'Home' }] };
  loadItems({
    cache: store,
    remote: { fetchItemsWithKeys: (keys, callback) => callback(server, null) },
    keys: ['mine'],
    completion: (items, origin) => events.push(`${origin} ${items.mine.map((i) => `${i.identifier}:${i.title}`).join(',')}`),
  });
  assert.deepEqual(events, ['cache t1:Family', 'network t2:Work,t1:Home']);
  assert.deepEqual(store.cachedItems('mine'), server.mine, "the server's items are saved with their ids");
  store.saveTitles(['A'], 'mine');
  assert.equal(store.cachedItems('mine')[0].identifier, 'A', 'plain titles: each title is its id');
  // A remote source with titles only: each title is its own id.
  const titlesOnly = [];
  loadItems({
    cache: null,
    remote: { fetchSectionsWithKeys: (keys, callback) => callback({ mine: ['X'] }, null) },
    keys: ['mine'],
    completion: (items) => titlesOnly.push(items.mine[0]),
  });
  assert.deepEqual(titlesOnly, [{ identifier: 'X', title: 'X' }]);
  store.removeAllTitles();
});

test('renaming through the add field keeps the id after a reorder and reports it when editing ends', () => {
  const restoreLanguage = useLanguage('en');
  const name = 'tag-cloud-renaming.rename';
  new CYLTagListStore('userDefaults', name).removeAllTitles();
  const cloud = mountCloud({
    tags: ['Family', 'Friends', 'Clients'].map((title) => model.makeTag(title)),
    listStyle: model.tagCloudStyle(),
    cachePolicy: 'userDefaults',
    cacheName: name,
  });
  cloud.setEditing(true);
  assert.equal(cloud.data.items[0].editingIcons, null, 'no edit icon without supportsRenamingItems');
  cloud.setData({ supportsRenamingItems: true });
  assert.ok(cloud.data.items[0].editingIcons);
  assert.equal(cloud.data.items[0].renamesOnTitleTap, true, 'a tap on the title renames too, by default');
  cloud.onRename(at(1));
  assert.equal(cloud.renamingIndex(), 1);
  assert.equal(cloud.data.addText, 'Friends', 'the field shows the title to rename');
  assert.equal(cloud.data.addTitle, 'Done');
  cloud.setData({ addText: 'Best Friends' });
  cloud.onAddSubmit();
  assert.equal(cloud.renamingIndex(), -1);
  assert.equal(cloud.data.addTitle, 'Add Tag', 'the control adds tags again');
  const rename = cloud.events.find((event) => event.name === 'tagrename');
  assert.equal(rename.detail.position, 1);
  assert.equal(rename.detail.title, 'Best Friends');
  assert.deepEqual(new CYLTagListStore('userDefaults', name).cachedItems('0').map((item) => item.identifier),
    ['Family', 'Friends', 'Clients'], 'the renamed tag keeps its old title as its id');
  cloud.beginRenaming(0);
  cloud.finishRenaming('Family');
  assert.equal(cloud.events.filter((event) => event.name === 'tagrename').length, 1, 'an unchanged name only ends renaming');
  cloud.setEditing(false);
  const finish = cloud.events.find((event) => event.name === 'editingfinish');
  assert.deepEqual(finish.detail.items['0'][1], { identifier: 'Friends', title: 'Best Friends' });
  assert.deepEqual(finish.detail.titles['0'], ['Family', 'Best Friends', 'Clients']);
  new CYLTagListStore('userDefaults', name).removeAllTitles();
  restoreLanguage();
});

test("a host's editor renames and adds; cancelling changes nothing", () => {
  const cloud = mountCloud({
    tags: [model.makeTag('Family', { identifier: 7 }), model.makeTag('Friends')],
    listStyle: model.tagCloudStyle(),
    supportsRenamingItems: true,
    showsAddItemViewWhileEditing: false,
  });
  let request = '';
  cloud.setRenameRequestHandler((position, title) => { request = `${position} ${title}`; });
  cloud.setEditing(true);
  assert.equal(cloud.data.showsAddItem, false, 'no built-in field');
  cloud.beginRenaming(0);
  assert.equal(request, '0 Family');
  assert.equal(cloud.data.showsAddItem, false, 'still none while the host renames');
  cloud.finishRenaming('Home');
  assert.deepEqual(cloud.editableSectionItems()['0'][0], { identifier: '7', title: 'Home' }, 'its own id kept');
  cloud.beginRenaming(1);
  cloud.cancelRenaming();
  assert.equal(cloud.renamingIndex(), -1);
  assert.equal(cloud.getTags()[1].title, 'Friends');
  cloud.submitNewItem('  Clients ');
  assert.deepEqual(cloud.events.pop(), { name: 'requestnewitem', detail: { name: 'Clients', position: 2 } });
});

test('the header clear button is built in, read with the section title', () => {
  const restoreLanguage = useLanguage('en');
  const cloud = mountCloud({
    tags: [model.makeTag('Coworkers')],
    listStyle: model.tagCloudStyle(),
    showsSectionHeaders: true,
    sectionTitle: 'Recent',
  });
  assert.equal(cloud.data.clearImage, '', 'hidden by default');
  cloud.setData({ showsClearButton: true });
  assert.match(cloud.data.clearImage, /^data:image\/svg\+xml;base64,/);
  assert.equal(cloud.data.clearLabel, 'Clear Recent');
  cloud.onClearTap();
  assert.deepEqual(cloud.events.pop(), { name: 'clearbuttontap', detail: { section: 0 } });
  restoreLanguage();
});

test('a touch on the × or the pencil still makes a tap: mut-bind, no catchtouchstart (the × did nothing)', () => {
  const fs = require('node:fs');
  const wxml = fs.readFileSync(path.join(PACKAGE, 'cyl-tag-list/cyl-tag-list.wxml'), 'utf8');
  // catchtouchstart keeps WeChat from making a tap of the touches: the handlers never ran on a device or in DevTools.
  assert.doesNotMatch(wxml, /catchtouchstart/, 'no catchtouchstart anywhere in the cloud');
  // The item and every icon use mut-bind, so a touch on an icon does not press (highlight) the tag.
  assert.match(wxml, /class="cyl-tc-item [^"]*"[^>]*mut-bind:touchstart="onTouchStart"/s);
  const icons = wxml.match(/<view[^>]*(?:catchtap="onDelete"|catchtap="onRename")[^>]*>/gs) || [];
  assert.equal(icons.length, 4, 'the two delete indicators and the two editing icons');
  for (const icon of icons) assert.match(icon, /mut-bind:touchstart="noop"/);
});
