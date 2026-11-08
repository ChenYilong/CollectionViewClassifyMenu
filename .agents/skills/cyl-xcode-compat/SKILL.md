---
name: cyl-xcode-compat
description: Xcode project format and deployment compatibility for CollectionViewClassifyMenu.
---

# Xcode compatibility

When modifying the project or deployment target, keep the app and podspec at
iOS 15.0 or later. Preserve `objectVersion = 46` and
`compatibilityVersion = "Xcode 3.2"` for Xcode compatibility. Keep schemes in
`xcshareddata/xcschemes` and do not commit personal `xcuserdata`.

Build the shared scheme for a generic iOS Simulator with signing disabled. Do
not copy target identifiers, signing settings or optional dependencies from
CYLTabBarController: this repository has its own app target and source tree.
