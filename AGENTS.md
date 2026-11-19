# Agent instructions

CollectionViewClassifyMenu is an Objective-C iOS demo with a collapsible
collection-view menu and a multiple-choice filter. Read `README.md` and the
relevant source before changing behavior. If documentation and code disagree,
verify the behavior and update the applicable documentation.

## Task log in docs/

- **Record every task in `docs/` before starting it.** Find the most relevant existing document in `docs/`
  (create one only when none fits; `docs/issue-progress.md` holds the general TODO list). Add a `TODO` entry
  first: the task's detailed context, the user's requirements, and the user's prompt quoted verbatim. Then do the
  task. When it is finished, mark the entry done and add the result and its evidence (commits, tests,
  screenshots). Purpose: if the work is interrupted, the context can be found again and the task resumed.
- The same rule is in the vault's root `instructions.md` (section 16). Details: `.agents/skills/cyl-commit/`.

## Task start: TODO, branch, acceptance score

Details and checklist: `.agents/skills/cyl-task-start/SKILL.md`.

- **Check other sessions first.** Before starting, list the other agent sessions and read their current tasks. Step
  one: find out whether any session is editing the same branch (same repository and branch). If none is, continue.
  If one is, check whether its task duplicates this one: if it does, do not repeat it (coordinate with that session,
  or take a part it is not doing); if it does not, continue and avoid touching the same files at the same time.
- **Mark the task at the top.** Before starting any task, write a `TODO` line at the very top of the session (the
  first lines of the first reply) with the task and the current branch, for example
  `TODO (branch feat/harmony): <task>`.
- **Write the task into docs/.** Find the most suitable document in `docs/` (see "Task log in docs/") and write the
  task there, together with its acceptance scoring criteria: what earns full marks (100) and what is a pass (the
  passing score, 60 unless the task says otherwise), each criterion with its points.
- **Score until it passes.** Score the work against those criteria. Below the passing score the task must not be
  interrupted or handed back: keep working and scoring again until it passes.
- **Explain the missing points.** Write the score, and why it is not full marks, into the document. At the end of
  the session, print every missing point as a `TODO` (criterion, points, what is still needed) in the final lines of
  the last reply.
- **Update the document at the end.** Update the entry written when the task started: the final score, the reasons
  for the missing points, the result and its evidence (commits, tests, screenshots).

## Session roles by name: Mac for iOS, Win for the other platforms

Checklist: `.agents/skills/cyl-task-start/SKILL.md` ("Before the task", step 0).

- **Check the session names before a task.** List the active agent sessions working on this repository (for example
  with the agent tool that lists sessions) and read their names.
- **Mac sessions mainly do iOS.** A session whose name starts with `Mac` (case insensitive: `Mac`, `mac`, `MAC`…)
  mainly develops and tests the iOS side: the Swift core, the iOS examples, and the iOS runs of the Flutter and React
  Native examples, on macOS with Xcode and the iOS simulator.
- **Win sessions mainly do the other platforms.** A session whose name starts with `Win` (case insensitive) mainly
  develops the other platforms: Android, HarmonyOS, the WeChat mini program, and the Android runs of the Flutter and
  React Native examples.
- **Both active: route by platform.** When a matching Mac session and a matching Win session are both active, prefer
  handing each platform's part of a task to the session that owns that platform: send it the request with the context
  and the acceptance criteria, keep your own platform's part, and do not repeat the other session's part. A
  cross-platform task is split by platform, each session doing its side and reporting back.
- **Otherwise: skip the rule.** When no active session follows this naming, or only one side is active, skip this
  rule and finish the whole task independently.
- This rule decides who does a platform's work; the other rules (checking the other sessions for the same branch,
  folder ownership, the task log) still apply.

## Shared emulators and simulators

- Emulators and simulators are shared with other sessions (for example the Android emulator `emulator-5556`).
- **An emulator that stays hung until it is restarted** (package manager hangs, `adb` or `hdc` commands time out,
  the screen stops updating): tell the other sessions first (one message to each session that may use it: which
  emulator and that it is being restarted), then restart it, and tell them again when it is back.
- **An emulator that will not open or boot: restart it first.** Restarting is the preferred fix. Do not ask whether
  to restart; run the restart from the command line directly (Android: `adb -s <serial> reboot`, or kill and relaunch
  the emulator with `-no-snapshot-load` if `adb` cannot reach it; HarmonyOS: restart the emulator from its command
  line tool; iOS: `xcrun simctl shutdown <udid> && xcrun simctl boot <udid>`).

## Code and naming

- Use the `CYL` prefix for project-specific Objective-C classes and protocols;
  category names use `CYL` and category methods use `cyl_`. Preserve existing
  public APIs unless a requested naming migration explicitly changes them;
  document incompatible changes and update XIBs and callers.
- Use descriptive English identifiers and conventional Objective-C naming.
  Keep existing names and localization unless a change is necessary.
- Document user-visible changes and verify them with a targeted build or test.
- Code comments: a public API (everything in the pod's headers, and any
  `public`/`open` Swift declaration) is documented with a documentation comment
  that callers see in Xcode's Quick Help and in the Swift interface of the
  Objective-C headers. A comment of more than one line is one block, never a
  stack of single-line comments: in Objective-C headers use
  ```objc
  /*!
   * What it does, and what callers must know.
   */
  ```
  In Swift source, where the compiler does not treat `/*!` as documentation,
  use `/** … */` with the same layout. Plain `//` comments are for
  implementation notes only, never for public API docs.
- The format required for multi-line public API comments also applies to
  one-line public API comments:
  - One-line comments use the block format too: a one-line public API comment
    is written like a multi-line one, as the three lines `/*!`, ` * text`,
    ` */`, above the declaration. Never put `/*! text */` on one line, and
    never add a trailing `/**< */`, `/*!< */`, `///<` or `//` after a
    declaration or an enum value.
  - Each file that holds public API uses one comment format, for long and
    short comments alike.
  - This applies to every platform and language, always with the block form of
    the platform's documentation tool, laid out the same way (opener, one line
    per text line, closer on its own line):
    - Kotlin, Java, TypeScript, JavaScript: `/** */`.
    - Python: a triple-quoted docstring whose quotes stand on lines of their
      own.
    - Go: `/* */`.
    - C#: `/** */` with XML tags.
    - Rust: `/** */`.
    - A language without a block form uses its only documentation comment form
      throughout the file.
  - Every comment format follows the official rules of its language and
    documentation tool, which take precedence: the syntax inside a comment
    (tags, Markdown, XML elements, docstring content) is the official one,
    and a form the official tool does not read as documentation is never
    used. The forms above are this project's choice among the officially
    valid ones. References: `.agents/skills/cyl-comments/`.
  Details and the check: `.agents/skills/cyl-comments/`.
