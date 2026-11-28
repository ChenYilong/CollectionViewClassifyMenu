# WeChat mini program (CrossPlatform/wechat-miniprogram)

Per-declaration detail: api-reference/miniprogram-library-part1.md to miniprogram-library-part2.md.

## Package: packages/cyl-tag-list-miniprogram/miniprogram_dist (hand-written source)
package.json sets "miniprogram": "miniprogram_dist"; scripts/verify-package.js packs it directly. Folders with a COMMIT
file are vendored (cyl-animated-item, cyl-animation-placeholder, cyl-dealloc-block-executor), fetched by
scripts/fetch-cyltabbar.js. core-tables.js and core-strings.js hold the core's tables and strings.
- cyl-tag-list: model.js is free of wx calls and mirrors CYLTagListView(configuration:): value parsers, style defaults
  (tag background #F2F2F7, dark #1C1C1E, app tint #2AB9A0, sectionStyle insetGrouped, direction auto acts as ltr),
  merge/normalize, long-press decision, selection and tap rules, fold from measured row tops, tag CSS (tagLayout),
  section geometry (contentColumn / boardColumn / tagColumn), glass card, tint resolution against the real background.
  The component measures rows with boundingClientRect. This list does not reorder.
- theme.js rebuilds the model on system theme change, so unset colors follow it.
- cyl-tag-button: one tag. cyl-tag-cloud: port of the tag cloud and tag container presets with editing, rename, tail
  fold, smear, drag reorder, ripple. cache.js ports CYLTagListStore and the load policies.
- cyl-tag-image: image tag geometry model and a setInterval-animated component.
- PLANNED CHANGE (docs/tag-gesture-migration.md, 2026-11-25): merge cyl-tag-cloud into cyl-tag-list and delete it;
  the doc records the owner's decision. At 03707ba2 cyl-tag-cloud still exists. Check this before fixing bugs in it.

## Example app (miniprogram/)
One-to-one mirror of the iOS example. Page logic sits in modules without wx calls (menu-linkage.js, discover-model.js,
reviews query/store) so node --test can run it. SQLite is emulated in JavaScript (utils/places-db.js).
menu-linkage.js queries source titles; localizedTitle is for display only. The reviews page drops stale responses
(query identity check plus cancel()).
Generated (never edit): data/strings.js, data/places.js, lottie and animation data, classify-menu.js, animations/index.js.
Scripts: draw-sample-images.py, export-animations.py, export-search-data.py, fetch-cyltabbar.js, verify-package.js.

## Tests (test/*.test.js, node --test)
Cover models and component logic with hand-written Component / setData stand-ins; I saw no automated DevTools run.
tag-glass-border and tag-list-fold-title-and-icon (and tag-tail-fold-style) say "Written statically, not yet run".
