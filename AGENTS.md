# Agent instructions

CollectionViewClassifyMenu is an Objective-C iOS demo with a collapsible
collection-view menu and a multiple-choice filter. Read `README.md` and the
relevant source before changing behavior. If documentation and code disagree,
verify the behavior and update the applicable documentation.

## [guidelines] Behavioral guidelines: read in full first

- **Read [docs/instructions/Behavioral_guidelines_to_reduce_common_LLM_coding_mistakes.md](docs/instructions/Behavioral_guidelines_to_reduce_common_LLM_coding_mistakes.md) in full, every line, before any task.** It is required reading, not a summary: think before
  coding (state assumptions, ask when unclear), simplicity first, surgical changes, goal-driven execution with
  verifiable success criteria. Where it and a project rule below differ, the project rule decides.

## [instructions] How these instructions are organized

- Every rule is filed under a tag, and each tag is a visible heading here: `## [<tag>] <title>`. Read the headings
  whose tags match the task (testing, windows, macos, docs, …) and open the linked file for the details.
- This file stays at 200 lines or fewer. When a tag's text would push it over, the overflow goes into
  `docs/instructions/<tag>.md`, linked here with a relative path; the heading and a short form stay here.
- Section names are unchanged in the tag files: a reference such as AGENTS.md "Fix issues in the core first" means
  that section in the tag file listed below. CLAUDE.md, `docs/instructions.md`, `scripts/instructions.md` and
  `harmony/instructions.md` use the same tag headings. Details: `.agents/skills/cyl-instructions/SKILL.md`.

| Tag | Covers | Details |
|:---|:---|:---|
| `guidelines` | behavioral guidelines, read in full before any task | [Behavioral_guidelines_to_reduce_common_LLM_coding_mistakes.md](docs/instructions/Behavioral_guidelines_to_reduce_common_LLM_coding_mistakes.md) |
| `workflow` | task log, task start, acceptance score, issue progress | [workflow.md](docs/instructions/workflow.md) |
| `sessions` | session roles, shared emulators, running scripts | [sessions.md](docs/instructions/sessions.md) |
| `windows` | Windows-only notes: shell, paths, HarmonyOS and Android tools | [windows.md](docs/instructions/windows.md) |
| `macos` | macOS-only: Xcode, CocoaPods, iOS simulator | [macos.md](docs/instructions/macos.md) |
| `testing` | example tests, parity tables, CI/CD, screenshots | [testing.md](docs/instructions/testing.md) |
| `harmonyos` | x86_64 emulator, accessibility-first UI tests | [harmonyos.md](docs/instructions/harmonyos.md) |
| `code` | naming, comments, commits, Swift core, core first, bugs | [code.md](docs/instructions/code.md) |
| `dependencies` | CYLTabBarController pins, licenses, resources, upstreams | [dependencies.md](docs/instructions/dependencies.md) |
| `examples` | example demo rules, search bars, tab bars | [examples.md](docs/instructions/examples.md) |
| `i18n` | localization bundles and lookups | [i18n.md](docs/instructions/i18n.md) |
| `accessibility` | accessibility everywhere | [accessibility.md](docs/instructions/accessibility.md) |
| `docs` | documentation assets, bilingual documents | [docs.md](docs/instructions/docs.md) |
| `git` | branches, pull requests, repository hygiene | [git.md](docs/instructions/git.md) |

## [workflow] Tasks and workflow

- Record every task in `docs/` before starting it: a `TODO` entry with the context, the requirements and the user's
  prompt verbatim; mark it done with the result and evidence (commits, tests, screenshots).
- Check the other sessions first (same branch? duplicate task?). Write `TODO (branch <branch>): <task>` at the top of
  the first reply. Give the task acceptance criteria (100 = full marks, pass 60 unless stated) and score until it
  passes; write the missing points into the document and list them as `TODO` at the end of the session.
