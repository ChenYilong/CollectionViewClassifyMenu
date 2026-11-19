---
name: cyl-license
description: Make every package this project publishes (CocoaPods, SwiftPM, Gradle / Maven, npm, pub.dev, ohpm, mini program npm) ship its license file in its built-in resource container and declare the same license in its manifest.
---

# License in every published package

Applies to every package this repository publishes to an external registry, on every platform: the core and
anything else that is uploaded (AGENTS.md, "License in every published package" and "Fix issues in the core first"
list the published packages).

## Rule

- Every published package contains its license declaration: the license file ships inside the package, and the
  package manifest names the same license.
- The license file goes into the package's built-in resource container. When the package already has one, put the
  license file in it; when it has none, create one. Example for iOS: the core's resource bundle
  `CYLClassifyMenuResources.bundle` contains `LICENSE`.
- The rule applies to every platform and every registry, including but not limited to CocoaPods, Gradle, Maven and
  npm.
- Ported or copied third-party code keeps its upstream license and notice next to it, and a package that contains it
  ships those notices as well.
- A missing license file, or a placeholder such as "TODO: Add your license here", blocks publishing.

## Where the license goes

The license of this repository's own code is MIT (`LICENSE` at the repository root, decided 2026-11-17); every copy
below has the same text. Third-party code keeps its own license and notice.

| Platform / registry | Package | License files in the package | Manifest declaration |
|---|---|---|---|
| iOS, CocoaPods | `CollectionViewClassifyMenu.podspec` | `LICENSE` and `THIRD-PARTY-NOTICES.md` (UICollectionViewLeftAlignedLayout, MIT) in `CYLClassifyMenuResources.bundle`, from `CollectionViewClassifyMenu/Resources/License/`; `LICENSE` at the repository root | `s.license = { :type => 'MIT', :file => 'LICENSE' }`, `s.resource_bundles` lists `Resources/License/*` |
| iOS, Swift Package Manager | `Package.swift` | the same folder in the package's bundle | `resources: [.copy("Resources/License")]` |
| Android, Gradle / Maven | `com.cyl:classifymenu` (`android/merged/library`) | `src/main/resources/META-INF/classifymenu/LICENSE` (MIT), `NOTICE` and `LICENSE-APACHE-2.0` (the translated AndroidTagView and android-tagview), inside the AAR | POM `licenses`: MIT and Apache-2.0 |
| Android, Gradle / Maven | `co.lujun:androidtagview` (`android/AndroidTagView/androidtagview`) | `src/main/resources/META-INF/androidtagview/LICENSE` (Apache-2.0) and `NOTICE` | POM `licenses`: Apache-2.0 |
| npm (React Native) | `react-native/react-native-cyl-tag-list` | `LICENSE` at the package root (npm always packs it) | `package.json` `"license": "MIT"` |
| pub.dev (Flutter) | `flutter/cyl_tag_list`, `flutter/cyl_tag_list_ohos` | `LICENSE` at the package root (pub.dev requires it); `flutter/cyl_tag_list_ohos/ohos/LICENSE` for its HAR | the `LICENSE` file; `oh-package.json5` `"license": "MIT"` |
| ohpm (HarmonyOS) | `harmony/classifymenu` | `LICENSE` at the module root and in `src/main/resources/rawfile/` | `oh-package.json5` `"license": "MIT"` |
| npm (mini program) | `CrossPlatform/wechat-miniprogram/packages/cyl-tag-list-miniprogram` | `LICENSE` at the package root (listed in `files`) and in the component folder `miniprogram_dist/` (copied into `miniprogram_npm` when DevTools builds npm, as CYLTabBarController's mini program packages do); `scripts/verify-package.js` expects both in the tarball | `package.json` `"license": "MIT"` |

Android puts each library's files under `META-INF/<artifact>/`, so two libraries in one app never collide on
`META-INF/LICENSE`.

A new published package, or a new registry, gets a row here, a line in `scripts/check-licenses.sh`, and follows the
same rule. CYLTabBarController applies the same rule to its own packages (`docs/License-Notices.md`,
`scripts/check-license-notices.py` there).

## Check

- `bash scripts/check-licenses.sh`: every file above exists, is not a placeholder, has the same text as `./LICENSE`
  (or the Apache-2.0 text for the ports), and the manifests declare it. Run it before a release and after changing a
  package's manifest or resources.
- The license text is the same in every package of this repository's own code; third-party notices are added, never
  replaced.
