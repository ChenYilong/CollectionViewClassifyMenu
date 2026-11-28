# ios-core: library (part 3 of 5)

## CollectionViewClassifyMenu/Class/TagList/CYLTag.swift

 CYLTag.swift
 CollectionViewClassifyMenu
 One tag as a value the host creates and adds (android-tagview's Tag), and CYLTagDataSource, the data source that
 holds such tags. CYLTagListView's tag methods (addTag(_:), addTags(withTitles:), removeTag(at:)…) use one:
     let tagListView = CYLTagListView()
     tagListView.lineSpacing = 5
     tagListView.interitemSpacing = 3
     tagListView.addTags(withTitles: ["Asia", "Europe", "Africa"])
     let tag = CYLTag(title: "Tag Text")
     tag.textColor = .white
     tag.backgroundColor = UIColor(white: 0.87, alpha: 1)
     tag.cornerRadius = 20
     tag.isDeletable = true
     tagListView.addTag(tag)
 Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).

- `public final class CYLTag` (L28)
  One tag of a `CYLTagListView`: its title, icons, state and, optionally, its own look over the list's style. The
  look properties that are `nil` use the list's (or `style`'s) value. A final class: copy it with `copy()`.

- `public var identifier: Int` (L33)
  The host's identifier (android-tagview's Tag.id), 0 by default.

- `public var title: String` (L38)
  The title.

- `public var subtitle: String?` (L43)
  A longer description, shown in a callout on a long press (`CYLTagLongPressActions.callout`).

- `public var image: UIImage?` (L48)
  The icon, as the data source's `menuImageForItem(at:)`.

- `public var selectedImage: UIImage?` (L53)
  The icon while selected, as `menuSelectedImageForItem(at:)`.

- `public var animationURL: URL?` (L58)
  An animated icon (Lottie .json, .pag, .riv, .svga, .gif), as `menuAnimationURLForItem(at:)`.

- `public var isEnabled = true` (L63)
  True by default; a disabled tag is dimmed and ignores taps.

