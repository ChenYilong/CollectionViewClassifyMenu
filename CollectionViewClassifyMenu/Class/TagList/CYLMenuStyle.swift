//
//  CYLMenuStyle.swift
//  CollectionViewClassifyMenu
//
//  Appearance of CYLTagListView. Copy a preset and change what you need.
//
//  Each tag is drawn like a CYLFlatDesignTabBarItem of CYLTabBarController, laid out horizontally (icon, then title)
//  instead of vertically: per-state title text attributes and icon colors, image/title position adjustments, image
//  insets and layoutCentered for icon-only or title-only tags. Its box (background, border, corner radius, margin) is
//  configured like a CYLBadgeView, through one CYLTagAppearance per state.
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * Where a tag's icon goes relative to its title.
 */
@objc public enum CYLTagImagePlacement: Int {
    /**
     * Icon, then title (the default).
     */
    case leading = 0
    /**
     * Title, then icon, e.g. "更多 ⌄".
     */
    case trailing
}

/**
 * Where a tag's content (its icon and title, in the order of `CYLTagImagePlacement`) sits in the tag.
 */
@objc public enum CYLTagContentAlignment: Int {
    /**
     * Centered in the tag (the default).
     */
    case center = 0
    /**
     * At the leading margin: the title (or the icon) starts there and the other follows it, e.g. a search suggestion
     * "苹果官方社区… [热]" whose title is truncated so the icon after it stays visible.
     */
    case leading
}

/**
 * How the tags of a row line up (AndroidTagView's container_gravity).
 */
@objc public enum CYLTagRowAlignment: Int {
    /**
     * From the leading edge (the default).
     */
    case leading = 0
    /**
     * Centered.
     */
    case center
    /**
     * From the trailing edge.
     */
    case trailing
}

/**
 * Where a deletable tag's delete indicator is.
 */
@objc public enum CYLTagDeleteIndicatorPlacement: Int {
    /**
     * After the title (the default).
     */
    case trailing = 0
    /**
     * Before the content, as AndroidTagView's cross in right-to-left tags.
     */
    case leading
}

/**
 * The look of a `CYLTagListView`'s tags, section headers and fold controls. Gray bordered tags with a green selection
 * by default (`CYLMenuStyle()`); copy a preset (`tagCloud()`, `tagContainer()`, `gridStyle(itemsPerRow:)`) and change
 * what you need.
 */
@objc(CYLMenuStyle)
open class CYLMenuStyle: NSObject, NSCopying {

    private static let appTintColor = UIColor(red: 42 / 255, green: 185 / 255, blue: 160 / 255, alpha: 1)
    private static let defaultDeleteIndicatorTitle = "\u{00D7}"

    // MARK: Tag box and text, per state (CYLBadgeAppearance)

    /**
     * Normal tags. The appearance objects belong to the style: change their properties.
     */
    open private(set) var normalAppearance: CYLTagAppearance

    /**
     * Selected tags.
     */
    open private(set) var selectedAppearance: CYLTagAppearance

    /**
     * Disabled tags.
     */
    open private(set) var disabledAppearance: CYLTagAppearance

    /**
     * The background of a tag while a finger is on it (as android-tagview's layoutColorPress). `nil` (the default)
     * keeps the state's background.
     */
    open var highlightedBackgroundColor: UIColor?

    /**
     * The content insets of every state's appearance at once (as android-tagview's textPadding…); reading it gives the
     * normal appearance's. {5, 10, 5, 10} by default.
     */
    open var tagContentInsets: UIEdgeInsets {
        get {
            normalAppearance.contentInsets
        }
        set {
            for appearance in allAppearances {
                appearance.contentInsets = newValue
            }
        }
    }

    // MARK: Delete indicator (deletable tags)

    /**
     * Shown after the title of a deletable tag (`menuItemIsDeletable(at:)`, `CYLTag.isDeletable`); a tap on it deletes
     * the tag. Defaults to "×" (as android-tagview's deleteIcon).
     */
    open var deleteIndicatorTitle = CYLMenuStyle.defaultDeleteIndicatorTitle

