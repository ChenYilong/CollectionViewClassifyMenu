/**
 * The state of the Styles tab without `wx` calls (node tests): CYLTagStyleDemoViewController's actions, their values
 * and the preview's configuration. The style is kept as the core's style dictionary (CYLMenuStyleKey /
 * CYLTagAppearanceKey keys), applied to the preview as `tagListView.style = style` is on iOS; the values the table
 * shows are read from the effective style (model.mergeStyle), as iOS reads them from the CYLMenuStyle.
 */
const model = require('cyl-tag-list-miniprogram/cyl-tag-list/model.js');

/** Identifiers of the actions, in table order. */
const ACTION_IDENTIFIERS = [
  ['iconColor.normal', 'iconColor.selected', 'titleColor.normal', 'titleColor.selected', 'font',
    'imageTitleSpacing', 'imageSize', 'imageInsets', 'titlePositionAdjustment', 'imagePositionAdjustment',
    'content.iconAndTitle', 'content.iconOnly', 'content.titleOnly', 'layoutCentered', 'selectedImage'],
  ['backgroundColor.normal', 'backgroundColor.selected', 'borderColor', 'borderWidth', 'cornerRadius', 'margin'],
  ['animation.lottie', 'animation.pag', 'animation.rive', 'animation.svga', 'animation.gif', 'animation.off', 'animationSpeed', 'configuration', 'tagCloud'],
  ['sample.tagCloud', 'sample.imageTag', 'sample.tagContainer'],
  ['sample.wordPicker'],
  ['reset'],
];

const SECTION_TITLES = [
  '标题与图标（参照 CYLFlatDesignTabBarItem）',
  '背景、边框与圆角（参照 CYLBadgeView）',
  '动效图标（CYLTabBarController 动效引擎）',
  'Android 标签库示例（Swift 复刻）',
  '选词填入（涂抹选择）',
  '其它',
];

/** The localization keys of the action titles. */
const ACTION_TITLES = {
  'iconColor.normal': '设置 iconColor（normal）',
  'iconColor.selected': '设置 iconColor（selected）',
  'titleColor.normal': '设置文字颜色 titleTextAttributes（normal）',
  'titleColor.selected': '设置文字颜色 titleTextAttributes（selected）',
  font: '设置字体 NSFontAttributeName',
  imageTitleSpacing: '设置 icon 与文字间距 imageTitleSpacing',
  imageSize: '设置 icon 大小 imageSize',
  imageInsets: '设置 imageInsets',
  titlePositionAdjustment: '设置 titlePositionAdjustment',
  imagePositionAdjustment: '设置 imagePositionAdjustment',
  'content.iconAndTitle': '显示 icon + title',
  'content.iconOnly': '只显示 icon',
  'content.titleOnly': '只显示 title',
  layoutCentered: '切换 layoutCentered（只有 icon 或 title 时居中）',
  selectedImage: '切换选中图片 selectedImage',
  'backgroundColor.normal': '设置背景色 backgroundColor（normal）',
  'backgroundColor.selected': '设置背景色 backgroundColor（selected）',
  borderColor: '设置边框颜色 borderColor',
  borderWidth: '设置边框宽度 borderWidth',
  cornerRadius: '设置圆角 cornerRadius（0 为直角，1000 为胶囊）',
  margin: '设置内边距 margin',
  'animation.lottie': 'Lottie 动效图标',
  'animation.pag': 'PAG 动效图标',
  'animation.rive': 'Rive 动效图标',
  'animation.svga': 'SVGA 动效图标',
  'animation.gif': 'GIF 动效图标',
  'animation.off': '关闭动效（静态图标）',
  animationSpeed: '设置动效速度 animationSpeed',
  configuration: '配置文件 / 字典（map）初始化',
  tagCloud: '标签云：android-tagview 的初始化方式',
  'sample.tagCloud': 'android-tagview 示例（Swift 版）',
  'sample.imageTag': 'TagViewGroup 示例：图片标签',
  'sample.tagContainer': 'AndroidTagView 示例：标签容器',
  'sample.wordPicker': '选词填入：涂抹选择填入词',
  reset: '重置 reset',
};

