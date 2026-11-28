# ios-core: library (part 4 of 5)

## CollectionViewClassifyMenu/Class/TagList/CYLTagListView+CYLConfiguration.swift

 CYLTagListView+CYLConfiguration.swift
 CollectionViewClassifyMenu
 Creating a tag list from one dictionary (a map) or a configuration file, the way CYLTabBarController is created
 with init(configuration:) and init(configurationFile:). In code, values have their usual types; in a file, strings
 work for every key (colors "#RRGGBB", images "system:star", insets "{top, left, bottom, right}" or arrays, enum
 names...).
     let tags = CYLTagListView(configuration: [
         CYLTagListKey.selectionMode: "multiple",
         CYLTagListKey.foldStyle: "footerChevron",
         CYLTagListKey.style: [CYLMenuStyleKey.normal: [CYLTagAppearanceKey.cornerRadius: 0]],
         CYLTagListKey.sections: [[CYLTagSectionKey.title: "Tabs",
                                   CYLTagSectionKey.items: [[CYLTagItemKey.title: "Home",
                                                             CYLTagItemKey.image: "system:house",
                                                             CYLTagItemKey.animation: "tab_home.json"]]]],
     ])
     let fromFile = try CYLTagListView(configurationFile: "tags.json")
 Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).

- `public enum CYLTagListKey` (L40)
  The keys of a tag list configuration (`CYLTagListView(configuration:)`).

- `public static let sections = "sections"` (L45)
  An array of section dictionaries (`CYLTagSectionKey`).

- `public static let style = "style"` (L50)
  A `CYLMenuStyle`, or a dictionary of `CYLMenuStyleKey` keys.

- `public static let selectionMode = "selectionMode"` (L55)
  A `CYLMenuSelectionMode` raw value, or "none", "single", "multiple".

- `public static let foldStyle = "foldStyle"` (L60)
  A `CYLMenuFoldStyle` raw value, or "none", "headerButton", "footerChevron", "truncate".

- `public static let allowsEmptySelection = "allowsEmptySelection"` (L65)
  A Boolean, or "true" / "false".

- `public static let showsSectionHeaders = "showsSectionHeaders"` (L70)
  A Boolean, or "true" / "false".

- `public static let longPressAction = "longPressAction"` (L76)
  What a long press does: "reorder", "callout", "report" or "none", or an array of them (the first that can begin
  wins). A list without "none" and without "report" also reports the long press where no listed action takes it.

- `public static let scrollEnabled = "scrollEnabled"` (L81)
  A Boolean, or "true" / "false".

- `public static let defaultVisibleRows = "defaultVisibleRows"` (L86)
  A number.

- `public static let selectedItems = "selectedItems"` (L91)
  An array of index paths, "section-item" strings or [section, item] arrays.

- `public static let foldControl = "foldControl"` (L97)
  A `CYLMenuFoldControl`, a position name ("footer", "headerTrailing"…), or a dictionary of `CYLMenuFoldControlKey`
  keys. Applied after `foldStyle`.

- `public static let title = "title"` (L102)
  A string: the list's title, above every section.

- `public static let titlePosition = "titlePosition"` (L107)
  A `CYLMenuTitlePosition` raw value, or "topLeading" ("leading", "left"), "topCenter" ("center").

- `public static let titleImage = "titleImage"` (L112)
  A `UIImage`, or an image name, "system:<SF Symbol>" or a file path: the title's icon.

- `public static let titleStyle = "titleStyle"` (L118)
  A `CYLMenuStyle`, or a dictionary of `CYLMenuStyleKey` keys applied over `CYLTagListView.defaultTitleStyle`
  (e.g. {normal: {textColor: "#07C160", iconColor: "#07C160"}}).

- `public static let tags = "tags"` (L124)
  An array of tags, as android-tagview's addTags(): strings (titles) or dictionaries of `CYLTagItemKey` keys
  (title, image, id, deletable, enabled, style…). Replaces the list's tags (`addTags(_:)`, `tagDataSource`).

- `public enum CYLMenuFoldControlKey` (L130)
  The keys of a fold control configuration (`CYLMenuFoldControl(configuration:)`).

- `public static let position = "position"` (L136)
  A `CYLMenuFoldControlPosition` raw value, or "none", "footer", "headerTrailing" ("headerRight"), "headerLeading"
  ("headerLeft"), "tail" (the last item of the tags).

- `public static let content = "content"` (L142)
  A `CYLMenuFoldControlContent` raw value, or "iconAndTitle" ("titleAndIcon"), "title", "icon",
  "titleAndIconAlways" (`.titleAndIcon`: the title and the icon in both states).

- `public static let title = "title"` (L147)
  A string.

- `public static let collapseTitle = "collapseTitle"` (L152)
  A string.

- `public static let image = "image"` (L157)
  A `UIImage`, or an image name, "system:<SF Symbol>" or a file path.

- `public static let color = "color"` (L162)
  A `UIColor` or a color string.

- `public static let font = "font"` (L167)
  A `UIFont`, a point size, or {size:, weight:, name:, italic:}.

- `public static let rotatesImage = "rotatesImageWhenExpanded"` (L172)
  A Boolean, or "true" / "false".

- `public enum CYLTagSectionKey` (L178)
  The keys of a section dictionary (`CYLTagListKey.sections`).

- `public static let title = "title"` (L183)
  A string.

- `public static let image = "image"` (L188)
  A `UIImage`, or an image name, "system:<SF Symbol>" or a file path.

- `public static let items = "items"` (L193)
  An array of item dictionaries (`CYLTagItemKey`), or of strings (titles).

- `public static let style = "style"` (L199)
  A `CYLMenuStyle`, or a dictionary of `CYLMenuStyleKey` keys applied over the list's style: the look of this
  section's tags (see `menuStyle(forSection:)`), e.g. dark tags for white icons.

- `public enum CYLTagItemKey` (L205)
  The keys of an item dictionary (`CYLTagSectionKey.items`, `CYLTagListKey.tags`).

- `public static let title = "title"` (L210)
  A string.

- `public static let subtitle = "subtitle"` (L215)
  A string: a longer description, shown in a callout on a long press (`longPressAction` "callout").

- `public static let image = "image"` (L220)
  A `UIImage`, or an image name, "system:<SF Symbol>" or a file path.

- `public static let selectedImage = "selectedImage"` (L225)
  A `UIImage`, or an image name, "system:<SF Symbol>" or a file path.

- `public static let animation = "animation"` (L231)
  A `URL`, or a URL string, a file path or a file name (in the main bundle, or next to the configuration file): a
  Lottie .json, .pag, .riv, .svga or .gif animated icon.

- `public static let animationOptions = "animationOptions"` (L238)
  A dictionary of strings (numbers are converted): options read by the animation's library, written into the
  animation URL with `URL.cylAddingAnimationOptions(_:)`. For Rive, as in CYLTabBarController: "artboard",
  "stateMachine", "input", "triggerInput", "animation", "duration", "legacy"...

- `public static let animationRestingProgress = "animationRestingProgress"` (L243)
  A number 0...1: the frame shown while not selected (see `menuAnimationRestingProgressForItem(at:)`).

- `public static let enabled = "enabled"` (L248)
  A Boolean, or "true" / "false". True by default.

- `public static let exclusive = "exclusive"` (L253)
  A Boolean, or "true" / "false". False by default.

- `public static let type = "type"` (L258)
  A `CYLMenuItemType` raw value, or "tag" (default), "create" ("+ 新建标签"; its title is the name to create).