    /**
     * Its color; `nil` (the default) uses the state's text color.
     */
    open var deleteIndicatorColor: UIColor?

    /**
     * Its font; `nil` (the default) uses the state's title font. Scaled for Dynamic Type as the title is.
     */
    open var deleteIndicatorFont: UIFont?

    /**
     * Draws the delete indicator as a cross of two lines this wide instead of `deleteIndicatorTitle` (AndroidTagView's
     * tag_cross_line_width); 0 (the default) draws the title.
     */
    open var deleteIndicatorLineWidth: CGFloat = 0

    /**
     * The width of the delete indicator's area (tag_cross_width); 0 (the default) fits the title, or the font's line
     * height for a drawn cross.
     */
    open var deleteIndicatorWidth: CGFloat = 0

    /**
     * Space between the area's edges and a drawn cross (tag_cross_area_padding). 0 by default.
     */
    open var deleteIndicatorPadding: CGFloat = 0

    /**
     * After the title (the default) or before the content.
     */
    open var deleteIndicatorPlacement: CYLTagDeleteIndicatorPlacement = .trailing

    // MARK: Touch ripple (AndroidTagView)

    /**
     * A circle that grows from the touch point while a tag is pressed (tag_ripple_color); `nil` (the default) for none.
     */
    open var rippleColor: UIColor?

    /**
     * Its opacity at the start, 0...1 (tag_ripple_alpha). 0.2 by default.
     */
    open var rippleAlpha: CGFloat = 0.2

    /**
     * How long it grows, in seconds (tag_ripple_duration). 1 by default.
     */
    open var rippleDuration: TimeInterval = 1

    // MARK: Titles

    /**
     * Titles longer than this many characters are cut and end with "..." (tag_max_length); 0 (the default) keeps them.
     */
    open var maximumTitleLength = 0

    /**
     * Shows each title's characters in reverse order (AndroidTagView's tag_support_letters_rlt). False by default.
     */
    open var reversesTitleCharacters = false

    // MARK: Rows and section headers

    /**
     * How the tags of a row line up: leading (the default), centered or trailing.
     */
    open var rowAlignment: CYLTagRowAlignment = .leading

    /**
     * A bar before each section title, as in a "| 热门搜索" header; `nil` (the default) for none.
     */
    open var headerIndicatorColor: UIColor?

    /**
     * The bar's size, {3, 16} by default.
     */
    open var headerIndicatorSize = CGSize(width: 3, height: 16)

    /**
     * Rounds the icon's corners (AndroidTagView's round avatars): half the icon's size or more makes it a circle. 0 by
     * default.
     */
    open var imageCornerRadius: CGFloat = 0

    // MARK: Title and icon (CYLFlatDesignTabBarItem)

    /**
     * Space between the icon and the title, 4 by default.
     */
    open var imageTitleSpacing: CGFloat = 4

    /**
     * Icon size. `.zero` uses the image's own size. 14 × 14 by default.
     */
    open var imageSize = CGSize(width: 14, height: 14)

    /**
     * Shrinks the icon from its slot without moving it, as `CYLFlatDesignTabBarItem.imageInsets`.
     */
    open var imageInsets: UIEdgeInsets = .zero

    /**
     * Moves the title from its computed position.
     */
    open var titlePositionAdjustment: UIOffset = .zero

    /**
     * Moves the icon from its computed position.
     */
    open var imagePositionAdjustment: UIOffset = .zero

    /**
     * The icon before (default) or after the title.
     */
    open var imagePlacement: CYLTagImagePlacement = .leading

    /**
     * For a tag with only an icon or only a title: true (the default) centers it; false keeps it where it would be with
     * both, the title after an empty icon slot, the icon at the leading margin (as
     * `CYLFlatDesignTabBarItem.layoutCentered = NO`).
     */
    open var layoutCentered = true

