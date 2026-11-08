# Agent instructions

CollectionViewClassifyMenu is an Objective-C iOS demo with a collapsible
collection-view menu and a multiple-choice filter. Read `README.md` and the
relevant source before changing behavior. If documentation and code disagree,
verify the behavior and update the applicable documentation.

## Code and naming

- Preserve existing public APIs and user content; use the existing `CYL` prefix
  for new project-specific Objective-C types.
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
