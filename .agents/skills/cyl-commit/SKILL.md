---
name: cyl-commit
description: Commit message format for CollectionViewClassifyMenu (Conventional Commits with emoji, the required author line) and the checks to run before every commit.
---

# Commits

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
