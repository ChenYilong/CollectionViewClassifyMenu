# learn-codebase CVCM @03707ba2 (read-only)
## 1 iOS core (CollectionViewClassifyMenu/Class/**/*.swift) - READ IN FULL (xib/strings excluded)
- CYLTag/CYLTagDataSource; CYLTagAppearance (explicit vs built-in colors, border explicitness for glass); CYLTagColors themes; CYLMenuStyle (presets tagCloud/tagContainer/gridStyle/wordPicker/classify/filter/sectionTitle; section card/header band/divider; copy() lists every property).
- CYLTagListView: caches titles/widths/heights/rows; one column function (column/boardColumn/tagColumn); CYLTagListHeaderRoom; fold none/footer/header*/tail; editing, rename, cache/remote load, smear, reorder (movingItem/measuredIndexPath), callout in window.
- CYLTagButton: CYLAnimatedItemView subclass, color channels + indicator color roles. Layout/Card: CYLTagListLayout decoration card (glass via CYLAnimatedItemView).
- Cache: sqlite/defaults/file; items stored in "<section>#items" with US separator. LongPress actions reorder/report/callout/none/handler/first.
- ImageTag group/view; legacy ClassifyMenu VC + MultipleFilter keep ObjC KVC names; demo files in core folder (DemoDataSource, FilterDemo, Main, AppDelegate, DBManager, DemoLocalization).
Observations (unverified, minor): copy() of CYLMenuStyle omits nothing obvious; CYLTag.copy() skips backgroundColor reassignment (passed via init) ok. CYLTagListStore.removeAllTitles for database also fine. CYLTagListView.measureItemHeights passes no showsRenameIndicator to height(forTitle:...).
## TODO order
2 harmony/classifymenu; 3 android/merged core+tests; 4 miniprogram src; 5 flutter, RN; 6 harmony entry, iOS/Swift/Android examples+tests; 7 TagCollectionView, android upstream ports; 8 scripts/workflows/podspec/Package.swift; 9 report

## 2 harmony/classifymenu - READ IN FULL
- core/ + components/: CYLTagListState = UI-free model/controller (data, fold, measure, layoutSections frames, cache, rename, smear, reorder, RTL, config); CYLTagListView renders absolute frames in Scroll; CYLMenuGestureState.shared stops container scroll.
- tagviews/: CYLTagButton (@Observed state+manual layoutSubviews; colour channels explicit/builtIn -> CYLAnimatedItemColorResolver; glass tint only explicit; CYLTagButtonComponent/Host), ListCell (performTapAt: rename/delete hit areas), FoldButton/FoldCell, CreateCell, legacy TagView.
- classify/: ClassifyMenu VC+view, left-aligned layout, filter base panel (backdropBlur, back-press hook), MultipleFilter (exclusive rules), IndexPathButton, header views, ParamsTool, Log.
- imagetag/: GroupView (timer animations), pure geometry in CYLImageTagModel, ImageTagView (collision separation).
## Candidate findings (reading only, untested)
- CYLTag.copy() omits subtitle (iOS + Harmony).
- measureItemHeights passes delete indicator but not rename icons to wrapped height (iOS + Harmony).
- TagListConfigurationSource: menuRemoveItem but no menuMoveItem (both).
- Harmony: canMoveItem has NO caller (grep of classifymenu/src); drag uses canReorderItem=canReorder, moveItem checks only canReorder -> create item / non-editable section may be draggable. iOS enforces via collectionView(canMoveItemAt:).
- Stale comment: CYLTagAnimatedIcon.ets says vendored fe5c3ae, Index.ets says 618ac11a.
- iOS misplaced doc comments: CYLTagListView renamesOnTitleTapWhileEditing; CYLTagButton editingIndicatorsView, delete width, bounds/center, contentSizeThatFits.

