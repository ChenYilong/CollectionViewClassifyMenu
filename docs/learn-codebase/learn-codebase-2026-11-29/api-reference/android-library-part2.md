# android: library (part 2 of 4)

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLImageTagGroupView.kt

- `enum class CYLImageTagDirection` (L30)
  `CYLImageTagDirection`: where a tag sits around its group's dot (TagViewGroup's DIRECTION).

- `fun CYLImageTagDirectionNext(direction: CYLImageTagDirection): CYLImageTagDirection` (L47)
  `CYLImageTagDirectionNext`: the next direction, the last one (and Center) wrapping to LeftCenter.

- `const val CYLImageTagGroupDefaultCircleRadius = 8f` (L57)
  The default radius of a group's dot, dp.

- `const val CYLImageTagGroupDefaultCircleInnerRadius = 4f` (L61)
  The default radius of the dot's center, dp.

- `const val CYLImageTagGroupDefaultVerticalDistance = 28f` (L65)
  The default vertical distance of a tag from the dot, dp.

- `const val CYLImageTagGroupDefaultTiltDistance = 20f` (L69)
  The default distance of a slanted ("straight") tag, dp.

- `const val CYLImageTagGroupDefaultLineWidth = 1f` (L73)
  The default width of the lines, dp.

- `const val CYLImageTagGroupMaximumTagCount = 6` (L77)
  At most this many tags in a group.

- `const val CYLImageTagGroupDefaultRippleMaxRadius = 20f` (L81)
  The default radius of the ripple, dp.

- `const val CYLImageTagGroupKeyCircleRadius = "circleRadius"` (L85)
  Animation key of `circleRadius`.

- `const val CYLImageTagGroupKeyCircleInnerRadius = "circleInnerRadius"` (L89)
  Animation key of `circleInnerRadius`.

- `const val CYLImageTagGroupKeyLinesProgress = "linesProgress"` (L93)
  Animation key of `linesProgress`.

- `const val CYLImageTagGroupKeyTagAlpha = "tagAlpha"` (L97)
  Animation key of `tagAlpha`.

- `interface CYLImageTagItem` (L102)
  `CYLImageTagItem`: a view shown as a tag of a group.

- `var tagDirection: CYLImageTagDirection` (L106)
  Where the view sits around the dot.

- `class CYLImageTag(var title: String, var direction: CYLImageTagDirection)` (L112)
  `CYLImageTag`: a tag of a picture: its title, direction, link and user info.

- `var link: String? = null` (L116)
  A link the tag opens, if any.

- `var userInfo: Any? = null` (L120)
  Anything the app attaches.

- `fun copy(): CYLImageTag = CYLImageTag(title, direction).also` (L125)
  `-copy`.

- `fun tagWithTitle(title: String?, direction: CYLImageTagDirection) = CYLImageTag(title ?: "", direction)` (L135)
  `+tagWithTitle:direction:`.

- `class CYLImageTagGroup(var tags: List<CYLImageTag>, var percentPosition: CYLPoint)` (L142)
  `CYLImageTagGroup`: the tags around one dot, at a position given in fractions of the picture (0…1).

- `fun copy(): CYLImageTagGroup = CYLImageTagGroup(tags.map { it.copy() }, percentPosition)` (L146)
  `-copy`: the tags are copied too.

- `fun groupWithTags(tags: List<CYLImageTag>?, percentPosition: CYLPoint) = CYLImageTagGroup(tags ?: emptyList(), percentPosition)` (L153)
  `+groupWithTags:percentPosition:`.

- `fun defaultDirectionsForTagCount(count: Int): List<CYLImageTagDirection> = when (count)` (L159)
  `+defaultDirectionsForTagCount:`: right first (top, center, bottom), then left, at most six.

- `class CYLImageTagLabel @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : androidx.appcompat.widget.AppCompatTextView(context, attrs), CYLImageTagItem` (L174)
  `CYLImageTagLabel`: the default tag view: white 13 sp text with a shadow, inside `contentInsets`.

- `var contentInsets: CYLEdgeInsets = CYLEdgeInsets(4f, 12f, 4f, 12f)` (L180)
  The space around the text, dp (4, 12, 4, 12 by default).

- `class CYLImageTagRippleView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : View(context, attrs), CYLImageTagItem` (L205)
  `CYLImageTagRippleView`: a circle growing and fading from the dot, repeated every second (not with Reduce Motion).

- `var maximumRadius: Float = CYLImageTagGroupDefaultRippleMaxRadius` (L211)
  The radius the ripple grows to, dp.

- `var startAlpha: Float = 100f / 255f` (L220)
  The opacity the ripple starts with (100 / 255 by default).

- `var color: Int = Color.WHITE` (L225)
  The ripple's color (white by default).

- `fun startAnimating()` (L258)
  `-startAnimating`.

- `fun stopAnimating()` (L276)
  `-stopAnimating`.

- `val isAnimating: Boolean get() = animator?.isRunning == true` (L286)
  Whether the ripple is animating.

- `interface CYLImageTagGroupViewDataSource` (L299)
  `CYLImageTagGroupViewDataSource`: custom tag views instead of `tags`.

- `fun numberOfTagsInGroupView(groupView: CYLImageTagGroupView): Int` (L303)
  The number of tags (at most `CYLImageTagGroupMaximumTagCount` are shown).

- `fun groupViewViewForTagAtIndex(groupView: CYLImageTagGroupView, index: Int): View?` (L308)
  The view of a tag.

- `interface CYLImageTagGroupViewDelegate` (L314)
  `CYLImageTagGroupViewDelegate`: taps, long press and drags of a group; every method is optional.

- `fun groupViewDidTapCircle(groupView: CYLImageTagGroupView) {}` (L318)
  `-groupViewDidTapCircle:`.

- `fun groupViewDidTapTagAtIndex(groupView: CYLImageTagGroupView, index: Int) {}` (L323)
  `-groupView:didTapTagAtIndex:`.

- `fun groupViewDidLongPress(groupView: CYLImageTagGroupView) {}` (L328)
  `-groupViewDidLongPress:`.

- `fun groupViewDidDragToPercentPosition(groupView: CYLImageTagGroupView, percentPosition: CYLPoint) {}` (L333)
  `-groupView:didDragToPercentPosition:`.

- `fun handlesLongPress(): Boolean = false` (L338)
  Whether `groupViewDidLongPress` is implemented (respondsToSelector on iOS).

- `class CYLImageTagGroupView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : ViewGroup(context, attrs)` (L347)
  `CYLImageTagGroupView`: a dot on a picture with up to six tags around it, joined by lines (TagViewGroup): position in
  fractions of the view, ripple, show / hide animations, tap, long press and drag, and accessibility (the dot is an
  element with move actions). Lengths are dp.

- `var percentPosition: CYLPoint = CYLPoint(0.5f, 0.5f)` (L372)
  The dot's position in fractions of the view, each clamped to 0…1.

- `fun setPercentX(percentX: Float, percentY: Float)` (L381)
  `-setPercentX:percentY:`.

- `var centerPoint: CYLPoint = CYLPoint()` (L388)
  The dot's center after layout, dp.

- `var displayOffset: CYLPoint = CYLPoint()` (L394)
  An offset added to the dot (the picture view moves groups apart with it), dp.

- `val occupiedFrame: CYLRect` (L406)
  The dot and the tags' frames together, dp.

- `var tags: List<CYLImageTag> = emptyList()` (L425)
  The tags (a copy); setting them rebuilds the tag views.

- `val tagViews: List<View> get() = itemViews.toList()` (L436)
  The tag views, in order.

- `var tagLabelConfiguration: ((label: CYLImageTagLabel, tag: CYLImageTag) -> Unit)? = null` (L441)
  Called for every default label, to style it.

