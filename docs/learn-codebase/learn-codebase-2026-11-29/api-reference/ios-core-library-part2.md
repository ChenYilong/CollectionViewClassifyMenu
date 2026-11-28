# ios-core: library (part 2 of 5)

## CollectionViewClassifyMenu/Class/Other/Tool/CYLMenuDataSource.swift

 CYLMenuDataSource.swift
 CollectionViewClassifyMenu
 Host-owned data and callbacks shared by every menu in the component.
 Translated from Objective-C to Swift (2026, docs/Swift-Migration.md). The protocols stay `@objc` with their
 Objective-C selectors: their methods are optional and the core's Objective-C tests implement them.

- `@objc public enum CYLMenuItemType: Int` (L15)

- `case tag = 0` (L19)
  A tag (the default).

- `case create` (L25)
  "+ 新建标签": an outlined action with the core's plus icon (`CYLTagCreateCell`), never selected. Its title from
  `menuTitleForItem(at:)` is the name to create, shown as "新建标签：<name>" (localized); an empty title shows
  "新建标签". A tap calls `menu(_:didRequestNewItemWithName:at:)`.

- `@objc public protocol CYLMenuDataSource: NSObjectProtocol` (L31)

- `func numberOfSectionsInMenu() -> Int` (L36)
  The number of sections.

- `func menuNumberOfItems(inSection section: Int) -> Int` (L41)
  The number of items in a section.

- `func menuTitle(forSection section: Int) -> String` (L46)
  A section's title.

- `func menuTitleForItem(at indexPath: IndexPath) -> String` (L52)
  An item's title.

- `optional func menuImageForItem(at indexPath: IndexPath) -> UIImage?` (L58)
  Icon drawn before the item's title. Return `nil` for a text-only item.

- `optional func menuSelectedImageForItem(at indexPath: IndexPath) -> UIImage?` (L64)
  Icon shown while the item is selected; `nil` keeps the normal icon.

- `optional func menuAnimationURLForItem(at indexPath: IndexPath) -> URL?` (L72)
  Animated icon (a Lottie .json, .pag, .riv, .svga or .gif file), played like a CYLTabBarController tab icon: it plays
  when a tap selects the item. Needs the library's CYLTabBarController subspec in the app (e.g.
  `pod 'CYLTabBarController/Lottie'`); without it the image is shown.

- `optional func menuSubtitleForItem(at indexPath: IndexPath) -> String?` (L79)
  The item's subtitle, shown in a callout with an arrow on a long press when the list's `longPressAction` includes
  `CYLTagLongPressActions.callout` (a longer description of a short title). `nil` or empty: none.

- `optional func menuAnimationRestingProgressForItem(at indexPath: IndexPath) -> NSNumber?` (L86)
  The frame (0...1) an animated icon shows while its item is not selected. Default (`nil`) 0, the first frame, as
  a CYLTabBarController tab icon; for a file whose first frame is empty, e.g. 1 for the last.

- `optional func menuStyle(forSection section: Int) -> CYLMenuStyle?` (L94)
  The look of one section's tags (colors, fonts, borders, icon colors, title and image layout), e.g. dark tags for
  white icons. Return `nil` for the list's style. Item height, spacing and insets always come from the list's
  style. Return the same object for as long as it does not change.

- `optional func menuStyleForItem(at indexPath: IndexPath) -> CYLMenuStyle?` (L101)
  The look of one item, over its section's (for example an outlined "+ 新建标签" action among the tags). Return
  `nil` for the section's style. Metrics come from the list's style, as for sections.

- `optional func menuImage(forSection section: Int) -> UIImage?` (L107)
  Icon drawn before the section title. Return `nil` for no icon.

- `optional func menuAccessoryView(forSection section: Int) -> UIView?` (L115)
  View placed at the trailing edge of the section header, such as a picker button. The menu sizes it with
  `sizeThatFits(_:)` and does not retain it beyond the header's lifetime; return the same instance to keep its
  state.

- `optional func menuItemIsEnabled(at indexPath: IndexPath) -> Bool` (L121)
  Disabled items are drawn dimmed and cannot be selected. Defaults to true.

- `optional func menuItemIsExclusive(at indexPath: IndexPath) -> Bool` (L128)
  Selecting an exclusive item clears the other items in its section and vice versa (for example "全部").
  Defaults to false.

- `optional func menuItemIsSelectable(at indexPath: IndexPath) -> Bool` (L136)
  False for an item that acts like a button in any selection mode, such as "+ 新建标签": a tap is reported through
  `menu(_:didSelectItemAt:)` but the item never stays selected and the selection does not change. Defaults to
  true.

- `optional func menuItemType(at indexPath: IndexPath) -> CYLMenuItemType` (L142)
  Tag (default) or "+ 新建标签" (`CYLMenuItemType.create`).

- `optional func menuAccessibilityHintForItem(at indexPath: IndexPath) -> String?` (L149)
  The VoiceOver hint of an item (what a tap does, for example "Double-tap to remove"), already localized. The
  label is the item's title, the traits are set by the list. Defaults to `nil`.

- `optional func menuShowsMoreButton(inSection section: Int) -> Bool` (L157)
  True shows a More button (three dots, `CYLMenuStyle.moreButtonImage`) at the trailing edge of the section
  header, whose action the host decides in `menu(_:didTapMoreButtonInSection:)` (for example refreshing the
  section). Defaults to false. Only `CYLTagListView` shows it.

- `optional func menuAccessibilityLabelForMoreButton(inSection section: Int) -> String?` (L164)
  What VoiceOver, Voice Control and the Large Content Viewer call the section's More button, already localized:
  say what its action does, for example "换一批" (refresh). `nil` (the default) uses "<section title> 更多操作".

- `optional func menuItemIsDeletable(at indexPath: IndexPath) -> Bool` (L172)
  True shows a delete indicator ("×", `CYLMenuStyle.deleteIndicatorTitle`) after the item's title, as
  android-tagview's deletable tags; a tap on it (or VoiceOver's "Delete" action) deletes the item. Defaults to
  false. Only `CYLTagListView` shows it.

- `optional func menuRemoveItem(at indexPath: IndexPath)` (L180)
  Remove the item from your data: the delete indicator of a deletable item was tapped. The list then reloads and
  calls `menu(_:didDeleteItemAt:)`. Without it, the list only reports the tap (the host removes the item and calls
  `reloadMenuData()`).

- `optional func menuMoveItem(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)` (L186)
  Move the item in your data: the user reordered the items of a section (`CYLTagListView.allowsReordering`).

- `optional func menuSectionAllowsEditing(_ section: Int) -> Bool` (L193)
  Whether a section takes part in `CYLTagListView`'s editing mode (delete indicators, reordering); true when not
  implemented.

