# Findings at 03707ba2 (nothing was built or run)

Confidence: "source-checked" = the lines were compared again against the source; "by reading" = seen while reading, effect
not demonstrated. Re-check the source before acting.

| # | Finding | Evidence | Confidence |
|---|---|---|---|
| 1 | Android menu linkage example queries with localized titles; expect no rows in English. iOS, HarmonyOS, mini program, Flutter, RN use source titles | android/merged/example/.../menu/CYLQueryScenarios.kt:322,334,363; ClassifyDemoDataSource.kt:117,125; correct uses: ClassifyMainFragment.kt:150, FilterDemoFragment.kt:191; iOS CYLMenuLinkageViewController.swift:149,170,184,222; CYLMenuLinkagePage.ets:184,219,239 | source-checked |
| 2 | RN iOS UI test and e2e-android.sh expect English UI text but Chinese data titles; no locale set. Titles were localized (76d70415e, 11-19) after the tests' last change (5d5133f17, 11-15) | CylTagListExampleUITests.swift; scripts/e2e-android.sh; example/src/ClassifyPage.tsx, i18n.ts. Stale docs: docs/cross-platform.md:479 still records e2e-android.sh as PASS, and docs/example-demo-rules.md marks React Native done on 11-15, both before that change | by reading |
| 3 | Flutter RunnerTests.swift (stock template) calls CylTagListPlugin().handle, which the class lacks; no script or CI found that builds it | RunnerTests.swift; CylTagListPlugin.swift:6, private handle at :82 on the platform view | source-checked |
| 4 | check-doc-comments.py globs only *.h in the core and TagCollectionView; no tracked file matches | scripts/check-doc-comments.py:24-27 | source-checked |
| 5 | Four CYLTabBarController pins; the pubspec comment says gradle.properties has the same pin (it does not); the pin check covers 4 Podfiles and the pubspec only. The iOS/Windows split is recorded as in progress, target dd691795 | table in 01; scripts/cyl-tabbar-latest-commit.sh; docs/todo/20261104/next-merge-windows-work-get-ci-green-land-on-master.md | source-checked |
| 6 | Mini program cyl-tag-cloud: _renaming is a position; removeTag, onDelete, insertTag, replaceTags, drag move neither update nor end it, so finishRenaming can rename another tag. Component is planned for removal (05) | cyl-tag-cloud.js: removeTag 230, replaceTags 245, finishRenaming 406, drag 699, onDelete 799 | source-checked |
| 7 | Mini program cyl-tag-image: _timers keyed by group index; removeTagGroup splices without re-keying, so a later stop or start at an index can hit another group's timer | cyl-tag-image.js:93-97, 262-283 | by reading |
| 8 | CYLTag.copy() drops subtitle | CYLTag.swift copy at 291; CYLTag.kt:128; CYLTag.ets:164 | source-checked |
| 9 | Wrapped item height counts the delete indicator but not the rename icon | CYLTagListView.swift:2565-2574; CYLTagListView.kt:1078-1089; CYLTagListState.ets:3130-3139 | by reading |
| 10 | Configuration data source implements remove but not move, so configuration-built lists cannot reorder | CYLTagListView+CYLConfiguration.swift:1035; CYLTagListViewConfiguration.kt:677; CYLTagListState.ets:3688 | source-checked |
| 11 | HarmonyOS canMoveItem has no caller; canReorderItem returns canReorder and moveItem checks only that, so the create cell or a non-editable section may be draggable | CYLTagListState.ets:2441, 2590, 2643 | source-checked (behavior not shown) |
| 12 | Android moveItem checks only canReorder(); finishDrag does not exclude the create cell as target | CYLTagListView.kt:1626, 2389 | by reading, effect unknown |
| 13 | Flutter HarmonyOS plugin has no applyConfiguration case | CylTagListOhosPlugin.ets:82-102 | source-checked |

## Minor / lower confidence
- HarmonyOS CYLReviewStore .catch calls completion([]) without a superseded check.
- RN CylTagListView.mm has no prepareForRecycle.
- Dart _CylTagListViewState has no didUpdateWidget (maybe intended).
- Examples: avatar downloads keyed by position (iOS CYLTagContainerSample; Android lujun samples, which also sleep 50 ms
  per tag on the main thread). Android review list: a pending 600 ms request can overwrite after a mode switch.
  TagImageView toggle hint set with setTag while accessibilityDelegate is null (likely silent in TalkBack).
- Stale comments: HarmonyOS CYLTagAnimatedIcon.ets (fe5c3ae) vs Index.ets (618ac11a); a HarmonyOS test comment says a
  6 vp gap while HEADER_ITEM_SPACING is 8. Misplaced doc comments in CYLTagListView (renamesOnTitleTapWhileEditing above
  renameRequestHandler) and CYLTagButton (editing indicators view, delete width, bounds/center, contentSizeThatFits).
- Mini program places-db.js statement() comment says it is the SQL shown on the page, but the page shows
  menu-linkage.js query(); an animated-item "every page" test checks 3 of 4 engine components.
- AGENTS.md calls the repo an Objective-C demo.

