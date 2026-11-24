/**
 * The state of the 动效 tab without `wx` calls (node tests): CYLTagAnimationDemoViewController's configuration (the
 * map the tag list is created with) and its playback controls (docs/example-demo-rules.md).
 */

/** Playback controls: 0.25× to 4× in steps of 0.25. */
const SPEED_RANGE = [0.25, 4];
const SPEED_STEP = 0.25;

/** Section identifiers, one per library, in order. */
const SECTION_IDENTIFIERS = ['lottie', 'lottie-images', 'lottie-green', 'pag', 'rive', 'rive-icons', 'svga', 'svga-dark', 'gif', 'images'];

/** A file of CYLMenuExample.bundle/Animations (copied from CYLTabBarController's examples). */
function animation(path) {
  return `CYLMenuExample.bundle/Animations/${path}`;
}

/** CYLTabBarController's tab images (Assets.xcassets, exported to images/styles/tab). */
function tabImage(name) {
  return `/images/styles/tab/${name}.png`;
}

/** The configuration (map) the tag list is created with; `t` localizes the titles (CYLExampleLocalizedString). */
function configuration(t = (s) => s) {
  const item = (title, file, image) => {
    const value = { title: t(title) };
    if (file) value.animation = file;
    if (image) value.image = image;
    return value;
  };
  const rive = (title, name, options) => ({ ...item(title, animation(`Rive/${name}.riv`)), animationOptions: options });
  const sections = [];
  sections.push({ title: "Lottie · pod 'CYLTabBarController/Lottie'", items: [
    item('首页', animation('Lottie/tab_home_animate.json')),
    item('消息', animation('Lottie/tab_message_animate.json')),
    item('搜索', animation('Lottie/tab_search_animate.json')),
    item('我的', animation('Lottie/tab_me_animate.json'))] });
  // Lottie files with image assets next to them, and placeholder images for when no engine is linked.
  sections.push({ title: t('Lottie（带图片资源与占位图）'), items: [
    item('首页', animation('Lottie/gray_tabbar_home_animation.json'), tabImage('gray_tabbar_home_animation_lottie_placeholder')),
    item('消息', animation('Lottie/gray_tabbar_message_animation.json'), tabImage('gray_tabbar_message_animation_lottie_placeholder')),
    item('我的', animation('Lottie/gray_tabbar_me_animation.json'), tabImage('gray_tabbar_me_animation_lottie_placeholder'))] });
  sections.push({ title: t('Lottie（绿色主题）'), items: [
    item('首页', animation('Lottie/green_lottie_tab_home.json')),
    item('资讯', animation('Lottie/green_lottie_tab_news.json')),
    item('发现', animation('Lottie/green_lottie_tab_discover.json')),
    item('我的', animation('Lottie/green_lottie_tab_mine.json'))] });
  // The PAG tab icons of CYLTabBarController's Example-PAG and two libpag samples. 1.pag's first frame is empty: while
  // not selected it rests on its last frame instead.
  sections.push({ title: "PAG · pod 'CYLTabBarController/PAG'", items: [
    item('首页', 'pag-ios/tab_home.pag'),
    item('健康', 'pag-ios/tab_health.pag'),
    item('动态', 'pag-ios/tab_moments.pag'),
    item('我的', 'pag-ios/tab_me.pag'),
    item('动效一', 'pag-ios/0.pag'),
    { title: t('动效二'), animation: 'pag-ios/1.pag', animationRestingProgress: 1 }] });
  // The options CYLTabBarController's Rive examples use for each file.
  sections.push({ title: "Rive · pod 'CYLTabBarController/Rive'", items: [
    // house.riv moves only when its number input Rooms changes: each play sets the next of `values` (CYLTabBarController B20).
    rive('首页', 'house', { stateMachine: 'State Machine 1', numberInput: 'Rooms', values: '3,4,5,6' }),
    rive('完成', 'check', { stateMachine: 'State Machine 1', triggerInput: 'Check' }),
    rive('菜单', 'menu_button', { stateMachine: 'State Machine', input: 'isOpen', duration: '0' }),
    rive('按钮', 'button', { animation: 'active' }),
    rive('形状', 'shapes', { legacy: '1' }),
    // truck.riv from rive-app/rive-ios's examples, in place of confetti.riv (empty until its explosion plays).
    rive('卡车', 'truck', { legacy: '1' })] });
  // icons.riv, as on CYLTabBarController's dark Rive tab bar: its artboards are white strokes, so this section's tags
  // are dark (the section's style, over the list's style).
  const darkTags = {
    normal: { backgroundColor: '#17203A', textColor: '#FFFFFF', borderColor: '#17203A' },
    selected: { backgroundColor: '#3A4E8C', textColor: '#FFFFFF', borderColor: '#6792FF' },
  };
  sections.push({
    title: t('Rive · icons.riv（深色标签）'),
    style: darkTags,
    items: [
      rive('聊天', 'icons', { artboard: 'CHAT', stateMachine: 'CHAT_Interactivity', input: 'active' }),
      rive('搜索', 'icons', { artboard: 'SEARCH', stateMachine: 'SEARCH_Interactivity', input: 'active' }),
      rive('计时', 'icons', { artboard: 'TIMER', stateMachine: 'TIMER_Interactivity', input: 'active' }),
      rive('提醒', 'icons', { artboard: 'BELL', stateMachine: 'BELL_Interactivity', input: 'active' }),
      rive('我的', 'icons', { artboard: 'USER', stateMachine: 'USER_Interactivity', input: 'active' })],
  });
  // SVGA wherever Rive is shown (docs/example-demo-rules.md): CYLTabBarController's SVGA tab icons, as on iOS and
  // Android, played by its cyl-svga; the second section on the dark tags of icons.riv.
  sections.push({ title: "SVGA · pod 'CYLTabBarController/SVGA'", items: [
    item('首页', animation('SVGA/tab_home.svga')),
    item('搜索', animation('SVGA/tab_search.svga')),
    item('消息', animation('SVGA/tab_chat.svga')),
    item('我的', animation('SVGA/tab_profile.svga'))] });
  sections.push({ title: t('SVGA · 深色标签'), style: darkTags, items: [
    item('动态', animation('SVGA/tab_activity.svga')),
    item('列表', animation('SVGA/tab_list.svga')),
    item('首页', animation('SVGA/tab_home.svga'))] });
  sections.push({ title: "GIF · pod 'CYLTabBarController/GIF'", items: [
    item('火焰', animation('GIF/tab_fire.gif')),
    item('火箭', animation('GIF/tab_rocket.gif')),
    item('星星', animation('GIF/tab_star.gif')),
    item('示例', animation('GIF/cyl_tab_sample_animated.gif'))] });
  // CYLTabBarController's tab images: normal and highlighted.
  const still = (title, name) => ({ title: t(title), image: tabImage(`${name}_normal`), selectedImage: tabImage(`${name}_highlight`) });
  sections.push({ title: t('静态图片（CYLTabBarController Example）'), items: [
    still('首页', 'home'), still('同城', 'fishpond'), still('发布', 'post'), still('消息', 'message'), still('我的', 'account')] });
  return {
    selectionMode: 'single',
    allowsEmptySelection: false,
    selectedItems: sections.map((section, index) => `${index}-0`),
    style: {
      imageSize: '{28, 28}',
      imageTitleSpacing: 6,
      itemHeight: 44,
      layoutCentered: true,
      sectionInsets: [6, 16, 14, 16],
      normal: { cornerRadius: 1000, margin: 12, borderColor: '#D1D1D6', borderWidth: 1 },
      selected: { cornerRadius: 1000, margin: 12, backgroundColor: '#FFF1E6', textColor: '#FF6A00', borderColor: '#FF6A00', borderWidth: 1 },
    },
    sections,
  };
}

