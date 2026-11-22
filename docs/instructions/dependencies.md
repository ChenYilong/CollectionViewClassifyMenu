# Dependencies, licenses and resources

Tag: `dependencies`. The full rules of this tag. [AGENTS.md](../../AGENTS.md) keeps the short form under the heading
`[dependencies] Dependencies, licenses and resources`; read this file when a task touches the tag. Moved from AGENTS.md word for word on 2026-11-22, when
AGENTS.md was limited to 200 lines; section names are unchanged, so a reference such as AGENTS.md "CYLTabBarController reference and dependency" now
means the section of that name here.


## CYLTabBarController reference and dependency

- Every mention of CYLTabBarController (its code, APIs, podspec, initialization,
  animation engine, CI, demos, rules) means its newest commit over every branch,
  found by commit timestamp; it may be on a branch other than `master` or
  `main` (so far `feat/cross-platform-components`), and it is never a CocoaPods
  release.
- This project always integrates CYLTabBarController through CocoaPods, by that
  commit: `:git => 'https://github.com/ChenYilong/CYLTabBarController.git'` with
  `:commit => '<sha>'` (the `CYL_TAB_BAR` hash of `Example/Podfile` and
  `Example-Swift/Podfile`). Never a version number, `:branch` or `:tag`.
- The Flutter example's tab bar on Android is CYLTabBarController's Flutter plugin `flutter_cyltabbar`, a git
  dependency of `flutter/cyl_tag_list/example/pubspec.yaml` (`ref:` the same commit, `path:
  CrossPlatform/flutter_cyltabbar`). It is a pin like the Podfiles: it moves with them, and `--check` covers it.
- Before every build, find the newest commit with
  `scripts/cyl-tabbar-latest-commit.sh` (it fetches the tip of every branch and
  sorts by committer date; `--check` fails when a Podfile pins another commit).
  When it changed, update every pin and anything copied from CYLTabBarController
  in the same commit, after checking what changed in between.
- A pull request branch that is already merged into the newest branch does not
  count, even when it gets a newer commit afterwards (owner's decision,
  2026-11-17): pin the newest branch's tip, and move once that newer commit is
  merged there. CollectionViewClassifyMenu and CYLSearchViewController pin the
  same commit.