- `optional func menuCacheKey(forSection section: Int) -> String` (L200)
  The key `CYLTagListView` saves a section's titles under in its cache (`cachePolicy`), stable when sections come
  and go (e.g. "mine"); the section's index when not implemented.

- `optional func menuShowsClearButton(forSection section: Int) -> Bool` (L208)
  Shows a clear button (the bundle's trash icon, `CYLMenuStyle.clearButtonImage`) at the trailing end of the
  section's header, its top and bottom aligned with the title's; a tap calls `menu(_:didTapClearButtonInSection:)`
  and `CYLTagListView.clearButtonHandler`. False when not implemented.

- `optional func menuIdentifierForItem(at indexPath: IndexPath) -> String` (L215)
  The item's stable identifier (a database id), kept by `CYLTagListView`'s cache and sync so that a reorder or a
  rename never loses what the item stands for; its title when not implemented.

- `optional func menuRenameItem(at indexPath: IndexPath, to title: String)` (L223)
  Rename the item in your data. Implementing it shows `CYLTagListView`'s rename indicator (a pencil before the
  delete indicator) in editing mode; a tap fills the add control with the title and raises the keyboard, and its
  submit calls this, then the list reloads, saves its cache and calls `menu(_:didRenameItemAt:to:)`.

- `@objc public protocol CYLMenuDelegate: NSObjectProtocol` (L230)

- `optional func menu(_ menu: Any, shouldSelectItemAt indexPath: IndexPath) -> Bool` (L236)
  Return false to ignore a tap. Not called for disabled items.

- `optional func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath)` (L243)
  Called for every accepted tap, including in `CYLMenuSelectionMode.none`. For a `CYLMenuItemType.create` item,
  only when the delegate does not implement `menu(_:didRequestNewItemWithName:at:)`.

- `optional func menu(_ menu: Any, didRequestNewItemWithName name: String, at indexPath: IndexPath)` (L250)
  A tap on a "+ 新建标签" item (`CYLMenuItemType.create`): `name` is its title from the data source, empty when
  the host should ask for one.

- `optional func menu(_ menu: Any, didDeselectItemAt indexPath: IndexPath)` (L256)
  Called when a tap or another selection removes an item from the selection.

- `optional func menu(_ menu: Any, didChangeSelectedItems indexPaths: [IndexPath])` (L263)
  Called once after a tap that changed the selection, after the select and deselect callbacks: the place to
  refresh content filtered by the selection.

- `optional func menu(_ menu: Any, didConfirmSelectedItems indexPaths: [IndexPath])` (L269)
  The selection a filter panel confirmed (`CYLMultipleFilterController`).

- `optional func menu(_ menu: Any, didChangeExpanded expanded: Bool, inSection section: Int)` (L275)
  Called after a section is expanded or collapsed by the user or the host.

- `optional func menu(_ menu: Any, didChangeContentHeight height: CGFloat)` (L282)
  Called when the height needed to show the whole menu changes, so that a host can resize an embedded,
  non-scrolling menu.

- `optional func menu(_ menu: Any, didTapMoreButtonInSection section: Int)` (L289)
  The More button of a section header was tapped (`menuShowsMoreButton(inSection:)`); the host runs its own
  action, for example loading other items and calling `reloadMenuData()`.

