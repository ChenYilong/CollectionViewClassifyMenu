// The 样式 and 动效 tabs and the configuration demo, without wx (node --test): the iOS example's actions, values,
// configurations and playback controls.
const test = require('node:test');
const assert = require('node:assert/strict');
const { t, setLanguage } = require('../miniprogram/utils/i18n.js');
const model = require('cyl-tag-list-miniprogram/cyl-tag-list/model.js');
const animations = require('../miniprogram/utils/tag-animations.js');
const styles = require('../miniprogram/pages/styles/demo.js');
const animationDemo = require('../miniprogram/pages/animations/demo.js');
const configurationDemo = require('../miniprogram/pages/configuration/demo.js');
const fs = require('node:fs');
const path = require('node:path');

test('styles: the table has the iOS sections and actions in order, with their localized titles', () => {
  setLanguage('en');
  const table = styles.table(styles.createState(), t);
  assert.equal(table.length, 5);
  assert.equal(table[0].header, 'Title and icon (as CYLFlatDesignTabBarItem)');
  assert.deepEqual(table.map((s) => s.rows.length), [15, 6, 8, 3, 1]);
  assert.equal(table[0].rows[0].title, 'Set iconColor (normal)');
  assert.equal(table[4].rows[0].identifier, 'reset');
  setLanguage('zh-Hans');
});

test('styles: the initial values are those of demoStyle()', () => {
  const state = styles.createState();
  const value = (id) => styles.valueForAction(state, id, { pixelRatio: 3 });
  assert.equal(value('imageTitleSpacing'), '4');
  assert.equal(value('imageSize'), '{16, 16}');
  assert.equal(value('imageInsets'), '{0, 0, 0, 0}');
  assert.equal(value('titlePositionAdjustment'), '{0, 0}');
  assert.equal(value('layoutCentered'), 'YES');
  assert.equal(value('selectedImage'), 'YES');
  assert.equal(value('font'), '.SFUI-Regular 14');
  assert.equal(value('borderWidth'), '0.3');
  assert.equal(value('cornerRadius'), '3');
  assert.equal(value('margin'), '10');
  assert.equal(value('animationSpeed'), '1.0');
  assert.equal(value('content.iconAndTitle'), '✓');
  assert.equal(value('content.iconOnly'), '');
  assert.equal(value('animation.off'), '✓');
  assert.equal(value('iconColor.normal'), '');
});

test('styles: every action cycles through the iOS values', () => {
  const state = styles.createState();
  const run = (id, times) => {
    const values = [];
    for (let i = 0; i < times; i += 1) {
      styles.performAction(state, id);
      values.push(styles.valueForAction(state, id));
    }
    return values;
  };
  assert.deepEqual(run('imageTitleSpacing', 4), ['10', '0', '4', '10']);
  assert.deepEqual(run('imageSize', 3), ['{20, 20}', '{10, 10}', '{14, 14}']);
  assert.deepEqual(run('imageInsets', 2), ['{3, 3, 3, 3}', '{0, 0, 0, 0}']);
  assert.deepEqual(run('titlePositionAdjustment', 3), ['{0, -4}', '{4, 0}', '{0, 0}']);
  assert.deepEqual(run('imagePositionAdjustment', 3), ['{0, -4}', '{-4, 0}', '{0, 0}']);
  assert.deepEqual(run('font', 4), ['.SFUI-Semibold 16', '.SFUI-Regular 12', '.SFUI-RegularItalic 15', '.SFUI-Regular 14']);
  assert.deepEqual(run('borderWidth', 4), ['2.0', '0.0', '1.0', '0.5']);
  assert.deepEqual(run('cornerRadius', 3), ['0', '8', '3']);
  assert.deepEqual(run('margin', 3), ['18', '4', '10']);
  assert.deepEqual(run('animationSpeed', 3), ['0.5', '2.0', '1.0']);
  assert.deepEqual(run('layoutCentered', 2), ['NO', 'YES']);
  assert.deepEqual(run('selectedImage', 2), ['NO', 'YES']);
  const effective = () => styles.effectiveStyle(state);
  styles.performAction(state, 'iconColor.normal');
  assert.equal(effective().normal.iconColor, '#FF9500');
  styles.performAction(state, 'iconColor.selected');
  assert.equal(effective().selected.iconColor, '#FFCC00');
  styles.performAction(state, 'titleColor.selected');
  styles.performAction(state, 'titleColor.selected');
  assert.equal(effective().selected.textColor, '#D9D9D9');
  styles.performAction(state, 'backgroundColor.normal');
  assert.equal(effective().normal.backgroundColor, 'rgba(255, 149, 0, 0.149)');
  styles.performAction(state, 'backgroundColor.selected');
  assert.deepEqual([effective().selected.backgroundColor, effective().selected.borderColor], ['#FF9500', '#FF9500']);
  styles.performAction(state, 'borderColor');
  assert.equal(effective().normal.borderColor, '#FF9500');
});

