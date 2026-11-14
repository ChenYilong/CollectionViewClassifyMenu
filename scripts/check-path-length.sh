#!/usr/bin/env bash
# Fails when a tracked path is longer than MAX characters (default 160).
# Windows limits a full path to 260 characters; this repository is often cloned into deep folders such as
# "C:\Users\<name>\OneDrive - <org>\Documents\GitHub\CollectionViewClassifyMenu\" (about 90 characters), so a path
# longer than about 170 characters inside the repository makes `git checkout`, `git worktree add` and `git stash`
# fail with "Filename too long". 160 keeps a margin.
set -euo pipefail
MAX="${1:-160}"
cd "$(git rev-parse --show-toplevel)"
long=$(git ls-files -z | tr '\0' '\n' | awk -v max="$MAX" '{ n = split($0, c, ""); if (n > max) printf "%d  %s\n", n, $0 }' | sort -rn)
if [ -n "$long" ]; then
  echo "Paths longer than $MAX characters (shorten the file or folder names):"
  echo "$long"
  exit 1
fi
echo "OK: every tracked path has at most $MAX characters."
