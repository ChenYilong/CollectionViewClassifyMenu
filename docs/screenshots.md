# 截图 / Screenshots

| 中文 | English |
|:---|:---|
| 来自 CI/CD 和本地构建、没有独立功能文档的截图。图片放在 `assets/`。规则：AGENTS.md，“CI/CD and Example screenshots”（标签：平台、系统版本、模拟器版本、平台 SDK 版本、仓库版本或提交 URL、拍摄时间；清晰的原图）。拼接（2026-11-18）：一列；高于一屏手机时用两列；页眉、各面板说明和页脚各占独立区域（AGENTS.md；`.agents/skills/cyl-screenshots/SKILL.md`）。 | Screenshots from CI/CD and local builds that have no feature document of their own. Images live in `assets/`. Rules: AGENTS.md, "CI/CD and Example screenshots" (labels: platform, OS version, simulator / emulator version, platform SDK version, repository version or commit URL, time taken; clear originals). Stitching (2026-11-18): one column, two when taller than a phone screen; header, panel captions and footer in their own bands (AGENTS.md; `.agents/skills/cyl-screenshots/SKILL.md`). |

| 截图 | 平台 | 环境 | 提交 | 拍摄时间 |
| --- | --- | --- | --- | --- |
| <img src="assets/ios-demo-tabbar-raised-plus.png" width="360" alt="iOS demo tab bar: Classify, the raised plus button (About), Filter"> 标签栏：每个功能一个标签，凸起的加号按钮 | iOS 系统 | macOS 27.3，Xcode 27.2 (27B5028f)，iPhone 17 Pro 模拟器，iOS 27.2 (24B8117)，CYLTabBarController `53766de` | `feat/android-kotlin`（添加此行的提交） | 2026-11-12 19:20 NZDT（新西兰时间） |
| <img src="assets/ios-demo-classify-tab.png" width="300" alt="iOS demo Classify tab"> 分类标签页：仅有单选分类菜单 | iOS 系统 | 同上 | 同上 | 2026-11-12 19:20 NZDT（新西兰时间） |
| <img src="assets/ios-demo-filter-tab.png" width="300" alt="iOS demo Filter tab"> 筛选标签页：筛选按钮、重置筛选、示例数据中的 83 个地点 | iOS 系统 | 同上 | 同上 | 2026-11-12 19:25 NZDT（新西兰时间） |
| <img src="assets/ios-demo-filter-panel.png" width="300" alt="iOS demo filter panel"> 筛选标签页：面板从左侧滑入，占据大部分屏幕；重置 / 应用按钮位于主屏幕指示条上方 | iOS 系统 | 同上 | 同上 | 2026-11-12 19:20 NZDT（新西兰时间） |
| <img src="assets/android-filter-panel.png" width="300" alt="Android filter panel"> Android 筛选标签页（详情见 [android.md](android.md)） | Android 系统 | Android 15 (API 35) 模拟器 `CYL_API35_arm64`，compileSdk 35 | `3598332` | 2026-11-12 18:35 NZDT（新西兰时间） |

| Screenshot | Platform | Environment | Commit | Taken |
| --- | --- | --- | --- | --- |
| <img src="assets/ios-demo-tabbar-raised-plus.png" width="360" alt="iOS demo tab bar: Classify, the raised plus button (About), Filter"> Tab bar: one tab per feature, raised plus button | iOS | macOS 27.3, Xcode 27.2 (27B5028f), iPhone 17 Pro simulator, iOS 27.2 (24B8117), CYLTabBarController `53766de` | `feat/android-kotlin` (the commit adding this row) | 2026-11-12 19:20 NZDT |
| <img src="assets/ios-demo-classify-tab.png" width="300" alt="iOS demo Classify tab"> Classify tab: single-choice classify menu only | iOS | as above | as above | 2026-11-12 19:20 NZDT |
| <img src="assets/ios-demo-filter-tab.png" width="300" alt="iOS demo Filter tab"> Filter tab: the filter button, Reset filters, the 83 places of the demo data | iOS | as above | as above | 2026-11-12 19:25 NZDT |
| <img src="assets/ios-demo-filter-panel.png" width="300" alt="iOS demo filter panel"> Filter tab: the panel slides in from the left over most of the screen; Reset / Apply above the home indicator | iOS | as above | as above | 2026-11-12 19:20 NZDT |
| <img src="assets/android-filter-panel.png" width="300" alt="Android filter panel"> Android Filter tab (details in [android.md](android.md)) | Android | Android 15 (API 35) emulator `CYL_API35_arm64`, compileSdk 35 | `3598332` | 2026-11-12 18:35 NZDT |

## iOS：每个示例页面（2026-11-17） / iOS: every example screen (2026-11-17)