/** The speed as the slider sets it: clamped to the range, a multiple of the step. */
function snapSpeed(value) {
  const n = Number(value);
  const clamped = Math.min(Math.max(Number.isFinite(n) ? n : 1, SPEED_RANGE[0]), SPEED_RANGE[1]);
  return Math.round(clamped / SPEED_STEP) * SPEED_STEP;
}

/** "%g" of the speed: 1, 0.25, 2.5. */
function speedValue(speed) {
  return String(Number(Number(speed).toFixed(2)));
}

/** UIKit's own value of a switch (VoiceOver reads "Loop, on"); it is not in the example's bundle. */
const SWITCH_VALUES = {
  // NOLOCALIZE-BEGIN: UIKit's own switch values per language (not in any bundle table)
  en: ['off', 'on'],
  'zh-Hans': ['关', '开'],
  'zh-Hant': ['關', '開'],
  // NOLOCALIZE-END
};

/** The texts and accessibility labels of the controls for a speed and a loop setting. */
function controls(speed, loops, t, language = 'zh-Hans') {
  const value = speedValue(speed);
  const switchValues = SWITCH_VALUES[language] || SWITCH_VALUES['zh-Hans'];
  return {
    speed,
    speedText: `${value}×`,
    // The slider reads its title and its value ("Speed, 2 times"): the two labels beside it are hidden.
    speedAccessibility: `${t('倍速')}, ${t('%@ 倍', value)}`,
    loops,
    loopAccessibility: `${t('循环播放')}, ${switchValues[loops ? 1 : 0]}`,
  };
}

module.exports = { SPEED_RANGE, SPEED_STEP, SECTION_IDENTIFIERS, SWITCH_VALUES, configuration, snapSpeed, speedValue, controls };