- `fun reloadData()` (L446)
  `-reloadData`: rebuilds the tag views from the data source or from `tags`.

- `var linesProgress: Float = 1f` (L509)
  How much of each line is drawn, 0…1.

- `var tagAlpha: Float = 1f` (L518)
  The tags' opacity, 0…1.

- `fun animateValueForKey(key: String, values: List<Float>, duration: Double, completion: (() -> Unit)?)` (L539)
  `-animateValueForKey:values:duration:completion:`: animates one of the `CYLImageTagGroupKey…` values through
  `values` (eased out); with Reduce Motion, or no duration, it jumps to the last value.

- `var isGroupHidden: Boolean = false` (L581)
  Whether the group is hidden by `hideAnimated`.

- `val groupHidden: Boolean get() = isGroupHidden` (L587)
  `groupHidden`.

- `fun showAnimated(animated: Boolean, completion: (() -> Unit)?)` (L595)
  `-showAnimated:completion:`: the dot bounces, the lines draw, then the tags fade in.

- `fun hideAnimated(animated: Boolean, completion: (() -> Unit)?)` (L618)
  `-hideAnimated:completion:`: the dot bounces, the tags fade and the lines retract, then the group hides.

- `val isDraggable: Boolean get() = draggable` (L653)
  `isDraggable`.

- `val circleAccessibilityElement: View = View(context).apply` (L660)
  The dot as an accessibility element ("Tag group: …"), with the long press and move actions.

- `var accessibilityMoveStep: Float = 0.05f` (L681)
  How far a move action moves the dot, in fractions of the view (0.05).

- `fun tagSpaceUsed(): CYLEdgeInsets = tagSpaceUsedForSizes(itemSizes())` (L774)
  `-tagSpaceUsed`: how far the tags reach from the dot on each side, dp.

- `fun originForTagOfSize(size: CYLSize, direction: CYLImageTagDirection): CYLPoint` (L779)
  `-originForTagOfSize:direction:`: the top-left corner of a tag of `size` in `direction`, dp.

- `fun layoutGroup()` (L812)
  Lays the dot and the tags out now (`-layoutIfNeeded` on iOS); the picture view calls it to move groups apart.

- `fun frameOfTagView(view: View): CYLRect? = frames[view]` (L846)
  The frame of a tag view after layout, dp.

- `fun pointInside(point: CYLPoint): Boolean = !isGroupHidden && (isPointOnCircle(point) || tagIndexAt(point) >= 0)` (L907)
  `-pointInside:withEvent:`: only the dot and the tags take touches (dp).

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLImageTagView.kt

- `class CYLImageTagView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : ViewGroup(context, attrs)` (L18)
  `CYLImageTagView`: a picture with tag groups (TagViewGroup's sample): groups from models, edit mode (drag the dots,
  tap a tag to turn it), show / hide all groups, groups moved apart vertically when they would overlap, and event
  handlers. Lengths are dp.

- `val imageView: ImageView = ImageView(context).apply` (L25)
  The picture, filling the view (center crop).

- `var image: Drawable?` (L44)
  The picture (`imageView`'s drawable).

- `var tagGroups: List<CYLImageTagGroup>` (L54)
  The groups (copies); setting them replaces every group.

- `fun addTagGroup(group: CYLImageTagGroup)` (L64)
  `-addTagGroup:`: adds a copy of the group and its view.

- `fun removeTagGroupAtIndex(index: Int)` (L83)
  `-removeTagGroupAtIndex:`.

- `fun removeAllTagGroups()` (L92)
  `-removeAllTagGroups`.

- `val groupViews: List<CYLImageTagGroupView> get() = views.toList()` (L101)
  The group views, in order.

- `var editing: Boolean = false` (L106)
  Edit mode: dots can be dragged and a tap turns a tag; no ripple.

- `val isEditing: Boolean get() = editing` (L120)
  `isEditing`.

- `fun toggleTagGroupsAnimated(animated: Boolean)` (L125)
  `-toggleTagGroupsAnimated:`: shows hidden groups and hides shown ones.

- `var groupConfiguration: ((groupView: CYLImageTagGroupView, groupIndex: Int) -> Unit)? = null` (L134)
  Called for every new group view, to style it.

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLMenuColor.kt

- `fun CYLMenuColorFromString(string: String?): Int?` (L9)
  `CYLMenuColorFromString`: "#RGB", "#RRGGBB", "#RRGGBBAA" (alpha last, as on iOS), or the name of a UIColor class
  property ("systemBlue", "systemBlueColor", "red"…); null when it is none of them.

- `fun CYLMenuColorLuminance(color: Int): Float?` (L27)
  The relative luminance (WCAG 2.x, 0 black ... 1 white) of an opaque ARGB color; null when the color is not opaque
  (transparent or translucent: what is behind it is not known).

- `internal fun CYLMenuRelativeLuminance(red: Double, green: Double, blue: Double): Double` (L35)
  The WCAG relative luminance of an opaque sRGB color given as components in 0...1 (iOS: `CYLTintContrast.relativeLuminance(red:green:blue:)`).

- `const val CYLTintLuminanceThreshold: Float = 0.179f` (L45)
  The relative luminance above which a background counts as light, so that the default tint on it is black: 0.179 is where
  black and white have the same contrast ratio against it.

- `internal val CYLUIColorNames: Map<String, Int> = mapOf(` (L57)
  The UIColor class properties a configuration may name, in their light appearance.

- `internal object CYLSystemColors` (L78)
  The list's own tint and the tag defaults in dark mode, as iOS does with dynamic colors (`UIColor.label`,
  `secondarySystemBackground`): resolved from the context when the host left a color unset.

- `fun isNight(context: android.content.Context): Boolean =` (L80)
  Whether the context is in night mode (the system's dark theme or the app's).

- `fun primary(context: android.content.Context): Int` (L93)
  The one tint of the list's texts and icons: the theme's `textColorPrimary` (what `UIColor.label` is on iOS), else white in
  night mode and black otherwise. The theme's color counts only where it agrees with the mode: a host theme that is not a
  DayNight theme keeps a DARK `textColorPrimary` in night mode (and a light one in day mode), which would put dark text on dark
  glass; there the label color of the mode (white in night mode, black otherwise) is used.

- `fun systemBackground(context: android.content.Context): Int = if (isNight(context)) Color.BLACK else Color.WHITE` (L112)
  The system background (iOS `systemBackground`): white in light mode, black in dark mode; the default list background.

- `const val SECONDARY_BACKGROUND_DARK: Int = -0xe3e3e2 // 0xFF1C1C1E` (L115)
  The secondary system background of dark mode (iOS #1C1C1E), the default tag background there.

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLMenuDataSource.kt

- `enum class CYLMenuItemType { CYLMenuItemTypeTag, CYLMenuItemTypeCreate }` (L8)
  `CYLMenuItemType`: a tag, or the "+ New tag" item that asks for a name.

- `interface CYLMenuDataSource` (L14)
  `CYLMenuDataSource`: the sections and items of a tag list. The four required methods are abstract; the optional
  ones have the iOS default behavior (as when a data source does not implement them).

- `fun menuSubtitleForItemAtIndexPath(indexPath: CYLIndexPath): String? = null` (L28)
  The item's subtitle, shown in a callout with an arrow on a long press when the list's `longPressAction` includes
  `CYLTagLongPressActions.callout` (a longer description of a short title). null or empty: none.

- `fun menuMoveItemAtIndexPath(sourceIndexPath: CYLIndexPath, toIndexPath: CYLIndexPath) {}` (L45)
  Optional on iOS: a list may only reorder items when its data source moves them.

- `fun supportsMovingItems(): Boolean = false` (L48)
  Whether `menuMoveItemAtIndexPath` is implemented (`respondsToSelector:` on iOS).

- `fun decidesDeletableItems(): Boolean = false` (L54)
  Whether `menuItemIsDeletableAtIndexPath` is implemented (`respondsToSelector:` on iOS). In `CYLTagListView`'s
  editing mode every item of an editable section is deletable unless the data source decides (then its answer).

- `fun menuSectionAllowsEditing(section: Int): Boolean = true` (L60)
  `menuSectionAllowsEditing:`: whether a section takes part in `CYLTagListView`'s editing mode (delete indicators,
  reordering); true by default.

