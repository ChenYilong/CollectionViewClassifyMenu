#!/bin/sh
# Usage: scripts/publish-screenshots.sh     (in GitHub Actions, after scripts/example-screenshots.sh)
#
# [EN] Commits build/screenshots/*.png to the `ci-screenshots` branch under <branch>/<commit>/ and writes them into the
#      job summary as images. Artifacts are served from changing storage hosts; files on a branch can always be read
#      through the GitHub API and git, so every build run's screenshots stay reachable (AGENTS.md).
# [CN] 把 build/screenshots/*.png 提交到 `ci-screenshots` 分支的 <分支>/<提交>/ 下，并以图片写入 job summary。Artifact 的存储主机会变化；
#      分支上的文件始终可以通过 GitHub API 与 git 读取，因此每次构建的截图都可获取（AGENTS.md）。
set -eu
cd "$(dirname "$0")/.."
: "${GITHUB_REPOSITORY:?run in GitHub Actions}" "${GITHUB_SHA:?}"
# [EN] The branch of a pull request, else the pushed ref. [CN] PR 的分支，否则为推送的 ref。
REF_NAME="${SCREENSHOT_REF:-${GITHUB_REF_NAME:?}}"
BRANCH=ci-screenshots
DIR="$(printf '%s' "$REF_NAME" | tr '/' '-')/$(printf '%s' "$GITHUB_SHA" | cut -c1-7)"
SOURCE="$PWD/build/screenshots"
ls "$SOURCE"/*.png > /dev/null

WORK=$(mktemp -d "${TMPDIR:-/tmp}/cyl-screenshots.XXXXXX")
trap 'rm -rf "$WORK"' EXIT
git config --global user.name "github-actions[bot]"
git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"
REMOTE="https://x-access-token:${GITHUB_TOKEN:?}@github.com/${GITHUB_REPOSITORY}.git"
if git ls-remote --exit-code --heads "$REMOTE" "$BRANCH" > /dev/null 2>&1; then
  git clone --quiet --depth 1 --branch "$BRANCH" "$REMOTE" "$WORK/repo"
else
  git init --quiet "$WORK/repo"
  git -C "$WORK/repo" checkout --quiet --orphan "$BRANCH"
  printf '# CI screenshots\n\nExample screenshots of each CI build run, by branch and commit.\n' > "$WORK/repo/README.md"
fi
mkdir -p "$WORK/repo/$DIR"
cp "$SOURCE"/*.png "$WORK/repo/$DIR/"
git -C "$WORK/repo" add -A
git -C "$WORK/repo" commit --quiet -m "Example screenshots for $REF_NAME@$(printf '%s' "$GITHUB_SHA" | cut -c1-7)" || true
for ATTEMPT in 1 2 3; do
  if git -C "$WORK/repo" push --quiet "$REMOTE" "HEAD:$BRANCH"; then break; fi
  echo "Push failed (attempt $ATTEMPT), rebasing"
  git -C "$WORK/repo" pull --quiet --rebase "$REMOTE" "$BRANCH" || true
done

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    echo "### Example screenshots"
    echo
    echo "Branch \`$BRANCH\`, folder \`$DIR\`."
    echo
    for FILE in "$SOURCE"/*.png; do
      NAME=$(basename "$FILE")
      echo "<img src=\"https://raw.githubusercontent.com/$GITHUB_REPOSITORY/$BRANCH/$DIR/$NAME\" width=\"240\" alt=\"$NAME\">"
    done
  } >> "$GITHUB_STEP_SUMMARY"
fi
echo "Published $(find "$SOURCE" -name '*.png' | wc -l | tr -d ' ') screenshots to $BRANCH/$DIR"