/** The rows that open another screen (pushed with wx.navigateTo). */
const PAGES = {
  configuration: '/pages/configuration/configuration',
  tagCloud: '/pages/tag-cloud/tag-cloud',
  'sample.tagCloud': '/pages/sample-tag-cloud/sample-tag-cloud',
  'sample.imageTag': '/pages/sample-image-tag/sample-image-tag',
  'sample.tagContainer': '/pages/sample-tag-container/sample-tag-container',
  'sample.wordPicker': '/pages/sample-word-picker/sample-word-picker',
};

/** A fixed palette, so that screenshots are stable: systemOrange, systemPurple, systemTeal, systemPink, systemIndigo, systemGreen. */
const PALETTE = ['#FF9500', '#AF52DE', '#30B0C7', '#FF2D55', '#5856D6', '#34C759'];

function colorAtStep(step) {
  return PALETTE[step % PALETTE.length];
}

/** The palette color with an alpha of 0.15 ("#RRGGBBAA"). */
function lightColorAtStep(step) {
  return `${colorAtStep(step)}26`;
}

/** UIColor(white: 1 - 0.15 * (step % 3)). */
function whiteAtStep(step) {
  const level = Math.round((1 - 0.15 * (step % 3)) * 255).toString(16).toUpperCase().padStart(2, '0');
  return `#${level}${level}${level}`;
}

const APPEARANCES = ['normal', 'selected', 'disabled'];

/** CYLTagStyleDemoViewController.demoStyle(). */
function demoStyle() {
  return {
    // The preview is a flat strip of glass tags, not a card: opt out of the default rounded section card.
    sectionStyle: model.SECTION_STYLES.plain,
    backgroundStyle: 'liquidGlass',
    normal: { iconColor: 'systemBlue' },
    selected: { iconColor: '#FFFFFF', backgroundColor: 'systemBlue', borderColor: 'systemBlue' },
    disabled: {},
    imageSize: '{16, 16}',
    imageTitleSpacing: 4,
    itemHeight: 34,
    sectionInsets: [12, 16, 12, 16],
  };
}

/** Title key, icon and selected icon of the preview's tags (reloadItems). */
const SAMPLES = [
  ['首页', 'house', 'house.fill'],
  ['同城', 'mappin.and.ellipse', 'mappin.circle.fill'],
  ['消息', 'message', 'message.fill'],
  ['我的', 'person', 'person.fill'],
  ['一个很长很长的标签标题', 'star', 'star.fill'],
  ['已禁用', 'nosign', 'nosign'],
];

/** The demo's animated icons, from CYLTabBarController's examples (Lottie, GIF, Rive, SVGA) and libpag/pag-ios (PAG). */
const ANIMATION_FILES = {
  lottie: ['CYLMenuExample.bundle/Animations/Lottie/tab_home_animate.json', 'CYLMenuExample.bundle/Animations/Lottie/tab_me_animate.json'],
  gif: ['CYLMenuExample.bundle/Animations/GIF/tab_star.gif', 'CYLMenuExample.bundle/Animations/GIF/cyl_tab_sample_animated.gif'],
  pag: ['pag-ios/0.pag', 'pag-ios/1.pag'],
  rive: ['CYLMenuExample.bundle/Animations/Rive/house.riv', 'CYLMenuExample.bundle/Animations/Rive/menu_button.riv'],
  svga: ['CYLMenuExample.bundle/Animations/SVGA/tab_home.svga', 'CYLMenuExample.bundle/Animations/SVGA/tab_profile.svga'],
};

function createState() {
  return {
    style: demoStyle(),
    content: 'iconAndTitle',
    animationLibrary: null,
    usesSelectedImage: true,
    steps: {},
    selection: ['0-0'],
  };
}

function nextStep(state, identifier) {
  const step = state.steps[identifier] || 0;
  state.steps[identifier] = step + 1;
  return step;
}