- `fun menuCacheKeyForSection(section: Int): String? = null` (L66)
  `menuCacheKeyForSection:`: the key `CYLTagListView` saves a section's titles under in its cache (`cachePolicy`),
  stable when sections come and go (e.g. "mine"); null (the default) uses the section's index.

- `fun menuIdentifierForItemAtIndexPath(indexPath: CYLIndexPath): String? = null` (L72)
  `menuIdentifierForItemAtIndexPath:`: the item's stable identifier (a database id), kept by `CYLTagListView`'s
  cache and sync so a reorder or a rename never loses what the item stands for; null (the default): its title.

- `fun menuRenameItemAtIndexPath(indexPath: CYLIndexPath, title: String) {}` (L80)
  `menuRenameItemAtIndexPath:toTitle:`: rename the item in your data. Implementing it (with `supportsRenamingItems`)
  shows `CYLTagListView`'s rename indicator before the delete indicator in editing mode; a tap fills the add control
  with the title, and its submit calls this, then the list reloads, saves its cache and calls
  `menuDidRenameItemAtIndexPath`.

- `fun supportsRenamingItems(): Boolean = false` (L83)
  Whether `menuRenameItemAtIndexPath` is implemented (`respondsToSelector:` on iOS).

- `fun menuShowsClearButtonForSection(section: Int): Boolean = false` (L90)
  `menuShowsClearButtonForSection:`: shows a clear button (the trash icon, `CYLMenuStyle.clearButtonImage`) at the
  trailing end of the section's header; a tap calls `menuDidTapClearButtonInSection` and
  `CYLTagListView.clearButtonHandler`. False by default.

- `interface CYLMenuDelegate` (L97)
  `CYLMenuDelegate`: selection, new items, folding, height, the More button, deletion, long press, reordering and
  dragging of a tag list. Every method is optional (no-op by default); `menu` is the list.

- `fun menuDidChangeReordering(menu: Any, reordering: Boolean) {}` (L109)
  `menuDidChangeReordering(_:reordering:)`: a drag (reordering) started (true) or ended (false: a drop or a
  cancelled touch), once per change, as the mini program's `reorderingchange`; a container turns its own scrolling
  off while it is true.

- `fun menuDidChangeSmearing(menu: Any, smearing: Boolean) {}` (L115)
  `menuDidChangeSmearing(_:smearing:)`: a word picker smear (`allowsSmearSelection`) started (true) or ended
  (false), once per change, as the mini program's `smearingchange`.

- `fun menuDidChangeEditing(menu: Any, editing: Boolean) {}` (L126)
  `menu:didChangeEditing:`: `CYLTagListView` entered (true) or left (false) editing mode (`setEditing`).

- `fun menuDidFinishEditingWithTitles(menu: Any, titles: Map<String, List<String>>) {}` (L132)
  `menu:didFinishEditingWithTitles:`: `CYLTagListView`'s editing ended; the edited sections' titles by cache key
  (`cacheKeyForSection`), in their new order, already saved to its cache: upload them to your server here.

- `fun menuDidFinishEditingWithItems(menu: Any, items: Map<String, List<CYLTagListCacheItem>>) {}` (L138)
  `menu:didFinishEditingWithItems:`: the same edited sections as items (stable identifier and title,
  `menuIdentifierForItemAtIndexPath`): upload these when your items have ids.

- `fun menuDidRenameItemAtIndexPath(menu: Any, indexPath: CYLIndexPath, title: String) {}` (L141)
  `menu:didRenameItemAtIndexPath:toTitle:`: the list renamed an item in editing mode, already saved to its cache.

- `fun menuDidTapClearButtonInSection(menu: Any, section: Int) {}` (L144)
  `menu:didTapClearButtonInSection:`: the section header's clear button was tapped: clear the section's data.

- `fun handlesLongPress(): Boolean = false` (L147)
  Whether the long press is handled (`respondsToSelector:` of `menu:didLongPressItemAtIndexPath:`).

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLMenuFoldControl.kt

- `enum class CYLMenuFoldControlPosition` (L6)
  `CYLMenuFoldControlPosition`: where a section's fold control sits.

- `enum class CYLMenuFoldControlContent` (L18)
  `CYLMenuFoldControlContent`: what a fold control shows. The raw order matches iOS: IconAndTitle 0, Title 1, Icon 2,
  TitleAndIcon 3 (title and icon ALWAYS: "More" + chevron folded, "Less" + the chevron turned 180 degrees expanded).

- `class CYLMenuFoldControl` (L29)
  `CYLMenuFoldControl`: the control that expands or collapses a folded section: its position, content, titles, image
  (a chevron by default, turned when expanded), color and font. `copy()` is NSCopying; equal controls compare equal.

- `var content: CYLMenuFoldControlContent = CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon` (L33)
  The chevron icon only, on every platform: the title ("More") is opt-in (`iconAndTitle`), as the header presets do.

- `var title: String?` (L40)
  null_resettable: "Expand" (localized) by default.

- `var collapseTitle: String?` (L45)
  null_resettable: "Collapse" (localized) by default.

- `var image: Drawable?` (L50)
  null_resettable: a chevron by default.

- `val usesDefaultImage: Boolean get() = _image == null` (L55)
  Whether `image` is the default chevron.

- `fun copy(): CYLMenuFoldControl = CYLMenuFoldControl().also` (L82)
  NSCopying.

- `fun foldControlWithPosition(position: CYLMenuFoldControlPosition, content: CYLMenuFoldControlContent) =` (L102)
  `+foldControlWithPosition:content:`.

- `fun noFoldControl() = foldControlWithPosition(CYLMenuFoldControlPosition.NONE, CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon)` (L110)
  `+noFoldControl`: no control, the section shows every item.

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLMenuIcons.kt

- `class CYLMenuIconDrawable(private val kind: Kind) : Drawable()` (L17)
  The core's default icons, drawn in code (SF Symbols on iOS): the fold chevron ("chevron.down"), the plus of the
  "+ New tag" item ("plus") and the More button ("ellipsis"). They draw in black and take the tint (`setColorFilter` / `setTint`) of the view.

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLMenuKeys.kt

- `const val kDataSourceSectionKey: String = "Items"` (L6)
  The keys of a classify-menu data source's dictionaries (CYLMenuKeys.h).

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLMenuResources.kt

- `object CYLMenuResources` (L12)
  The core's localized strings and images: the same `<language>.lproj/CYLClassifyMenu.strings` tables as iOS
  (`CYLClassifyMenuResources.bundle`), packaged as Java resources under `CYLClassifyMenuResources/`, so they load
  without a Context. `preferredLanguage` overrides the system language; a missing key falls back to English, then to
  the key itself.

- `val imagesBundle: String = "CYLClassifyMenuImages.bundle"` (L21)
  `imagesBundle`: the core's image folder, `CYLClassifyMenuImages.bundle` (new images live there as files, e.g.
  "cyl_trash", AGENTS.md "Image resources: folder bundles"); `imageNamed` reads it first.

- `fun bundle(): String = BUNDLE` (L28)
  `+bundle`: the resource folder's name in the library's Java resources.

- `fun imageNamed(name: String): Drawable?` (L35)
  `+imageNamed:`: a drawable of the bundle's images (`CYLClassifyMenuResources/<name>@3x.png`, `@2x` or 1x, copied
  from the iOS asset catalog), scaled like the iOS image (3x as xxhdpi, 2x as xhdpi, 1x as mdpi); null when missing.

