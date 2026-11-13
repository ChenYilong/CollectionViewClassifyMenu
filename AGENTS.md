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
- Every commit message's description (the body) must contain the author line
  `By @ChenYilong <luohanchenyilong@163.com>`, exactly as written, on its own
  line after the description and before any trailers. Details:
  `.agents/skills/cyl-commit/`.

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
  `swift-concurrency`, `cyl-swift`). The Swift API callers see and the
  Objective-C names stay the same (`@objc(CYLName)`, `@objc(selector:)`);
  `scripts/swift-api-check.sh` must report no API breakage after every commit.
  Progress and score (no Objective-C file left = 100): `docs/Swift-Migration.md`.
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
- Before every build, find the newest commit with
  `scripts/cyl-tabbar-latest-commit.sh` (it fetches the tip of every branch and
  sorts by committer date; `--check` fails when a Podfile pins another commit).
  When it changed, update every pin and anything copied from CYLTabBarController
  in the same commit, after checking what changed in between.
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
- The core library does not depend on CYLTabBarController: it finds the
  animation engine (`CYLTabBarItemAnimationFactory`) and the configuration
  parser (`CYLTabBarConfigurationParser`) at runtime, because the published
  CocoaPods release lacks them. Only the examples link it.
- Details: `.agents/skills/cyl-dependency/`.

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
  `CYLMenuLocalizedString` for the core (Swift: `CYLMenuLocalizedString(_:)`), and
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
    `.bundle` folder (`CYLClassifyMenuResources.bundle`, macro
    `CYLMenuLocalizedString`).
  - Every example has its own lookup that reads the example's localized files
    from the example-level bundle. The examples are Swift, which has no macros,
    so each uses one global function in that role: `CYLExampleLocalizedString`
    (`Example/CYLMenuExample`), `CYLTagEditorLocalizedString` (`Example-Swift`),
    `CYLDemoLocalizedString` (the demo app). A core macro also needs a function
    Swift can call.
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
