#!/bin/sh
# Builds the example and its instrumented test (entry/src/ohosTest), installs both on the running emulator and runs
# the UI tests. Usage: scripts/ui-test.sh [project dir, default: harmony/]. Needs DevEco Studio and a booted emulator.
set -eu
DEVECO=${DEVECO:-/Applications/DevEco-Studio.app/Contents}
PROJECT=${1:-$(cd "$(dirname "$0")/.." && pwd)}
HDC="$DEVECO/sdk/default/openharmony/toolchains/hdc"
export DEVECO_SDK_HOME="$DEVECO/sdk"
export PATH="$DEVECO/tools/node/bin:$DEVECO/tools/ohpm/bin:$PATH"
BUNDLE=com.cyl.classifymenu.example

cd "$PROJECT"
node "$DEVECO/tools/hvigor/bin/hvigorw.js" --no-daemon assembleHap
node "$DEVECO/tools/hvigor/bin/hvigorw.js" --no-daemon -p module=entry@ohosTest assembleHap
OUT=entry/build/default/outputs
"$HDC" install -r "$OUT/default/entry-default-unsigned.hap"
"$HDC" install -r "$OUT/ohosTest/entry-ohosTest-unsigned.hap"
RESULT=$("$HDC" shell aa test -b "$BUNDLE" -m entry_test -s unittest OpenHarmonyTestRunner -s timeout 60000 -w 180)
echo "$RESULT"
echo "$RESULT" | grep -q "OHOS_REPORT_CODE: 0" || exit 1
echo "$RESULT" | grep -Eq "Failure: 0, Error: 0" || exit 1