- `fun availableLanguages(): List<String> = listOf("en", "zh-Hans", "zh-Hant").filter { table(it).isNotEmpty() }.sorted()` (L49)
  `+availableLanguages`, sorted.

- `var preferredLanguage: String? = null` (L54)
  `preferredLanguage`: a language of `availableLanguages()` used instead of the system's; null for the system's.

- `fun currentLanguage(): String` (L58)
  `+currentLanguage`: the preferred language when set, else the system language, else English.

- `fun localizedStringForKey(key: String): String = localizedStringForKey(key, currentLanguage())` (L66)
  `+localizedStringForKey:`.

- `fun localizedStringForKey(key: String, language: String?): String` (L70)
  `+localizedStringForKey:language:`.

- `internal fun parseStrings(text: String): Map<String, String>` (L101)
  Parses an Apple `.strings` file: `"key" = "value";` lines, comments allowed.

- `fun CYLMenuLocalizedStringForKey(key: String): String = CYLMenuResources.localizedStringForKey(key)` (L141)
  `CYLMenuLocalizedStringForKey` / the macro `CYLMenuLocalizedString(key, comment)`.

- `fun CYLMenuLocalizedString(key: String, comment: String? = null): String = CYLMenuResources.localizedStringForKey(key)` (L147)
  The macro `CYLMenuLocalizedString(key, comment)`: the comment only documents the key.

- `fun CYLMenuImage(name: String): Drawable? = CYLMenuResources.imageNamed(name)` (L152)
  The macro `CYLMenuImage(name)`.

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLMenuStyle.kt

- `enum class CYLTagImagePlacement` (L14)
  `CYLTagImagePlacement`: the icon before or after the title, or above (`Top`, raw value 2) or below (`Bottom`, 3) it,
  both centered.

- `val isVertical: Boolean get() = this == CYLTagImagePlacementTop || this == CYLTagImagePlacementBottom` (L18)
  True for `Top` and `Bottom`: the icon and the title are stacked.

- `enum class CYLTagContentAlignment { CYLTagContentAlignmentCenter, CYLTagContentAlignmentLeading }` (L22)
  `CYLTagContentAlignment`: the icon and title centered in the tag, or at its leading edge.

- `enum class CYLTagBackgroundStyle { CYLTagBackgroundStyleFlat, CYLTagBackgroundStyleLiquidGlass }` (L25)
  `CYLTagBackgroundStyle`: a tag's flat color, or a Liquid Glass background where the device draws one (`CYLLiquidGlass.isActive()`).

- `enum class CYLTagRowAlignment { CYLTagRowAlignmentLeading, CYLTagRowAlignmentCenter, CYLTagRowAlignmentTrailing }` (L28)
  `CYLTagRowAlignment`: where a row of tags sits in the list's width.

- `enum class CYLSectionStyle { CYLSectionStylePlain, CYLSectionStyleInsetGrouped }` (L35)
  `CYLSectionStyle`: how a section's tags sit in the list: `insetGrouped` (the default) inside a rounded card (UITableView's
  inset grouped look), the header above it; `plain` on the list's background (the opt-out: the look before the default
  changed).

- `enum class CYLHeaderSeparatorStyle { CYLHeaderSeparatorStyleNone, CYLHeaderSeparatorStyleLine }` (L38)
  `CYLHeaderSeparatorStyle`: the line at the bottom of a section header: `none` (the default) or a `line`.

- `object CYLSectionStyleMetrics` (L41)
  The named lengths of the section style, dp.

- `const val CARD_CORNER_RADIUS: Float = 10f` (L43)
  The corner radius of a section card.

- `const val CARD_PADDING: Float = 12f` (L45)
  The padding between a section card and its tags.

- `const val HEADER_BAND_PADDING: Float = 12f` (L47)
  The padding between a header band and its title, leading and trailing.

- `const val SEPARATOR_THICKNESS: Float = 0.5f` (L49)
  The thickness of the header divider: one hairline.

- `const val HEADER_FONT_SIZE: Float = 17f` (L51)
  The default size of a section header title (the table header look; its weight is [CYLFont.WEIGHT_SEMIBOLD]).

- `object CYLSectionStyleColors` (L58)
  The colors of the section style, each following the color mode (as `CYLSystemColors`): a style whose color is null
  resolves to them; an app can also set one itself, for example [HEADER_BAND] on `headerBackgroundColor`.

- `const val CARD: Int = Color.WHITE` (L60)
  The section card in light mode: white.

- `const val CARD_DARK: Int = CYLSystemColors.SECONDARY_BACKGROUND_DARK` (L62)
  The section card in dark mode: #1C1C1E (the secondary system background).

- `const val HEADER_BAND: Int = 0xFFEFEFF4.toInt()` (L64)
  The header band in light mode: #EFEFF4 (the TagCollectionView header).

- `const val HEADER_BAND_DARK: Int = 0xFF2C2C2E.toInt()` (L66)
  The header band in dark mode: #2C2C2E.

- `const val GROUPED_BACKGROUND: Int = 0xFFF2F2F7.toInt()` (L68)
  The list background under `insetGrouped` in light mode: #F2F2F7.

- `const val GROUPED_BACKGROUND_DARK: Int = Color.BLACK` (L70)
  The list background under `insetGrouped` in dark mode: black.

- `const val SEPARATOR: Int = 0x4A3C3C43` (L72)
  The header divider in light mode: the system separator (#3C3C43 at 29 %).

- `const val SEPARATOR_DARK: Int = 0x99545458.toInt()` (L74)
  The header divider in dark mode: the system separator (#545458 at 60 %).

- `enum class CYLTagDeleteIndicatorPlacement { CYLTagDeleteIndicatorPlacementTrailing, CYLTagDeleteIndicatorPlacementLeading }` (L83)
  `CYLTagDeleteIndicatorPlacement`: the delete indicator after or before the title.

- `class CYLMenuStyle` (L90)
  `CYLMenuStyle`: the look of a tag list: the tags in each state (`CYLTagAppearance`), the delete indicator, the touch
  ripple, titles, rows, icons, layout spacing, section headers, fold controls and the More button. Lengths are dp,
  font sizes sp. `copy()` is NSCopying.

- `var editingIndicatorSpacing: Float = 10f` (L115)
  `editingIndicatorSpacing`: the space between the two editing icons of a renamable tag in `CYLTagListView`'s
  editing mode (the edit icon and the delete icon, `CYLTagButton.editingIndicatorsView`), dp. 10 by default; a
  negative value is 0.

- `var editingIndicatorInsets: CYLEdgeInsets = CYLEdgeInsets(0f, 4f, 0f, 0f)` (L122)
  `editingIndicatorInsets`: the margins around the two editing icons as a whole: left from the title, right to the
  tag's padding, top and bottom within the tag, dp. Left 4 and right 0 by default (the tag's own padding follows
  the cross); negative values are 0.

- `var clearButtonImage: android.graphics.drawable.Drawable? = null` (L125)
  `clearButtonImage`: the image of a section header's clear button; null: the core's trash icon ("cyl_trash").

- `var clearButtonColor: Int? = null` (L128)
  `clearButtonColor`: the color of the clear button; null: `headerTextColor`.

- `var rippleDuration: Double = 1.0` (L135)
  Seconds, as `NSTimeInterval`.

- `var backgroundStyle: CYLTagBackgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat` (L162)
  The tag background: flat (the default) is the solid color of each state's appearance; Liquid Glass draws a glass background
  behind the content, tinted with the state's `backgroundColor` and clipped to the corner radius. Where the device draws no
  Liquid Glass the style is ignored (`resolvedBackgroundStyle`).

- `val resolvedBackgroundStyle: CYLTagBackgroundStyle` (L168)
  The background style a tag really draws: `backgroundStyle`, or flat when `CYLLiquidGlass.isActive()`
  (`CYLAnimatedItemView.isLiquidGlassActive()`, the rule of CYLTabBarController: Android 12 and later) is false.

- `var minimumTagSize: CYLSize = CYLSize.ZERO` (L176)
  The smallest size of a tag, dp: a tag narrower or shorter than it grows to it, its content staying where `contentAlignment`
  puts it. `CYLSize.ZERO` (the default) keeps the tag as large as its content and `itemHeight` make it.

- `var maximumFontScale: Float = CYLMaximumFontScale` (L186)
  The largest system font scale this style's texts follow when `adjustsFontForContentSizeCategory`: the text grows with the
  system font size up to this factor. Default [CYLMaximumFontScale]; the fold controls lower it to
  [CYL_FOLD_CONTROL_MAX_FONT_SCALE] so they stay small at accessibility font sizes.

- `var titleMaxLines: Int = CYLTagTitleMaxLines.SINGLE` (L194)
  The most lines a title may take: a title too wide for its tag wraps onto more lines, up to this number, and the tag
  grows taller; beyond it the title is truncated. Default [CYLTagTitleMaxLines.SINGLE] (1, one line, truncated).
  [CYLTagTitleMaxLines.UNLIMITED] shows every line. The app chooses the number; a value below 1 is 1.

- `var backgroundColor: Int` (L210)
  The list's background color. Never set, the list paints the SYSTEM background (white in light mode, black in dark mode),
  or the grouped background under `insetGrouped` ([resolvedBackgroundColor], resolved per mode); this getter then returns
  white, the light value, because it has no context. A set color, even a transparent one, wins in both modes.

- `internal val explicitBackgroundColor: Int? get() = if (backgroundColorWasSet) backgroundColorValue else null` (L218)
  The list background the app set, null while it was never set (the default follows light / dark mode).

- `var sectionStyle: CYLSectionStyle = CYLSectionStyle.CYLSectionStyleInsetGrouped` (L225)
  `insetGrouped` (the default): the section's tags inside a rounded card; `plain` opts out (the tags on the list's
  background). The library's own looks that must stay flat ([tagCloudStyle], [wordPicker], ...) set `plain`.

