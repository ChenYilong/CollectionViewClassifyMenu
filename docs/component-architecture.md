---
title: Component architecture and community review
date: 2026-11-10
updated: 2026-11-11
tags: [architecture, cocoapods, issues]
---

# Component architecture and community review

## aklee 封装思路 / Encapsulation

[b38bceba](https://github.com/aklee/CollectionViewClassifyMenu/commit/b38bceba34d76c56a1dc72a2c6e40bd0a611f3e0)
将标签布局、分组模型、cell 和 header 集中到独立示例中，便于复用界面和理解展开逻辑。
后续的 `TagView` 进一步提供可嵌入的视图。

原始提交仍将数据和行为绑定在控制器、具体 `TagGroup`/`TagModel`、屏幕宽度、
主 bundle 与日志输出中；它不是数据源可替换的 Pod。旧行计数反复扫描和复制数组，
数据改变后缓存也可能过期。组件现在由 `CYLMenuDataSource` 和 `CYLMenuDelegate`
连接宿主：两个示例提供自己的数据，选择和持久化由宿主负责。资源放在独立 bundle；
`TagView` 支持代码和 XIB 初始化。旧公开模型和接口仍可用于兼容。

The original change usefully grouped tag views, cells and models, but tied
data, screen geometry and callbacks to the implementation. The current Pod
inverts that dependency through host-owned protocols and keeps sample data and
persistence in the demos.

## 低耦合接口 / Decoupled API (CYLTagListView)

旧控制器把图片、分组图标、选择规则、折叠方式和尺寸写死在实现里，宿主只能改源码。
新增的 `CYLTagListView` 只负责布局、折叠和选择状态，其余全部交给宿主：

- 数据：`CYLMenuDataSource` 新增标签图标、分组图标、分组标题右侧视图和禁用状态。
- 行为：`CYLMenuDelegate` 新增拦截选择、取消选中、展开/折叠和内容高度变化回调。
- 外观：`CYLMenuStyle` 统一描述字体（含 Dynamic Type 上限）、颜色、边框、圆角、间距和高度；
  视图持有样式副本，宿主修改原对象不会意外影响已显示的菜单。
- 选择：`CYLMenuSelectionMode`（无 / 单选 / 多选）、`allowsEmptySelection` 和互斥项；
  代码修改选择不触发回调，与 UIKit 惯例一致。
- 折叠：`CYLMenuFoldStyle`（标题按钮、底部箭头、仅截断预览）与 `defaultVisibleRows`。
- 嵌入：`contentHeight`、`intrinsicContentSize`、`heightThatFitsWidth:` 和 `scrollEnabled`，
  可放进表头、Stack View 或 Auto Layout。

行计算与旧组件相同，按实际容器宽度单次遍历；宽度或文字大小变化时重新测量。
`Example/` 通过 Podfile 以本地路径集成核心库，用这些接口实现 README 的两个场景；
`CYLExampleMenuSource` 演示宿主如何把自己的模型转成数据源。

## Swift 示例与 Swift 友好的核心 / Swift examples, Swift-friendly core

所有示例（`Example/`、`Example-Swift/`、根目录工程的演示 App `CYLClassifyMenuDemo`、`TagCollectionView` 演示）及其测试均为 Swift；
核心库保持 Objective-C，只通过 Swift 标注适配 Swift 调用（`NS_SWIFT_NAME`、字符串字面量形式的 `swift_name`、`cyl_` 方法的
`cylXxx` 版本），从不修改 Objective-C 接口。例如 `+[CYLTagView tagView]` 在 Swift 中为 `makeTagView()`，
`CYLMenuLocalizedString` 宏另有 Swift 可调用的同名函数。公开头文件的多行注释统一为 `/*! … */` 文档注释块
（`scripts/check-doc-comments.py`），Xcode 快速帮助与 Swift 接口都能显示。
The examples are all Swift; the core stays Objective-C and only gains Swift annotations next to its public
declarations, so Objective-C callers see no change.

不兼容修改：移除 `menuItemHasImageAtIndexPath:`，改用 `menuImageForItemAtIndexPath:`；
`CYLClassifyMenuViewController` 的分组图标改由 `menuImageForSection:` 提供。

## 社区提交 / Community commits

- [ce86ea2](https://github.com/XIAODINGPA/CollectionViewClassifyMenu/commit/ce86ea2bedce65c89344ebb6933bb5cf01cbab82)
  已在当前历史中。其单行累计宽度思路简化了旧算法，但 `<=` 会在间距恰好相等时过早换行，
  且后续行仍反复扫描。现有实现一次遍历所有行，按实际可用宽度计算。
- `izhangmi`、`NSIRLConnection` 和 `XIAODINGPA` 已有分支提交均已在本仓库历史中；
  `jouns/CollectionViewClassifyMenu` 为空仓库，没有可合并的分支。
- `SecondShuo/CollectionViewClassifyMenu-master` 的唯一提交是无共同祖先的旧项目快照，
  源码与本仓库历史快照实质相同，仅有空行和文件权限差异，还包含 Xcode 个人状态。
  已通过 [922cd7f](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/922cd7fc880c1a21d8275a4b1ce272ca587f079e)
  合并其历史，同时保留现有代码和修复，未重新引入旧代码或个人状态。

## 验证边界 / Validation limits

- 行布局与复用对应 [#8](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/8)、
  [#9](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/9) 和
  [#13](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/13)；
  section header 宽度对应 [#7](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/7)。
- 演示和测试覆盖 320/390 pt、长文本及 emoji、复用和外部数据源，以及 Dynamic Type 字号缩放、
  无障碍元素（标签、特征、提示与固定的 `accessibilityIdentifier`）；并未覆盖所有真机、旋转，
  也没有在设备上用 VoiceOver 实际走查。
- iOS 15 已弃用的按钮 edge insets、`adjustsImageWhenHighlighted` 和
  `UIGraphicsBeginImageContext` 已在 [32720b0](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/32720b0352a0ab93fb5722e711e9954356b63624) 中替换；
  2026-11-11 的 CI（[ff35b27](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/ff35b27)，`macos-26`）中
  `pod lib lint` 与库的构建/静态分析（有警告即失败）均已通过。
- 历史 3.5 英寸设备不支持项目现有的 iOS 15 最低版本，因此不能在原设备上复验 #7。
