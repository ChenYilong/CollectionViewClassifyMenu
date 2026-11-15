#!/bin/sh
# Runs the local unit tests (entry/src/test) on this computer, without a device, and prints the result.
# Usage: harmony/scripts/unit-test.sh. DEVECO: DevEco Studio's folder (the Windows default when it exists).
set -eu
if [ -z "${DEVECO:-}" ]; then
  if [ -d "/c/Program Files/Huawei/DevEco Studio" ]; then DEVECO="/c/Program Files/Huawei/DevEco Studio"
  else DEVECO=/Applications/DevEco-Studio.app/Contents; fi
fi
PROJECT=$(cd "$(dirname "$0")/.." && pwd)
export DEVECO_SDK_HOME="$DEVECO/sdk"
export JAVA_HOME="$DEVECO/jbr"
export PATH="$DEVECO/jbr/bin:$DEVECO/tools/node:$DEVECO/tools/node/bin:$DEVECO/tools/ohpm/bin:$PATH"
cd "$PROJECT"
RESULT=entry/.test/default/intermediates/test/coverage_data/test_result.txt
rm -f "$RESULT"
node "$DEVECO/tools/hvigor/bin/hvigorw.js" --no-daemon -p module=entry@default test >/dev/null
grep -E "^(class|test|result)=|^Tests run" "$RESULT" | grep -v "result=Success" || true
grep -q "Failure: 0, Error: 0" "$RESULT"
