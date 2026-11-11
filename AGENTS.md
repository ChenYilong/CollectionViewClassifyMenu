# Agent instructions

CollectionViewClassifyMenu is an Objective-C iOS demo with a collapsible
collection-view menu and a multiple-choice filter. Read `README.md` and the
relevant source before changing behavior. If documentation and code disagree,
verify the behavior and update the applicable documentation.

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
  A one-line `///` is fine for a one-line comment. In Swift source, where the
  compiler does not treat `/*!` as documentation, use `/** … */` (or `///` for
  one line). Other platforms use their official documentation format (KDoc
  `/** … */` for Kotlin, Javadoc for Java, JSDoc/TSDoc `/** … */` for
  JavaScript/TypeScript, Dart `///`, Rust `///`, Python docstrings). Plain `//`
  comments are for implementation notes only, never for public API docs.
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
  `TagCollectionView` demo. Never add Objective-C example code. Only the core
  library (the pod's sources) and its own tests stay in Objective-C.
- The core library stays in Objective-C. When an example calls an Objective-C API
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
- If this project is CYLTabBarController itself, depend on it locally instead:
  `pod 'CYLTabBarController', :path => '<relative path to the folder that holds
  CYLTabBarController.podspec>'`. Every other project uses the commit.
- The core library does not depend on CYLTabBarController: it finds the
  animation engine (`CYLTabBarItemAnimationFactory`) and the configuration
  parser (`CYLTabBarConfigurationParser`) at runtime, because the published
  CocoaPods release lacks them. Only the examples link it.
- Details: `.agents/skills/cyl-dependency/`.

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

## Issue progress

- Keep all issues in `docs/issue-progress.md`, including non-UI issues.
- After each issue-fix commit, add its URL and reassess the score. Explain
  unverified scenarios and why a score is below 100.
