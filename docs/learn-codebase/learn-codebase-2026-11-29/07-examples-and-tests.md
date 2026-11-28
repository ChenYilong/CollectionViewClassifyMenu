# Examples and tests

Per-file detail: api-reference/*-examples.md and *-tests.md. NONE of these tests were run in this pass.

## iOS
- Example/CYLMenuExample: root tabs via CYLTabBarController plus a plus button; launch a screen with
  -CYLExampleScreen (with a layout report). CYLExampleDatabase copies cyl_places.sqlite and stores selections. Menu
  linkage, product and review pages (memory / network / database queries), query scenarios, search pages, tag
  animation / cloud / configuration / container / style demos, ports of the three Android samples, word picker.
- Example-Swift: tag editor (fold styles, remark, CYLTagStore).
- Example-Shared/TestSupport: six protocol helpers. CYLTagListProbe is the only KVC access to core private views.
- Tests run XCTest inside windows of the host app. Golden frame snapshots use sectionStyle = .plain
  (CYLTagListDefaultFramesTests). Modified truck.riv and house.riv are pinned by SHA-256. Upstream regressions
  (#1, #7, #13, left-aligned layout PRs). An every-screen language test (en, zh-Hant).
- Root test files: CYLClassifyMenuDemoTests.swift, two Objective-C layout tests, one Swift left-aligned layout test.

## Android
Robolectric, often GraphicsMode NATIVE. Glass is forced with CYLAnimatedItemView.liquidGlassActiveOverride. Because the
default section style is insetGrouped, frame tests call usePlainSections(). Golden default frames, RTL mirroring,
upstream-issue regressions; two device tests (editing icons, title fit).

## HarmonyOS, mini program, Flutter, React Native
See 04, 05, 06. Flutter has two integration tests (21 tags in the animation list; database classify and filter).
React Native has Jest tests, an iOS UI test and scripts/e2e-android.sh (accessibility labels, no coordinates).

## Test gaps seen for the findings in 09
No test read covers CYLTag.copy() subtitle or rename icons in wrapped height. HarmonyOS
enablesReorderingOfEditableSections asserts only canMoveItem, which has no runtime caller. No Android test drags onto
the create cell. No Android test matches "linkage". Mini program rename tests never remove, insert or move while
renaming (one test is named for a reorder but performs none); the image test removes a group only with no animation.
