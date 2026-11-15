/**
 * The root tab bar of the example, 1:1 with the iOS example's `CYLExampleAppDelegate.makeRootTabBarController()`,
 * in CYLTabBarController's configuration keys (its docs/Configuration-File.md): 场景一：评价筛选, 场景二：搜索分类,
 * 样式 and 动效, with the plus button (`CYLExamplePlusButton`: an orange plus.circle.fill without a title, at index 2,
 * selected like a tab) in the middle; it opens the scenario list (查询筛选). Titles are the iOS example's strings
 * (utils/i18n.js); images are drawn stand-ins for the SF Symbols, relative to /images.
 */
const { t } = require('../utils/i18n.js');

function items() {
  return [
    {
      CYLTabBarItemTitle: t('场景一：评价筛选'),
      CYLTabBarItemImage: 'tab/cart.png',
      CYLTabBarItemSelectedImage: 'tab/cart_fill.png',
      CYLTabBarItemIdentifier: 'product',
    },
    {
      CYLTabBarItemTitle: t('场景二：搜索分类'),
      CYLTabBarItemImage: 'tab/magnifyingglass_circle.png',
      CYLTabBarItemSelectedImage: 'tab/magnifyingglass_circle_fill.png',
      CYLTabBarItemIdentifier: 'search-home',
    },
    {
      CYLTabBarItemTitle: t('样式'),
      CYLTabBarItemImage: 'tab/paintbrush.png',
      CYLTabBarItemSelectedImage: 'tab/paintbrush_fill.png',
      CYLTabBarItemIdentifier: 'styles',
    },
    {
      CYLTabBarItemTitle: t('动效'),
      CYLTabBarItemImage: 'tab/sparkles.png',
      CYLTabBarItemSelectedImage: 'tab/sparkles_selected.png',
      CYLTabBarItemIdentifier: 'animations',
    },
  ];
}

function plusButton() {
  return {
    CYLTabBarItemImage: 'tab/plus_circle_fill_orange.png',
    CYLTabBarItemSelectedImage: 'tab/plus_circle_fill_orange.png',
    CYLTabBarItemIdentifier: 'plus',
    CYLTabBarItemPageIdentifier: 'scenarios',
    CYLPlusButtonIndexInTabBar: 2,
    CYLPlusButtonImageSize: '{44, 44}',
    CYLPlusButtonShowsSelection: true,
  };
}

/** The configuration in the current language. */
function configuration() {
  return {
    CYLTabBarControllerContext: 'CYLMenuExampleRoot',
    CYLTabBarControllerThemeIdentifier: 'light',
    CYLTabBarControllerThemes: {
      // UIKit's defaults: systemBlue selected, systemGray otherwise.
      light: { CYLTabBarItemSelectedTitleColor: '#007AFF', CYLTabBarItemTitleColor: '#8E8E93' },
    },
    CYLTabBarControllerTabBarItemsAttributes: items(),
    CYLTabBarControllerPlusButton: plusButton(),
  };
}

const CONFIGURATION = configuration();

/** The page of a tab or of the plus button: pages/<identifier>/<identifier>. */
function pagePath(identifier) {
  return `/pages/${identifier}/${identifier}`;
}

/** The identifier of a page route ("pages/search-home/search-home" -> "search-home"); the plus button's page is "plus". */
function identifierForRoute(route) {
  const match = /^\/?pages\/([^/]+)\//.exec(route || '');
  if (!match) return '';
  return match[1] === 'scenarios' ? 'plus' : match[1];
}

module.exports = { CONFIGURATION, configuration, pagePath, identifierForRoute };