- `public static let deletable = "deletable"` (L263)
  A Boolean, or "true" / "false": shows the delete indicator ("×"); a tap removes the item. False by default.

- `public static let identifier = "id"` (L268)
  A number: `CYLTag.identifier` (`CYLTagListKey.tags` only).

- `public static let style = "style"` (L274)
  A `CYLMenuStyle`, or a dictionary of `CYLMenuStyleKey` keys applied over the section's style: this item's own
  look.

- `public enum CYLMenuStyleKey` (L280)
  The keys of a style dictionary (`CYLMenuStyle(configuration:)`).

- `public static let normal = "normal"` (L285)
  A dictionary of `CYLTagAppearanceKey` keys for the normal state.

- `public static let selected = "selected"` (L290)
  A dictionary of `CYLTagAppearanceKey` keys for the selected state.

- `public static let disabled = "disabled"` (L295)
  A dictionary of `CYLTagAppearanceKey` keys for the disabled state.

- `public static let imageTitleSpacing = "imageTitleSpacing"` (L300)
  A number.

- `public static let itemHeight = "itemHeight"` (L305)
  A number.

- `public static let titleMaxLines = "titleMaxLines"` (L310)
  The most lines a title may take: a whole number, or "unlimited". Default 1.

- `public static let numberOfItemsPerRow = "itemsPerRow"` (L315)
  The grid's items per row (`CYLMenuStyle.numberOfItemsPerRow`); 0 for the flow layout.

- `public static let interitemSpacing = "interitemSpacing"` (L320)
  A number.

- `public static let lineSpacing = "lineSpacing"` (L325)
  A number.

- `public static let headerHeight = "headerHeight"` (L330)
  A number.

- `public static let headerMaxLines = "headerMaxLines"` (L335)
  The most lines a section header's title may take: a whole number, or "unlimited". Default 1.

- `public static let animationSpeed = "animationSpeed"` (L340)
  A number.

- `public static let imageSize = "imageSize"` (L345)
  A size: an `NSValue`, "{width, height}", [w, h] or {width:, height:}.

- `public static let animationSize = "animationSize"` (L350)
  A size: an `NSValue`, "{width, height}", [w, h] or {width:, height:}.

- `public static let imageInsets = "imageInsets"` (L355)
  Insets: an `NSValue`, "{top, left, bottom, right}", [t, l, b, r] or {top:, left:, bottom:, right:}.

- `public static let sectionInsets = "sectionInsets"` (L360)
  Insets: an `NSValue`, "{top, left, bottom, right}", [t, l, b, r] or {top:, left:, bottom:, right:}.

- `public static let sectionStyle = "sectionStyle"` (L365)
  A `CYLSectionStyle` raw value, or "plain" / "insetGrouped" (case-insensitive).

- `public static let sectionBackgroundColor = "sectionBackgroundColor"` (L370)
  A color; absent keeps the system card color.

- `public static let sectionBackgroundStyle = "sectionBackgroundStyle"` (L375)
  A `CYLTagBackgroundStyle` raw value, or "flat" / "liquidGlass" (case-insensitive); anything else is "flat".

- `public static let sectionCornerRadius = "sectionCornerRadius"` (L380)
  A number.

- `public static let sectionContentInsets = "sectionContentInsets"` (L385)
  Insets: an `NSValue`, "{top, left, bottom, right}", [t, l, b, r] or {top:, left:, bottom:, right:}.

- `public static let sectionBoardInset = "sectionBoardInset"` (L390)
  A number: how far the board extends beyond the tags, left and right. Absent: `sectionContentInsets` leading / trailing.

- `public static let headerBackgroundColor = "headerBackgroundColor"` (L395)
  A color; absent: no band.

- `public static let headerCornerRadius = "headerCornerRadius"` (L400)
  A number.

- `public static let headerContentInsets = "headerContentInsets"` (L405)
  Insets (left and right are used; absent: 0).

- `public static let headerSeparatorStyle = "headerSeparatorStyle"` (L410)
  A `CYLHeaderSeparatorStyle` raw value, or "none" / "line" (case-insensitive).

- `public static let headerSeparatorColor = "headerSeparatorColor"` (L415)
  A color; absent keeps the system separator color.

- `public static let headerSeparatorThickness = "headerSeparatorThickness"` (L420)
  A number.

- `public static let headerSeparatorInsets = "headerSeparatorInsets"` (L425)
  Insets (left and right are used; absent: 0).

- `public static let titlePositionAdjustment = "titlePositionAdjustment"` (L430)
  An offset: an `NSValue`, "{horizontal, vertical}", [h, v] or {horizontal:, vertical:}.

- `public static let imagePositionAdjustment = "imagePositionAdjustment"` (L435)
  An offset: an `NSValue`, "{horizontal, vertical}", [h, v] or {horizontal:, vertical:}.

- `public static let layoutCentered = "layoutCentered"` (L440)
  A Boolean, or "true" / "false".

- `public static let imagePlacement = "imagePlacement"` (L446)
  A `CYLTagImagePlacement` raw value, or "leading" (icon, then title) / "trailing" (title, then icon) / "top" (icon
  above the title) / "bottom" (icon below the title).

- `public static let contentAlignment = "contentAlignment"` (L451)
  A `CYLTagContentAlignment` raw value, or "center" / "leading".

- `public static let backgroundStyle = "backgroundStyle"` (L456)
  A `CYLTagBackgroundStyle` raw value, or "flat" / "liquidGlass"; anything else is "flat".

- `public static let minimumTagSize = "minimumTagSize"` (L461)
  A size "{width, height}" in points, or `CYLMenuStyle.minimumTagSize`'s `{"width": 69, "height": 29}`.

- `public static let adjustsFontForContentSizeCategory = "adjustsFontForContentSizeCategory"` (L466)
  A Boolean, or "true" / "false".

- `public static let backgroundColor = "backgroundColor"` (L471)
  A `UIColor`, or "#RGB", "#RRGGBB", "#RRGGBBAA" or a UIColor name ("systemBlue").

- `public static let headerTextColor = "headerTextColor"` (L476)
  A color.

- `public static let tintColor = "tintColor"` (L481)
  A color: the one tint of the header title, the section icon and the fold and More controls; absent resolves against the background.

- `public static let foldControlColor = "foldControlColor"` (L486)
  A color.

- `public static let headerFont = "headerFont"` (L491)
  A `UIFont`, a point size, or {size:, weight: "semibold", name: "Menlo", italic: true}.

- `public static let highlightedBackgroundColor = "highlightedBackgroundColor"` (L496)
  A color: the background while pressed.

