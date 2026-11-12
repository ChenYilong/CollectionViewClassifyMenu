#!/bin/sh
# Usage: scripts/pod-lint.sh {lib|version|check-tag <tag>|bump <version>|push} [pod options]
set -eu
cd "$(dirname "$0")/.."
export XCODE_XCCONFIG_FILE="$PWD/scripts/pod-lint.xcconfig"
PODSPEC=CollectionViewClassifyMenu.podspec

pod_version() {
  sed -n 's/^[[:space:]]*s\.version[[:space:]]*=[[:space:]]*["'\'']\([^"'\'']*\)["'\''].*/\1/p' "$PODSPEC" | head -n 1
}

version=$(pod_version)
if [ -z "$version" ]; then
  echo "error: no version in $PODSPEC" >&2
  exit 1
fi

command=${1:-lib}
if [ "$#" -gt 0 ]; then shift; fi
case "$command" in
  version)
    echo "$version"
    ;;
  check-tag)
    tag=${1:?usage: scripts/pod-lint.sh check-tag <tag>}
    if [ "$tag" != "$version" ]; then
      echo "error: tag $tag does not match podspec version $version" >&2
      exit 1
    fi
    echo "Tag $tag matches $PODSPEC"
    ;;
  bump)
    next=${1:?usage: scripts/pod-lint.sh bump <major.minor.patch>}
    if ! printf '%s\n' "$next" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
      echo "error: expected a version such as 0.1.0, got $next" >&2
      exit 1
    fi
    tmp=$(mktemp "${PODSPEC}.XXXXXX")
    trap 'rm -f "$tmp"' EXIT HUP INT TERM
    sed "s/^\\([[:space:]]*s\\.version[[:space:]]*=[[:space:]]*['\"]\\)[^'\"]*\\(['\"]\\)/\\1$next\\2/" "$PODSPEC" > "$tmp"
    if [ "$(grep -c "s.version[[:space:]]*=[[:space:]]*['\"]${next}['\"]" "$tmp")" -ne 1 ]; then
      echo "error: could not update the unique podspec version" >&2
      exit 1
    fi
    mv "$tmp" "$PODSPEC"
    echo "Updated $PODSPEC: $version → $next. Commit and tag the release before pushing."
    ;;
  lib)
    pod lib lint "$PODSPEC" --allow-warnings "$@"
    ;;
  push)
    if ! git ls-remote --exit-code --tags origin "refs/tags/$version" >/dev/null; then
      echo "error: tag $version is not available on origin" >&2
      exit 1
    fi
    pod trunk push "$PODSPEC" --allow-warnings "$@"
    ;;
  *)
    echo "usage: scripts/pod-lint.sh {lib|version|check-tag <tag>|bump <version>|push} [pod options]" >&2
    exit 2
    ;;
esac
