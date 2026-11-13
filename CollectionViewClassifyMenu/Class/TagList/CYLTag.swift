//
//  CYLTag.swift
//  CollectionViewClassifyMenu
//
//  One tag as a value the host creates and adds (android-tagview's Tag), and CYLTagDataSource, the data source that
//  holds such tags. CYLTagListView's tag methods (addTag(_:), addTags(withTitles:), removeTag(at:)…) use one:
//
//      let tagListView = CYLTagListView()
//      tagListView.lineSpacing = 5
//      tagListView.interitemSpacing = 3
//      tagListView.addTags(withTitles: ["Asia", "Europe", "Africa"])
//      let tag = CYLTag(title: "Tag Text")
//      tag.textColor = .white
//      tag.backgroundColor = UIColor(white: 0.87, alpha: 1)
//      tag.cornerRadius = 20
//      tag.isDeletable = true
//      tagListView.addTag(tag)
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * One tag of a `CYLTagListView`: its title, icons, state and, optionally, its own look over the list's style. The
 * look properties that are `nil` use the list's (or `style`'s) value. A final class: copy it with `copy()`.
 */
public final class CYLTag {

    /**
     * The host's identifier (android-tagview's Tag.id), 0 by default.
     */
    public var identifier: Int

    /**
     * The title.
     */
    public var title: String

    /**
     * The icon, as the data source's `menuImageForItem(at:)`.
     */
    public var image: UIImage?

    /**
     * The icon while selected, as `menuSelectedImageForItem(at:)`.
     */
    public var selectedImage: UIImage?

    /**
     * An animated icon (Lottie .json, .pag, .riv, .gif), as `menuAnimationURLForItem(at:)`.
     */
    public var animationURL: URL?

    /**
     * True by default; a disabled tag is dimmed and ignores taps.
     */
    public var isEnabled = true

    /**
     * Shows a delete indicator ("×") after the title; a tap on it removes the tag (android-tagview's isDeletable).
     */
    public var isDeletable = false

    /**
     * A round badge before the title with this text, e.g. "热" or "神" in a search app's hot list; drawn in
     * `badgeColor` (the title color by default) with white text, when the tag has no `image`.
     */
    public var badgeText: String?

    /**
     * The badge's color; `nil` for the title color.
     */
    public var badgeColor: UIColor?

    /**
     * What VoiceOver reads for the badge, after the title (the tag's value), when the badge's glyph alone does not say
     * it, such as "热门" for "热". `nil`: `badgeText`.
     */
    public var badgeAccessibilityLabel: String?

    /**
     * Anything the host wants to keep with the tag.
     */
    public var userInfo: Any?

    // MARK: Look (over the list's style)

    /**
     * The style this tag starts from instead of the list's; the properties below apply over it. Setting copies the
     * style. `nil` by default.
     */
    public var style: CYLMenuStyle? {
        get {
            styleStorage
        }
        set {
            styleStorage = newValue?.cylCopy()
        }
    }

    /**
     * The title color (android-tagview's tagTextColor); `nil` for the style's.
     */
    public var textColor: UIColor?

    /**
     * The title font; `nil` for a system font of `textSize`, or the style's.
     */
    public var font: UIFont?

    /**
     * The title's point size (android-tagview's tagTextSize), a system font; `nil` for the style's. A larger text makes
     * the tag taller.
     */
    public var textSize: CGFloat?

    /**
     * The background (android-tagview's layoutColor); `nil` for the style's.
     */
    public var backgroundColor: UIColor?

    /**
     * The background while pressed (android-tagview's layoutColorPress); `nil` for the style's.
     */
    public var highlightedBackgroundColor: UIColor?

    /**
     * The background while selected (AndroidTagView's tagSelectedBackgroundColor); `nil` for the style's.
     */
    public var selectedBackgroundColor: UIColor?

    /**
     * Drawn behind the title, stretched (android-tagview's background); `nil` for none.
     */
    public var backgroundImage: UIImage?

    /**
     * The corner radius (android-tagview's radius); 0 is a capsule, `nil` the style's.
     */
    public var cornerRadius: CGFloat?

    /**
     * The border width (android-tagview's layoutBorderSize); `nil` for the style's.
     */
    public var borderWidth: CGFloat?

