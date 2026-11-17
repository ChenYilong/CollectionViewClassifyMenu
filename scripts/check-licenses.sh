#!/usr/bin/env bash
# Usage: scripts/check-licenses.sh
#
# Checks that every package this repository publishes ships its license (AGENTS.md, "License in every published
# package"; .agents/skills/cyl-license/): the file exists, is not a placeholder, carries the same MIT text as the
# repository's LICENSE (or the Apache-2.0 text for the AndroidTagView port), and the manifest declares it.
set -euo pipefail
cd "$(dirname "$0")/.."

failures=0
fail() {
  echo "error: $*" >&2
  failures=$((failures + 1))
}

# The repository's own code: the same MIT text as ./LICENSE.
mit_files=(
  CollectionViewClassifyMenu/Resources/License/LICENSE
  android/merged/library/src/main/resources/META-INF/classifymenu/LICENSE
  react-native/react-native-cyl-tag-list/LICENSE
  flutter/cyl_tag_list/LICENSE
  flutter/cyl_tag_list_ohos/LICENSE
  flutter/cyl_tag_list_ohos/ohos/LICENSE
  harmony/classifymenu/LICENSE
  harmony/classifymenu/src/main/resources/rawfile/LICENSE
  CrossPlatform/wechat-miniprogram/packages/cyl-tag-list-miniprogram/LICENSE
  CrossPlatform/wechat-miniprogram/packages/cyl-tag-list-miniprogram/miniprogram_dist/LICENSE
)
[ -f LICENSE ] || fail "LICENSE is missing at the repository root"
grep -q '^MIT License$' LICENSE || fail "LICENSE is not the MIT License"
for file in "${mit_files[@]}"; do
  if [ ! -f "$file" ]; then
    fail "$file is missing"
  elif ! cmp -s LICENSE "$file"; then
    fail "$file differs from ./LICENSE"
  fi
done

# Third-party notices and the Apache-2.0 ports.
for file in CollectionViewClassifyMenu/Resources/License/THIRD-PARTY-NOTICES.md \
            android/merged/library/src/main/resources/META-INF/classifymenu/NOTICE \
            android/merged/library/src/main/resources/META-INF/classifymenu/LICENSE-APACHE-2.0 \
            android/AndroidTagView/androidtagview/src/main/resources/META-INF/androidtagview/LICENSE \
            android/AndroidTagView/androidtagview/src/main/resources/META-INF/androidtagview/NOTICE; do
  [ -f "$file" ] || fail "$file is missing"
done
for file in android/merged/library/src/main/resources/META-INF/classifymenu/LICENSE-APACHE-2.0 \
            android/AndroidTagView/androidtagview/src/main/resources/META-INF/androidtagview/LICENSE; do
  [ -f "$file" ] && ! grep -q 'Apache License' "$file" && fail "$file is not the Apache License"
done

# CYLTabBarController's cyl-animated-item, vendored by commit into the mini program package: its own MIT license next to it.
for folder in cyl-animated-item cyl-animation-placeholder; do
  file="CrossPlatform/wechat-miniprogram/packages/cyl-tag-list-miniprogram/miniprogram_dist/$folder/LICENSE"
  if [ ! -f "$file" ]; then
    fail "$file is missing"
  elif ! grep -q 'CYLTabBarController' "$file" || ! grep -q 'Permission is hereby granted' "$file"; then
    fail "$file is not CYLTabBarController's MIT license"
  fi
done

# No placeholder anywhere in a published package's license.
if grep -l 'TODO: Add your license' "${mit_files[@]}" LICENSE 2>/dev/null; then
  fail "a license file is a placeholder"
fi

# The manifests declare the license and ship the file.
grep -q ":type => 'MIT', :file => 'LICENSE'" CollectionViewClassifyMenu.podspec || fail "the podspec does not declare MIT with LICENSE"
grep -q "CollectionViewClassifyMenu/Resources/License/\*" CollectionViewClassifyMenu.podspec || fail "the podspec's bundle does not include Resources/License"
grep -q '.copy("Resources/License")' Package.swift || fail "Package.swift does not copy Resources/License"
grep -q 'The MIT License' android/merged/library/build.gradle.kts || fail "the classifymenu POM does not declare the MIT License"
grep -q 'The Apache License, Version 2.0' android/AndroidTagView/androidtagview/build.gradle.kts || fail "the androidtagview POM does not declare Apache-2.0"
for manifest in react-native/react-native-cyl-tag-list/package.json \
                CrossPlatform/wechat-miniprogram/packages/cyl-tag-list-miniprogram/package.json \
                harmony/classifymenu/oh-package.json5 flutter/cyl_tag_list_ohos/ohos/oh-package.json5; do
  grep -q '"license": "MIT"' "$manifest" || fail "$manifest does not declare \"license\": \"MIT\""
done
grep -q '"LICENSE"' CrossPlatform/wechat-miniprogram/packages/cyl-tag-list-miniprogram/package.json \
  || fail "the mini program package's files do not list LICENSE"

if [ "$failures" -gt 0 ]; then
  echo "check-licenses: $failures problem(s)" >&2
  exit 1
fi
echo "OK: every published package ships its license"