    /**
     * Where the icon and title sit together: `.center` (the default) centers them; `.leading` puts them at the leading
     * margin, without an empty icon slot before a title alone. A title too long for the tag is truncated with an
     * ellipsis, so its icon stays visible.
     */
    open var contentAlignment: CYLTagContentAlignment = .center

    /**
     * Size of animated icons (`menuAnimationURLForItem(at:)`). `.zero` (the default) uses `imageSize`.
     */
    open var animationSize: CGSize = .zero

    /**
     * Playback speed of animated icons, as `CYLTabBarController.tabBarItemAnimationSpeed`; 1 (the default) is the
     * file's own speed.
     */
    open var animationSpeed: CGFloat = 1

    /**
     * Scale the appearance fonts for Dynamic Type (capped at 2×). Defaults to true.
     */
    open var adjustsFontForContentSizeCategory = true

    /**
     * Minimum tag height; grows with the font for large text sizes. 30 by default.
     */
    open var itemHeight: CGFloat = 30

    /**
     * Grid layout: 0 (the default) lays the tags out one after another, each as wide as its title; a number above 0
     * gives every tag the same width, that many per row (the content width minus the spacing between them, divided
     * evenly), and truncates a longer title with an ellipsis ("…"), like a search app's suggestions, two per row.
     */
    open var numberOfItemsPerRow = 0

    // MARK: Layout

    /**
     * Space between tags in a row, 10 by default.
     */
    open var interitemSpacing: CGFloat = 10

    /**
     * Space between rows, 10 by default.
     */
    open var lineSpacing: CGFloat = 10

    /**
     * Insets of every section, {10, 16, 10, 16} by default.
     */
    open var sectionInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

    /**
     * The list's background, white by default.
     */
    open var backgroundColor = UIColor.white

    // MARK: Section headers

    /**
     * Minimum header height, 36 by default; it grows with the font.
     */
    open var headerHeight: CGFloat = 36

    /**
     * Header font, the system font of 14 points by default (scaled for Dynamic Type).
     */
    open var headerFont = UIFont.systemFont(ofSize: 14)

    /**
     * Header title color, gray by default.
     */
    open var headerTextColor = UIColor.gray

    /**
     * Space before the header's title and after its controls, 16 by default.
     */
    open var headerHorizontalInset: CGFloat = 16

    // MARK: Fold controls

    /**
     * The fold controls' color, gray by default (a control's own color wins).
     */
    open var foldControlColor = UIColor.gray

    /**
     * Defaults to the localized "More" from CYLClassifyMenuResources.bundle.
     */
    open var expandTitle = CYLMenuLocalizedString("CYLMenuExpand")

    /**
     * Footer chevron, pointing down while folded; it turns 180° when the section expands. `nil` uses the bundle's
     * chevron.
     */
    open var foldChevronImage: UIImage?

    /**
     * Defaults to the localized "Less" from CYLClassifyMenuResources.bundle.
     */
    open var collapseTitle = CYLMenuLocalizedString("CYLMenuCollapse")

    // MARK: The More button

    /**
     * The icon of the More button in a section header (`menuShowsMoreButton(inSection:)`). `nil` (the default) uses
     * the bundle's "cyl_more", three dots like the "ellipsis" icon of CYLTabBarController's More tab.
     */
    open var moreButtonImage: UIImage?

    /**
     * The color of the More button. Defaults to the secondary label color.
     */
    open var moreButtonColor = UIColor.secondaryLabel

    // MARK: - Initializers

    /**
     * Gray bordered tags, green selection: the style used when no style is set.
     */
    public required override init() {
        let hairline = 1 / max(1, UIScreen.main.scale)
        normalAppearance = CYLTagAppearance()
        normalAppearance.borderColor = UIColor(white: 0.82, alpha: 1)
        normalAppearance.borderWidth = hairline
        selectedAppearance = CYLTagAppearance()
        selectedAppearance.backgroundColor = Self.appTintColor
        selectedAppearance.textColor = .white
        selectedAppearance.borderColor = Self.appTintColor
        selectedAppearance.borderWidth = hairline
        disabledAppearance = CYLTagAppearance()
        disabledAppearance.textColor = UIColor(white: 0.7, alpha: 1)
        disabledAppearance.borderColor = UIColor(white: 0.88, alpha: 1)
        disabledAppearance.borderWidth = hairline
        super.init()
    }

