//
//  CYLIndexPathButton.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md). A CYLTagButton since 2026-11-17, so the
//  classify menu's and the multiple filter's tags draw their icon, title and animated icon with the same component as
//  every other tag (docs/issue-progress.md, "every icon + title component is CYLTagButton").
//

import UIKit

/**
 * A tag that knows the item it shows (`section`, `row`): a `CYLTagButton`, drawn from its `style` (for example
 * `CYLMenuStyle.classifyMenuTag()` or `CYLMenuStyle.filterTag()`), with `title`, `image` and `animationURL`.
 */
@objc(CYLIndexPathButton)
open class CYLIndexPathButton: CYLTagButton {

    /**
     * The section of the item the button shows.
     */
    @objc public var section = 0

    /**
     * The row (item) of the item the button shows.
     */
    @objc public var row = 0

    public override init(frame: CGRect) {
        super.init(frame: frame)
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    /**
     * The title as shown, unless a label was set.
     */
    open override var accessibilityLabel: String? {
        get {
            super.accessibilityLabel ?? style.displayedTitle(forTitle: title)
        }
        set {
            super.accessibilityLabel = newValue
        }
    }
}