    /**
     * The border color (android-tagview's layoutBorderColor); `nil` for the style's.
     */
    public var borderColor: UIColor?

    /**
     * The delete indicator's text (android-tagview's deleteIcon); `nil` for the style's ("×").
     */
    public var deleteIndicatorTitle: String?

    /**
     * The delete indicator's color (deleteIndicatorColor); `nil` for the style's (the title color).
     */
    public var deleteIndicatorColor: UIColor?

    /**
     * The delete indicator's point size (deleteIndicatorSize); `nil` for the style's (the title font).
     */
    public var deleteIndicatorSize: CGFloat?

    private var styleStorage: CYLMenuStyle?

    // MARK: - Initializers

    /**
     * A tag with the list's look, an optional identifier of the host's (android-tagview's Tag.id) and an optional
     * background color.
     */
    public init(identifier: Int = 0, title: String, backgroundColor: UIColor? = nil) {
        self.identifier = identifier
        self.title = title
        self.backgroundColor = backgroundColor
    }

    /**
     * With its background color as "#RGB", "#RRGGBB", "#RRGGBBAA" or a UIColor name ("systemBlue").
     */
    public convenience init(identifier: Int = 0, title: String, backgroundColorHex: String?) {
        self.init(identifier: identifier, title: title,
                  backgroundColor: backgroundColorHex.flatMap { UIColor.cylMenuColor(from: $0) })
    }

    // MARK: - API

    /**
     * Sets `backgroundColor`, `borderColor`, `textColor` and `selectedBackgroundColor` at once (AndroidTagView's color
     * array), or reads them.
     */
    public var colors: CYLTagColors {
        get {
            CYLTagColors(backgroundColor: backgroundColor, borderColor: borderColor, textColor: textColor,
                         selectedBackgroundColor: selectedBackgroundColor)
        }
        set {
            backgroundColor = newValue.backgroundColor
            borderColor = newValue.borderColor
            textColor = newValue.textColor
            selectedBackgroundColor = newValue.selectedBackgroundColor
        }
    }

    /**
     * Whether any look property is set: false draws the tag with the base style itself.
     */
    public var hasCustomStyle: Bool {
        styleStorage != nil || textColor != nil || font != nil || Self.validValue(textSize) != nil
            || backgroundColor != nil || highlightedBackgroundColor != nil || selectedBackgroundColor != nil
            || backgroundImage != nil || Self.validValue(cornerRadius) != nil || Self.validValue(borderWidth) != nil
            || borderColor != nil || deleteIndicatorTitle != nil || deleteIndicatorColor != nil
            || Self.validValue(deleteIndicatorSize) != nil
    }

    /**
     * A copy of `style` (or of `baseStyle` when it is `nil`) with this tag's look applied: the colors to the normal
     * state, the font, corner radius and border to every state.
     */
    public func style(basedOn baseStyle: CYLMenuStyle) -> CYLMenuStyle {
        let style = (styleStorage ?? baseStyle).cylCopy()
        let normal = style.normalAppearance
        let cornerRadius = Self.validValue(cornerRadius)
        let borderWidth = Self.validValue(borderWidth)
        if let textColor {
            normal.textColor = textColor
        }
        if let backgroundColor {
            normal.backgroundColor = backgroundColor
        }
        if let backgroundImage {
            normal.backgroundImage = backgroundImage
        }
        if let borderColor {
            normal.borderColor = borderColor
            if borderWidth == nil && normal.borderWidth <= 0 {
                normal.borderWidth = 1
            }
        }
        let font = self.font ?? Self.validValue(textSize).flatMap { $0 > 0 ? UIFont.systemFont(ofSize: $0) : nil }
        for appearance in [normal, style.selectedAppearance, style.disabledAppearance] {
            if let font {
                appearance.font = font
            }
            if let cornerRadius {
                appearance.cornerRadius = cornerRadius
            }
            if let borderWidth {
                appearance.borderWidth = borderWidth
            }
        }
        if let highlightedBackgroundColor {
            style.highlightedBackgroundColor = highlightedBackgroundColor
        }
        if let selectedBackgroundColor {
            style.selectedAppearance.backgroundColor = selectedBackgroundColor
        }
        if let deleteIndicatorTitle {
            style.deleteIndicatorTitle = deleteIndicatorTitle
        }
        if let deleteIndicatorColor {
            style.deleteIndicatorColor = deleteIndicatorColor
        }
        if let size = Self.validValue(deleteIndicatorSize), size > 0 {
            style.deleteIndicatorFont = UIFont.systemFont(ofSize: size)
        }
        return style
    }