- `optional func menu(_ menu: Any, didDeleteItemAt indexPath: IndexPath)` (L296)
  The delete indicator of a deletable item was tapped (as android-tagview's onTagDeleted). When the data source
  implements `menuRemoveItem(at:)`, the item is already gone and `indexPath` is where it was.

- `optional func menu(_ menu: Any, didChangeEditing editing: Bool)` (L302)
  `CYLTagListView` entered (true) or left (false) editing mode (`setEditing(_:animated:)`).

- `optional func menu(_ menu: Any, didFinishEditingWithTitles titles: [String: [String]])` (L309)
  `CYLTagListView`'s editing ended: the edited sections' titles by cache key (`cacheKey(forSection:)`), in their
  new order, already saved to its cache; upload them to your server here.

- `optional func menu(_ menu: Any, didFinishEditingWithItems items: [String: [CYLTagListCacheItem]])` (L316)
  The same edited sections as items (stable identifier and title, `menuIdentifierForItem(at:)`): upload these when
  your items have ids.

- `optional func menu(_ menu: Any, didRenameItemAt indexPath: IndexPath, to title: String)` (L322)
  `CYLTagListView` renamed an item in editing mode (`menuRenameItem(at:to:)`), already saved to its cache.

- `optional func menu(_ menu: Any, didTapClearButtonInSection section: Int)` (L329)
  The clear button of `section`'s header was tapped (`menuShowsClearButton(forSection:)`): clear the section's data
  (and reload).

- `optional func menu(_ menu: Any, didLongPressItemAt indexPath: IndexPath)` (L335)
  A long press on an item that did not move it (AndroidTagView's onTagLongClick).

- `optional func menu(_ menu: Any, didMoveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)` (L341)
  The user moved an item; the data source has moved it.

- `optional func menu(_ menu: Any, didBeginDraggingSelectedItemAt indexPath: IndexPath)` (L347)
  A selected item started moving (AndroidTagView's onSelectedTagDrag).

- `optional func menu(_ menu: Any, didChangeReordering reordering: Bool)` (L354)
  A drag to reorder items began (`reordering` is true) or ended, was dropped or was cancelled (false), once per change.
  A host that embeds the list in a scroll view locks that scroll view while it is true.

- `optional func menu(_ menu: Any, didChangeSmearing smearing: Bool)` (L361)
  A smear selection (`allowsSmearSelection`) began (`smearing` is true) or ended or was cancelled (false), once per
  change. A host that embeds the list in a scroll view locks that scroll view while it is true.

## CollectionViewClassifyMenu/Class/Other/Tool/CYLMenuKeys.swift

 CYLMenuKeys.swift
 CollectionViewClassifyMenu
 Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).

- `public let kDataSourceSectionKey: String = "Items"` (L13)
  The key of a section's items in the dictionaries `CYLClassifyMenuViewController` builds from its data source.

- `public let kDataSourceCellTextKey: String = "Item_Title"` (L18)
  The key of an item's title in those dictionaries.

- `public let kDataSourceCellPictureKey: String = "Picture"` (L23)
  The key of an item's picture (a `UIImage`, or a non-empty string for the bundled default) in those dictionaries.

- `public final class CYLMenuKeys: NSObject` (L30)
  The same keys for Objective-C, which cannot see Swift global constants: `CYLMenuKeys.dataSourceSectionKey` in
  place of `kDataSourceSectionKey` (docs/Swift-Migration.md, "Objective-C API changes").

- `@objc public static let dataSourceSectionKey = kDataSourceSectionKey` (L35)
  `kDataSourceSectionKey`.

- `@objc public static let dataSourceCellTextKey = kDataSourceCellTextKey` (L40)
  `kDataSourceCellTextKey`.

- `@objc public static let dataSourceCellPictureKey = kDataSourceCellPictureKey` (L45)
  `kDataSourceCellPictureKey`.

## CollectionViewClassifyMenu/Class/Other/Tool/CYLMenuResources.swift

 CYLMenuResources.swift
 CollectionViewClassifyMenu
 The component's single resource bundle, CYLClassifyMenuResources.bundle: images, XIBs and the localized strings
 (<language>.lproj/CYLClassifyMenu.strings).
 Translated from Objective-C to Swift (2026, docs/Swift-Migration.md). Swift has no macros: the core's lookup is the
 function `CYLMenuLocalizedString(_:)`, as each example has its own lookup function over its own bundle (AGENTS.md,
 localization). The Objective-C selectors stay for the core's Objective-C tests.

- `public func CYLMenuLocalizedString(_ key: String) -> String` (L18)
  Looks up a key in the component's string table, in the component's language (`CYLMenuResources.currentLanguage`):
  the core's lookup, always through CYLClassifyMenuResources.bundle.

- `public final class CYLMenuResources: NSObject` (L27)
  The core's resource lookups (one per kind of resource), always through CYLClassifyMenuResources.bundle: callers
  never name the bundle.

- `@objc public static let bundle: Bundle =` (L40)
  The bundle: the package's resources under Swift Package Manager; otherwise next to the component's code
  (CocoaPods resources) or in the main bundle.

- `@objc public static let imagesBundle: Bundle? = bundle.url(forResource: "CYLClassifyMenuImages", withExtension: "bundle")` (L62)
  The core's image folder, `CYLClassifyMenuImages.bundle` inside `bundle` (new images live there as files, e.g.
  "cyl_trash"); nil if it is missing.

- `public static func image(named name: String) -> UIImage?` (L69)
  An image of the component: from `imagesBundle` first, then the bundle's asset catalog (e.g. "cyl_tag_plus").

- `@objc public static var availableLanguages: [String]` (L81)
  Languages the bundle has strings for, e.g. ["en", "zh-Hans", "zh-Hant"].

- `@objc public static var preferredLanguage: String?` (L90)
  Language of the component's strings. `nil` (the default) follows the user's preferred languages, even when the
  host app does not declare them; set it to switch languages inside the app. Views created afterwards use the new
  language.

- `@objc public static var currentLanguage: String` (L107)
  The language used now: `preferredLanguage` when available, else the best match for the user's preferred
  languages, else English.

- `public static func localizedString(forKey key: String) -> String` (L122)
  The string for `key` in the current language; English, then the key itself, when it is missing.

- `public static func localizedString(forKey key: String, language: String) -> String` (L131)
  The string for `key` in `language`, for hosts that show several languages; English, then the key itself, when
  it is missing.

## CollectionViewClassifyMenu/Class/Other/Tool/CYLTagMetrics.swift

 CYLTagMetrics.swift
 CollectionViewClassifyMenu
 Fonts and heights of the classify menu's tags (was CYLParameterConfiguration.h, created by 陈宜龙 (Chen Yilong) on
 16/1/6). Translated from Objective-C to Swift (2026, docs/Swift-Migration.md): the inline functions and macros are
 class members, which Swift and the core's Objective-C tests both call.

- `public final class CYLTagMetrics: NSObject` (L17)
  Fonts and heights of tags: the title font scaled for Dynamic Type (capped at `maximumFontScale`) and the height a
  tag needs for one line of a font.

- `@objc public static let maximumFontScale: CGFloat = 2` (L22)
  Largest multiple of the base size used for Dynamic Type, so tags stay usable at accessibility sizes.

- `@objc public static let titleFontSize: CGFloat = 16` (L27)
  The point size of the tags' title font at the default content size.

- `public static func scaledSystemFont(ofSize pointSize: CGFloat, traitCollection: UITraitCollection?) -> UIFont` (L43)
  System font of `pointSize` scaled for the content size category of `traitCollection` (the app's current
  category when it is `nil`), at most `maximumFontScale` times larger.

- `public static func tagHeight(for font: UIFont, minimumHeight: CGFloat) -> CGFloat` (L53)
  Tag height that fits one line of `font` and is never below `minimumHeight`.

- `public static func titleFont(for traitCollection: UITraitCollection?) -> UIFont` (L61)
  Tag title font for the given traits. Use it for both measuring and drawing.

## CollectionViewClassifyMenu/Class/TagList/CYLMenuFoldControl.swift

 CYLMenuFoldControl.swift
 CollectionViewClassifyMenu
 The fold control of CYLTagListView ("更多 ⌄"), given when the view is created: where it is (below the section as in
 a shopping app's review filter, in the section header as in the original classify menu, or as the last tag) and
 what it shows (icon and title, title only, icon only). Expanded, a control with an icon keeps only the icon, turned
 180°; a title-only control shows its collapse title. It is drawn by CYLTagFoldButton, a borderless CYLTagButton.
     let filter = CYLTagListView(foldControl: CYLMenuFoldControl(position: .footer, content: .icon))
 Translated from Objective-C to Swift (2026, docs/Swift-Migration.md); the positions were renamed
 (docs/component-architecture.md, "rename the fold control positions").

- `@objc public enum CYLMenuFoldControlPosition: Int` (L21)

- `case none = 0` (L25)
  No fold control: every row is shown.

- `case footer` (L29)
  Centered in the section's footer, below the tags, like a shopping app's review filter.

- `case headerTrailing` (L33)
  At the trailing edge of the section header, like the original classify menu.

- `case headerLeading` (L37)
  At the leading edge of the section header, before the section title.

- `case tail` (L44)
  The last item of the tags, like a search app's recent searches: folded, it is the last visible item (the hidden
  items make room for it on the last visible row); expanded, it follows the last item. A tap on it expands or
  collapses the section. With `.icon` content it is a circle with the bundle's chevron, outlined like the tags
  (`CYLTagFoldCell`).

- `@objc public enum CYLMenuFoldControlContent: Int` (L50)

- `case iconAndTitle = 0` (L54)
  "更多 ⌄"; expanded, the collapse title and the icon, turned ("收起 ⌃").

- `case title` (L58)
  "更多"; expanded, the collapse title ("收起").

- `case icon` (L62)
  "⌄"; expanded, the same icon, turned.

- `case titleAndIcon` (L67)
  "更多 ⌄" collapsed and "收起 ⌃" expanded: the title and the icon in both states (the icon turned 180° when
  expanded). In a configuration file: "titleAndIconAlways" ("titleAndIcon" is an older alias of `.iconAndTitle`).