- `public static let tagContentInsets = "tagContentInsets"` (L501)
  Insets for every state (android-tagview's textPaddingTop / Left / Bottom / Right).

- `public static let deleteIndicatorTitle = "deleteIndicatorTitle"` (L506)
  The delete indicator's text ("×").

- `public static let deleteIndicatorColor = "deleteIndicatorColor"` (L511)
  The delete indicator's color.

- `public static let deleteIndicatorFont = "deleteIndicatorFont"` (L516)
  The delete indicator's font.

- `public enum CYLTagAppearanceKey` (L522)
  The keys of an appearance dictionary (`CYLTagAppearance.applyConfiguration(_:)`), as CYLBadgeAppearance.

- `public static let backgroundColor = "backgroundColor"` (L527)
  A color.

- `public static let textColor = "textColor"` (L532)
  A color.

- `public static let font = "font"` (L537)
  A font.

- `public static let iconColor = "iconColor"` (L542)
  A color.

- `public static let cornerRadius = "cornerRadius"` (L547)
  A number.

- `public static let borderColor = "borderColor"` (L552)
  A color.

- `public static let borderWidth = "borderWidth"` (L557)
  A number.

- `public static let margin = "margin"` (L562)
  A number.

- `public static let contentInsets = "contentInsets"` (L567)
  Insets: space between the border and the content on each side.

- `public static let backgroundImage = "backgroundImage"` (L572)
  A `UIImage`, or an image name, "system:<SF Symbol>" or a file path, drawn behind the content.

- `public struct CYLMenuConfigurationError: Error, CustomNSError, LocalizedError` (L580)
  Why a configuration file could not be read (domain `CYLMenuConfigurationErrorDomain`).

- `public enum Code: Int, Sendable` (L585)
  The error codes.

- `case fileNotFound = 1` (L589)
  No file at the path.

- `case invalidContents` (L593)
  The file does not hold a dictionary.

- `case unsupportedFormat` (L597)
  The format needs CYLTabBarController's configuration parser, which is not linked.

- `public static let errorDomain = "CYLMenuConfigurationErrorDomain"` (L603)
  The error domain, as in Objective-C.

- `public let code: Code` (L608)
  What went wrong.

- `public let message: String` (L613)
  A description for developers.

- `enum CYLConfigurationValue` (L633)
  Reads configuration values: the types of code, or the strings of a file.

- `static let baseURLKey = "__CYLConfigurationBaseURL"` (L639)
  The directory of the configuration file, added by `configuration(contentsOfFile:)` so that relative file names
  resolve next to it.

- `static func rawValue(_ value: Any?, names: [String: Int]) -> Int?` (L811)
  An enum's raw value from a number or one of `names` (lowercased); nil when it is neither.

- `static func dictionary(_ value: Any?, baseURL: URL?) -> [String: Any]?` (L828)
  `value` as a dictionary, with the configuration file's directory when there is one.

- `public static func cylMenuColor(from string: String) -> UIColor?` (L847)
  A color from "#RGB", "#RRGGBB", "#RRGGBBAA" or a UIColor name ("systemBlue", "systemBlueColor"); `nil`
  otherwise.

- `public func cylAddingAnimationOptions(_ options: [String: Any]) -> URL` (L885)
  This animation URL with options, encoded exactly as CYLTabBarController's CYLTabBarAnimationURLWithOptions()
  does ("name=value&…" in the fragment, percent-encoded and sorted by name), so that its animation libraries read
  them, e.g. which artboard and state machine of a Rive file a tag plays. Values are strings or numbers; the URL
  itself when there are no options.
      item.animationURL = iconsURL.cylAddingAnimationOptions(["artboard": "CHAT",
                                                              "stateMachine": "CHAT_Interactivity",
                                                              "input": "active"])

- `final class CYLTagListConfigurationSource: NSObject, CYLMenuDataSource` (L911)
  The data source of `CYLTagListKey.sections`.

- `public convenience init?(configuration: Any)` (L1082)
  A fold control from a dictionary of `CYLMenuFoldControlKey` keys, or from a position name or raw value alone
  (with the content that suits it: an icon in the footer, an icon and a title elsewhere); `nil` for anything else.

- `public func applyConfiguration(_ configuration: [String: Any])` (L1098)
  Applies a dictionary of `CYLMenuFoldControlKey` keys; missing keys keep their values.

- `public func applyConfiguration(_ configuration: [String: Any])` (L1150)
  Applies a dictionary of `CYLTagAppearanceKey` keys; missing keys keep their values; a key whose value is not a
  color, font or image restores the default (or clears an optional one).

- `public convenience init(configuration: [String: Any])` (L1192)
  A default style with the configuration's values (`CYLMenuStyleKey` keys).

- `public func applyConfiguration(_ configuration: [String: Any])` (L1200)
  Applies a dictionary of `CYLMenuStyleKey` keys; missing keys keep their values.

- `func applySectionStyle(_ configuration: [String: Any])` (L1333)
  The section card, header band and header divider keys of `applyConfiguration(_:)`.

- `public convenience init(configuration: [String: Any])` (L1393)
  A tag from a dictionary of `CYLTagItemKey` keys (title, image, selectedImage, animation, id, enabled, deletable,
  style).

- `static func contents(ofFile url: URL) throws -> Any?` (L1429)
  The file's contents read by `+[CYLTabBarConfigurationParser dictionaryWithContentsOfFile:error:]`, else by
  `+[CYLTabBarController configurationWithContentsOfFile:error:]`.
  - Throws: `CYLMenuConfigurationError.Code.unsupportedFormat` when neither is linked, or the parser's error.

- `public convenience init(configuration: [String: Any])` (L1460)
  Creates a tag list from one dictionary holding everything (`CYLTagListKey`). The view keeps the data source it
  builds from `CYLTagListKey.sections`.

- `public convenience init(configurationFile filePath: String) throws` (L1469)
  Reads a configuration file (`configuration(contentsOfFile:)`) and creates a tag list from it.

- `public class func objcTagListView(configuration: [String: Any]) -> CYLTagListView` (L1479)
  Objective-C's `+tagListViewWithConfiguration:` of the Objective-C core; Swift uses `init(configuration:)`.

- `public class func objcTagListView(configurationFile filePath: String) throws -> CYLTagListView` (L1489)
  Objective-C's `+tagListViewWithConfigurationFile:error:` of the Objective-C core; Swift uses
  `init(configurationFile:)`.

- `@objc public var configurationDataSource: CYLMenuDataSource?` (L1496)
  The data source built from `CYLTagListKey.sections`, or `nil`.

- `public func applyConfiguration(_ configuration: [String: Any])` (L1504)
  Applies a configuration to an existing view; keys that are missing keep their values.

- `public static func configuration(contentsOfFile filePath: String) throws -> [String: Any]` (L1611)
  Reads a configuration file: a path, a file URL string, or a file name in the main bundle (e.g. "tags.json" or
  "Configurations.bundle/tags.plist"). JSON and property lists (XML or binary) are read directly; the other formats
  of CYLTabBarController's CYLTabBarConfigurationParser (JSON5, YAML, TOML, INI, .properties, XML, Protocol Buffers
  text…) are read by it when CYLTabBarController is linked. The values are then read by this project's rules
  (strings for every key). Relative file names inside resolve next to the file.
  - Throws: `CYLMenuConfigurationError`, or the reader's error.

- `static func longPressAction(fromConfiguration value: Any?) -> CYLTagLongPressAction?` (L1649)
  A configuration's `longPressAction` (a name or an array of names) as an action; `nil` when absent or unknown.

## CollectionViewClassifyMenu/Class/TagList/CYLTagListView.swift

 CYLTagListView.swift
 CollectionViewClassifyMenu
 A configurable, embeddable tag menu. The host owns the data (through CYLMenuDataSource) and reacts to taps
 (through CYLMenuDelegate); the view owns only layout, folding and selection state.
 Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).

- `@objc public enum CYLMenuSelectionMode: Int` (L15)

- `case none = 0` (L19)
  Items behave like buttons: taps are reported, nothing stays selected.

- `case single` (L23)
  At most one selected item per section.

- `case multiple` (L27)
  Any number of selected items; exclusive items clear the others.

- `@objc public enum CYLMenuTitlePosition: Int` (L33)

- `case topLeading = 0` (L37)
  At the leading edge.