- Keep every issue in `docs/issue-progress.md`; after each fix commit add its URL and the new score.
- Sections: [Task log in docs/](docs/instructions/workflow.md#task-log-in-docs) · [Task start: TODO, branch, acceptance score](docs/instructions/workflow.md#task-start-todo-branch-acceptance-score) · [Issue progress](docs/instructions/workflow.md#issue-progress).

## [sessions] Sessions and shared devices

- Session names: `Mac…` sessions mainly do iOS; `Win…` sessions do Android, HarmonyOS, the mini program and the
  Android runs of Flutter and React Native. When both are active, route each platform's part to its owner.
- Emulators and simulators are shared: tell the other sessions before restarting a hung one and when it is back; an
  emulator that will not boot is restarted without asking.
- Run scripts with bash (`bash script.sh`, `bash <<'EOF'`), never in the interactive zsh.
- Sections: [Session roles by name: Mac for iOS, Win for the other platforms](docs/instructions/sessions.md#session-roles-by-name-mac-for-ios-win-for-the-other-platforms) · [Shared emulators and simulators](docs/instructions/sessions.md#shared-emulators-and-simulators) · [Running scripts](docs/instructions/sessions.md#running-scripts).

## [windows] Windows-only scenarios

- Git Bash needs `MSYS_NO_PATHCONV=1` for `hdc shell` paths; `hdc` misreads some absolute paths (use relative
  ones); Python is `py -3` with `PYTHONUTF8=1`.
- The HarmonyOS emulators are x86_64: use the `emulator` target (see [harmonyos]). Windows cannot build iOS or run
  Rive and PAG playback: hand those to the macOS session or CI.
- Details: [windows.md](docs/instructions/windows.md).

## [macos] macOS-only scenarios

- iOS 15.0 minimum; keep `objectVersion = 46` and `compatibilityVersion = "Xcode 3.2"`; never commit Xcode user
  state or derived data; validate with `pod lib lint CollectionViewClassifyMenu.podspec`.
- Local runs use the developer's Mac (assume macOS 27, Xcode 27; `scripts/simulator-id.sh`); `pod install` and the
  iOS build of every pin move are done on macOS. The macOS (arm64) session also runs Rive and PAG playback tests.
- Sections: [Xcode and CocoaPods](docs/instructions/macos.md#xcode-and-cocoapods); CI runners: [testing.md](docs/instructions/testing.md#cicd-and-example-screenshots).

## [testing] Testing, parity and CI

- Example tests: one test class per feature, one file each; shared helpers are protocols in
  `Example-Shared/TestSupport/`. UI tests find controls through accessibility first.
- Parity tables: source API | description | counterpart (`TODO` by default); score = rows with a counterpart / all
  rows × 100; loop until 100, core first, then the reverse table. Generated tables are never edited by hand.
- CI follows CYLTabBarController's `ios.yml` (macOS 26 runners, `MACOS_RUNNER`). Every build run produces Example
  screenshots; look at them and show them. Screenshots go to `docs/assets/` through `scripts/stitch-screenshots.py`
  / `.swift` only, with the full header and footer label; re-read `.agents/skills/cyl-screenshots/SKILL.md` first.
- Sections: [Example tests](docs/instructions/testing.md#example-tests) · [Parity tables and the score loop](docs/instructions/testing.md#parity-tables-and-the-score-loop) · [CI/CD and Example screenshots](docs/instructions/testing.md#cicd-and-example-screenshots).

## [harmonyos] HarmonyOS

- x86_64 emulator (install error 9568347): the default HAP's Rive and PAG libraries are arm64-only. Use the entry's
  `emulator` target / `emulatorTest` mode (`ui-test.sh` picks them); CYLTabBarController's `CYLAnimatedItemView`
  shows PAG and Rive as still images there. Never add the ABI filter to the default target.
- Rive and PAG tests that need arm64: plan 1, x86_64 libraries from GitHub in `CYLAnimatedItemView`, guarded by the
  running architecture and, until verified, a debug build guard (its removal needs the owner's approval); compile and
  no crash first, then playback. Plan 2 if it fails: forward the tests to the macOS (arm64) session.
- All HarmonyOS code is accessible and localized (`accessibilityText`, groups, decorative icons, `fp` sizes); UI tests
  locate controls by localized label, then description, then id.
- Sections: [HarmonyOS: the HAP will not install on an x86_64 emulator (arm64-only Rive and PAG)](docs/instructions/harmonyos.md#harmonyos-the-hap-will-not-install-on-an-x86_64-emulator-arm64-only-rive-and-pag) · [HarmonyOS: accessibility, localization and accessibility-first UI tests](docs/instructions/harmonyos.md#harmonyos-accessibility-localization-and-accessibility-first-ui-tests).

## [code] Code, Swift core and bugs

- `CYL` prefix, `cyl_` category methods; keep public APIs; document user-visible changes and verify them.
- Public API comments are blocks (`/*! … */` in Objective-C headers, `/** … */` in Swift and other languages), never
  stacked one-line comments (`.agents/skills/cyl-comments/`).
- Commits: `git cz` style (`<type>(<scope>): <emoji> <summary>`), English only, with the author line
  `By @ChenYilong <luohanchenyilong@163.com>`; check with `scripts/check-commit-message.sh`.
- Every iOS example is Swift; the core is moving to Swift (`docs/Swift-Migration.md`); core quality first, examples
  last.
- Fix issues in the core first (the code published to a registry); an example-layer fix is the last resort, asked
  for first and recorded in `docs/example-layer-fixes.md`. Bugs: record, screenshot, fix, screenshot again; animation
  and icon + title bugs are fixed in CYLTabBarController's animated item.
- Sections: [Code and naming](docs/instructions/code.md#code-and-naming) · [Swift examples and a Swift-friendly core](docs/instructions/code.md#swift-examples-and-a-swift-friendly-core) · [Fix issues in the core first](docs/instructions/code.md#fix-issues-in-the-core-first) · [Bugs: record, screenshot, fix in CYLTabBarController's animated item](docs/instructions/code.md#bugs-record-screenshot-fix-in-cyltabbarcontrollers-animated-item).

## [dependencies] Dependencies, licenses and resources

- CYLTabBarController always means its newest commit over every branch: run `scripts/cyl-tabbar-latest-commit.sh`
  before every build and move every pin (Podfiles, `Package.swift`, Flutter, React Native, Android, mini program,
  HarmonyOS vendored module) in one commit. Never a version, branch or tag. CYLSearchViewController pins the same.
- Every published package ships its license inside its resource container. Bundled animation files stay unmodified
  (documented exceptions only). New core images live in folder bundles. Upstream projects of a port: bring in their
  open pull requests and track their open issues.
- Sections: [CYLTabBarController reference and dependency](docs/instructions/dependencies.md#cyltabbarcontroller-reference-and-dependency) · [License in every published package](docs/instructions/dependencies.md#license-in-every-published-package) · [Bundled animation files](docs/instructions/dependencies.md#bundled-animation-files) · [Image resources: folder bundles (added 2026-11-19)](docs/instructions/dependencies.md#image-resources-folder-bundles-added-2026-11-19) · [Upstream projects (translations and ports)](docs/instructions/dependencies.md#upstream-projects-translations-and-ports).

## [examples] Example demo rules

- Animation screens on every platform offer Play all, a speed slider and a loop switch (`docs/example-demo-rules.md`).
- A search bar never covers any view. Tab bars are always at the bottom; pushed screens hide the bottom bar; set
  `navigationItem.title`, not the tab root's `title`.
- Sections: [Example demo rules](docs/instructions/examples.md#example-demo-rules) · [Search bars](docs/instructions/examples.md#search-bars) · [Tab bars](docs/instructions/examples.md#tab-bars).

## [i18n] Internationalization and localization

- One bundle per module; the core bundle stays and its keys are stable. Strings go through the level's lookup
  (`CYLMenuLocalizedString`, one function per example); no user-facing literal in code.
- Before a commit that touches strings: `python3 scripts/check-localization.py`; the Localization CI blocks like a
  failing test.
- Sections: [Internationalization and localization](docs/instructions/i18n.md#internationalization-and-localization).

## [accessibility] Accessibility

- The core and every example support VoiceOver, Voice Control, Switch Control, Full Keyboard Access, Dynamic Type,
  Reduce Motion, Bold Text and Increase Contrast. Every control has a localized label; decorative views are hidden;
  core views have stable identifiers. A change that adds a control without accessibility is not done.
- Sections: [Accessibility](docs/instructions/accessibility.md#accessibility).

## [docs] Documentation

- Attachments go into an `assets/` folder next to the Markdown file, linked by relative path, named in English.
- `README.md` and the converted documents in `docs/` are bilingual (`docs/Bilingual-Documentation.md`); check with
  `python3 scripts/bilingual-docs.py check <file> --against origin/master`.
- Sections: [Documentation assets](docs/instructions/docs.md#documentation-assets) · [Documentation: bilingual Chinese–English (added 2026-11-20)](docs/instructions/docs.md#documentation-bilingual-chineseenglish-added-2026-11-20).

## [git] Git, branches and repository hygiene

- Every new branch gets a pull request right away; a branch with commits always has one. Run
  `bash scripts/check-branch-pr.sh` before every commit; more than two open pull requests: ask the user first.
- At the end of every answer on a branch other than `master` / `main`, commit and push.
- Never commit `._*`, `.DS_Store` or doubled-dot copies; never rewrite published history without approval.
- Sections: [Branches and pull requests](docs/instructions/git.md#branches-and-pull-requests) · [Repository hygiene](docs/instructions/git.md#repository-hygiene).
