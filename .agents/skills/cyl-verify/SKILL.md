---
name: cyl-verify
description: Build and verify the CollectionViewClassifyMenu app and CocoaPods configuration.
---

# Verify changes

Run the smallest checks relevant to the change:

```sh
xcodebuild -project CollectionViewClassifyMenu.xcodeproj \
  -scheme CollectionViewClassifyMenu -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
pod lib lint CollectionViewClassifyMenu.podspec --allow-warnings
```

Report existing warnings and unavailable checks. For UI or layout changes,
also exercise reuse, section changes and narrow screen sizes in a simulator.