- `case topCenter` (L41)
  Centered.

- `@objc public enum CYLMenuFoldStyle: Int` (L47)

- `case none = 0` (L51)
  Every row is always visible.

- `case headerButton` (L55)
  A "更多/收起" button at the trailing edge of the section header.

- `case footerChevron` (L59)
  A chevron below the section, as in shopping review filters.

- `case truncate` (L64)
  Shows only `defaultVisibleRows` rows with no control, for previews; the host may still call
  `setExpanded(_:forSection:animated:)`.

- `struct CYLTagListHeaderRoom` (L76)
  The widths inside a section header, one model for the layout (`CYLTagListHeaderView`) and the height (`headerHeight(forSection:)`):
  INNER WIDTH is the header's width between its leading and trailing insets; the views are separated by `spacing`; the fold control
  is `min(natural width of its wider state, cap x inner)` (cap 0.4 alone, 0.3 with More / clear / an accessory view, the same width
  collapsed and expanded); an accessory view is at most 0.3 of the inner width; only the title shrinks, to
  `max(one em, inner - the fixed parts - the spacings)`, or the inner width when nothing else is shown.

- `static let spacing: CGFloat = 8` (L81)
  The gap between two adjacent header views.

- `static let foldFractionAlone: CGFloat = 0.4` (L85)
  The fold control's cap as a fraction of the inner width: alone, and next to More / clear / an accessory view.

- `static let accessoryFraction: CGFloat = 0.3` (L90)
  The accessory view's cap as a fraction of the inner width.

- `static let foldMargin: CGFloat = 6` (L94)
  The control's own margin: its content lines up with the title, so it takes this much less than its width.

- `init(inner: CGFloat, indicatorWidth: CGFloat?, foldNaturalWidth: CGFloat?, moreExtent: CGFloat?, clearSide: CGFloat?,` (L105)
  - `foldNaturalWidth`: the wider of the fold control's two states; `nil`: no fold control in this header.
  - `moreExtent`, `clearSide`, `accessoryNaturalWidth`: the width each takes; `nil`: not shown.
  - `indicatorWidth`: the indicator bar's width; `nil`: none.

- `static let moreButtonSize: CGFloat = 44` (L147)
  The More button's touch target.

- `static func moreExtent(iconWidth: CGFloat) -> CGFloat` (L153)
  What the More button takes at the trailing edge: its touch target less the part that sticks out so the icon lines up with the inset.

- `@objc let titleButton = CYLTagButton(frame: .zero)` (L160)
  The section's icon and title: the same component as the tags, so a section icon can be anything a tag icon can.

- `let moreButton = UIButton(type: .system)` (L171)
  The More button (three dots) at the trailing edge, hidden unless the data source asks for it.

- `let indicatorView = UIView()` (L175)
  CYLMenuStyle.headerIndicatorColor and size: a bar before the title.

- `let clearButton = CYLTagListClearButton(type: .system)` (L180)
  The section's clear button (the bundle's trash icon, `CYLMenuDataSource.menuShowsClearButton(forSection:)`): its top
  and bottom are the title's.

- `var foldSize: CGSize = .zero` (L187)
  The fold control's size, and whether it is at the leading edge (before the title).

- `var leadingInset: CGFloat = 0` (L192)
  The distances from the header's leading and trailing edges to the title and the controls.

- `var bandEdges: (left: CGFloat, right: CGFloat)?` (L198)
  The header band (`CYLMenuStyle.headerBackgroundColor`) and the divider, as distances from the header's own edges
  (left, right); `nil`: not shown.

- `open class CYLTagListView: UIView` (L443)
  A configurable, embeddable tag menu: sections of tags from `menuDataSource`, taps reported to `menuDelegate`,
  folding, selection, a title, reordering and the android-tagview tag methods (`addTag(_:)`…).

- `@objc open weak var menuDataSource: CYLMenuDataSource?` (L469)
  The sections and items.

- `@objc open weak var menuDelegate: CYLMenuDelegate?` (L474)
  Receives taps, selection changes, folding and size changes.

- `@objc open var style: CYLMenuStyle` (L481)
  Appearance. Setting copies the style; set it again after changing it.

- `@objc open var selectionMode: CYLMenuSelectionMode = .single` (L496)
  How taps select items; `.single` by default.

- `@objc open var allowsEmptySelection = true` (L519)
  When false, a tap never removes the last selected item of a section. True by default.

- `@objc open var showsSectionHeaders = true` (L524)
  True by default. When false, sections are laid out back to back without titles.

- `@objc open var foldControl: CYLMenuFoldControl` (L535)
  The fold control of a foldable section (more rows than `defaultVisibleRows`): where it is and what it shows.
  Default: none. Setting copies it and also sets `foldStyle` (footer: `.footerChevron`, header: `.headerButton`,
  none: `.none`, or `.truncate` when `foldStyle` was `.truncate`).

- `@objc open var foldStyle: CYLMenuFoldStyle` (L562)
  `.none` by default. Setting it also sets `foldControl`: `.headerButton` is a top trailing title ("更多"),
  `.footerChevron` a bottom icon; `.none` and `.truncate` have none.

- `@objc open var defaultVisibleRows = 1` (L583)
  Rows shown while a foldable section is collapsed. 0 shows every row. 1 by default.

- `@objc open var title: String?` (L597)
  A title above every section (`nil`, the default, for none), e.g. "评价". It is drawn by `titleView`, the same
  tag view as the tags (`CYLTagButton`), laid out horizontally: an icon (`titleImage`), a title, or both. Neither:
  no title area.

- `@objc open var titleImage: UIImage?` (L607)
  The title's icon, before the title (or after it with `titleStyle.imagePlacement`); `nil` for none.

- `@objc open var titlePosition: CYLMenuTitlePosition = .topLeading` (L617)
  Where the title is.

- `@objc open var titleStyle: CYLMenuStyle` (L627)
  The title's look (font, colors, icon size and color, spacing…). Default `defaultTitleStyle`: the bold headline
  font in the label color, no box. Setting copies the style.

- `@objc public let titleView = CYLTagButton(frame: .zero)` (L642)
  The view that draws the title: every public API of `CYLTagButton` is available (e.g. an animated icon with
  `animationURL`). Set the title, icon and style through the properties above.

- `@objc open var titleLabel: UILabel` (L647)
  The title's label (`titleView.titleLabel`).

- `@objc open class var defaultTitleStyle: CYLMenuStyle` (L655)
  The default title look: the headline font (bold, scaled with Dynamic Type) in the label color, an 18 pt icon in
  the label color, no background or border.

- `@objc open var isScrollEnabled: Bool` (L682)
  Turn off to embed the view in another scroll view and size it with `contentHeight` or Auto Layout's intrinsic
  content size. True by default.

- `@objc open private(set) var contentHeight: CGFloat = 0` (L701)
  Height needed to show the current content at the current width. Also reported as the intrinsic content height
  and through `menu(_:didChangeContentHeight:)`.

- `@IBInspectable open var lineSpacing: CGFloat` (L709)
  The space between rows (`style.lineSpacing`, lineMargin). Like the other spacing shortcuts, it copies the
  style, changes it and sets it again, and can be set in Interface Builder.

- `@IBInspectable open var interitemSpacing: CGFloat` (L721)
  The space between tags in a row (`style.interitemSpacing`, tagMargin).

- `@objc open var tagContentInsets: UIEdgeInsets` (L733)
  The space inside every tag (`style.tagContentInsets`, textPaddingTop / Left / Bottom / Right).

