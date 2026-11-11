#!/bin/sh
# Runs Gradle for one project in android/ from a mirror under /tmp: Gradle fails on the macOS `._*` files this
# volume creates. Usage: android/scripts/gradle.sh <android-tagview|TagViewGroup|AndroidTagView|merged> <tasks...>
#   ANDROID_MIRROR (default /tmp/xpa/android), JAVA_HOME (JDK 17) and ANDROID_HOME are used when set.
set -eu
cd "$(dirname "$0")/.."
PROJECT=$1
shift
MIRROR=${ANDROID_MIRROR:-/tmp/xpa/android}
: "${JAVA_HOME:=$HOME/develop/jdk/jdk-17.0.21+9/Contents/Home}"
: "${ANDROID_HOME:=$HOME/Library/Android/sdk}"
export JAVA_HOME ANDROID_HOME
mkdir -p "$MIRROR"
rsync -a --delete --exclude '._*' --exclude build --exclude .gradle --exclude .kotlin --exclude .cyltabbar ./ "$MIRROR/"
GRADLE=${GRADLE:-$(command -v gradle || ls -d "$HOME"/.gradle/wrapper/dists/gradle-9.3.1-all/*/gradle-9.3.1/bin/gradle | head -1)}
cd "$MIRROR/$PROJECT"
"$GRADLE" --no-daemon "$@"
