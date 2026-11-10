---
name: cyl-dependency
description: How CollectionViewClassifyMenu depends on CYLTabBarController (CocoaPods, newest commit over every branch) and how to update the pin.
---

# CYLTabBarController dependency

Rules in `AGENTS.md` ("CYLTabBarController reference and dependency").

## The version is a commit

- CocoaPods only, pinned to a commit:

  ```ruby
  CYL_TAB_BAR = { :git => 'https://github.com/ChenYilong/CYLTabBarController.git',
                  :commit => '<sha>' }
  pod 'CYLTabBarController', CYL_TAB_BAR
  pod 'CYLTabBarController/Lottie', CYL_TAB_BAR   # subspecs use the same hash
  ```

  Never a version number (`'~> 1.99'`), `:branch` or `:tag`: the CocoaPods release lacks the APIs the examples
  use (animation engine, configuration parser), and a branch would move under a build.
- The commit is the newest one over **every** branch, by committer date. It may be on a branch other than
  `master` or `main` (so far `feat/cross-platform-components`).
- If the project being worked on is CYLTabBarController itself, use the local podspec instead:
  `pod 'CYLTabBarController', :path => '../'` (the relative path of the folder holding
  `CYLTabBarController.podspec`). Every other project uses the commit.

## Before every build

```sh
scripts/cyl-tabbar-latest-commit.sh          # "<sha> <date> <branch>" of the newest commit
scripts/cyl-tabbar-latest-commit.sh --check  # exit 1 when a Podfile pins another commit
```

The script fetches only the tip of every branch (`git fetch --depth=1 '+refs/heads/*:…'`) and sorts them with
`git for-each-ref --sort=-committerdate`. CI runs `--check` in the `shellcheck` job as a warning.

## Updating the pin

1. Run the script; note the new `<sha>`.
2. See what changed since the old pin (`git log <old>..<new>` in a clone) and whether anything copied from
   CYLTabBarController changed: its `.gitignore`, `scripts/fetch-animation-resources.py`,
   `Example-Shared/PAGResources/pag-resources.json`, the animation and image resources of the examples, its rules
   referred to in `AGENTS.md`.
3. Replace the hash in every Podfile (`Example/Podfile`, `Example-Swift/Podfile`) and update the copied files in
   the same commit; run `--check`.
4. Build and test the examples (`scripts/unit-tests.sh example`, `scripts/unit-tests.sh swift`) and look at the
   screenshots: a new CYLTabBarController commit can change the tab bars (for example, it cuts long titles next to
   the plus button).
