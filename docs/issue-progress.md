---
title: Issue 修复进度
date: 2026-11-09
updated: 2026-11-12
tags: [issues, ui, cocoapods, progress]
---

# Issue 修复进度

本表记录全部 issue，包括非 UI 问题。分数表示问题的修复及验证程度，并非代码完成比例；
100 分要求相关场景验证通过。尚未验证的修改不计为完全修复。每次提交修复后，
在本表追加提交链接并重新评估；不能复现或缺少验证时说明原因。

2026-11-11 复评：GitHub CI（`macos-26` runner，默认 Xcode 26.x）在 [ff35b27](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/ff35b27) 上全部通过——`pod lib lint`、库的构建与静态分析（库源码有警告即失败）、四组单元测试（menu、tag、example、swift；示例与其测试已全部改写为 Swift）以及 46 张示例截图。下表中“未能构建/测试”的扣分据此更新。

| 存在的 issue | 修复 commit 地址 | 评估是否修复 |
| --- | --- | --- |
| [#13 复用后 cell 重叠](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/13) | [c5f4f01](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/c5f4f016ff9158e09070bc7dff2ba51ed2fd9c8b)、[107b898](https://github.com/dennisxiaoding/CollectionViewClassifyMenu/commit/107b898e582513697c7c513a8555f81d5bc5f8b4)、[977398d](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/977398d6c5881496802b29689c21fdfca34b7e57)、[3ad4953](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/3ad49531ca67e5f12253603e976b46526570295d)、[84f44be](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/84f44beb5144e77ec2297659d7e4e00e12a23eb2) | **90/100**：dennis 方案仅限制单选宽度，结合属性副本、多选宽度及复用修复；两套菜单的演示条目均追加 emoji 和长文字，已验证滚动复用、展开、折叠和 320/390 pt 宽度。组件化后重新验证 TagCollectionView 的长文字。尚未覆盖所有设备和字体设置。 |
| [#12 layout attributes 被修改](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/12) | [c5f4f01](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/c5f4f016ff9158e09070bc7dff2ba51ed2fd9c8b) | **90/100**：布局返回属性副本，测试修改返回值后再次读取不受影响；尚未覆盖所有自定义布局和动态尺寸场景。 |
| [#11 CocoaPods 支持](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/11) | [84f44be](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/84f44beb5144e77ec2297659d7e4e00e12a23eb2)、[32720b0](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/32720b0352a0ab93fb5722e711e9954356b63624)、[ff35b27](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/ff35b27) | 原 **75/100**：84f44be 提供 iOS 15 podspec、资源 bundle、协议化接口和两个示例的本地 Pod 集成，README 说明通过 Git 分支引入；32720b0 替换 iOS 15 已弃用的按钮 edge insets、`adjustsImageWhenHighlighted` 和旧绘图 API，消除已知的 lint 弃用警告来源，并补充按钮布局测试。2026-11-11：CI 在 [ff35b27](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/ff35b27) 上 `pod lib lint` 与库的构建/分析（无警告）通过，三个示例工程以本地 Pod 集成并通过测试。**85/100**：仍未发布到 CocoaPods trunk，也没有对应 Git tag。 |
| [#9 标签太多时卡顿](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/9) | [c5f4f01](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/c5f4f016ff9158e09070bc7dff2ba51ed2fd9c8b)、[84f44be](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/84f44beb5144e77ec2297659d7e4e00e12a23eb2) | **85/100**：两套标签布局均采用线性行计算；1,200 项测试验证读取次数，数据更新会使缓存失效。尚未在真机测量滚动帧率。 |
| [#8 布局算法复杂及 iOS 10 问题](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/8) | [c5f4f01](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/c5f4f016ff9158e09070bc7dff2ba51ed2fd9c8b)、[84f44be](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/84f44beb5144e77ec2297659d7e4e00e12a23eb2) | **80/100**：两套布局行计数改为单次遍历，测试长文本折叠和缓存失效；尚未改成 self-sizing。本项目最低版本现为 iOS 15，不再支持 iOS 10。 |
| [#7 3.5 英寸屏幕 header 溢出](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/7) | [c5f4f01](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/c5f4f016ff9158e09070bc7dff2ba51ed2fd9c8b)、[84f44be](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/84f44beb5144e77ec2297659d7e4e00e12a23eb2) | **90/100**：header 按容器宽度布局，测试 240、320、390 pt；iOS 15 不支持原 3.5 英寸设备，无法在原设备上验证。 |
| [#3 类似库参考](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/3) | 无 | 不适用：不是缺陷，是参考资料，issue 已关闭，无需修复。[component-architecture.md](component-architecture.md) 记录了本项目的封装取舍。 |
| [#2 编译报错](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/2) | [1e383ca](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/1e383cab8dca462773e0a04969b7aba67a99deef)、[ff35b27](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/ff35b27) | 原 **90/100**：历史提交已修正 block 参数中 `*` 的位置，issue 已关闭；现有代码不再包含该写法。2026-11-11：CI 在 [ff35b27](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/ff35b27) 上编译库与全部示例并通过测试，**95/100**；未在 Xcode 旧版本上复现原报错环境。 |
| [#1 复用后选择状态错误](https://github.com/ChenYilong/CollectionViewClassifyMenu/issues/1) | [c5f4f01](https://github.com/ChenYilong/CollectionViewClassifyMenu/commit/c5f4f016ff9158e09070bc7dff2ba51ed2fd9c8b) | **80/100**：已验证侧边栏选中后滚动复用仍保持状态；历史报告缺少具体复现步骤，其他选择组合未覆盖。 |

## 验证截图 / Screenshot evidence

以下截图来自 CI（`Example screenshots`，提交 `22370a8`，`macos-26`），对应表中的 issue：

| #13 / #1：长文字与 emoji 标签复用后不重叠、选中状态保持 | #13：多选后折叠的长文字标签 | #7：分组标题按容器宽度布局，右侧有宿主视图 | #9：大量标签滚动到末尾 |
| --- | --- | --- | --- |
| <img src="assets/classify-menu-filtered.png" width="200" alt="#13 / #1：长文字与 emoji 标签复用后不重叠、选中状态保持"> | <img src="assets/issue-13-collapsed-long-titles.png" width="200" alt="#13：多选后折叠的长文字标签"> | <img src="assets/issue-7-section-header-width.png" width="200" alt="#7：分组标题按容器宽度布局，右侧有宿主视图"> | <img src="assets/issue-9-many-tags.png" width="200" alt="#9：大量标签滚动到末尾"> |

## 待办 / TODO

2026-11-12 记录，分支 `claude/intelligent-curie-1etnx5`（[PR #15](https://github.com/ChenYilong/CollectionViewClassifyMenu/pull/15)）：

- TODO（合并）：PR #15 的 CI 全部通过后合并到 `master`。当前状态：本地 example 79、swift 19 个测试通过；
  CI 运行中。完成条件：`gh pr checks 15` 全部通过，查看 CI 截图，合并后在本表记录合并提交。
- TODO（依赖）：`Example/Podfile` 与 `Example-Swift/Podfile` 固定的 CYLTabBarController 提交落后于最新提交
  `0e69250`（`feat/cross-platform-components`，2026-11-12）。CI 的检查只警告，不失败。剩余工作：确认两次提交之间
  的改动后更新两个 `CYL_TAB_BAR`，`pod install` 并运行全部测试。
- TODO（Rive 资源）：`house.riv` 自带天空背景（`Rectangle-6`，紫色渐变）和灰色画板填充，在标签中显示为方形画面。
  来源（Design+Code 课程附件）没有许可文件，按 PR #22 的规则不能修改。剩余工作：换成有许可的房子动画
  （例如 rive-app 官方示例），或取得作者许可后把背景填充透明度设为 0，并在 `Animations/Rive/README.md` 记录。
- TODO（可读性）：最大辅助字号下，搜索栏输入框里的占位文字被缩小（搜索发现、热门搜索页面）。属于
  CYLSearchViewController 的 `CYLSearchBarView`：剩余工作是在那里让占位文字跟随字号或换行显示，再更新
  `CYL_SEARCH`。验证：`CYLSearchBarPlacementTests` 的最大字号截图。
- TODO（布局）：最大辅助字号下，图片标签的两个标签组位置固定，可能相互接触（组内不重叠）。剩余工作：按字号
  调整组的位置或允许拖开；验证：`CYLAndroidSampleAccessibilityTests` 的大字号截图。
- TODO（验证）：尚未在真机上用 VoiceOver、Voice Control、Switch Control 和 Accessibility Inspector 检查新增的
  无障碍操作（标签前移/后移、图片标签组、搜索栏）；目前由单元测试覆盖标签、操作和字号。
