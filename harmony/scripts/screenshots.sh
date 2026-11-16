#!/bin/sh
# Screenshots of every demo of the HarmonyOS example on the running emulator (docs/harmony-verification.md rows B,
# E3 and F2): builds and installs the example, opens each screen with the launch options of CYLLaunchOptions
# (cylScreen, cylScreenParam, cylLanguage, cylColorMode), and saves docs/assets/harmonyos-<name>.jpeg.
# Usage: harmony/scripts/screenshots.sh [name ...] (default: all). DEVECO: DevEco Studio's folder.
set -eu
if [ -z "${DEVECO:-}" ]; then
  if [ -d "/c/Program Files/Huawei/DevEco Studio" ]; then DEVECO="/c/Program Files/Huawei/DevEco Studio"
  else DEVECO=/Applications/DevEco-Studio.app/Contents; fi
fi
PROJECT=$(cd "$(dirname "$0")/.." && pwd)
OUT="$PROJECT/../docs/assets"
HDC_BIN="$DEVECO/sdk/default/openharmony/toolchains/hdc"
# HDC_TARGET: the device to use when several run (hdc list targets), e.g. 127.0.0.1:5563.
hdc() { if [ -n "${HDC_TARGET:-}" ]; then "$HDC_BIN" -t "$HDC_TARGET" "$@"; else "$HDC_BIN" "$@"; fi; }
HDC=hdc
BUNDLE=com.cyl.classifymenu.example
WAIT=${WAIT:-3}

if [ -z "${SKIP_INSTALL:-}" ]; then
  sh "$PROJECT/scripts/build.sh" >/dev/null
  $HDC install -r "$PROJECT/entry/build/default/outputs/default/entry-default-unsigned.hap"
fi
mkdir -p "$OUT"

# name | route ('' = the root tab bar) | route parameter (JSON, '' for none) | language | color mode
SCREENS='
root||||
product|CYLProductViewController|||
reviews-memory|CYLReviewListViewController|{"selectedFilterIndex":0,"mode":"memory"}||
reviews-network|CYLReviewListViewController|{"selectedFilterIndex":0,"mode":"network"}||
reviews-database|CYLReviewListViewController|{"selectedFilterIndex":0,"mode":"database"}||
search-home|CYLSearchHomeViewController|||
search-category|CYLSearchCategoryViewController|||
search-category-page|CYLSearchCategoryPageViewController|||
search-discover|CYLSearchDiscoverViewController|||
query-scenarios|CYLQueryScenariosViewController|||
menu-linkage|CYLMenuLinkageViewController|||
styles|CYLTagStyleDemoViewController|||
animations|CYLTagAnimationDemoViewController|||
configuration|CYLTagConfigurationDemoViewController|||
tag-cloud|CYLTagCloudDemoViewController|||
tag-cloud-sample|CYLTagCloudSampleViewController|||
tag-cloud-sub|CYLTagCloudSubViewController|||
tag-cloud-list|CYLTagCloudListViewController|||
tag-cloud-recycler|CYLTagCloudRecyclerViewController|||
hot-search|CYLHotSearchViewController|||
image-tag-sample|CYLImageTagSampleViewController|||
image-tag-edit|CYLImageTagEditViewController|||
image-tag-list|CYLImageTagListViewController|||
tag-container|CYLTagContainerSampleViewController|||
en-root|||en|
en-animations|CYLTagAnimationDemoViewController||en|
zh-hant-styles|CYLTagStyleDemoViewController||zh-Hant|
dark-root||||dark
dark-animations|CYLTagAnimationDemoViewController|||dark
'


echo "$SCREENS" | while IFS='|' read -r name route param language mode; do
  [ -z "$name" ] && continue
  if [ "$#" -gt 0 ]; then
    found=0
    for w in "$@"; do [ "$w" = "$name" ] && found=1; done
    [ "$found" -eq 0 ] && continue
  fi
  args=""
  [ -n "$route" ] && args="$args --ps cylScreen $route"
  [ -n "$param" ] && args="$args --ps cylScreenParam '$param'"
  [ -n "$language" ] && args="$args --ps cylLanguage $language"
  [ -n "$mode" ] && args="$args --ps cylColorMode $mode"
  $HDC shell "aa force-stop $BUNDLE" >/dev/null
  $HDC shell "aa start -b $BUNDLE -a EntryAbility$args" >/dev/null
  sleep "$WAIT"
  $HDC shell "snapshot_display -f /data/local/tmp/cyl-shot.jpeg" >/dev/null
  $HDC file recv /data/local/tmp/cyl-shot.jpeg "$OUT/harmonyos-$name.jpeg" >/dev/null
  echo "harmonyos-$name.jpeg"
done
