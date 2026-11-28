# android: library (part 4 of 4)

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLTagListViewConfiguration.kt

Keys of a tag list configuration (`CYLTagListView+CYLConfiguration.h`); the values are the iOS strings, so one file
configures both platforms.

- `const val CYLTagListViewSections = "sections"` (L25)
  Tag list key: an array of section dictionaries.

- `const val CYLTagListViewStyle = "style"` (L29)
  Tag list key: a style dictionary applied to the list's style.

- `const val CYLTagListViewSelectionMode = "selectionMode"` (L33)
  Tag list key: "none", "single" or "multiple".

- `const val CYLTagListViewFoldStyle = "foldStyle"` (L37)
  Tag list key: "none", "headerButton", "footerChevron" or "truncate".

- `const val CYLTagListViewAllowsEmptySelection = "allowsEmptySelection"` (L41)
  Tag list key: a Boolean.

- `const val CYLTagListViewShowsSectionHeaders = "showsSectionHeaders"` (L45)
  Tag list key: a Boolean.

- `const val CYLTagListViewLongPressAction = "longPressAction"` (L47)
  What a long press does: "reorder", "callout", "report" or "none", or a list of them (the first that can begin wins).

- `const val CYLTagListViewScrollEnabled = "scrollEnabled"` (L51)
  Tag list key: a Boolean.

- `const val CYLTagListViewDefaultVisibleRows = "defaultVisibleRows"` (L55)
  Tag list key: a number.

- `const val CYLTagListViewSelectedItems = "selectedItems"` (L59)
  Tag list key: index paths as "section-item" strings or [section, item] arrays.

- `const val CYLTagListViewFoldControl = "foldControl"` (L63)
  Tag list key: a fold control dictionary, or a position name.

- `const val CYLTagListViewTitle = "title"` (L67)
  Tag list key: the list's title.

- `const val CYLTagListViewTitlePosition = "titlePosition"` (L71)
  Tag list key: "topLeading" or "topCenter".

- `const val CYLTagListViewTitleImage = "titleImage"` (L75)
  Tag list key: an image name or path.

- `const val CYLTagListViewTitleStyle = "titleStyle"` (L79)
  Tag list key: a style dictionary applied to `defaultTitleStyle()`.