test('styles: content, selected images and animations change the preview items; reset keeps the selection', () => {
  const state = styles.createState();
  let items = styles.configuration(state, t).sections[0].items;
  assert.deepEqual(items.map((i) => i.title), ['首页', '同城', '消息', '我的', '一个很长很长的标签标题', '已禁用']);
  assert.deepEqual([items[0].image, items[0].selectedImage, items[5].enabled], ['system:house', 'system:house.fill', false]);
  styles.performAction(state, 'content.iconOnly');
  items = styles.configuration(state, t).sections[0].items;
  assert.ok(items.every((i) => i.title === '' && i.image));
  styles.performAction(state, 'content.titleOnly');
  styles.performAction(state, 'animation.lottie');
  items = styles.configuration(state, t).sections[0].items;
  assert.ok(items.every((i) => !i.image && !i.animation));
  styles.performAction(state, 'content.iconAndTitle');
  assert.deepEqual(styles.performAction(state, 'animation.gif'), { play: true });
  items = styles.configuration(state, t).sections[0].items;
  assert.deepEqual(items.map((i) => i.animation), [
    'CYLMenuExample.bundle/Animations/GIF/tab_star.gif', 'CYLMenuExample.bundle/Animations/GIF/cyl_tab_sample_animated.gif',
    'CYLMenuExample.bundle/Animations/GIF/tab_star.gif', 'CYLMenuExample.bundle/Animations/GIF/cyl_tab_sample_animated.gif',
    'CYLMenuExample.bundle/Animations/GIF/tab_star.gif', undefined]);
  styles.performAction(state, 'animation.rive');
  items = styles.configuration(state, t).sections[0].items;
  assert.deepEqual(items[1].animationOptions, { stateMachine: 'State Machine', input: 'isOpen', duration: '0' });
  // Rive is linked (CYLTabBarController's cyl-rive): the tags play the exported .riv.bin files.
  assert.equal(animations.resolve(items[0].animation).engine, 'rive');
  styles.performAction(state, 'selectedImage');
  assert.equal(styles.configuration(state, t).sections[0].items[0].selectedImage, undefined);
  state.selection = ['0-2'];
  styles.performAction(state, 'reset');
  assert.deepEqual(state.selection, ['0-2']);
  assert.equal(state.animationLibrary, null);
  assert.deepEqual(styles.configuration(state, t).selectedItems, ['0-2']);
  const configuration = styles.configuration(state, t);
  assert.equal(configuration.selectionMode, 'multiple');
  assert.equal(configuration.showsSectionHeaders, false);
});

test('styles: the rows that open another screen navigate to their pages', () => {
  const state = styles.createState();
  assert.deepEqual(styles.performAction(state, 'configuration'), { navigate: '/pages/configuration/configuration' });
  assert.deepEqual(styles.performAction(state, 'tagCloud'), { navigate: '/pages/tag-cloud/tag-cloud' });
  assert.deepEqual(styles.performAction(state, 'sample.tagCloud'), { navigate: '/pages/sample-tag-cloud/sample-tag-cloud' });
  assert.deepEqual(styles.performAction(state, 'sample.imageTag'), { navigate: '/pages/sample-image-tag/sample-image-tag' });
  assert.deepEqual(styles.performAction(state, 'sample.tagContainer'), { navigate: '/pages/sample-tag-container/sample-tag-container' });
});

