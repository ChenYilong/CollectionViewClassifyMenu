#!/bin/sh
# Usage: scripts/unit-tests.sh <suite> [simulator name]     suite: menu | tag | example
#
# [EN] Installs the pods of one project and runs its unit tests on an iOS simulator (macOS with Xcode and CocoaPods):
#      menu    → CollectionViewClassifyMenu.xcworkspace, scheme CollectionViewClassifyMenuTests
#      tag     → TagCollectionView/TagCollectionView.xcworkspace, scheme TagCollectionView
#      example → Example/CYLMenuExample.xcworkspace, scheme CYLMenuExample
#      Prints every test case and the failures; the full log is build/unit-tests-<suite>.log. Exits with xcodebuild's status.
# [CN] 安装一个工程的 pods，并在 iOS 模拟器上运行其单元测试（需要装有 Xcode 与 CocoaPods 的 macOS）。输出每个测试用例与失败原因；
#      完整日志为 build/unit-tests-<suite>.log。退出码为 xcodebuild 的结果。
set -eu
SUITE="${1:?usage: $0 <menu|tag|example> [simulator name]}"
cd "$(dirname "$0")/.."
ROOT="$PWD"
case "$SUITE" in
  menu) DIR=.; WORKSPACE=CollectionViewClassifyMenu.xcworkspace; SCHEME=CollectionViewClassifyMenuTests ;;
  tag) DIR=TagCollectionView; WORKSPACE=TagCollectionView.xcworkspace; SCHEME=TagCollectionView ;;
  example) DIR=Example; WORKSPACE=CYLMenuExample.xcworkspace; SCHEME=CYLMenuExample ;;
  *) echo "error: unknown suite $SUITE" >&2; exit 2 ;;
esac
mkdir -p build
LOG="$ROOT/build/unit-tests-$SUITE.log"
DEVICE_ID=$(scripts/simulator-id.sh "${2:-}")
echo "Simulator: $DEVICE_ID"
xcodebuild -version

(cd "$DIR" && pod install)
DERIVED_DATA=$(mktemp -d "${TMPDIR:-/tmp}/cyl-unit-tests.XXXXXX")
trap 'rm -rf "$DERIVED_DATA"' EXIT

set +e
(cd "$DIR" && xcodebuild test \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -destination "id=$DEVICE_ID" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO) > "$LOG" 2>&1
STATUS=$?
set -e
# [EN] The result of every test case, then the failures with their reasons. [CN] 每个测试用例的结果，然后是失败原因。
grep -E "^Test Case .*(passed|failed)|error: -\[|Executed [0-9]+ tests|\*\* TEST" "$LOG" || true
if [ "$STATUS" -ne 0 ]; then
  echo "xcodebuild test failed ($STATUS). Errors and last lines:"
  grep -nE "(error|fatal error):" "$LOG" | sort -u | head -n 60 || true
  tail -n 40 "$LOG"
fi
PASSED=$(grep -cE "^Test Case .*passed" "$LOG" || true)
FAILED=$(grep -cE "^Test Case .*failed" "$LOG" || true)
echo "| $SUITE | \`$SCHEME\` | $([ "$STATUS" -eq 0 ] && echo ✅ || echo ❌) | $PASSED | $FAILED |" >> "$ROOT/build/summary.md"
exit "$STATUS"