- `var sectionBackgroundColor: Int? = null` (L227)
  The card's color; null resolves to the system card color ([resolvedSectionBackgroundColor]).

- `var sectionBackgroundStyle: CYLTagBackgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat` (L233)
  The card's background: flat (the default) is the solid [sectionBackgroundColor]; Liquid Glass draws the library's glass
  behind the tags with the card's corners, tinted with [sectionBackgroundColor] when it is set. Where the device draws no
  glass the card stays flat ([resolvedSectionBackgroundStyle]). Independent of the tags' `backgroundStyle`.

- `val resolvedSectionBackgroundStyle: CYLTagBackgroundStyle` (L236)
  The card background really drawn: [sectionBackgroundStyle], or flat when `CYLLiquidGlass.isActive()` is false.

- `var sectionContentInsets: CYLEdgeInsets = CYLEdgeInsets(CYLSectionStyleMetrics.CARD_PADDING, CYLSectionStyleMetrics.CARD_PADDING,` (L242)
  The padding inside the card around the tags (`insetGrouped`), dp.

- `var sectionBoardInset: Float? = null` (L252)
  How far the board (the card, the header band and the divider) extends beyond the tag column on the leading and trailing
  sides, one value for both, dp. The tags and the header title always share the tag column, so this never changes the tag
  width. 0: the board's edges coincide with the tags' edges. null (the default): the leading and trailing parts of
  [sectionContentInsets] ([CYLSectionStyleMetrics.CARD_PADDING], 12): the board spans the section column as before. A set
  value (0 included) replaces those two parts (top and bottom still come from [sectionContentInsets]); a negative value is 0.
  A set value above the default can push the board past the list's margin ([sectionInsets]); that is accepted.

- `var headerBackgroundColor: Int? = null` (L255)
  The header band's color; null: no band (today's look). [CYLSectionStyleColors.HEADER_BAND] is the usual one.

- `var headerContentInsets: CYLEdgeInsets = CYLEdgeInsets(0f, CYLSectionStyleMetrics.HEADER_BAND_PADDING, 0f, CYLSectionStyleMetrics.HEADER_BAND_PADDING)` (L259)
  A plain header's title and fold control inset from the band's edges (left and right), dp.

- `var headerSeparatorColor: Int? = null` (L262)
  The divider's color; null resolves to the system separator color ([resolvedHeaderSeparatorColor]).

- `var headerSeparatorInsets: CYLEdgeInsets? = null` (L269)
  The divider's leading (left) and trailing (right) inset from the column's edges, dp; null (the default) is 0 and 0: the
  divider has the same left and right edges as the card and the header band, never the title's x.

- `val isInsetGrouped: Boolean get() = sectionStyle == CYLSectionStyle.CYLSectionStyleInsetGrouped` (L272)
  True when the section style draws the cards.

- `fun resolvedBackgroundColor(context: android.content.Context): Int = when` (L278)
  The list background in use: [backgroundColor] when the app set it (even transparent); else the grouped background under
  `insetGrouped`, else the system background (white in light mode, black in dark mode).

- `fun resolvedSectionBackgroundColor(context: android.content.Context): Int = sectionBackgroundColor ?: CYLSectionStyleColors.card(context)` (L285)
  The card's color in use.

- `fun resolvedHeaderSeparatorColor(context: android.content.Context): Int = headerSeparatorColor ?: CYLSectionStyleColors.separator(context)` (L288)
  The divider's color in use.

- `var headerHeight: Float` (L299)
  The fixed header height, dp (default 36). Under `insetGrouped` with no header divider the header is sized to its text
  instead (a title line plus [HEADER_BOARD_TITLE_PADDING], not below the fold control) and this value is a minimum only
  when the app set it ([isHeaderHeightSet]); the divider and the plain style keep it as the minimum always.

- `val isHeaderHeightSet: Boolean get() = headerHeightWasSet` (L307)
  Whether the app set [headerHeight] (the default 36 does not count).

- `var headerMaxLines: Int = CYLHeaderTitleMaxLines.SINGLE` (L315)
  The most lines a section header's title may take: a title too wide for the room beside the fold control wraps onto more
  lines, up to this number, and the header grows taller than [headerHeight]. Default [CYLHeaderTitleMaxLines.SINGLE] (1, one
  line, truncated: the header is exactly [headerHeight] high). [CYLHeaderTitleMaxLines.UNLIMITED] shows every line. A value
  below 1 is 1.

- `var headerFont: CYLFont = CYLFont.semiboldSystemFont(CYLSectionStyleMetrics.HEADER_FONT_SIZE)` (L318)
  The section header title: 17 dp semibold ([CYLSectionStyleMetrics.HEADER_FONT_SIZE], weight 600), the table header look.

- `var headerTextColor: Int? = null` (L320)
  null (the default): [tintColor], else its default by the background luminance ([resolvedHeaderTextColor]).

- `var foldControlColor: Int? = null` (L325)
  null (the default): the tint (see [headerTextColor]); a control's own color wins.

- `var moreButtonColor: Int? = null` (L333)
  null (the default): the tint (see [headerTextColor]).

- `var tintColor: Int? = null` (L340)
  The one color of every built-in view that is not a tag (header title, section icon, fold / More / clear controls); null
  (the default): black or white by the luminance of the background it is drawn on ([resolvedTintColor]). A color set on
  the title, the fold control, the More button or the clear button itself wins over it for that view.

- `fun resolvedTintColor(context: android.content.Context, onBand: Boolean = false): Int` (L357)
  The tint as drawn: [tintColor], else the default against what is behind the view: the band color when `onBand` (a
  header with a band) and a band is set, else the list's own background ([resolvedBackgroundColor]: the app's color, the
  grouped background under `insetGrouped`, the system background the list paints by default).

