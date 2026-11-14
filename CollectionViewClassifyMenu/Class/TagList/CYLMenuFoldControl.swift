//
//  CYLMenuFoldControl.swift
//  CollectionViewClassifyMenu
//
//  The fold control of CYLTagListView ("更多 ⌄"), given when the view is created: where it is (below the section as in
//  a shopping app's review filter, in the section header as in the original classify menu, or as the last tag) and
//  what it shows (icon and title, title only, icon only). Expanded, a control with an icon keeps only the icon, turned
//  180°; a title-only control shows its collapse title. It is drawn by CYLTagFoldButton, a borderless CYLTagButton.
//
//      let filter = CYLTagListView(foldControl: CYLMenuFoldControl(position: .footer, content: .icon))
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md); the positions were renamed
//  (docs/component-architecture.md, "rename the fold control positions").
//

import UIKit

/**
 * Where the fold control of a foldable section is: named after the part of the collection view that holds it.
 */
@objc public enum CYLMenuFoldControlPosition: Int {
    /**
     * No fold control: every row is shown.
     */
    case none = 0
    /**
     * Centered in the section's footer, below the tags, like a shopping app's review filter.
     */
    case footer
    /**
     * At the trailing edge of the section header, like the original classify menu.
     */
    case headerTrailing
    /**
     * At the leading edge of the section header, before the section title.
     */
    case headerLeading
    /**
     * The last item of the tags, like a search app's recent searches: folded, it is the last visible item (the hidden
     * items make room for it on the last visible row); expanded, it follows the last item. A tap on it expands or
     * collapses the section. With `.icon` content it is a circle with the bundle's chevron, outlined like the tags
     * (`CYLTagFoldCell`).
     */
    case tail
}

/**
 * What the fold control shows while the section is collapsed.
 */
@objc public enum CYLMenuFoldControlContent: Int {
    /**
     * "更多 ⌄"; expanded, only the icon, turned.
     */
    case iconAndTitle = 0
    /**
     * "更多"; expanded, the collapse title ("收起").
     */
    case title
    /**
     * "⌄"; expanded, the same icon, turned.
     */
    case icon
}

/**
 * The fold control of a `CYLTagListView`: its position, content, titles, icon, color and font.
 */
@objc(CYLMenuFoldControl)
open class CYLMenuFoldControl: NSObject, NSCopying {

    /**
     * Where the control is.
     */
    open var position: CYLMenuFoldControlPosition

    /**
     * What the control shows while the section is collapsed.
     */
    open var content: CYLMenuFoldControlContent

    /**
     * Shown while collapsed (with a title). Default: the localized "更多" (`CYLMenuExpand`).
     */
    open var title: String {
        get {
            customTitle ?? CYLMenuLocalizedString("CYLMenuExpand")
        }
        set {
            customTitle = newValue
        }
    }

    /**
     * Shown while expanded by a title-only control. Default: the localized "收起" (`CYLMenuCollapse`).
     */
    open var collapseTitle: String {
        get {
            customCollapseTitle ?? CYLMenuLocalizedString("CYLMenuCollapse")
        }
        set {
            customCollapseTitle = newValue
        }
    }

    /**
     * The icon, pointing down while collapsed. Default: the core's chevron (`cyl_fold_chevron`), drawn in `color`.
     */
    open var image: UIImage {
        get {
            customImage ?? CYLMenuResources.image(named: "cyl_fold_chevron") ?? UIImage(systemName: "chevron.down") ?? UIImage()
        }
        set {
            customImage = newValue
        }
    }

    /**
     * True while `image` is the default chevron (no image was set).
     */
    open var usesDefaultImage: Bool {
        customImage == nil
    }

    /**
     * Title and icon color. `nil` (the default) uses `CYLMenuStyle.foldControlColor`.
     */
    open var color: UIColor?

    /**
     * `nil` (the default): the footnote text style, scaled with Dynamic Type.
     */
    open var font: UIFont?

    /**
     * The icon turns 180° when expanded. True by default.
     */
    open var rotatesImageWhenExpanded = true

    private var customTitle: String?
    private var customCollapseTitle: String?
    private var customImage: UIImage?

    // MARK: - Initializers

    /**
     * A control at this position showing this content; the default is no fold control.
     */
    @objc(initWithPosition:content:)
    public required init(position: CYLMenuFoldControlPosition = .none, content: CYLMenuFoldControlContent = .icon) {
        self.position = position
        self.content = content
        super.init()
    }

    // MARK: - API

    /**
     * Whether the control shows its icon in the expanded or collapsed state.
     */
    open func showsImage(whenExpanded expanded: Bool) -> Bool {
        content != .title
    }

    /**
     * Whether the control shows its title in the expanded or collapsed state.
     */
    open func showsTitle(whenExpanded expanded: Bool) -> Bool {
        switch content {
        case .iconAndTitle:
            return !expanded
        case .title:
            return true
        case .icon:
            return false
        }
    }

    /**
     * The title shown in that state, or `nil`.
     */
    open func title(whenExpanded expanded: Bool) -> String? {
        guard showsTitle(whenExpanded: expanded) else {
            return nil
        }
        return expanded ? collapseTitle : title
    }

    /**
     * An independent copy (the image and colors are shared).
     */
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init(position: position, content: content)
        copy.customTitle = customTitle
        copy.customCollapseTitle = customCollapseTitle
        copy.customImage = customImage
        copy.color = color
        copy.font = font
        copy.rotatesImageWhenExpanded = rotatesImageWhenExpanded
        return copy
    }

    // MARK: - Equality

    open override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CYLMenuFoldControl else {
            return false
        }
        return other.position == position && other.content == content && other.title == title
            && other.collapseTitle == collapseTitle && other.image === image && other.color == color
            && other.font == font && other.rotatesImageWhenExpanded == rotatesImageWhenExpanded
    }

    open override var hash: Int {
        position.rawValue * 31 + content.rawValue
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
