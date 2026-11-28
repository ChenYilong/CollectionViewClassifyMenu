/**
 * The data of the tag cloud demo (CYLTagCloudDemoViewController): the upper list created the android-tagview way
 * (the continents, a detailed tag, the styled tags) and the configuration of the lower list. No `wx` calls.
 */
const { t } = require('../../utils/i18n.js');
const model = require('cyl-tag-list-miniprogram/cyl-tag-cloud/model.js');

/** The continents of android-tagview's sample. */
const CONTINENTS = ['Asia', 'Africa', 'North America', 'South America', 'Antarctica', 'Europe', 'Australia'];

/** android-tagview's "add a tag in details": every look property of its Tag. */
function detailedTag() {
  return model.makeTag('Tag Text', {
    identifier: 7,
    backgroundColor: model.color('#DDDDDD'),
    textColor: '#FFFFFF',
    highlightedBackgroundColor: model.white(0.33),
    cornerRadius: 20,
    textSize: 14,
    borderWidth: 1,
    borderColor: '#FFFFFF',
    isDeletable: true,
  });
}

/** A horizontal gradient, as android-tagview's custom background drawable (systemPurple to systemTeal). */
const BACKGROUND_IMAGE = `linear-gradient(to right, ${model.NAMED_COLORS.systemPurple}, ${model.NAMED_COLORS.systemTeal})`;

/** Tags that show the rest of android-tagview's Tag: deletable, a larger text, a background image, a delete icon. */
function styledTags() {
  return [
    model.makeTag(t('可删除'), {
      backgroundColor: model.color('#00BFFF'),
      textColor: '#FFFFFF',
      borderWidth: 0,
      isDeletable: true,
      highlightedBackgroundColor: model.rgba(0, 0.5, 0.7),
    }),
    model.makeTag(t('大字号'), {
      backgroundColor: model.NAMED_COLORS.systemOrange,
      textColor: '#FFFFFF',
      textSize: 22,
      borderWidth: 0,
    }),
    model.makeTag(t('背景图'), { backgroundImage: BACKGROUND_IMAGE, textColor: '#FFFFFF', borderWidth: 0 }),
    model.makeTag(t('自定义删除'), {
      backgroundColor: model.NAMED_COLORS.systemPink,
      textColor: '#FFFFFF',
      borderWidth: 0,
      isDeletable: true,
      deleteIndicatorTitle: '⊗',
      deleteIndicatorColor: model.white(1, 0.8),
      deleteIndicatorSize: 18,
    }),
  ];
}

/** The upper list: `CYLTagListView()` with lineSpacing 5, interitemSpacing 3, tagContentInsets {3, 10, 3, 10}. */
function codeList() {
  const style = model.defaultStyle();
  style.backgroundStyle = 'liquidGlass';
  style.lineSpacing = 5;
  style.interitemSpacing = 3;
  model.setTagContentInsets(style, { top: 3, left: 10, bottom: 3, right: 10 });
  const tags = CONTINENTS.map((title) => model.makeTag(title)).concat(detailedTag(), styledTags());
  return { style, tags };
}

/** The configuration of the lower list: the same kinds of tags, as strings and dictionaries. */
function mapConfiguration() {
  const blue = {
    normal: { backgroundColor: '#00BFFF', textColor: '#FFFFFF', borderWidth: 0, cornerRadius: 1000 },
    highlightedBackgroundColor: '#88363636',
  };
  return {
    style: { lineSpacing: 5, interitemSpacing: 3, tagContentInsets: '{3, 10, 3, 10}' },
    scrollEnabled: false,
    tags: ['Asia', 'Europe',
      { title: 'Africa', id: 3, deletable: true, style: blue },
      { title: 'Australia', image: 'system:globe' }],
  };
}

/** SF Symbols of the configuration as the example's images. */
const SYMBOLS = { 'system:globe': '/images/samples/globe.png' };

/** The lower list built from its configuration (`CYLTagListView(configuration:)`). */
function mapList() {
  const configuration = mapConfiguration();
  const style = model.styleFromConfiguration(Object.assign({ backgroundStyle: 'liquidGlass' }, configuration.style));
  const tags = configuration.tags.map((item) => {
    const tag = model.tagFromConfiguration(item);
    if (tag.image) tag.image = SYMBOLS[tag.image] || tag.image;
    return tag;
  });
  return { style, tags };
}

module.exports = { CONTINENTS, detailedTag, styledTags, codeList, mapConfiguration, mapList };