- Note (2026-11-17): from `e7ec145` to the next pin the pins stayed at `fbd05d5`
  (CYLTabBarController PR #814) because the newest branch lacked it; the owner
  merged #814 into `feat/cross-platform-components` (PR #788, `9a54e26`), so the
  pins follow the newest commit of that branch again.
- Search bars in the examples are CYLSearchViewController's `CYLSearchBarView`
  (the sibling `../CYLSearchViewController` repository, unreleased, no API
  compatibility to keep). Change it there as the examples need, commit and
  push on a feature branch, then pin that commit as `CYL_SEARCH` in
  `Example/Podfile` (`:git` + `:commit`, so CI can fetch it). Do not use a
  local `:path` in a committed Podfile: CI does not have the sibling folder.
- If this project is CYLTabBarController itself, depend on it locally instead:
  `pod 'CYLTabBarController', :path => '<relative path to the folder that holds
  CYLTabBarController.podspec>'`. Every other project uses the commit.
- Default integration in the examples (unless a request says otherwise):
  this project integrates CYLTabBarController by default, and every
  CYLTabBarController at the example level is the version **with a
  PlusButton that has a `plusChildViewController`** (the plus button selects
  a page of its own), **created from a local configuration file** in the
  example's bundle: `CYLTabBarController(configurationFile:)` /
  `+tabBarControllerWithConfigurationFile:error:`, with the tabs in
  `CYLTabBarControllerTabBarItemsAttributes`, the plus button in
  `CYLTabBarControllerPlusButton` (its page through
  `CYLTabBarItemPageIdentifier`), pages registered in
  `CYLTabBarPageRegistry`, and a `CYLTabBarControllerContext` of its own per
  tab bar. Build a tab bar in code, or leave out the plus button, only when a
  request asks for it. Details: `.agents/skills/cyl-dependency/`.
- Raised plus button: whenever an example integrates a PlusButton to demonstrate it, always prefer the raised
  ("bulging") plus button effect. Raised means the top of the plus button extends beyond the top edge of the tab
  bar. In a configuration file, raise it with `CYLPlusButtonCenterYOffset` (a negative offset) or
  `CYLPlusButtonCenterYMultiplier`; in code, with `+constantOfPlusButtonCenterYOffsetForTabBarHeight:` /
  `+multiplierOfTabBarHeight:` of `CYLPlusButtonSubclassing`. A flat plus button needs a request. Details:
  `.agents/skills/cyl-dependency/`.
- The core library depends on the shared animated icon + title component only:
  `CYLTagButton` subclasses `CYLAnimatedItemView`, from the pod and module
  `CYLAnimatedItem` (`CYLAnimatedItem.podspec` in CYLTabBarController's
  repository, no dependency on CYLTabBarController; podspec
  `s.dependency 'CYLAnimatedItem'`, Swift `import CYLAnimatedItem`; Swift package
  `.product(name: "CYLTabBarController")`, which still compiles the component
  into that module; Android `io.github.chenyilong:cyltabbarcontroller-animateditem`,
  package `com.cyl.animateditem`, built from the pinned commit through
  `substitute(...).using(project(":cylanimateditem"))`; guide:
  <https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md>).
  It never depends on an animation engine or library: only the examples add the
  engine subspecs (`CYLAnimatedItem/<Type>`: `LottieSwift`, `LottieObjectiveC`,
  `PAG`, `PAGEnterprise`, `Rive`, `SVGA`, `GIF`) and the Android animation
  libraries (Lottie, libpag, rive-android, SVGAPlayer); without them tags show
  their static images. The display priority, the failure fallbacks, the
  placeholder and the URL loading are the base class's: never reimplement them
  in a subclass. The configuration parser (`CYLTabBarConfigurationParser`) is
  still found at runtime. Since `CYLAnimatedItem` is not on the CocoaPods trunk
  yet, every Podfile names it by `:git` + `:commit` (`CYL_ANIMATED_ITEM`, the
  same commit as `CYL_TAB_BAR`; a Podfile that uses CYLTabBarController names it
  too, because CYLTabBarController's CYLUtils depends on `CYLAnimatedItem/Core`),
  and `scripts/pod-lint.sh lib` lints against a checkout of that commit.
- Details: `.agents/skills/cyl-dependency/`.


## License in every published package

- **Every package published to an external registry contains its license declaration.** This covers, without
  being limited to, CocoaPods, Swift Package Manager, Gradle / Maven, npm, pub.dev, ohpm and the mini program npm
  packages, on every platform. The license file ships with the package, and the package manifest names it.
- **The license goes into the package's built-in resource container**: when the package already has one, put the
  license file in it; when it has none, create one. On iOS the core's resource bundle
  (`CYLClassifyMenuResources.bundle`) contains `LICENSE`. The same rule applies to every platform: an Android
  library's Java resources (`META-INF/<artifact>/LICENSE`, inside the AAR), an npm package's root (listed in
  `files`), a pub.dev package's root, an ohpm HAR's module root and its `resources/rawfile`, a mini program npm
  package's root and its component folder `miniprogram_dist` (copied into `miniprogram_npm` when DevTools builds npm),
  as CYLTabBarController's `docs/License-Notices.md` does.
- The manifest declares the same license: podspec `s.license` (with `:file`), `Package.swift` resources, Maven POM
  `licenses`, `package.json` / `oh-package.json5` `license`, the pub.dev package's `LICENSE`.
- Ported or copied third-party code keeps its upstream license and notice next to it (for example the Apache-2.0
  ports in `android/`); a package that contains it ships those notices too.
- A package without its license file, or with a placeholder ("TODO: Add your license here"), is not ready to publish.
- The license of this repository's own code is MIT (`LICENSE`, decided 2026-11-17). Check:
  `bash scripts/check-licenses.sh`. Details and the per-platform locations: `.agents/skills/cyl-license/`.


## Bundled animation files

- Keep copied animation files (Lottie, PAG, Rive, GIF) unmodified, with their source, commit, path and
  license in the README next to them. One exception, as in CYLTableViewPlaceHolder
  ([PR #22](https://github.com/ChenYilong/CYLTableViewPlaceHolder/pull/22)): a background fill baked into a
  file (a Rive artboard fill, a "BG" shape) that draws a square behind an icon may be made transparent by
  setting its alpha to 0, and nothing else, when the license allows modification, or when the maintainer
  decides so for a file without a license (`house.riv`, 2026-11-12). Record the change and both SHA-256
  values in that README (`Animations/Rive/README.md`: `truck.riv`, `house.riv`).


## Image resources: folder bundles (added 2026-11-19)

- **New images of the core live as files in a folder bundle**, never in an asset catalog (user's prompt, verbatim:
  "请确保新增的图片资源文件在core代码仓库中均以文件夹形式管理，以iOS为例，图片资源文件均存放在.bundle的文件夹形式中"). On iOS that folder is
  `CollectionViewClassifyMenu/Resources/CYLClassifyMenuImages.bundle` (PNG files at @1x, @2x, @3x, e.g. `cyl_trash`),
  as CYLTabBarController's `CYLAnimatedItem.bundle`: the podspec copies it into `CYLClassifyMenuResources.bundle`,
  `Package.swift` copies it with `.copy`, and `CYLMenuResources.image(named:)` reads it first (`imagesBundle`).
  Other platforms keep their images in a resource folder of the same kind.


## Upstream projects (translations and ports)

- **Upstream projects used for translation.** When a document of this project links to a GitHub repository of
  another project, and that repository is the source of a translation or port (for example the projects ported to
  Kotlin in `android/`), do not translate only its default branch:
  1. **Pull requests.** Visit the upstream's open pull requests and bring them in. If the translation has not started,
     merge the open pull requests into the source first; if it is already done, translate each open pull request's
     change and merge it into our port.
  2. **Issues.** List the upstream's open issues in a table in the related document in `docs/` (create one when none
     fits): column 1 the issue link, column 2 its description, column 3 the fix status (`TODO` by default). Find each
     issue's counterpart in our code and try to fix it.
  3. **Score.** 100 means every listed issue is resolved. Give a score after each fixed issue and continue until 100.
  4. **Order.** For a translation not started yet: merge the open pull requests, fix issues until the score reaches
     60, translate, then fix the remaining issues up to 100. For a finished translation: translate and merge the open
     pull requests, then fix the issues on the translated code up to 100.
  5. The same rule applies to every platform (iOS, Android, Flutter, React Native, HarmonyOS, Mini Program).
  Details: `.agents/skills/cyl-upstream/`. The same rule is in the vault's root `instructions.md` (section 17).