/** The effective style (CYLMenuStyle) of the demo's style dictionary. */
function effectiveStyle(state, options) {
  return model.mergeStyle(state.style, options && options.pixelRatio ? model.defaultStyle(options.pixelRatio) : undefined);
}

/**
 * Performs an action as a tap on its row does. Returns {navigate} for the rows that open another screen, {play: true}
 * after an animation library is chosen (the selected tags play their icons), or {}.
 */
function performAction(state, identifier) {
  const style = state.style;
  const step = nextStep(state, identifier);
  const each = (fn) => APPEARANCES.forEach((name) => fn(style[name]));
  switch (identifier) {
    case 'iconColor.normal':
      style.normal.iconColor = colorAtStep(step);
      break;
    case 'iconColor.selected':
      style.selected.iconColor = ['systemYellow', '#000000', '#FFFFFF'][step % 3];
      break;
    case 'titleColor.normal':
      style.normal.textColor = colorAtStep(step);
      break;
    case 'titleColor.selected':
      style.selected.textColor = whiteAtStep(step);
      break;
    case 'font': {
      const fonts = [{ size: 16, weight: 'semibold' }, { size: 12 }, { size: 15, italic: true }, { size: 14 }];
      each((appearance) => { appearance.font = { ...fonts[step % fonts.length] }; });
      break;
    }
    case 'imageTitleSpacing':
      style.imageTitleSpacing = [10, 0, 4][step % 3];
      break;
    case 'imageSize': {
      const side = [20, 10, 14][step % 3];
      style.imageSize = `{${side}, ${side}}`;
      break;
    }
    case 'imageInsets': {
      const inset = step % 2 === 0 ? 3 : 0;
      style.imageInsets = [inset, inset, inset, inset];
      break;
    }
    case 'titlePositionAdjustment':
      style.titlePositionAdjustment = ['{0, -4}', '{4, 0}', '{0, 0}'][step % 3];
      break;
    case 'imagePositionAdjustment':
      style.imagePositionAdjustment = ['{0, -4}', '{-4, 0}', '{0, 0}'][step % 3];
      break;
    case 'content.iconAndTitle':
    case 'content.iconOnly':
    case 'content.titleOnly':
      state.content = identifier.slice('content.'.length);
      break;
    case 'layoutCentered':
      style.layoutCentered = !effectiveStyle(state).layoutCentered;
      break;
    case 'selectedImage':
      state.usesSelectedImage = !state.usesSelectedImage;
      break;
    case 'backgroundColor.normal':
      style.normal.backgroundColor = lightColorAtStep(step);
      break;
    case 'backgroundColor.selected':
      style.selected.backgroundColor = colorAtStep(step);
      style.selected.borderColor = colorAtStep(step);
      break;
    case 'borderColor':
      style.normal.borderColor = colorAtStep(step);
      break;
    case 'borderWidth': {
      const width = [2, 0, 1, 0.5][step % 4];
      each((appearance) => { appearance.borderWidth = width; });
      break;
    }
    case 'cornerRadius': {
      const radius = [0, 8, 3][step % 3];
      each((appearance) => { appearance.cornerRadius = radius; });
      break;
    }
    case 'margin': {
      const margin = [18, 4, 10][step % 3];
      each((appearance) => { appearance.margin = margin; });
      break;
    }
    case 'animation.lottie':
    case 'animation.pag':
    case 'animation.rive':
    case 'animation.svga':
    case 'animation.gif':
    case 'animation.off': {
      const library = identifier.slice('animation.'.length);
      state.animationLibrary = library === 'off' ? null : library;
      // Show the animations: the selected tags play their icons.
      return { play: true };
    }
    case 'animationSpeed':
      style.animationSpeed = [0.5, 2, 1][step % 3];
      break;
    case 'reset': {
      const selection = state.selection;
      Object.assign(state, createState(), { selection: selection.length ? selection : ['0-0'] });
      break;
    }
    default:
      if (PAGES[identifier]) return { navigate: PAGES[identifier] };
  }
  return {};
}

