//
//  CYLTagFoldCell.swift
//  CollectionViewClassifyMenu
//
//  The inline fold control of CYLTagListView (CYLMenuFoldControlPosition.inline): a cell among the tags, after the
//  last visible one, drawn like a tag.
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * A collection view cell that shows a fold control like a tag (`CYLTagFoldButton`); the cell is the accessibility
 * element (identifier `CYLTagListFoldControl`), a button whose label the list sets.
 */
open class CYLTagFoldCell: UICollectionViewCell {

    /**
     * The control drawn in the cell; the collection view handles its taps.
     */
    @objc public let foldButton = CYLTagFoldButton(frame: .zero)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        foldButton.frame = contentView.bounds
        foldButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // The collection view handles taps; the cell is the accessibility element.
        foldButton.isUserInteractionEnabled = false
        foldButton.isAccessibilityElement = false
        contentView.addSubview(foldButton)
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityIdentifier = CYLTagListAccessibilityIdentifier.foldControl
    }

    /**
     * Shows `foldControl` for the expanded or collapsed state, drawn like the tags of `itemStyle`.
     */
    open func configure(foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: Bool, animated: Bool) {
        foldButton.applyInlineFoldControl(foldControl, itemStyle: itemStyle, expanded: expanded, animated: animated)
    }
}
