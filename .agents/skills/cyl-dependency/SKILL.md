---
name: cyl-dependency
description: How CollectionViewClassifyMenu depends on CYLTabBarController (CocoaPods, newest commit over every branch), how to update the pin, and how examples integrate it by default (PlusButton with a plusChildViewController, created from a local configuration file).
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

## Integrating CYLTabBarController in an example (the default)

Unless a request says otherwise, every CYLTabBarController in an example (the root tab bar, and a tab bar nested in a
screen) is integrated the same way:

1. **With a PlusButton that has a `plusChildViewController`**: the plus button selects a page of its own (it is not
   only an action). In a configuration this is the `CYLTabBarControllerPlusButton` dictionary with
   `CYLTabBarItemPageIdentifier` (the page is found like a tab's page: the configuration's resolver, its registry, or
   `CYLTabBarPageRegistry.shared`). The plus button sits in the middle, so give an even number of tabs. A plus
   button that only runs code (`CYLTabBarControllerPlusButtonAction`) or no plus button at all needs a request.
2. **Created from a local configuration file** in the example's resource bundle (any format CYLTabBarController's
   parser reads: JSON, plist, YAML, TOML, XML…), not from attributes built in code:

   ```swift
   // Pages first: every page ID of the file must resolve.
   CYLTabBarPageRegistry.shared.register(factory: { _ in CYLProductViewController() }, forPageIdentifier: "scenario1")
   CYLTabBarPageRegistry.shared.register(factory: { _ in CYLQueryScenariosViewController() }, forPageIdentifier: "query")
   let path = CYLExampleLocalization.resourceBundle?.path(forResource: "tabbar", ofType: "json")
   let tabBarController = try CYLTabBarController(configurationFile: path ?? "tabbar.json")
   ```

   ```json
   {
     "CYLTabBarControllerContext": "CYLMenuExampleRoot",
     "CYLTabBarControllerTabBarItemsAttributes": [
       { "CYLTabBarItemTitle": "场景一", "CYLTabBarItemImage": "system:cart", "CYLTabBarItemPageIdentifier": "scenario1" },
       { "CYLTabBarItemTitle": "场景二", "CYLTabBarItemImage": "system:magnifyingglass", "CYLTabBarItemPageIdentifier": "scenario2" }
     ],
     "CYLTabBarControllerPlusButton": {
       "CYLTabBarItemTitle": "查询", "CYLTabBarItemImage": "system:plus.circle.fill", "CYLTabBarItemPageIdentifier": "query"
     }
   }
   ```

   Check the factory's Swift signature (`CYLTabBarPageFactory`) and the key names in `CYLTabBarController.h` and
   `CYLTabBarPageRegistry.h` at the pinned commit before writing the code; the keys above are the string values of
   the `CYLTabBar…` constants.
3. **One `CYLTabBarControllerContext` per tab bar**, so a nested tab bar's plus button never replaces the root
   one's.
4. Titles are localized: one configuration file per language in the example's `<language>.lproj` (as
   `fold-styles.*` in `Example-Swift`), or keys looked up through the example's lookup before the file is read. The
   accessibility labels of tabs and the plus button go in the same file (`CYLTabBarItemAccessibilityLabel`,
   `CYLTabBarItemAccessibilityHint`).
5. The other tab bar rules still apply (AGENTS.md, "Tab bars"): at the bottom, `hidesBottomBarWhenPushed` on
   pushes, `navigationItem.title` instead of `title`.
6. **Raised plus button**: whenever an example integrates a PlusButton to demonstrate it, always prefer the raised
   ("bulging") plus button effect: the top of the plus button extends beyond the top edge of the tab bar. In the
   configuration's `CYLTabBarControllerPlusButton` dictionary, set `CYLPlusButtonCenterYOffset` to a negative value
   (or `CYLPlusButtonCenterYMultiplier` below 0.5) so the button's top is above the tab bar; in code, return it from
   `+constantOfPlusButtonCenterYOffsetForTabBarHeight:` / `+multiplierOfTabBarHeight:` (`CYLPlusButtonSubclassing`).
   Check that the raised part still receives taps and is not clipped, and show it in the example's screenshots. A
   flat plus button (its top inside the tab bar) needs a request.

### Status of the examples

| Tab bar | Plus button with a page | From a configuration file |
| --- | --- | --- |
| `Example/CYLMenuExample` root (`CYLExampleAppDelegate`) | yes (`CYLExamplePlusButton` → `CYLQueryScenariosViewController`) | no: built in code |
| `Example/CYLMenuExample` scenario 2 categories (`CYLSearchCategoryViewController`) | no | no: built in code |
| `Example-Swift/CYLTagEditorExample` root (`CYLTagEditorAppDelegate`) | no | no: built in code |

These predate the rule; migrate a tab bar when it is next changed (or when asked), keeping its screenshots and tests.

## Example animation playback controls

Every example screen that shows animations, on every platform, offers Play all (restart from progress 0), a speed
slider and a loop switch that combine and change playback in real time. When the animation engine (the core's
animated icons or CYLTabBarController's `CYLTabBarItemAnimationFactory`) lacks a speed or loop API, add it there,
not in the example. Rule, platform status and TODO: `docs/example-demo-rules.md` (AGENTS.md "Example demo rules").
