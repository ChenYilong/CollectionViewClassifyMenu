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
- Use English Conventional Commit messages, such as `fix: 🐛 ...` and
  `docs: 📝 ...`.

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
  `CYLMenuLocalizedString` for the core, `CYLExampleLocalizedString` for the
  Example. Do not call `NSLocalizedString` or read a bundle directly.
- Other platforms follow the same rules with their own resource mechanism: one
  resource container per module, the core one kept stable, a lookup helper per
  module.
- Details and checks: `.agents/skills/cyl-localization/`.

## CI and Example screenshots

- CI follows CYLTabBarController's `.github/workflows/ios.yml`; the scripts
  live in `scripts/` (see `.agents/skills/cyl-verify/`).
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

## Issue progress

- Keep all issues in `docs/issue-progress.md`, including non-UI issues.
- After each issue-fix commit, add its URL and reassess the score. Explain
  unverified scenarios and why a score is below 100.