/** The value a row shows next to its title. */
function valueForAction(state, identifier, options) {
  const style = effectiveStyle(state, options);
  const fixed = (n, digits) => Number(n).toFixed(digits);
  switch (identifier) {
    case 'imageTitleSpacing': return fixed(style.imageTitleSpacing, 0);
    case 'imageSize': return model.coderString(style.imageSizeWH);
    case 'imageInsets': return model.coderString(style.imageInsets);
    case 'titlePositionAdjustment': return model.coderString(style.titlePositionAdjustment);
    case 'imagePositionAdjustment': return model.coderString(style.imagePositionAdjustment);
    case 'layoutCentered': return style.layoutCentered ? 'YES' : 'NO';
    case 'selectedImage': return state.usesSelectedImage ? 'YES' : 'NO';
    case 'font': return `${model.fontName(style.normal.font)} ${fixed(style.normal.font.size, 0)}`;
    case 'borderWidth': return fixed(style.normal.borderWidth, 1);
    case 'cornerRadius': return fixed(style.normal.cornerRadius, 0);
    case 'margin': return fixed(Math.max(style.normal.contentInsets.left, style.normal.contentInsets.right), 0);
    case 'animationSpeed': return fixed(style.animationSpeed, 1);
    default: break;
  }
  if (identifier.startsWith('animation.')) {
    const library = identifier.slice('animation.'.length);
    const current = library === 'off' ? state.animationLibrary === null : library === state.animationLibrary;
    return current ? '✓' : '';
  }
  if (identifier.startsWith('content.')) return identifier === `content.${state.content}` ? '✓' : '';
  return '';
}

/** The animation file of the tag at `index` for the current library, with its Rive options (animationURL(forIndex:)). */
function animationForIndex(state, index) {
  const names = ANIMATION_FILES[state.animationLibrary];
  if (!names) return null;
  const animation = { animation: names[index % names.length] };
  if (state.animationLibrary === 'rive') {
    // The state machines CYLTabBarController's Rive example plays for these files.
    animation.animationOptions = index % 2 === 0
      ? { stateMachine: 'State Machine 1' }
      : { stateMachine: 'State Machine', input: 'isOpen', duration: '0' };
  }
  return animation;
}

/** The preview's configuration (reloadItems + applyStyle): one section without a header, multiple selection. */
function configuration(state, t = (s) => s) {
  const iconOnly = state.content === 'iconOnly';
  const titleOnly = state.content === 'titleOnly';
  const items = [];
  SAMPLES.forEach(([title, image, selectedImage]) => {
    const item = { title: iconOnly ? '' : t(title) };
    if (!titleOnly) item.image = `system:${image}`;
    if (!titleOnly && state.usesSelectedImage) item.selectedImage = `system:${selectedImage}`;
    item.enabled = title !== '已禁用';
    if (state.animationLibrary && item.enabled && !titleOnly) Object.assign(item, animationForIndex(state, items.length));
    items.push(item);
  });
  return {
    selectionMode: 'multiple',
    showsSectionHeaders: false,
    scrollEnabled: false,
    selectedItems: state.selection.length ? state.selection.slice() : ['0-0'],
    style: JSON.parse(JSON.stringify(state.style)),
    sections: [{ title: '', items }],
  };
}

/** The table: sections with their header and rows (identifier, title, value). */
function table(state, t = (s) => s, options) {
  return ACTION_IDENTIFIERS.map((identifiers, section) => ({
    header: t(SECTION_TITLES[section]),
    rows: identifiers.map((identifier) => ({
      identifier,
      title: t(ACTION_TITLES[identifier] || identifier),
      value: valueForAction(state, identifier, options),
    })),
  }));
}

module.exports = {
  ACTION_IDENTIFIERS, SECTION_TITLES, ACTION_TITLES, PAGES, PALETTE, SAMPLES, ANIMATION_FILES,
  colorAtStep, lightColorAtStep, whiteAtStep, demoStyle, createState, performAction, valueForAction,
  animationForIndex, configuration, table, effectiveStyle,
};