    /**
     * An independent copy (the user info and the images are shared).
     */
    public func copy() -> CYLTag {
        let copy = CYLTag(identifier: identifier, title: title, backgroundColor: backgroundColor)
        copy.image = image
        copy.selectedImage = selectedImage
        copy.animationURL = animationURL
        copy.isEnabled = isEnabled
        copy.isDeletable = isDeletable
        copy.userInfo = userInfo
        copy.styleStorage = styleStorage
        copy.textColor = textColor
        copy.font = font
        copy.textSize = textSize
        copy.highlightedBackgroundColor = highlightedBackgroundColor
        copy.selectedBackgroundColor = selectedBackgroundColor
        copy.badgeText = badgeText
        copy.badgeColor = badgeColor
        copy.badgeAccessibilityLabel = badgeAccessibilityLabel
        copy.backgroundImage = backgroundImage
        copy.cornerRadius = cornerRadius
        copy.borderWidth = borderWidth
        copy.borderColor = borderColor
        copy.deleteIndicatorTitle = deleteIndicatorTitle
        copy.deleteIndicatorColor = deleteIndicatorColor
        copy.deleteIndicatorSize = deleteIndicatorSize
        return copy
    }

    /**
     * A round badge image: `text` in white on a `color` circle `diameter` points wide (rendered as original).
     */
    public static func badgeImage(text: String, color: UIColor, diameter: CGFloat) -> UIImage {
        let side = max(1, diameter)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side))
        let image = renderer.image { _ in
            color.setFill()
            UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: side, height: side)).fill()
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: side * 0.6),
                                                             .foregroundColor: UIColor.white]
            let size = (text as NSString).size(withAttributes: attributes)
            (text as NSString).draw(at: CGPoint(x: (side - size.width) / 2, y: (side - size.height) / 2),
                                    withAttributes: attributes)
        }.withRenderingMode(.alwaysOriginal)
        image.accessibilityLabel = text
        return image
    }

    /**
     * A look value that is set: finite and not negative.
     */
    private static func validValue(_ value: CGFloat?) -> CGFloat? {
        guard let value, value.isFinite, value >= 0 else {
            return nil
        }
        return value
    }
}

extension CYLTag: CustomStringConvertible {

    public var description: String {
        "<CYLTag: identifier = \(identifier); title = \(title)>"
    }
}

/**
 * A data source of `CYLTag` objects in one section. `CYLTagListView`'s tag methods create and use one
 * (`tagDataSource`); it can also be given to any list as its `menuDataSource` (keep a strong reference to it).
 */
open class CYLTagDataSource: NSObject, CYLMenuDataSource {

    /**
     * The tags, in order. Setting them builds every tag's style again.
     */
    open var tags: [CYLTag] {
        get {
            storedTags
        }
        set {
            storedTags = newValue
            invalidateStyles()
        }
    }

    /**
     * The title of the one section, shown when the list shows section headers ("热门搜索"); empty by default.
     */
    open var sectionTitle: String?

    /**
     * The style tags with their own look start from (`CYLTagListView` keeps it equal to its style). Setting copies the
     * style.
     */
    open var baseStyle: CYLMenuStyle {
        get {
            baseStyleStorage
        }
        set {
            baseStyleStorage = newValue.cylCopy()
            invalidateStyles()
        }
    }

    private var storedTags: [CYLTag]
    private var baseStyleStorage = CYLMenuStyle()
    /**
     * Each tag's style built from `baseStyle`, so that the same object is returned until something changes.
     */
    private var styles: [ObjectIdentifier: CYLMenuStyle] = [:]

    /**
     * A data source with these tags.
     */
    public init(tags: [CYLTag] = []) {
        storedTags = tags
        super.init()
    }

    // MARK: - Tags

    /**
     * Adds a tag at the end.
     */
    open func addTag(_ tag: CYLTag) {
        storedTags.append(tag)
    }

    /**
     * Adds tags at the end.
     */
    open func addTags(_ tags: [CYLTag]) {
        storedTags.append(contentsOf: tags)
    }