## 3 android/merged (reading lite: import + [CN] lines skipped)
- READ: library cyl/classifymenu Types, Keys, DataSource, Tag, Appearance, Colors, MenuColor, FoldControl, Resources, Style, Cache, LongPressAction, ParameterConfiguration.
- Android mirrors iOS API names; Context-based storage; night-mode resolved from context (CYLSystemColors).
- Finding: Android CYLTag.copy() ALSO omits subtitle -> all of iOS/Harmony/Android.
- READ (cont.): CYLTagListView.kt (all), CYLTagButton, AddItemView, ListViewConfiguration (all), CYLTagView, cells, ClassifyMenu part 1.
- Android reorder: canMoveItemAt DOES check create item + section editability (so Harmony's missing guard is Harmony-only). moveItem checks only canReorder(); finishDrag picks nearest cell in same section, create cell not excluded as a target (unverified effect).
- Android heightsForItems also passes only the delete indicator (not rename) to heightForTitleWidth -> same on all 3.
- Android CYLTagListConfigurationSource overrides remove but not move/supportsMovingItems.
- DONE: all of android/merged/library cyl/classifymenu main (views, ClassifyMenu, filter, image tags).
- DONE: Android ports co/lujun/androidtagview, com/licrafter/tagview, me/kaede/tagview (merged copies = standalone ports except R imports). Android tests + example still TODO (after cores).
- Ports are classic custom Views (TagContainerLayout canvas-drawn TagView; TagViewGroup dot+lines; kaede RelativeLayout) with upstream issue fixes annotated "#N".
## 4 mini program - miniprogram_dist IS the source (no src); vendored subfolders with COMMIT = cyl-animated-item, cyl-animation-placeholder, cyl-dealloc-block-executor. Reading full (real line numbers).
- MP read: index, locale, cyl-tag-list (model.js full: color/config parsing, style, tap/fold, tagLayout CSS, section geometry; component measures rows via boundingClientRect; wxml/wxss), theme, animations, symbols, cyl-tag-button. cyl-tag-list does NOT reorder (cyl-tag-cloud does).
- MP cyl-tag-cloud read (model.js, component js). CANDIDATE (read only, untested): _renaming is a raw position; removeTag/onDelete/insertTag/replaceTags/drag move don't update or end it, so finishRenaming may rename a different tag.
- MP core COMPLETE (cache.js, editing-icons, cyl-tag-image model/component/wxml/wxss too). CANDIDATE: cyl-tag-image _timers keyed by group index; removeTagGroup splices without re-keying, so a later _stopAnimation(i) can cancel/miss another group's running animation.
- MP remaining (step 6): example pages, engines, test/*.test.js, scripts.

## 5 flutter + RN libraries - READ IN FULL
- Flutter: Dart CylTagListView/Controller -> platform view; iOS plugin hosts Swift CYLTagListView, Android hosts android/merged (maven com.cyl:classifymenu:0.1.0), ohos package hosts harmony/classifymenu with configurationJSON. "asset:" strings resolved per platform.
- RN: Fabric view, configuration as JSON; CylTagListBridge.swift / CylTagListView.kt (manual measure+layout) ; CylTagListConfiguration.ts types.
- CANDIDATE: CylTagListOhosPlugin.onMethodCall has no 'applyConfiguration' case (iOS+Android do) -> Dart CylTagListController.applyConfiguration gets notImplemented on HarmonyOS.
- CANDIDATE (lower): Dart _CylTagListViewState has no didUpdateWidget: swapped controller never attached; new configuration prop not forwarded (maybe by design).

## 6 examples/tests
- TagCollectionView app sources (7 swift) read; its CYLTagView.swift is the old copy of core CYLTagView.
- harmony/entry main ets read in full (except generated CYLExampleStrings.ets): shell tabs, reviews (memory/network/sqlite), menu linkage SQL, search discover, style/animation/glass/config pages, Android sample ports, word picker. Sibling harmony/* non-classifymenu modules all have VENDORED.md -> vendored, excluded.
- harmony tests (src/test, src/ohosTest) TODO.
- iOS Example (CYLMenuExample), Example-Swift tag editor, Example-Shared/TestSupport read (lite). Root tab = CYLTabBarController + plus button; -CYLExampleScreen launch + layout report; SQLite copy of cyl_places.sqlite; three review query modes; three Android sample ports. Tests reach core private views only via CYLTagListProbe KVC.
  - minor example-only (unverified): CYLTagContainerSample.loadAvatars keys avatar by position, so a drag/delete before download completes can misassign it.
- scripts/*.sh|py|swift (top level), .github/workflows (ios, localization, miniprogram, screenshots), podspec, Package.swift, root Podfile, lefthook.yml READ IN FULL. CI: path<=160, shellcheck, doc comments, pin check (Podfiles + Flutter pubspec only), pod lint, warnings=0, 4 unit suites, screenshots to ci-screenshots branch.

- iOS TESTS READ (all 61 chunks, lite): CYLMenuExampleTests (+Support), Example-Swift tests, TagCollectionViewTests (.m + RowTests.swift), 4 root tests (demo app tests, core layout .m, left-aligned layout .m/.swift). XCTest in windows of the host app; core private views via CYLTagListProbe / KVC; golden frame snapshots for sectionStyle=.plain (CYLTagListDefaultFramesTests); pinned SHA256 of modified truck.riv/house.riv; upstream-issue regression tests (#1,#7,#13, left-aligned PRs); every-screen language test (en, zh-Hant). No test covers CYLTag.copy() subtitle or rename icons in wrapped-height measurement.

- ANDROID tests + example + ports' samples + build files + scripts READ (lite: import/blank/[CN]/block comments stripped). Merged example mirrors iOS (CYLTabBarController from json; pinned commit b5b36fbf in gradle.properties). Tests: Robolectric (NATIVE graphics), liquidGlassActiveOverride, usePlainSections() since default sectionStyle=insetGrouped, golden default frames, RTL, upstream-issue regressions. TagViewGroup Android = reimplementation (original GPL-3.0).
## New candidates from Android pass (untested)
- Android menu linkage (menu/CYLQueryScenarios.kt CYLMenuLinkageScreen) queries DB with menuTitleForItemAtIndexPath (LOCALIZED) instead of sourceTitle (applyFilterSelection, selectClassifyItem, restoreSavedSelection); DB holds Chinese. FilterDemoFragment/ClassifyMainFragment use sourceTitle. -> verify.
- CYLDatabaseReviewQuery: ids.mapNotNull { store.reviews.getOrNull(it) } (id as index) -> verify ids in scripts/generate-places-db.py.
- lower, example-only: CYLReviewListScreen.setMode new query object so a pending 600ms network completion can overwrite; sample avatar callbacks keyed by position + Thread.sleep(50) on main; TagImageView toggle hint via setTag with accessibilityDelegate=null (not exposed to TalkBack).
- No Android test drags onto create cell; tag editor example moveTag clamps target.

VERIFIED by source (not run): Android CYLMenuLinkageScreen localized-title query is a divergence; iOS CYLMenuLinkageViewController.swift:149,170 and Harmony CYLMenuLinkagePage.ets:184,219,239 use sourceTitle. zh-Hans unaffected (localized==source); en expected to return no rows. No Android test matches "linkage". Review-id candidate DROPPED (ids are 0-based, generate-places-db.py:96-97).

- HARMONY tests (src/test, src/ohosTest), scripts, root build files READ (lite). Hypium host tests on UI-free CYLTagListState with FIXED text measurer; UI tests accessibility-first. TagListEditing 'enablesReorderingOfEditableSections' asserts canMoveItem only (no runtime caller) -> doesn't cover the drag guard candidate. No test of CYLTag.copy subtitle or rename icons in wrapped height.

- MINI PROGRAM example (pages, components, tab bar, utils, scripts, all test/*.test.js) READ (lite). 1:1 mirror of iOS example; page logic in wx-free modules tested with node --test using hand-written Component/setData stand-ins (no automated DevTools run seen). SQLite emulated in JS. menu-linkage.js queries SOURCE titles (parity with iOS; Android-only divergence stands). tag-cloud-renaming tests never remove/insert/move while renaming; tag-components image test calls removeTagGroup only with no animation running -> both MP candidates uncovered by tests.

- FLUTTER example (lib, integration_test, iOS Runner + RunnerTests, tool, build files) and RN (src test, example src+tests, UITests, android/iOS shell, scripts, CI, lefthook, harmony-example ets/cpp/js/setup.sh), remaining Podfiles, flutter Package.swift/podspec READ (lite). RN CI/lefthook live under the package dir (nested .github; GitHub does not run nested workflows).
- Flutter RunnerTests.swift is the stock template: calls CylTagListPlugin().handle / getPlatformVersion; the class has no handle (private handle is on CylTagListPlatformView, :82) -> by reading, cannot compile. Not built.
- PINS (git grep): 4d0e00ae in iOS Podfiles, Package.swift, Flutter (podfile+pubspec), RN; b5b36fbf in android/merged/gradle.properties + mini program; 19cbf801 in RN harmony-example setup.sh (comment explains). pubspec comment claims gradle.properties has the same pin: it does not. Which is newer NOT checked (no fetch).
- MP _renaming rechecked: _render never ends a rename; only setEditing(false)/cancel/finish/submitNewItem do.

## PASS 2 (gap fill)
- Port block comments (deduped) + all unique import lines + the 1 stripped [CN] line READ. Lite had stripped almost nothing else. AndroidTagView port: upstream issue fixes #6,#12,#19,#24,#29,#42,#58..#123 and PR#110 documented in KDoc; TagViewGroup = Kotlin reimplementation (original GPL-3.0); kaede port fixes #10-#29, PR#21/22.

### vendored read: cyldeallocblockexecutor (harmony+MP), cylliquidglass, animation placeholder
- Lifecycle blocks per owner (identifier order, keyed replace, beforeSuper/afterSuper/end, forwarding, global LifecycleCenter). Controllers map ArkUI / wx page callbacks to iOS event names. MP copy = TS types erased to blanks; WeakRef fallback holds strongly.
- Candidate (upstream): controllers' teardown during a scroll never fires scrollDidEndScrolling (MP onUnload only clears timer; harmony aboutToDisappear) -> LifecycleCenter.isUserScrolling can stay true until GC (forever with MP strong fallback).
- cylliquidglass: isActive() always true unless activeOverride; blur+tint view.

### vendored harmony cylanimateditem (part 1: Index, Background, ColorCount+Loader, ColorResolver, Contrast, Countdown)
- Index = public surface. Background modifier: one place for flat vs drawn glass (default tint light #1AE1DEDC, dark #0AFFFFFF; capsule const 1000; glass content inset 14; default 1vp rim).
- ColorCount: oneColor/multiColor/unknown for Lottie (fl/st colors, gradients/images=multi) and GIF first frame (98% of 4-bit bucket).
- ColorResolver precedence: own > subclass-explicit > stack > subclass built-in > component built-in; adapted only on drawn DARK glass (title 4.5, icon 3); rendered glass floor 0.4 white share measured on HarmonyOS emulator.
- Countdown: end-time state machine, 250ms tick, cache "start,end,duration", clock-rollback guard.

### vendored part 2: Engine (registry of wrapped builders; creation queued 50ms apart to avoid appfreeze), GIF (fallback chain: frames->first frame->ArkUI Image cache copy->failure; <=10ms delay->100ms), Missing reporter, Player/TimedPlayer/PlaybackDriver/Binding, Resources, SVGA (+timing), Source parsing ("asset:", #/? options, inline JSON), StackView

### vendored part 3: Types registry (built-in Lottie/PAG/Rive/SVGA/GIF; PAG+Rive arm64 only; canPlay by ABI), LiquidGlass, own zlib inflate + SVGA protobuf decoder + canvas renderer (matte not supported; arc drawn as line), Lottie engine (changeColor first color only; reload to restore; destroy by name), PAG engine (timer-driven progress), cylanimateditemrive (emulator uses Canvas renderer; restart logic per input kind; cylanimateditem_rive re-exports)
- Minor candidates: Lottie engine calls binding.ready -> onLoaded immediately, even for a remote path still downloading. cylRiveFileAndOptions (CYLRiveIcon.ets) calls decodeURIComponent without try (CYLAnimatedItemSource guards it) -> bad % escape throws for callers of that export.

### vendored part 4: CYLRiveLoopPolicy, CYLAnimatedItemColors (hex parse, glass tint, tint truth table, rendering mode precedence item>url>stack, built-in colors), StackModel (items/actions/dividers/a11y rules) -- all read

### vendored part 5: CYLAnimatedItemView.ets read in full -> ALL harmony vendored sources read.
- View: static image/placeholder under animation until onLoaded; tint = SRC_IN layer in offscreen group; engine state mutated in place; countdown; scroll pause = speed 0; teardown via lifecycle block; bare/divider modes.
- Stale comments: cylInternalDivider doc says icon colour at alpha 0.3 (code uses 0.6); Background.glassTint says default alpha 0.5 (constant #1AE1DEDC = 0.10).
- With pause-while-scrolling, context.speed=0 but player speed setter maps <=0 to 1 (CYLAnimatedItemPlayer.set speed) -> default engine views would not pause on scroll (candidate; verify cylUpdateEngineState: state.speed=context.speed=0).

### vendored MP part 1: contrast (render floor 0.37, calculated not measured), countdown, player (capability table), animation events, GIF first-frame decoder (LZW), one-color detector, wxml/wxss -- read
- MP cylPausesAnimationsWhileUserScrolls uses cyl_pause/cyl_play directly (not the speed trick).

### vendored MP part 2: model.js + index.js read -> all vendored MP sources read.
- model: pure render model; type table; option parser (same vectors as harmony); tint truth table; color precedence own > subclass explicit > inherited > subclass built-in > component; glass CSS blur16/sat160/bright1.05; reasons for resourcemissing.
- index.js: teardown as keyed dealloc block; GIF still drawn on canvas; play/pause/rest per engine capability; countdown with wx storage + onAppShow.
- Candidate G: cylAnimationDidStop is called only by cyl_animationDidEnd and stopAnimation; selection-change cyl_halt and cyl_stopAtProgress do not remove the item from cylPlayingItems -> with cylPausesAnimationsWhileUserScrolls(true), scroll end may cyl_play() a halted (deselected) item. verify.

### vendored part 6: harmony cylanimateditem/rive tests (*.mjs, test_cyl_hap_x86_64.py) and tools/cyl_hap_x86_64.py read -> vendored source complete.
- Player test pins "speed 0 or less is 1". Tool docstring: engines read the x86_64 marker in debug AND release builds (compare AGENTS.md debug-guard rule).
- SVGA decoder test reads CrossPlatform/harmonyos-cyltabbar/... paths (upstream layout); check they exist here.

## After the checks (supersedes candidate wording above)
Verified and re-ranked as V1-V8 in 09-findings.md. V1-V3 resume paths need opt-ins no caller in this repo uses.
