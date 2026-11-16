#!/usr/bin/env bash
# Run before every commit (AGENTS.md "Branches and pull requests"): the current branch must have an open pull request,
# and more than two open pull requests need the user's decision first.
# Usage: bash scripts/check-branch-pr.sh   (exit 0: commit; 1: open a PR first; 2: more than two open PRs, ask the user)
set -eu
branch=$(git branch --show-current)
# The pull request belongs to the branch on the remote: use the upstream's name when there is one.
upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)
[ -n "$upstream" ] && branch=${upstream#*/}
case "$branch" in master|main) echo "On $branch: commit on a feature branch instead"; exit 1 ;; esac
open=$(gh pr list --state open --json number,headRefName,baseRefName --jq '.[] | "#\(.number) \(.headRefName) -> \(.baseRefName)"')
count=$(printf '%s\n' "$open" | grep -c . || true)
echo "Open pull requests ($count):"; printf '%s\n' "$open"
if ! printf '%s\n' "$open" | grep -q " $branch -> "; then
  echo "No open pull request for $branch: open one before committing (base: the open PR's branch active before this branch, else master)."
  exit 1
fi
if [ "$count" -gt 2 ]; then
  echo "More than two open pull requests: ask the user whether to keep committing here or to open another branch and PR."
  exit 2
fi
echo "OK: $branch has an open pull request; $count open in all."