- `fun resolvedHeaderTextColor(context: android.content.Context, onBand: Boolean = false): Int = headerTextColor ?: resolvedTintColor(context, onBand)` (L365)
  The header title color in use: [headerTextColor], else the tint.

- `fun resolvedFoldControlColor(context: android.content.Context, onBand: Boolean = false): Int = foldControlColor ?: resolvedTintColor(context, onBand)` (L369)
  The fold controls' color in use: [foldControlColor], else the tint (a control's own color still wins).

- `fun resolvedMoreButtonColor(context: android.content.Context, onBand: Boolean = false): Int = moreButtonColor ?: resolvedTintColor(context, onBand)` (L373)
  The More button's color in use: [moreButtonColor], else the tint.

- `fun resolvedClearButtonColor(context: android.content.Context, onBand: Boolean = false): Int = clearButtonColor ?: resolvedHeaderTextColor(context, onBand)` (L377)
  The clear button's color in use: [clearButtonColor], else the header title's.

- `var tagContentInsets: CYLEdgeInsets` (L391)
  The content insets of every state; reads the normal state's.

- `fun appearanceForState(state: Int): CYLTagAppearance = when` (L400)
  `-appearanceForState:`: disabled wins over selected, which wins over normal.

- `fun displayedTitleForTitle(title: String?): String` (L410)
  `-displayedTitleForTitle:`: at most `maximumTitleLength` characters (whole grapheme clusters) then "...", and
  reversed character by character when `reversesTitleCharacters`.

- `fun setTitleTextAttributes(font: CYLFont?, textColor: Int?, forState: Int)` (L426)
  `-setTitleTextAttributes:forState:`: the font and text color of `state` (null resets them).

- `fun titleTextAttributesForState(state: Int): Pair<CYLFont, Int>` (L433)
  `-titleTextAttributesForState:`: the font and text color of `state`.

- `fun setIconColor(iconColor: Int?, forState: Int)` (L439)
  `-setIconColor:forState:`.

- `internal fun explicitIconColorForState(state: Int): Int? = appearanceForState(state).iconColor` (L447)
  The icon color the app set for `state`, null while it was never set: the built-in default (the text color) does not count.
  The tag hands only an explicit color to the item as its icon color; the item adapts it on dark Liquid Glass.

- `internal fun explicitTextColorForState(state: Int): Int? = appearanceForState(state).explicitTextColor` (L453)
  The text color the app set for `state`, null while it was never set: the built-in default does not count.
  The tag hands only an explicit color to the item as its title color; the item adapts it on dark Liquid Glass.

- `fun iconColorForState(state: Int): Int` (L456)
  `-iconColorForState:`: the icon color, else the text color.

- `fun titleFontForState(state: Int, fontScale: Float? = null, boldText: Boolean = false): CYLFont =` (L475)
  `-titleFontForState:traitCollection:`; the trait collection is the font scale and Bold Text.

- `fun deleteIndicatorFontForState(state: Int, fontScale: Float? = null, boldText: Boolean = false): CYLFont =` (L480)
  `-deleteIndicatorFontForState:traitCollection:`: `deleteIndicatorFont`, else the title font.

- `fun headerFontForTraitCollection(fontScale: Float? = null, boldText: Boolean = false): CYLFont = scaledFont(headerFont, fontScale, boldText)` (L485)
  `-headerFontForTraitCollection:`.

- `fun copy(): CYLMenuStyle` (L488)
  NSCopying.

- `fun defaultStyle() = CYLMenuStyle()` (L570)
  `+defaultStyle`.

- `fun tagCloudStyle(): CYLMenuStyle` (L580)
  `+tagCloudStyle`: android-tagview's look: blue square tags, white text, 5 dp spacing.

- `fun wordPicker(): CYLMenuStyle` (L608)
  `+wordPicker` (选词填入, as WeChat's "涂抹选择填入词"): one character per cell, 9 equal cells per row, light gray
  cells with small corners that turn mint green when selected, the character centered. Use it with
  `CYLTagListView.setTagsWithCharactersOfText`, `selectionMode` multiple and `allowsSmearSelection`; the picked
  text is `selectedText`.

- `fun tagContainerStyle(): CYLMenuStyle` (L636)
  `+tagContainerStyle`: AndroidTagView's look: translucent red capsules, gray text, 23 characters at most.

- `fun classifyMenuTag(look: CYLCollectionCellButtonStyle = CYLCollectionCellButtonStyle.chengNi): CYLMenuStyle` (L671)
  `+classifyMenuTag:`: a tag of `CYLClassifyMenuViewController`, in one of the looks its tag buttons have had
  (`CYLCollectionCellButtonStyle`; `chengNi`, the default, is a light green capsule that takes the app's tint
  while selected or pressed). The tags' title font (`CYLTagTitleFontSize`, scaled like every tag), the icon 5 dp
  before the title, a 4 dp margin at both ends.

- `fun filterTag(): CYLMenuStyle` (L718)
  `+filterTag`: a tag of the multiple-choice filter (`CYLMultipleFilterController`): the filter's stretchable
  slide images as the normal and selected backgrounds, green titles that turn white when selected.

- `fun sectionTitle(fontSize: Float = 15f, textColor: Int = Color.BLACK, leadingInset: Float = 0f): CYLMenuStyle` (L737)
  `+sectionTitleWithFontSize:textColor:leadingInset:`: a section title of a header: no background and no border,
  the content at the leading edge after `leadingInset` (dp), an icon 4 dp before the title, in `fontSize` (sp).

- `fun gridStyleWithNumberOfItemsPerRow(numberOfItemsPerRow: Int): CYLMenuStyle` (L776)
  `+gridStyleWithNumberOfItemsPerRow:`: borderless items in `numberOfItemsPerRow` columns, icon after title.

- `object CYLHeaderTitleMaxLines` (L803)
  The line limits of a section header's title ([CYLMenuStyle.headerMaxLines]): named values, never a literal at a call site.

- `const val SINGLE: Int = 1` (L805)
  One line, the default: a title too wide for its header is truncated and the header keeps its fixed height.

- `const val UNLIMITED: Int = Int.MAX_VALUE` (L808)
  No limit: a title wraps onto as many lines as it needs and the header grows with it.

- `object CYLTagTitleMaxLines` (L812)
  The line limits of a tag's title ([CYLMenuStyle.titleMaxLines]): named values, never a literal at a call site.

- `const val SINGLE: Int = 1` (L814)
  One line, the default: a title too wide for its tag is truncated.

- `const val UNLIMITED: Int = Int.MAX_VALUE` (L817)
  No limit: a title wraps onto as many lines as it needs (the MAX of the line counts).

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLMultipleFilter.kt

- `const val kMultipleFilterSetting = "kMultipleFilterSetting"` (L31)
  Key of the filter settings in `filterParamsDictionary`.

- `const val kMultipleFilterSettingModified = "kMultipleFilterSettingModified"` (L36)
  Key of the "modified" flag in `filterParamsDictionary`.

- `class CYLFilterParamsTool` (L42)
  `CYLFilterParamsTool`: the state of the multiple filter: the titles per section (`dataSources`) and a selected flag
  per item (`filterParamsArray`, the first item of each section selected by default).

- `var dataSources: List<List<String>> = emptyList()` (L46)
  The titles, one list per section.

- `var filterParamsArray: MutableList<MutableList<Boolean>>` (L53)
  One selected flag per item; made from `dataSources` (first item selected) on first use.

- `var filterParamsDictionary: MutableMap<String, Any?>` (L62)
  The settings and the modified flag.

- `var filterParamsContentDictionary: MutableMap<String, Any?>` (L72)
  Free-form content of the filter ("skilled" by default, as on iOS).

- `var filename: String` (L82)
  Where the settings are saved: `kMultipleFilterSetting` in the app's files folder (the documents folder on iOS),
  once `filesDir` is known; set it to choose another file.

- `var filesDir: File? = null` (L89)
  The folder `filename` defaults to (an app sets `context.filesDir`).

- `internal class CYLStretchableDrawable(private val bitmap: android.graphics.Bitmap) : android.graphics.drawable.Drawable()` (L96)
  `-stretchableImageWithLeftCapWidth:topCapHeight:` with caps at half the image (`+[UIImage stretchableImageNamed:]`
  of the iOS cell): the corners are drawn at their size and only the middle column and row stretch.

- `class CYLFilterCollectionCell @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : FrameLayout(context, attrs)` (L135)
  `CYLFilterCollectionCell`: an item of the multiple filter: a tag (`CYLIndexPathButton`, a `CYLTagButton` in
  `CYLMenuStyle.filterTag()`: the slide backgrounds, a green title that turns white when selected) that fills the cell
  and shows the selection; the cell takes the touches and is the accessibility element.

- `class CYLMultipleFilterHeaderView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : ViewGroup(context, attrs)` (L155)
  `CYLMultipleFilterHeaderView`: a section header of the multiple filter: the section's title (`titleButton`, a
  `CYLTagButton`, half-transparent black, 50 dp in), with an optional icon before it (6 dp in), above a green line.
  TalkBack reads the title as a heading.