- `open class CYLMenuFoldControl: NSObject, NSCopying` (L78)

- `open var position: CYLMenuFoldControlPosition` (L83)
  Where the control is.

- `open var content: CYLMenuFoldControlContent` (L88)
  What the control shows while the section is collapsed.

- `open var title: String` (L93)
  Shown while collapsed (with a title). Default: the localized "更多" (`CYLMenuExpand`).

- `open var collapseTitle: String` (L105)
  Shown while expanded by a title-only control. Default: the localized "收起" (`CYLMenuCollapse`).

- `open var image: UIImage` (L117)
  The icon, pointing down while collapsed. Default: the core's chevron (`cyl_fold_chevron`), drawn in `color`.

- `open var usesDefaultImage: Bool` (L129)
  True while `image` is the default chevron (no image was set).

- `open var color: UIColor?` (L136)
  Title and icon color. `nil` (the default) uses `CYLMenuStyle.foldControlColor`.

- `open var font: UIFont?` (L141)
  `nil` (the default): the footnote text style, scaled with Dynamic Type.

- `open var rotatesImageWhenExpanded = true` (L146)
  The icon turns 180° when expanded. True by default.

- `public required init(position: CYLMenuFoldControlPosition = .none, content: CYLMenuFoldControlContent = .icon)` (L158)
  A control at this position showing this content; the default is no fold control.

- `open func showsImage(whenExpanded expanded: Bool) -> Bool` (L169)
  Whether the control shows its icon in the expanded or collapsed state.

- `open func showsTitle(whenExpanded expanded: Bool) -> Bool` (L176)
  Whether the control shows its title in the expanded or collapsed state.

- `open func title(whenExpanded expanded: Bool) -> String?` (L190)
  The title shown in that state, or `nil`.

- `open var isSizeCapped: Bool` (L201)
  Whether the control is size-capped (its font stops at the footnote size of the `.large` content size category,
  its width at 40% of the header): the header controls and `.titleAndIcon`.

- `public func copy(with zone: NSZone? = nil) -> Any` (L208)
  An independent copy (the image and colors are shared).

- `func cylCopy() -> CYLMenuFoldControl` (L240)
  A typed copy (`NSCopying` returns `Any`).

## CollectionViewClassifyMenu/Class/TagList/CYLMenuStyle.swift

 CYLMenuStyle.swift
 CollectionViewClassifyMenu
 Appearance of CYLTagListView. Copy a preset and change what you need.
 Each tag is drawn like a CYLFlatDesignTabBarItem of CYLTabBarController, laid out horizontally (icon, then title)
 instead of vertically: per-state title text attributes and icon colors, image/title position adjustments, image
 insets and layoutCentered for icon-only or title-only tags. Its box (background, border, corner radius, margin) is
 configured like a CYLBadgeView, through one CYLTagAppearance per state.
 Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).

- `@objc public enum CYLTagImagePlacement: Int` (L29)

- `case leading = 0` (L33)
  Icon, then title (the default).

- `case trailing` (L37)
  Title, then icon, e.g. "更多 ⌄".

- `case top` (L41)
  The icon above the title, both centered, as a tab bar item or a placeholder (raw value 2).

- `case bottom` (L45)
  The icon below the title, both centered (raw value 3).

- `@objc public enum CYLTagContentAlignment: Int` (L51)

- `case center = 0` (L55)
  Centered in the tag (the default).

- `case leading` (L60)
  At the leading margin: the title (or the icon) starts there and the other follows it, e.g. a search suggestion
  "苹果官方社区… [热]" whose title is truncated so the icon after it stays visible.

- `@objc public enum CYLTagBackgroundStyle: Int` (L66)

- `case flat = 0` (L70)
  The solid color of each state's appearance (the default).

- `case liquidGlass` (L76)
  A Liquid Glass material behind the content, tinted with the state's EXPLICIT `backgroundColor` (an unset one is ignored: frosted default), drawn only where the system
  draws Liquid Glass (`CYLAnimatedItemView.isLiquidGlassActive()`: iOS 26 and later, the rule of CYLTabBarController);
  elsewhere the style is ignored and the tag stays flat.

- `@objc public enum CYLTagRowAlignment: Int` (L82)

- `case leading = 0` (L86)
  From the leading edge (the default).

- `case center` (L90)
  Centered.

- `case trailing` (L95)
  From the trailing edge: each row's first tag at the trailing edge, the next ones before it (AndroidTagView's
  container_gravity="right").

- `@objc public enum CYLTagDeleteIndicatorPlacement: Int` (L101)

- `case trailing = 0` (L105)
  After the title (the default).

- `case leading` (L109)
  Before the content, as AndroidTagView's cross in right-to-left tags.

- `open class CYLMenuStyle: NSObject, NSCopying` (L118)
  The look of a `CYLTagListView`'s tags, section headers and fold controls. Gray bordered tags with a green selection
  by default (`CYLMenuStyle()`); copy a preset (`tagCloud()`, `tagContainer()`, `gridStyle(itemsPerRow:)`) and change
  what you need.

- `open private(set) var normalAppearance: CYLTagAppearance` (L128)
  Normal tags. The appearance objects belong to the style: change their properties.

- `open private(set) var selectedAppearance: CYLTagAppearance` (L133)
  Selected tags.

- `open private(set) var disabledAppearance: CYLTagAppearance` (L138)
  Disabled tags.

- `open var highlightedBackgroundColor: UIColor?` (L144)
  The background of a tag while a finger is on it (as android-tagview's layoutColorPress). `nil` (the default)
  keeps the state's background.

- `open var tagContentInsets: UIEdgeInsets` (L150)
  The content insets of every state's appearance at once (as android-tagview's textPadding…); reading it gives the
  normal appearance's. {5, 10, 5, 10} by default.

- `open var deleteIndicatorTitle = CYLMenuStyle.defaultDeleteIndicatorTitle` (L167)
  Shown after the title of a deletable tag (`menuItemIsDeletable(at:)`, `CYLTag.isDeletable`); a tap on it deletes
  the tag. Defaults to "×" (as android-tagview's deleteIcon).

- `open var deleteIndicatorColor: UIColor?` (L172)
  Its color; `nil` (the default) uses the state's text color.

- `open var deleteIndicatorFont: UIFont?` (L177)
  Its font; `nil` (the default) uses the state's title font. Scaled for Dynamic Type as the title is.

- `open var deleteIndicatorLineWidth: CGFloat = 0` (L183)
  Draws the delete indicator as a cross of two lines this wide instead of `deleteIndicatorTitle` (AndroidTagView's
  tag_cross_line_width); 0 (the default) draws the title.

- `open var deleteIndicatorWidth: CGFloat = 0` (L189)
  The width of the delete indicator's area (tag_cross_width); 0 (the default) fits the title, or the font's line
  height for a drawn cross.

- `open var deleteIndicatorPadding: CGFloat = 0` (L194)
  Space between the area's edges and a drawn cross (tag_cross_area_padding). 0 by default.

- `@objc open var editingIndicatorSpacing: CGFloat = 10` (L201)
  The space between the two editing icons of a renamable tag in `CYLTagListView`'s editing mode (the edit icon and
  the delete icon, `CYLTagButton.editingIndicatorsView`, a `CYLAnimatedItemStackView`). 10 points by default; a
  negative value is 0.

