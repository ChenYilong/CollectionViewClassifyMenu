---
name: cyl-verify
description: Build and verify the CollectionViewClassifyMenu app, the Example and the CocoaPods configuration.
---

# Verify changes

CI (`.github/workflows/ios.yml`, modelled on CYLTabBarController) runs the same
scripts on a macOS runner. Locally, on a Mac with Xcode and CocoaPods, run the
smallest checks relevant to the change:

```sh
scripts/unit-tests.sh menu       # CollectionViewClassifyMenuTests
scripts/unit-tests.sh tag        # TagCollectionView tests
scripts/unit-tests.sh example    # Example (CYLTagListView API and README scenarios)
scripts/unit-tests.sh swift      # Example-Swift (pure Swift tag editor: new tags)
scripts/library-warnings.sh      # build + analyze; fails on warnings in the library sources
scripts/pod-lint.sh lib          # pod lib lint
scripts/cyl-tabbar-latest-commit.sh --check   # the CYLTabBarController pin is its newest commit (before building)
scripts/example-screenshots.sh   # simulator screenshots in build/screenshots/ (swift-*.png: Example-Swift)
shellcheck scripts/*.sh
```

Report existing warnings and unavailable checks. For UI or layout changes,
also exercise reuse, section changes and narrow screen sizes in a simulator,
and attach the screenshots.

Every CI run that builds code must provide Example screenshots (the
`example-screenshots` artifact of the `Example screenshots` job in `ios.yml`,
also committed to the `ci-screenshots` branch under `<branch>/<commit>/`).
Download them, look at each screen and show them to the user. If they are
missing, fix the CI so it produces them; if that is impossible, explain why.
