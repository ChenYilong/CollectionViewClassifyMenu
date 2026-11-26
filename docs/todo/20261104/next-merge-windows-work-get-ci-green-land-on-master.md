# Next: merge the Windows glass work, get CI green on the integration head, then land it on master

Handover document for the next developer of CollectionViewClassifyMenu. Written 2026-11-26 (NZDT).

**Folder naming rule:** `docs/todo/YYYYMMWW/`, where `WW` is the week of the month; a week belongs to the month of its Thursday. 2026-11-26 is the 4th Thursday of November, so the folder is `20261104`. The folder holds exactly one file: append to this file, do not add another one.

## 0. Read this first

| Item | Value |
|---|---|
| Repository | https://github.com/ChenYilong/CollectionViewClassifyMenu |
| Branch to work on | [`fix/shared-contrast-ios`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/fix/shared-contrast-ios) |
| Code state described here | `44f226c42441d22c74c6d9e37be5b899bf45f91f` (also `feat/tag-final-merge-plus`) |
| Shared component repository | https://github.com/ChenYilong/CYLTabBarController, branch `feat/harmony-animated-item-engines` |
| Component commit pinned by iOS | `4d0e00aec79fae5f36659d3f005eb53468468003` (the branch tip was `ff2ada53` on 2026-11-26) |
| Scores (advisor rubric, 2026-11-26) | Development progress about **80 / 100**. Release readiness **48 / 100** |

### What to do next, in order