- `@objc open var clearButtonImage: UIImage?` (L207)
  The image of a section header's clear button (`CYLMenuDataSource.menuShowsClearButton(forSection:)`); nil: the
  bundle's trash icon ("cyl_trash"), drawn as a template.

- `@objc open var clearButtonColor: UIColor?` (L212)
  The color of the clear button; nil: `headerTextColor`.

- `@objc open var editingIndicatorInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)` (L220)
  The margins around the two editing icons as a whole (the stack view `CYLTagButton.editingIndicatorsView`): left
  from the title, right to the tag's padding, top and bottom within the tag. Left 4 and right 0 points by default
  (the tag's own padding follows the cross); negative values are 0. With `editingIndicatorSpacing` (between the
  icons) it sets every space of the icons.

- `open var deleteIndicatorPlacement: CYLTagDeleteIndicatorPlacement = .trailing` (L225)
  After the title (the default) or before the content.

- `open var rippleColor: UIColor?` (L232)
  A circle that grows from the touch point while a tag is pressed (tag_ripple_color); `nil` (the default) for none.

- `open var rippleAlpha: CGFloat = 0.2` (L237)
  Its opacity at the start, 0...1 (tag_ripple_alpha). 0.2 by default.

- `open var rippleDuration: TimeInterval = 1` (L242)
  How long it grows, in seconds (tag_ripple_duration). 1 by default.

- `open var maximumTitleLength = 0` (L250)
  Titles longer than this many characters are cut to this length, the last three being "..." (tag_max_length); 0 (the
  default) keeps them.

- `open var reversesTitleCharacters = false` (L255)
  Shows each title's characters in reverse order (AndroidTagView's tag_support_letters_rlt). False by default.

- `open var rowAlignment: CYLTagRowAlignment = .leading` (L262)
  How the tags of a row line up: leading (the default), centered or trailing.

- `open var headerIndicatorColor: UIColor?` (L267)
  A bar before each section title, as in a "| 热门搜索" header; `nil` (the default) for none.

- `open var headerIndicatorSize = CGSize(width: 3, height: 16)` (L272)
  The bar's size, {3, 16} by default.

- `open var imageCornerRadius: CGFloat = 0` (L278)
  Rounds the icon's corners (AndroidTagView's round avatars): half the icon's size or more makes it a circle. 0 by
  default.

- `open var imageTitleSpacing: CGFloat = 4` (L285)
  Space between the icon and the title, 4 by default.

- `open var imageSize = CGSize(width: 14, height: 14)` (L290)
  Icon size. `.zero` uses the image's own size. 14 × 14 by default.

- `open var imageInsets: UIEdgeInsets = .zero` (L295)
  Shrinks the icon from its slot without moving it, as `CYLFlatDesignTabBarItem.imageInsets`.

- `open var titlePositionAdjustment: UIOffset = .zero` (L300)
  Moves the title from its computed position.

- `open var imagePositionAdjustment: UIOffset = .zero` (L305)
  Moves the icon from its computed position.

- `open var imagePlacement: CYLTagImagePlacement = .leading` (L310)
  The icon before (default) or after the title, or above (`.top`) or below (`.bottom`) it.

- `open var imageFillsTagHeight = false` (L316)
  True: a leading image is a circle as tall as the tag, at its leading edge, and the title follows it
  (`imageSize`, `imageInsets` and the leading content inset do not apply to it); AndroidTagView's avatar. Default false.

- `open var titleMaxLines = CYLTagTitleMaxLines.single` (L324)
  The most lines a title may take: a title too wide for its tag wraps onto more lines, up to this number, and the tag
  grows taller; beyond it the title is truncated. Default `CYLTagTitleMaxLines.single` (1, one line, truncated).
  `CYLTagTitleMaxLines.unlimited` shows every line. The list measures the taller tag at the width it gets. The number
  is the app's choice; a value below 1 is 1.

- `open var titleWraps: Bool` (L337)
  True: a title too wide for its row wraps onto as many lines as it needs and the tag grows taller, instead of being
  truncated (AndroidTagView's tag_text_wrap): the same as `titleMaxLines` = `CYLTagTitleMaxLines.unlimited`; false:
  one line. The list measures the taller tag at the width it gets. Default false.

- `open var elevation: CGFloat = 0` (L346)
  A shadow under each tag, as Android's elevation in points (AndroidTagView's tag_elevation): offset down by half of
  it and blurred by it. Default 0, no shadow.

- `open var deleteIndicatorImage: UIImage?` (L353)
  An image drawn as the delete indicator instead of `deleteIndicatorTitle` or the drawn cross (AndroidTagView's
  tag_cross drawable), a square as tall as a line of the indicator font, plus `deleteIndicatorPadding` on each side.
  Default nil.

- `open var layoutCentered = true` (L360)
  For a tag with only an icon or only a title: true (the default) centers it; false keeps it where it would be with
  both, the title after an empty icon slot, the icon at the leading margin (as
  `CYLFlatDesignTabBarItem.layoutCentered = NO`).

- `open var contentAlignment: CYLTagContentAlignment = .center` (L367)
  Where the icon and title sit together: `.center` (the default) centers them; `.leading` puts them at the leading
  margin, without an empty icon slot before a title alone. A title too long for the tag is truncated with an
  ellipsis, so its icon stays visible.

- `open var backgroundStyle: CYLTagBackgroundStyle = .flat` (L374)
  The tag background: `.flat` (the default) is the solid color of each state's appearance; `.liquidGlass` draws a
  Liquid Glass material behind the content, tinted with the state's explicit `backgroundColor` (an unset one is ignored, so the
  backdrop shows through the item's low-alpha default tint `CYLAnimatedItemView.defaultGlassTint`) and clipped to the corner radius. Where the system draws no Liquid Glass the style is ignored (`resolvedBackgroundStyle`).

- `public static let defaultGlassTintAlphaLight: CGFloat = CYLAnimatedItemView.defaultGlassTintAlphaLight` (L381)
  The tint alpha of the default Liquid Glass in light mode, 0.10: forwards to `CYLAnimatedItemView.defaultGlassTintAlphaLight`, which owns the default
  (a tag or a board with no background color hands the item nil).