    // MARK: - Presets

    /**
     * android-tagview's defaults (Constants): #00BFFF capsules with white 14 pt titles and no border, #88363636 while
     * pressed, 5 × 8 pt padding, 5 pt between tags and between rows, "×" for deletable tags.
     */
    open class func tagCloud() -> Self {
        let style = Self()
        let blue = UIColor(red: 0, green: 0xBF / 255, blue: 1, alpha: 1)
        for appearance in style.allAppearances {
            appearance.backgroundColor = blue
            appearance.textColor = .white
            appearance.borderWidth = 0
            // android-tagview's layoutBorderColor: a tag that sets only a border width gets a white border.
            appearance.borderColor = .white
            appearance.cornerRadius = 0
            appearance.font = UIFont.systemFont(ofSize: 14)
        }
        style.disabledAppearance.backgroundColor = blue.withAlphaComponent(0.4)
        style.highlightedBackgroundColor = UIColor(red: 0x36 / 255, green: 0x36 / 255, blue: 0x36 / 255, alpha: 0x88 / 255)
        style.tagContentInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
        style.interitemSpacing = 5
        style.lineSpacing = 5
        style.itemHeight = 0
        style.backgroundColor = .clear
        return style
    }

    /**
     * AndroidTagView's defaults: #33F44336 capsules with a 0.5 pt #88F44336 border and #666666 14 pt titles, #33FF7669
     * while selected, 10 × 8 pt padding, 5 pt between tags and rows, titles cut after 23 characters, and a 1 pt black
     * cross with 10 pt padding for deletable tags.
     */
    open class func tagContainer() -> Self {
        let style = Self()
        let red = UIColor(red: 0xF4 / 255, green: 0x43 / 255, blue: 0x36 / 255, alpha: 1)
        for appearance in style.allAppearances {
            appearance.backgroundColor = red.withAlphaComponent(0x33 / 255)
            appearance.borderColor = red.withAlphaComponent(0x88 / 255)
            appearance.borderWidth = 0.5
            appearance.textColor = UIColor(white: 0x66 / 255, alpha: 1)
            appearance.cornerRadius = 15
            appearance.font = UIFont.systemFont(ofSize: 14)
        }
        style.selectedAppearance.backgroundColor = UIColor(red: 1, green: 0x76 / 255, blue: 0x69 / 255, alpha: 0x33 / 255)
        style.disabledAppearance.textColor = UIColor(white: 0x66 / 255, alpha: 0.5)
        style.tagContentInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        style.interitemSpacing = 5
        style.lineSpacing = 5
        style.itemHeight = 0
        style.maximumTitleLength = 23
        style.deleteIndicatorLineWidth = 1
        style.deleteIndicatorPadding = 10
        style.deleteIndicatorColor = .black
        style.rippleColor = UIColor(white: 0xEE / 255, alpha: 1)
        style.rippleAlpha = 128 / 255
        style.backgroundColor = .clear
        return style
    }

