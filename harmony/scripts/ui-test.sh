#!/bin/sh
# Builds the example and its instrumented test (entry/src/ohosTest), installs both on the running emulator and runs
# the UI tests. Usage: scripts/ui-test.sh [project dir, default: harmony/]. Needs DevEco Studio and a booted emulator.
set -eu
if [ -z "${DEVECO:-}" ]; then
  if [ -d "/c/Program Files/Huawei/DevEco Studio" ]; then DEVECO="/c/Program Files/Huawei/DevEco Studio"
  else DEVECO=/Applications/DevEco-Studio.app/Contents; fi
fi
export JAVA_HOME="$DEVECO/jbr"
PROJECT=${1:-$(cd "$(dirname "$0")/.." && pwd)}
HDC_BIN="$DEVECO/sdk/default/openharmony/toolchains/hdc"
# HDC_TARGET: the device to use when several run (hdc list targets), e.g. 127.0.0.1:5563.
hdc() { if [ -n "${HDC_TARGET:-}" ]; then "$HDC_BIN" -t "$HDC_TARGET" "$@"; else "$HDC_BIN" "$@"; fi; }
HDC=hdc
export DEVECO_SDK_HOME="$DEVECO/sdk"
export PATH="$DEVECO/jbr/bin:$DEVECO/tools/node:$DEVECO/tools/node/bin:$DEVECO/tools/ohpm/bin:$PATH"
BUNDLE=com.cyl.classifymenu.example

cd "$PROJECT"
# An x86_64 emulator cannot load the arm64-only Rive and PAG libraries (install error 9568347): use the entry's
# "emulator" target and the "emulatorTest" build mode, which leave out every arm64-v8a library; Rive and PAG tags show
# their still images there (CYLAnimatedItemEngines.isSupportedOnDevice). Phones and arm64 emulators use "default".
ABIS=$($HDC shell param get const.product.cpu.abilist | tr -d '\r')
case "$ABIS" in
  *arm64-v8a*) TARGET=default; TEST_MODE="" ;;
  *) TARGET=emulator; TEST_MODE="-p buildMode=emulatorTest" ;;
esac
echo "device ABIs: $ABIS; entry target: $TARGET"
node "$DEVECO/tools/hvigor/bin/hvigorw.js" --no-daemon assembleHap
# shellcheck disable=SC2086
node "$DEVECO/tools/hvigor/bin/hvigorw.js" --no-daemon $TEST_MODE -p module=entry@ohosTest assembleHap
OUT=entry/build/default/outputs
$HDC install -r "$OUT/$TARGET/entry-$TARGET-unsigned.hap"
$HDC install -r "$OUT/ohosTest/entry-ohosTest-unsigned.hap"
RESULT=$($HDC shell aa test -b "$BUNDLE" -m entry_test -s unittest OpenHarmonyTestRunner -s timeout 60000 -w 180)
echo "$RESULT"
echo "$RESULT" | grep -q "OHOS_REPORT_CODE: 0" || exit 1
echo "$RESULT" | grep -Eq "Failure: 0, Error: 0" || exit 1