- Use English Conventional Commit messages, such as `fix: 🐛 ...` and
  `docs: 📝 ...`.
- **Commit messages: git cz style, English only.** Every commit is written in the `git cz` (commitizen, cz-emoji)
  style: the subject is `<type>(<optional scope>): <emoji> <summary>`, with the type one of `feat`, `fix`, `docs`,
  `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore` or `revert` (for example `feat: ✨ …`, `fix(harmony): 🐛
  …`), followed by a body and the author line. The whole message (subject, body and trailers) is in English: no
  Chinese characters, and no other non-English text, are allowed anywhere in a commit message. Write a user's
  non-English prompt only in the task log in `docs/` (quoted verbatim there), never in a commit. Check:
  `scripts/check-commit-message.sh [range]`.
- Every commit message's description (the body) must contain the author line
  `By @ChenYilong <luohanchenyilong@163.com>`, exactly as written, on its own
  line after the description and before any trailers. Details:
  `.agents/skills/cyl-commit/`.

## Bugs: record, screenshot, fix in CYLTabBarController's animated item

- For every bug: first record it (a `TODO` row in the related document in
  `docs/`, with the steps and what was expected), then take a screenshot of it
  (`docs/assets/`, linked from the row), then fix it, then take the screenshot
  again and mark the row done with both images.
- Animation and icon + title bugs are fixed in CYLTabBarController's shared
  animated item component (`CYLAnimatedItem` / `CYLAnimatedItemView` on iOS,
  `cylanimateditem` on Android and HarmonyOS, `cyl-animated-item` in the mini
  program), not in this repository's examples. This repository only pins the
  fixed commit (by `:commit` or the vendored copy) and adapts its own core
  (`CYLTagButton`) to the component.
- Avoid changing the examples. When a demo needs something the component does
  not offer, CYLTabBarController adds that API to the component and the demo
  uses it; record the request and the CYLTabBarController pull request.
- A fix made here meanwhile (in this repository's core, never the example)
  names the CYLTabBarController change that will replace it, as a `TODO` in
  `docs/animated-item-migration.md`.

## Fix issues in the core first

- The core is the code this repository publishes to a package registry: the
  CocoaPods pod and Swift package (`CollectionViewClassifyMenu/`), the Android
  library on Maven / Gradle (`android/merged/library`,
  `android/AndroidTagView/androidtagview`), the npm package
  `react-native-cyl-tag-list` (its `src/`, `android/`, `ios/`, not `example/`
  or `harmony-example/`), the pub.dev plugins (`flutter/cyl_tag_list`,
  `flutter/cyl_tag_list_ohos`, not their `example/`), the ohpm HAR
  (`harmony/classifymenu`, not `harmony/entry`) and the mini program npm
  packages (`CrossPlatform/wechat-miniprogram/packages`). Everything
  else (example apps, demo pages, demo data, screenshot scripts) is the example
  layer.
- When an issue or bug is reported, even one seen only in an example screen or
  screenshot, fix it in the core first, so that every app using the library, and
  every similar case, is fixed and the same problem cannot come back elsewhere.
  Look for the core cause before touching the example: a wrong default, a
  missing option, a measurement or layout rule, a missing localization or
  accessibility hook, a color that does not follow the color mode.
- A fix in the example layer is the worst option. Use it only when the defect
  really is in example code or example data (a demo string, a demo page's own
  layout, a screenshot script), or when the core cannot fix it.
- When a core defect cannot be fixed in the core, stop and ask the user before
  fixing it in the example, and say why the core cannot fix it (for example: a
  third-party library's bug, a platform limitation, an API the core must keep
  for compatibility).
- Record every example-layer fix in `docs/example-layer-fixes.md`: the issue,
  the files changed, and why it could not be solved in the core (or why the
  defect was example-only). Mention that document in the issue's row of its
  progress table.

## Parity tables and the score loop

- When a feature set must be compared with another platform, another
  component or an upstream project (for example the Android core against the
  iOS core), keep a three-column table in the most related document in
  `docs/` (insert it when the document exists, create the document when it does
  not): column 1 is the source API or feature, column 2 its description,
  column 3 the counterpart API or feature, `TODO` by default.
- Score: full marks (100) when column 3 has no `TODO`, 0 when every row is
  `TODO`, proportional in between (rows with a counterpart / all rows x 100).
  Write the score above the table and keep a score history.
- Loop until 100:
  1. Search the existing code for every `TODO` row and fill in the matching
     API or feature (a platform type maps to the platform's own type, e.g. an
     Android `CYLRect` to iOS `CGRect`).
  2. Score.
  3. Work through the remaining `TODO` rows one by one: implement the missing
     API or feature, and replace the `TODO` with the implementation.
  4. Score again, and repeat from step 1.
- Implement in the core first (AGENTS.md "Fix issues in the core first"): same
  logic, names and behavior as the source platform, so both cores stay
  consistent; then show the usage in the example, ported one for one from the
  source platform's example (for example drag to reorder, or a tag with an
  icon, a title and an always-shown delete icon whose deletion updates the data
  source and relayouts the list).