    /**
     * A grid of plain titles, like a search app's suggestions: `itemsPerRow` items per row (at least 1), each as wide
     * as the others, no background and no border, the content at the leading edge in the body size: the title, then its
     * icon if it has one (such as a "热" icon), the title truncated with an ellipsis.
     */
    open class func gridStyle(itemsPerRow: Int) -> Self {
        let style = Self()
        style.numberOfItemsPerRow = max(1, itemsPerRow)
        let font = UIFont.systemFont(ofSize: 17)
        for appearance in style.allAppearances {
            appearance.backgroundColor = .clear
            appearance.borderWidth = 0
            appearance.borderColor = nil
            appearance.margin = 0
            appearance.font = font
        }
        style.normalAppearance.textColor = .label
        style.selectedAppearance.textColor = .label
        style.disabledAppearance.textColor = .tertiaryLabel
        // The title at the leading edge, then its icon (such as "热"); no empty icon slot before a title alone.
        style.contentAlignment = .leading
        style.imagePlacement = .trailing
        style.imageSize = CGSize(width: 18, height: 18)
        style.imageTitleSpacing = 6
        style.itemHeight = 32
        style.interitemSpacing = 24
        style.lineSpacing = 18
        return style
    }

    // MARK: - Appearances

    /**
     * The appearance for `.normal`, `.selected` or `.disabled` (disabled wins over selected); others give normal.
     */
    open func appearance(for state: UIControl.State) -> CYLTagAppearance {
        if state.contains(.disabled) {
            return disabledAppearance
        }
        if state.contains(.selected) {
            return selectedAppearance
        }
        return normalAppearance
    }

    /**
     * Like `UITabBarItem.setTitleTextAttributes(_:for:)`: `.font` and `.foregroundColor` set the state's appearance
     * font and text color (their defaults when missing).
     */
    open func setTitleTextAttributes(_ attributes: [NSAttributedString.Key: Any]?, for state: UIControl.State) {
        let appearance = appearance(for: state)
        appearance.font = attributes?[.font] as? UIFont ?? CYLTagAppearance.defaultFont
        appearance.textColor = attributes?[.foregroundColor] as? UIColor ?? CYLTagAppearance.defaultTextColor
    }

    /**
     * The state's font and text color as text attributes.
     */
    open func titleTextAttributes(for state: UIControl.State) -> [NSAttributedString.Key: Any] {
        let appearance = appearance(for: state)
        return [.font: appearance.font, .foregroundColor: appearance.textColor]
    }

    /**
     * Tint of template icons in a state (like `UITabBarItemStateAppearance.iconColor`); `nil` uses the state's
     * text color.
     */
    open func setIconColor(_ iconColor: UIColor?, for state: UIControl.State) {
        appearance(for: state).iconColor = iconColor
    }

    /**
     * The effective icon tint for a state.
     */
    open func iconColor(for state: UIControl.State) -> UIColor {
        let appearance = appearance(for: state)
        return appearance.iconColor ?? appearance.textColor
    }

    /**
     * The title as a tag shows it: cut to `maximumTitleLength`, reversed when `reversesTitleCharacters`.
     */
    open func displayedTitle(forTitle title: String?) -> String {
        var text = title ?? ""
        if maximumTitleLength > 0 && (text as NSString).length > maximumTitleLength {
            let range = (text as NSString).rangeOfComposedCharacterSequences(for: NSRange(location: 0, length: maximumTitleLength))
            text = (text as NSString).substring(with: range) + "..."
        }
        if reversesTitleCharacters && text.count > 1 {
            text = String(text.reversed())
        }
        return text
    }

    // MARK: - Fonts

    /**
     * The title font of a state for the given traits: bold for the Bold Text setting, scaled for Dynamic Type when
     * `adjustsFontForContentSizeCategory` is true.
     */
    open func titleFont(for state: UIControl.State, traitCollection: UITraitCollection?) -> UIFont {
        scaledFont(appearance(for: state).font, traitCollection: traitCollection)
    }

    /**
     * The delete indicator's font for the given traits (`deleteIndicatorFont`, or the state's title font).
     */
    open func deleteIndicatorFont(for state: UIControl.State, traitCollection: UITraitCollection?) -> UIFont {
        guard let deleteIndicatorFont else {
            return titleFont(for: state, traitCollection: traitCollection)
        }
        return scaledFont(deleteIndicatorFont, traitCollection: traitCollection)
    }

