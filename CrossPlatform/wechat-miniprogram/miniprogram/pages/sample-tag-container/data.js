/**
 * whilu/AndroidTagView's sample data and the five containers of content_main.xml, as CYLTagContainerSample.swift
 * (CYLTagContainerSampleData and makeContainer). No `wx` calls.
 */
const model = require('cyl-tag-list-miniprogram/cyl-tag-cloud/model.js');

/**
 * The last tag of list1: the running system, as the iOS sample ("Welcome to use iOS 27.2 CollectionViewClassifyMenu"):
 * `system` of wx.getDeviceInfo() ("iOS 17.0", "Android 14"); outside a mini program (node tests) "Node".
 */
function welcomeTitle() {
  let system = 'Node';
  try {
    if (typeof wx !== 'undefined') {
      const info = typeof wx.getDeviceInfo === 'function' ? wx.getDeviceInfo() : wx.getSystemInfoSync();
      system = info.system || system;
    }
  } catch (error) {
    // keep the fallback
  }
  return `Welcome to use ${system} CollectionViewClassifyMenu`;
}

const LIST1 = ['Java', 'C++', 'Python', 'Swift', '你好，这是一个TAG。你好，这是一个TAG。你好，这是一个TAG。你好，这是一个TAG。', // NOLOCALIZE: sample data: deliberately multilingual tags of AndroidTagView's sample
  'PHP', 'JavaScript', 'Html', welcomeTitle()];
const LIST2 = ['China', 'USA', 'Austria', 'Japan', 'Sudan', 'Spain', 'UK', 'Germany', 'Niger', 'Poland', 'Norway',
  'Uruguay', 'Brazil'];
const LIST3 = ['Persian', '波斯语', 'فارسی', 'Hello', '你好', 'سلام']; // NOLOCALIZE: sample data: deliberately multilingual tags of AndroidTagView's sample
const LIST4 = ['Adele', 'Whitney Houston'];
const LIST5 = ['Custom Red Color', 'Custom Blue Color'];

/** {backgroundColor, tagBorderColor, tagTextColor, tagSelectedBackgroundColor} of list5. */
function colors5() {
  return ['#ff0000', '#0000ff'].map((hex) => ({
    backgroundColor: model.color(hex),
    borderColor: '#000000',
    textColor: '#FFFFFF',
    selectedBackgroundColor: model.color('#999999'),
  }));
}

/** The default image (yellow_avatar): a round yellow face. */
const AVATAR = '/images/samples/avatar.png';

/**
 * A TagContainerLayout with the library's defaults (`makeContainer`): the #11FF0000 background, a 0.5 pt #22FF0000
 * border with a 10 pt radius, 10 pt padding, not tappable, the pure cyan theme; then `configure(options, style)`.
 */
function makeContainer(configure) {
  const style = model.tagContainerStyle();
  style.sectionInsets = { top: 10, left: 10, bottom: 10, right: 10 };
  style.backgroundColor = model.rgba(1, 0, 0, 0x11 / 255);
  const options = {
    containerBorderWidth: 0.5,
    containerBorderColor: model.rgba(1, 0, 0, 0x22 / 255),
    containerCornerRadius: 10,
    allowsTapping: false,
    colorTheme: 'pureCyan',
    allowsReordering: false,
    removesItemsOnDelete: true,
    defaultTagImage: '',
  };
  configure(options, style);
  return { style, options };
}

/** Tags with these titles, and colors per tag in order (setTags(withTitles:colors:)). */
function tagsWithTitles(titles, colors = [], deletable = false) {
  return titles.map((title, index) => {
    const tag = model.makeTag(title, { isDeletable: deletable });
    if (index < colors.length) model.setTagColors(tag, colors[index]);
    return tag;
  });
}

/** tagcontainerLayout1: drag, clickable, cross, pure teal, 10 pt spacing, the default avatar. */
function first() {
  const container = makeContainer((options, style) => {
    style.interitemSpacing = 10;
    style.lineSpacing = 10;
    // The avatar as AndroidTagView draws it (and iOS's CYLTagContainerSample): a circle as tall as the tag at its
    // leading edge.
    style.imageFillsTagHeight = true;
    options.allowsReordering = true;
    options.allowsTapping = true;
    options.colorTheme = 'pureTeal';
    options.removesItemsOnDelete = false;
    options.defaultTagImage = AVATAR;
  });
  return { ...container, tags: tagsWithTitles(LIST1, [], true) };
}

/** tagcontainerLayout2: transparent, a 4 pt #3300ff00 border, square, drag, not clickable, random colors. */
function second() {
  const container = makeContainer((options, style) => {
    style.interitemSpacing = 10;
    style.lineSpacing = 10;
    style.backgroundColor = model.NAMED_COLORS.clear;
    options.containerBorderColor = model.rgba(0, 1, 0, 0x33 / 255);
    options.containerBorderWidth = 4;
    options.containerCornerRadius = 0;
    options.allowsReordering = true;
    options.colorTheme = 'random';
  });
  return { ...container, tags: tagsWithTitles(LIST2) };
}

/** tagcontainerLayout3: right-aligned, right-to-left, white tags with a #330000ff border, selectable, cross. */
function third() {
  const container = makeContainer((options, style) => {
    style.interitemSpacing = 10;
    style.lineSpacing = 10;
    style.backgroundColor = model.NAMED_COLORS.clear;
    style.rowAlignment = 'trailing';
    style.maximumTitleLength = 18;
    style.reversesTitleCharacters = true;
    style.deleteIndicatorPlacement = 'leading';
    model.setTagContentInsets(style, { top: 10, left: 15, bottom: 10, right: 15 });
    for (const state of ['normal', 'selected']) {
      Object.assign(style[state], {
        backgroundColor: '#FFFFFF',
        borderColor: model.rgba(0, 0, 1, 0x33 / 255),
        borderWidth: 1,
        cornerRadius: 1,
        textColor: model.white(0x66 / 255),
      });
    }
    style.selected.backgroundColor = model.rgba(1, 0x76 / 255, 0x69 / 255, 0x33 / 255);
    options.containerBorderColor = model.white(0x66 / 255, 0x33 / 255);
    options.containerCornerRadius = 0;
    options.allowsTapping = true;
    options.colorTheme = 'none';
    options.removesItemsOnDelete = false;
  });
  return { ...container, tags: tagsWithTitles(LIST3, [], true) };
}

/** tagcontainerLayout4: centered, clickable, a 2 s black ripple at alpha 47, pure teal. */
function fourth() {
  const container = makeContainer((options, style) => {
    style.interitemSpacing = 10;
    style.lineSpacing = 10;
    style.rowAlignment = 'center';
    style.rippleColor = '#000000';
    style.rippleAlpha = 47 / 255;
    style.rippleDuration = 2;
    options.allowsTapping = true;
    options.colorTheme = 'pureTeal';
  });
  return { ...container, tags: tagsWithTitles(LIST4) };
}

/** tagcontainerLayout5: a 4 pt square border, not clickable, random theme, but custom colors per tag. */
function fifth() {
  const container = makeContainer((options, style) => {
    style.interitemSpacing = 10;
    style.lineSpacing = 10;
    options.containerBorderWidth = 4;
    options.containerCornerRadius = 0;
    options.colorTheme = 'random';
  });
  return { ...container, tags: tagsWithTitles(LIST5, colors5()) };
}

/** The five containers, in order. */
function containers() {
  return [first(), second(), third(), fourth(), fifth()];
}

module.exports = { LIST1, LIST2, LIST3, LIST4, LIST5, AVATAR, colors5, welcomeTitle, makeContainer, tagsWithTitles, containers };
