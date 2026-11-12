#!/bin/sh
# Usage: scripts/library-warnings.sh
#
# [EN] Builds and analyzes the Example app, which compiles the pod's sources, and fails when the library's own sources
#      (CollectionViewClassifyMenu/Class, TagCollectionView/TagCollectionView) produce a build or analyzer warning.
#      Logs: build/library-build.log, build/library-analyze.log. A table of warnings goes to build/warnings.md.
# [CN] 编译并静态分析 Example（它会编译 pod 源码）；本库源码（CollectionViewClassifyMenu/Class、TagCollectionView/TagCollectionView）
#      出现构建或静态分析警告时失败。日志在 build/ 下，警告列表写入 build/warnings.md。
set -eu
cd "$(dirname "$0")/.."
ROOT="$PWD"
mkdir -p build
(cd Example && pod install)
DERIVED_DATA=$(mktemp -d "${TMPDIR:-/tmp}/cyl-library.XXXXXX")
trap 'rm -rf "$DERIVED_DATA"' EXIT
for ACTION in build analyze; do
  set +e
  (cd Example && xcodebuild "$ACTION" \
    -workspace CYLMenuExample.xcworkspace \
    -scheme CYLMenuExample \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$DERIVED_DATA" \
    CODE_SIGNING_ALLOWED=NO \
    COMPILER_INDEX_STORE_ENABLE=NO) > "build/library-$ACTION.log" 2>&1
  STATUS=$?
  set -e
  if [ "$STATUS" -ne 0 ]; then
    echo "xcodebuild $ACTION failed ($STATUS)"
    grep -nE "(error|fatal error):" "build/library-$ACTION.log" | sort -u | head -n 60 || true
    tail -n 40 "build/library-$ACTION.log"
    exit "$STATUS"
  fi
done
WARNINGS=$(grep -hE '/(CollectionViewClassifyMenu/Class|TagCollectionView/TagCollectionView)/[^:]+\.[mh]:[0-9]+:[0-9]+: warning: ' \
  build/library-build.log build/library-analyze.log | sed "s|$ROOT/||" | sort -u || true)
COUNT=$(printf '%s' "$WARNINGS" | grep -c . || true)
{
  echo "### Library warnings: $COUNT"
  echo
  echo '```'
  printf '%s\n' "${WARNINGS:-(none)}"
  echo '```'
} > build/warnings.md
cat build/warnings.md
[ "$COUNT" -eq 0 ]
