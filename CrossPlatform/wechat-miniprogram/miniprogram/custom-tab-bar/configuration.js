/**
 * The tab bar of the example, in CYLTabBarController's configuration keys (its docs/Configuration-File.md): the tabs
 * Tags and Classify and the raised Post button with a page of its own between them, as in the React Native example
 * (`example/src/App.tsx`: CYLTabBarController's CYLPlusButtonSubclass, centerYOffset -14). Images are relative to
 * /images (the `image-base-path` of custom-tab-bar/index.wxml); a Mini Program has no SF Symbols.
 */
const ITEMS = [
  {
    CYLTabBarItemTitle: 'Tags',
    CYLTabBarItemImage: 'tab/tag.png',
    CYLTabBarItemSelectedImage: 'tab/tag_selected.png',
    CYLTabBarItemIdentifier: 'tags',
  },
  {
    CYLTabBarItemTitle: 'Classify',
    CYLTabBarItemImage: 'tab/grid.png',
    CYLTabBarItemSelectedImage: 'tab/grid_selected.png',
    CYLTabBarItemIdentifier: 'classify',
  },
];

const PLUS_BUTTON = {
  CYLTabBarItemTitle: 'Post',
  CYLTabBarItemImage: 'tab/post_normal.png',
  CYLTabBarItemSelectedImage: 'tab/post_highlight.png',
  CYLTabBarItemIdentifier: 'post',
  CYLTabBarItemPageIdentifier: 'post',
  CYLPlusButtonIndexInTabBar: 1,
  CYLPlusButtonSize: '{55, 80}',
  CYLPlusButtonImageSize: '{55, 55}',
  CYLPlusButtonCenterYOffset: -14,
  CYLPlusButtonAlignsTitle: true,
  CYLPlusButtonShowsSelection: true,
};

const CONFIGURATION = {
  CYLTabBarControllerContext: 'CYLTagListMiniProgram',
  CYLTabBarControllerThemeIdentifier: 'light',
  CYLTabBarControllerThemes: {
    light: { CYLTabBarItemSelectedTitleColor: '#2AB9A0', CYLTabBarItemTitleColor: '#8E8E93' },
  },
  CYLTabBarControllerTabBarItemsAttributes: ITEMS,
  CYLTabBarControllerPlusButton: PLUS_BUTTON,
};

/** The page of a tab or of the plus button: pages/<identifier>/<identifier>. */
function pagePath(identifier) {
  return `/pages/${identifier}/${identifier}`;
}

/** The identifier of a page route ("pages/classify/classify" -> "classify"). */
function identifierForRoute(route) {
  const match = /^\/?pages\/([^/]+)\//.exec(route || '');
  return match ? match[1] : '';
}

module.exports = { CONFIGURATION, pagePath, identifierForRoute };
