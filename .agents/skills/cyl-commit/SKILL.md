---
name: cyl-commit
description: Commit message format for CollectionViewClassifyMenu (Conventional Commits with emoji, the required author line), the task log in docs/ kept before and after every task, the checks to run before every commit, and the pull request every new branch gets.
---

# Commits

## Task log in docs/ (before any work)

1. Find the most relevant existing document in `docs/` (create one only when none fits); the general TODO list is
   the "待办 / TODO" section of `docs/issue-progress.md`.
2. Add a `TODO` entry before changing anything: the detailed context (branch, files, what was found so far), the
   user's requirements, and the user's prompt quoted verbatim.
3. Do the task. Commit the entry with the first commit of the task, so it survives an interruption.
4. When the task is finished, mark the entry done and add the result and its evidence (commits, test counts,
   screenshots).
5. The entry also holds the acceptance scoring criteria (full marks and pass), the score and why it is not full marks;
   the missing points are printed as `TODO` at the end of the session. See `.agents/skills/cyl-task-start/`.

## Fix issues in the core first

- The core is the code published to a package registry: the CocoaPods pod / Swift package, the Maven / Gradle
  libraries (`android/merged/library`, `android/AndroidTagView/androidtagview`), the npm package
  `react-native-cyl-tag-list` (not its examples), the pub.dev plugins (not their `example/`), the ohpm HAR
  `harmony/classifymenu` (not `harmony/entry`) and the mini program packages. Everything else is the example layer.
- Fix every issue or bug in the core first, even one seen only in an example screenshot, so that every app using the
  library and every similar case is fixed. Look for the core cause (a default, a missing option, a layout or
  measurement rule, a missing localization or accessibility hook, a color that ignores the color mode) before
  touching the example.
- An example-layer fix is the worst option: only for a defect that really is in example code or data (a demo string,
  a demo page's own layout, a screenshot script), or when the core cannot fix it.
- When a core defect cannot be fixed in the core: ask the user first and say why (a third-party bug, a platform
  limitation, an API kept for compatibility).
- Record every example-layer fix in `docs/example-layer-fixes.md` (issue, files, why not in the core) and mention it in
  the issue's progress-table row. Full rule: AGENTS.md "Fix issues in the core first".

## Bugs: record, screenshot, fix upstream

- Bugs (AGENTS.md "Bugs: record, screenshot, fix in CYLTabBarController's animated item"): record first, then screenshot, then fix; animation and icon + title bugs are fixed in CYLTabBarController's animated item component, not in the examples; a demo that needs more gets a new component API from CYLTabBarController.

## Message

```
<type>: <emoji> <summary in English, imperative or descriptive, no trailing period>

<what changed and why, wrapped at about 72 columns>

By @ChenYilong <luohanchenyilong@163.com>

<trailers, if any (Co-Authored-By:, …)>
```

- Types and emoji: `feat: ✨`, `fix: 🐛`, `docs: 📝`, `refactor: ♻️`, `test: ✅`, `chore: 🔧`, `ci: 👷`,
  `perf: ⚡️`, `style: 💄`.
- **The author line is required in every commit message**: `By @ChenYilong <luohanchenyilong@163.com>`, exactly as
  written (one space after `By`, the `@` handle, the address in angle brackets), on its own line after the
  description and before the trailers. A commit without it is not done; amend it before pushing (never rewrite
  commits that are already published without approval).
- No model identifiers in messages.

Check the last commit:

```sh
git log -1 --format=%B | grep -qxF 'By @ChenYilong <luohanchenyilong@163.com>' && echo ok || echo "missing author line"
```

## git cz style, English only

Every commit is written in the `git cz` (commitizen, cz-emoji)
  style: the subject is `<type>(<optional scope>): <emoji> <summary>`, with the type one of `feat`, `fix`, `docs`,
  `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore` or `revert` (for example `feat: ✨ …`, `fix(harmony): 🐛
  …`), followed by a body and the author line. The whole message (subject, body and trailers) is in English: no
  Chinese characters, and no other non-English text, are allowed anywhere in a commit message. Write a user's
  non-English prompt only in the task log in `docs/` (quoted verbatim there), never in a commit. Check:
  `scripts/check-commit-message.sh [range]`.

```sh
scripts/check-commit-message.sh                    # the last commit
scripts/check-commit-message.sh origin/master..HEAD   # every commit of the branch
```

## Before every commit

- A fix in the example layer: is it recorded, with the reason it is not in the core, in `docs/example-layer-fixes.md`, and did the user agree when the defect was in the core?

1. `scripts/cyl-tabbar-latest-commit.sh --check` (see `cyl-dependency`); update the pins and anything copied from
   CYLTabBarController in the same commit.
2. Update `.gitignore` from CYLTabBarController's newest commit, then `git ls-files -ci --exclude-standard` and
   untrack what it lists (AGENTS.md, "Repository hygiene").
3. Stage only the intended files and read `git diff --cached --stat` (no `._*`, `.DS_Store`, user state or Pods).
4. For an issue fix, update `docs/issue-progress.md`.

## Branches and pull requests

Every time a branch is created, open its pull request automatically; never ask first.

1. Note the source branch before creating the new one: `SOURCE=$(git branch --show-current)`.
2. Create the branch, commit, and push it: `git push -u origin <new-branch>`.
3. Open the pull request against the source branch, preferred; use `main` or `master` only when the source branch
   is not on the remote (or the branch was not created from another branch):

   ```sh
   gh pr create --base "$SOURCE" --head <new-branch> --title "<commit-style title>" --body "<summary>"
   ```

4. Give the pull request link in the reply. If a pull request for the branch already exists
   (`gh pr list --head <new-branch> --state all`), reuse it instead of opening another one.

Opening is automatic; merging follows the repository's rules and the user's approval.

### Pull request before every commit

- **A branch with commits always has an open pull request.** Never create a branch and keep committing to it
  without a pull request: the commits of a branch without one are ignored (nobody reviews or merges them).
- **Before every commit, check the branch's pull request** (`bash scripts/check-branch-pr.sh`). If the branch has no
  open pull request (none yet, or the previous one was closed or merged), open a new one before committing.
- **Target (base) of a new pull request:** the branch of the pull request that was active (open) before the new branch
  was created, preferred; only when there is none, `master` (or `main`).
- **More than two open pull requests: stop and ask the user** whether to create a new branch and pull request or to keep
  committing on the current branch. More than two open branches make merging hard and leave no sensible target branch
  for each.

```sh
bash scripts/check-branch-pr.sh   # 0: commit; 1: open a PR first; 2: more than two open PRs, ask the user
```

### Commit and push after every answer

- **Commit and push at the end of every answer, without asking, on any branch other than `master` / `main`.** When
  a question-and-answer turn ends and the current branch is not `master` or `main`, commit the work (following the
  checks above: an open pull request, `bash scripts/check-branch-pr.sh`) and push it. This is safe: the code is always
  on a branch, never pushed to `master` / `main`, so a push carries no risk that needs a question first. Never push to
  `master` / `main` this way.