- `public static let defaultGlassTintAlphaDark: CGFloat = CYLAnimatedItemView.defaultGlassTintAlphaDark` (L386)
  The tint alpha of the default Liquid Glass in dark mode, 0.04: forwards to `CYLAnimatedItemView.defaultGlassTintAlphaDark`.

- `public static var defaultGlassTint: UIColor { CYLAnimatedItemView.defaultGlassTint }` (L393)
  The tint of the default Liquid Glass: forwards to `CYLAnimatedItemView.defaultGlassTint`. A tag or board with no explicit background hands the item
  nil instead; an explicit color is never replaced by it.

- `public var resolvedBackgroundStyle: CYLTagBackgroundStyle` (L399)
  The background style a tag really draws: `backgroundStyle`, or `.flat` where the system draws no Liquid Glass
  (`CYLAnimatedItemView.isLiquidGlassActive()`, the rule of CYLTabBarController).

- `open var minimumTagSize: CGSize = .zero` (L407)
  The smallest size of a tag: a tag narrower or shorter than it grows to it, its content staying where
  `contentAlignment` puts it. `.zero` (the default) keeps the tag as large as its content and `itemHeight` make it.

- `open var animationSize: CGSize = .zero` (L412)
  Size of animated icons (`menuAnimationURLForItem(at:)`). `.zero` (the default) uses `imageSize`.

- `open var animationSpeed: CGFloat = 1` (L418)
  Playback speed of animated icons, as `CYLTabBarController.tabBarItemAnimationSpeed`; 1 (the default) is the
  file's own speed.

- `open var adjustsFontForContentSizeCategory = true` (L423)
  Scale the appearance fonts for Dynamic Type (capped at 2×). Defaults to true.

- `var maximumContentSizeCategory: UIContentSizeCategory?` (L430)
  The largest content size category the fonts of this style scale to (the title never grows past what the system draws at that
  category); `nil` (the default) leaves only `CYLTagMetrics.maximumFontScale`. The fold control sets
  `CYLTagFoldButton.maximumContentSizeCategory`.

- `open var itemHeight: CGFloat = 30` (L435)
  Minimum tag height; grows with the font for large text sizes. 30 by default.

- `open var numberOfItemsPerRow = 0` (L442)
  Grid layout: 0 (the default) lays the tags out one after another, each as wide as its title; a number above 0
  gives every tag the same width, that many per row (the content width minus the spacing between them, divided
  evenly), and truncates a longer title with an ellipsis ("…"), like a search app's suggestions, two per row.

- `open var interitemSpacing: CGFloat = 10` (L449)
  Space between tags in a row, 10 by default.

- `open var lineSpacing: CGFloat = 10` (L454)
  Space between rows, 10 by default.

- `open var sectionInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)` (L459)
  Insets of every section, {10, 16, 10, 16} by default.

- `open var backgroundColor = UIColor.systemBackground` (L466)
  The list's background: `UIColor.systemBackground` by default (white in light mode, black in dark mode). Under
  `CYLSectionStyle.insetGrouped` a list whose background the app never set shows the grouped background instead
  (`resolvedBackgroundColor`). A color the app sets, a clear one included, wins in both modes.

- `open var sectionStyle: CYLSectionStyle = .insetGrouped` (L485)
  `.insetGrouped` (the default) puts each section's tags inside a rounded card, UITableView's inset grouped look, with the
  header above it; `.plain` puts the tags on the list's background. The presets that are a complete look of their own
  (`tagCloud()`, `tagContainer()`, `gridStyle(itemsPerRow:)`, `wordPicker()` and the tags of the classify menu and the
  filter) are `.plain`; in a configuration: `"sectionStyle": "plain"`.

- `open var sectionBackgroundColor: UIColor?` (L490)
  The card's color; `nil` (the default) resolves to `UIColor.secondarySystemGroupedBackground` (white; #1C1C1E in dark mode).

- `open var sectionBackgroundStyle: CYLTagBackgroundStyle = .flat` (L497)
  The card's background: `.flat` (the default) is the solid `sectionBackgroundColor` (or the system card color); `.liquidGlass`
  is the library's Liquid Glass with the card's corner radius, tinted with `sectionBackgroundColor` when it is set. Where the system
  draws no glass the card is flat (`resolvedSectionBackgroundStyle`). Independent of the tags' `backgroundStyle`.

- `public var resolvedSectionBackgroundStyle: CYLTagBackgroundStyle` (L502)
  The card background really drawn: `sectionBackgroundStyle`, or `.flat` where the system draws no Liquid Glass.

- `open var sectionCornerRadius: CGFloat = CYLSectionStyleMetrics.cardCornerRadius` (L509)
  The card's corner radius, 10 by default (`CYLSectionStyleMetrics.cardCornerRadius`).

- `open var sectionContentInsets = UIEdgeInsets(top: CYLSectionStyleMetrics.cardPadding, left: CYLSectionStyleMetrics.cardPadding,` (L515)
  The padding inside the card around the tags (`.insetGrouped`), 12 on every side by default. In a right-to-left layout
  `left` is the leading side, as in `sectionInsets`.

- `open var sectionBoardInset: CGFloat?` (L525)
  How far the board (the card) extends beyond the tag column on the left and on the right: one value for both sides. The tags
  and the header title always share the tag column, so the board never changes the tag width. `0`: the board's edges coincide
  with the tags' edges. `nil` (the default): `sectionContentInsets` leading / trailing (12), the board spans the section column as
  before. A set value (0 included) overrides those two parts of `sectionContentInsets`; top and bottom still come from it.
  Configuration key: `sectionBoardInset`.

- `open var headerBackgroundColor: UIColor?` (L531)
  The header band's color; `nil` (the default) draws no band. `CYLSectionStyleColors.headerBand` (#EFEFF4, with a dark variant)
  is the usual one.

- `open var headerCornerRadius: CGFloat = 0` (L536)
  The header band's corner radius, 0 by default.

- `open var headerContentInsets = UIEdgeInsets(top: 0, left: CYLSectionStyleMetrics.headerBandPadding, bottom: 0,` (L542)
  A plain header's title and fold control inset from the band's edges (`left` and `right` only), 12 by default; used only
  where a band is shown.

- `open var headerSeparatorStyle: CYLHeaderSeparatorStyle = .none` (L548)
  `.none` (the default) or `.line`: a line at the bottom of a section header, inside the header's height (it adds none).

- `open var headerSeparatorColor: UIColor?` (L553)
  The divider's color; `nil` (the default) resolves to `UIColor.separator` (light and dark).

