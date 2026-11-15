/**
 * cyl-tag-list-miniprogram: the tag list, the tag cloud and the image tag of CollectionViewClassifyMenu for WeChat
 * Mini Programs. The components are used by path (usingComponents):
 *
 *   "cyl-tag-list":  "cyl-tag-list-miniprogram/cyl-tag-list/cyl-tag-list"
 *   "cyl-tag-cloud": "cyl-tag-list-miniprogram/cyl-tag-cloud/cyl-tag-cloud"
 *   "cyl-tag-image": "cyl-tag-list-miniprogram/cyl-tag-image/cyl-tag-image"
 *
 * This module gathers their models and settings for scripts.
 */
module.exports = {
  tagList: require('./cyl-tag-list/model.js'),
  tagCloud: require('./cyl-tag-cloud/model.js'),
  tagImage: require('./cyl-tag-image/model.js'),
  symbols: require('./cyl-tag-list/symbols.js'),
  animations: require('./cyl-tag-list/animations.js'),
  locale: require('./locale.js'),
  coreStrings: require('./core-strings.js'),
};
