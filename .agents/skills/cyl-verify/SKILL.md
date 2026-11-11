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

`unit-tests.sh example|swift` also writes the screenshots the tests record (`CYLScreenshotCapturing`) to
`build/test-screenshots/<suite>/`; look at them and copy the ones the README shows to `assets/test-*.png`.

Apps built with the iOS 27 SDK (Xcode 27) must adopt the scene lifecycle, otherwise UIKit stops them at launch
(`_UIApplicationEvaluateRuntimeIssueForNoSceneLifecycleAdoption`, "The test runner crashed before establishing
connection"). Both examples and both root demo apps (the hosts of `menu` and `tag`) have a scene delegate; test windows
join the app's scene (`CYLWindowHosting`). `simulator-id.sh` without a name may pick a new device type (such as
"iPhone Duo") whose tab bar is not at the bottom; pass "iPhone 17 Pro" to compare with earlier runs.

## Environments

| Where | System | Xcode | How |
| --- | --- | --- | --- |
| GitHub CI/CD (default) | macOS 26 runner (`macos-26`, Apple Silicon) | the image's default Xcode 26.x | `.github/workflows/ios.yml`: `runs-on: ${{ vars.MACOS_RUNNER \|\| 'macos-26' }}` |
| GitHub CI/CD, other runner | the repository variable `MACOS_RUNNER` (for example `xcode-27`, Xcode 27 preview) | that image's Xcode | Settings → Secrets and variables → Actions → Variables |
| Local run | macOS 27 (default assumption) | Xcode 27 | the scripts above, run directly on the Mac, with its Simulator |

- **Always check CYLTabBarController's workflow first** before changing a runner, an Xcode version, a simulator
  name or a setting that depends on them:
  <https://github.com/ChenYilong/CYLTabBarController/blob/master/.github/workflows/ios.yml>, and the same file at
  its newest commit over every branch (`cyl-dependency`):

  ```sh
  D=$(mktemp -d) && git clone -q --filter=blob:none https://github.com/ChenYilong/CYLTabBarController.git "$D"
  git -C "$D" show origin/master:.github/workflows/ios.yml | grep -nE 'runs-on|macos|xcode'
  git -C "$D" show "$(scripts/cyl-tabbar-latest-commit.sh | cut -d' ' -f1)":.github/workflows/ios.yml | grep -nE 'runs-on|macos|xcode'
  ```

  Keep this project's `ios.yml` on the same runner (today both use `macos-26`).
- **A local run** does not use GitHub CI/CD: it runs on the developer's Mac, starting Xcode and the iOS Simulator
  there. The runner rule does not apply; assume macOS 27 and Xcode 27, confirm with `sw_vers` and
  `xcodebuild -version`, and let `scripts/simulator-id.sh` pick a simulator this Xcode has (pass a name to choose
  one). Report the versions you actually used.
- A Linux container (such as a cloud agent session) has neither: it can only push and read the CI results and
  screenshots.

Report existing warnings and unavailable checks. For UI or layout changes,
also exercise reuse, section changes and narrow screen sizes in a simulator,
and attach the screenshots.

Every CI run that builds code must provide Example screenshots (the
`example-screenshots` artifact of the `Example screenshots` job in `ios.yml`,
also committed to the `ci-screenshots` branch under `<branch>/<commit>/`).
Download them, look at each screen and show them to the user. If they are
missing, fix the CI so it produces them; if that is impossible, explain why.