- `@IBInspectable open var tagContentInsetTop: CGFloat` (L745)
  `tagContentInsets.top`, for Interface Builder.

- `@IBInspectable open var tagContentInsetLeft: CGFloat` (L757)
  `tagContentInsets.left`, for Interface Builder.

- `@IBInspectable open var tagContentInsetBottom: CGFloat` (L769)
  `tagContentInsets.bottom`, for Interface Builder.

- `@IBInspectable open var tagContentInsetRight: CGFloat` (L781)
  `tagContentInsets.right`, for Interface Builder.

- `open var animationSpeed: CGFloat?` (L796)
  The playback speed of every animated icon, applied at once, also to animations that are playing, without
  reloading the list. `nil` (the default) uses each tag's `style.animationSpeed`.

- `open var animationSpeedNumber: NSNumber?` (L808)
  `animationSpeed` for Objective-C, which cannot see an optional `CGFloat`: the speed as an `NSNumber`, or `nil`
  for each tag's `style.animationSpeed`. Objective-C calls it `animationSpeed`; Swift uses `animationSpeed`.

- `@objc open var animationLoops = false` (L821)
  True repeats the animated icons after they start playing (a tap, `playAllAnimations()`) until it is set to
  false; false (the default) plays them once (`CYLTagButton.animationLoops`).

- `@objc open func playAllAnimations()` (L830)
  Plays the animated icon of every tag on screen from its start (progress 0), whatever its selection.

- `open var tagClickHandler: ((Int, CYLTag) -> Void)?` (L840)
  Called for every accepted tap on one of `tags` (android-tagview's OnTagClickListener), after the menu delegate.

- `open var objcTagClickHandler: ((Int, String) -> Void)?` (L848)
  Objective-C's `tagClickHandler`: called for the same taps as `tagClickHandler`, right after it, with the tag's
  index and title (Swift uses `tagClickHandler`, whose `CYLTag` Objective-C cannot see).

- `open var tagDeleteHandler: ((Int, CYLTag) -> Void)?` (L862)
  Called after a tap on a tag's delete indicator removed it (android-tagview's OnTagDeleteListener), after the
  menu delegate.

- `@objc open var containerBorderWidth: CGFloat = 0` (L869)
  The list's own border width (container_border_width); 0 by default. The background is `style.backgroundColor`.

- `@objc open var containerBorderColor: UIColor?` (L879)
  The list's own border color (container_border_color); `nil` by default.

- `@objc open var containerCornerRadius: CGFloat = 0` (L888)
  The list's own corner radius (container_border_radius); 0 by default.

- `@objc open var maximumNumberOfRows: Int` (L900)
  At most this many rows of each section (container_max_lines); 0 (the default) shows every row. Setting it sets
  `foldStyle` to `.truncate` and `defaultVisibleRows` to it.

- `@objc open var colorTheme: CYLTagColorTheme = .none` (L918)
  Colors every item that has no look of its own from a theme (tag_theme): `.none` (the default), random, pure cyan
  or pure teal.

- `@objc open var allowsTapping = true` (L929)
  False ignores taps on tags: no highlight, no selection, no callbacks (tag_clickable). Long presses still work.
  True by default.

- `@objc open var defaultTagImage: UIImage?` (L934)
  The icon of every item without one of its own (setDefaultImageDrawableID), e.g. an avatar. `nil` by default.