- `public var isDeletable = false` (L68)
  Shows a delete indicator ("×") after the title; a tap on it removes the tag (android-tagview's isDeletable).

- `public var badgeText: String?` (L75)
  A round badge before the title with this text, e.g. "热" or "神" in a search app's hot list; drawn in
  `badgeColor` (the title color by default) with white text, when the tag has no `image`. An empty string (not `nil`) draws a
  dot instead, as `CYLTagButton.badgeValue` "": a filled circle `badgeDotDiameter` points wide in `badgeColor` (system red by default).

- `public var badgeColor: UIColor?` (L80)
  The badge's color; `nil` for the title color.

- `public var badgeAccessibilityLabel: String?` (L86)
  What VoiceOver reads for the badge, after the title (the tag's value), when the badge's glyph alone does not say
  it, such as "热门" for "热". `nil`: `badgeText`.

- `public var userInfo: Any?` (L91)
  Anything the host wants to keep with the tag.

- `public var style: CYLMenuStyle?` (L99)
  The style this tag starts from instead of the list's; the properties below apply over it. Setting copies the
  style. `nil` by default.

- `public var textColor: UIColor?` (L111)
  The title color (android-tagview's tagTextColor); `nil` for the style's.

- `public var font: UIFont?` (L116)
  The title font; `nil` for a system font of `textSize`, or the style's.

- `public var textSize: CGFloat?` (L122)
  The title's point size (android-tagview's tagTextSize), a system font; `nil` for the style's. A larger text makes
  the tag taller.

- `public var backgroundColor: UIColor?` (L127)
  The background (android-tagview's layoutColor); `nil` for the style's.

- `public var highlightedBackgroundColor: UIColor?` (L132)
  The background while pressed (android-tagview's layoutColorPress); `nil` for the style's.

- `public var selectedBackgroundColor: UIColor?` (L137)
  The background while selected (AndroidTagView's tagSelectedBackgroundColor); `nil` for the style's.

- `public var backgroundImage: UIImage?` (L142)
  Drawn behind the title, stretched (android-tagview's background); `nil` for none.

- `public var cornerRadius: CGFloat?` (L147)
  The corner radius (android-tagview's radius); 0 is square, a large value such as 1000 a capsule, `nil` the style's.

- `public var borderWidth: CGFloat?` (L152)
  The border width (android-tagview's layoutBorderSize); `nil` for the style's.

- `public var borderColor: UIColor?` (L157)
  The border color (android-tagview's layoutBorderColor); `nil` for the style's.

- `public var deleteIndicatorTitle: String?` (L162)
  The delete indicator's text (android-tagview's deleteIcon); `nil` for the style's ("×").

- `public var deleteIndicatorColor: UIColor?` (L167)
  The delete indicator's color (deleteIndicatorColor); `nil` for the style's (the title color).

- `public var deleteIndicatorSize: CGFloat?` (L172)
  The delete indicator's point size (deleteIndicatorSize); `nil` for the style's (the title font).

- `public init(identifier: Int = 0, title: String, backgroundColor: UIColor? = nil)` (L182)
  A tag with the list's look, an optional identifier of the host's (android-tagview's Tag.id) and an optional
  background color.

- `public convenience init(identifier: Int = 0, title: String, backgroundColorHex: String?)` (L191)
  With its background color as "#RGB", "#RRGGBB", "#RRGGBBAA" or a UIColor name ("systemBlue").

- `public var colors: CYLTagColors` (L202)
  Sets `backgroundColor`, `borderColor`, `textColor` and `selectedBackgroundColor` at once (AndroidTagView's color
  array), or reads them.

- `public func resetColors()` (L219)
  Resets `colors`: the background, border, text and selected background colors go back to `nil`, so the tag
  draws them from the list's style again (Android `CYLTag.resetColors()`).

- `public var hasCustomStyle: Bool` (L226)
  Whether any look property is set: false draws the tag with the base style itself.

- `public func style(basedOn baseStyle: CYLMenuStyle) -> CYLMenuStyle` (L238)
  A copy of `style` (or of `baseStyle` when it is `nil`) with this tag's look applied: the colors to the normal
  state, the font, corner radius and border to every state.

- `public func copy() -> CYLTag` (L291)
  An independent copy (the user info and the images are shared).

- `public static let badgeDotDiameter: CGFloat = 8` (L321)
  The diameter of a badge dot, in points: 8, as `CYLTagButton`'s dot and the other platforms' (Android `BADGE_DOT_DIAMETER`).

- `public static func badgeDotImage(color: UIColor, canvas: CGFloat) -> UIImage` (L327)
  A badge dot image: a filled `color` circle `badgeDotDiameter` points wide (at most `canvas`), centered in a `canvas` square
  so the tag's icon slot keeps its size (rendered as original). Its accessibility label is the localized dot text.

- `public static let badgeImageTextPadding: CGFloat = 4` (L343)
  The side padding of a badge image's text, in points: 4, as `CYLTagButton`'s corner badge and the other platforms'
  (`BADGE_PADDING`).

- `public static func badgeImageWidth(text: String, diameter: CGFloat) -> CGFloat` (L358)
  The width of a badge image: the diameter (a circle) for a short text, or the text's width and `badgeImageTextPadding`
  on both sides when that is more (a capsule, as `CYLTagButton`'s corner badge: width = max(height, text + 2 * padding)).
  One character (a digit, a letter, a CJK character such as "热") always keeps the circle: it fits inside without the
  padding.

- `public static func badgeImage(text: String, color: UIColor, diameter: CGFloat) -> UIImage` (L372)
  A badge image: `text` in white on a `color` capsule `diameter` points high (rendered as original). A short text
  (a character, a digit) keeps the circle; a longer one ("new", "99+") widens the capsule so that the text is whole
  and centered. The tag's icon slot follows the image's width (`CYLTagButton.iconSize(for:animated:style:)`).

- `var cylIsBadgeImage: Bool` (L408)
  Whether this is a badge image (`CYLTag.badgeImage`), whose own width, not the style's square image size, is its
  icon slot's width.

- `open class CYLTagDataSource: NSObject, CYLMenuDataSource` (L425)
  A data source of `CYLTag` objects in one section. `CYLTagListView`'s tag methods create and use one
  (`tagDataSource`); it can also be given to any list as its `menuDataSource` (keep a strong reference to it).

- `open var tags: [CYLTag]` (L430)
  The tags, in order. Setting them builds every tag's style again.

- `open var sectionTitle: String?` (L443)
  The title of the one section, shown when the list shows section headers ("热门搜索"); empty by default.

- `open var baseStyle: CYLMenuStyle` (L449)
  The style tags with their own look start from (`CYLTagListView` keeps it equal to its style). Setting copies the
  style.

- `public init(tags: [CYLTag] = [])` (L469)
  A data source with these tags.

- `open func addTag(_ tag: CYLTag)` (L479)
  Adds a tag at the end.

- `open func addTags(_ tags: [CYLTag])` (L486)
  Adds tags at the end.

- `open func insertTag(_ tag: CYLTag, at index: Int)` (L493)
  Inserts a tag; an index past the end adds it at the end.

- `open func removeTag(at index: Int)` (L500)
  Removes a tag; out-of-range indexes are ignored.

- `open func removeAllTags()` (L511)
  Removes every tag.

- `open func moveTag(at fromIndex: Int, to toIndex: Int)` (L519)
  Moves a tag; out-of-range indexes are ignored.

- `open func invalidateStyles()` (L529)
  Builds every tag's style again; call it after changing a tag's look (`CYLTagListView.reloadMenuData()` does).

## CollectionViewClassifyMenu/Class/TagList/CYLTagAppearance.swift

 CYLTagAppearance.swift
 CollectionViewClassifyMenu
 The box and text of a tag in one state. Every tag is treated like a CYLBadgeView (CYLTabBarController), so the
 properties and their defaults follow CYLBadgeAppearance: background, text color, font, corner radius (in points, 0 = square
 corners), border and margin.
 Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).

- `public final class CYLTagAppearance` (L25)
  The box and text of a tag in one state (`CYLMenuStyle.normalAppearance`…). A final class: the style copies it.

- `public static let defaultBackgroundColor = UIColor { traits in` (L31)
  The default background: white in light mode, the secondary system background in dark mode (a dynamic color), so the list's one dynamic
  tint (`UIColor.label`: the default of the text, the fold chevron, the More and clear icons, the header title) stays readable on it.

- `public static let defaultTextColor = UIColor { traits in` (L38)
  The default title color: dark gray in light mode, the label color in dark mode (a dynamic color).

- `public static let defaultFont = UIFont.systemFont(ofSize: 14)` (L45)
  The default title font: the system font of 14 points.

- `public var backgroundColor: UIColor!` (L59)
  Background color, `null_resettable`: reads the EFFECTIVE value (the explicit color, else `defaultBackgroundColor`, never nil);
  assigning nil resets to the built-in. `explicitBackgroundColor` / `isBackgroundColorSet` tell whether one was set.

- `public var explicitBackgroundColor: UIColor? { explicitBackground }` (L67)
  The color set on `backgroundColor`; nil when unset (the class built-in applies).

- `public var isBackgroundColorSet: Bool { explicitBackground != nil }` (L72)
  True when `backgroundColor` was set to a color (and not reset).

- `public var textColor: UIColor!` (L78)
  Title color, `null_resettable`: reads the EFFECTIVE value (the explicit color, else `defaultTextColor`, never nil);
  assigning nil resets to the built-in.

- `public var explicitTextColor: UIColor? { explicitText }` (L86)
  The color set on `textColor`; nil when unset.

- `public var isTextColorSet: Bool { explicitText != nil }` (L91)
  True when `textColor` was set to a color (and not reset).

- `public var font = CYLTagAppearance.defaultFont` (L97)
  Title font, the system font of 14 points by default. Scaled for Dynamic Type when the style's
  `adjustsFontForContentSizeCategory` is true.

- `public func resetBackgroundColor()` (L102)
  Resets `backgroundColor` to `defaultBackgroundColor` (Android `resetBackgroundColor`).

- `public func resetTextColor()` (L109)
  Resets `textColor` to `defaultTextColor` (Android `resetTextColor`).

- `public func resetFont()` (L116)
  Resets `font` to `defaultFont` (Android `resetFont`).

- `public var iconColor: UIColor!` (L125)
  Tint of template icons (like `UITabBarItemStateAppearance.iconColor`), `null_resettable`: reads the EFFECTIVE value (the explicit
  icon color, else the effective `textColor`, never nil); assigning nil resets so that the icon follows the text again.
  Icons rendered as original keep their colors.

- `public var explicitIconColor: UIColor? { explicitIcon }` (L133)
  The color set on `iconColor`; nil when unset.

- `public var isIconColorSet: Bool { explicitIcon != nil }` (L138)
  True when `iconColor` was set to a color (and not reset).

- `public var cornerRadius = CYLTagAppearance.defaultCornerRadius` (L145)
  Corner radius in points: 0 is square corners, and a value of half the tag height or more is a capsule (the radius
  is limited to half the height, so a large value such as 1000 is a capsule for any tag). Negative or non-finite
  values are treated as 0. `cylAnimatedItemCornerRadiusCapsule` by default.

- `public var borderColor: UIColor?` (L162)
  Border color, `nil` (no border) by default. Drawn only when `borderWidth` > 0. Reads the effective value (the explicit one, else the
  style's built-in); assigning marks it explicit, also `nil` ("no border").

- `public var borderWidth: CGFloat` (L170)
  Border width, 0 by default. Negative or non-finite values are treated as 0. Assigning marks it explicit.

- `public var isBorderColorSet: Bool { explicitBorderColorStorage != nil }` (L178)
  True when `borderColor` / `borderWidth` was assigned (an app, a configuration, a preset), not the style's built-in default.

- `public var glassBorderColor: UIColor?` (L185)
  The border drawn under Liquid Glass: the EXPLICIT color decides. An explicit color draws the border (the explicit width, else the
  default width); a width set without an explicit color, or nothing explicit, draws none (the shared glass rim shows).

- `func applyBuiltInBorder(color: UIColor?, width: CGFloat)` (L195)
  Sets the style's built-in border, which is not explicit (the style's initializer).

- `func copyBorder(from other: CYLTagAppearance)` (L203)
  Takes `other`'s border with its explicitness (the fold cell copying a tag's border).

- `public var contentInsets = CYLTagAppearance.defaultContentInsets` (L215)
  Space between the border and the content on each side, {5, 10, 5, 10} by default (as android-tagview's
  textPaddingTop / Left / Bottom / Right). The left and right widen the tag; the top and bottom make it taller than
  the style's `itemHeight` only when the font needs it. Negative or non-finite values are treated as 0.

- `public var margin: CGFloat` (L230)
  Horizontal space between the border and the content, 10 by default: the left and right of `contentInsets`.
  Setting it sets both; reading it gives the larger. Negative or non-finite values are treated as 0.

- `public var backgroundImage: UIImage?` (L245)
  Drawn behind the content, stretched to the tag (as android-tagview's Tag.background); use a resizable image for
  caps. `nil` (the default) for none: the background color only.

- `public init() {}` (L250)
  An appearance with the built-in defaults.

- `public func reset()` (L255)
  Restores every property to its built-in default.

- `public func copy() -> CYLTagAppearance` (L272)
  An independent copy.

- `public static func == (lhs: CYLTagAppearance, rhs: CYLTagAppearance) -> Bool` (L296)
  Equal when every property is equal; an unset color is not equal to a color set to the same value as the built-in.

## CollectionViewClassifyMenu/Class/TagList/CYLTagButton.swift

 CYLTagButton.swift
 CollectionViewClassifyMenu
 One tag: CYLTabBarController's shared animated icon + title component, CYLAnimatedItemView (pod
 CYLAnimatedItem, module CYLAnimatedItem, guide:
 https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md), laid out
 as a tag: the icon before, after, above or below the title, in a box drawn from the style's appearance for the
 current state, with an optional delete indicator (the base class's accessory view) and an optional badge.
 CYLTagListView puts one in every cell; the libraries built on this one (a search bar item) subclass it. The icon,
 the title and the animated icon are the base class's: it plays any file of CYLTabBarController's animation engine
 once the app adds an engine subspec (CYLAnimatedItem/LottieSwift, …/PAG, …/Rive, …/SVGA, …/GIF), and shows the static
 image (or its placeholder) otherwise. The core links no engine.
 Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).

- `open class CYLTagButton: CYLAnimatedItemView` (L49)
  One tag: an icon and a title side by side (the icon after, above or below the title with `imagePlacement`), in a box
  drawn from the style's appearance for the current state, with an optional delete indicator, an optional badge and an
  optional animated icon. Use it on its own with `init(title:image:)` or `init(title:image:animationURL:)`.
  It is a `CYLAnimatedItemView`: `title`, `image`, `selectedImage`, `imageView`, `titleLabel`, `animationURL`,
  `animationSpeed`, `animationLoops`, `animationRestingProgress`, `animationView`, `playAnimation()`,
  `restartAnimation()`, `stopAnimation()`, the accessory (the delete indicator) and the gesture `delegate` are the base
  class's. So is the display priority: the animation when it can play; otherwise the static `image` /
  `selectedImage`; the component's placeholder only when there is no static image (a file that cannot play: no engine
  or library, an unknown type, a missing, empty or corrupted file, a failed download). A tag with a title and no icon
  never shows a placeholder. While a remote file downloads, the static image shows.

- `static func contentInset(for style: CYLMenuStyle) -> CGFloat` (L58)
  The space between the border and the content, left and right, that the shape asks for: `cylAnimatedItemLiquidGlassContentInset` for a
  Liquid Glass style where the glass is really drawn (the same condition as the capsule), else 0 (CYLAnimatedItemView's
  `itemContentHorizontalInset` left unset gives the same). The effective inset is the larger of this and the appearance's.

- `@objc public let deleteIndicatorLabel = UILabel()` (L74)
  The label that draws the delete indicator (hidden unless `showsDeleteIndicator`). It is the base class's
  `accessoryView`: a tap on it calls `CYLAnimatedItemViewDelegate.animatedItemViewDidTapAccessory(_:)`.

- `@objc public let badgeLabel = UILabel()` (L79)
  The label that draws the badge (hidden while `badgeValue` is `nil`), at the top trailing corner of the icon.

- `@objc open var badgeValue: String?` (L86)
  The badge's text, as `UITabBarItem.badgeValue`: `nil` (the default) hides the badge, an empty string shows a dot,
  any other text ("3", "99+", "New") a capsule with it. It sits at the top trailing corner of the icon, or of the
  title when there is no icon, and VoiceOver reads it as the tag's value.

- `@objc open var badgeColor: UIColor?` (L97)
  The badge's background color. Setting `nil` restores the default, `UIColor.systemRed`; the text is white.

- `open override var title: String?` (L110)
  The title (the base class's), shown through the style (`CYLMenuStyle.displayedTitle(forTitle:)`).

- `open override var image: UIImage?` (L120)
  The static icon (the base class's): shown until an animation is ready, whenever none can play, and while a
  remote file downloads.

- `open override var selectedImage: UIImage?` (L129)
  Shown while selected (the base class's); `nil` keeps `image` (as CYLFlatDesignTabBarItem.selectedImage).

- `open override var animationSpeed: CGFloat` (L139)
  The playback speed of the animated icon (the base class's), applied at once, also to an animation that is
  playing. Until it is set, the tag follows `style.animationSpeed`; `resetAnimationSpeed()` goes back to it.

- `@objc open var showsDeleteIndicator = false` (L152)
  Shows the style's delete indicator ("×", `CYLMenuStyle.deleteIndicatorTitle`) after the title, as
  android-tagview's deletable tags. False by default. `CYLTagListView` turns it on for deletable items and handles
  taps on it; a tag on its own reports them to `delegate` (`animatedItemViewDidTapAccessory(_:)`).

- `open private(set) var deleteIndicatorHitFrame: CGRect = .zero` (L164)
  The area a tap on the delete indicator should cover, in the tag's coordinates: from the space before it to the
  trailing edge, the tag's full height. `.zero` while it is hidden.

- `@objc open var showsRenameIndicator = false` (L171)
  Shows a rename indicator (a square and pencil) before the delete indicator, for a tag that can be renamed: the two icons are
  then drawn by `editingIndicatorsView`. Needs `showsDeleteIndicator`. False by default; `CYLTagListView` turns it
  on in editing mode for the items its data source can rename and handles taps on it.

- `open private(set) var renameIndicatorHitFrame: CGRect = .zero` (L183)
  The area a tap on the rename indicator should cover, in the tag's coordinates; `.zero` while it is hidden.

- `@objc open var style: CYLMenuStyle` (L236)
  The style the tag is drawn with. Setting copies it; set it again after changing it.

- `public var liquidGlassView: UIView?` (L273)
  The Liquid Glass layer behind the content (CYLAnimatedItemView's `itemLiquidGlassView`) while
  `drawsLiquidGlass`; `nil` when the tag is flat.

- `public convenience init(title: String?, image: UIImage?)` (L300)
  A tag for use on its own (a search bar item, a toolbar button): a title, an icon or both, sized to fit
  (`intrinsicContentSize`), drawn with the default style, an accessibility element with the button trait.

- `public convenience init(title: String?, image: UIImage?, animationURL: URL?)` (L309)
  The same with an animated icon (Lottie, PAG, Rive, SVGA, GIF…) in the icon slot; `image` is shown while no
  engine is in the app, while the file downloads, or when it cannot be played.

- `open override func reloadAnimation()` (L396)
  Builds the animation view again (a new file or size) and shows the state's frame (the base class does, `showsLastFrameWhenSelected`).

- `@objc open func resetAnimationSpeed()` (L404)
  Goes back to `style.animationSpeed` after `animationSpeed` was set.

- `public static func width(forTitle title: String?, image: UIImage?, style: CYLMenuStyle,` (L415)
  Width a tag needs for its content in every state (so that selecting it does not resize it), before any limit on
  the available width.

- `public static func width(forTitle title: String?, iconSize: CGSize, showsDeleteIndicator: Bool = false,` (L425)
  The same for an icon of `iconSize` (`.zero` for none), e.g. an animated icon, with room for the delete indicator
  when `showsDeleteIndicator`.

- `public static func iconSize(for image: UIImage?, animated: Bool, style: CYLMenuStyle) -> CGSize` (L480)
  Size of the icon slot for an image, or for an animated icon when `animated` and an engine is in the app; an
  animated icon without an engine and without an image takes the size of the component's placeholder
  (`CYLAnimatedItemView.defaultPlaceholderImage`), which the tag then shows.

- `public static func height(for style: CYLMenuStyle, traitCollection: UITraitCollection?) -> CGFloat` (L494)
  Tag height: `style.itemHeight`, or more when a line of the title font plus the appearance's top and bottom
  content insets needs it; with the icon above or below the title, also the icon slot and the spacing.

- `public static func height(forTitle title: String?, iconSize: CGSize, style: CYLMenuStyle,` (L510)
  The height a tag needs for this title and an icon of `iconSize` (`.zero` for none) in every state: the tallest
  of the two side by side, or both and the spacing when the icon is above or below the title; at least
  `style.itemHeight`.

- `public static func height(forTitle title: String?, iconSize: CGSize, width: CGFloat, showsDeleteIndicator: Bool,` (L531)
  The height of a tag `width` wide: with `CYLMenuStyle.titleWraps`, the title wrapped to the room it has beside the
  icon and the delete indicator; otherwise `height(forTitle:iconSize:style:traitCollection:)`.

- `open override var intrinsicContentSize: CGSize` (L572)
  The size the tag needs for its title, icon (or animated icon), delete indicator and style, in every state.

- `open override var accessibilityLabel: String?` (L604)
  The title (or the icon's `accessibilityLabel`) unless a label was set.

- `open override func itemAccessibilityLabel() -> String?` (L616)
  The title as shown, or the icon's `accessibilityLabel` for an icon-only tag.

- `open override func updateItemAccessibility()` (L625)
  The label, value and traits are computed when VoiceOver reads them (`accessibilityLabel`, `accessibilityValue`,
  `accessibilityTraits`), so a label or traits set by the app are kept.

- `open override var accessibilityValue: String?` (L632)
  The badge unless a value was set: its text, or "New" (localized) for a dot.

- `open override var accessibilityTraits: UIAccessibilityTraits` (L651)
  For a tag made with a convenience initializer, the traits it was given plus selected and not enabled from its
  state.

- `open override func itemStateDidChange()` (L678)
  The look of the state (selected, highlighted, enabled), from the style's appearance.

- `open override func layoutContent(in rect: CGRect)` (L693)
  CYLFlatDesignTabBarButton's `_updateLayout`, with the icon and title side by side (the base class's layout hook;
  the insets come from the style's appearance for the current state). The image view and the animation view share
  the icon frame: the base class shows the static image (or its placeholder) until the animation shows.

- `var mirrorsContent = false` (L708)
  Whether the icon and the title are mirrored (placed from the right edge). The section headers set it on their title and fold
  control while their own layout direction is right-to-left; the tags keep the placement they have always had.

- `var cylIsVertical: Bool` (L1189)
  True for `.top` and `.bottom`: the icon and the title are stacked.

- `func fillsTagHeight(withIconSize iconSize: CGSize) -> Bool` (L1199)
  Whether an icon of this size is drawn by `imageFillsTagHeight` (a leading icon beside the title).

## CollectionViewClassifyMenu/Class/TagList/CYLTagColors.swift

 CYLTagColors.swift
 CollectionViewClassifyMenu
 The four colors of a tag (background, border, text, selected background) and the color themes that make them, as
 AndroidTagView's ColorFactory: a random Material color, pure cyan or pure teal, each a 0x33 background and a 0x88
 border of the same color.
 Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).

- `@objc public enum CYLTagColorTheme: Int` (L16)

- `case none = -1` (L20)
  The style's own colors (ColorFactory.NONE, the default).

- `case random = 0` (L24)
  A Material color per tag (ColorFactory.RANDOM), the same one for a tag every time it is drawn.

- `case pureCyan = 1` (L28)
  ColorFactory.PURE_CYAN.

- `case pureTeal = 2` (L32)
  ColorFactory.PURE_TEAL.

- `public struct CYLTagColors: Equatable` (L38)
  The four colors of a tag; `nil` keeps the style's color.

- `public static let backgroundAlpha: CGFloat = 0x33 / 255` (L43)
  ColorFactory's alpha of a theme's background ("33").

- `public static let borderAlpha: CGFloat = 0x88 / 255` (L48)
  ColorFactory's alpha of a theme's border ("88").

- `public static let paletteHexByName = Dictionary(uniqueKeysWithValues: zip(paletteNames, palette))` (L54)
  ColorFactory's palette: RED, LIGHTBLUE, AMBER, ORANGE, YELLOW, LIME, BLUE, INDIGO, LIGHTGREEN, GREY, DEEPPURPLE,
  TEAL, CYAN, as "RRGGBB".

- `public static var gray666666: UIColor` (L59)
  ColorFactory's SHARP666666.

- `public static var gray727272: UIColor` (L66)
  ColorFactory's SHARP727272.

- `public var backgroundColor: UIColor?` (L81)
  The background.

- `public var borderColor: UIColor?` (L86)
  The border.

- `public var textColor: UIColor?` (L91)
  The title.

- `public var selectedBackgroundColor: UIColor?` (L96)
  The background while selected.

- `public init(backgroundColor: UIColor? = nil, borderColor: UIColor? = nil, textColor: UIColor? = nil,` (L101)
  Colors; `nil` keeps the style's.

- `public init(paletteHex hex: String, textColor: UIColor, selectedBackgroundColor: UIColor)` (L113)
  The palette color `hex` ("F44336") as a theme makes it (0x33 background, 0x88 border), with these text and
  selected background colors.

- `public init?(theme: CYLTagColorTheme, seed: Int)` (L123)
  The colors of a theme; for the random theme, the palette color at `seed` modulo the palette's size
  (ColorFactory's onRandomBuild picks one at random). `nil` for `.none`.

- `public static func random() -> CYLTagColors` (L141)
  A random palette color (onRandomBuild).

- `public func styleByApplying(to style: CYLMenuStyle) -> CYLMenuStyle` (L150)
  A copy of `style` with these colors: background, border (a hairline when the style had none) and text in the
  normal state, the text, border and background in the selected state.

## CollectionViewClassifyMenu/Class/TagList/CYLTagCreateCell.swift

 CYLTagCreateCell.swift
 CollectionViewClassifyMenu
 The "+ 新建标签" item of CYLTagListView (CYLMenuItemType.create): an outlined tag with a plus icon. A tap on it
 asks the delegate to create a tag (menu(_:didRequestNewItemWithName:at:)); it is never selected.
 Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).

- `open class CYLTagCreateCell: CYLTagListCell` (L15)
  The "+ 新建标签" item: an outlined tag with a plus icon, an action rather than a tag (never selected).

- `public static var plusImage: UIImage` (L22)
  The plus icon of the core bundle (a template image, drawn in the icon color).

- `public static func title(forName name: String?) -> String` (L29)
  "新建标签" for an empty name, "新建标签：<name>" otherwise, in the component's language.

- `public static func outlinedStyle(from style: CYLMenuStyle) -> CYLMenuStyle` (L40)
  The outlined look of the item, from a list (or section) style: the list's background, a hairline border and
  secondary text. The metrics stay the list's.

- `open func configure(name: String?, style: CYLMenuStyle, isEnabled: Bool)` (L60)
  Shows "+ 新建标签" or "+ 新建标签：<name>" in `style` (already outlined, `outlinedStyle(from:)`).

## CollectionViewClassifyMenu/Class/TagList/CYLTagFoldButton.swift

 CYLTagFoldButton.swift
 CollectionViewClassifyMenu
 Draws a CYLMenuFoldControl: a CYLTagButton (the tag view) without a border or background, with the title and the
 chevron after it. Expanded, it shows what the control shows expanded (the collapse title, the icon turned 180°, or only the icon). CYLTagListView puts it below the section, in its header or among the tags.
 Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).

- `open class CYLTagFoldButton: CYLTagButton` (L15)
  The view of a fold control (`CYLMenuFoldControl`), a tag view whose title and icon follow the expanded state.

- `public static let maximumUncappedContentSizeCategory = UIContentSizeCategory.accessibilityMedium` (L28)
  The largest content size category an uncapped control's title scales to: at the accessibility sizes the "More" control
  stays a control, not a banner.

- `public static let maximumContentSizeCategory = UIContentSizeCategory.large` (L40)
  The largest content size category a size-capped control (`CYLMenuFoldControl.isSizeCapped`) scales its font to.

- `public static let maximumHeaderWidthFraction: CGFloat = 0.4` (L45)
  The widest a size-capped header control gets, as a fraction of the header's width.

- `open private(set) var foldControl: CYLMenuFoldControl?` (L50)
  The control last applied.

- `open private(set) var isExpanded = false` (L55)
  The state last applied.

- `open func applyFoldControl(_ foldControl: CYLMenuFoldControl, color: UIColor?, expanded: Bool, animated: Bool)` (L81)
  Shows `foldControl` in `color` (its own color wins) for the expanded or collapsed state; the icon turns with an
  animation when `animated` (not with Reduce Motion).

- `public static func font(for foldControl: CYLMenuFoldControl, traitCollection: UITraitCollection?) -> UIFont` (L92)
  The control's font: its own, else the footnote text style scaled with Dynamic Type, for a size-capped control
  no larger than the footnote size of `maximumContentSizeCategory`.

- `open func applyInlineFoldControl(_ foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: Bool,` (L112)
  The inline fold control (`CYLMenuFoldControlPosition.tail`): the same content as
  `applyFoldControl(_:color:expanded:animated:)`, drawn like the tags of `itemStyle` (its normal look, outlined),
  so it reads as the last tag; its icon and title take the control's color, else `itemStyle.foldControlColor`,
  like the other fold controls. An icon-only control is a circle.

- `public static func inlineSize(for foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: Bool,` (L122)
  The size of the inline fold control in that state: the tags' height, and at least as wide as it is high.

- `public static func size(for foldControl: CYLMenuFoldControl, expanded: Bool,` (L135)
  The size the control needs in that state (at least a 44 pt wide touch target).

## CollectionViewClassifyMenu/Class/TagList/CYLTagFoldCell.swift

 CYLTagFoldCell.swift
 CollectionViewClassifyMenu
 The inline fold control of CYLTagListView (CYLMenuFoldControlPosition.tail): a cell among the tags, after the
 last visible one, drawn like a tag.
 Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).

- `open class CYLTagFoldCell: UICollectionViewCell` (L16)
  A collection view cell that shows a fold control like a tag (`CYLTagFoldButton`); the cell is the accessibility
  element (identifier `CYLTagListFoldControl`), a button whose label the list sets.

- `@objc public let foldButton = CYLTagFoldButton(frame: .zero)` (L21)
  The control drawn in the cell; the collection view handles its taps.

- `open func configure(foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: Bool, animated: Bool)` (L48)
  Shows `foldControl` for the expanded or collapsed state, drawn like the tags of `itemStyle`.

## CollectionViewClassifyMenu/Class/TagList/CYLTagListAccessibility.swift

 CYLTagListAccessibility.swift
 CollectionViewClassifyMenu
 Stable accessibility identifiers of CYLTagListView's views, so UI tests, Voice Control scripts and tools find them
 without coordinates. The labels stay localized; the identifiers never change.
 Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).

- `public enum CYLTagListAccessibilityIdentifier` (L15)
  The accessibility identifiers of `CYLTagListView`'s views.

- `public static let title = "CYLTagListTitle"` (L20)
  The list's title view (`CYLTagListView.titleView`), a header.

- `public static let foldControl = "CYLTagListFoldControl"` (L25)
  Every fold control ("<section> 更多/收起"), in a section header, at the bottom or among the tags.

- `public static let item = "CYLTagListItem"` (L30)
  Every tag cell; its label is the tag's title.

- `public static let createItem = "CYLTagCreateItem"` (L35)
  The "+ 新建标签" item (`CYLMenuItemType.create`).

- `public static let moreButton = "CYLTagListMoreButton"` (L40)
  The More button of a section header (`menuShowsMoreButton(inSection:)`).

- `public static let deleteButton = "CYLTagListDeleteButton"` (L45)
  The tappable delete indicator ("×") of a deletable tag; VoiceOver users get a "Delete" action on the tag instead.

- `public static let renameButton = "CYLTagListRenameButton"` (L50)
  The rename indicator of a tag in editing mode (a pencil before the delete indicator).

- `public static let renameTitle = "CYLTagListRenameTitle"` (L56)
  The title of a renamable tag in editing mode: a tap on it renames the tag too
  (`CYLTagListView.renamesOnTitleTapWhileEditing`).

- `public static let clearButton = "CYLTagListClearButton"` (L61)
  A section header's clear button (the trash icon).

## CollectionViewClassifyMenu/Class/TagList/CYLTagListAddItemView.swift

 CYLTagListAddItemView.swift
 CollectionViewClassifyMenu
 The "add tag" control CYLTagListView shows below its last section while it is editing (`isEditing`): a text field
 and an Add button, like AndroidTagView's demo (an EditText and an "ADD TAG" button under the tags).

- `open class CYLTagListAddItemView: UIView, UITextFieldDelegate` (L17)
  The "add tag" control of `CYLTagListView` in editing mode: a text field and an Add button. The list places it below
  its last section and reports a submitted name through `menu(_:didRequestNewItemWithName:at:)`; customize its field
  and button (placeholder, fonts, colors) as needed.

- `public let textField = UITextField()` (L22)
  The name field. Its placeholder is the localized "Tag name" (`CYLMenuAddTagPlaceholder`).

- `public let addButton = UIButton(type: .system)` (L27)
  The Add button (`CYLMenuAddTag`); it is enabled while the field has a name.

- `open var submitHandler: ((String) -> Void)?` (L32)
  Called with the trimmed name when the Add button or the keyboard's return key is tapped; the field is cleared.

- `open private(set) var isRenaming = false` (L37)
  Whether the control renames a tag (`beginRenaming(title:)`) instead of adding one.

- `@objc open func beginRenaming(title: String)` (L43)
  Renames a tag: the field shows `title` with the keyboard up, the button reads "Done" (`CYLMenuRenameDone`); the
  next submit reports the new name, then the control adds tags again.

- `@objc open func endRenaming()` (L58)
  Leaves renaming without a change: the field is cleared and adds tags again.

- `open var preferredHeight: CGFloat` (L72)
  The height of the control; 44 points by default, larger with larger Dynamic Type.

- `public static let textFieldIdentifier = "CYLTagListAddItemField"` (L118)
  The accessibility identifier of the text field ("CYLTagListAddItemField").

- `public static let addButtonIdentifier = "CYLTagListAddItemButton"` (L123)
  The accessibility identifier of the Add button ("CYLTagListAddItemButton").

- `open var name: String` (L136)
  The trimmed name in the field.

- `@objc open func submit()` (L148)
  Submits the name in the field (as the Add button does): calls `submitHandler` and clears the field. An empty
  name does nothing.

## CollectionViewClassifyMenu/Class/TagList/CYLTagListCache.swift

 CYLTagListCache.swift
 CollectionViewClassifyMenu
 A cache of a tag list's sections, so an order changed in editing mode (a drag), a deleted tag or an added one
 survives a relaunch: a SQLite database (the default), NSUserDefaults or a JSON file in the app's sandbox, behind
 one store, as CYLSearchViewController's suggestion cache (CYLSearchSuggestionStore).

- `@objc public enum CYLTagListCachePolicy: Int` (L16)

- `case none` (L20)
  No cache (the default of `CYLTagListView`): edits live as long as the host's data.

- `case database` (L24)
  A SQLite database in the app's Application Support folder.

- `case userDefaults` (L28)
  `NSUserDefaults`.

- `case sandboxFile` (L32)
  A JSON file in the app's sandbox (Application Support).

- `@objc public protocol CYLTagListCache: NSObjectProtocol` (L39)

- `func cachedTitles(forSection section: String) -> [String]?` (L43)
  The titles saved for `section`, in order; nil when nothing was saved for it.

- `func saveTitles(_ titles: [String], forSection section: String)` (L48)
  Saves `titles` (in this order) as the contents of `section`, replacing what was saved.

- `func removeTitles(forSection section: String)` (L53)
  Removes what was saved for `section`.

- `func removeAllTitles()` (L58)
  Removes every section of this cache.

- `@objc optional func cachedItems(forSection section: String) -> [CYLTagListCacheItem]?` (L64)
  The items (stable identifier and title) saved for `section`, in order; nil when none were saved. Optional: a
  cache without it keeps titles only.

- `@objc optional func saveItems(_ items: [CYLTagListCacheItem], forSection section: String)` (L69)
  Saves `items` (in this order) as the contents of `section`; `cachedTitles(forSection:)` then returns their titles.

- `public final class CYLTagListCacheItem: NSObject` (L78)
  One saved item of a tag list: its stable identifier (a database id; the title when the item has none) and its
  current title. A reorder or a rename keeps the identifier, so whatever the host binds to it (contacts) stays bound.

- `public let identifier: String` (L82)
  The stable identifier.

- `public let title: String` (L87)
  The title shown.

- `public init(identifier: String, title: String)` (L92)
  An item with `identifier` and `title`.

- `public final class CYLTagListStore: NSObject, CYLTagListCache` (L117)
  The built-in caches: a database, `NSUserDefaults` or a file, behind one class. `name` separates the caches of
  different lists (the database key, the defaults key or the file name).

- `public let policy: CYLTagListCachePolicy` (L122)
  The policy of this store.

- `public let name: String` (L127)
  Separates the caches of different lists.

- `public static func cache(policy: CYLTagListCachePolicy, name: String) -> CYLTagListStore?` (L136)
  The store for `policy` and `name`; nil for `CYLTagListCachePolicyNone`.

- `public init(policy: CYLTagListCachePolicy, name: String)` (L143)
  A store for `policy` and `name` ("CYLTagListView" when empty).

- `@objc public enum CYLTagListLoadPolicy: Int` (L362)

- `case cacheThenNetwork` (L366)
  The cache at once, then the remote source; a successful download is saved and reported again (the default).

- `case cacheFirst` (L370)
  The cache when it holds every section asked for; otherwise the remote source (the cache if that fails).

- `case networkFirst` (L374)
  The remote source; the cache only when the download fails.

- `@objc public enum CYLTagListDataOrigin: Int` (L380)

- `case cache` (L384)
  The local cache (`CYLTagListView.cache`).

- `case network` (L388)
  The remote source (`CYLTagListView.remoteSource`).

- `@objc public protocol CYLTagListRemoteSource: NSObjectProtocol` (L396)

- `func fetchSections(withKeys keys: [String], completion: @escaping ([String: [String]]?, Error?) -> Void)` (L402)
  Downloads the sections saved under `keys`; calls `completion` once, on any queue, with the titles by key (a
  missing key: nothing on the server) or an error.

- `optional func fetchItems(withKeys keys: [String], completion: @escaping ([String: [CYLTagListCacheItem]]?, Error?) -> Void)` (L410)
  Downloads the sections saved under `keys` as items (stable identifier and title), for
  `CYLTagListView.loadItems(withKeys:completion:)`. Optional: without it, the titles are fetched and each title is
  its own identifier.

## CollectionViewClassifyMenu/Class/TagList/CYLTagListCell.swift

 CYLTagListCell.swift
 CollectionViewClassifyMenu
 The cell of CYLTagListView: it hosts one CYLTagButton (the tag view) and is the accessibility element.
 Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).

- `open class CYLTagListCell: UICollectionViewCell` (L15)
  The cell of `CYLTagListView`: one `CYLTagButton` (the tag view); the cell is the accessibility element, a button
  whose label is the tag's title.

- `@objc public let button = CYLTagButton(frame: .zero)` (L22)
  The tag view. The collection view handles taps, so it ignores touches.

- `open weak var appliedStyle: CYLMenuStyle?` (L27)
  The list's style object last applied, so that a style is copied into the button only when it changes.

- `open var isDeletable = false` (L32)
  Shows the delete indicator ("×") and makes it tappable; also adds a VoiceOver "Delete" action. False by default.

- `open var deleteHandler: (() -> Void)?` (L44)
  Called when the delete indicator is tapped (or the VoiceOver action is used).

- `open var isRenamable = false` (L50)
  Shows the rename indicator (a pencil before the cross, `CYLTagButton.showsRenameIndicator`) and makes it
  tappable; also adds a VoiceOver "Edit" action. Needs `isDeletable`. False by default.

- `open var renameHandler: (() -> Void)?` (L64)
  Called when the rename indicator is tapped (or the VoiceOver action is used), and on a title tap while
  `renamesOnTitleTap`.

- `open var renamesOnTitleTap = false` (L70)
  A tap on the title (outside the editing icons) renames too, as the pencil does. Needs `isRenamable`. False by
  default.

- `open var additionalAccessibilityActions: [UIAccessibilityCustomAction] = []` (L80)
  Custom actions after 删除 (the list's long-press and 前移 / 后移 actions); reset on reuse.

- `open func showRipple(at point: CGPoint)` (L131)
  Plays `CYLMenuStyle`'s touch ripple (`rippleColor`) from `point`, in the tag's coordinates; a touch plays it
  too.

- `open func configure(title: String, image: UIImage?, selectedImage: UIImage?, animationURL: URL?,` (L171)
  Shows a tag: its title (also its accessibility label; an icon-only tag's is its icon's), icons, look and state. An
  icon's `accessibilityLabel`, when the app gives it one (such as a "hot" icon), is read by VoiceOver as the tag's
  value; an SF Symbol's automatic label is not (it names the glyph, in the device's language).

## CollectionViewClassifyMenu/Class/TagList/CYLTagListSectionCard.swift

 CYLTagListSectionCard.swift
 CollectionViewClassifyMenu
 The section card of `CYLSectionStyle.insetGrouped`: a decoration view behind the section's tags, placed by the list's
 layout from the tags' own frames (docs/tag-section-style.md).

- `struct CYLTagListCardSpec` (L24)
  What the layout needs to draw one section's card.

- `let column: CGRect` (L29)
  The section column: its x and width in the layout's coordinates (y and height are 0).

- `let padding: UIEdgeInsets` (L34)
  The padding between the card and the tags, top and bottom (left and right are inside `column`).

- `let color: UIColor` (L38)
  The flat card's color, as drawn where the glass is not.

- `let glassTint: UIColor?` (L42)
  The glass tint: `sectionBackgroundColor` when the app set it, else `nil` (the item's default glass tint `CYLAnimatedItemView.defaultGlassTint` applies, as for a tag).

- `let usesGlass: Bool` (L46)
  Whether the card is Liquid Glass (`sectionBackgroundStyle`); flat where the system draws none.

- `final class CYLTagListCardAttributes: UICollectionViewLayoutAttributes` (L53)
  Layout attributes of a card: its color and corner radius travel with the frame.

- `final class CYLTagListCardView: UICollectionReusableView` (L85)
  A section card. Its colors are dynamic colors, resolved with this view's own traits, so a mode change updates a shown card. A glass
  card is the library's Liquid Glass (a `CYLAnimatedItemView` with `itemBackgroundStyle = .liquidGlass`, as the glass tags are) with the
  card's corner radius; where the system draws no glass the card is flat.

- `@objc let glassHost = CYLAnimatedItemView()` (L90)
  The glass behind the card's content, hidden while the card is flat.

- `final class CYLTagListLayout: CYLCollectionViewLeftAlignedLayout` (L146)
  The left-aligned tag layout, plus one card per section behind its items.

- `var cardProvider: ((Int) -> CYLTagListCardSpec?)?` (L153)
  The card of a section; `nil`: none (a plain list).

