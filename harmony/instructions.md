# harmony folder instructions

- This folder is the HarmonyOS NEXT port: `classifymenu` (the core, a HAR) and `entry` (the example).
- Fix issues in the core first (AGENTS.md "Fix issues in the core first"): the core is the code published to a package registry (here: `classifymenu`, the ohpm HAR; `entry` is the example layer); an example-layer fix is the worst option; when the core cannot fix a core defect, ask the user first and say why; record every example-layer fix and its reason in `docs/example-layer-fixes.md`.
- Accessibility and localization: AGENTS.md "HarmonyOS: accessibility, localization and accessibility-first UI tests"
  (every control labeled and localized, support added first where missing, UI tests locate controls through
  accessibility first). Checks: `harmony/scripts/accessibility-check.py`, `harmony/scripts/check-native-strings.py`,
  `harmony/scripts/unit-test.sh`; parity: `docs/harmony.md`.
- Commits: `git cz` style, English only, no Chinese characters (AGENTS.md "Commit messages: git cz style, English
  only"; `scripts/check-commit-message.sh`).
- Run scripts with bash (`bash harmony/scripts/<name>.sh`), never by pasting their commands into zsh; keep `hdc -t
  <target>` in a wrapper script or a bash array (AGENTS.md "Running scripts").
- Before every commit: `bash scripts/check-branch-pr.sh` (an open pull request for the branch; ask the user when more
  than two are open; AGENTS.md "Branches and pull requests").
- At the end of every answer, on a branch other than `master` / `main`: commit and push without asking.
- Parity tables and the score loop (AGENTS.md "Parity tables and the score loop"): source API | description | counterpart (`TODO` by default); 100 when no `TODO` is left, 0 when all are; loop: match existing code, score, implement the `TODO` rows in the core first and show them in the example, score again, until 100; then the reverse table.
- Bugs (AGENTS.md "Bugs: record, screenshot, fix in CYLTabBarController's animated item"): record first, then screenshot, then fix; animation and icon + title bugs are fixed in CYLTabBarController's animated item component, not in the examples; a demo that needs more gets a new component API from CYLTabBarController.
- Session roles by name (AGENTS.md "Session roles by name: Mac for iOS, Win for the other platforms"): before a task, check the active session names. A session whose name starts with Mac (case insensitive) mainly develops and tests iOS; one starting with Win (case insensitive) mainly develops the other platforms (Android, HarmonyOS, the mini program). When both are active, prefer handing each platform's part of a task to the matching session; when no session follows this naming, skip the rule and finish the task independently.