- `@objc open var removesItemsOnDelete = true` (L940)
  False makes a tap on a delete indicator only report it (AndroidTagView's onTagCrossClick); the host removes the
  item. True by default.

- `open var longPressAction: CYLTagLongPressAction = CYLTagLongPressActions.makeDefault()` (L949)
  What a long press on an item does: `CYLTagLongPressActions.first([reorder, report])` by default (reordering where
  the list can reorder, else the long press is reported). Set another built-in action, a combination or your own
  (docs/tag-long-press-action.md). Setting it cancels a press in progress and hides the callout.

- `open var tagLongPressHandler: ((Int, CYLTag) -> Void)?` (L970)
  A long press on an item without moving it: `menu(_:didLongPressItemAt:)`, then this (onTagLongClick).

- `@objc open var longPressAccessibilityActionName: String?` (L982)
  The name of the long-press custom action that VoiceOver, Voice Control and Switch Control users pick instead of
  a long press (each tag gets it while `tagLongPressHandler` is set or the delegate handles long presses), such as
  "删除". `nil`: "长按" (core string `CYLMenuLongPress`). While `allowsReordering`, tags also get 前移 / 后移
  actions, which move them like a drag and announce the new position.

- `@objc open var allowsReordering = false` (L992)
  A long press and a move reorders the items of a section (container_enable_drag). Needs a data source that
  implements `menuMoveItem(at:to:)` (`CYLTagDataSource` does). False by default.

- `@objc open var allowsSmearSelection = false` (L1006)
  True: a finger dragged across the items selects them ("smearing", as in WeChat's 涂抹选择填入词): the drag starts on
  an item and selects every item from it to the item under the finger, in item order, or deselects them when the
  first item was already selected. A tap still toggles one item, so VoiceOver, Voice Control and Switch Control
  select the same items. Needs `selectionMode == .multiple`; a drag that starts between items scrolls the list. The
  delegate gets `menu(_:didChangeSelectedItems:)`. False by default; `CYLMenuStyle.wordPicker()` is the matching look.

- `@objc open var reorderingSensitivity: CGFloat = 1` (L1016)
  How quickly a press starts reordering (container_drag_sensitivity): the press lasts 0.5 s divided by it; a value
  that is not positive is 1. 1 by default.

- `@objc open private(set) var isReordering = false` (L1028)
  Whether an item is being moved (getTagViewState).

- `@objc open var tagMoveHandler: ((Int, Int) -> Void)?` (L1036)
  One of `tags` moved (after `menu(_:didMoveItemAt:to:)`).

- `open var selectedTagDragHandler: ((Int, CYLTag) -> Void)?` (L1041)
  A selected tag started moving (onSelectedTagDrag), after `menu(_:didBeginDraggingSelectedItemAt:)`.

- `@objc open private(set) var isEditing = false` (L1051)
  Whether the list is in editing mode (`setEditing(_:animated:)`). While editing, the items of the editable sections
  (`menuSectionAllowsEditing(_:)`, every section by default) show the delete indicator and can be dragged to
  reorder; a tap no longer selects an item but still calls `menu(_:didSelectItemAt:)`, so the host can open the
  item; folded sections show every item; and `addItemView` appears below the last section. False by default.

- `@objc open var showsAddItemViewWhileEditing = true` (L1056)
  Shows `addItemView` below the last section while editing. True by default.

- `@objc open private(set) lazy var addItemView: CYLTagListAddItemView =` (L1066)
  The "add tag" control shown while editing: a text field and an Add button. A submitted name is reported through
  `menu(_:didRequestNewItemWithName:at:)` with the index path after the last item of the first editable section.

- `@objc open private(set) var renamingIndexPath: IndexPath?` (L1083)
  The item being renamed in editing mode (its rename indicator was tapped); nil otherwise.

- `@objc open var renameRequestHandler: ((IndexPath, String) -> Void)?` (L1095)
  Your own editor for renaming (an editing bar above the keyboard, for example): when set, a pencil or title tap
  calls it with the item and its title instead of filling `addItemView`; finish with `finishRenaming(to:)` or
  `cancelRenaming()`. nil (the default): `addItemView` is the rename field.

- `@objc open var clearButtonHandler: ((Int) -> Void)?` (L1101)
  Called with the section when its clear button (the bundle's trash icon, shown for the sections the data source's
  `menuShowsClearButton(forSection:)` names) is tapped, after `menu(_:didTapClearButtonInSection:)`.

- `@objc open var cachePolicy: CYLTagListCachePolicy = .none` (L1115)
  Where the list saves its editable sections after an edit (a drag, a delete or an added tag in editing mode), so
  the order survives a relaunch: `.none` (the default), a SQLite database, `NSUserDefaults` or a sandbox file. The
  host restores it when it builds its data (`cachedTitles(inSection:)`). Setting it makes `cache` the built-in
  store of the policy and `cacheName`.

- `@objc open var cacheName = "CYLTagListView"` (L1125)
  Separates the caches of different lists ("CYLTagListView" by default). Set it before `cachePolicy`, or set
  `cachePolicy` again after changing it.

- `@objc open var cache: CYLTagListCache?` (L1134)
  The store the list saves to: the built-in store of `cachePolicy`, or one of yours. nil: no cache.

- `@objc open var remoteSource: CYLTagListRemoteSource?` (L1139)
  The server the sections are also kept on, for `loadSections(withKeys:completion:)`; nil: the cache only.

- `@objc open var loadPolicy: CYLTagListLoadPolicy = .cacheThenNetwork` (L1145)
  How `loadSections(withKeys:completion:)` combines the cache and `remoteSource`: `.cacheThenNetwork` (the cache
  at once, then a refresh from the server) by default.

- `@objc open var editingFinishHandler: (([String: [String]]) -> Void)?` (L1151)
  Called when editing ends (`setEditing(false, animated:)`) with the edited sections, by cache key, after
  `menu(_:didFinishEditingWithTitles:)`: the place to upload them.

- `open func cachedTitles(inSection section: Int) -> [String]?` (L1157)
  The titles saved for `section` (its index), in order; nil when nothing was saved or there is no cache.

- `open func cacheKey(forSection section: Int) -> String` (L1165)
  The key of `section` in the cache: the data source's `menuCacheKey(forSection:)`, else the section's index.

- `@objc open func saveEditableSectionsToCache()` (L1172)
  Saves the current titles of every editable section to `cache` (the list calls it after each edit).

- `@objc open func editableSectionItems() -> [String: [CYLTagListCacheItem]]` (L1192)
  The items (identifier from `menuIdentifierForItem(at:)`, else the title; and title) of every editable section,
  by cache key, without create items.

- `open func beginRenaming(at indexPath: IndexPath)` (L1213)
  Starts renaming `indexPath` (its rename indicator does this): `addItemView` shows the title with the keyboard up;
  its submit renames the item through the data source's `menuRenameItem(at:to:)`.

- `@objc open func cancelRenaming()` (L1234)
  Ends renaming without a change.

- `open func submitNewItem(named name: String)` (L1248)
  Adds an item named `name` from your own editor, as `addItemView`'s submit does: reported through
  `menu(_:didRequestNewItemWithName:at:)` at the end of the first editable section, then the cache is saved.

- `open func finishRenaming(to title: String)` (L1262)
  Renames the item being renamed to `title` (trimmed; an empty or unchanged one only ends renaming): the data
  source renames it, the list reloads, saves its cache and calls `menu(_:didRenameItemAt:to:)`.

- `@objc open func editableSectionTitles() -> [String: [String]]` (L1284)
  The titles of every editable section, by cache key (`cacheKey(forSection:)`), without create items: what the
  list saves and what `menu(_:didFinishEditingWithTitles:)` reports.

- `open func setEditing(_ editing: Bool, animated: Bool)` (L1303)
  Enters or leaves editing mode: the delete indicators, reordering, the selection rules, folding and `addItemView`
  change together; then `menu(_:didChangeEditing:)` is called. The list itself does not move or open anything.

- `open func sectionAllowsEditing(_ section: Int) -> Bool` (L1347)
  Whether a section takes part in editing: the data source's `menuSectionAllowsEditing(_:)`, else true.

- `var smearTouchDown: CGPoint?` (L1402)
  Where the finger touched down for the current smear (in the collection view): the smear begins on that item, not
  on the one under the finger once it has moved far enough to count as a drag (it may be in a gap by then).

- `public convenience init(foldControl: CYLMenuFoldControl?)` (L1437)
  A tag list without a title, with its fold control (`nil`: none).

- `public convenience init(foldControl: CYLMenuFoldControl?, title: String?, titleImage: UIImage? = nil,` (L1446)
  A tag list with its fold control and title, and an icon before the title (either may be `nil`: icon only, title
  only). The styles are fixed at creation; both can change later.

- `public convenience init(foldPosition: CYLMenuFoldControlPosition, content: CYLMenuFoldControlContent)` (L1467)
  A tag list with a fold control at this position showing this content.

- `public convenience init(objcFoldControl foldControl: CYLMenuFoldControl?, title: String?,` (L1477)
  Objective-C's `-initWithFoldControl:title:titlePosition:` of the Objective-C core, without an icon; Swift uses
  `init(foldControl:title:titleImage:titlePosition:)`.

- `public class func objcTagListView(foldPosition: CYLMenuFoldControlPosition,` (L1488)
  Objective-C's `+tagListViewWithFoldPosition:content:` of the Objective-C core; Swift uses
  `init(foldPosition:content:)`.

- `@objc open func reloadMenuData()` (L1542)
  Reads everything from the data source again. Selections and expanded sections that are still in range are kept.

- `open func heightThatFitsWidth(_ width: CGFloat) -> CGFloat` (L1567)
  Height the content needs at `width` with the current data and fold state, without laying the view out.

- `open func contentColumn(inSection section: Int) -> CGRect` (L1599)
  The section column at the current width: the list width minus `sectionInsets` (x and width; y and height are 0). The card,
  the header band and the divider span it.

- `open func boardColumn(inSection section: Int) -> CGRect` (L1607)
  The board (the card) of `.insetGrouped`: the tag column widened by `CYLMenuStyle.sectionBoardInset` on each side, which is
  `contentColumn(inSection:)` when the inset is unset. The header band and the divider span it too. Plain: `contentColumn(inSection:)`.

- `open func tagColumn(inSection section: Int) -> CGRect` (L1615)
  The column the tags are laid in: `contentColumn(inSection:)` narrowed by the card's padding under `.insetGrouped`. Tag
  widths, rows, fold decisions, heights and frames all come from it.

- `@objc open var tagDataSource: CYLTagDataSource` (L1627)
  The list's own tags, for a list filled the android-tagview way: create it, add `CYLTag` objects (or titles),
  react to taps and deletions in closures. The first tag method makes `tagDataSource` the `menuDataSource` and, the
  way android-tagview behaves, turns section headers off and sets `selectionMode` to `.none` (change them
  afterwards to select tags). Every other API (styles, folding, selection, configuration) keeps working.

- `open var tags: [CYLTag]` (L1640)
  The tags of `tagDataSource`, in order (android-tagview's getTags()).

- `open func addTag(_ tag: CYLTag)` (L1647)
  Adds a tag.

- `open func addTags(_ tags: [CYLTag])` (L1655)
  Adds tags.

- `open func addTags(withTitles titles: [String])` (L1664)
  Tags with these titles and the list's look (android-tagview's addTags(String[])).

- `open func addTag(withTitle title: String)` (L1672)
  Adds a tag with this title.

- `open func insertTag(_ tag: CYLTag, at index: Int)` (L1679)
  Inserts a tag; selections at or after it move down. An index past the end adds it at the end.

- `open func insertTag(withTitle title: String, at index: Int)` (L1691)
  Inserts a tag with this title.

- `open func removeTag(at index: Int)` (L1700)
  Removes a tag (android-tagview's remove(position)); selections after it move up. Out-of-range indexes are
  ignored.

- `open func removeTags(at indexes: IndexSet)` (L1714)
  Removes several tags (removeConsecutiveTags).

- `@objc open func removeAllTags()` (L1726)
  Removes every tag.

- `open func replaceTags(_ tags: [CYLTag])` (L1735)
  Replaces the tags (setTags).

- `open func setTags(withTitles titles: [String], colors: [CYLTagColors] = [])` (L1745)
  Replaces the tags with tags of these titles, and colors per tag, in order (setTags(List, List<int[]>)); tags past
  the colors keep the list's look.

- `open func objcSetTags(withTitles titles: [String])` (L1761)
  Objective-C's `-setTagsWithTitles:`: replaces the tags with tags of these titles and the list's look (Swift uses
  `setTags(withTitles:colors:)`, whose `CYLTagColors` Objective-C cannot see).

- `open func deleteItem(at indexPath: IndexPath)` (L1771)
  Deletes a deletable item as a tap on its delete indicator does: the data source removes it
  (`menuRemoveItem(at:)`), the list reloads and reports it. Does nothing for an item that is not deletable or not
  enabled.

- `open func tagButton(at indexPath: IndexPath) -> CYLTagButton?` (L1795)
  The tag view of a shown item (getTagView), or `nil` when it is not on screen.

- `@objc open var selectedIndexPaths: [IndexPath]` (L1806)
  Selected items in ascending order. Setting applies the selection rules of `selectionMode`; it raises
  `NSInvalidArgumentException` for an item outside the menu (validate before setting it from Swift, which cannot
  catch the exception).

- `@objc open var selectedTitles: [String]` (L1831)
  The titles of the selected items, in order (getSelectedTagViewText).

- `open func selectItem(at indexPath: IndexPath)` (L1839)
  Applies the selection rules of `selectionMode` without calling the delegate.

- `open func deselectItem(at indexPath: IndexPath)` (L1851)
  Deselects an item without calling the delegate.

- `@objc open func deselectAllItems()` (L1859)
  Deselects every item without calling the delegate.

- `open func toggleSelection(at indexPath: IndexPath)` (L1869)
  Selects an unselected item or deselects a selected one (toggleSelectTagView). In `.none` mode, where taps never
  select, it still selects (any number of items), as AndroidTagView's long press does.

- `open func isSectionExpanded(_ section: Int) -> Bool` (L1889)
  Whether a section is expanded.

- `open func setExpanded(_ expanded: Bool, forSection section: Int, animated: Bool)` (L1897)
  Expands or collapses a section and calls `menu(_:didChangeExpanded:inSection:)`.

- `open func canFoldSection(_ section: Int) -> Bool` (L1935)
  Whether the section has more rows than `defaultVisibleRows` and can fold.

- `open func numberOfRows(inSection section: Int) -> Int` (L1948)
  Number of rows the section's items occupy at the current width.

- `open func numberOfVisibleItems(inSection section: Int) -> Int` (L1957)
  Number of items currently shown in the section (fewer while collapsed).

- `open func scroll(toSection section: Int, animated: Bool)` (L1998)
  Scrolls so that the section (its header, or its first row) is at the top, as far as the content allows.

- `open func scrollToItem(at indexPath: IndexPath, animated: Bool)` (L2030)
  Scrolls so that the item is centered vertically, as far as the content allows (e.g. a tag just created, or the
  last item). Does nothing for an item that is not shown (folded away).

- `func style(forItemAt indexPath: IndexPath) -> CYLMenuStyle` (L2155)
  The item's own look, or its section's.

- `func style(forSection section: Int) -> CYLMenuStyle` (L2176)
  The section's own look, or the list's style.

- `func themeStyle(forItemAt indexPath: IndexPath, baseStyle: CYLMenuStyle) -> CYLMenuStyle` (L2187)
  The theme's colors over `baseStyle` (`colorTheme`), one cached style per item.

- `func tag(at indexPath: IndexPath) -> CYLTag?` (L2203)
  One of `tags` when the list shows them.

- `func showTags() -> CYLTagDataSource` (L2214)
  Shows `tagDataSource`, the way android-tagview does the first time: no section headers, taps only.

- `func titleHeight(forWidth width: CGFloat) -> CGFloat` (L2263)
  The height of the title area, 0 without a title or an icon.

- `func titleFrame(forWidth width: CGFloat, height titleHeight: CGFloat) -> CGRect` (L2274)
  The title view's frame: as wide as its content (no wider than the list), at the leading edge or centered.

- `func showsInlineFoldCell(inSection section: Int) -> Bool` (L2326)
  Whether a section shows the inline fold cell (it can fold: some items do not fit in the visible rows).

- `func isInlineFoldCell(at indexPath: IndexPath) -> Bool` (L2333)
  The inline fold cell comes right after the section's visible items.

- `var displayedFoldControl: CYLMenuFoldControl` (L2341)
  The fold control as shown: `CYLMenuStyle.foldChevronImage` replaces the default chevron.

- `func foldSize(expanded: Bool) -> CGSize` (L2358)
  The fold control's size in a state.

- `func headerFoldSize(expanded: Bool) -> CGSize` (L2365)
  The fold control in a header: the wider of the two states' widths (the header does not change when the section folds), the height of `expanded`.

- `var sizesHeaderToText: Bool` (L2393)
  Whether the header is sized to its text and the board starts `CYLSectionStyleMetrics.headerBoardSpacing` below it: under
  `.insetGrouped` with no header divider (the divider needs the old reservation) and with section headers shown.

- `func headerHeight(forSection section: Int, width: CGFloat, canFold: Bool) -> CGFloat` (L2402)
  The header of `section` at the list width `width`: `headerHeight(foldable:)`, or, when `CYLMenuStyle.headerMaxLines` allows more than
  one line, tall enough for the title wrapped to the room left of the indicator and the fold / More / clear controls, plus 12 pt
  of padding; never below `headerHeight(foldable:)`. `canFold`: the section shows a fold control.

- `func column(atWidth width: CGFloat) -> CGRect` (L2436)
  The one column function: the section column at the list width `width`, the list width minus `sectionInsets` (x and width; y and
  height are 0). The card, the header band and the divider span it.

- `func boardColumn(atWidth width: CGFloat) -> CGRect` (L2445)
  The board's column: the tag column widened by `sectionBoardInset` on both sides; the section column when the inset is unset or
  the style is plain (no board).

- `var cardInsets: UIEdgeInsets` (L2458)
  The card's padding around the tags: `sectionContentInsets` under `.insetGrouped`, else none.

- `func tagColumn(atWidth width: CGFloat) -> CGRect` (L2466)
  The column the tags are laid in: the section column, narrowed by the card's padding. Every tag width, row count, fold decision,
  height and frame takes its width and x from here.

- `func tagInsets(atWidth width: CGFloat) -> UIEdgeInsets` (L2475)
  The flow layout's section insets: the tag column's edges, and the section's top and bottom insets plus the card's.

- `func headerEdgeInsets(atWidth width: CGFloat) -> (leading: CGFloat, trailing: CGFloat)` (L2500)
  The distances from the list's leading and trailing edges to a header's title and fold control: the tags' edges inside the card
  (`.insetGrouped`), the band's edges plus `headerContentInsets` (a plain header with a band), else `headerHorizontalInset`.

- `func configureHeaderSectionStyle(_ header: CYLTagListHeaderView)` (L2516)
  Gives a header its insets, band and divider.

- `func measureItemHeights(widths: [[CGFloat]]) -> [[CGFloat]]` (L2565)
  Each item's height; an item whose style wraps its title (`CYLMenuStyle.titleWraps`) is measured at its width in
  `widths`, so a long title that wraps gets a taller cell.

- `func heightOfRows(_ rowCount: Int, rows: [Int], heights: [CGFloat]) -> CGFloat` (L2588)
  The height of the first `rowCount` rows of a section: each row as tall as its tallest item. Rows past the
  measured ones (the inline fold cell on a row of its own) are the list's item height.

- `func gridItemWidth(forContentWidth contentWidth: CGFloat, itemsPerRow: Int) -> CGFloat` (L2609)
  The width of a grid item: the content width minus the spacing, divided evenly.

- `func rows(forWidths widths: [[CGFloat]], contentWidth: CGFloat) -> [[Int]]` (L2617)
  Items per row, computed in a single pass.

- `func setInlineExpanded(_ expanded: Bool, forSection section: Int, animated: Bool)` (L2715)
  The inline fold cell moves with the items: reload the section (the chevron turns in its new place).

- `func moveAccessibilityFocusToFoldControl(inSection section: Int)` (L2731)
  VoiceOver keeps its place after the section changes size: focus the section's fold control.

- `func updateFoldControls(inSection section: Int, animated: Bool)` (L2752)
  Updates the visible fold controls of a section without reloading it.

- `func configureFoldButton(_ button: CYLTagFoldButton, section: Int, expanded: Bool, animated: Bool)` (L2769)
  Shows the fold control in a state, with its VoiceOver label ("<section> 更多/收起") and hint.

- `func foldAccessibilityLabel(forSection section: Int) -> String` (L2793)
  "<section title> <expand or collapse title>", so a fold control says which section it changes.

- `func applySelection(of indexPath: IndexPath) -> [IndexPath]` (L2813)
  Adds `indexPath` and removes the items that the selection mode excludes; returns the removed ones.

- `func shiftSelection(inSection section: Int, fromItem item: Int, by offset: Int)` (L2885)
  Moves selected items of a section at or after `item` by `offset`.

- `func removeSelection(at indexPath: IndexPath)` (L2895)
  An item was removed: it leaves the selection and the items after it move up.

- `func accessibilityActions(forItemAt indexPath: IndexPath) -> [UIAccessibilityCustomAction]` (L2972)
  What VoiceOver, Voice Control and Switch Control users pick instead of a long press or a drag.

- `func accessibilityMoveItem(at indexPath: IndexPath, by offset: Int) -> Bool` (L3003)
  前移 / 后移: the same move as a drag, then the new position is announced.

- `@objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer)` (L3041)
  Reorders on a long press and a move; a long press that does not move is reported (onTagLongClick).

- `func measuredIndexPath(for indexPath: IndexPath) -> IndexPath` (L3185)
  The index path whose measurement belongs at `indexPath`. While a tag is dragged (and until the measurements follow
  the move), the collection view shows the items in the new order but the widths are still in the old one: without
  this, every slot kept the width of the tag that was there before and the moved titles were cut ("Kot…").

- `func headerTitleStyle() -> CYLMenuStyle` (L3204)
  The look of a section's icon and title: the style's header font and color, a 16 pt icon 8 pt before the title,
  at the leading edge.

- `public func scrollViewWillBeginDragging(_ scrollView: UIScrollView)` (L3291)
  A scroll hides the long-press callout.

- `func cylApplyListAnimationSpeed(_ speed: CGFloat?)` (L3382)
  The list's `animationSpeed`: a speed sets the tag's own, `nil` lets it follow its style again.

- `var firstEditableSection: Int?` (L3396)
  The first section that takes part in editing, if any.

- `func updateAddItemView()` (L3401)
  Shows or hides `addItemView` and reserves its space below the last section.

- `func layoutAddItemView()` (L3419)
  Places `addItemView` right below the sections, inside the collection view (it scrolls with the items).

- `func requestNewItem(named name: String)` (L3431)
  A name submitted in `addItemView`: a rename while one is in progress, else a new item at the end of the first
  editable section.

- `open func loadSections(withKeys keys: [String], completion: @escaping ([String: [String]], CYLTagListDataOrigin) -> Void)` (L3454)
  Reads the sections saved under `keys` from the cache and `remoteSource`, in the order of `loadPolicy`, and calls
  `completion` on the main queue with the titles by key and where they come from: once or twice
  (`.cacheThenNetwork`: the cache at once, then the server). Downloaded sections are saved to the cache first.
  Without a remote source it reads the cache only; nothing saved anywhere calls nothing.

- `open func loadItems(withKeys keys: [String],` (L3512)
  `loadSections(withKeys:completion:)` with identifiers: the cache's items (`cachedItems(forSection:)`) and the
  remote source's (`fetchItems(withKeys:completion:)`, else its titles, each its own identifier), in the order of
  `loadPolicy`; downloaded items are saved to the cache first.

- `final class CYLTagListClearButton: UIButton` (L3613)
  A section header's clear button: drawn as tall as the title's line, tapped in a 44 point area around it.

- `open func setTags(withCharactersOf text: String)` (L3631)
  Replaces the tags with one tag per character of `text`, in order: each grapheme (a letter, a Chinese character, an
  emoji, a space) is one tag, as the word picker's cells (`CYLMenuStyle.wordPicker()`). Unlike the first
  `setTags(withTitles:)`, it keeps `selectionMode` (a word picker selects several cells).

- `@objc open var selectedText: String` (L3641)
  The titles of the selected items joined in item order: the picked text (for a word picker, the characters the user
  smeared, as they stand in the text).

- `open func selectItems(from start: IndexPath, through end: IndexPath)` (L3650)
  Selects every selectable item from `start` through `end` (either order), in item order across sections, as a smear
  over them does, without calling the delegate. Needs `selectionMode == .multiple`.

- `func itemIndexPathsInOrder() -> [IndexPath]` (L3661)
  Every item, in order across sections (the order a smear follows).

- `func smearedSelection(from base: Set<IndexPath>, anchor: IndexPath, to end: IndexPath, selects: Bool) -> Set<IndexPath>` (L3668)
  `base` with the items from `anchor` to `end` (in item order) selected, or deselected when `selects` is false.

- `func smearableIndexPath(at point: CGPoint) -> IndexPath?` (L3688)
  The item a smear can start on or reach at `point` (in the collection view): a selectable tag, not the fold cell or
  the "new tag" cell.

- `func shouldBeginSmear(at point: CGPoint) -> Bool` (L3699)
  Whether a smear may begin at `point`: smear selection on, multiple selection, a tag under the finger.

- `final class CYLTagListSmearGestureDelegate: NSObject, UIGestureRecognizerDelegate` (L3755)
  Lets the smear recognizer begin only on a tag (`CYLTagListView.allowsSmearSelection`), so that a drag elsewhere
  scrolls.

- `open override func didMoveToWindow()` (L3786)
  Removed from its window in the middle of a drag or a smear: the gesture is over, so the delegate hears `false` and a
  host that locked its scroll view unlocks it.

