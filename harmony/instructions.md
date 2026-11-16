# harmony folder instructions

- This folder is the HarmonyOS NEXT port: `classifymenu` (the core, a HAR) and `entry` (the example).
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