- `val titleButton: CYLTagButton = object : CYLIndexPathButton(context)` (L162)
  The section's title, and its icon (`image`, or `animationURL`) when it has one: a `CYLTagButton` in a
  section-title style, read by TalkBack as a heading labeled with the title. Set the title with `titleButton.title`.

- `val imageView: ImageView get() = titleButton.imageView` (L183)
  The icon of `titleButton` (its `imageView`); set it with `titleButton.image`.

- `val titleLabel: TextView get() = titleButton.titleLabel` (L188)
  The label of `titleButton` (its `titleLabel`); set the text with `titleButton.title`.

- `interface CYLFilterControllerDelegate` (L226)
  `CYLFilterControllerDelegate`: the filter panel closed after Apply or Reset.

- `fun filterControllerDidComplete(controller: CYLFilterBaseController) {}` (L230)
  `-filterControllerDidComplete:`.

- `open class CYLFilterBaseController : Fragment()` (L238)
  `CYLFilterBaseController`: a panel that slides in from the leading edge over a dimmed screen, on a blurred capture
  of the screen, with Reset and Apply buttons at the bottom; tapping the dimmed part closes it. On Android it is a
  `Fragment` added over a container with `showInView`.

- `var collectionView: ViewGroup? = null` (L242)
  The panel's scrolling content (the collection view on iOS).

- `var contentView: View? = null` (L248)
  The dimmed area beside the panel.

- `var dataSource: List<Any?> = emptyList()` (L260)
  Free-form data of a subclass.

- `var settingArray: MutableList<Any?> = mutableListOf()` (L265)
  Free-form settings of a subclass.

- `open fun showInView(view: ViewGroup)` (L346)
  `-showInView:`: captures and blurs `view` as the panel's background, adds the panel over it and slides it in.

- `open fun hide() = close {}` (L393)
  Closes the panel without applying (a tap on the dimmed area).

- `open fun itemButtonClicked(button: CYLIndexPathButton) {}` (L398)
  `-itemButtonClicked:`: a subclass's item was tapped (nothing in the base class).

- `open fun confirmButtonClicked(sender: Any?)` (L403)
  `-confirmButtonClicked:`: closes the panel, then tells the delegate.

- `open fun restoreButtonClicked(sender: Any?) = confirmButtonClicked(null)` (L410)
  `-restoreButtonClicked:`: closes like Apply (a subclass resets first).

- `val isShowing: Boolean get() = root?.parent != null` (L415)
  Whether the panel is on screen.

- `open class CYLMultipleFilterController : CYLFilterBaseController()` (L423)
  `CYLMultipleFilterController`: the multiple-choice filter: sections of items from a `CYLMenuDataSource`, one or
  more selected per section, an exclusive item ("All") selected alone; Apply reports the selection to the delegate,
  Reset selects the defaults again.

- `fun refreshFilterParams()` (L440)
  `-refreshFilterParams`: shows the current selection again.

- `fun reloadMenuData()` (L447)
  `-reloadMenuData`: reads the data source again; each section selects its first exclusive item.

- `fun selectedIndexPaths(): List<CYLIndexPath> = filterParamsTool.filterParamsArray.flatMapIndexed { section, states ->` (L473)
  `-selectedIndexPaths`.

- `fun setSelectedIndexPaths(indexPaths: List<CYLIndexPath>)` (L480)
  `-setSelectedIndexPaths:`: throws for an invalid item, or an exclusive item selected with another in its section.

- `fun selectItemAtIndexPath(indexPath: CYLIndexPath)` (L510)
  Selects or deselects an item as a tap does (the collection view's `didSelectItemAtIndexPath:`).

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLParameterConfiguration.kt

CYLParameterConfiguration.h: the tint, the font sizes and the tag height rule shared by the core's views.

- `val CYLAppTintColor: Int = CYLColor.APP_TINT` (L12)
  The macro `CYLAppTintColor`.

- `const val CYLMaximumFontScale: Float = 2.0f` (L15)
  `CYLMaximumFontScale`: text grows with the system font size up to this factor.

- `const val CYLTagTitleFontSize: Float = 16f` (L18)
  `CYLTagTitleFontSize`, sp.

- `fun CYLScaledSystemFont(pointSize: Float, fontScale: Float = 1f): CYLFont =` (L24)
  `CYLScaledSystemFont`: the system font of `pointSize` scaled by `fontScale` (the system font scale, 1 by default),
  at most `CYLMaximumFontScale` times.

- `fun CYLTagHeightForFont(font: CYLFont, minimumHeight: Float): Float = max(minimumHeight, ceil(font.size * 1.2f) + 10)` (L28)
  `CYLTagHeightForFont`: at least `minimumHeight`, else the font's line height plus 10.

- `fun CYLTagTitleFontForTraitCollection(fontScale: Float = 1f): CYLFont = CYLScaledSystemFont(CYLTagTitleFontSize, fontScale)` (L31)
  `CYLTagTitleFontForTraitCollection`: the scaled title font.

- `val CYLTagTitleFont: CYLFont` (L34)
  The macro `CYLTagTitleFont`.

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLTag.kt

- `const val CYLTagUseListValue: Float = -1f` (L17)
  `CYLTagUseListValue`: a tag length that uses the list's style (-1).

- `class CYLTag(` (L25)
  `CYLTag`: one tag of a `CYLTagDataSource`: its title, identifier, icons, badge, state, and the look it changes over
  the list's style (android-tagview's `Tag`). Lengths of `CYLTagUseListValue` (-1) use the list's value.

- `var title: String = title` (L31)
  The title; null becomes "".

- `var subtitle: String? = null` (L35)
  A longer description, shown in a callout on a long press (`CYLTagLongPressActions.callout`).

- `var colors: CYLTagColors` (L80)
  The four colors of the tag; setting it sets them.

- `fun resetColors()` (L90)
  Resets `colors` (null_resettable): all four colors to the list's.

- `val hasCustomStyle: Boolean` (L95)
  Whether the tag changes anything of the list's style.

- `fun styleWithBaseStyle(baseStyle: CYLMenuStyle?): CYLMenuStyle` (L102)
  `-styleWithBaseStyle:`: the tag's style over `baseStyle` (its own `style` when set).

- `fun copy(): CYLTag = CYLTag(identifier, title, backgroundColor).also` (L128)
  NSCopying.

