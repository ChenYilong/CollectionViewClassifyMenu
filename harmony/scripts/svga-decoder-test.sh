#!/bin/sh
# Runs svga-decoder-test.js with DevEco Studio's node and TypeScript (no device needed).
set -eu
if [ -z "${DEVECO:-}" ]; then
  if [ -d "/c/Program Files/Huawei/DevEco Studio" ]; then DEVECO="/c/Program Files/Huawei/DevEco Studio"
  else DEVECO=/Applications/DevEco-Studio.app/Contents; fi
fi
"$DEVECO/tools/node/node" "$(dirname "$0")/svga-decoder-test.js" "$DEVECO/tools/hvigor/hvigor/node_modules/typescript"