- `const val CYLTagListViewTags = "tags"` (L83)
  Tag list key: an array of tag dictionaries or titles (android-tagview's tags).

- `const val CYLMenuFoldControlKeyPosition = "position"` (L88)
  Fold control key: the position name.

- `const val CYLMenuFoldControlKeyContent = "content"` (L92)
  Fold control key: "iconAndTitle", "title" or "icon".

- `const val CYLMenuFoldControlKeyTitle = "title"` (L96)
  Fold control key: the expand title.

- `const val CYLMenuFoldControlKeyCollapseTitle = "collapseTitle"` (L100)
  Fold control key: the collapse title.

- `const val CYLMenuFoldControlKeyImage = "image"` (L104)
  Fold control key: an image name or path.

- `const val CYLMenuFoldControlKeyColor = "color"` (L108)
  Fold control key: a color.

- `const val CYLMenuFoldControlKeyFont = "font"` (L112)
  Fold control key: a font.

- `const val CYLMenuFoldControlKeyRotatesImage = "rotatesImageWhenExpanded"` (L116)
  Fold control key: a Boolean.

- `const val CYLTagSectionTitle = "title"` (L121)
  Section key: the section's title.

- `const val CYLTagSectionImage = "image"` (L125)
  Section key: the section's image.

- `const val CYLTagSectionItems = "items"` (L129)
  Section key: the section's items.

- `const val CYLTagSectionStyle = "style"` (L133)
  Section key: a style dictionary for the section.

- `const val CYLTagItemTitle = "title"` (L138)
  Item key: the title.

- `const val CYLTagItemSubtitle = "subtitle"` (L140)
  A longer description, shown in a callout on a long press (`longPressAction` "callout").

- `const val CYLTagItemImage = "image"` (L144)
  Item key: an image name or path.

- `const val CYLTagItemSelectedImage = "selectedImage"` (L148)
  Item key: the image when selected.

- `const val CYLTagItemAnimation = "animation"` (L152)
  Item key: an animation file (Lottie, PAG, Rive, GIF).

- `const val CYLTagItemAnimationOptions = "animationOptions"` (L156)
  Item key: options appended to the animation URL's fragment.

- `const val CYLTagItemAnimationRestingProgress = "animationRestingProgress"` (L160)
  Item key: the progress shown while the animation rests.

- `const val CYLTagItemEnabled = "enabled"` (L164)
  Item key: a Boolean.

- `const val CYLTagItemExclusive = "exclusive"` (L168)
  Item key: a Boolean.

- `const val CYLTagItemType = "type"` (L172)
  Item key: "tag" or "create".

- `const val CYLTagItemDeletable = "deletable"` (L176)
  Item key: a Boolean.

- `const val CYLTagItemIdentifier = "id"` (L180)
  Item key: a number identifying a tag.

- `const val CYLTagItemStyle = "style"` (L184)
  Item key: a style dictionary for the item.

- `const val CYLMenuStyleNormal = "normal"` (L189)
  Style key: the normal appearance dictionary.

- `const val CYLMenuStyleSelected = "selected"` (L193)
  Style key: the selected appearance dictionary.

- `const val CYLMenuStyleDisabled = "disabled"` (L197)
  Style key: the disabled appearance dictionary.

- `const val CYLMenuStyleImageTitleSpacing = "imageTitleSpacing"` (L201)
  Style key: a number.

- `const val CYLMenuStyleItemHeight = "itemHeight"` (L205)
  Style key: a number.

- `const val CYLMenuStyleTitleMaxLines = "titleMaxLines"` (L207)
  The most lines a title may take: a whole number, or "unlimited". Default 1.

- `const val CYLMenuStyleHeaderMaxLines = "headerMaxLines"` (L209)
  The most lines a section header's title may take: a whole number, or "unlimited"; a value below 1 is 1. Default 1.

- `const val CYLMenuStyleNumberOfItemsPerRow = "itemsPerRow"` (L213)
  Style key: a number, 0 for flowing rows.

- `const val CYLMenuStyleInteritemSpacing = "interitemSpacing"` (L217)
  Style key: a number.

- `const val CYLMenuStyleLineSpacing = "lineSpacing"` (L221)
  Style key: a number.

- `const val CYLMenuStyleHeaderHeight = "headerHeight"` (L225)
  Style key: a number.

- `const val CYLMenuStyleAnimationSpeed = "animationSpeed"` (L229)
  Style key: a number.

- `const val CYLMenuStyleImageSize = "imageSize"` (L233)
  Style key: a size.

- `const val CYLMenuStyleAnimationSize = "animationSize"` (L237)
  Style key: a size.

- `const val CYLMenuStyleImageInsets = "imageInsets"` (L241)
  Style key: insets.

- `const val CYLMenuStyleSectionInsets = "sectionInsets"` (L245)
  Style key: insets.

- `const val CYLMenuStyleTitlePositionAdjustment = "titlePositionAdjustment"` (L249)
  Style key: an offset.

- `const val CYLMenuStyleImagePositionAdjustment = "imagePositionAdjustment"` (L253)
  Style key: an offset.

- `const val CYLMenuStyleLayoutCentered = "layoutCentered"` (L257)
  Style key: a Boolean.

- `const val CYLMenuStyleImagePlacement = "imagePlacement"` (L261)
  Style key: "leading" or "trailing".

- `const val CYLMenuStyleContentAlignment = "contentAlignment"` (L265)
  Style key: "center" or "leading".

- `const val CYLMenuStyleBackgroundStyle = "backgroundStyle"` (L268)
  A `CYLTagBackgroundStyle` ordinal, or "flat" / "liquidGlass" (case-insensitive); anything else is flat.

- `const val CYLMenuStyleMinimumTagSize = "minimumTagSize"` (L271)
  A size "{width, height}" in dp, or {"width": 69, "height": 29}: `CYLMenuStyle.minimumTagSize`.

- `const val CYLMenuStyleAdjustsFontForContentSizeCategory = "adjustsFontForContentSizeCategory"` (L275)
  Style key: a Boolean.

- `const val CYLMenuStyleBackgroundColor = "backgroundColor"` (L279)
  Style key: a color.

- `const val CYLMenuStyleSectionStyle = "sectionStyle"` (L281)
  Style key: "plain" or "insetGrouped" (case-insensitive), or a `CYLSectionStyle` ordinal: the section card.

- `const val CYLMenuStyleSectionBackgroundColor = "sectionBackgroundColor"` (L283)
  Style key: a color: the card's.

- `const val CYLMenuStyleSectionBackgroundStyle = "sectionBackgroundStyle"` (L285)
  Style key: "flat" or "liquidGlass" (case-insensitive), or a `CYLTagBackgroundStyle` ordinal: the card's background.

- `const val CYLMenuStyleSectionCornerRadius = "sectionCornerRadius"` (L287)
  Style key: a number, dp.

- `const val CYLMenuStyleSectionContentInsets = "sectionContentInsets"` (L289)
  Style key: insets, the padding inside the card.

- `const val CYLMenuStyleSectionBoardInset = "sectionBoardInset"` (L291)
  Style key: a number, dp: how far the board extends beyond the tag column on both sides (negative is 0; absent: the content insets' leading/trailing).

- `const val CYLMenuStyleHeaderBackgroundColor = "headerBackgroundColor"` (L293)
  Style key: a color: the header band's; absent: no band.

- `const val CYLMenuStyleHeaderCornerRadius = "headerCornerRadius"` (L295)
  Style key: a number, dp.

- `const val CYLMenuStyleHeaderContentInsets = "headerContentInsets"` (L297)
  Style key: insets (left and right are used).

- `const val CYLMenuStyleHeaderSeparatorStyle = "headerSeparatorStyle"` (L299)
  Style key: "none" or "line" (case-insensitive), or a `CYLHeaderSeparatorStyle` ordinal: the header divider.

- `const val CYLMenuStyleHeaderSeparatorColor = "headerSeparatorColor"` (L301)
  Style key: a color: the divider's.

- `const val CYLMenuStyleHeaderSeparatorThickness = "headerSeparatorThickness"` (L303)
  Style key: a number, dp.

- `const val CYLMenuStyleHeaderSeparatorInsets = "headerSeparatorInsets"` (L305)
  Style key: insets (left and right are used): the divider's inset from the column's edges.

- `const val CYLMenuStyleTintColor = "tintColor"` (L307)
  Style key: a color: `CYLMenuStyle.tintColor`, the one color of the title, section icon and fold / More controls.

- `const val CYLMenuStyleHeaderTextColor = "headerTextColor"` (L311)
  Style key: a color.

- `const val CYLMenuStyleFoldControlColor = "foldControlColor"` (L315)
  Style key: a color.

- `const val CYLMenuStyleHeaderFont = "headerFont"` (L319)
  Style key: a font.

- `const val CYLMenuStyleHighlightedBackgroundColor = "highlightedBackgroundColor"` (L323)
  Style key: a color.

- `const val CYLMenuStyleTagContentInsets = "tagContentInsets"` (L327)
  Style key: insets.

- `const val CYLMenuStyleDeleteIndicatorTitle = "deleteIndicatorTitle"` (L331)
  Style key: a string.

- `const val CYLMenuStyleDeleteIndicatorColor = "deleteIndicatorColor"` (L335)
  Style key: a color.

- `const val CYLMenuStyleDeleteIndicatorFont = "deleteIndicatorFont"` (L339)
  Style key: a font.

- `const val CYLTagAppearanceBackgroundColor = "backgroundColor"` (L344)
  Appearance key: a color.

- `const val CYLTagAppearanceTextColor = "textColor"` (L348)
  Appearance key: a color.

- `const val CYLTagAppearanceFont = "font"` (L352)
  Appearance key: a font.

- `const val CYLTagAppearanceIconColor = "iconColor"` (L356)
  Appearance key: a color.

- `const val CYLTagAppearanceCornerRadius = "cornerRadius"` (L360)
  Appearance key: a number.

- `const val CYLTagAppearanceBorderColor = "borderColor"` (L364)
  Appearance key: a color.

- `const val CYLTagAppearanceBorderWidth = "borderWidth"` (L368)
  Appearance key: a number.

- `const val CYLTagAppearanceMargin = "margin"` (L372)
  Appearance key: a number.

- `const val CYLTagAppearanceContentInsets = "contentInsets"` (L376)
  Appearance key: insets.

- `const val CYLTagAppearanceBackgroundImage = "backgroundImage"` (L380)
  Appearance key: an image name or path.

- `const val CYLMenuConfigurationErrorDomain = "CYLMenuConfigurationErrorDomain"` (L385)
  The error domain of configuration files (`NSErrorDomain`).

- `enum class CYLMenuConfigurationError(val code: Int)` (L390)
  `CYLMenuConfigurationError`: why a configuration file could not be read.

- `class CYLMenuConfigurationException(val error: CYLMenuConfigurationError, message: String, cause: Throwable? = null) :` (L399)
  The exception thrown where iOS returns an `NSError` of `CYLMenuConfigurationErrorDomain`.

- `val domain: String get() = CYLMenuConfigurationErrorDomain` (L404)
  Always `CYLMenuConfigurationErrorDomain`.

- `fun CYLMenuAnimationURLWithOptions(fileURL: Uri?, options: Map<String, Any?>?): Uri?` (L504)
  `CYLMenuAnimationURLWithOptions`: `fileURL` with `options` as its fragment ("name=value&…", names sorted, percent
  encoded), which the animation engine reads (Rive's artboard and state machine, for example).

- `fun CYLMenuFoldControl.Companion.foldControlWithConfiguration(configuration: Any?, context: Context? = null): CYLMenuFoldControl?` (L709)
  `CYLMenuFoldControl (CYLConfiguration) +foldControlWithConfiguration:`: a copy of a fold control, a control for a
  position name (with the position's usual content), or one built from a dictionary; null for anything else.

- `fun CYLMenuFoldControl.applyConfiguration(configuration: Map<String, Any?>, context: Context? = null)` (L733)
  `CYLMenuFoldControl (CYLConfiguration) -applyConfiguration:`: sets the values the dictionary holds.

- `fun CYLTagAppearance.applyConfiguration(configuration: Map<String, Any?>?, context: Context? = null)` (L764)
  `CYLTagAppearance (CYLConfiguration) -applyConfiguration:`: sets the values the dictionary holds; a key whose
  color cannot be read clears the optional color, as on iOS.

- `fun CYLMenuStyle.Companion.styleWithConfiguration(configuration: Map<String, Any?>, context: Context? = null): CYLMenuStyle =` (L783)
  `CYLMenuStyle (CYLConfiguration) +styleWithConfiguration:`: the default style with the dictionary applied.

- `fun CYLMenuStyle.applyConfiguration(configuration: Map<String, Any?>, context: Context? = null)` (L789)
  `CYLMenuStyle (CYLConfiguration) -applyConfiguration:`: sets the values the dictionary holds.

- `fun CYLTag.Companion.tagWithConfiguration(configuration: Map<String, Any?>?, context: Context? = null): CYLTag` (L877)
  `CYLTag (CYLConfiguration) +tagWithConfiguration:`: a tag from an item dictionary (id, title, images, animation,
  enabled, deletable, style).

- `val CYLTagListView.configurationDataSource: CYLMenuDataSource?` (L900)
  `-configurationDataSource`: the data source the last configuration with sections installed (kept alive by the list).

- `fun CYLTagListView.Companion.tagListViewWithConfiguration(context: Context, configuration: Map<String, Any?>): CYLTagListView =` (L906)
  `-initWithConfiguration:` / `+tagListViewWithConfiguration:`: a list with the configuration applied.

- `fun CYLTagListView.applyConfiguration(configuration: Map<String, Any?>)` (L913)
  `-applyConfiguration:`: sets the values the dictionary holds, in the iOS order: style, selection mode, fold style
  and control, title, flags, then sections or tags, then the selection.

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLTagLongPressAction.kt

What a long press on an item does (`CYLTagListView.longPressAction`). The list owns the gesture; an action owns the
behavior: reordering, a callout with the item's subtitle, or the host's own code. The events
(`menuDidLongPressItemAtIndexPath`, `tagLongPressHandler`) stay notifications: the built-in actions report them, and
they never change the behavior. The same contract as HarmonyOS (docs/tag-long-press-action.md).
  list.longPressAction = CYLTagLongPressActions.first(listOf(CYLTagLongPressActions.reorder, CYLTagLongPressActions.callout))
  list.longPressAction = CYLTagLongPressActions.handler { host, indexPath -> host.showCallout("My text", indexPath) }
The default is `first(reorder, report)`: reordering where the list can reorder, else the long press is reported,
exactly as before this API existed.

- `interface CYLTagLongPressHost` (L27)
  The list as an action sees it: the primitives the built-in and the custom actions are made of.

- `fun subtitleForItem(indexPath: CYLIndexPath): String?` (L29)
  The item's subtitle from the data source (`menuSubtitleForItemAtIndexPath`), or null.

- `fun showCallout(text: String, indexPath: CYLIndexPath)` (L32)
  Shows a small callout with an arrow, pointing at the item, with [text]. Replaces a callout that is showing.

- `fun dismissCallout()` (L35)
  Hides the callout.

- `fun canReorderItem(indexPath: CYLIndexPath): Boolean` (L38)
  Whether the list can reorder this item now.

- `fun beginReordering(indexPath: CYLIndexPath)` (L41)
  Starts reordering with the item picked up (a selected item's drag is reported).

- `fun endReordering(destination: CYLIndexPath?, moved: Boolean)` (L44)
  Ends reordering: the data source moves the item to [destination] when [moved]; a press that did not move is reported as a long press.

- `fun cancelReordering()` (L47)
  Ends reordering without moving anything.

- `fun reportLongPress(indexPath: CYLIndexPath)` (L50)
  Reports a long press: `menuDidLongPressItemAtIndexPath`, then `tagLongPressHandler`.

- `interface CYLTagLongPressAction` (L54)
  What a long press on an item does.

- `fun canBegin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): Boolean` (L56)
  Whether this action takes the press on this item (reorder: the list can reorder; callout: the item has a subtitle).

- `fun begin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): Boolean` (L59)
  The press was recognized. Returns true to follow the finger; [end] or [cancel] then arrive.

- `fun end(host: CYLTagLongPressHost, destination: CYLIndexPath?, moved: Boolean) {}` (L62)
  The finger lifted over [destination] (null: outside the list); [moved] tells whether it left the item.

- `fun cancel(host: CYLTagLongPressHost) {}` (L65)
  The gesture was cancelled.

- `object CYLTagLongPressActions` (L146)
  The built-in long-press actions, and the ways to combine them or write your own.

- `val reorder: CYLTagLongPressAction = CYLTagReorderAction()` (L149)
  Picks the item up to reorder it, where the list can reorder (the data source moves the item).

- `val report: CYLTagLongPressAction = CYLTagReportAction()` (L153)
  Only reports the long press (`menuDidLongPressItemAtIndexPath`, `tagLongPressHandler`).

- `val callout: CYLTagLongPressAction = CYLTagCalloutAction()` (L157)
  Shows the item's subtitle in a callout with an arrow, where the item has one, and reports the long press.

- `val none: CYLTagLongPressAction = CYLTagNoneAction()` (L161)
  Does nothing (not even a report).

- `fun handler(handler: (CYLTagLongPressHost, CYLIndexPath) -> Unit): CYLTagLongPressAction = CYLTagHandlerAction(handler)` (L165)
  Runs [handler] instead of a built-in behavior; it can use the host's primitives, such as `showCallout`.

- `fun first(actions: List<CYLTagLongPressAction>): CYLTagLongPressAction = CYLTagFirstAction(actions)` (L169)
  The first of [actions] that can begin takes the press, as "reorder where editable, a callout elsewhere".

- `fun makeDefault(): CYLTagLongPressAction = CYLTagFirstAction(listOf(reorder, report))` (L173)
  The default of a list: `first(reorder, report)`, the behavior before this API existed.

- `internal class CYLTagCalloutBubble(context: Context, text: String) : androidx.appcompat.widget.AppCompatTextView(context)` (L180)
  The callout of a long press: a small bubble with an arrow pointing at the tag. [arrowCenter] is the arrow's x in the
  bubble; [arrowUp] puts the arrow on the top edge (the bubble is below the tag), else on the bottom edge.

- `fun placesBelow(targetTop: Int, targetBottom: Int, height: Int, safeTop: Int, bottomLimit: Int, shadowMargin: Int,` (L223)
  Whether the callout goes below the tag (arrow up), as iOS `CYLTagCalloutView.placesBelow`. Above first (the contract); below
  when it does not fit above, or when it would cover the header (the section header above a first-row tag) and it fits below;
  above when neither side is free of the header and below does not fit. Pure: all values are in screen pixels.
  [height] is the bubble view's height, which includes [shadowMargin] on both sides; the drawn bubble is smaller.

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLTagView.kt

The TagCollectionView part of the pod (`TagCollectionView/TagCollectionView`): CYLTagView, its models and cells.

- `const val kTagCollectionViewCellsHorizonMargin = 12f` (L26)
  `kTagCollectionViewCellsHorizonMargin`: the space between tags, dp.

- `const val kTagCollectionViewToLeftMargin = 16f` (L30)
  `kTagCollectionViewToLeftMargin`, dp.

- `const val kTagCollectionViewToTopMargin = 12f` (L34)
  `kTagCollectionViewToTopMargin`, dp.

- `const val kTagCollectionViewToRightMargin = 16f` (L38)
  `kTagCollectionViewToRightMargin`, dp.

- `const val kTagCollectionViewToBottomtMargin = 10f` (L42)
  `kTagCollectionViewToBottomtMargin` (the iOS spelling), dp.

- `class CYLTagModel` (L48)
  `CYLTagModel`: a tag's title and its size: the title's width at 17 sp plus 50, and the height of that font (at
  least 35), dp.

- `var title: String = ""` (L52)
  The title; setting it measures the tag again.

- `fun updateSizeForTraitCollection(fontScale: Float?)` (L67)
  `-updateSizeForTraitCollection:`: measures the tag at `fontScale` (null: the system's text size).

- `fun modelWithTitle(title: String?): CYLTagModel = CYLTagModel().also { it.title = title ?: "" }` (L78)
  `+modelWithTitle:`.

- `fun titleFontForTraitCollection(fontScale: Float?): CYLFont = CYLScaledSystemFont(17f, fontScale ?: android.content.res.Resources.getSystem().configuration.fontScale)` (L84)
  `+titleFontForTraitCollection:`: 17 sp, scaled with the text size.

- `class CYLTagGroup` (L92)
  `CYLTagGroup`: a section of a `CYLTagView`: its name, its tags, whether it is opened, and how many tags fit on its
  first row (dp).

- `var width: Float = 0f` (L98)
  The width of the view, dp (0 until laid out: then the screen's width).

- `var height: Float = 38f` (L103)
  The header's height, dp (38).

- `var opened: Boolean = false` (L108)
  Whether every tag shows (`isOpened`).

- `val isOpened: Boolean get() = opened` (L113)
  `isOpened`.

- `var itemArr: List<CYLTagModel> = emptyList()` (L120)
  The tags; setting them computes the rows again.

- `var cellsCountArrayPerRowInSections: List<Int>?` (L134)
  The number of tags of each row at the view's width.

- `fun firstRowCellCountForContentWidth(contentWidth: Float): Int` (L165)
  `-firstRowCellCountForContentWidth:`: how many tags fit on the first row of `contentWidth` dp.

- `class CYLTagCell @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : FrameLayout(context, attrs)` (L182)
  `CYLTagCell`: a tag: white text on a blue pill (the XIB's label).

- `var model: CYLTagModel? = null` (L204)
  The tag shown.

- `interface CYLTagHeaderCellDelegate` (L223)
  `CYLTagHeaderCellDelegate`: the header's button was tapped.

- `fun headerViewDidTapNameView(headerCell: CYLTagHeaderCell, index: Int)` (L227)
  `-headerViewDidTapNameView:index:`.

- `class CYLTagHeaderCell @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : ViewGroup(context, attrs)` (L233)
  `CYLTagHeaderCell`: a section header: the group's name and a More / Less button that opens or closes the group.

- `var group: CYLTagGroup? = null` (L257)
  The group shown.

- `fun btnClick()` (L279)
  `-btnClick`: opens or closes the group and tells the delegate.

- `class CYLTagView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : FrameLayout(context, attrs), CYLTagHeaderCellDelegate` (L304)
  `CYLTagView`: the sections of a `CYLMenuDataSource` as blue tags in left-aligned rows, each section showing its
  first row until its header's More button opens it. Lengths are dp.

- `var showHeader: Boolean = true` (L312)
  Whether the section headers show (`isShowHeader`).

- `val isShowHeader: Boolean get() = showHeader` (L321)
  `isShowHeader`.

- `var groups: MutableList<CYLTagGroup> = ArrayList()` (L326)
  The sections, made by `reloadMenuData`.

- `fun tagView(context: Context): CYLTagView = CYLTagView(context)` (L343)
  `+tagView` (`makeTagView()` in Swift).

- `fun reloadMenuData()` (L349)
  `-reloadMenuData`: reads the data source again.

- `fun numberOfVisibleItemsInSection(section: Int): Int = content.visibleCount(section)` (L378)
  The number of tags a section shows now (for tests).

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLTypes.kt

- `data class CYLEdgeInsets(val top: Float = 0f, val left: Float = 0f, val bottom: Float = 0f, val right: Float = 0f)` (L9)
  The Android forms of the UIKit value types the iOS API uses. Lengths are dp and font sizes sp, as points on iOS.

- `val ZERO = CYLEdgeInsets()` (L13)
  `UIEdgeInsetsZero`.

- `data class CYLSize(val width: Float = 0f, val height: Float = 0f)` (L20)
  `CGSize` in dp.

- `val ZERO = CYLSize()` (L24)
  `CGSizeZero`.

- `data class CYLOffset(val horizontal: Float = 0f, val vertical: Float = 0f)` (L31)
  `UIOffset` in dp.

- `val ZERO = CYLOffset()` (L35)
  `UIOffsetZero`.

- `data class CYLPoint(val x: Float = 0f, val y: Float = 0f)` (L42)
  `CGPoint` / `CGRect` in dp (view coordinates).

- `data class CYLRect(val x: Float = 0f, val y: Float = 0f, val width: Float = 0f, val height: Float = 0f)` (L47)
  `CGRect` in dp.

- `data class CYLIndexPath(val item: Int, val section: Int) : Comparable<CYLIndexPath>` (L57)
  `NSIndexPath` of a list: an item in a section.

- `data class CYLFont(val size: Float, val typeface: Typeface = Typeface.DEFAULT)` (L69)
  `UIFont`: a size in sp and a typeface.

- `fun bold(): CYLFont = if (isBold) this else copy(typeface = Typeface.create(typeface, Typeface.BOLD))` (L73)
  The same font in bold (Bold Text).

- `fun systemFont(size: Float) = CYLFont(size, Typeface.DEFAULT)` (L80)
  `+[UIFont systemFontOfSize:]`.

- `const val WEIGHT_SEMIBOLD = 600` (L83)
  The weight of a semibold font on the CSS / Android scale (400 regular, 700 bold).

- `fun systemFont(size: Float, weight: Int): CYLFont` (L90)
  The system font in `weight` (100...900). Android 9 (API 28) and later draw any weight; earlier ones only have regular
  and bold, so a weight of [WEIGHT_SEMIBOLD] or more is bold there (the closest to semibold they can draw).

- `fun semiboldSystemFont(size: Float) = systemFont(size, WEIGHT_SEMIBOLD)` (L98)
  `+[UIFont systemFontOfSize:weight:]` with `UIFontWeightSemibold`: the table header look.

- `fun boldSystemFont(size: Float) = CYLFont(size, Typeface.DEFAULT_BOLD)` (L102)
  `+[UIFont boldSystemFontOfSize:]`.

- `object CYLControlState` (L109)
  `UIControlState`: bit flags, `NORMAL` being none of them.

- `object CYLColor` (L119)
  Colors as ARGB ints, the Android form of `UIColor`.

- `fun white(white: Float, alpha: Float = 1f): Int` (L122)
  `+[UIColor colorWithWhite:alpha:]`.

- `fun rgb(red: Float, green: Float, blue: Float, alpha: Float = 1f): Int = Color.argb(` (L129)
  `+[UIColor colorWithRed:green:blue:alpha:]` with components 0...1.

- `fun withAlpha(color: Int, alpha: Float): Int = (color and 0x00FFFFFF) or ((alpha.coerceIn(0f, 1f) * 255 + 0.5f).toInt() shl 24)` (L136)
  `-[UIColor colorWithAlphaComponent:]`.

- `fun fromHex(hex: String?, alpha: Float = 1f): Int?` (L140)
  A "RRGGBB" or "#RRGGBB" hex string with `alpha`, or null when it does not parse.

- `val APP_TINT: Int = Color.rgb(42, 185, 160)` (L148)
  `CYLAppTintColor` (42, 185, 160).

- `const val CLEAR: Int = Color.TRANSPARENT` (L151)
  `+[UIColor clearColor]`.

## android/merged/library/src/main/java/com/licrafter/tagview/DIRECTION.kt

- `enum class DIRECTION` (L7)
  Where a tag sits relative to the group's dot. "Straight" tags are reached by a diagonal line (tilt distance);
  the others by a vertical line (vertical distance) then a horizontal one under the tag.

- `val isLeft: Boolean` (L22)
  True for the five directions on the left of the dot.

## android/merged/library/src/main/java/com/licrafter/tagview/TagAdapter.kt

- `abstract class TagAdapter` (L14)
  Supplies the tags of a TagViewGroup, as a PagerAdapter supplies pages: `getCount()` tags, each made by
  `getItem(position)`. Call `notifyDataSetChanged()` after the data changes; the group rebuilds its tags.

- `fun instantiateItem(container: ViewGroup, position: Int): ITagView` (L25)
  Makes the tag at `position` and adds it to `container` (the TagViewGroup).

- `fun destroyItem(container: ViewGroup, position: Int, tagView: ITagView)` (L38)
  Removes the tag made for `position` from `container`.

## android/merged/library/src/main/java/com/licrafter/tagview/TagViewGroup.kt

- `class TagViewGroup @JvmOverloads constructor(` (L36)
  A group of tags attached to a point of a picture: a dot (outer and inner circle), lines from the dot to each tag,
  and up to DEFAULT_MAX_TAG tags around it in the ten DIRECTION positions. The dot sits at `setPercent(x, y)` of the
  view's size and moves inward when its tags would leave the view. Tags come from a TagAdapter. Taps on the dot or a
  tag, long presses and drags of the dot are reported through the listeners.
  An API-compatible Kotlin reimplementation of shellljx/TagViewGroup (no code copied: the original is GPL-3.0).

- `class ItemInfo` (L45)
  A tag the adapter made, with its position and the frame it was laid out in.

- `fun getTagList(): List<ITagView>` (L194)
  The tags the adapter made, in order (the ripple included when the adapter made one).

- `fun setPercent(percentX: Float, percentY: Float)` (L255)
  Places the dot at (percentX, percentY) of the view's size (0...1 each).

- `fun setLinesRatio(ratio: Float)` (L353)
  How much of each line is drawn, 0...1 (animated by LINES_RATIO).

- `fun setTagAlpha(alpha: Float)` (L363)
  The tags' alpha, 0...1 (animated by TAG_ALPHA); the dot and the ripple stay opaque.

- `const val DEFAULT_RADIUS: Int = 8` (L393)
  The dot's outer radius, dp.

- `const val DEFAULT_INNER_RADIUS: Int = 4` (L395)
  The dot's inner radius, dp.

- `const val DEFAULT_V_DISTANCE: Int = 28` (L397)
  The vertical line to a non-straight tag, dp.

- `const val DEFAULT_TILT_DISTANCE: Int = 20` (L399)
  The diagonal line to a straight tag, dp.

- `const val DEFAULT_LINES_WIDTH: Int = 1` (L401)
  The lines' width, dp.

- `const val DEFAULT_MAX_TAG: Int = 6` (L403)
  At most this many tags per group.

## android/merged/library/src/main/java/com/licrafter/tagview/utils/DipConvertUtils.kt

- `object DipConvertUtils` (L8)
  dp to px conversion.

## android/merged/library/src/main/java/com/licrafter/tagview/utils/TagGroupUtils.kt

- `object TagGroupUtils` (L13)
  Geometry shared by TagViewGroup's measure, layout and drawing.

- `fun getTagViewUsed(group: TagViewGroup): IntArray` (L20)
  The space the group's tags need around the dot: [left, top, right, bottom] in px. Never less than the dot's
  radius on each side.

- `fun getStartPoint(group: TagViewGroup, child: ITagView): Point` (L52)
  The top-left corner of `child` for the group's current dot, from its direction and size.

## android/merged/library/src/main/java/com/licrafter/tagview/views/ITagView.kt

- `interface ITagView` (L9)
  A view a TagViewGroup lays out around its dot: a tag (TagTextView) or the ripple (RippleView). The size and
  layout methods are the ones every android.view.View already has.

## android/merged/library/src/main/java/com/licrafter/tagview/views/RippleView.kt

- `class RippleView @JvmOverloads constructor(` (L22)
  The ripple that pulses around a TagViewGroup's dot: a filled circle that grows to the maximum radius while it
  fades, repeated while the view is attached. The group centers it on the dot whatever its direction. Animations
  stop when the system's animator scale is 0 (Remove animations).

## android/merged/library/src/main/java/com/licrafter/tagview/views/TagTextView.kt

- `class TagTextView @JvmOverloads constructor(` (L15)
  A text tag of a TagViewGroup: white text with a soft shadow, readable on a photo, laid out on the side its
  direction says. Text size follows the system font scale (sp).

## android/merged/library/src/main/java/me/kaede/tagview/Constants.kt

- `internal object Constants` (L8)
  Default values of the tag view; dimensions are in dp or sp, not px.

## android/merged/library/src/main/java/me/kaede/tagview/LogUtil.kt

- `internal object LogUtil` (L5)

## android/merged/library/src/main/java/me/kaede/tagview/OnTagClickListener.kt

- `fun interface OnTagClickListener` (L6)
  Listener for tag clicks.

## android/merged/library/src/main/java/me/kaede/tagview/OnTagDeleteListener.kt

- `fun interface OnTagDeleteListener` (L6)
  Listener for tag deletion.

## android/merged/library/src/main/java/me/kaede/tagview/ResolutionUtil.kt

- `internal object ResolutionUtil` (L6)

## android/merged/library/src/main/java/me/kaede/tagview/Tag.kt

- `class Tag(` (L9)
  Tag entity: its text, colors, size, corner radius, border, background and the delete indicator.

## android/merged/library/src/main/java/me/kaede/tagview/TagView.kt

- `open class TagView @JvmOverloads constructor(` (L24)
  Android TagView widget: lays tags out in lines, each tag a colored, rounded label with an optional delete
  indicator.

- `var isSingleSelectionMode: Boolean = false` (L48)
  Single selection (kaedea/android-tagview PR #21, opt-in here so existing layouts keep their colors): a tap
  checks the tag (`checkedLayoutColor`) and unchecks the others (their own colors). The checked positions are kept
  in `checkedTagArray`.

- `var checkedLayoutColor: Int = android.graphics.Color.GREEN` (L53)
  The background color of the checked tag in single selection mode (PR #21 used green).

- `val checkedTagArray = android.util.SparseBooleanArray()` (L58)
  The checked state of each tag position (single selection mode).

- `fun setMaxWidth(width: Int)` (L224)
  The width the lines may take, in pixels (issue #24's `setMaxWith`): fixes it instead of following the view's
  width, for example in list items measured before they have a width. 0 follows the view again.

- `fun replaceAtPosition(position: Int, tag: Tag)` (L235)
  Replaces the tag at `position` and updates only its view (issues #10, #16, #19: changing one tag's colors no
  longer needs removing and adding every tag).

- `fun setTagChecked(position: Int, checked: Boolean)` (L248)
  Checks or unchecks the tag at `position` (single selection mode: checking unchecks the others), shown with
  `checkedLayoutColor` and `checkedTextColor` (issue #16).

- `var checkedTextColor: Int? = null` (L263)
  The text color of a checked tag (issue #16); null keeps the tag's own text color.

- `var isSingleLine: Boolean = false` (L268)
  Every tag on one line, never wrapped (issue #29): put the TagView in a HorizontalScrollView to scroll them.
