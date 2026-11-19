#!/bin/sh
# Installs the ohpm dependencies and builds the HarmonyOS project (the classifymenu HAR and the entry HAP).
# Usage: harmony/scripts/build.sh [hvigor task, default: assembleHap]. DEVECO: DevEco Studio's folder (macOS: the
# app's Contents; Windows: C:/Program Files/Huawei/DevEco Studio, the default when it exists).
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
ohpm install >/dev/null
node "$DEVECO/tools/hvigor/bin/hvigorw.js" --no-daemon --mode module -p module=classifymenu@default assembleHar
node "$DEVECO/tools/hvigor/bin/hvigorw.js" --no-daemon "${1:-assembleHap}"