- At 100, make the reverse table (column 1 the other platform's API) with its
  own score, and run the same loop.
- Generated tables (for example `docs/android-ios-api.md` from
  `android/scripts/android_public_api.py`, `docs/android-api.md` from
  `android/scripts/ios_public_api.py`) are never edited by hand: change the
  maps or the code, then regenerate.

## Swift examples and a Swift-friendly core

- Every iOS example is written in Swift, tests included: `Example/CYLMenuExample`,
  `Example-Swift/CYLTagEditorExample`, the demo app of
  `CollectionViewClassifyMenu.xcodeproj` (module `CYLClassifyMenuDemo`) and the
  `TagCollectionView` demo. Never add Objective-C example code. The core library
  (the pod's sources) is moving from Objective-C to Swift (next item); its own
  tests stay in Objective-C until the migration says otherwise.
- **The core moves to Swift** (since 2026-11-12): the pod's sources are translated
  file by file, following `docs/Swift-Coding-Standard.md` and the Swift skills it
  lists (`swift-api-design-guidelines-skill`, `migration-patterns`,
  `swift-concurrency`, `cyl-swift`). Progress and score (no Objective-C file
  left = 100): `docs/Swift-Migration.md`.
- **Core quality first, examples last (2026-11-13).** When the migration breaks
  an example (a compile error or a test), change the example's code first: the
  examples have the lowest weight in the project, and no compatibility is kept
  for them. Change example code freely so that the core's Swift code carries no
  baggage: never lower the core's Swift quality to fit an example's usage; the
  Swift coding standard (`docs/Swift-Coding-Standard.md`) decides. The Swift API
  may become idiomatic; `scripts/swift-api-check.sh` reports each change, which
  is listed in `docs/Swift-Migration.md` with the baseline refreshed.
  Objective-C names stay only where the core's own Objective-C tests, XIBs,
  selectors or key-value coding need them.
- Until a part of the core is Swift: when an example calls an Objective-C API
  that reads badly in Swift, fix it in the core, never with workarounds in the
  example: the Swift API Design Guidelines decide (`NS_SWIFT_NAME`, nullability,
  lightweight generics, `NS_ENUM`/`NS_OPTIONS`/`NS_TYPED_ENUM` string constants,
  class properties, `NS_DESIGNATED_INITIALIZER`, `NS_SWIFT_UNAVAILABLE`, `throws`
  through `NSError **` as the last parameter).
- `cyl_` methods: follow CYLTabBarController's rule ("Swift-friendly names for
  underscored protocol methods" in its AGENTS.md, and its `docs/Swift-Guide.md`,
  at its newest commit):
  Swift names have no underscore, and the Swift name of an existing public method
  never changes. Add a new method without the underscore that keeps the `cyl`
  prefix (`-cyl_setWidth:` → `-cylSetWidth:`), give only the new one its Swift
  name with `NS_SWIFT_NAME`, and run the same logic for both spellings (for a
  protocol method, call the new one when implemented, otherwise the old one, and
  make an old `@required` method `@optional`).
- Details, the check of imported Swift names and the list of methods still to
  adapt: `.agents/skills/cyl-swift/`.

## Example tests

- One test case class per feature, one file each (`CYLTagListSelectionTests`, `CYLReviewFilterScenarioTests`, …);
  never grow a single file that tests everything.
- Shared capabilities are protocols with default implementations in `Example-Shared/TestSupport/`, compiled into
  the test targets of `Example/` and `Example-Swift/`: `CYLWindowHosting` (windows in the app's scene),
  `CYLTagListInspecting` (cells, headers, footers, fold controls, taps), `CYLAccessibilityQuerying` (find views by
  identifier and label), `CYLScreenshotCapturing`, `CYLConditionWaiting` and `CYLViewOverlapInspecting` (the views
  a view covers in its window). Each test target has one small base class (`CYLMenuExampleTestCase`,
  `CYLTagEditorTestCase`) for its language and its screens, and its fixtures in `Support/`.
- Tests reach private views of the core only through `CYLTagListProbe` (key-value coding in one place).
- Tests record screenshots of the states they check with `captureScreenshot(of:named:)` / `captureScreen(named:)`
  (names start with `test-`); `scripts/unit-tests.sh` writes them to `build/test-screenshots/<suite>/`.

## Xcode and CocoaPods

- The minimum supported iOS version is 15.0. Keep the project and podspec
  consistent.
- Preserve `objectVersion = 46` and `compatibilityVersion = "Xcode 3.2"` for
  compatibility with the reference project; do not introduce folder-synced
  groups without verifying supported Xcode versions.
- Do not commit Xcode user state, derived data or generated dependencies.
- Validate the podspec with `pod lib lint CollectionViewClassifyMenu.podspec`
  and build the affected target. Report any warnings or checks that could not
  be completed.
- Project-specific Xcode and verification guidance lives in
  `.agents/skills/cyl-xcode-compat/` and `.agents/skills/cyl-verify/`.

## CYLTabBarController reference and dependency

- Every mention of CYLTabBarController (its code, APIs, podspec, initialization,
  animation engine, CI, demos, rules) means its newest commit over every branch,
  found by commit timestamp; it may be on a branch other than `master` or
  `main` (so far `feat/cross-platform-components`), and it is never a CocoaPods
  release.
- This project always integrates CYLTabBarController through CocoaPods, by that
  commit: `:git => 'https://github.com/ChenYilong/CYLTabBarController.git'` with
  `:commit => '<sha>'` (the `CYL_TAB_BAR` hash of `Example/Podfile` and
  `Example-Swift/Podfile`). Never a version number, `:branch` or `:tag`.
- The Flutter example's tab bar on Android is CYLTabBarController's Flutter plugin `flutter_cyltabbar`, a git
  dependency of `flutter/cyl_tag_list/example/pubspec.yaml` (`ref:` the same commit, `path:
  CrossPlatform/flutter_cyltabbar`). It is a pin like the Podfiles: it moves with them, and `--check` covers it.
- Before every build, find the newest commit with
  `scripts/cyl-tabbar-latest-commit.sh` (it fetches the tip of every branch and
  sorts by committer date; `--check` fails when a Podfile pins another commit).
  When it changed, update every pin and anything copied from CYLTabBarController
  in the same commit, after checking what changed in between.
- A pull request branch that is already merged into the newest branch does not
  count, even when it gets a newer commit afterwards (owner's decision,
  2026-11-17): pin the newest branch's tip, and move once that newer commit is
  merged there. CollectionViewClassifyMenu and CYLSearchViewController pin the
  same commit.
- Note (2026-11-17): from `e7ec145` to the next pin the pins stayed at `fbd05d5`
  (CYLTabBarController PR #814) because the newest branch lacked it; the owner
  merged #814 into `feat/cross-platform-components` (PR #788, `9a54e26`), so the
  pins follow the newest commit of that branch again.
- Search bars in the examples are CYLSearchViewController's `CYLSearchBarView`
  (the sibling `../CYLSearchViewController` repository, unreleased, no API
  compatibility to keep). Change it there as the examples need, commit and
  push on a feature branch, then pin that commit as `CYL_SEARCH` in
  `Example/Podfile` (`:git` + `:commit`, so CI can fetch it). Do not use a
  local `:path` in a committed Podfile: CI does not have the sibling folder.
- If this project is CYLTabBarController itself, depend on it locally instead:
  `pod 'CYLTabBarController', :path => '<relative path to the folder that holds
  CYLTabBarController.podspec>'`. Every other project uses the commit.
- Default integration in the examples (unless a request says otherwise):
  this project integrates CYLTabBarController by default, and every
  CYLTabBarController at the example level is the version **with a
  PlusButton that has a `plusChildViewController`** (the plus button selects
  a page of its own), **created from a local configuration file** in the
  example's bundle: `CYLTabBarController(configurationFile:)` /
  `+tabBarControllerWithConfigurationFile:error:`, with the tabs in
  `CYLTabBarControllerTabBarItemsAttributes`, the plus button in
  `CYLTabBarControllerPlusButton` (its page through
  `CYLTabBarItemPageIdentifier`), pages registered in
  `CYLTabBarPageRegistry`, and a `CYLTabBarControllerContext` of its own per
  tab bar. Build a tab bar in code, or leave out the plus button, only when a
  request asks for it. Details: `.agents/skills/cyl-dependency/`.
- Raised plus button: whenever an example integrates a PlusButton to demonstrate it, always prefer the raised
  ("bulging") plus button effect. Raised means the top of the plus button extends beyond the top edge of the tab
  bar. In a configuration file, raise it with `CYLPlusButtonCenterYOffset` (a negative offset) or
  `CYLPlusButtonCenterYMultiplier`; in code, with `+constantOfPlusButtonCenterYOffsetForTabBarHeight:` /
  `+multiplierOfTabBarHeight:` of `CYLPlusButtonSubclassing`. A flat plus button needs a request. Details:
  `.agents/skills/cyl-dependency/`.
- The core library depends on the shared animated icon + title component only:
  `CYLTagButton` subclasses `CYLAnimatedItemView`, from the pod and module
  `CYLAnimatedItem` (`CYLAnimatedItem.podspec` in CYLTabBarController's
  repository, no dependency on CYLTabBarController; podspec
  `s.dependency 'CYLAnimatedItem'`, Swift `import CYLAnimatedItem`; Swift package
  `.product(name: "CYLTabBarController")`, which still compiles the component
  into that module; Android `io.github.chenyilong:cyltabbarcontroller-animateditem`,
  package `com.cyl.animateditem`, built from the pinned commit through
  `substitute(...).using(project(":cylanimateditem"))`; guide:
  <https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md>).
  It never depends on an animation engine or library: only the examples add the
  engine subspecs (`CYLAnimatedItem/<Type>`: `LottieSwift`, `LottieObjectiveC`,
  `PAG`, `PAGEnterprise`, `Rive`, `SVGA`, `GIF`) and the Android animation
  libraries (Lottie, libpag, rive-android, SVGAPlayer); without them tags show
  their static images. The display priority, the failure fallbacks, the
  placeholder and the URL loading are the base class's: never reimplement them
  in a subclass. The configuration parser (`CYLTabBarConfigurationParser`) is
  still found at runtime. Since `CYLAnimatedItem` is not on the CocoaPods trunk
  yet, every Podfile names it by `:git` + `:commit` (`CYL_ANIMATED_ITEM`, the
  same commit as `CYL_TAB_BAR`; a Podfile that uses CYLTabBarController names it
  too, because CYLTabBarController's CYLUtils depends on `CYLAnimatedItem/Core`),
  and `scripts/pod-lint.sh lib` lints against a checkout of that commit.
- Details: `.agents/skills/cyl-dependency/`.

## License in every published package

- **Every package published to an external registry contains its license declaration.** This covers, without
  being limited to, CocoaPods, Swift Package Manager, Gradle / Maven, npm, pub.dev, ohpm and the mini program npm
  packages, on every platform. The license file ships with the package, and the package manifest names it.
- **The license goes into the package's built-in resource container**: when the package already has one, put the
  license file in it; when it has none, create one. On iOS the core's resource bundle
  (`CYLClassifyMenuResources.bundle`) contains `LICENSE`. The same rule applies to every platform: an Android
  library's Java resources (`META-INF/<artifact>/LICENSE`, inside the AAR), an npm package's root (listed in
  `files`), a pub.dev package's root, an ohpm HAR's module root and its `resources/rawfile`, a mini program npm
  package's root and its component folder `miniprogram_dist` (copied into `miniprogram_npm` when DevTools builds npm),
  as CYLTabBarController's `docs/License-Notices.md` does.
- The manifest declares the same license: podspec `s.license` (with `:file`), `Package.swift` resources, Maven POM
  `licenses`, `package.json` / `oh-package.json5` `license`, the pub.dev package's `LICENSE`.
- Ported or copied third-party code keeps its upstream license and notice next to it (for example the Apache-2.0
  ports in `android/`); a package that contains it ships those notices too.
- A package without its license file, or with a placeholder ("TODO: Add your license here"), is not ready to publish.
- The license of this repository's own code is MIT (`LICENSE`, decided 2026-11-17). Check:
  `bash scripts/check-licenses.sh`. Details and the per-platform locations: `.agents/skills/cyl-license/`.

## Bundled animation files

- Keep copied animation files (Lottie, PAG, Rive, GIF) unmodified, with their source, commit, path and
  license in the README next to them. One exception, as in CYLTableViewPlaceHolder
  ([PR #22](https://github.com/ChenYilong/CYLTableViewPlaceHolder/pull/22)): a background fill baked into a
  file (a Rive artboard fill, a "BG" shape) that draws a square behind an icon may be made transparent by
  setting its alpha to 0, and nothing else, when the license allows modification, or when the maintainer
  decides so for a file without a license (`house.riv`, 2026-11-12). Record the change and both SHA-256
  values in that README (`Animations/Rive/README.md`: `truck.riv`, `house.riv`).

## Example demo rules

- **Animation playback controls.** Every example screen that shows animations (Lottie, PAG, Rive, GIF, symbol
  effects), on every platform (iOS, Android, React Native, Flutter, Mini Program, HarmonyOS), offers three controls
  that combine and act in real time: **Play all** (restart every animation from progress 0, once), a **speed slider**
  and a **loop switch**. Change the core library (and CYLTabBarController's animation engine) when an engine lacks
  the speed or loop API; never work around it in the example. Details, status per platform and the TODO:
  `docs/example-demo-rules.md`. The same rule, with the library-side notes, is in CYLTabBarController's
  `docs/Tab-Icon-Animation-Quick-Start.md` ("Playback controls in the animation examples").

## Search bars

- A search bar never covers any view, at any time: not the view controller's view, not a sibling, not a background
  view, not a bar item, in every state (scrolling, editing, Cancel shown) and at every Dynamic Type size. A screen
  whose navigation bar holds the search bar removes `.top` from `edgesForExtendedLayout`; a `CYLSearchBarView` is
  laid out against the safe area beside the content, and a colored area behind the status bar ends where the bar
  begins. `CYLSearchBarPlacementTests` checks every screen with a search bar through `CYLViewOverlapInspecting`;
  add a test there for each new one.

## Tab bars

- Tab bars are always at the bottom of the screen, including tab bars nested in
  a screen (such as scenario 2's category tabs); never move a tab bar to the top.
- A screen pushed from a tab sets `hidesBottomBarWhenPushed = YES`, so the
  parent tab bar is hidden after the push.
- Do not set a tab's root view controller `title`; set `navigationItem.title`,
  otherwise it replaces the tab item's title.

## Internationalization and localization

- Localization usually spans several files: structure them before use. On iOS,
  put all `<language>.lproj` string tables of one module into a single
  `.bundle`; several bundles are allowed, one per module.
- The core bundle (`CYLClassifyMenuResources.bundle`, sources in
  `CollectionViewClassifyMenu/Resources/Localization/`) always stays. Update it
  cautiously: keep keys stable, add every key to every language, never remove
  or rename a key without a documented, incompatible change.
- Example strings belong to an Example-level bundle
  (`Example/CYLMenuExample/CYLMenuExample.bundle`), never to the core bundle.
- Always look strings up through a macro that maps keys to its bundle:
  `CYLMenuLocalizedString(_:)` for the core (a Swift function since the core moved to Swift; Objective-C:
  `+[CYLMenuResources localizedStringForKey:]`), and
  one Swift function per example (`CYLExampleLocalizedString`,
  `CYLTagEditorLocalizedString`, `CYLDemoLocalizedString`). Do not call
  `NSLocalizedString` or read a bundle directly.
- Other platforms follow the same rules with their own resource mechanism: one
  resource container per module, the core one kept stable, a lookup helper per
  module.
- Acceptance criteria (following CYLTabBarController's localization rule at its
  newest commit: "Localization (i18n / l10n) file structure" in its AGENTS.md):
  - The core has its own lookup macro that reads the localized files inside the
    core's resource bundle. The bundle's form, name and folder name may differ
    per platform, but it is always a folder or package; on iOS it is a
    `.bundle` folder (`CYLClassifyMenuResources.bundle`, lookup
    `CYLMenuLocalizedString(_:)`: the core is Swift, which has no macros, so the
    function takes the macro's role, as in the examples).
  - Every example has its own lookup that reads the example's localized files
    from the example-level bundle. The examples are Swift, which has no macros,
    so each uses one global function in that role: `CYLExampleLocalizedString`
    (`Example/CYLMenuExample`), `CYLTagEditorLocalizedString` (`Example-Swift`),
    `CYLDemoLocalizedString` (the demo app).
  - A project passes only if it has at least two different lookup macros (or
    Swift functions), one per level, each reading a different bundle: the core
    one and at least one example's. No code reads a bundle or calls
    `NSLocalizedString` directly.
- No Chinese (or any user-facing) text in code (CYLTabBarController's "No
  Chinese text in code" rule): every string literal shown to a user, including
  accessibility labels, values and hints, goes through the lookup of its level,
  with `[NSString stringWithFormat:]` / `String(format:)` for values. Exceptions:
  localization keys stored in tables and looked up later, resource identifiers
  (image or file names), sample data loaded as data, and tests.
- Details and checks: `.agents/skills/cyl-localization/` (and the copied
  `ios-localization` skill for general iOS practice).

- Before a commit that touches strings or screens: `python3 scripts/check-localization.py` (every key a lookup is called
  with exists in every translated language with the same format specifiers; no Chinese literal outside a lookup) and
  `CYLLocalizationTests.testEveryScreenIsInTheAppLanguage` (every Example screen in English and Traditional Chinese).
  Data shared with other platforms (data.json, the places database, configuration files) keeps its source titles;
  the iOS screens translate them where they are shown. User-generated content (reviews, a shop's product title, song
  and user names) and deliberately multilingual samples stay as written, between `NOLOCALIZE-BEGIN` / `NOLOCALIZE-END`
  comments or with `NOLOCALIZE` on the line, with the reason.
- The Flutter and React Native examples take their strings from the iOS bundle: after changing those keys, run
  `python3 flutter/cyl_tag_list/example/tool/export_strings.py` and
  `python3 react-native/react-native-cyl-tag-list/example/tool/export_strings.py` (each has `--check`).

## Accessibility

Copied from CYLTabBarController ("Accessibility is required everywhere" in its
AGENTS.md, newest commit) and adapted to this project:

- The core library (the CocoaPods pod) and every example fully support
  accessibility: VoiceOver, Voice Control, Switch Control, Full Keyboard Access
  and Dynamic Type, plus Reduce Motion, Bold Text, Increase Contrast and Larger
  Text. This applies to new code, to code you change and to existing code you
  review: fix what is missing when you meet it.
- Every control and every piece of text is an accessibility element with a
  meaningful, localized label, and a value, traits (button, header, selected,
  not enabled) and a hint when useful: tags (selected or not), "+ 新建标签", the
  fold control ("<section> 更多/收起"), the list's title (a header), section
  headers, search fields, buttons and rows.
- Hide purely decorative views from accessibility; never leave an interactive
  view without a label. An icon-only element needs a label of its own.
- Text uses Dynamic Type (`adjustsFontForContentSizeCategory`, scaled fonts) and
  layouts grow with it; animations respect Reduce Motion
  (`UIAccessibilityIsReduceMotionEnabled`); colors keep enough contrast and do
  not carry meaning alone.
- The core's views have stable `accessibilityIdentifier`s (for example
  `CYLTagListFoldControl`, `CYLTagCreateItem`, `CYLTagListTitle`), so tests and
  tools find them without coordinates.
- Tests and simulator checks drive the UI through accessibility first: find
  elements by their accessibility label or identifier, and fall back to
  coordinates only when no element can be found, then file the missing label as
  a bug and fix it.
- A change that adds a control or a text without accessibility is not done.
- Details and checks: `.agents/skills/cyl-accessibility/` (and the copied
  `ios-accessibility`, `uikit-accessibility-auditor` and `accessibility-audit`
  skills).

## HarmonyOS: accessibility, localization and accessibility-first UI tests

- All code of this project supports visual accessibility and screen readers (blind users), the HarmonyOS code
  included (`harmony/classifymenu`, the library; `harmony/entry`, the example): every control and every piece of
  text is an accessibility element with a meaningful, localized label (`accessibilityText`), a description when it
  helps (`accessibilityDescription`), and its selected state (`CYLAccessibilitySelectedModifier`, API 13 and later;
  the library targets API 12). A tappable row or button made of several views is one element
  (`accessibilityGroup(true)`); an icon beside its label is decorative (`accessibilityLevel('no')`); a text field is
  labeled like its placeholder. Text sizes are `fp`, so they follow the system font size.
- All code supports internationalization and localization, with localization files: the HarmonyOS example's strings
  come from the iOS example bundle (`harmony/scripts/export-example-strings.py`, looked up with
  `CYLExampleLocalizedString`), the core's from the iOS core bundle (`CYLMenuLocalizedString`), and the strings the
  system shows (app name, ability label) and the tab titles copied from CYLTabBarController's HarmonyOS example are
  native resources (`resources/base|en_US|zh_CN|zh_TW/element/string.json`). Compare keys, never translated text,
  in code.
- If something is found that does not support accessibility or localization, add the support first, then go on
  with the task.
- The same rule covers the cross-platform HarmonyOS shells (`flutter/cyl_tag_list_ohos`,
  `react-native/react-native-cyl-tag-list/harmony-example`, whose strings are its own native resources and whose tab
  bar is CYLTabBarController's), and visual assistance includes touch targets of at least 44 vp.
- Automated UI tests locate controls through accessibility first: by the localized accessibility label
  (`ON.text(CYLExampleLocalizedString(key))`), then its description, and only then by an id
  (`cylFindAccessible` / `cylTapAccessible` in `harmony/entry/src/ohosTest/ets/test/TestSupport.ets`). This applies to
  taps, to complex flows and to sequences of actions. An id alone is only for controls without a distinctive label
  (rows of generated data). A control a test cannot find by its label is an accessibility bug: fix the label.
- Checks: `harmony/scripts/accessibility-check.py` (every image, input and control has a label or is marked
  decorative), `harmony/scripts/check-native-strings.py` (native string files complete and equal to the iOS strings),
  `harmony/scripts/unit-test.sh`. Details: `.agents/skills/cyl-harmonyos/`, `.agents/skills/cyl-accessibility/`,
  `.agents/skills/cyl-localization/`.

## Running scripts

- **Run scripts with bash, not the interactive shell.** Shell scripts and multi-line command sequences run in bash:
  `bash path/to/script.sh`, or `bash <<'EOF' … EOF` (or `bash -c '…'`) for an inline sequence; new scripts start with
  `#!/usr/bin/env bash` (a POSIX `#!/bin/sh` script is run with `sh` or `bash`, never sourced into zsh). The
  interactive shell on macOS is zsh, which behaves differently: it does not split an unquoted `$var` into words
  (`box="10 20 30 40"; set -- $box` gives one argument, so a measurement over `$box` silently reads one value), a
  variable holding a command with its arguments (`hdc="hdc -t 127.0.0.1:5563"; $hdc shell …`) fails with "no such
  file or directory", and a glob that matches nothing aborts the whole command. The error this rule prevents: "zsh
  doesn't split $box into words either. Running the same measurement as a bash script." Keep a command with
  arguments in a wrapper script or a bash array (`hdc=(hdc -t 127.0.0.1:5563); "${hdc[@]}" shell …`), never in a
  string variable.

## CI/CD and Example screenshots

- CI follows CYLTabBarController's `.github/workflows/ios.yml`; the scripts
  live in `scripts/` (see `.agents/skills/cyl-verify/`).
- Runner environment (GitHub CI/CD): the iOS jobs run on **macOS 26** by
  default (`runs-on: ${{ vars.MACOS_RUNNER || 'macos-26' }}`, the image's
  default Xcode 26.x; the repository variable `MACOS_RUNNER` selects another
  runner without editing the workflow). Before changing a runner, an Xcode
  version or a build setting that depends on them, always read
  CYLTabBarController's workflow first to confirm the environment:
  <https://github.com/ChenYilong/CYLTabBarController/blob/master/.github/workflows/ios.yml>,
  and the same file at its newest commit (see "CYLTabBarController reference
  and dependency"). Keep `ios.yml` on the runner they use.
- Local runs ignore that runner rule. A local run does not go through GitHub
  CI/CD: it uses the developer's Mac directly, with Xcode and the iOS
  Simulator started on that machine (`scripts/unit-tests.sh`,
  `scripts/example-screenshots.sh`, `xcodebuild`, `xcrun simctl`). Assume
  **macOS 27 with Xcode 27** there unless `sw_vers` / `xcodebuild -version`
  say otherwise, and pick a simulator that this Xcode provides
  (`scripts/simulator-id.sh`).
- Every CI run that builds code must provide screenshots of the Example app
  (`Example screenshots` job in `ios.yml`: the `example-screenshots` artifact,
  and a copy on the `ci-screenshots` branch under `<branch>/<commit>/`, which
  can be read through the GitHub API when artifact storage is not reachable). When
  reporting such a run, look at the screenshots and show them to the user,
  checking that each README scenario renders as expected.
- If the screenshots are missing or cannot be obtained, first find out why and
  change the CI (workflow or `scripts/example-screenshots.sh`) so that they are
  produced. If that is still not possible, explain the exact reason (for
  example the runner, the simulator or artifact download) to the user.

- **Screenshots: where they go.** Every screenshot, from CI/CD and from local builds alike, is saved in the
  Git repository and shown in the related document in `docs/` (images in `docs/assets/`); when no document fits,
  create one (the default is `docs/screenshots.md`). At the right moment, when you judge that the result looks as
  expected, update `README.md` with the newest images, in the matching section (create it if missing).
- **Screenshots: labels.** Every screenshot shown in `docs/` or `README.md` is labeled with:
  - the platform it ran on: iOS, Android, Flutter, React Native, HarmonyOS or Mini Program;
  - the environment: the operating system version, the simulator / emulator version, and the platform's SDK version
    (iOS, Android, Flutter, React Native, HarmonyOS or Mini Program SDK);
  - this repository's version number or commit URL;
  - the current time (when it was taken).
- **Screenshots: quality.** Use clear original images; never downscale or recompress them.
- **Screenshots: key moments.** Update the README images at key moments: for example when a `TODO` keyword or a
  `Linux` keyword can be removed, when a pull request can be merged, or when you judge the result as expected, with
  no bug and no open issue.
- **Screenshots: crop to the detail.** Screenshots in `README.md` show the key details, cropped; do not use
  full-screen captures unless necessary. Prefer one stitched image that shows several key details.
- **Screenshots: stitching layout.** Stitch in this order of preference: (1) stacked vertically, top to bottom, which
  reads best on a phone; (2) two columns, several rows; (3) last resort, side by side in one row, at most three
  columns per row. Correction (2026-11-12): the original request said both "prefer a horizontal layout" and "a horizontal stitch is the worst", which contradict each other; the user corrected it to vertical first.
- **Screenshots: stitching layout, update (2026-11-18).** Prompt (verbatim): "截图除了 优先选用竖版排列风格。优先两列，多行。且给拼接好的图增加header，footer，header，footer不能与截图区域重叠 覆盖，标注关键信息：关键信息也是英文，测试模拟器平台，模拟器系统版本，操作系统版本，ide 版本，以及测试目的等等。以附带的截图为例。提取截图的附带信息以及风格 完善我的描述规则。" This replaces the order above:
  - The stitched image is portrait (taller than wide). Default: two columns and as many rows as needed, filled left
    to right, then top to bottom, in step or time order. Use one column only for a single panel, or when two columns
    would make the image wider than tall (wide crops). Never more than two columns.
  - Every panel has the same size (the same crop rectangle), keeps its original pixels (no scaling) and shows whole
    elements: never cut through a row of controls.
  - Tool: `scripts/stitch-screenshots.swift`; details and checklist: `.agents/skills/cyl-screenshots/SKILL.md`.
- **Screenshots: header and footer (2026-11-18).** Every stitched image has a header band above the panels, a footer
  band below them and a caption band above each panel. No text is ever drawn on a screenshot; header, footer and
  captions never overlap or cover a panel. White background; a thin gray rule under the header and above the footer.
  All text is in English.
  - Header (red `#FF3B30`, bold): line 1 `Purpose:` what the test checks and the expected result, with the commit of
    the change under test; line 2 `Platform:` the simulator or emulator platform and device model, the simulator OS
    version, then `| Host:` the host operating system version, then `| IDE:` the IDE version.
  - Panel caption (red, bold, above the panel): step number, the state or action, the time offset from the first
    panel, the screen or launch argument, the measurement when there is one.
  - Footer (dark gray, regular): `Result:` the measured outcome (for example changed pixels); `Versions:` this
    repository's branch and commit, the dependency commits (CYLTabBarController) and engine versions; `Taken:` the
    local date and time with the time zone, then `| Stitched by` the script.
  - Fields per platform: iOS: Simulator device, iOS version, Xcode version, macOS version. Android: emulator (AVD)
    and API level, Android Studio or Gradle and JDK, host OS. HarmonyOS: emulator name, HarmonyOS version, DevEco
    Studio version, host OS. Mini Program: WeChat DevTools version and base library version, host OS. Flutter and
    React Native: the Flutter or React Native version plus the fields of the platform it ran on.
  - Example and its lessons: `docs/assets/ios-rive-rest.png` (first version: one red bold header with the platform,
    simulator, Xcode, dependency commit, branch, date and purpose; a red bold caption above each panel in its own
    band; but no host OS, everything crammed into the header, one column, a panel cut through the Shapes row) and its
    redo by these rules, `docs/assets/ios-rive-rest-then-play-grid.png`.
- **Screenshots: columns, update (2026-11-18, later).** Prompt (verbatim): "更新截图规则，优选一列多行 如果一列拼接后长度超过普通手机的一屏幕 则两列多行" This replaces the column order of the update above:
  one column first, panels top to bottom; when the one-column image (header and footer included) would be longer
  than one screen of an ordinary phone, i.e. taller than 19.5:9 (height > 2.17 x width, the shape of an iPhone 17 Pro
  screen, 1206 x 2622 px), use two columns and several rows, filled left to right, then top to bottom. Never more
  than two columns.
  `scripts/stitch-screenshots.swift` chooses this way by default (`--columns auto`). Examples: one column,
  `docs/assets/ios-rive-rest-one-column.png` (two cropped panels); two columns,
  `docs/assets/ios-rive-rest-then-play-grid.png` (four full screens).

- **Screenshots: enforced (2026-11-18).** Prompt (verbatim): "检查为什么没有应用新增的截图Label规范，并强化该策略保证以后截图必须遵循该规范，避免再出现该问题。" Why
  they were missed (Windows session, four images committed 09:54-11:03: `miniprogram-devtools-gif-stills-play-all.png`,
  `miniprogram-devtools-rive-rest-until-played-dcbfdec6.png`, `android-rive-menu-stuck-dcbfdec6.png`,
  `android-rive-menu-stuck-ad3dca0e.png`): (1) the header / footer rules were committed by another session at 11:06 and
  11:10, while that session ran; instructions are read once at session start and nothing told it to read them again;
  (2) the older rules ("labels", 2026-11-12: platform, environment, repository version, time; "quality": no scaling)
  were broken too, because on Windows there was no stitch tool (the Swift one needs macOS) and the images were composed
  by hand (PIL): downscaled, captions only, no environment, commit or time; (3) nothing checked an image before it was
  committed. All four are restitched. So:
  - **Re-read before every screenshot.** Before taking or stitching a screenshot, `git pull` and read
    `.agents/skills/cyl-screenshots/SKILL.md` again: the rules can change while a session runs.
  - **Only the stitch tools make a screenshot for `docs/` or `README.md`:** `scripts/stitch-screenshots.py` (any host,
    Python with Pillow) or `scripts/stitch-screenshots.swift` (macOS), same arguments. Never compose, crop-and-paste,
    annotate or resize an image by hand or with an ad-hoc script. A single raw screen is stitched too (one panel).
  - **The tools refuse an incomplete label:** the header needs `Purpose:`, `Platform:`, `Host:` and `IDE:`, the footer
    `Result:`, `Versions:` and `Taken:`, every panel a caption. They write the label into the PNG.
  - **Checked before every commit:** `scripts/check-screenshots.py` (run by `bash scripts/check-branch-pr.sh`, exit 3
    when a staged screenshot has no label). A failing check is fixed by restitching, never by skipping it. Not checked
    in CI (2026-11-18, prompt verbatim: "Remove label CI screenshots from ci"; the workflow
    `.github/workflows/screenshot-labels.yml` is removed, as in CYLTabBarController `70064275`). Only images that are not screenshots or that a script
    regenerates as a set go into `scripts/screenshot-check-exempt.txt`, with the reason.

## Documentation assets

- Images and other attachments of a Markdown file go into an `assets/` folder
  next to that file (as Obsidian saves new attachments): `README.md` uses
  `assets/`, a file in `docs/` uses `docs/assets/`. Link them with the shortest
  relative path (`![…](assets/<file>)`), never with absolute GitHub URLs or
  external image hosts.
- Name files in English, lowercase with hyphens, after what they show
  (`swift-tag-editor.png`, `scenario1-taobao-review-filter.gif`).
- README screenshots of the examples come from a CI run of the current commit
  (the `ci-screenshots` branch, see "CI/CD and Example screenshots"); replace them
  when the screens change.

## Repository hygiene

- Ignore macOS AppleDouble metadata (`._*`), `.DS_Store`, and stray doubled-dot
  copies such as `..git`, `..github`, `..gitignore`, and `..claude`.
- If such files are already tracked, remove them from Git's index while
  preserving local files; never commit them. Do not rewrite published history
  without explicit approval.
- If AppleDouble files inside `.git/objects` interfere with Git, inspect the
  exact files and preserve them before removing them; run `git fsck --full`
  afterward. Do not blindly delete files from Git's object store.
- Stage only intended changes and check the staged diff before committing.
- Before every commit, update `.gitignore` from CYLTabBarController's
  `.gitignore` (its newest commit, see "CYLTabBarController reference and
  dependency"): add every file and folder it ignores, and
  change only what does not match this project (project names such as
  `CYLTabBarController.xcodeproj`, example folder names). Keep this project's
  own rules. Then run `git ls-files -ci --exclude-standard`: remove every
  tracked file it lists from the index (`git rm --cached`, local files kept),
  after checking that nothing needs it (CocoaPods workspaces and lock files are
  regenerated by `pod install` in the CI scripts).

## Branches and pull requests

- **Every new branch gets a pull request right away, without asking.** As soon as a branch is created and first
  pushed, open its pull request (`gh pr create --base <source branch>`) and give the link in the reply.
- Target (base) branch: the branch the new one was created from (its source branch), preferred; otherwise `main` or
  `master`.
- Opening is automatic; merging still follows the rules of the repository and the user's approval.
- **A branch with commits always has an open pull request.** Never create a branch and keep committing to it
  without a pull request: the commits of a branch without one are ignored (nobody reviews or merges them).
- **Before every commit, check the branch's pull request** (`bash scripts/check-branch-pr.sh`). If the branch has no
  open pull request (none yet, or the previous one was closed or merged), open a new one before committing.
- **Target (base) of a new pull request:** the branch of the pull request that was active (open) before the new branch
  was created, preferred; only when there is none, `master` (or `main`).
- **More than two open pull requests: stop and ask the user** whether to create a new branch and pull request or to keep
  committing on the current branch. More than two open branches make merging hard and leave no sensible target branch
  for each.
- **Commit and push at the end of every answer, without asking, on any branch other than `master` / `main`.** When
  a question-and-answer turn ends and the current branch is not `master` or `main`, commit the work (following the
  checks above: an open pull request, `bash scripts/check-branch-pr.sh`) and push it. This is safe: the code is always
  on a branch, never pushed to `master` / `main`, so a push carries no risk that needs a question first. Never push to
  `master` / `main` this way.
- Details: `.agents/skills/cyl-commit/`. The same rule is in the vault's root `instructions.md` (section 15).

## Upstream projects (translations and ports)

- **Upstream projects used for translation.** When a document of this project links to a GitHub repository of
  another project, and that repository is the source of a translation or port (for example the projects ported to
  Kotlin in `android/`), do not translate only its default branch:
  1. **Pull requests.** Visit the upstream's open pull requests and bring them in. If the translation has not started,
     merge the open pull requests into the source first; if it is already done, translate each open pull request's
     change and merge it into our port.
  2. **Issues.** List the upstream's open issues in a table in the related document in `docs/` (create one when none
     fits): column 1 the issue link, column 2 its description, column 3 the fix status (`TODO` by default). Find each
     issue's counterpart in our code and try to fix it.
  3. **Score.** 100 means every listed issue is resolved. Give a score after each fixed issue and continue until 100.
  4. **Order.** For a translation not started yet: merge the open pull requests, fix issues until the score reaches
     60, translate, then fix the remaining issues up to 100. For a finished translation: translate and merge the open
     pull requests, then fix the issues on the translated code up to 100.
  5. The same rule applies to every platform (iOS, Android, Flutter, React Native, HarmonyOS, Mini Program).
  Details: `.agents/skills/cyl-upstream/`. The same rule is in the vault's root `instructions.md` (section 17).

## Issue progress

- Keep all issues in `docs/issue-progress.md`, including non-UI issues.
- After each issue-fix commit, add its URL and reassess the score. Explain
  unverified scenarios and why a score is below 100.

## Image resources: folder bundles (added 2026-11-19)

- **New images of the core live as files in a folder bundle**, never in an asset catalog (user's prompt, verbatim:
  "请确保新增的图片资源文件在core代码仓库中均以文件夹形式管理，以iOS为例，图片资源文件均存放在.bundle的文件夹形式中"). On iOS that folder is
  `CollectionViewClassifyMenu/Resources/CYLClassifyMenuImages.bundle` (PNG files at @1x, @2x, @3x, e.g. `cyl_trash`),
  as CYLTabBarController's `CYLAnimatedItem.bundle`: the podspec copies it into `CYLClassifyMenuResources.bundle`,
  `Package.swift` copies it with `.copy`, and `CYLMenuResources.image(named:)` reads it first (`imagesBundle`).
  Other platforms keep their images in a resource folder of the same kind.

