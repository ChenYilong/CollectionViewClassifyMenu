# learn-codebase: CollectionViewClassifyMenu @ 03707ba2 (branch fix/shared-contrast-ios), 2026-11-29

An early report, kept as written: 09-findings.md and 10-coverage-and-method.md supersede it (the vendored modules were
read later).

Read-only. Nothing built or tested; every finding below comes from reading the source.

## Score: 90/100 (pass mark 60; my own judgement against the rubric)
Core source of every platform, then tests, examples, scripts and workflows were read.
Lite reading (import, blank and [CN] lines skipped): Android library, Android tests/examples/build files/scripts
(the 3 Android ports also without block comments), iOS examples and tests, HarmonyOS tests/scripts, mini program
example/tests/scripts, Flutter example, React Native tests/example/HarmonyOS example, the last Podfiles and the
Flutter Package.swift/podspec.
Excluded: vendored modules, generated and data files (strings tables, places, lottie), json/xml data, lockfiles,
pbxproj, docs other than instructions, third-party skills, bundled yarn release. The mini program's miniprogram_dist
was first excluded by mistake and then read.
Coverage sample check: 761 tracked files by extension, up to 12 lines each looked up in the session's tool output;
32 fell below 75%: generated/data and license texts, plus 11 small config files that were read afterwards.
This is a sample, not proof that every line was seen, and json/xml/properties/plist were not checked.
TODO (missing points): re-read the lite areas with their comments; run any of the tests.

## Findings (not run)
1. Android menu linkage example queries by localized title: android/merged/example/.../menu/CYLQueryScenarios.kt
   (CYLMenuLinkageScreen, 322/334/363). iOS, HarmonyOS, mini program, Flutter and React Native query by source title.
   Expected: no rows in English; zh-Hans unaffected. Other Android screens use the source title.
2. React Native iOS UI test and scripts/e2e-android.sh expect English UI text but Chinese data titles (川菜, 广州).
   Data titles are localized since 76d70415e (2026-11-19); both tests were last changed 2026-11-15 (5d5133f17).
   Neither sets a locale, so by reading neither can pass in en or zh.
3. Flutter example RunnerTests.swift is the stock template: calls CylTagListPlugin().handle, but the class has no
   such method (private handle is on CylTagListPlatformView). By reading it cannot compile; I found no script or CI
   that builds it.
4. scripts/check-doc-comments.py globs only *.h in the core and TagCollectionView; no tracked file matches (core is Swift).
5. CYLTabBarController pins differ although AGENTS.md asks for one: 4d0e00ae (iOS Podfiles, Package.swift, Flutter,
   RN), b5b36fbf (android/merged, mini program, 5 HarmonyOS vendored modules), 8fa168fa (harmony/cylliquidglass),
   19cbf801 (RN HarmonyOS example, commented). The iOS/Windows split is recorded as in progress (target dd691795) in
   docs/todo/20261104/next-merge-windows-work-get-ci-green-land-on-master.md. The pubspec comment saying
   gradle.properties has the same pin is false. cyl-tabbar-latest-commit.sh --check covers 4 Podfiles and the pubspec only.
6. Mini program cyl-tag-cloud: _renaming is a raw position; removeTag, onDelete, insertTag, replaceTags and drag move
   neither update nor end it, so finishRenaming can rename another tag. No test covers it.
7. Mini program cyl-tag-image: _timers keyed by group index; removeTagGroup splices without re-keying.
8. CYLTag.copy() drops subtitle (iOS, Android, HarmonyOS).
9. Item height measurement counts the delete indicator but not the rename icon (iOS, Android, HarmonyOS).
10. CYLTagListConfigurationSource implements remove but not move (iOS, Android, HarmonyOS).
11. HarmonyOS drag: canMoveItem has no caller in classifymenu/src, so the create cell or a non-editable section may be
    draggable. Android: finishDrag does not exclude the create cell as a target (effect unverified).
12. Flutter HarmonyOS: CylTagListOhosPlugin has no applyConfiguration case (iOS and Android do).

## Minor
- AGENTS.md calls the repo an Objective-C iOS demo; the core folder has 45 .swift files and no .h/.m.
- react-native/.../.github/workflows/ci.yml is nested and targets main: GitHub runs only root workflows.
- HarmonyOS CYLReviewStore .catch can report after being superseded; RN CylTagListView.mm has no prepareForRecycle;
  Dart _CylTagListViewState has no didUpdateWidget (may be intended).
- Sample avatars keyed by position (iOS, Android examples). Android review list: a pending request can overwrite
  after a mode switch; TagImageView's toggle hint is likely not exposed to TalkBack.
- Stale or misplaced comments: HarmonyOS CYLTagAnimatedIcon.ets vs Index.ets commit; several iOS doc comments.

## Rules not applied
No docs/ task record and no commit or push, because the task is read-only.

## Notes
Detailed area notes: appendix-reading-notes.md (same folder).
