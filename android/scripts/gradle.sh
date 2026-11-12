#!/bin/sh
# Runs Gradle for one project in android/ from a mirror under /tmp: Gradle fails on the macOS `._*` files this
# volume creates. Usage: android/scripts/gradle.sh <android-tagview|TagViewGroup|AndroidTagView|merged> <tasks...>
#   ANDROID_MIRROR (default /tmp/xpa/android), ANDROID_JAVA_HOME (a JDK 17; default ~/develop/jdk/jdk-17.0.21+9,
#   else JAVA_HOME) and ANDROID_HOME are used when set.
set -eu
cd "$(dirname "$0")/.."
PROJECT=$1
shift
MIRROR=${ANDROID_MIRROR:-/tmp/xpa/android}
JDK17="$HOME/develop/jdk/jdk-17.0.21+9/Contents/Home"
if [ -n "${ANDROID_JAVA_HOME:-}" ]; then
  JAVA_HOME=$ANDROID_JAVA_HOME
elif [ -d "$JDK17" ]; then
  JAVA_HOME=$JDK17
fi
: "${ANDROID_HOME:=$HOME/Library/Android/sdk}"
export JAVA_HOME ANDROID_HOME
mkdir -p "$MIRROR"
rsync -a --delete --exclude '._*' --exclude build --exclude .gradle --exclude .kotlin --exclude .cyltabbar ./ "$MIRROR/"
# The shared example data (Example-Shared/Database/cyl_places.sqlite), next to the mirror as it is next to android/.
mkdir -p "$MIRROR/../Example-Shared"
rsync -a --delete --exclude '._*' ../Example-Shared/Database "$MIRROR/../Example-Shared/"
# The tag editor example's bundle (its strings, tags.json, fold-styles.*), read by the Android example as assets.
mkdir -p "$MIRROR/../Example-Swift/CYLTagEditorExample"
rsync -a --delete --exclude '._*' ../Example-Swift/CYLTagEditorExample/CYLTagEditorExample.bundle "$MIRROR/../Example-Swift/CYLTagEditorExample/"
GRADLE=${GRADLE:-$(command -v gradle || ls -d "$HOME"/.gradle/wrapper/dists/gradle-9.3.1-all/*/gradle-9.3.1/bin/gradle | head -1)}
cd "$MIRROR/$PROJECT"
"$GRADLE" --no-daemon "$@"
