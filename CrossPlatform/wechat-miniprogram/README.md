# WeChat Mini Program example

The Mini Program example of CollectionViewClassifyMenu, a 1:1 port of the iOS example (`Example/CYLMenuExample`,
the reference, `docs/cross-platform.md`): the same screens, texts (the iOS example's and the core's string tables),
data and behaviors. Its shell is CYLTabBarController's Mini Program tab bar (`cyl-tab-bar` of
`cyl-tabbar-miniprogram`) set up as the iOS example's `makeRootTabBarController()`.

| iOS screen | Page | What it shows |
| --- | --- | --- |
| Root tab bar | `custom-tab-bar/` | 场景一：评价筛选, 场景二：搜索分类, the orange plus button (查询筛选), 样式, 动效 |
| CYLProductViewController | `pages/product` (tab) | 宝贝详情: the product, 宝贝评价(10), the keyword preview, 查看更多评价 |
| CYLReviewListViewController | `pages/reviews` | The review filter (multiple choice, 全部 exclusive, folded, footer chevron), memory / network (simulated, 0.6 s) / database modes with the request or the SQL, the review cells |
| CYLSearchHomeViewController | `pages/search-home` (tab) | 脉脉搜索 and the search field button |
| CYLSearchCategoryViewController | `pages/search-category` | The search page with its own category tab bar (找人/动态/八卦/职位, `cyl-tab-bar`), the 职位 sidebar and 行业 menu |
| CYLQueryScenariosViewController | `pages/scenarios` (plus button) | 查询筛选: the filter demos by scenario and the database's row counts |
| CYLMenuLinkageViewController | `pages/classify` | 菜单选择 · 数据库联动: the core's classify menu look (data.json, two rows, 更多 / 收起), the multiple filter panel from the left (返回默认 / 确认筛选), the conditions, the SQL and the rows; saved selections |
| CYLSearchDiscoverViewController | `pages/search-discover` | 最近搜索 folded to two rows with the chevron as the last tag, 发现 two per row, 换一批 (seedable) |
| CYLTagStyleDemoViewController | `pages/styles` (tab) | The preview and the 33 style actions with their values |
| CYLTagAnimationDemoViewController | `pages/animations` (tab) | The eight animation sections, speed slider (0.25×–4×), loop switch, Play all (`docs/example-demo-rules.md`) |
| CYLTagConfigurationDemoViewController | `pages/configuration` | The list from the iOS JSON file and from a dictionary |
| CYLTagCloudDemoViewController | `pages/tag-cloud` | The tag cloud built in code and from a configuration |
| CYLTagCloudSample (+ sub-screens) | `pages/sample-tag-cloud*` | The android-tagview sample: 25 tags, add, result page, list, RecyclerView, hot search |
| CYLImageTagSample (+ sub-screens) | `pages/sample-image-tag*` | Tags on a picture: groups, edit (drag, turn, delete, 创建, 保存), the list |
| CYLTagContainerSample | `pages/sample-tag-container` | The five AndroidTagView containers |

Deviations that a Mini Program imposes (no SF Symbols, no SQLite, no UIKit bar buttons, no PAG/Rive engines within
the 2 MB main package, no VoiceOver announcements) are listed per screen in `docs/cross-platform.md`.

## Layout

```
wechat-miniprogram/
├── project.config.json          appid "touristappid"; set an AppID in the git-ignored project.private.config.json
├── package.json                 `npm test` runs the unit tests; depends on the library below (file:)
├── packages/
│   └── cyl-tag-list-miniprogram/ the npm library: cyl-tag-list, cyl-tag-cloud, cyl-tag-image, locale.js, the core
│                                strings (miniprogram_dist; README.md for install and use)
├── scripts/
│   ├── fetch-cyltabbar.js       installs CYLTabBarController's cyl-tabbar-miniprogram and cyl-lottie-miniprogram (its
│   │                            lottie-miniprogram fork, which draws image assets) at the pinned commit (git-ignored)
│   ├── export-search-data.py    the search discover JSON and images of the iOS bundle
│   ├── export-animations.py     the iOS example's Lottie / GIF resources and configuration file
│   ├── draw-sample-images.py    the samples' pictures
│   └── verify-package.js        npm pack the library, check the tarball, install it for Build npm
├── test/                        node --test: models, queries, pages and components without wx
└── miniprogram/
    ├── app.json / app.wxss      the pages; UIKit-like shared styles (inset grouped tables)
    ├── custom-tab-bar/          cyl-tab-bar with the root tab bar's configuration (configuration.js)
    ├── components/
    │   ├── cyl-lottie-icon/     one animated icon (Lottie, Rive, PAG, GIF), given to cyl-tag-list as
    │   │                        generic:cyl-animation-icon
    │   └── cyl-sample-toast/    the samples' toast
    ├── miniprogram_npm/         git-ignored: Build npm's copy of cyl-tag-list-miniprogram
    ├── data/                    generated: places, reviews, data.json, the iOS and core strings, animations, search
    ├── images/                  core, tab, symbols, reviews, search, styles and samples images
    ├── pages/                   one folder per iOS screen (the table above)
    ├── styles/                  shared sample styles
    └── utils/                   i18n.js (t, tc), tag-animations.js (the engines, registered with the library),
                                 places-db.js, selections.js, android-sample.js
```

## Run

1. `node scripts/fetch-cyltabbar.js` in this folder: it checks CYLTabBarController out at the pinned commit into
   `.deps/` and copies its tab bar and its Lottie fork to `miniprogram/cyl_components/`. WeChat DevTools rejects
   `touristappid`: put an AppID (CYLTabBarController's examples use `wx5e29c9d33906f074`) in a git-ignored
   `project.private.config.json` (`{"appid": "wx…"}`).
2. `npm install` in this folder (links `cyl-tag-list-miniprogram` from `packages/`).
3. Open this folder in WeChat DevTools (or `wechatide -c <client> project_import --project <this folder>`).
4. Tools → Build npm (工具 → 构建 npm; `wechatide -c <client> build_npm --project <this folder>`), then compile. Launch options for screenshots, like the iOS example's `-CYLExampleScreen`:
   `pages/animations/animations?autoplay=1`, `pages/classify/classify?select=0-1&filter=0-2,0-4,1-2,1-3`
   (plus-menu-filtered), `pages/reviews/reviews?mode=database&select=1,4` (plus-reviews-db),
   `pages/search-discover/search-discover?seed=2026` (plus-discover-refreshed).

Checks: `npm test` (Node 18+, after `npm install`); `npm run verify-package` packs the library as npm publishes it
and installs the tarball (run Build npm afterwards; `node scripts/verify-package.js --restore` relinks); from the repository root `python3 scripts/export-miniprogram-data.py --check`; in this
folder `python3 scripts/export-search-data.py --check` and `python3 scripts/export-animations.py --check` (Pillow).
WXSS has no `*` selector: one in any file stops every page from compiling.
