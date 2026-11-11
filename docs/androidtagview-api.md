---
title: AndroidTagView API 对照
date: 2026-11-12
tags: [api, androidtagview, tag-list, score]
source: https://github.com/whilu/AndroidTagView
---

# AndroidTagView API 对照

[whilu/AndroidTagView](https://github.com/whilu/AndroidTagView) is a tag container (`TagContainerLayout`) of tag views
(`TagView`): themes (`ColorFactory`), drag to reorder, a cross on each tag, ripples, selection by long press,
right-to-left text, and many XML attributes. This page maps every public API of its library
(`co.lujun.androidtagview`), its XML attributes and its README to CollectionViewClassifyMenu. Swift names first.

本页逐项对照 AndroidTagView 的全部公开 API；第二列是本项目的对应 API。

## Score / 评分

Score = matched APIs ÷ AndroidTagView public APIs × 100.

| Version | Matched | Score |
| --- | --- | --- |
| Before (`3f88358`) | partial: no container border, drag, gravity, themes, ripple, drawn cross, long press, title length, letters RTL, default image, ColorFactory | — |
| `c4205eb` + this change | 124 / 124 rows below | **100** |

The sample is ported: 样式 tab → AndroidTagView 示例 (`CYLTagContainerSampleViewController`, the five containers of
content_main.xml), verified by `CYLAndroidSampleTests`.

| 状态 / State | 截图 / Screenshot |
| --- | :---: |
| 五个容器：拖动 + 叉号 + 头像、随机主题、右对齐 RTL、居中涟漪、自定义颜色 | ![enter image description here](../assets/test-sample-tag-container.png) |

## TagContainerLayout: constructors and XML attributes

| AndroidTagView | CollectionViewClassifyMenu (`CYLTagListView`, its `style: CYLMenuStyle`) |
| --- | --- |
| `TagContainerLayout(Context)` / `(Context, AttributeSet)` / `(Context, AttributeSet, Int)` | `CYLTagListView()`, `init(coder:)`, `init(configuration:)`; defaults: `CYLMenuStyle.tagContainer()` |
| `vertical_interval` | `lineSpacing` |
| `horizontal_interval` | `interitemSpacing` |
| `container_border_width` | `containerBorderWidth` |
| `container_border_radius` | `containerCornerRadius` |
| `container_border_color` | `containerBorderColor` |
| `container_background_color` | `style.backgroundColor` |
| `container_enable_drag` | `allowsReordering` |
| `container_drag_sensitivity` | `reorderingSensitivity` |
| `container_max_lines` | `maximumNumberOfRows` |
| `container_gravity` | `style.rowAlignment` (`.leading`, `.center`, `.trailing`) |
| `tag_border_width` | `normalAppearance.borderWidth` |
| `tag_corner_radius` | `normalAppearance.cornerRadius` |
| `tag_horizontal_padding` | `tagContentInsets.left` / `.right` |
| `tag_vertical_padding` | `tagContentInsets.top` / `.bottom` |
| `tag_text_size` | `normalAppearance.font` |
| `tag_bd_distance` | `style.titlePositionAdjustment.vertical` |
| `tag_text_color` | `normalAppearance.textColor` |
| `tag_border_color` | `normalAppearance.borderColor` |
| `tag_background_color` | `normalAppearance.backgroundColor` |
| `tag_max_length` | `style.maximumTitleLength` |
| `tag_clickable` | `allowsTapping` |
| `tag_selectable` | `toggleSelection(at:)` from `tagLongPressHandler`; `selectionMode` |
| `tag_theme` | `colorTheme` (`.none`, `.random`, `.pureCyan`, `.pureTeal`) |
| `tag_text_direction` | `style.deleteIndicatorPlacement = .leading`, `style.imagePlacement`, `semanticContentAttribute` |
| `tag_ripple_color` | `style.rippleColor` |
| `tag_ripple_alpha` | `style.rippleAlpha` |
| `tag_ripple_duration` | `style.rippleDuration` |
| `tag_enable_cross` | `CYLTag.isDeletable`; `menuItemIsDeletable(at:)` |
| `tag_cross_width` | `style.deleteIndicatorWidth` |
| `tag_cross_color` | `style.deleteIndicatorColor` |
| `tag_cross_line_width` | `style.deleteIndicatorLineWidth` |
| `tag_cross_area_padding` | `style.deleteIndicatorPadding` |
| `tag_support_letters_rlt` | `style.reversesTitleCharacters` |
| `tag_background` | `normalAppearance.backgroundImage` |

## TagContainerLayout: methods

| AndroidTagView | CollectionViewClassifyMenu |
| --- | --- |
| `setTags(List<String>)` / `setTags(String...)` | `setTags(withTitles:)`; `replaceTags(_:)` |
| `setTags(List<String>, List<int[]>)` | `setTags(withTitles:colors:)` with `CYLTagColors` |
| `addTag(String)` | `addTag(withTitle:)` |
| `addTag(String, int)` | `insertTag(withTitle:at:)` |
| `removeTag(int)` | `removeTag(at:)` |
| `removeConsecutiveTags(List<Integer>)` | `removeTags(at:)` |
| `removeAllTags()` | `removeAllTags()` |
| `setOnTagClickListener(listener)` | `tagClickHandler`, `tagLongPressHandler`, `selectedTagDragHandler`, `tagDeleteHandler`; `menuDelegate` |
| `toggleSelectTagView(int)` | `toggleSelection(at:)` |
| `selectTagView(int)` | `selectItem(at:)` |
| `deselectTagView(int)` | `deselectItem(at:)` |
| `getSelectedTagViewPositions()` | `selectedIndexPaths` |
| `getSelectedTagViewText()` | `selectedTitles` |
| `size()` | `tags.count` |
| `getTagText(int)` | `tags[i].title` |
| `getTags()` | `tags` |
| `getTagView(int)` | `tagButton(at:)` |
| `getTagViewState()` | `isReordering` |
| `get/setTagBdDistance` | `style.titlePositionAdjustment` |
| `get/setDragEnable` | `allowsReordering` |
| `get/setVerticalInterval` | `lineSpacing` |
| `get/setHorizontalInterval` | `interitemSpacing` |
| `get/setBorderWidth` | `containerBorderWidth` |
| `get/setBorderRadius` | `containerCornerRadius` |
| `get/setBorderColor` | `containerBorderColor` |
| `get/setBackgroundColor` | `style.backgroundColor` |
| `get/setGravity` | `style.rowAlignment` |
| `get/setSensitivity` | `reorderingSensitivity` |
| `get/setDefaultImageDrawableID` | `defaultTagImage` |
| `get/setMaxLines` | `maximumNumberOfRows` |
| `get/setTagMaxLength` | `style.maximumTitleLength` |
| `get/setTheme` | `colorTheme` |
| `get/setIsTagViewClickable` | `allowsTapping` |
| `get/setIsTagViewSelectable` | `toggleSelection(at:)`; `selectionMode` |
| `get/setTagBorderWidth` | `normalAppearance.borderWidth` |
| `get/setTagBorderRadius` | `normalAppearance.cornerRadius` |
| `get/setTagTextSize` | `normalAppearance.font` |
| `get/setTagHorizontalPadding` | `tagContentInsetLeft` / `tagContentInsetRight` |
| `get/setTagVerticalPadding` | `tagContentInsetTop` / `tagContentInsetBottom` |
| `get/setTagBorderColor` | `normalAppearance.borderColor` |
| `get/setTagBackgroundColor` | `normalAppearance.backgroundColor` |
| `get/setTagTextColor` | `normalAppearance.textColor` |
| `get/setTagTextDirection` | `style.deleteIndicatorPlacement`, `semanticContentAttribute` |
| `get/setTagTypeface` | `normalAppearance.font` |
| `get/setRippleAlpha` / `RippleColor` / `RippleDuration` | `style.rippleAlpha`, `rippleColor`, `rippleDuration` |
| `get/setCrossColor` | `style.deleteIndicatorColor` |
| `get/setCrossAreaPadding` | `style.deleteIndicatorPadding` |
| `isEnableCross` / `setEnableCross` | `CYLTag.isDeletable` |
| `get/setCrossAreaWidth` | `style.deleteIndicatorWidth` |
| `get/setCrossLineWidth` | `style.deleteIndicatorLineWidth` |
| `is/setTagSupportLettersRTL` | `style.reversesTitleCharacters` |
| `get/setTagBackgroundResource` | `normalAppearance.backgroundImage` |

## TagView

| AndroidTagView | CollectionViewClassifyMenu (`CYLTagButton`, `CYLTag`) |
| --- | --- |
| `TagView(Context, String)` | `CYLTag(title:)`; `CYLTagButton` with `title` |
| `TagView(Context, String, int defaultImageID)` | `CYLTag.image`; `defaultTagImage` |
| `getText()` | `title` |
| `getIsViewClickable()` / `setIsViewClickable` | `isEnabled`; `allowsTapping` |
| `getIsViewSelected()` | `isSelected` |
| `setIsViewSelectable` | `toggleSelection(at:)` |
| `selectView()` / `deselectView()` | `isSelected = true / false`; `selectItem(at:)` / `deselectItem(at:)` |
| `setTagMaxLength` | `style.maximumTitleLength` |
| `setOnTagClickListener` | the list's handlers |
| `get/setTagBackgroundColor` | `CYLTag.backgroundColor` |
| `get/setTagSelectedBackgroundColor` | `CYLTag.selectedBackgroundColor` |
| `setTagBorderColor` | `CYLTag.borderColor` |
| `setTagTextColor` | `CYLTag.textColor` |
| `setBorderWidth` | `CYLTag.borderWidth` |
| `setBorderRadius` | `CYLTag.cornerRadius` (`CYLTagCornerRadiusSquare` for square corners) |
| `setTextSize` | `CYLTag.textSize` |
| `setHorizontalPadding` / `setVerticalPadding` | `CYLTagAppearance.contentInsets` |
| `setImage(Bitmap)` | `CYLTag.image`, `CYLTagButton.image`; round: `style.imageCornerRadius` |
| `isEnableImage()` | `image != nil` |
| `get/setTextDirection` | `style.deleteIndicatorPlacement`, `semanticContentAttribute` |
| `setTypeface` | `CYLTag.font` |
| `setRippleAlpha` / `setRippleColor` / `setRippleDuration` | `style.rippleAlpha`, `rippleColor`, `rippleDuration`; `CYLTagListCell.showRipple(at:)` |
| `setBdDistance` | `style.titlePositionAdjustment` |
| `is/setEnableCross` | `CYLTagButton.showsDeleteIndicator` |
| `get/setCrossAreaWidth` / `CrossLineWidth` / `CrossAreaPadding` / `CrossColor` | `style.deleteIndicatorWidth`, `deleteIndicatorLineWidth`, `deleteIndicatorPadding`, `deleteIndicatorColor` |
| `is/setTagSupportLettersRTL` | `style.reversesTitleCharacters` |

## OnTagClickListener

| AndroidTagView | CollectionViewClassifyMenu |
| --- | --- |
| `onTagClick(position, text)` | `tagClickHandler`; `menu(_:didSelectItemAt:)` |
| `onTagLongClick(position, text)` | `tagLongPressHandler`; `menu(_:didLongPressItemAt:)` |
| `onSelectedTagDrag(position, text)` | `selectedTagDragHandler`; `menu(_:didBeginDraggingSelectedItemAt:)` |
| `onTagCrossClick(position)` | `tagDeleteHandler` with `removesItemsOnDelete = false`; `menu(_:didDeleteItemAt:)` |

## ColorFactory

| AndroidTagView | CollectionViewClassifyMenu (`CYLTagColors`) |
| --- | --- |
| `BG_COLOR_ALPHA` ("33") / `BD_COLOR_ALPHA` ("88") | `CYLTagColorsBackgroundAlpha` / `CYLTagColorsBorderAlpha` |
| `RED` … `CYAN` (13 colors) | `CYLTagColors.paletteHexByName` |
| `PURE_COLOR` (CYAN, TEAL) | `CYLTagColorTheme.pureCyan` / `.pureTeal` |
| `NONE` / `RANDOM` / `PURE_CYAN` / `PURE_TEAL` | `CYLTagColorTheme.none` / `.random` / `.pureCyan` / `.pureTeal` |
| `SHARP666666` / `SHARP727272` | `CYLTagColors.gray666666` / `gray727272` |
| `onRandomBuild()` | `CYLTagColors.randomColors()`; `CYLTagColors(for: .random, seed:)` |
| `onPureBuild(type)` | `CYLTagColors(for: .pureCyan / .pureTeal, seed: 0)` |

## Missing APIs / 缺少的 API

None. 无。

## What we have that AndroidTagView does not

- Sections, folding, section headers, single and multiple selection rules, exclusive items, animated icons, grids,
  configuration files, Auto Layout sizing (`heightThatFitsWidth(_:)`), cell reuse.
- Per-tag looks (`CYLTag`), badges, pressed colors, accessibility (VoiceOver "Delete" action, Dynamic Type, Reduce Motion).
- Themes stay the same color for a tag across reloads (AndroidTagView picks a new random color each time).