## Dropped
Android CYLReviews getOrNull(id) looked like an index bug; it is fine because review ids are 0-based
(scripts/generate-places-db.py:96-97).

## Second pass: vendored modules and related files (added after reading them)
Traced by reading and grep; none was run. "Dormant" = needs an option or call that nothing in this repository was found to
use; an app that uses the library can still hit it. V7 and the classifymenu part of V1 are CVCM's own files; fixing only
the upstream player would not fix that adapter (the repo's core-first rule applies to it). Vendored findings are as of the pins in 11; whether upstream has
since changed them was not checked.

| # | Finding | Evidence | Reach here |
|---|---|---|---|
| V1 | HarmonyOS pause-while-scrolling does not pause. The item sends speed 0, but the player's speed setter turns 0 or less into 1. A speed other than 1 drops to 1 while "paused"; didPause is still posted. All five engine views go through this path (Rive has no speed at all). With drivesPlayback false nothing is applied either. A custom animationBuilder gets the unpaused speed | CYLAnimatedItemView.ets:1175, 1201, 1385-1404, 1499; CYLAnimatedItemPlayer.ts:67, 285-286, 387; binding.update: GIF.ets:92, SVGA.ets:133, PAG.ets:74, CYLAnimatedItemRive.ets:726, CYLAnimatedItemLottie.ets:186; the classifymenu adapter clamps too: CYLAnimationPlayer.ets:156, CYLTagAnimatedIcon.ets:302. A test pins "speed 0 or less is 1" | Dormant: flag default false (View.ets:464), no caller of cylSetPausesWhileUserScrolls found |
| V2 | Mini program playing-set is incomplete. (a) The default autoplay-on-ready path sets cylIsPlaying but never calls cylAnimationDidStart: no didStart/didStop, and pauseAnimation() returns false and does nothing for it. (b) Deselection and stopAtProgress halt the engine but leave the item in the set, so after a later pause/resume cyl_play() is called on a halted item. (c) The example wrapper's cyl_play() is cyl_playFromStart(), so "resume" restarts there. cyl-lottie (fetched, untracked) resumes the frame and cyl-rive sets playing; PAG and SVGA engines were not available. The cyl-lottie / cyl-rive behavior is from the local fetched copies at 41660d24, not the pin b5b36fbf | index.js:772 (autoplay), 452 and 1048 (halt), didStart only 789/794/806, didStop only 831-833/926; cyl_animation_events.js:41, 53; cyl-tag-animation-view.js:138 | Dormant: no caller of pauseAnimation or cylPausesAnimationsWhileUserScrolls found |
| V3 | A lifecycle controller torn down during a scroll never fires scrollDidEndScrolling: LifecycleCenter.isUserScrolling stays true until the owner is collected, and whileUserScrolls resume does not run until another scroll ends. In the mini program, without WeakRef it does not clear by collection | harmony controller.ts:127-134, center.ts:39-44, 74-83; mini program controller.js:87-97, center.js:12-13 | Resume part dormant (only the opt-ins above use it); isUserScrolling is public |
| V4 | HarmonyOS Lottie with an http(s) file reports ready, and so onLoaded, before the download ends, so the still image is hidden while nothing is drawn yet; a later data_failed reports the failure | CYLAnimatedItemLottie.ets:198-206, 244-250; CYLAnimatedItemPlayer.ts binding.ready | Any remote Lottie source (visual effect not observed) |
| V5 | cylRiveFileAndOptions calls decodeURIComponent unguarded; a malformed % escape throws. CYLAnimatedItemSource guards the same call | CYLRiveIcon.ets:112; CYLAnimatedItemSource.ts:43-49 | Needs a malformed option |
| V6 | Stale comments: divider "alpha 0.3" (code 0.6); glassTint "default alpha 0.5" (constant #1AE1DEDC, about 0.10) | CYLAnimatedItemView.ets:731 vs CYLAnimatedItemColors.ts:216; CYLAnimatedItemBackground.ets:116 vs :42 | Documentation only |
| V7 | AGENTS.md, CLAUDE.md and docs/instructions/harmonyos.md still describe a debug-build guard for the x86_64 Rive/PAG kit; vendored comments and READMEs say it was removed with the owner's approval on 2026-11-23 and it also works in release builds. The approval itself cannot be checked from the repo | AGENTS.md:97, CLAUDE.md:28, harmonyos.md:48-50; CYLAnimatedItemView.ets:236-247; cylanimateditem/README.md:145 | Rule text out of date, or a question for the owner |
| V8 | The vendored SVGA decoder test cannot pass here: its zlib-comparison case uses upstream's depth ('../../../..' resolves above this repo) and CrossPlatform/harmonyos-cyltabbar paths. Similar .svga files are under harmony/entry/src/main/resources/rawfile/svga | CYLAnimatedItemSVGADecoder.test.mjs:20, 127-130 | No workflow here runs it |

Observation, not counted as a bug: cylanimateditem uses glass brightness 1.05 in both modes (Background.ets:133,
View.ets:1680) and its DARK_BRIGHTNESS (CYLLiquidGlass.ets:30) is unused, while cylliquidglass uses 0.9 in dark
(:62, :115). The mini program uses 1.05 on purpose and calculates its contrast floor from it.
