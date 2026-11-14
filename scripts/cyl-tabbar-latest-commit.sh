#!/bin/sh
# Usage: scripts/cyl-tabbar-latest-commit.sh [--check]
#
# [EN] Prints the newest commit of CYLTabBarController over every branch (not only master or main), by committer
#      date: "<sha> <ISO date> <branch>". This project always depends on that commit through CocoaPods
#      (`:git` + `:commit`, the CYL_TAB_BAR pin of each Podfile); run this before every build and update the pins
#      when it changes (AGENTS.md, "CYLTabBarController dependency"). --check exits 1 when a Podfile pins another
#      commit.
# [CN] 输出 CYLTabBarController 所有分支（不只 master 或 main）中按提交时间最新的一次提交："<sha> <ISO 时间> <分支>"。本项目总是通过
#      CocoaPods 以该提交作为依赖（`:git` + `:commit`，各 Podfile 中的 CYL_TAB_BAR）；每次构建前运行，提交变化时更新依赖。
#      --check：Podfile 依赖的不是该提交时退出码为 1。
set -eu
REPO="${CYL_TAB_BAR_REPO:-https://github.com/ChenYilong/CYLTabBarController.git}"
cd "$(dirname "$0")/.."
ROOT="$PWD"
WORK=$(mktemp -d "${TMPDIR:-/tmp}/cyl-tabbar.XXXXXX")
trap 'rm -rf "$WORK"' EXIT

git init -q "$WORK"
# [EN] The tip of every branch, without history. [CN] 每个分支的最新提交，不含历史。
git -C "$WORK" fetch -q --depth=1 "$REPO" '+refs/heads/*:refs/remotes/origin/*'
LATEST=$(git -C "$WORK" for-each-ref --sort=-committerdate --count=1 \
  --format='%(objectname) %(committerdate:iso-strict) %(refname:lstrip=3)' refs/remotes/origin)
echo "$LATEST"

if [ "${1:-}" = "--check" ]; then
  SHA=${LATEST%% *}
  STATUS=0
  for PODFILE in "$ROOT"/Podfile "$ROOT"/Example/Podfile "$ROOT"/Example-Swift/Podfile; do
    [ -f "$PODFILE" ] || continue
    if grep -q "CYLTabBarController" "$PODFILE" && ! grep -q ":commit => '$SHA'" "$PODFILE"; then
      echo "warning: ${PODFILE#"$ROOT"/} does not pin CYLTabBarController at $SHA"
      STATUS=1
    fi
  done
  exit "$STATUS"
fi
