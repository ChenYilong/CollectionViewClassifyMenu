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

## Before every commit

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