1. **Verify the head.** Run `scripts/unit-tests.sh menu`, `example` and `swift`, `scripts/library-warnings.sh`, `pod lib lint`, a SwiftPM build, Example-Swift, and the React Native and Flutter iOS builds. The ClassifyMenu suites have **never run at `44f226c4`**.
2. **Get CI to run on the head.** `.github/workflows/ios.yml` runs on push only for `master` and `claude/**`, so the integration branch has had **no CI at all**. Open a pull request from the head, or add the branch to the workflow. Also find out why the iOS jobs of PR #37 and #38 stay queued.
3. **Merge the Windows work.** The Windows `feat/glass-backdrop` head `4c20779c` is **not on GitHub** (it waits for the owner's approval to push). After it is pushed, merge it into the head, keep both sides of the documents, and keep the Windows pins and the iOS pins consistent.
4. **Get the open decisions in section 6 answered** by the project owner.
5. **Decide the merge order of PR #31 to #39**, land on `master`, then do the release work in section 3.

## 1. Working model

| Topic | Rule |
|---|---|
| Two repositories | `CYLTagButton` subclasses `CYLAnimatedItemView` from CYLTabBarController (pod `CYLAnimatedItem`). Fix item behaviour in the component, not in the tag or the examples. |
| iOS pins (9 files) | `Package.swift`, `Podfile`, `Example/Podfile`, `Example-Swift/Podfile`, `TagCollectionView/Podfile`, `react-native/react-native-cyl-tag-list/example/ios/Podfile`, `react-native/react-native-cyl-tag-list/scripts/fetch-cyltabbar.sh`, `flutter/cyl_tag_list/example/pubspec.yaml`, `flutter/cyl_tag_list/example/ios/Podfile`. |
| Other pins (handled on Windows) | `android/merged/gradle.properties`, `harmony/*/VENDORED.md`, mini program `COMMIT` files and `fetch-cyltabbar.js`. Harmony and mini program contain vendored source: re-vendor it, never edit only the SHA. On 2026-11-26 Android and the mini program name `08343e9f`; the Harmony vendored files name `08343e9f` and, in two places, `8fa168fa`. |
| Testing an unpushed component commit | Redirect the clone URL with git `url.<local path>.insteadOf` (set through `GIT_CONFIG_COUNT` / `GIT_CONFIG_KEY_n`) before `pod install`. Push the component before you push a pin that names it: a pin to a local-only commit broke this branch once. |
| Component batches | Develop on a side branch, ask for a full `CYLTabBarController-Framework` run, then fast-forward `feat/harmony-animated-item-engines`. Announce before pushing: others work on that branch. On 2026-11-26 the tab bar owner announced an ongoing change to the flat tab bar button (`CYLFlatDesignTabBarButton`). |
| Git | No force push. Do not merge a pull request without the owner's approval. Commit rules: `docs/instructions/git.md` and `AGENTS.md`. |
| Simulators and emulators | Use your own device by UDID, terminate the app and shut the device down afterwards, never `simctl shutdown all` (see `docs/instructions/sessions.md`). |
| Platforms | iOS is developed on macOS; Android, HarmonyOS and the WeChat mini program are verified on a Windows machine. iOS is the reference for APIs and behaviour. |

## 2. What the last iteration delivered (iOS)

| Area | Result |
|---|---|
| Tag style | Liquid Glass tags and section board share one glass style and lit edge; no default border under glass (an explicit border colour draws one); default glass tint 0.10 light / 0.04 dark, owned by the component |
| Layout | Header room model (`CYLTagListHeaderRoom`); tail fold cell styled like any tag |
| Refactor | `CYLTagButton` no longer duplicates the component: colour roles (`CYLAnimatedItemColorRole`), subclass colour channels, one resolver |
| Dark mode contrast | One lift-only rule (title 4.5:1, icon 3:1) on drawn glass and on flat items that draw a fill; iOS floor for rendered dark glass 0.28 |
| Delete indicator | `deleteIndicatorImage` is a colour role |
| Plus button | The component aligns the plus title with the tab titles by default |
| Example | Configuration page uses plain sections like Android; animated entries of the dictionary list use `renderingMode=automatic` |

Verification on record:

| What | Commit | Result |
|---|---|---|
| `CYLTabBarController-Framework` suite (run by the tab bar owner) | component `4d0e00ae` | 384 tests, 3 skipped, 0 failures |
| CYLTabBarController ObjC Example and Example-Swift-04 builds | `9d2b9e7b` with ClassifyMenu `44f226c4` | Build succeeded |
| ClassifyMenu `library-warnings.sh` and `CYLMenuExample` build-for-testing | `44f226c4` | Succeeded (compile only) |
| Configuration page on the iOS 27.2 simulator, expanded | before the merge, same code | SF Symbol star 4.66:1, its title 6.95:1 in dark; 10.21:1 in light |
| ClassifyMenu unit test suites | `44f226c4` | **Not run** |

New tests that were only compiled include `CYLTagListHeaderRoomTests`, `CYLGlassBorderTests` additions and the delete indicator image test in `CYLTagButtonTests` (no run is on record at this SHA).

Evidence (committed): [bug and fix comparison](../../assets/ios-27.2-iphone18pro-sim-config-dark-bug-a40c4ee4-vs-fix-9cc46181.png). The component repository holds `docs/assets/ios-27.2-iphone-18-pro-example-swift-04-tag-roles-dark-light-4d0e00ae-2026-11-26-1917.png`.

## 3. Scores and missing points

These are rubric judgements by a reviewing model (the "advisor") from the evidence in this document, not measurements.

**Development progress: about 80 / 100.** The iOS feature work is mostly done; cross-platform alignment is in progress.

**Release readiness: 48 / 100.**

| Area | Weight | Score | Missing points |
|---|---|---|---|
| iOS scope | 15 | 13 | Badge contrast deferred; header controls and the FlatDesign tab bar are outside the contrast rule; contrast limits wait for decisions |
| Parity: Android, HarmonyOS, mini program, React Native, Flutter | 20 | 9 | Windows head unpushed; colour roles and flat adaptation being ported; component pins differ from iOS; open divergences (section 5); Increase Contrast and Reduce Motion not ported |
| Verification of `44f226c4` | 20 | 8 | ClassifyMenu suites not run; no `pod lib lint`, SwiftPM, Example-Swift, React Native or Flutter iOS build |
| CI and path to master | 15 | 3 | `master` is 317 commits behind; no CI on the integration head; 9 open stacked PRs, #33 and #36 conflicting, #37 and #38 iOS checks queued; merge order undecided |
| Release engineering | 10 | 2 | No release tag (only an `archive/` tag) although podspec `0.1.0` points at a tag; the podspec depends on `CYLAnimatedItem`, which is **not in a CocoaPods release**; no CHANGELOG; npm publish needs a login; `scripts/swift-api-baseline.json` not regenerated; public `CYLIconContrast` removed without a deprecated alias (API break) |
| Known defects | 10 | 5 | See section 5 |
| Documentation | 10 | 8 | Stale TODO headings; upstream issues #7, #8, #9, #11, #12, #13 still open on GitHub although the progress document scores them 100 at best |

## 4. All open branches (47 remote branches including master)

"Open" means every remote branch other than `master`. Percentages are estimates. "Not in head" counts commits that `fix/shared-contrast-ios` does not contain. The data was read before this document was committed.

### A. Integration head

| Branch (link, tip, date) | Progress | TODO |
|---|---|---|
| [`fix/shared-contrast-ios`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/fix/shared-contrast-ios) `44f226c4` (2026-11-26) | 80% | master+317, not in head: 0. **Integration head and the branch to keep developing.** Run all ClassifyMenu suites, merge the Windows work, open the PR path to `master`. |
| [`feat/tag-final-merge-plus`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/tag-final-merge-plus) `44f226c4` (2026-11-26) | 80% | master+317, not in head: 0. Same commit as the head; it is the SHA that other repositories pin. Fast-forward it together with the head. |
| [`refactor/tag-color-roles`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/refactor/tag-color-roles) `44f226c4` (2026-11-26) | 100% (merged) | master+317, not in head: 0. Side branch of the colour-role batch. Same commit as the head: delete it. |

### B. Heads of open pull requests

| Branch (link, tip, date) | Progress | TODO |
|---|---|---|
| [`feat/animated-item-engines`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/animated-item-engines) `f10279f0` (2026-11-23) | 60% | master+6, not in head: 2. PR [#31](https://github.com/ChenYilong/CollectionViewClassifyMenu/pull/31). HarmonyOS engines. Has 2 commits that are not in the head: check whether later work replaces them, then rebase or close. |
| [`feat/harmony`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/harmony) `bb15d93a` (2026-11-25) | 90% (in head) | master+15, not in head: 0. PR [#32](https://github.com/ChenYilong/CollectionViewClassifyMenu/pull/32) (to `master`). Mergeable, checks green. Close once the head lands, or merge first. |
| [`feat/engine-api-core`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/engine-api-core) `59ce43cc` (2026-11-24) | 90% (in head) | master+19, not in head: 0. PR [#33](https://github.com/ChenYilong/CollectionViewClassifyMenu/pull/33). **Conflicting**, no checks. Content is in the head: close after the head lands. |
| [`feat/pin-f45a8f1d`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/pin-f45a8f1d) `cd95371c` (2026-11-24) | Superseded | master+11, not in head: 1. PR [#34](https://github.com/ChenYilong/CollectionViewClassifyMenu/pull/34). Old dependency pin (1 commit not in the head). Close. |
| [`feat/corner-radius-numeric`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/corner-radius-numeric) `6787e7f5` (2026-11-24) | 80% | master+6, not in head: 1. PR [#35](https://github.com/ChenYilong/CollectionViewClassifyMenu/pull/35) (to `master`). Bottom of the PR stack. 1 commit not in the head: check whether it is superseded. |
| [`feat/tag-liquid-glass`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/tag-liquid-glass) `e20eef2c` (2026-11-25) | 90% (in head) | master+93, not in head: 0. PR [#36](https://github.com/ChenYilong/CollectionViewClassifyMenu/pull/36). **Conflicting**, no checks. Content is in the head. |
| [`feat/tag-long-press-action`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/tag-long-press-action) `5e633559` (2026-11-25) | 85% (in head) | master+111, not in head: 0. PR [#37](https://github.com/ChenYilong/CollectionViewClassifyMenu/pull/37). Mergeability unknown; the iOS jobs have been queued since about 2026-11-25. |
| [`refactor/remove-duplicate-tag-containers`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/refactor/remove-duplicate-tag-containers) `edc4c01b` (2026-11-26) | 75% | master+123, not in head: 17. PR [#38](https://github.com/ChenYilong/CollectionViewClassifyMenu/pull/38). **Breaking** removal of the duplicate tag containers; 17 commits not in the head. The CI fix (NOLOCALIZE, drop the `tag` suite) is pushed, the iOS run is still queued. The owner decides whether it merges. |
| [`feat/tag-liquid-glass-on-37`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/tag-liquid-glass-on-37) `9f90d53a` (2026-11-25) | 95% (in head) | master+119, not in head: 0. PR [#39](https://github.com/ChenYilong/CollectionViewClassifyMenu/pull/39). Checks green. Content is in the head. |

### C. Branches with commits that are not in the head

| Branch (link, tip, date) | Progress | TODO |
|---|---|---|
| [`feat/example-scenarios-taglist-ios`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/example-scenarios-taglist-ios) `ba289033` (2026-11-25) | Unknown, probably superseded | master+114, not in head: 3. iOS: query-scenarios screen on the tag list (3 commits not in the head). One commit message says "NOT compiled". Compare with the head, then merge or delete. |
| [`feat/example-scenarios-taglist-and`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/example-scenarios-taglist-and) `09ef157b` (2026-11-25) | Unknown, probably superseded | master+114, not in head: 3. Android: query-scenarios screen on the tag list (3 commits not in the head). Compare with the head, then merge or delete. |
| [`feat/example-scenarios-taglist-har`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/example-scenarios-taglist-har) `9f6544bf` (2026-11-25) | Unknown, probably superseded | master+114, not in head: 3. HarmonyOS: query-scenarios screen on the tag list (3 commits not in the head). Compare with the head, then merge or delete. |
| [`feat/example-scenarios-taglist-mp`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/example-scenarios-taglist-mp) `2a143e2b` (2026-11-25) | Unknown, probably superseded | master+114, not in head: 3. Mini program: query-scenarios screen on the tag list (3 commits not in the head). Compare with the head, then merge or delete. |
| [`feat/android-kotlin-b`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/android-kotlin-b) `9719fb65` (2026-11-17) | Stale (not verified) | master+135, not in head: 135. 135 commits not in the head, last change 2026-11-17. Check for unported work before deleting. |
| [`ci-screenshots`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/ci-screenshots) `48a5d542` (2026-11-26) | n/a | master+246, not in head: 246. Screenshot output pushed by `screenshots.yml`. Not for merging. |

### D. Branches fully contained in the head or in master

| Branch (link, tip, date) | Progress | TODO |
|---|---|---|
| [`docs/bilingual-en-zh`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/docs/bilingual-en-zh) `42a314ce` (2026-11-20) | 100% (in `master`) | master+0, not in head: 0. Delete now. |
| [`docs/readme-swift-refresh`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/docs/readme-swift-refresh) `e9f49956` (2026-11-20) | 100% (in `master`) | master+0, not in head: 0. Delete now. |
| [`docs/simulator-cleanup-rule`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/docs/simulator-cleanup-rule) `bfb24afd` (2026-11-25) | 100% (in head) | master+214, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`docs/tag-liquid-glass-screenshots`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/docs/tag-liquid-glass-screenshots) `80e7bbc0` (2026-11-25) | 100% (in head) | master+39, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`docs/todo-reconcile`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/docs/todo-reconcile) `a688afea` (2026-11-21) | 100% (in `master`) | master+0, not in head: 0. Delete now. |
| [`feat/examples-tail-fold`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/examples-tail-fold) `7b8faa16` (2026-11-25) | 100% (in head) | master+215, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`feat/fold-tail-default-icon`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/fold-tail-default-icon) `0920c9e4` (2026-11-25) | 100% (in head) | master+120, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`feat/glass-backdrop`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/glass-backdrop) `c0b183de` (2026-11-26) | 100% (in head) | master+274, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`feat/pin-c4a1f8fd`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/pin-c4a1f8fd) `75a7cd37` (2026-11-22) | 100% (in `master`) | master+0, not in head: 0. Delete now. |
| [`feat/pin-c8fee654`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/pin-c8fee654) `a6f1fe4e` (2026-11-22) | 100% (in `master`) | master+0, not in head: 0. Delete now. |
| [`feat/pin-cyltabbar-8b7dea18`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/pin-cyltabbar-8b7dea18) `bbf854ce` (2026-11-20) | 100% (in `master`) | master+0, not in head: 0. Delete now. |
| [`feat/tag-final-merge`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/tag-final-merge) `22c9f5ca` (2026-11-25) | 100% (in head) | master+225, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`feat/tag-section-style`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/tag-section-style) `bbe56951` (2026-11-25) | 100% (in head) | master+216, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`feat/tag-section-style-and`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/tag-section-style-and) `1cfe9494` (2026-11-25) | 100% (in head) | master+130, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`feat/tag-section-style-ios`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/tag-section-style-ios) `aa158cd6` (2026-11-25) | 100% (in head) | master+157, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`feat/tag-section-style-mp`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/feat/tag-section-style-mp) `cd9eaf48` (2026-11-25) | 100% (in head) | master+131, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`fix/android-lint-141740e8`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/fix/android-lint-141740e8) `dedf6ace` (2026-11-26) | 100% (in head) | master+287, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`fix/board-inset-har`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/fix/board-inset-har) `552671fd` (2026-11-25) | 100% (in head) | master+248, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`fix/board-shares-tag-glass-ios`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/fix/board-shares-tag-glass-ios) `affb5bc8` (2026-11-26) | 100% (in head) | master+287, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`fix/callout-scroll-badge-ios`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/fix/callout-scroll-badge-ios) `0a654459` (2026-11-26) | 100% (in head) | master+227, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`fix/glass-default-tint-alpha-ios`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/fix/glass-default-tint-alpha-ios) `14ef1827` (2026-11-26) | 100% (in head) | master+292, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`fix/glass-icon-and-callout`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/fix/glass-icon-and-callout) `6d4cf3b2` (2026-11-25) | 100% (in head) | master+215, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`fix/glass-no-default-border-ios`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/fix/glass-no-default-border-ios) `7ece3ae5` (2026-11-26) | 100% (in head) | master+294, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`fix/header-board-gap-har`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/fix/header-board-gap-har) `a3efb400` (2026-11-25) | 100% (in head) | master+231, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`fix/header-font-board-align-har`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/fix/header-font-board-align-har) `247ebfbb` (2026-11-25) | 100% (in head) | master+223, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`fix/header-font-board-align-ios`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/fix/header-font-board-align-ios) `a6ce02d6` (2026-11-26) | 100% (in head) | master+229, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`fix/header-room-ios`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/fix/header-room-ios) `b66f1b3e` (2026-11-26) | 100% (in head) | master+289, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |
| [`fix/lift-dot-warnings-ios`](https://github.com/ChenYilong/CollectionViewClassifyMenu/tree/fix/lift-dot-warnings-ios) `595c6639` (2026-11-26) | 100% (in head) | master+229, not in head: 0. Superseded by the head. Delete after the head reaches `master`. |

### Outside this repository

| Branch or PR | Progress | TODO |
|---|---|---|
| [CYLTabBarController `feat/harmony-animated-item-engines`](https://github.com/ChenYilong/CYLTabBarController/tree/feat/harmony-animated-item-engines), [PR #824](https://github.com/ChenYilong/CYLTabBarController/pull/824) | In progress | Tip `ff2ada53`; iOS here pins `4d0e00ae`. A flat tab bar button change was announced. Repin after that batch. PR #824 targets `feat/cross-platform-components` ([PR #788](https://github.com/ChenYilong/CYLTabBarController/pull/788) to its `master`); [#813](https://github.com/ChenYilong/CYLTabBarController/pull/813) and [#823](https://github.com/ChenYilong/CYLTabBarController/pull/823) are also open there. |
| Windows `feat/glass-backdrop` `4c20779c` | In progress | **Not on GitHub.** The version on GitHub is `c0b183de`, which the head already contains. Push needs the owner's approval, then merge into the head. Reported there: mini program 312 / 312, Android 284 tests with one known Windows path failure (`CYLTagListConfigurationTest.animationSourceTextSplitsOptionsAsTheEngineDoes`), HarmonyOS host 212 / 212 and UI 15 / 15 (reported by the Windows side, not re-run on macOS). |

## 5. Bugs and known defects

Doc links are relative to this file.

### Contrast and appearance (iOS)

| Bug | Why not fixed | Fix plan and approach | Docs |
|---|---|---|---|
| Selected titles on accent fills: white on orange 2.89:1 (dark), 2.92:1 (light); on indigo 3.55:1 (dark) | The rule only raises lightness; white is already the maximum | Owner picks: darker example accent (shared JSON, also changes Android) or a new darkening rule on all platforms | [tint unification](../../tag-item-tint-unification.md) |
| Disabled tag in light mode: 1.96:1 | The disabled look is never adapted, by design | Owner decides whether it needs a floor; if so add it in the component and mirror it | same |
| Dark title on a half-alpha light fill caps at 3.98:1 | Same lift-only limit | Covered by the darkening decision | same |
| Flat items without a fill are not adapted | Owner decision: the item cannot know what is behind it | Optional API for the host to declare the backdrop colour | same |
| Badge dot and capsule images, header More / Clear buttons, header title / icon / fold chevron, FlatDesign tab bar button and badge view are outside the rule | Different drawing paths; badge exists twice in two item subclasses | Make the badge one component role; route header colours through `adaptedForContrast`; coordinate FlatDesign with the ongoing tab bar change | same |
| Fixed `animationTint` is adapted on glass only, not on flat fills | Owner decision | Revisit only on a real report | same |
| Create cell plus icon about 2.4:1 judged over black (code estimate) | Dynamic `tertiaryLabel`, not adapted | Use a stronger dynamic colour or a role | same |
| Original images and palette / multicolour SF Symbols ignore the tint | UIKit behaviour | Document for integrators; use template images | same |
| Light mode artwork is faint: SVGA about 1.3, GIF 1.6, PAG 1.7, Rive white disc | Colours belong to the example artwork | Replace the artwork or opt in to a tint | same |
| The 6th Configuration tag ("SF Symbol") is hidden next to the fold on iOS; Android shows it | Same fold algorithm; iOS tag text is a little wider. **Accepted by the owner** | None. A margin change was tried and reverted | same, section 7 |

### Cross-platform divergences

| Bug | Why not fixed | Fix plan and approach | Docs |
|---|---|---|---|
| Android: the SF Symbol star is dark on dark glass | Android's built-in icon colour does not go through the adaptation | Send the built-in / unset icon colour through the icon role, as iOS does | [tint unification](../../tag-item-tint-unification.md) |
| Android: the selected Lottie tag shows the house, iOS shows the circular arrow | Not investigated on Android. iOS is correct: progress 0 is the house, progress 1 the arrow (an earlier claim of an iOS bug was **wrong and retracted**) | Check `showAnimationLastFrame` for selected tags on Android, HarmonyOS and the mini program | same |
| Android: tags at the top of the board reach only 3.50 and 4.25 | One uniform floor; the glass is brighter at the top | Owner: accept, or raise the Android floor to cover the brightest spot (about 0.44) | [platform table](../../tag-liquid-glass-platforms.md) |
| HarmonyOS: delete indicator / cross / editing icons unadapted; a disabled tag takes the component's disabled colour instead of the style's | Not ported | Register the same roles; hand the style's disabled default as the subclass built-in | [tint unification](../../tag-item-tint-unification.md) |
| Increase Contrast and Reduce Motion options not ported to HarmonyOS / mini program; mini program has no stack-inherited level | Follow-up | Port the default-off options | same |
| Header spacing differs: iOS 8 pt, Android 8 dp, HarmonyOS 6 vp, mini program 12 px | Each platform chose its own | Proposal: 8 logical units (16 rpx) | [section style](../../tag-section-style.md) |
| Header divider and card edges should align by default (done on HarmonyOS; the entry still lists Android, mini program, iOS) | The TODO line may be stale | Check each platform and screenshot, then update the entry | [issue progress](../../issue-progress.md) |
| Native Android / HarmonyOS parity maps still mention the removed iOS `CYLIconContrast` | Windows follow-up | Map to `CYLAnimatedItemContrast` | [tint unification](../../tag-item-tint-unification.md) |

### HarmonyOS, mini program and tests

| Bug | Why not fixed | Fix plan and approach | Docs |
|---|---|---|---|
| Scrolled content draws over the status bar and title on the animation screen | Logged as TODO | Clip the list under the header | [issue progress, about line 1077](../../issue-progress.md) |
| `--ps cylColorMode dark` leaves the page light | TODO | Fix the launch option or document that the system setting is needed | same, about line 1078 |
| PAG "health" shows only a faint ring at rest | Not checked | Check the intended first frame | same, about line 1090 |
| Rive on a real HarmonyOS device untested (`RendererType.Rive`) | No device | Run on a device | [Rive](../../rive.md), [issue progress, about line 1113](../../issue-progress.md) |
| Deferred device rows C1 to C6, D1 to D5, E3, F1, G2 | Marked N/A: no device at the time (later emulator runs may cover some) | Re-run on the emulator and update | [HarmonyOS verification](../../harmony-verification.md) |
| Mini program BUG 1: animated icons drift after scrolling while playing | Waiting for a re-check in WeChat DevTools and a real AppID | Re-check, then fix in the animated item package | [cross platform](../../cross-platform.md) |
| Mini program BUG 2: Rive icons do not show (marked fixed 2026-11-15, heading still says TODO) | Re-check pending | Confirm and update the heading | same |
| `CYLSearchCategoryScenarioTests.testSearchCategoriesUseABottomTabBarAndFillTheSearchBar` failed (tab bar frame at y = 0) | Cause not determined; not confirmed whether it still fails | Run the `example` suite on the head | [issue progress, about line 1139](../../issue-progress.md) |

### Code health and process

| Bug | Why not fixed | Fix plan and approach | Docs |
|---|---|---|---|
| The GIF UIKit template-frames branch in the component's tint code is dead (`frames` is private, not `@objc`) | No behaviour effect: GIF uses the overlay like PAG and SVGA | Remove it or expose it, with tests | component `docs/Animated-Item.md` |
| One build reported a link error for `CYLTabBarItemAnimationPrepareTint`; two re-runs passed | Not reproducible | Watch CI | none |
| `CYLIconContrast` removed without a deprecated alias | Part of moving the rule into the component | Add a deprecated forwarder before release, or document the break | [tint unification](../../tag-item-tint-unification.md) |
| CI does not run on integration branches | Workflow triggers | See step 2 in section 0 | `.github/workflows/ios.yml` |

## 6. Open decisions (ask the project owner)

1. Merge order of PR #31 to #39, and whether the breaking PR #38 merges.
2. A darkening rule, or a different example accent colour, for light text on mid-luminance fills.
3. Whether the disabled look needs a minimum contrast.
4. Whether Android and HarmonyOS must guarantee 4.5:1 everywhere on a board (floors measured or estimated per platform).
5. The 0.10 / 0.04 default glass tint on the other platforms. The Windows side reported it as done in its unpushed head; earlier it was paused until the owner had seen Android and HarmonyOS. Confirm before merging.
6. A tint specification change (for example: an unset tint never follows an icon colour). Current rule: with `renderingMode=automatic` a one-colour file follows the icon colour, so the selected one-colour GIF is white on iOS and Android.
7. One header spacing value for all platforms.
8. Badge and FlatDesign contrast.
9. Release version, git tag, CocoaPods / npm / pub / ohpm publishing, and how to depend on the unreleased `CYLAnimatedItem`.
10. Restore `CYLIconContrast` as a deprecated alias or not.

## 7. All other open TODOs

| TODO | Owner / blocker | Docs |
|---|---|---|
| Align Android, HarmonyOS, mini program, React Native and Flutter with the iOS colour roles, flat-with-fill adaptation, `adaptedForContrast`, `renderingMode=automatic` example, per-platform floor (in progress on Windows). React Native / Flutter iOS use the native component; check their bridges and examples | Windows machine | [tint unification](../../tag-item-tint-unification.md) |
| Android `gradle.properties`, Harmony vendored sources and mini program `miniprogram_dist` must move to the component commit that iOS pins | Windows machine | [cross platform](../../cross-platform.md) |
| Mini program npm publish needs `npm login`; phone check needs a real WeChat AppID | Owner | [cross platform](../../cross-platform.md) |
| Windows test batch of 2026-11-24 (six items: HarmonyOS build and emulator, launch stall, libpag freeze, Flutter / React Native on Android, mini program bugs, re-vendoring and `menu.riv` with Loop off). Some may be done since: check against the Windows report | Windows machine | [issue progress](../../issue-progress.md) |
| HarmonyOS "run it" entry (stale if the later emulator runs count) | Verify | [cross platform](../../cross-platform.md) |
| Default tab bar height re-measure for Flutter / React Native | Windows machine | [cross platform](../../cross-platform.md) |
| GitHub issues [#7](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/7), [#8](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/8), [#9](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/9), [#11](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/11), [#12](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/12), [#13](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/13) are still open: verify on the released version, then close | Owner | [issue progress](../../issue-progress.md) |
| Stale task-log headings: engine API entry "TODO, 0 / 100" (a later follow-up says merged, 70 / 100) and the Liquid Glass entry "TODO, 0 / 100" (feature shipped) | Docs clean-up | [animated item migration](../../animated-item-migration.md), [Liquid Glass](../../tag-liquid-glass.md) |
| 8 pt dot badge has no example fixture | iOS | [section style](../../tag-section-style.md) |
| Callout placement below the tag (when it would cover the header) was pending on Android, HarmonyOS and the mini program | Verify on Windows | [long-press action](../../tag-long-press-action.md) |
| Run `scripts/swift-api-check.sh` and `scripts/cyl-tabbar-latest-commit.sh --check` (the pin is not the newest component commit) | iOS | `scripts/` |

## 8. Document index

| Topic | Document |
|---|---|
| Contrast rule, colour roles, new APIs, before / after code and screenshots | [tag-item-tint-unification.md](../../tag-item-tint-unification.md) (parts of the early sections describe intermediate states; later sections win) |
| Liquid Glass | [tag-liquid-glass.md](../../tag-liquid-glass.md), [tag-liquid-glass-platforms.md](../../tag-liquid-glass-platforms.md) |
| Section style and header room | [tag-section-style.md](../../tag-section-style.md) |
| Long-press callout | [tag-long-press-action.md](../../tag-long-press-action.md) |
| Issue and task log with scores | [issue-progress.md](../../issue-progress.md) |
| Platforms | [cross-platform.md](../../cross-platform.md), [android.md](../../android.md), [harmony.md](../../harmony.md), [harmony-verification.md](../../harmony-verification.md) |
| Example-layer fixes | [example-layer-fixes.md](../../example-layer-fixes.md) |
| Screenshots | [screenshots.md](../../screenshots.md) |
| Working rules | [AGENTS.md](../../../AGENTS.md), [docs/instructions](../../instructions/) |
| Component documentation | [Animated-Item.md](https://github.com/ChenYilong/CYLTabBarController/blob/feat/harmony-animated-item-engines/docs/Animated-Item.md) |

## 9. Limits of this handover

- Built from git, GitHub, a keyword search of the documents and the working notes of the last iteration. A TODO written without those keywords may be missing; read [issue-progress.md](../../issue-progress.md) once.
- Branch percentages and "superseded" / "stale" labels are estimates; compare before deleting anything.
- Windows-side results are quoted from its reports and were not re-run.

## 10. Added 2026-11-26: unfinished local work, committed as draft pull requests

This work existed only as uncommitted changes on one Mac. It is committed so that it is not lost. **Do not merge either pull request.** This section adds to section 4, which lists the branches as they were before.

| Pull request | Content | Progress | Where to continue |
|---|---|---|---|
| [#40](https://github.com/ChenYilong/CollectionViewClassifyMenu/pull/40) `wip/ios-repin-1d356a0a-simulator-screenshots` into `feat/harmony` (conflicting) | Old component repin to `1d356a0a` and the TODO "run the simulator and take the screenshots" (2026-11-21). Not built; why it stopped is not recorded | Unfinished, pin part superseded | On `fix/shared-contrast-ios`: only add the screenshots if they are still missing, then close the pull request |
| [#41](https://github.com/ChenYilong/CollectionViewClassifyMenu/pull/41) `wip/ios-corner-radius-pod-install-pbxproj` into `feat/corner-radius-numeric` | Example project file, apparently from a local `pod install`. Not built | Superseded: `fix/shared-contrast-ios` has the same kinds of entries | Close the pull request; do not merge the old project file over the current one |

## 12. Added 2026-11-27 (Windows session): step 3, merge the Windows work into the head

User prompt (verbatim): "拉取远端最新代码，找到本项目最近的一条commit所在分支，切换到最近提交所在分支。阅读分支下，docs 文件夹下的包含 handover 文字的文件夹，遍历文件夹中的所有文件以及子文件夹下的所有文件。阅读交接文档完成交接任务。开始编写代码。"

Split with the Mac session: Mac takes steps 1 and 2 (iOS verification, CI path, `ios.yml`); Windows takes step 3. iOS sources, `ios.yml` and the 9 iOS pins are not touched here.

**Facts that differ from section 0:** the Windows head is now `c75f81e3` (not `4c20779c`): 77 commits not in the head, Windows pins moved to CYLTabBarController `b5b36fbf` (pushed, checked with `gh api`). iOS stays on `4d0e00ae`: the iOS repin is macOS work.

**Merge** (local branch `merge/glass-backdrop-into-head`, worktree `C:/w/cvcm-merge`, from `fix/shared-contrast-ios` `f32ffe6f`): 113 files, 2 conflicts.

| File | Resolution |
|---|---|
| `docs/tag-liquid-glass.md` | Both sections kept (iOS wiring, then the Windows "Colour channels" section); platform table: iOS row from the head, the other rows and the "Glass border rule" section from Windows (the head's rows described the removed `CYLIconContrast`) |
| `react-native/.../CylTagListConfiguration.ts` | Windows comment (the shared item adapts explicit and built-in colours; matches iOS) |

**Tests on the merged tree (Windows):**

| Suite | Result |
|---|---|
| Mini program `node --test` | 326 / 326 (after `node scripts/fetch-cyltabbar.js`; without it 1 module-not-found failure, the fetched folder is ignored) |
| Android `testDebugUnitTest` | 305 tests, 1 failure: the known Windows path failure `CYLTagListConfigurationTest.animationSourceTextSplitsOptionsAsTheEngineDoes` |
| HarmonyOS host `harmony/scripts/unit-test.sh` | 231 / 231 |
| HarmonyOS UI tests `harmony/scripts/ui-test.sh` (emulator `127.0.0.1:5555`, at `00fc149e`) | 15 / 15 |

**Acceptance (pass 60):** conflicts resolved keeping both sides 25 / 25; iOS files and pins untouched 15 / 15; Windows suites run on the merged tree 30 / 30; pins consistent per platform group 10 / 10; pushed with the owner's approval, on PR #42, 20 / 20. **Score 100 / 100** (was 75 before the push and the UI tests).

Notes (no missing points): 60 of the 77 Windows commits fail `scripts/check-commit-message.sh` (no author line or not git cz style), already committed before this session, not rewritten.

## 13. Added 2026-11-27 (macOS session): steps 1 and 2, iOS verification of the head and the CI path

User prompts (verbatim): "拉取远端最新代码，找到本项目最近的一条commit所在分支，切换到最近提交所在分支。阅读分支下，docs 文件夹下的包含 handover 文字的文件夹，遍历文件夹中的所有文件以及子文件夹下的所有文件。阅读交接文档完成交接任务。开始编写代码。" and "阅读docs 文件夹下的包含 todo 文字的文件夹，遍历文件夹中的所有文件以及子文件夹下的所有文件。阅读交接文档完成交接任务。继续编写代码。"

English: pull the newest code, switch to the branch with the newest commit, read the handover folder under `docs/` (every file and subfolder), complete the handover tasks and write code.

Environment: macOS 27, Xcode 27.2, iOS 27.2 simulator `CB9BDA60` (iPhone, this session's own), worktree `/tmp/xpr/cvcm-contrast`.

**Note on an older owner rule:** on 2026-11-26 the owner said the iOS side keeps only a compile check and does not run the suites (integrators test). Section 0 step 1 asks for the suites; this session followed the handover, the newer document.

### Step 1: verify the head

| Check | Commit | Result |
|---|---|---|
| `scripts/unit-tests.sh menu` | `f32ffe6f` | 37 / 37 |
| `scripts/unit-tests.sh swift` | `f32ffe6f` | 23 / 23 |
| `scripts/unit-tests.sh example` | `f32ffe6f` | **240 / 242**: two failures, fixed below |
| `example` and `menu` after the fixes | `09bc2413` (iOS sources equal to `598fdb15` plus the fix) | 243 / 243 and 37 / 37 |
| `scripts/cyl-tabbar-latest-commit.sh --check` | | Newest component commit `973c255a` (`feat/harmony-animated-item-engines`, 2026-11-26 23:27 +13); iOS pins `4d0e00ae`, Windows `b5b36fbf`: **TODO repin** after the tab bar owner announces the flat button batch |
| `library-warnings.sh`, `pod lib lint`, SwiftPM, Example-Swift, React Native and Flutter iOS builds | | TODO (next) |

Fixed in `fix: 🐛 one-character badges stay round, create-item plus icon reaches 3:1`:

| Failure / defect | Cause | Fix |
|---|---|---|
| `CYLAndroidSampleTests.testListContainerFeatures`: badge "热" 18 × 16, expected 16 × 16 | `CYLTag.badgeImageWidth` widened any text whose width plus 2 × 4 pt passed the diameter; one CJK character did, against the method's own documentation | One character always keeps the circle (library) |
| `CYLTagListHeaderRoomTests.testNoFoldTheTitleTakesTheInnerWidth`: fold frame `(0, 0, 0, 0)`, expected none | Test: the header always holds its fold button and hides it when the section does not fold | The test reads a hidden fold button as no fold, as the header room model does |
| Section 5: create cell plus icon about 2.4:1 over black | `tertiaryLabel` | `secondaryLabel` (the title's colour); new test `testTheCreateItemsPlusIconReachesThreeToOneOnTheListBackground` (3:1 in light and dark) |

The component's API comment on `adaptedForContrast` (CYLTabBarController `CYLAnimatedItemView.swift`) still says the plus icon is a `tertiaryLabel`: TODO for the tab bar session.

### Step 2: CI

- Draft pull request [#42](https://github.com/ChenYilong/CollectionViewClassifyMenu/pull/42) `fix/shared-contrast-ios` → `master` (owner's choice, 2026-11-27: a draft PR rather than a trigger change in `ios.yml`). Do not merge.
- Why the iOS jobs stay queued: since about 2026-11-25 07:30 UTC no macOS job has started in this repository **or** in CYLTabBarController, while the Ubuntu jobs finish. The workflow is not the cause; the account's macOS runner allowance (minutes or spending limit) is the likely one. **TODO (owner):** check https://github.com/settings/billing.

**Follow-up (Windows, 2026-11-27):** the Localization check failed on PR #42 after the merge (four Chinese sample titles in the HarmonyOS `CYLTagGlassPage.ets`); fixed with NOLOCALIZE in `598fdb15`, CI Localization and "Unit tests and data check" now pass. The iOS one-character badge rule of `09bc2413` is ported to Android (`CYLTag.badgeImageWidth`) and HarmonyOS (`CYLTag.badgeTextKeepsCircle`, used by `badgeImage`), with tests (Android `CYLTagIosParityTest` 14 / 14, HarmonyOS host 231 / 231). The mini program draws no badge image, nothing to port. Component repin: waiting for the CYLTabBarController role registry, then all pins in one commit with the Mac session.

**Follow-up 2 (Windows, 2026-11-27):**

- iOS at `b0f153fe` (Mac session): menu 37 / 37, example 243 / 243, swift 23 / 23, no library warnings, `pod lib lint` passed, SwiftPM build succeeded (2 warnings from the component's `CYLAnimatedItem/include/module.modulemap`, tab bar repository).
- PR #41 closed as section 10 says (branch kept). PR #40 is left to the Mac session (it needs the iOS screenshot check).
- Section 5 "the selected Lottie tag shows the house": covered on the Windows platforms. Android `CYLTagButton` and HarmonyOS `CYLTagAnimatedIcon` set `showsLastFrameWhenSelected`; the mini program tag lets the item drive playback, and the item's default already rests a selected item on its last frame. Not checked on screen.
- Section 5 "Increase Contrast and Reduce Motion not ported to HarmonyOS / mini program": the HarmonyOS and mini program items have no such options, so this is component work. It is queued with the CYLTabBarController Windows session (default-off options in the item, then the tag turns them on after the repin).
- Repin plan: one commit for all pins. The CYLTabBarController session sends the role-registry SHA; the Mac session repins and verifies iOS and sends the commit as a patch; Windows applies it, adds the Windows pins with `--amend`, runs the Windows suites and pushes.
