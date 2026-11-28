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
    # The podspec depends on the CYLAnimatedItem pod (in CYLTabBarController's repository), which is not on the trunk
    # yet: lint against the commit the Podfiles pin (CYL_ANIMATED_ITEM in Example/Podfile). `--include-podspecs` treats a
    # podspec as a local pod rooted at its own folder, so that folder must be a checkout of the commit (sources and
    # LICENSE), not a lone downloaded podspec.
    sha=$(sed -n "s/.*:commit => '\([0-9a-f]\{40\}\)'.*/\1/p" Example/Podfile | head -n 1)
    if [ -z "$sha" ]; then
      echo "error: no CYL_ANIMATED_ITEM commit in Example/Podfile" >&2
      exit 1
    fi
    dir=$(mktemp -d "${TMPDIR:-/tmp}/cyl-pod-lint.XXXXXX")
    trap 'rm -rf "$dir"' EXIT HUP INT TERM
    git -C "$dir" init --quiet
    git -C "$dir" fetch --quiet --depth 1 https://github.com/ChenYilong/CYLTabBarController.git "$sha"
    git -C "$dir" checkout --quiet --force FETCH_HEAD
    # CYLAnimatedItem brings CYLBadge and CYLUtils (same checkout), and CYLUtils needs CYLDeallocBlockExecutor ~> 1.4, also
    # not on the trunk: its commit is the one Example/Podfile pins.
    dealloc=$(sed -n "s/.*CYLDeallocBlockExecutor.*:commit => '\([0-9a-f]\{40\}\)'.*/\1/p" Example/Podfile | head -n 1)
    if [ -z "$dealloc" ]; then
      echo "error: no CYLDeallocBlockExecutor commit in Example/Podfile" >&2
      exit 1
    fi
    dealloc_dir=$(mktemp -d "${TMPDIR:-/tmp}/cyl-pod-lint-dealloc.XXXXXX")
    trap 'rm -rf "$dir" "$dealloc_dir"' EXIT HUP INT TERM
    git -C "$dealloc_dir" init --quiet
    git -C "$dealloc_dir" fetch --quiet --depth 1 https://github.com/ChenYilong/CYLDeallocBlockExecutor.git "$dealloc"
    git -C "$dealloc_dir" checkout --quiet --force FETCH_HEAD
    pod lib lint "$PODSPEC" --allow-warnings \
      --include-podspecs="{$dir/CYLAnimatedItem.podspec,$dir/CYLBadge.podspec,$dir/CYLUtils.podspec,$dealloc_dir/CYLDeallocBlockExecutor.podspec}" "$@"
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