| 中文 | English |
|:---|:---|
| **平台：** iOS，`Example/CYLMenuExample`（Swift）和纯 Swift 的 `Example-Swift/CYLTagEditorExample`（`swift-*`）。 | **Platform:** iOS, `Example/CYLMenuExample` (Swift) and the pure Swift `Example-Swift/CYLTagEditorExample` (`swift-*`). |
| **环境：** macOS 27.3，Xcode 27.2，模拟器“CYL ClassifyMenu iOS”（iPhone 17 Pro，iOS 27.2），干净的状态栏。 | **Environment:** macOS 27.3, Xcode 27.2, simulator "CYL ClassifyMenu iOS" (iPhone 17 Pro, iOS 27.2), clean status bar. |
| **提交：** `6f28226`（`feat/harmony`），CYLTabBarController / CYLAnimatedItem 锁定在 `57a527e`。 | **Commit:** `6f28226` (`feat/harmony`), CYLTabBarController / CYLAnimatedItem pinned at `57a527e`. |
| **拍摄时间：** 2026-11-17 22:30–22:55 NZDT，使用 `scripts/example-screenshots.sh "CYL ClassifyMenu iOS"`（每个页面启动一次，`-CYLExampleScreen <screen>`）；`product@zh-Hans` 在 22:53 重新拍摄（第一次截图显示的是上一个应用的最后一帧，已在脚本中修复）。 | **Taken:** 2026-11-17 22:30–22:55 NZDT with `scripts/example-screenshots.sh "CYL ClassifyMenu iOS"` (one launch per screen, `-CYLExampleScreen <screen>`); `product@zh-Hans` retaken at 22:53 (the first capture showed the previous app's last frame, fixed in the script). |
| **已检查：** 每个动效图标都能绘制（Lottie、PAG、Rive、SVGA、GIF），英文和繁体中文页面已翻译，`style-title-uncentered` 是仅标题的样式（设计上没有图标）。 | **Checked:** every animated icon draws (Lottie, PAG, Rive, SVGA, GIF), English and Traditional Chinese screens are translated, `style-title-uncentered` is the title-only style (no icons by design). |

| 页面 | 截图 |
|:---|:---|
| `animations-rive@zh-Hans` | <img src="assets/ios-1117/animations-rive@zh-Hans.png" width="200" alt="iOS animations-rive@zh-Hans"> |
| `animations-speed@zh-Hans` | <img src="assets/ios-1117/animations-speed@zh-Hans.png" width="200" alt="iOS animations-speed@zh-Hans"> |
| `animations-svga@zh-Hans` | <img src="assets/ios-1117/animations-svga@zh-Hans.png" width="200" alt="iOS animations-svga@zh-Hans"> |
| `animations@en` | <img src="assets/ios-1117/animations@en.png" width="200" alt="iOS animations@en"> |
| `animations@zh-Hans` | <img src="assets/ios-1117/animations@zh-Hans.png" width="200" alt="iOS animations@zh-Hans"> |
| `config@zh-Hans` | <img src="assets/ios-1117/config@zh-Hans.png" width="200" alt="iOS config@zh-Hans"> |
| `plus-discover-expanded@en` | <img src="assets/ios-1117/plus-discover-expanded@en.png" width="200" alt="iOS plus-discover-expanded@en"> |
| `plus-discover-expanded@zh-Hans` | <img src="assets/ios-1117/plus-discover-expanded@zh-Hans.png" width="200" alt="iOS plus-discover-expanded@zh-Hans"> |
| `plus-discover-refreshed@zh-Hans` | <img src="assets/ios-1117/plus-discover-refreshed@zh-Hans.png" width="200" alt="iOS plus-discover-refreshed@zh-Hans"> |
| `plus-discover@en` | <img src="assets/ios-1117/plus-discover@en.png" width="200" alt="iOS plus-discover@en"> |
| `plus-discover@zh-Hans` | <img src="assets/ios-1117/plus-discover@zh-Hans.png" width="200" alt="iOS plus-discover@zh-Hans"> |
| `plus-discover@zh-Hant` | <img src="assets/ios-1117/plus-discover@zh-Hant.png" width="200" alt="iOS plus-discover@zh-Hant"> |
| `plus-menu-filtered@en` | <img src="assets/ios-1117/plus-menu-filtered@en.png" width="200" alt="iOS plus-menu-filtered@en"> |
| `plus-menu-filtered@zh-Hans` | <img src="assets/ios-1117/plus-menu-filtered@zh-Hans.png" width="200" alt="iOS plus-menu-filtered@zh-Hans"> |
| `plus-menu@zh-Hans` | <img src="assets/ios-1117/plus-menu@zh-Hans.png" width="200" alt="iOS plus-menu@zh-Hans"> |
| `plus-reviews-db@zh-Hans` | <img src="assets/ios-1117/plus-reviews-db@zh-Hans.png" width="200" alt="iOS plus-reviews-db@zh-Hans"> |
| `plus@en` | <img src="assets/ios-1117/plus@en.png" width="200" alt="iOS plus@en"> |
| `plus@zh-Hans` | <img src="assets/ios-1117/plus@zh-Hans.png" width="200" alt="iOS plus@zh-Hans"> |
| `product@en` | <img src="assets/ios-1117/product@en.png" width="200" alt="iOS product@en"> |
| `product@zh-Hans` | <img src="assets/ios-1117/product@zh-Hans.png" width="200" alt="iOS product@zh-Hans"> |
| `reviews-expanded@en` | <img src="assets/ios-1117/reviews-expanded@en.png" width="200" alt="iOS reviews-expanded@en"> |
| `reviews-expanded@zh-Hans` | <img src="assets/ios-1117/reviews-expanded@zh-Hans.png" width="200" alt="iOS reviews-expanded@zh-Hans"> |
| `reviews-multi@zh-Hans` | <img src="assets/ios-1117/reviews-multi@zh-Hans.png" width="200" alt="iOS reviews-multi@zh-Hans"> |
| `reviews-network@zh-Hans` | <img src="assets/ios-1117/reviews-network@zh-Hans.png" width="200" alt="iOS reviews-network@zh-Hans"> |
| `reviews@zh-Hans` | <img src="assets/ios-1117/reviews@zh-Hans.png" width="200" alt="iOS reviews@zh-Hans"> |
| `search-gossip@zh-Hans` | <img src="assets/ios-1117/search-gossip@zh-Hans.png" width="200" alt="iOS search-gossip@zh-Hans"> |
| `search-home@zh-Hans` | <img src="assets/ios-1117/search-home@zh-Hans.png" width="200" alt="iOS search-home@zh-Hans"> |
| `search-jobs@en` | <img src="assets/ios-1117/search-jobs@en.png" width="200" alt="iOS search-jobs@en"> |
| `search-jobs@zh-Hans` | <img src="assets/ios-1117/search-jobs@zh-Hans.png" width="200" alt="iOS search-jobs@zh-Hans"> |
| `search@zh-Hans` | <img src="assets/ios-1117/search@zh-Hans.png" width="200" alt="iOS search@zh-Hans"> |
| `search@zh-Hant` | <img src="assets/ios-1117/search@zh-Hant.png" width="200" alt="iOS search@zh-Hant"> |
| `style-custom@zh-Hans` | <img src="assets/ios-1117/style-custom@zh-Hans.png" width="200" alt="iOS style-custom@zh-Hans"> |
| `style-gif@zh-Hans` | <img src="assets/ios-1117/style-gif@zh-Hans.png" width="200" alt="iOS style-gif@zh-Hans"> |
| `style-icon-only@zh-Hans` | <img src="assets/ios-1117/style-icon-only@zh-Hans.png" width="200" alt="iOS style-icon-only@zh-Hans"> |
| `style-lottie@zh-Hans` | <img src="assets/ios-1117/style-lottie@zh-Hans.png" width="200" alt="iOS style-lottie@zh-Hans"> |
| `style-pag@zh-Hans` | <img src="assets/ios-1117/style-pag@zh-Hans.png" width="200" alt="iOS style-pag@zh-Hans"> |
| `style-rive@zh-Hans` | <img src="assets/ios-1117/style-rive@zh-Hans.png" width="200" alt="iOS style-rive@zh-Hans"> |
| `style-svga@zh-Hans` | <img src="assets/ios-1117/style-svga@zh-Hans.png" width="200" alt="iOS style-svga@zh-Hans"> |
| `style-title-uncentered@zh-Hans` | <img src="assets/ios-1117/style-title-uncentered@zh-Hans.png" width="200" alt="iOS style-title-uncentered@zh-Hans"> |
| `style@en` | <img src="assets/ios-1117/style@en.png" width="200" alt="iOS style@en"> |
| `style@zh-Hans` | <img src="assets/ios-1117/style@zh-Hans.png" width="200" alt="iOS style@zh-Hans"> |
| `swift-editor-bottom@zh-Hans` | <img src="assets/ios-1117/swift-editor-bottom@zh-Hans.png" width="200" alt="iOS swift-editor-bottom@zh-Hans"> |
| `swift-editor-created@zh-Hans` | <img src="assets/ios-1117/swift-editor-created@zh-Hans.png" width="200" alt="iOS swift-editor-created@zh-Hans"> |
| `swift-editor-new@zh-Hans` | <img src="assets/ios-1117/swift-editor-new@zh-Hans.png" width="200" alt="iOS swift-editor-new@zh-Hans"> |
| `swift-editor-search@en` | <img src="assets/ios-1117/swift-editor-search@en.png" width="200" alt="iOS swift-editor-search@en"> |
| `swift-editor-search@zh-Hans` | <img src="assets/ios-1117/swift-editor-search@zh-Hans.png" width="200" alt="iOS swift-editor-search@zh-Hans"> |
| `swift-editor@en` | <img src="assets/ios-1117/swift-editor@en.png" width="200" alt="iOS swift-editor@en"> |
| `swift-editor@zh-Hans` | <img src="assets/ios-1117/swift-editor@zh-Hans.png" width="200" alt="iOS swift-editor@zh-Hans"> |
| `swift-remark@zh-Hans` | <img src="assets/ios-1117/swift-remark@zh-Hans.png" width="200" alt="iOS swift-remark@zh-Hans"> |
| `swift-styles-config@en` | <img src="assets/ios-1117/swift-styles-config@en.png" width="200" alt="iOS swift-styles-config@en"> |
| `swift-styles-config@zh-Hans` | <img src="assets/ios-1117/swift-styles-config@zh-Hans.png" width="200" alt="iOS swift-styles-config@zh-Hans"> |
| `swift-styles-expanded@zh-Hans` | <img src="assets/ios-1117/swift-styles-expanded@zh-Hans.png" width="200" alt="iOS swift-styles-expanded@zh-Hans"> |
| `swift-styles@en` | <img src="assets/ios-1117/swift-styles@en.png" width="200" alt="iOS swift-styles@en"> |
| `swift-styles@zh-Hans` | <img src="assets/ios-1117/swift-styles@zh-Hans.png" width="200" alt="iOS swift-styles@zh-Hans"> |

| Screen | Screenshot |
|:---|:---|
| `animations-rive@zh-Hans` | <img src="assets/ios-1117/animations-rive@zh-Hans.png" width="200" alt="iOS animations-rive@zh-Hans"> |
| `animations-speed@zh-Hans` | <img src="assets/ios-1117/animations-speed@zh-Hans.png" width="200" alt="iOS animations-speed@zh-Hans"> |
| `animations-svga@zh-Hans` | <img src="assets/ios-1117/animations-svga@zh-Hans.png" width="200" alt="iOS animations-svga@zh-Hans"> |
| `animations@en` | <img src="assets/ios-1117/animations@en.png" width="200" alt="iOS animations@en"> |
| `animations@zh-Hans` | <img src="assets/ios-1117/animations@zh-Hans.png" width="200" alt="iOS animations@zh-Hans"> |
| `config@zh-Hans` | <img src="assets/ios-1117/config@zh-Hans.png" width="200" alt="iOS config@zh-Hans"> |
| `plus-discover-expanded@en` | <img src="assets/ios-1117/plus-discover-expanded@en.png" width="200" alt="iOS plus-discover-expanded@en"> |
| `plus-discover-expanded@zh-Hans` | <img src="assets/ios-1117/plus-discover-expanded@zh-Hans.png" width="200" alt="iOS plus-discover-expanded@zh-Hans"> |
| `plus-discover-refreshed@zh-Hans` | <img src="assets/ios-1117/plus-discover-refreshed@zh-Hans.png" width="200" alt="iOS plus-discover-refreshed@zh-Hans"> |
| `plus-discover@en` | <img src="assets/ios-1117/plus-discover@en.png" width="200" alt="iOS plus-discover@en"> |
| `plus-discover@zh-Hans` | <img src="assets/ios-1117/plus-discover@zh-Hans.png" width="200" alt="iOS plus-discover@zh-Hans"> |
| `plus-discover@zh-Hant` | <img src="assets/ios-1117/plus-discover@zh-Hant.png" width="200" alt="iOS plus-discover@zh-Hant"> |
| `plus-menu-filtered@en` | <img src="assets/ios-1117/plus-menu-filtered@en.png" width="200" alt="iOS plus-menu-filtered@en"> |
| `plus-menu-filtered@zh-Hans` | <img src="assets/ios-1117/plus-menu-filtered@zh-Hans.png" width="200" alt="iOS plus-menu-filtered@zh-Hans"> |
| `plus-menu@zh-Hans` | <img src="assets/ios-1117/plus-menu@zh-Hans.png" width="200" alt="iOS plus-menu@zh-Hans"> |
| `plus-reviews-db@zh-Hans` | <img src="assets/ios-1117/plus-reviews-db@zh-Hans.png" width="200" alt="iOS plus-reviews-db@zh-Hans"> |
| `plus@en` | <img src="assets/ios-1117/plus@en.png" width="200" alt="iOS plus@en"> |
| `plus@zh-Hans` | <img src="assets/ios-1117/plus@zh-Hans.png" width="200" alt="iOS plus@zh-Hans"> |
| `product@en` | <img src="assets/ios-1117/product@en.png" width="200" alt="iOS product@en"> |
| `product@zh-Hans` | <img src="assets/ios-1117/product@zh-Hans.png" width="200" alt="iOS product@zh-Hans"> |
| `reviews-expanded@en` | <img src="assets/ios-1117/reviews-expanded@en.png" width="200" alt="iOS reviews-expanded@en"> |
| `reviews-expanded@zh-Hans` | <img src="assets/ios-1117/reviews-expanded@zh-Hans.png" width="200" alt="iOS reviews-expanded@zh-Hans"> |
| `reviews-multi@zh-Hans` | <img src="assets/ios-1117/reviews-multi@zh-Hans.png" width="200" alt="iOS reviews-multi@zh-Hans"> |
| `reviews-network@zh-Hans` | <img src="assets/ios-1117/reviews-network@zh-Hans.png" width="200" alt="iOS reviews-network@zh-Hans"> |
| `reviews@zh-Hans` | <img src="assets/ios-1117/reviews@zh-Hans.png" width="200" alt="iOS reviews@zh-Hans"> |
| `search-gossip@zh-Hans` | <img src="assets/ios-1117/search-gossip@zh-Hans.png" width="200" alt="iOS search-gossip@zh-Hans"> |
| `search-home@zh-Hans` | <img src="assets/ios-1117/search-home@zh-Hans.png" width="200" alt="iOS search-home@zh-Hans"> |
| `search-jobs@en` | <img src="assets/ios-1117/search-jobs@en.png" width="200" alt="iOS search-jobs@en"> |
| `search-jobs@zh-Hans` | <img src="assets/ios-1117/search-jobs@zh-Hans.png" width="200" alt="iOS search-jobs@zh-Hans"> |
| `search@zh-Hans` | <img src="assets/ios-1117/search@zh-Hans.png" width="200" alt="iOS search@zh-Hans"> |
| `search@zh-Hant` | <img src="assets/ios-1117/search@zh-Hant.png" width="200" alt="iOS search@zh-Hant"> |
| `style-custom@zh-Hans` | <img src="assets/ios-1117/style-custom@zh-Hans.png" width="200" alt="iOS style-custom@zh-Hans"> |
| `style-gif@zh-Hans` | <img src="assets/ios-1117/style-gif@zh-Hans.png" width="200" alt="iOS style-gif@zh-Hans"> |
| `style-icon-only@zh-Hans` | <img src="assets/ios-1117/style-icon-only@zh-Hans.png" width="200" alt="iOS style-icon-only@zh-Hans"> |
| `style-lottie@zh-Hans` | <img src="assets/ios-1117/style-lottie@zh-Hans.png" width="200" alt="iOS style-lottie@zh-Hans"> |
| `style-pag@zh-Hans` | <img src="assets/ios-1117/style-pag@zh-Hans.png" width="200" alt="iOS style-pag@zh-Hans"> |
| `style-rive@zh-Hans` | <img src="assets/ios-1117/style-rive@zh-Hans.png" width="200" alt="iOS style-rive@zh-Hans"> |
| `style-svga@zh-Hans` | <img src="assets/ios-1117/style-svga@zh-Hans.png" width="200" alt="iOS style-svga@zh-Hans"> |
| `style-title-uncentered@zh-Hans` | <img src="assets/ios-1117/style-title-uncentered@zh-Hans.png" width="200" alt="iOS style-title-uncentered@zh-Hans"> |
| `style@en` | <img src="assets/ios-1117/style@en.png" width="200" alt="iOS style@en"> |
| `style@zh-Hans` | <img src="assets/ios-1117/style@zh-Hans.png" width="200" alt="iOS style@zh-Hans"> |
| `swift-editor-bottom@zh-Hans` | <img src="assets/ios-1117/swift-editor-bottom@zh-Hans.png" width="200" alt="iOS swift-editor-bottom@zh-Hans"> |
| `swift-editor-created@zh-Hans` | <img src="assets/ios-1117/swift-editor-created@zh-Hans.png" width="200" alt="iOS swift-editor-created@zh-Hans"> |
| `swift-editor-new@zh-Hans` | <img src="assets/ios-1117/swift-editor-new@zh-Hans.png" width="200" alt="iOS swift-editor-new@zh-Hans"> |
| `swift-editor-search@en` | <img src="assets/ios-1117/swift-editor-search@en.png" width="200" alt="iOS swift-editor-search@en"> |
| `swift-editor-search@zh-Hans` | <img src="assets/ios-1117/swift-editor-search@zh-Hans.png" width="200" alt="iOS swift-editor-search@zh-Hans"> |
| `swift-editor@en` | <img src="assets/ios-1117/swift-editor@en.png" width="200" alt="iOS swift-editor@en"> |
| `swift-editor@zh-Hans` | <img src="assets/ios-1117/swift-editor@zh-Hans.png" width="200" alt="iOS swift-editor@zh-Hans"> |
| `swift-remark@zh-Hans` | <img src="assets/ios-1117/swift-remark@zh-Hans.png" width="200" alt="iOS swift-remark@zh-Hans"> |
| `swift-styles-config@en` | <img src="assets/ios-1117/swift-styles-config@en.png" width="200" alt="iOS swift-styles-config@en"> |
| `swift-styles-config@zh-Hans` | <img src="assets/ios-1117/swift-styles-config@zh-Hans.png" width="200" alt="iOS swift-styles-config@zh-Hans"> |
| `swift-styles-expanded@zh-Hans` | <img src="assets/ios-1117/swift-styles-expanded@zh-Hans.png" width="200" alt="iOS swift-styles-expanded@zh-Hans"> |
| `swift-styles@en` | <img src="assets/ios-1117/swift-styles@en.png" width="200" alt="iOS swift-styles@en"> |
| `swift-styles@zh-Hans` | <img src="assets/ios-1117/swift-styles@zh-Hans.png" width="200" alt="iOS swift-styles@zh-Hans"> |

## iOS：SVGA 动效图标（2026-11-17） / iOS: SVGA animated icons (2026-11-17)

| 中文 | English |
|:---|:---|
| 凡是展示 Rive 的地方都展示 SVGA（`example-demo-rules.md`，“SVGA wherever Rive is shown”）：动效图标页面的两个 SVGA 分区（CYLTabBarController 的 SVGA 标签图标，然后是 `icons.riv` 深色标签上的 SVGA），以及带有 SVGA 操作的样式页面。来自 CI 运行的原图，未作修改。 | SVGA wherever Rive is shown (`example-demo-rules.md`, "SVGA wherever Rive is shown"): the Animated icons screen's two SVGA sections (CYLTabBarController's SVGA tab icons, then on `icons.riv`'s dark tags) and the Styles screen with the SVGA action. Originals from the CI run, unchanged. |
| **平台：** iOS（`Example/CYLMenuExample`，Swift）。 | **Platform:** iOS (`Example/CYLMenuExample`, Swift). |
| **环境：** GitHub Actions `macos-26-arm64`，Xcode 26.6，iPhone 17 Pro 模拟器（该 Xcode 的 iOS 26 运行时）；CYLTabBarController `b5a02862`，使用 `pod 'CYLTabBarController/SVGA'`（SVGAPlayerLite）。 | **Environment:** GitHub Actions `macos-26-arm64`, Xcode 26.6, iPhone 17 Pro simulator (the iOS 26 runtime of that Xcode); CYLTabBarController `b5a02862` with `pod 'CYLTabBarController/SVGA'` (SVGAPlayerLite). |
| **仓库：** [`b27d340`](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/b27d340)，CI 运行 [43992497583](https://github.com/ChenYilong/CollectionViewClassifyMenu/actions/runs/43992497583)（9 个任务全部通过），截图位于 `ci-screenshots` 分支的 `feat-harmony/2444bc8/` 下。 | **Repository:** [`b27d340`](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/b27d340), CI run [43992497583](https://github.com/ChenYilong/CollectionViewClassifyMenu/actions/runs/43992497583) (all 9 jobs passed), screenshots on `ci-screenshots` under `feat-harmony/2444bc8/`. |
| **拍摄时间：** 2026-11-17 01:36 UTC。 | **Taken:** 2026-11-17 01:36 UTC. |

| 页面 | 截图 |
| --- | --- |
| 动效图标页面，`animations-svga`：“SVGA · pod 'CYLTabBarController/SVGA'”（首页已选中，搜索，消息，我的）和“SVGA · 深色标签”（动态已选中，列表，首页） | <img src="assets/ios-animations-svga.png" width="300" alt="iOS Animated icons screen, SVGA sections"> |
| 样式页面，`style-svga`：带有 SVGA 图标的预览标签（首页和我的交替出现；禁用的标签变暗） | <img src="assets/ios-style-svga.png" width="300" alt="iOS Styles screen with SVGA icons"> |

| Screen | Screenshot |
| --- | --- |
| Animated icons, `animations-svga`: "SVGA · pod 'CYLTabBarController/SVGA'" (Home selected, Search, Messages, Me) and "SVGA · Dark tags" (Feed selected, List, Home) | <img src="assets/ios-animations-svga.png" width="300" alt="iOS Animated icons screen, SVGA sections"> |
| Styles, `style-svga`: the preview tags with the SVGA icons (home and profile, alternating; the disabled tag dimmed) | <img src="assets/ios-style-svga.png" width="300" alt="iOS Styles screen with SVGA icons"> |

## HarmonyOS：每个示例（2026-11-16） / HarmonyOS: every demo (2026-11-16)

| 中文 | English |
|:---|:---|
| 包含 22 个示例的 HarmonyOS 示例应用（`harmony/entry`）在一台新的专用模拟器上运行，由 `harmony/scripts/screenshots.sh` 拍摄（启动选项用于打开各个页面；`en-`、`zh-hant-` 和 `dark-` 行设置语言或颜色模式）。有缺陷的行在 [harmony-verification.md](harmony-verification.md) 中为待办（B1、B9、B11、B12）。自上而下堆叠。 | The 22-demo HarmonyOS example (`harmony/entry`) on a new dedicated emulator, taken by `harmony/scripts/screenshots.sh` (launch options open each screen; `en-`, `zh-hant-` and `dark-` rows set the language or the color mode). Rows with a defect are TODO in [harmony-verification.md](harmony-verification.md) (B1, B9, B11, B12). Stacked top to bottom. |

| 截图 | 平台 | 环境 | 提交 | 拍摄时间 |
| --- | --- | --- | --- | --- |
| <img src="assets/harmonyos-root.jpeg" width="300" alt="HarmonyOS root"> `root` — 缺陷：页面能渲染，但中文标签页标题被截断（“场景一：评价筛”，“场景二：搜索分”）；英文显示正常 | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-en-root.jpeg" width="300" alt="HarmonyOS en-root"> `en-root` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-dark-root.jpeg" width="300" alt="HarmonyOS dark-root"> `dark-root` — 缺陷：页面能渲染，但中文标签页标题被截断（“场景一：评价筛”，“场景二：搜索分”）；英文显示正常 | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-product.jpeg" width="300" alt="HarmonyOS product"> `product` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-reviews-memory.jpeg" width="300" alt="HarmonyOS reviews-memory"> `reviews-memory` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-reviews-network.jpeg" width="300" alt="HarmonyOS reviews-network"> `reviews-network` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-reviews-database.jpeg" width="300" alt="HarmonyOS reviews-database"> `reviews-database` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-search-home.jpeg" width="300" alt="HarmonyOS search-home"> `search-home` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-search-category.jpeg" width="300" alt="HarmonyOS search-category"> `search-category` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-search-category-page.jpeg" width="300" alt="HarmonyOS search-category-page"> `search-category-page` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-search-discover.jpeg" width="300" alt="HarmonyOS search-discover"> `search-discover` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-query-scenarios.jpeg" width="300" alt="HarmonyOS query-scenarios"> `query-scenarios` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-menu-linkage.jpeg" width="300" alt="HarmonyOS menu-linkage"> `menu-linkage` — 缺陷：分类标题（吃喝玩逛）显示为放大、模糊、被拉伸的图片，而不是标题文字，若干标签显示为青色楔形；SQL 和 83 条结果是正确的 | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-styles.jpeg" width="300" alt="HarmonyOS styles"> `styles` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-zh-hant-styles.jpeg" width="300" alt="HarmonyOS zh-hant-styles"> `zh-hant-styles` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-animations.jpeg" width="300" alt="HarmonyOS animations"> `animations` — 缺陷：在中文（以及深色模式）下，Lottie、PAG 和 Rive 行不显示标签，只有空行；在英文下，每个动效标签都能渲染 | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-en-animations.jpeg" width="300" alt="HarmonyOS en-animations"> `en-animations` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-dark-animations.jpeg" width="300" alt="HarmonyOS dark-animations"> `dark-animations` — 缺陷：在中文（以及深色模式）下，Lottie、PAG 和 Rive 行不显示标签，只有空行；在英文下，每个动效标签都能渲染 | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-configuration.jpeg" width="300" alt="HarmonyOS configuration"> `configuration` — 缺陷：能渲染，但字典行的第四个 chip 为空；日志显示 `NapiDefineClass occur exception, className:JPAGImageView`（PAG） | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-tag-cloud.jpeg" width="300" alt="HarmonyOS tag-cloud"> `tag-cloud` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-tag-cloud-sample.jpeg" width="300" alt="HarmonyOS tag-cloud-sample"> `tag-cloud-sample` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-tag-cloud-sub.jpeg" width="300" alt="HarmonyOS tag-cloud-sub"> `tag-cloud-sub` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-tag-cloud-list.jpeg" width="300" alt="HarmonyOS tag-cloud-list"> `tag-cloud-list` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-tag-cloud-recycler.jpeg" width="300" alt="HarmonyOS tag-cloud-recycler"> `tag-cloud-recycler` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-hot-search.jpeg" width="300" alt="HarmonyOS hot-search"> `hot-search` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-image-tag-sample.jpeg" width="300" alt="HarmonyOS image-tag-sample"> `image-tag-sample` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-image-tag-edit.jpeg" width="300" alt="HarmonyOS image-tag-edit"> `image-tag-edit` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-image-tag-list.jpeg" width="300" alt="HarmonyOS image-tag-list"> `image-tag-list` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |
| <img src="assets/harmonyos-tag-container.jpeg" width="300" alt="HarmonyOS tag-container"> `tag-container` | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（Mate 70 Pro 配置，6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），DevEco Studio 6.0.1 hvigor，macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT（新西兰时间） |

| Screenshot | Platform | Environment | Commit | Taken |
| --- | --- | --- | --- | --- |
| <img src="assets/harmonyos-root.jpeg" width="300" alt="HarmonyOS root"> `root` — defect: the screen renders, but the Chinese tab titles are cut off (the titles for "Scenario 1: Review filter" and "Scenario 2: Search categories" lose their last characters); English fits | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-en-root.jpeg" width="300" alt="HarmonyOS en-root"> `en-root` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-dark-root.jpeg" width="300" alt="HarmonyOS dark-root"> `dark-root` — defect: the screen renders, but the Chinese tab titles are cut off (the titles for "Scenario 1: Review filter" and "Scenario 2: Search categories" lose their last characters); English fits | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-product.jpeg" width="300" alt="HarmonyOS product"> `product` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-reviews-memory.jpeg" width="300" alt="HarmonyOS reviews-memory"> `reviews-memory` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-reviews-network.jpeg" width="300" alt="HarmonyOS reviews-network"> `reviews-network` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-reviews-database.jpeg" width="300" alt="HarmonyOS reviews-database"> `reviews-database` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-search-home.jpeg" width="300" alt="HarmonyOS search-home"> `search-home` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-search-category.jpeg" width="300" alt="HarmonyOS search-category"> `search-category` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-search-category-page.jpeg" width="300" alt="HarmonyOS search-category-page"> `search-category-page` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-search-discover.jpeg" width="300" alt="HarmonyOS search-discover"> `search-discover` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-query-scenarios.jpeg" width="300" alt="HarmonyOS query-scenarios"> `query-scenarios` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-menu-linkage.jpeg" width="300" alt="HarmonyOS menu-linkage"> `menu-linkage` — defect: the category headers (Eat, Drink, Play, Shop) render as large blurred, stretched images instead of their titles, and several tags as teal wedges; the SQL and the 83 results are right | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-styles.jpeg" width="300" alt="HarmonyOS styles"> `styles` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-zh-hant-styles.jpeg" width="300" alt="HarmonyOS zh-hant-styles"> `zh-hant-styles` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-animations.jpeg" width="300" alt="HarmonyOS animations"> `animations` — defect: in Chinese (and dark mode) the Lottie, PAG and Rive rows show no tags, only empty rows; in English every animated tag renders | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-en-animations.jpeg" width="300" alt="HarmonyOS en-animations"> `en-animations` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-dark-animations.jpeg" width="300" alt="HarmonyOS dark-animations"> `dark-animations` — defect: in Chinese (and dark mode) the Lottie, PAG and Rive rows show no tags, only empty rows; in English every animated tag renders | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-configuration.jpeg" width="300" alt="HarmonyOS configuration"> `configuration` — defect: renders, but the fourth chip of the dictionary row is empty; the log shows `NapiDefineClass occur exception, className:JPAGImageView` (PAG) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-tag-cloud.jpeg" width="300" alt="HarmonyOS tag-cloud"> `tag-cloud` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-tag-cloud-sample.jpeg" width="300" alt="HarmonyOS tag-cloud-sample"> `tag-cloud-sample` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-tag-cloud-sub.jpeg" width="300" alt="HarmonyOS tag-cloud-sub"> `tag-cloud-sub` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-tag-cloud-list.jpeg" width="300" alt="HarmonyOS tag-cloud-list"> `tag-cloud-list` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-tag-cloud-recycler.jpeg" width="300" alt="HarmonyOS tag-cloud-recycler"> `tag-cloud-recycler` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-hot-search.jpeg" width="300" alt="HarmonyOS hot-search"> `hot-search` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-image-tag-sample.jpeg" width="300" alt="HarmonyOS image-tag-sample"> `image-tag-sample` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-image-tag-edit.jpeg" width="300" alt="HarmonyOS image-tag-edit"> `image-tag-edit` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-image-tag-list.jpeg" width="300" alt="HarmonyOS image-tag-list"> `image-tag-list` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |
| <img src="assets/harmonyos-tag-container.jpeg" width="300" alt="HarmonyOS tag-container"> `tag-container` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (Mate 70 Pro profile, 6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), DevEco Studio 6.0.1 hvigor, macOS 27.3 | `ccf9a57` | 2026-11-16 14:36–14:41 NZDT |

## HarmonyOS：推入的页面（2026-11-16） / HarmonyOS: pushed pages (2026-11-16)

| 中文 | English |
|:---|:---|
| 通过点击按文本或无障碍文本找到的控件到达（AGENTS.md，无障碍优先的 UI 驱动），从根标签栏或通过启动选项打开的示例进入。自上而下堆叠。 | Reached by tapping controls found by their text or accessibility text (AGENTS.md, accessibility-first UI driving), from the root tab bar or a demo opened by launch option. Stacked top to bottom. |

| 截图 | 平台 | 环境 | 提交 | 拍摄时间 |
| --- | --- | --- | --- | --- |
| <img src="assets/harmonyos-push-reviews-all.jpeg" width="300" alt="HarmonyOS reviews-all"> root → “查看更多评价”：评价列表，内存模式 | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），macOS 27.3 | `868db3e` | 2026-11-16 14:55–14:57 NZDT（新西兰时间） |
| <img src="assets/harmonyos-push-search-tab.jpeg" width="300" alt="HarmonyOS search-tab"> root → 标签页“场景二：搜索分类”（场景二） | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），macOS 27.3 | `868db3e` | 2026-11-16 14:55–14:57 NZDT（新西兰时间） |
| <img src="assets/harmonyos-push-styles-tab.jpeg" width="300" alt="HarmonyOS styles-tab"> root → 标签页“样式”（样式） | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），macOS 27.3 | `868db3e` | 2026-11-16 14:55–14:57 NZDT（新西兰时间） |
| <img src="assets/harmonyos-push-animations-tab.jpeg" width="300" alt="HarmonyOS animations-tab"> root → 标签页“动效”：在这条路径上，中文下的动效标签能够渲染 | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），macOS 27.3 | `868db3e` | 2026-11-16 14:55–14:57 NZDT（新西兰时间） |
| <img src="assets/harmonyos-push-image-tag-list.jpeg" width="300" alt="HarmonyOS image-tag-list"> 图片标签示例 → “标签列表” | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），macOS 27.3 | `868db3e` | 2026-11-16 14:55–14:57 NZDT（新西兰时间） |
| <img src="assets/harmonyos-push-tag-cloud-list-view.jpeg" width="300" alt="HarmonyOS tag-cloud-list-view"> 标签云示例 → “列表视图” | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），macOS 27.3 | `868db3e` | 2026-11-16 14:55–14:57 NZDT（新西兰时间） |
| <img src="assets/harmonyos-push-query-reviews-database.jpeg" width="300" alt="HarmonyOS query-reviews-database"> 查询场景 → “评价筛选 · 数据库（SQLite）”：数据库模式下的评价列表，并显示其 SQL | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），macOS 27.3 | `0452691` | 2026-11-16 15:07–15:09 NZDT（新西兰时间） |
| <img src="assets/harmonyos-push-query-menu-linkage.jpeg" width="300" alt="HarmonyOS query-menu-linkage"> 查询场景 → “分类菜单 + 多选筛选 · 数据库联动”：菜单联动页面（在 `38fc21d` 之后 10:36 重新拍摄：此前折叠箭头过大） | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），macOS 27.3 | `0452691` | 2026-11-16 15:07–15:09 NZDT（新西兰时间） |
| <img src="assets/harmonyos-push-query-search-discover.jpeg" width="300" alt="HarmonyOS query-search-discover"> 查询场景 → “最近搜索 + 发现” | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），macOS 27.3 | `0452691` | 2026-11-16 15:07–15:09 NZDT（新西兰时间） |
| <img src="assets/harmonyos-push-image-tag-create.jpeg" width="300" alt="HarmonyOS image-tag-create"> 图片标签示例 → “创建标签”：带有各步骤的编辑页面 | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），macOS 27.3 | `0452691` | 2026-11-16 15:07–15:09 NZDT（新西兰时间） |
| <img src="assets/harmonyos-push-tag-cloud-recycler-view.jpeg" width="300" alt="HarmonyOS tag-cloud-recycler-view"> 标签云示例 → “回收视图”（RecyclerView 示例） | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），macOS 27.3 | `0452691` | 2026-11-16 15:07–15:09 NZDT（新西兰时间） |
| <img src="assets/harmonyos-push-tag-cloud-result.jpeg" width="300" alt="HarmonyOS tag-cloud-result"> 标签云示例 → “页面返回结果”：返回一个标签的子页面 | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），macOS 27.3 | `0452691` | 2026-11-16 15:07–15:09 NZDT（新西兰时间） |

| Screenshot | Platform | Environment | Commit | Taken |
| --- | --- | --- | --- | --- |
| <img src="assets/harmonyos-push-reviews-all.jpeg" width="300" alt="HarmonyOS reviews-all"> root → "See all reviews": the review list, memory mode | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `868db3e` | 2026-11-16 14:55–14:57 NZDT |
| <img src="assets/harmonyos-push-search-tab.jpeg" width="300" alt="HarmonyOS search-tab"> root → tab "Scenario 2: Search categories" (Scenario 2) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `868db3e` | 2026-11-16 14:55–14:57 NZDT |
| <img src="assets/harmonyos-push-styles-tab.jpeg" width="300" alt="HarmonyOS styles-tab"> root → tab "Styles" | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `868db3e` | 2026-11-16 14:55–14:57 NZDT |
| <img src="assets/harmonyos-push-animations-tab.jpeg" width="300" alt="HarmonyOS animations-tab"> root → tab "Animations": the animated tags render in Chinese on this route | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `868db3e` | 2026-11-16 14:55–14:57 NZDT |
| <img src="assets/harmonyos-push-image-tag-list.jpeg" width="300" alt="HarmonyOS image-tag-list"> image tag sample → "Tag list" | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `868db3e` | 2026-11-16 14:55–14:57 NZDT |
| <img src="assets/harmonyos-push-tag-cloud-list-view.jpeg" width="300" alt="HarmonyOS tag-cloud-list-view"> tag cloud sample → "List view" | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `868db3e` | 2026-11-16 14:55–14:57 NZDT |
| <img src="assets/harmonyos-push-query-reviews-database.jpeg" width="300" alt="HarmonyOS query-reviews-database"> query scenarios → "Review filter · database (SQLite)": the review list in database mode, its SQL shown | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `0452691` | 2026-11-16 15:07–15:09 NZDT |
| <img src="assets/harmonyos-push-query-menu-linkage.jpeg" width="300" alt="HarmonyOS query-menu-linkage"> query scenarios → "Classify menu + multiple filter · database linkage": the menu linkage page (retaken 10:36 after `38fc21d`: the fold arrows were oversized before) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `0452691` | 2026-11-16 15:07–15:09 NZDT |
| <img src="assets/harmonyos-push-query-search-discover.jpeg" width="300" alt="HarmonyOS query-search-discover"> query scenarios → "Recent searches + discover" | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `0452691` | 2026-11-16 15:07–15:09 NZDT |
| <img src="assets/harmonyos-push-image-tag-create.jpeg" width="300" alt="HarmonyOS image-tag-create"> image tag sample → "Create tags": the edit page with its steps | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `0452691` | 2026-11-16 15:07–15:09 NZDT |
| <img src="assets/harmonyos-push-tag-cloud-recycler-view.jpeg" width="300" alt="HarmonyOS tag-cloud-recycler-view"> tag cloud sample → "RecyclerView example" | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `0452691` | 2026-11-16 15:07–15:09 NZDT |
| <img src="assets/harmonyos-push-tag-cloud-result.jpeg" width="300" alt="HarmonyOS tag-cloud-result"> tag cloud sample → "Page result": the sub-page that returns a tag | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `0452691` | 2026-11-16 15:07–15:09 NZDT |

| 中文 | English |
|:---|:---|
| 未记录为页面，因为点击后屏幕上没有任何变化（已报告给该移植版本的负责人，待办）：加号按钮（它不暴露无障碍文本，只有描述）、菜单联动的筛选按钮（既无文字也无描述的图片）、评价筛选“好评”和搜索分类“找人”。 | Not documented as pages, because the tap changed nothing on screen (reported to the port's owner, TODO): the plus button (it exposes no accessibility text, only a description), the menu-linkage filter button (an image with neither text nor description), the review filter "Good" and the search category "People". |
| 第二批（2026-11-16 15:07–15:09）：评价筛选，用其真实标签“好评(9)”重试，仍然停留在已选中“全部”，有 10 条匹配（已报告，待办）。点击商品评价标签（“质量不错(5)”）、热搜标签（“小西瓜”）、搜索分类标签（“腾讯工程师”）和标签云的“可删除”标签，都没有出现新页面；iOS 示例在那里是否会打开页面，尚未检查。 | Second batch (2026-11-16 15:07–15:09): the review filter, retried with its real label "Good (9)", still leaves "All" selected with 10 matches (reported, TODO). Taps on a product review tag ("Good quality (5)"), a hot-search tag ("Little watermelon"), a search-category tag ("Tencent engineer") and the tag-cloud "Deletable" tag showed no new page; whether the iOS example opens one there is not checked yet. |

### 修复后推入的页面（2026-11-16 10:26–10:31 模拟器时间） / Pushed pages after the port's fixes (2026-11-16 10:26–10:31 emulator time)

| 截图 | 平台 | 环境 | 提交 | 拍摄时间 |
| --- | --- | --- | --- | --- |
| <img src="assets/harmonyos-push-plus-page.jpeg" width="300" alt="HarmonyOS plus-page"> root → 加号按钮：其页面“查询筛选”，在 `53266fd` 之后 | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），macOS 27.3 | `d1bc5ec` | 2026-11-16 15:26–15:31 NZDT（新西兰时间） |
| <img src="assets/harmonyos-push-product-tag.jpeg" width="300" alt="HarmonyOS product-tag"> 商品 → 评价标签“质量不错(5)”：按它筛选后的评价列表，5 条匹配（在 `38fc21d` 之后，与 iOS 一致） | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），macOS 27.3 | `d1bc5ec` | 2026-11-16 15:26–15:31 NZDT（新西兰时间） |
| <img src="assets/harmonyos-push-reviews-good.jpeg" width="300" alt="HarmonyOS reviews-good"> 评价列表 → “好评(9)”：9 条匹配（在 `38fc21d` 之后） | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），macOS 27.3 | `d1bc5ec` | 2026-11-16 15:26–15:31 NZDT（新西兰时间） |
| <img src="assets/harmonyos-push-hot-search-tag.jpeg" width="300" alt="HarmonyOS hot-search-tag"> 热门搜索 → “小西瓜”：搜索框接收该标签（在 `38fc21d` 之后） | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），macOS 27.3 | `d1bc5ec` | 2026-11-16 15:26–15:31 NZDT（新西兰时间） |
| <img src="assets/harmonyos-push-search-category-tag.jpeg" width="300" alt="HarmonyOS search-category-tag"> 搜索分类 → “腾讯工程师”：搜索框接收该标签（在 `38fc21d` 之后） | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），macOS 27.3 | `d1bc5ec` | 2026-11-16 15:26–15:31 NZDT（新西兰时间） |
| <img src="assets/harmonyos-push-menu-filter-sheet.jpeg" width="300" alt="HarmonyOS menu-filter-sheet"> 菜单联动 → 筛选按钮：地区和菜品面板能打开（在 `53266fd` 之后），但位于灰色遮罩层之下，所以看起来是模糊的（待办） | HarmonyOS 系统 | HarmonyOS 6.0.1 SDK (API 21)，模拟器 `CYL ClassifyMenu Test`（6.0.0.112(SP3DEVC00E112R4P11)，1316 × 2832），macOS 27.3 | `d1bc5ec` | 2026-11-16 15:26–15:31 NZDT（新西兰时间） |

| Screenshot | Platform | Environment | Commit | Taken |
| --- | --- | --- | --- | --- |
| <img src="assets/harmonyos-push-plus-page.jpeg" width="300" alt="HarmonyOS plus-page"> root → the plus button: its page "Query filter", after `53266fd` | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `d1bc5ec` | 2026-11-16 15:26–15:31 NZDT |
| <img src="assets/harmonyos-push-product-tag.jpeg" width="300" alt="HarmonyOS product-tag"> product → review tag "Good quality (5)": the review list filtered to it, 5 matches (after `38fc21d`, as iOS) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `d1bc5ec` | 2026-11-16 15:26–15:31 NZDT |
| <img src="assets/harmonyos-push-reviews-good.jpeg" width="300" alt="HarmonyOS reviews-good"> review list → "Good (9)": 9 matches (after `38fc21d`) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `d1bc5ec` | 2026-11-16 15:26–15:31 NZDT |
| <img src="assets/harmonyos-push-hot-search-tag.jpeg" width="300" alt="HarmonyOS hot-search-tag"> hot search → "Little watermelon": the search field takes the tag (after `38fc21d`) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `d1bc5ec` | 2026-11-16 15:26–15:31 NZDT |
| <img src="assets/harmonyos-push-search-category-tag.jpeg" width="300" alt="HarmonyOS search-category-tag"> search category → "Tencent engineer": the search field takes the tag (after `38fc21d`) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `d1bc5ec` | 2026-11-16 15:26–15:31 NZDT |
| <img src="assets/harmonyos-push-menu-filter-sheet.jpeg" width="300" alt="HarmonyOS menu-filter-sheet"> menu linkage → filter button: the regions and dishes panel opens (after `53266fd`), but under a gray dimming layer, so it looks blurred (TODO) | HarmonyOS | HarmonyOS 6.0.1 SDK (API 21), emulator `CYL ClassifyMenu Test` (6.0.0.112(SP3DEVC00E112R4P11), 1316 × 2832), macOS 27.3 | `d1bc5ec` | 2026-11-16 15:26–15:31 NZDT |

## 已完成（2026-11-18，`feat/harmony`）：截图拼接规则（布局、页眉、页脚、标签） / DONE (2026-11-18, `feat/harmony`): screenshot stitching rules (layout, header, footer, labels)

| 中文 | English |
|:---|:---|
| **提示词（原文）**：「找到本项目instructions 相关文件以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入：找到截图相关规范，如果没有就新建保证写入成功，截图除了 优先选用竖版排列风格。优先两列，多行。且给拼接好的图增加header，footer，header，footer不能与截图区域重叠 覆盖，标注关键信息：关键信息也是英文，测试模拟器平台，模拟器系统版本，操作系统版本，ide 版本，以及测试目的等等。以附带的截图为例。提取截图的附带信息以及风格 完善我的描述规则。」 | **Prompt (verbatim)**: 「找到本项目instructions 相关文件以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入：找到截图相关规范，如果没有就新建保证写入成功，截图除了 优先选用竖版排列风格。优先两列，多行。且给拼接好的图增加header，footer，header，footer不能与截图区域重叠 覆盖，标注关键信息：关键信息也是英文，测试模拟器平台，模拟器系统版本，操作系统版本，ide 版本，以及测试目的等等。以附带的截图为例。提取截图的附带信息以及风格 完善我的描述规则。」 |
| **英文**：在本项目中找到说明文件和 skill 文件（缺少则创建），并只用英文写入截图规则（缺少则创建）：拼接后的截图优先采用竖版排列、两列、多行；每张拼接图都有页眉和页脚，且页眉页脚绝不与截图区域重叠或遮挡；它们用英文标注关键信息：模拟器平台、模拟器系统版本、宿主操作系统版本、IDE 版本、测试目的等。以附带的截图（`assets/ios-rive-rest.png`）为例：提取其信息和风格并完善这些规则。 | **English**: find this project's instruction files and skill files (create them if missing) and write, in English only, the screenshot rules (create them if missing): stitched screenshots prefer a portrait layout, two columns and several rows; every stitched image gets a header and a footer that never overlap or cover the screenshot areas; they carry the key information in English: the simulator platform, the simulator OS version, the host OS version, the IDE version, the test purpose and so on. Use the attached screenshot (`assets/ios-rive-rest.png`) as the example: extract its information and style and complete the rules. |
| **计划**：AGENTS.md（截图规则）、docs/instructions.md、scripts/instructions.md、新的 skill `.agents/skills/cyl-screenshots/SKILL.md`（从 `cyl-verify` 链接），以及按这些规则排布图片的 `scripts/stitch-screenshots.swift`；用它重做示例。 | **Plan**: AGENTS.md (the screenshot rules), docs/instructions.md, scripts/instructions.md, a new skill `.agents/skills/cyl-screenshots/SKILL.md` (linked from `cyl-verify`), and `scripts/stitch-screenshots.swift`, which lays the images out by these rules; redo the example with it. |
| **结果（2026-11-18）**：已完成。规则已追加到 AGENTS.md（“Screenshots: stitching layout, update”、“Screenshots: header and footer”）、`instructions.md`（本文件夹）、`../scripts/instructions.md`；新增 skill `.agents/skills/cyl-screenshots/SKILL.md`，从 `cyl-verify` 链接；新增工具 `../scripts/stitch-screenshots.swift`。按规则重做的示例： | **Result (2026-11-18)**: DONE. Rules appended to AGENTS.md ("Screenshots: stitching layout, update", "Screenshots: header and footer"), `instructions.md` (this folder), `../scripts/instructions.md`; new skill `.agents/skills/cyl-screenshots/SKILL.md`, linked from `cyl-verify`; new tool `../scripts/stitch-screenshots.swift`. Example redone by the rules: |

  ![iOS Rive icons rest until played, then play and loop: 2 x 2 grid with header and footer](assets/ios-rive-rest-then-play-grid.png)

## 已完成（2026-11-18，`feat/harmony`）：优先一列，一列高于一屏手机时用两列 / DONE (2026-11-18, `feat/harmony`): one column first, two columns when one column is taller than a phone screen

| 中文 | English |
|:---|:---|
| **提示词（原文）**：「更新截图规则，优选一列多行 如果一列拼接后长度超过普通手机的一屏幕 则两列多行」 | **Prompt (verbatim)**: 「更新截图规则，优选一列多行 如果一列拼接后长度超过普通手机的一屏幕 则两列多行」 |
| **英文**：更新截图规则：优先一列多行；如果一列拼接后的长度超过普通手机的一屏，则使用两列多行。 | **English**: update the screenshot rules: prefer one column with several rows; if the one-column stitch is longer than one screen of an ordinary phone, use two columns with several rows. |
| **计划**：将更新追加到 AGENTS.md、`instructions.md`、`../scripts/instructions.md` 和 `cyl-screenshots` skill；`scripts/stitch-screenshots.swift` 默认按此规则选择列数（`--columns auto`）。 | **Plan**: append the update to AGENTS.md, `instructions.md`, `../scripts/instructions.md` and the `cyl-screenshots` skill; `scripts/stitch-screenshots.swift` picks the columns by this rule by default (`--columns auto`). |
| **结果（2026-11-18）**：已完成。AGENTS.md 的“Screenshots: columns, update”、`instructions.md`、`../scripts/instructions.md` 和 `cyl-screenshots` skill 已更新；`scripts/stitch-screenshots.swift` 按该规则选择一列或两列（`--columns auto`，默认）。一列（两个裁剪后的面板，1148 x 1081 px）： | **Result (2026-11-18)**: DONE. AGENTS.md "Screenshots: columns, update", `instructions.md`, `../scripts/instructions.md` and the `cyl-screenshots` skill updated; `scripts/stitch-screenshots.swift` chooses one or two columns by the rule (`--columns auto`, the default). One column (two cropped panels, 1148 x 1081 px): |

  ![iOS Rive icons at rest, one column with header and footer](assets/ios-rive-rest-one-column.png)

## 已完成（2026-11-18，`feat/harmony`）：从 CI 中移除截图标签检查 / DONE (2026-11-18, `feat/harmony`): remove the screenshot label check from CI

| 中文 | English |
|:---|:---|
| **提示词（原文）**：“Remove label CI screenshots from ci” | **Prompt (verbatim)**: "Remove label CI screenshots from ci" |
| **英文**：从 CI 中移除截图标签检查。 | **English**: remove the screenshot label check from CI. |
| **计划**：删除 `.github/workflows/screenshot-labels.yml`；保留每次提交前的检查（`scripts/check-branch-pr.sh` 运行 `scripts/check-screenshots.py`）；更新 AGENTS.md 以及写有“in CI”的注释。CYLTabBarController 做了同样的事（`70064275`）。 | **Plan**: delete `.github/workflows/screenshot-labels.yml`; keep the check before every commit (`scripts/check-branch-pr.sh` runs `scripts/check-screenshots.py`); update AGENTS.md and the comments that say "in CI". CYLTabBarController did the same (`70064275`). |
| **结果（2026-11-18）**：已完成。已删除 `.github/workflows/screenshot-labels.yml`；AGENTS.md 的“Checked before every commit”以及 `scripts/stitch-screenshots.py`、`.swift` 和 `check-screenshots.py` 的注释不再提到 CI。每次提交前的检查（`scripts/check-branch-pr.sh`）保留。 | **Result (2026-11-18)**: DONE. `.github/workflows/screenshot-labels.yml` removed; AGENTS.md "Checked before every commit" and the comments of `scripts/stitch-screenshots.py`, `.swift` and `check-screenshots.py` no longer mention CI. The check before every commit (`scripts/check-branch-pr.sh`) stays. |


## iOS Liquid Glass tags (PR #36), 2026-11-25

| 中文 | English |
|:---|:---|
| 标签的 Liquid Glass 背景（`backgroundStyle = liquidGlass`）。环境：iOS 27.2、iPhone 18 Pro 模拟器、Xcode 27.2 (27B52)；ClassifyMenu `7c64042e` + CYLTabBarController `3f2a5b99`；拍摄于 2026-11-25 00:33 NZDT。浅色模式；“纯色页面”一行由本地临时改动测试代码的渐变高度得到（未提交），其余为分支上的原测试。 | Liquid Glass tag background (`backgroundStyle = liquidGlass`). Environment: iOS 27.2, iPhone 18 Pro simulator, Xcode 27.2 (27B52); ClassifyMenu `7c64042e` + CYLTabBarController `3f2a5b99`; taken 2026-11-25 00:33 NZDT. Light mode; the plain-page rows come from the branch's `testDefaultStyleFlatVersusGlassNormalSelectedDisabled` with the gradient height shortened locally (not committed, so the plain rows are really on white); the other shots are the branch's tests unchanged. |

![iOS default style tags: normal, selected, disabled; flat vs liquidGlass on a colorful and a plain page](assets/ios-tag-liquid-glass-default-style-light.png)

Default style: normal / selected / disabled tags, flat vs `liquidGlass`, on a colorful page and on a plain white page. On white the glass normal and disabled tags are nearly invisible (only a thin outline), the selected glass tag is a lighter teal than the flat one.

![iOS flat vs liquidGlass tags side by side on a colorful page](assets/ios-tag-liquid-glass-flat-vs-glass-colorful-light.png)

Flat vs `liquidGlass` over a colorful gradient, radius 1000 and radius 8 (`testFlatAndLiquidGlassTagsSideBySide`); the middle tag of each row is selected.

![iOS contact tag editor (Edit Tags) with selected tags, light and dark](assets/ios-contact-tag-editor-liquid-glass-selected.png)

Contact tag editor (Swift Example, `-CYLExampleScreen editor` and `editor-created`): selected tags (Book Club, Family, College Classmates; `ios` after Create) are green glass tags. Dark mode shows low contrast on the selected tags' green text (observation, not fixed here).
## 已完成（2026-11-24，`feat/harmony`）：iOS 27.2 模拟器上的示例主页面（当前依赖版本） / DONE (2026-11-24, `feat/harmony`): Example main screens on the iOS 27.2 simulator (current pins)

| 中文 | English |
|:---|:---|
| **平台：** iOS，iPhone 18 Pro 模拟器 “CYL cm-harmony2”，iOS 27.2 \| 主机：macOS 27.3 \| Xcode 27.2 (27B52) \| 提交 [`4737201e`](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/4737201e4c5944046cd3f7090bf1731edd84ebf4)，CYLTabBarController `c4a1f8fd` \| 拍摄时间：2026-11-24 23:14–23:33 NZDT。 | **Platform:** iOS, iPhone 18 Pro simulator "CYL cm-harmony2", iOS 27.2 \| Host: macOS 27.3 \| Xcode 27.2 (27B52) \| commit [`4737201e`](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/4737201e4c5944046cd3f7090bf1731edd84ebf4), CYLTabBarController `c4a1f8fd` \| Taken: 2026-11-24 23:14-23:33 NZDT. |
| **结果：** Example 118 / 118、Example-Swift 23 / 23 单元测试通过；七个页面（场景一、场景二、样式、动效、加号按钮的查询筛选、Swift 示例的标签编辑器和样式）以 `-CYLExampleScreen` 启动并截图，无崩溃。截图保持原始像素。 | **Result:** Example 118 / 118 and Example-Swift 23 / 23 unit tests pass; seven screens (Scenario 1, Scenario 2, Styles, Animations, the plus button's query scenarios, the Swift example's tag editor and styles) launched with `-CYLExampleScreen` and photographed, no crash. Original pixels. |

![iOS 27.2, iPhone 18 Pro simulator: Example and Example-Swift main screens](assets/ios-27-2-iphone18pro-example-main-tabs.png)

## 已完成（2026-11-25，`feat/harmony`）：iOS 27.2 上 menu.riv 的 Loop 关闭 / 开启（CYLTabBarController `edeb11e6`） / DONE (2026-11-25, `feat/harmony`): menu.riv with Loop off / on on iOS 27.2 (CYLTabBarController `edeb11e6`)

| 中文 | English |
|:---|:---|
| **平台：** iOS，iPhone 18 Pro 模拟器 “CYL cm-harmony2”，iOS 27.2 \| 主机：macOS 27.3 \| Xcode 27.2 (27B52) \| 提交 [`f8a9a952`](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/f8a9a9529a3dd5281d0be93bcccba2ad6a3875eb)，CYLTabBarController `edeb11e6` \| 拍摄时间：2026-11-25 01:04 NZDT。 | **Platform:** iOS, iPhone 18 Pro simulator "CYL cm-harmony2", iOS 27.2 \| Host: macOS 27.3 \| Xcode 27.2 (27B52) \| commit [`f8a9a952`](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/f8a9a9529a3dd5281d0be93bcccba2ad6a3875eb), CYLTabBarController `edeb11e6` \| Taken: 2026-11-25 01:04 NZDT. |
| **结果：** Loop 关闭，全部播放：Menu 标签只变化一次（X 变为汉堡，约 0.6 秒），随后静止（之后 11 秒内像素差 ≤ 0.1）；Loop 开启：Menu 约每 1.5 秒在 X 与汉堡之间交替，持续 19 秒。画面截自 60 fps 录屏，左列 Loop 关闭，右列 Loop 开启。 | **Result:** Loop off, Play all: the Menu tag changes once (X to hamburger, about 0.6 s) and then rests (pixel difference 0.1 or less for the next 11 s); Loop on: Menu alternates X and hamburger about every 1.5 s through 19 s. Frames cut from a 60 fps recording, left column Loop off, right column Loop on. |

![iOS 27.2: menu.riv with Loop off and Loop on after Play all](assets/ios-27-2-iphone18pro-menu-riv-loop-off-on.png)
