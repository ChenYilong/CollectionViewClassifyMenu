//
//  CYLIndexPathButton.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * A button that knows the item it shows (`section`, `row`) and places its image and title with a spacing and a
 * leading inset instead of the deprecated edge insets.
 */
@objc(CYLIndexPathButton)
open class CYLIndexPathButton: UIButton {

    /**
     * The section of the item the button shows.
     */
    public var section = 0

    /**
     * The row (item) of the item the button shows.
     */
    public var row = 0

    /**
     * Space between the image and the title when both are shown; 0 by default. (Objective-C name kept for the core's
     * tests.)
     */
    @objc(cyl_imageTitleSpacing)
    open var imageTitleSpacing: CGFloat = 0 {
        didSet {
            if imageTitleSpacing != oldValue {
                setNeedsLayout()
            }
        }
    }

    /**
     * Extra leading space before the title; 0 by default. (Objective-C name kept for the core's tests.)
     */
    @objc(cyl_titleLeadingInset)
    open var titleLeadingInset: CGFloat = 0 {
        didSet {
            if titleLeadingInset != oldValue {
                setNeedsLayout()
            }
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        let hasTitle = currentTitle?.isEmpty == false
        var titleOffset = titleLeadingInset
        if imageTitleSpacing > 0, currentImage != nil, hasTitle, let imageView {
            imageView.frame.origin.x -= imageTitleSpacing / 2
            titleOffset += imageTitleSpacing / 2
        }
        if titleOffset != 0, hasTitle, let titleLabel {
            var titleFrame = titleLabel.frame
            titleFrame.origin.x += titleOffset
            titleFrame.size.width = max(0, min(titleFrame.width, bounds.width - titleFrame.minX))
            titleLabel.frame = titleFrame
        }
    }
}