    /**
     * Inserts a tag; an index past the end adds it at the end.
     */
    open func insertTag(_ tag: CYLTag, at index: Int) {
        storedTags.insert(tag, at: min(max(0, index), storedTags.count))
    }

    /**
     * Removes a tag; out-of-range indexes are ignored.
     */
    open func removeTag(at index: Int) {
        guard storedTags.indices.contains(index) else {
            return
        }
        styles[ObjectIdentifier(storedTags[index])] = nil
        storedTags.remove(at: index)
    }

    /**
     * Removes every tag.
     */
    open func removeAllTags() {
        storedTags.removeAll()
        invalidateStyles()
    }

    /**
     * Moves a tag; out-of-range indexes are ignored.
     */
    open func moveTag(at fromIndex: Int, to toIndex: Int) {
        guard storedTags.indices.contains(fromIndex), storedTags.indices.contains(toIndex), fromIndex != toIndex else {
            return
        }
        storedTags.insert(storedTags.remove(at: fromIndex), at: toIndex)
    }

    /**
     * Builds every tag's style again; call it after changing a tag's look (`CYLTagListView.reloadMenuData()` does).
     */
    open func invalidateStyles() {
        styles.removeAll()
    }

    // MARK: - CYLMenuDataSource

    open func numberOfSectionsInMenu() -> Int {
        1
    }

    open func menuNumberOfItems(inSection section: Int) -> Int {
        section == 0 ? storedTags.count : 0
    }

    open func menuTitle(forSection section: Int) -> String {
        sectionTitle ?? ""
    }

    open func menuTitleForItem(at indexPath: IndexPath) -> String {
        tag(at: indexPath)?.title ?? ""
    }

    open func menuImageForItem(at indexPath: IndexPath) -> UIImage? {
        guard let tag = tag(at: indexPath) else {
            return nil
        }
        if tag.image == nil, let text = tag.badgeText, !text.isEmpty {
            let side = max(baseStyleStorage.imageSize.width, baseStyleStorage.imageSize.height)
            let image = CYLTag.badgeImage(text: text, color: tag.badgeColor ?? tag.textColor ?? .systemBlue,
                                          diameter: side > 0 ? side : 16)
            if let label = tag.badgeAccessibilityLabel, !label.isEmpty {
                image.accessibilityLabel = label
            }
            tag.image = image
        }
        return tag.image
    }

    open func menuSelectedImageForItem(at indexPath: IndexPath) -> UIImage? {
        tag(at: indexPath)?.selectedImage
    }

    open func menuAnimationURLForItem(at indexPath: IndexPath) -> URL? {
        tag(at: indexPath)?.animationURL
    }

    open func menuItemIsEnabled(at indexPath: IndexPath) -> Bool {
        tag(at: indexPath)?.isEnabled ?? true
    }

    open func menuItemIsDeletable(at indexPath: IndexPath) -> Bool {
        tag(at: indexPath)?.isDeletable ?? false
    }

    open func menuRemoveItem(at indexPath: IndexPath) {
        if tag(at: indexPath) != nil {
            removeTag(at: indexPath.item)
        }
    }

    open func menuMoveItem(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == 0 && destinationIndexPath.section == 0 {
            moveTag(at: sourceIndexPath.item, to: destinationIndexPath.item)
        }
    }

    open func menuStyleForItem(at indexPath: IndexPath) -> CYLMenuStyle? {
        guard let tag = tag(at: indexPath), tag.hasCustomStyle else {
            return nil
        }
        if let style = styles[ObjectIdentifier(tag)] {
            return style
        }
        let style = tag.style(basedOn: baseStyleStorage)
        styles[ObjectIdentifier(tag)] = style
        return style
    }

    // MARK: - Private

    private func tag(at indexPath: IndexPath) -> CYLTag? {
        indexPath.section == 0 && storedTags.indices.contains(indexPath.item) ? storedTags[indexPath.item] : nil
    }
}

// MARK: - Copies of the Objective-C models

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

extension CYLMenuFoldControl {

    /**
     * A typed copy (`NSCopying` returns `Any`).
     */
    func cylCopy() -> CYLMenuFoldControl {
        guard let copy = copy() as? CYLMenuFoldControl else {
            preconditionFailure("CYLMenuFoldControl copies itself")
        }
        return copy
    }
}