test('animations: eight sections in the iOS order, single choice, the first tag of each selected', () => {
  setLanguage('en');
  const configuration = animationDemo.configuration(t);
  assert.deepEqual(configuration.sections.map((s) => s.title), [
    "Lottie · pod 'CYLTabBarController/Lottie'", 'Lottie (image assets and placeholders)', 'Lottie (green theme)',
    "PAG · pod 'CYLTabBarController/PAG'", "Rive · pod 'CYLTabBarController/Rive'", 'Rive · icons.riv (dark tags)',
    "GIF · pod 'CYLTabBarController/GIF'", 'Static images (CYLTabBarController Example)']);
  assert.deepEqual(configuration.sections.map((s) => s.items.length), [4, 3, 4, 6, 6, 5, 4, 5]);
  assert.deepEqual(configuration.sections[0].items.map((i) => i.title), ['Home', 'Messages', 'Search', 'Me']);
  setLanguage('zh-Hans');
  const m = model.normalize(configuration);
  assert.equal(m.selectionMode, 'single');
  assert.equal(m.allowsEmptySelection, false);
  assert.deepEqual(m.selectedItems, ['0-0', '1-0', '2-0', '3-0', '4-0', '5-0', '6-0', '7-0']);
  assert.equal(m.style.imageSize, 28);
  assert.equal(m.sections[5].style.normal.backgroundColor, '#17203A');
  assert.equal(m.sections[3].items[5].animationRestingProgress, 1);
  // Every Lottie, GIF, Rive and PAG file of the screen resolves (PAG to the engines subpackage).
  m.sections.forEach((section) => section.items.forEach((item) => {
    if (!item.animation) return;
    const engine = model.animationEngine(item.animation);
    const resolved = animations.resolve(item.animation);
    if (['lottie', 'gif', 'rive', 'pag'].includes(engine)) assert.ok(resolved, item.animation);
    else assert.equal(resolved, null);
  }));
  for (const item of m.sections[7].items) {
    for (const image of [item.image, item.selectedImage]) {
      assert.ok(fs.existsSync(path.join(__dirname, '../miniprogram', image)), image);
    }
  }
});

test('animations: the speed slider clamps to 0.25x-4x in steps of 0.25; VoiceOver reads "Speed, 2 times" and "Loop, on"', () => {
  assert.equal(animationDemo.snapSpeed(2.1), 2);
  assert.equal(animationDemo.snapSpeed(0.1), 0.25);
  assert.equal(animationDemo.snapSpeed(9), 4);
  assert.equal(animationDemo.snapSpeed(1.37), 1.25);
  setLanguage('en');
  const controls = animationDemo.controls(2, true, t, 'en');
  assert.equal(controls.speedText, '2×');
  assert.equal(controls.speedAccessibility, 'Speed, 2 times');
  assert.equal(controls.loopAccessibility, 'Loop, on');
  assert.equal(animationDemo.controls(0.25, false, t, 'en').speedText, '0.25×');
  assert.equal(animationDemo.controls(0.25, false, t, 'en').loopAccessibility, 'Loop, off');
  setLanguage('zh-Hans');
  assert.equal(animationDemo.controls(1.5, false, t, 'zh-Hans').speedAccessibility, '倍速, 1.5 倍');
});

test('configuration: the file is read as the core reads it, and the map configuration matches the iOS dictionary', () => {
  const root = path.join(__dirname, '../miniprogram');
  const read = (p) => fs.readFileSync(path.join(root, p), 'utf8');
  const file = configurationDemo.readConfiguration(read);
  assert.equal(file.error, '');
  const m = model.normalize(file.configuration);
  assert.equal(m.foldControl.position, 'footer');
  assert.equal(m.defaultVisibleRows, 2);
  assert.equal(m.style.selected.font.weight, 'semibold');
  assert.equal(m.style.headerTextColor, '#8E8E93');
  assert.equal(m.sections[0].items[5].enabled, false);
  assert.equal(animations.resolve(m.sections[0].items[0].animation).engine, 'lottie');
  assert.equal(animations.resolve(m.sections[0].items[3].animation).engine, 'gif');
  assert.equal(animations.resolve(m.sections[0].items[1].animation).entry.src, '/engines/pag/0.pag.bin');
  assert.equal(configurationDemo.readConfiguration(() => { throw new Error('x'); }).error,
    'No configuration file at CYLMenuExample.bundle/Configurations/animated-tags.json');
  assert.match(configurationDemo.readConfiguration(() => '[1]').error, /does not hold a dictionary/);
  const map = model.normalize(configurationDemo.mapConfiguration(t));
  assert.equal(map.selectionMode, 'multiple');
  assert.deepEqual(map.selectedItems, ['0-1']);
  assert.equal(map.sections[0].items[4].title, 'Text only');
  assert.equal(map.style.normal.iconColor, '#5856D6');
  assert.equal(map.style.selected.textColor, '#FFFFFF');
  assert.equal(map.style.normal.cornerRadius, 8);
});

test('configuration: the copied file is the iOS bundle file, byte for byte', () => {
  const copy = fs.readFileSync(path.join(__dirname, '../miniprogram/data/animations/Configurations/animated-tags.json'));
  const source = fs.readFileSync(path.join(__dirname, '../../../Example/CYLMenuExample/CYLMenuExample.bundle/Configurations/animated-tags.json'));
  assert.ok(copy.equals(source));
});