- `open var headerSeparatorThickness: CGFloat = CYLSectionStyleMetrics.separatorThickness` (L558)
  The divider's thickness, 0.5 points by default (`CYLSectionStyleMetrics.separatorThickness`).

- `open var headerSeparatorInsets = UIEdgeInsets.zero` (L564)
  The divider's `left` and `right` insets from the section column's edges, 0 by default: the divider has the same edges as the
  card and the header band (the column's), never the title's x.

- `public var isInsetGrouped: Bool` (L569)
  Whether the sections sit in cards (`sectionStyle` is `.insetGrouped`).

- `public var resolvedBackgroundColor: UIColor` (L576)
  The list background as drawn: the grouped background where the style is `.insetGrouped` and the app never set `backgroundColor`.

- `public var resolvedSectionBackgroundColor: UIColor` (L583)
  The card's color as drawn.

- `public var resolvedHeaderSeparatorColor: UIColor` (L590)
  The divider's color as drawn.

- `open var headerHeight: CGFloat = 36` (L599)
  Minimum header height, 36 by default; it grows with the font.

- `open var headerMaxLines = CYLHeaderTitleMaxLines.single` (L617)
  The most lines a section header's title may take: a title too wide for the room left of the fold / More / clear controls
  wraps onto more lines, up to this number, and the header grows taller (the title's height plus 12 pt, never below
  `headerHeight`); beyond it the title is truncated. Default `CYLHeaderTitleMaxLines.single` (1: the header frames are
  unchanged). `CYLHeaderTitleMaxLines.unlimited` shows every line. A value below 1 is 1.

- `open var headerFont = UIFont.systemFont(ofSize: 17, weight: .semibold)` (L628)
  Header font, the system table header look by default: the system font of 17 points, semibold (scaled for Dynamic Type).

- `open var headerTextColor = UIColor.label` (L634)
  Header title color: the dynamic label color by default (`UIColor.label`, resolved per trait collection, so dark mode works), the one
  tint of the list's own texts and icons together with `foldControlColor`, `moreButtonColor` and `clearButtonColor`.

- `open var headerHorizontalInset: CGFloat = 16` (L644)
  Space before the header's title and after its controls, 16 by default.

- `open var foldControlColor = UIColor.label` (L651)
  The fold controls' color: the dynamic label color by default (`UIColor.label`; a control's own color wins), visible in dark mode and on glass.

- `open var expandTitle = CYLMenuLocalizedString("CYLMenuExpand")` (L661)
  Defaults to the localized "More" from CYLClassifyMenuResources.bundle.

- `open var foldChevronImage: UIImage?` (L667)
  Footer chevron, pointing down while folded; it turns 180° when the section expands. `nil` uses the bundle's
  chevron.

- `open var collapseTitle = CYLMenuLocalizedString("CYLMenuCollapse")` (L672)
  Defaults to the localized "Less" from CYLClassifyMenuResources.bundle.

- `open var moreButtonImage: UIImage?` (L680)
  The icon of the More button in a section header (`menuShowsMoreButton(inSection:)`). `nil` (the default) uses
  the bundle's "cyl_more", three dots like the "ellipsis" icon of CYLTabBarController's More tab.

- `open var moreButtonColor = UIColor.label` (L685)
  The color of the More button: the dynamic label color by default (`UIColor.label`).

- `open var tintColor: UIColor?` (L699)
  The one color of every built-in view that is not a tag: the header title, the section icon, the fold and More controls (text,
  icon, arrow). `nil` (the default) resolves against what is behind them (`resolvedTintColor(onHeaderBand:)`). A color set here wins in
  both modes; a `headerTextColor`, `foldControlColor`, `moreButtonColor` or `clearButtonColor` set on its own wins over it.

- `public func resolvedTintColor(onHeaderBand: Bool) -> UIColor` (L707)
  The default tint of the built-in views, a dynamic color resolved with the traits of the view that shows it: `tintColor` when set;
  else black or white by the luminance of the opaque background behind the view (`CYLTintContrast.luminanceThreshold`): the header
  band's color when `onHeaderBand` and a band is shown, else the list's `resolvedBackgroundColor`; else (a transparent list) the
  system mode, `UIColor.label`.

- `public var resolvedHeaderTextColor: UIColor` (L725)
  The header title's (and section icon's) color as drawn.

- `public func resolvedFoldControlColor(inHeader: Bool) -> UIColor` (L732)
  The fold control's color as drawn; `inHeader` when the control sits in the section header (on the band).

- `public var resolvedMoreButtonColor: UIColor` (L739)
  The More button's color as drawn (the button sits in the header).

- `public var resolvedClearButtonColor: UIColor` (L746)
  The clear button's color as drawn: `clearButtonColor`, else the header title's (the button sits in the header).

- `public required override init()` (L755)
  Gray bordered tags, green selection: the style used when no style is set.

- `open class func tagCloud() -> Self` (L775)
  android-tagview's defaults (Constants): #00BFFF capsules with white 14 pt titles and no border, #88363636 while
  pressed, 5 × 8 pt padding, 5 pt between tags and between rows, "×" for deletable tags.

- `open class func tagContainer() -> Self` (L803)
  AndroidTagView's defaults: #33F44336 capsules with a 0.5 pt #88F44336 border and #666666 14 pt titles, #33FF7669
  while selected, 10 × 8 pt padding, 5 pt between tags and rows, titles cut after 23 characters, and a 1 pt black
  cross with 10 pt padding for deletable tags.

- `open class func gridStyle(itemsPerRow: Int) -> Self` (L836)
  A grid of plain titles, like a search app's suggestions: `itemsPerRow` items per row (at least 1), each as wide
  as the others, no background and no border, the content at the leading edge in the body size: the title, then its
  icon if it has one (such as a "热" icon), the title truncated with an ellipsis.

