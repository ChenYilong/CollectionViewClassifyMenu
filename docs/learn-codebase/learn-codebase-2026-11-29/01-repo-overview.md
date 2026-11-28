# Repository overview (CollectionViewClassifyMenu @ 03707ba2, branch fix/shared-contrast-ios, 2026-11-29)

## What it is
A tag list / classify menu / multiple filter / image tag library. The iOS core is pure Swift (iOS 15+, public API @objc),
ported to Android (Kotlin), HarmonyOS NEXT (ArkTS), WeChat mini program, and wrapped for Flutter (iOS, Android,
HarmonyOS) and React Native (iOS, Android, plus a HarmonyOS example shell). Ports keep the iOS API names.
(AGENTS.md's first line still says "Objective-C iOS demo": stale.)

## Layout
| Path | Content |
|---|---|
| CollectionViewClassifyMenu/Class | iOS core (also holds demo-app files, excluded by name in podspec and Package.swift) |
| TagCollectionView | older demo app: CYLTagView collection view with per-group first-row fold |
| Example, Example-Swift, Example-Shared | iOS example app, Swift tag editor, shared test helpers and database |
| android/merged | the Kotlin library (com.cyl:classifymenu) and merged example |
| android/AndroidTagView, TagViewGroup, android-tagview | standalone Kotlin ports of upstream libraries; library sources equal the merged copies except R imports |
| harmony/classifymenu | HarmonyOS library; harmony/entry is the example app; other harmony/cyl* modules are vendored |
| CrossPlatform/wechat-miniprogram | packages/cyl-tag-list-miniprogram/miniprogram_dist is the HAND-WRITTEN source (no src folder); miniprogram/ is the example |
| flutter/cyl_tag_list, cyl_tag_list_ohos | Flutter plugin and its HarmonyOS implementation |
| react-native/react-native-cyl-tag-list | Fabric component, example, harmony-example |
| scripts, .github/workflows | checks, CI, screenshots, data generation |

## Working rules (AGENTS.md; details in docs/instructions/)
- Read docs/instructions/behavioral.md before any task; read docs/instructions/git.md before any git operation.
- Record each task in docs/ first; first reply starts "TODO (branch <branch>): <task>"; acceptance score, 60 passes.
- Fix in the core first; an example-layer fix needs asking and an entry in docs/example-layer-fixes.md.
- Commits: git cz style, English, with the author line from docs/instructions/code.md; check with scripts/check-commit-message.sh.
- Every branch has a PR; on a non-main branch, commit and push at the end of every answer.
- Sessions: Mac does iOS, Win does Android / HarmonyOS / mini program / Android runs of Flutter and RN. Windows cannot build iOS.
- Stop your own simulators after use; never "shutdown all".
- Strings: one bundle per module, core keys stable; run scripts/check-localization.py before string commits.
- Accessibility is required for every control.

## Dependencies and pins (git grep and VENDORED.md at 03707ba2)
| CYLTabBarController commit | Used by |
|---|---|
| 4d0e00ae | iOS Podfiles (root, Example, Example-Swift, TagCollectionView), Package.swift, Flutter example Podfile and pubspec, RN example Podfile and fetch-cyltabbar.sh |
| b5b36fbf | android/merged/gradle.properties (cyl.tabbar.commit), mini program fetch script and vendored folders, harmony cylanimateditem, _lottie, _pag, _rive, cylanimateditemrive |
| 8fa168fa | harmony/cylliquidglass |
| 19cbf801 | RN harmony-example/scripts/setup.sh (commented reason) |
Which commit is newest was not checked. CYLDeallocBlockExecutor: 4276a6da (Podfiles, harmony vendored copy; the mini
program's VENDORED.md names the same hash). Example/Podfile also pins CYLSearchViewController 167d6f4b.
Android library: api io.github.chenyilong:cyltabbarcontroller-animateditem:1.100.0.

## CI and scripts
- .github/workflows/ios.yml: path length <= 160, shellcheck, doc comment check, CYL pin check (warning), pod lib lint,
  zero library warnings, 4 unit test suites (menu, tag, example, swift), screenshots published to the ci-screenshots branch.
  Also localization.yml, miniprogram.yml, screenshots.yml. lefthook.yml at the root is entirely commented out.
- scripts/: bilingual-docs, check-branch-pr, check-commit-message, check-doc-comments, check-licenses,
  check-localization(-ports), check-path-length, check-screenshots, cyl-tabbar-latest-commit, example-screenshots,
  export-miniprogram-data, fetch-animation-resources, generate-places-db, library-warnings, pod-lint,
  publish-screenshots, simulator-id, stitch-screenshots (.py/.swift), swift-api-check/show, swift-migrate-pbxproj, unit-tests.
- The react-native package has its own nested .github workflow and lefthook; GitHub runs only root workflows.
- The shared demo database Example-Shared/Database/cyl_places.sqlite is made by scripts/generate-places-db.py
  (83 places, categories 吃 喝 玩 逛; review ids are 0-based). It stores Chinese SOURCE titles.