- `fun tagWithTitle(title: String) = CYLTag(title)` (L158)
  `+tagWithTitle:`.

- `const val BADGE_DOT_DIAMETER = 8f` (L161)
  The diameter of a badge dot, dp: 8, as `CYLTagButton`'s dot and iOS `CYLTag.badgeDotDiameter`.

- `const val BADGE_IMAGE_TEXT_PADDING = 4f` (L164)
  The side padding of a badge image's text, dp: 4, as `CYLTagButton`'s corner badge and iOS `CYLTag.badgeImageTextPadding`.

- `fun badgeImageWidth(text: String, diameter: Float): Float` (L188)
  `CYLTag.badgeImageWidth(text:diameter:)`: the width (dp) of a badge image: the diameter (a circle) for a short text, or the
  text's width and [BADGE_IMAGE_TEXT_PADDING] on both sides when that is more (a capsule, as `CYLTagButton`'s corner badge).
  One character (a digit, a letter, a CJK character such as "热") always keeps the circle, as on iOS.

- `fun badgeDotImage(color: Int?, canvas: Float): Drawable` (L203)
  `CYLTag.badgeDotImage(color:canvas:)`: a filled [color] circle [BADGE_DOT_DIAMETER] dp wide (at most [canvas]), centred in a
  [canvas] dp square so the tag's icon slot keeps its size. Its accessibility label is the localized dot text.

- `fun badgeImageWithText(text: String, color: Int?, diameter: Float): Drawable` (L220)
  `+badgeImageWithText:color:diameter:`: a filled capsule (`color`, else system blue) `diameter` dp high with `text` in white
  bold, as wide as [badgeImageWidth] says (a circle for a short text); its `contentDescription`-like label is the text (see
  `CYLBadgeDrawable.accessibilityLabel`).

- `class CYLBadgeDrawable(resources: Resources, bitmap: Bitmap, var accessibilityLabel: String?) : BitmapDrawable(resources, bitmap)` (L240)
  A badge image with the label VoiceOver/TalkBack reads (`UIImage.accessibilityLabel` on iOS).

- `class CYLOriginalImageDrawable(val image: Drawable) : android.graphics.drawable.InsetDrawable(image, 0)` (L247)
  `-[UIImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]` for tags: `drawable` drawn in its own colors.
  A tag tints its icon with `iconColor` (as iOS tints template images such as SF Symbols); an image wrapped in this
  class keeps its colors, as a non-template image does on iOS (a colored badge, a localized "hot" picture).

- `fun Drawable.cyl_imageWithRenderingModeAlwaysOriginal(): Drawable = this as? CYLOriginalImageDrawable ?: CYLOriginalImageDrawable(this)` (L253)
  `imageWithRenderingMode(.alwaysOriginal)`: this drawable, drawn in its own colors by tags (see
  `CYLOriginalImageDrawable`).

- `class CYLTagDataSource @JvmOverloads constructor(tags: List<CYLTag>? = null) : CYLMenuDataSource` (L259)
  `CYLTagDataSource`: a one-section `CYLMenuDataSource` of `CYLTag`s, with a section title and the list's base style;
  each tag's style is computed once and cached until it or the base style changes (`invalidateStyles()`).

- `var tags: List<CYLTag>` (L266)
  The tags, a copy; setting it replaces them and clears the cached styles.

- `var baseStyle: CYLMenuStyle?` (L276)
  The list's style the tags change; the default style when null (null_resettable).

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLTagAppearance.kt

- `class CYLTagAppearance : Cloneable` (L11)
  `CYLTagAppearance`: the box and text of a tag in one state (normal, selected, disabled). Negative or non-finite
  lengths become 0, as on iOS.

- `var backgroundColor: Int` (L18)
  null_resettable: white by default.

- `var textColor: Int` (L23)
  null_resettable: dark gray (white 0.25) by default.

- `fun resolvedBackgroundColor(context: android.content.Context): Int =` (L28)
  The background in use: [backgroundColor] when set, else white, or the secondary system background in night mode (iOS: the dynamic default).

- `val explicitBackgroundColor: Int? get() = _backgroundColor` (L35)
  The background the app (or a style) set for this state, null while it was never set: the built-in default (white, or
  the secondary system background in night mode) does not count. Under Liquid Glass only this color tints the glass.

- `val explicitTextColor: Int? get() = _textColor` (L42)
  The text color the app (or a style) set for this state, null while it was never set: the built-in default (dark gray, or the
  list's primary tint in night mode) does not count. The tag hands only an explicit color to the item as its title color; the
  item adapts it on dark Liquid Glass.

- `fun resolvedTextColor(context: android.content.Context): Int =` (L45)
  The title color in use: [textColor] when set, else dark gray, or the list's primary tint in night mode.

- `var font: CYLFont` (L49)
  null_resettable: the 14 sp system font by default.

- `var borderColor: Int?` (L64)
  The border color in use: the built-in default of the style until one is set (setter, configuration key, preset).

- `var borderWidth: Float` (L72)
  The border width in use (dp): the built-in default of the style until one is set. Negative or non-finite becomes 0.

- `val hasExplicitBorder: Boolean get() = borderColorWasSet` (L85)
  Whether the app (a setter, a configuration key or a preset) set the border COLOR of this state (a width alone draws no border
  under glass, as on HarmonyOS and the mini program; the width is then the explicit one, else the default). The built-in
  default border ([setDefaultBorder]) does not count. Under drawn Liquid Glass only an explicit border is handed to the
  glass; otherwise the glass draws its own rim.

- `val isBorderColorSet: Boolean get() = borderColorWasSet` (L88)
  Whether the border COLOR was set by the app, a configuration or a preset (not the style's built-in default); as iOS `isBorderColorSet`.

- `val isBorderWidthSet: Boolean get() = borderWidthWasSet` (L91)
  Whether the border WIDTH was set by the app, a configuration or a preset (not the style's built-in default); as iOS `isBorderWidthSet`.

- `val glassBorderColor: Int? get() = if (isBorderColorSet) borderColor else null` (L97)
  The border drawn under Liquid Glass: the EXPLICIT color decides. An explicit color draws the border (the explicit width, else
  the default width); a width set without an explicit color, or nothing explicit, draws none (the shared glass rim shows).

- `val glassBorderWidth: Float get() = if (glassBorderColor != null) borderWidth else 0f` (L100)
  The width (dp) of [glassBorderColor]: the effective width while there is a glass border color, else 0.

- `val isBackgroundColorSet: Boolean get() = _backgroundColor != null` (L103)
  Whether the background color was set (and not reset); as iOS `isBackgroundColorSet`.

- `val isTextColorSet: Boolean get() = _textColor != null` (L106)
  Whether the text color was set (and not reset); as iOS `isTextColorSet`.

- `val isIconColorSet: Boolean get() = iconColor != null` (L109)
  Whether the icon color was set (and not reset); as iOS `isIconColorSet`.

- `internal fun setDefaultBorder(color: Int?, width: Float)` (L112)
  The built-in default border of a state: readable through [borderColor] and [borderWidth] but NOT explicit.

- `internal fun copyBorderFrom(other: CYLTagAppearance)` (L120)
  Takes the border of `other` with its explicit flags (the default stays a default).

- `var margin: Float` (L128)
  The larger of the left and right content insets; setting it sets both.

- `fun reset()` (L141)
  Resets the colors and font to null (the defaults) and the lengths to their defaults.

- `fun resetBackgroundColor() { _backgroundColor = null }` (L153)
  Resets the background color to its default (null_resettable).

- `fun resetTextColor() { _textColor = null }` (L156)
  Resets the text color to its default (null_resettable).

- `fun resetFont() { _font = null }` (L159)
  Resets the font to its default (null_resettable).

- `public override fun clone(): CYLTagAppearance = CYLTagAppearance().also` (L162)
  NSCopying.