- `open class func wordPicker() -> Self` (L868)
  The word picker (选词填入, as WeChat's "涂抹选择填入词"): one character per cell, 9 equal cells per row, light gray
  cells with small corners that turn mint green when selected, the character centered. Use it with
  `CYLTagListView.setTags(withCharactersOf:)`, `selectionMode = .multiple` and `allowsSmearSelection = true`; the
  picked text is `selectedText`.

- `open class func classifyMenuTag(_ look: CYLCollectionCellButtonStyle = .chengNi) -> Self` (L906)
  A tag of `CYLClassifyMenuViewController`, in one of the looks its tag buttons have had
  (`CYLCollectionCellButtonStyle`; `.chengNi`, the default, is a light green capsule that takes the app's tint while
  selected or pressed). The tags' title font (`CYLTagMetrics.titleFontSize`, scaled like every tag), the icon 5 pt
  before the title, a 4 pt margin at both ends.

- `open class func filterTag() -> Self` (L950)
  A tag of the multiple-choice filter (`CYLMultipleFilterController`): the filter's stretchable slide images as the
  normal and selected backgrounds, green titles that turn white when selected, in the tags' title font.

- `open class func sectionTitle(fontSize: CGFloat = 15, textColor: UIColor = .black, leadingInset: CGFloat = 0) -> Self` (L967)
  A section title of a header: no background and no border, the content at the leading edge after `leadingInset`,
  an icon 4 pt before the title, in `fontSize` and `textColor`.

- `open func appearance(for state: UIControl.State) -> CYLTagAppearance` (L1022)
  The appearance for `.normal`, `.selected` or `.disabled` (disabled wins over selected); others give normal.

- `open func setTitleTextAttributes(_ attributes: [NSAttributedString.Key: Any]?, for state: UIControl.State)` (L1036)
  Like `UITabBarItem.setTitleTextAttributes(_:for:)`: `.font` and `.foregroundColor` set the state's appearance
  font and text color (their defaults when missing: a missing `.foregroundColor` resets the text color to unset, the class built-in).

- `open func titleTextAttributes(for state: UIControl.State) -> [NSAttributedString.Key: Any]` (L1045)
  The state's font and text color as text attributes.

- `open func setIconColor(_ iconColor: UIColor?, for state: UIControl.State)` (L1054)
  Tint of template icons in a state (like `UITabBarItemStateAppearance.iconColor`); `nil` uses the state's
  text color.

- `open func iconColor(for state: UIControl.State) -> UIColor` (L1061)
  The effective icon tint for a state: the explicit icon color, else the effective text color (explicit, else the class built-in).

- `open func explicitIconColor(for state: UIControl.State) -> UIColor?` (L1068)
  The icon color set for a state (`setIconColor`), nil when unset (the icon follows the text color).

- `open func displayedTitle(forTitle title: String?) -> String` (L1075)
  The title as a tag shows it: cut to `maximumTitleLength`, reversed when `reversesTitleCharacters`.

- `open func titleFont(for state: UIControl.State, traitCollection: UITraitCollection?) -> UIFont` (L1095)
  The title font of a state for the given traits: bold for the Bold Text setting, scaled for Dynamic Type when
  `adjustsFontForContentSizeCategory` is true.

- `open func deleteIndicatorFont(for state: UIControl.State, traitCollection: UITraitCollection?) -> UIFont` (L1102)
  The delete indicator's font for the given traits (`deleteIndicatorFont`, or the state's title font).

- `open func headerFont(for traitCollection: UITraitCollection?) -> UIFont` (L1112)
  Header font for the given traits, applying Dynamic Type when enabled.

- `open func copy(with zone: NSZone? = nil) -> Any` (L1121)
  An independent copy, with copies of the appearances.

- `func cylCopy() -> CYLMenuStyle` (L1236)
  A typed copy (`NSCopying` returns `Any`).

- `static let cylAppTint = UIColor(red: 42 / 255, green: 185 / 255, blue: 160 / 255, alpha: 1)` (L1250)
  The library's tint color (42, 185, 160): selected tags and the classify menu's titles (Android `CYLColor.APP_TINT`).

- `@objc public enum CYLSectionStyle: Int` (L1256)

- `case plain = 0` (L1260)
  The tags sit on the list's background (the opt-out of the default card).

- `case insetGrouped` (L1264)
  The tags sit inside a rounded card, UITableView's inset grouped look, the header above it (the default).

- `@objc public enum CYLHeaderSeparatorStyle: Int` (L1270)

- `case none = 0` (L1274)
  No line (the default).

- `case line` (L1278)
  A line at the header's bottom edge.

- `public enum CYLTintContrast` (L1284)
  The contrast rule of the default tint: black on a light background, white on a dark one (WCAG relative luminance).

- `public static let luminanceThreshold: CGFloat = 0.179` (L1290)
  The WCAG relative luminance (0 black, 1 white; sRGB linearised) above which a background counts as light and gets the dark
  tint: 0.179, where black and white have the same contrast ratio (the value HarmonyOS, Android and the mini program use).

- `public static func relativeLuminance(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGFloat` (L1295)
  The WCAG relative luminance of an sRGB color.

- `static func tint(on background: UIColor, traits: UITraitCollection) -> UIColor?` (L1306)
  Black or white for `background` resolved with `traits`; `nil` when the background is not opaque (it shows what is behind it).

- `public enum CYLSectionStyleMetrics` (L1318)
  The named lengths of the section style, in points.

- `public static let cardCornerRadius: CGFloat = 10` (L1323)
  The corner radius of a section card.

- `public static let cardPadding: CGFloat = 12` (L1328)
  The padding between a section card and its tags.

- `public static let headerBandPadding: CGFloat = 12` (L1333)
  The padding between a header band and its title, leading and trailing.

- `public static let separatorThickness: CGFloat = 0.5` (L1338)
  The thickness of the header divider: one hairline.

- `public static let headerBoardTitlePadding: CGFloat = 8` (L1343)
  The padding around a header title that is sized to its text (4 above, 4 below), under `.insetGrouped` with no divider.

- `public static let headerBoardSpacing: CGFloat = 4` (L1348)
  The gap between such a header and the board.

- `public enum CYLSectionStyleColors` (L1354)
  The colors of the section style: dynamic colors, resolved with the traits of the view that shows them.

- `public static let card = UIColor.secondarySystemGroupedBackground` (L1359)
  The section card: white; #1C1C1E in dark mode.

- `public static let headerBand = UIColor { traits in` (L1364)
  The header band: #EFEFF4 (the TagCollectionView header); #2C2C2E in dark mode.

- `public static let groupedBackground = UIColor.systemGroupedBackground` (L1373)
  The list background under `.insetGrouped`: #F2F2F7; black in dark mode.

- `public static let separator = UIColor.separator` (L1378)
  The header divider: the system separator color.

- `public enum CYLTagTitleMaxLines` (L1384)
  The line limits of a tag's title (`CYLMenuStyle.titleMaxLines`): named values, never a literal at a call site.

- `public static let single = 1` (L1389)
  One line, the default: a title too wide for its tag is truncated.

- `public static let unlimited = Int.max` (L1394)
  No limit: a title wraps onto as many lines as it needs (the MAX of the line counts).

- `public enum CYLHeaderTitleMaxLines` (L1400)
  The line limits of a section header's title (`CYLMenuStyle.headerMaxLines`): named values, never a literal at a call site.

- `public static let single = 1` (L1405)
  One line, the default: a title too wide for its header is truncated.

- `public static let unlimited = Int.max` (L1410)
  No limit: a title wraps onto as many lines as it needs.