    /**
     * Header font for the given traits, applying Dynamic Type when enabled.
     */
    open func headerFont(for traitCollection: UITraitCollection?) -> UIFont {
        scaledFont(headerFont, traitCollection: traitCollection)
    }

    // MARK: - NSCopying

    /**
     * An independent copy, with copies of the appearances.
     */
    open func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init()
        copy.normalAppearance = normalAppearance.copy()
        copy.selectedAppearance = selectedAppearance.copy()
        copy.disabledAppearance = disabledAppearance.copy()
        copy.imageTitleSpacing = imageTitleSpacing
        copy.imageSize = imageSize
        copy.imageInsets = imageInsets
        copy.titlePositionAdjustment = titlePositionAdjustment
        copy.imagePositionAdjustment = imagePositionAdjustment
        copy.imagePlacement = imagePlacement
        copy.layoutCentered = layoutCentered
        copy.animationSize = animationSize
        copy.animationSpeed = animationSpeed
        copy.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
        copy.itemHeight = itemHeight
        copy.interitemSpacing = interitemSpacing
        copy.lineSpacing = lineSpacing
        copy.sectionInsets = sectionInsets
        copy.backgroundColor = backgroundColor
        copy.headerHeight = headerHeight
        copy.headerFont = headerFont
        copy.headerTextColor = headerTextColor
        copy.headerHorizontalInset = headerHorizontalInset
        copy.foldControlColor = foldControlColor
        copy.foldChevronImage = foldChevronImage
        copy.expandTitle = expandTitle
        copy.collapseTitle = collapseTitle
        copy.numberOfItemsPerRow = numberOfItemsPerRow
        copy.contentAlignment = contentAlignment
        copy.moreButtonImage = moreButtonImage
        copy.moreButtonColor = moreButtonColor
        copy.highlightedBackgroundColor = highlightedBackgroundColor
        copy.deleteIndicatorTitle = deleteIndicatorTitle
        copy.deleteIndicatorColor = deleteIndicatorColor
        copy.deleteIndicatorFont = deleteIndicatorFont
        copy.deleteIndicatorLineWidth = deleteIndicatorLineWidth
        copy.deleteIndicatorWidth = deleteIndicatorWidth
        copy.deleteIndicatorPadding = deleteIndicatorPadding
        copy.deleteIndicatorPlacement = deleteIndicatorPlacement
        copy.rippleColor = rippleColor
        copy.rippleAlpha = rippleAlpha
        copy.rippleDuration = rippleDuration
        copy.maximumTitleLength = maximumTitleLength
        copy.reversesTitleCharacters = reversesTitleCharacters
        copy.rowAlignment = rowAlignment
        copy.headerIndicatorColor = headerIndicatorColor
        copy.headerIndicatorSize = headerIndicatorSize
        copy.imageCornerRadius = imageCornerRadius
        return copy
    }

    // MARK: - Private

    private var allAppearances: [CYLTagAppearance] {
        [normalAppearance, selectedAppearance, disabledAppearance]
    }

    private func scaledFont(_ font: UIFont, traitCollection: UITraitCollection?) -> UIFont {
        var font = font
        let effective = traitCollection ?? UITraitCollection.current
        if effective.legibilityWeight == .bold,
           let bold = font.fontDescriptor.withSymbolicTraits(font.fontDescriptor.symbolicTraits.union(.traitBold)) {
            // Bold Text accessibility setting.
            font = UIFont(descriptor: bold, size: font.pointSize)
        }
        guard adjustsFontForContentSizeCategory else {
            return font
        }
        return UIFontMetrics.default.scaledFont(for: font, maximumPointSize: font.pointSize * CYLTagMetrics.maximumFontScale,
                                                compatibleWith: traitCollection)
    }
}

extension CYLMenuStyle {

    /**
     * A typed copy (`NSCopying` returns `Any`).
     */
    func cylCopy() -> CYLMenuStyle {
        guard let copy = copy() as? CYLMenuStyle else {
            preconditionFailure("CYLMenuStyle copies itself")
        }
        return copy
    }
}
