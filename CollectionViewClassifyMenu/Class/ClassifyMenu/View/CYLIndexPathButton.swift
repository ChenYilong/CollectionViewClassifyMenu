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

    /**
     * Where UIButton puts the image: moved half of `imageTitleSpacing` to the leading side when the button shows an
     * image and a title. UIButton asks for the rect on every layout pass and uses the answer as it is, so the move is
     * applied once however often the button lays out (moving the frames after `layoutSubviews()` added up: the gap was
     * twice the spacing after the second pass).
     */
    open override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = super.imageRect(forContentRect: contentRect)
        if showsImageAndTitleWithSpacing {
            rect.origin.x -= imageTitleSpacing / 2
        }
        return rect
    }

    /**
     * Where UIButton puts the title: moved half of `imageTitleSpacing` to the trailing side next to an image, and by
     * `titleLeadingInset`; never past the button's trailing edge.
     */
    open override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = super.titleRect(forContentRect: contentRect)
        var offset = titleLeadingInset
        if showsImageAndTitleWithSpacing {
            offset += imageTitleSpacing / 2
        }
        if offset != 0, currentTitle?.isEmpty == false {
            rect.origin.x += offset
            rect.size.width = max(0, min(rect.width, bounds.width - rect.minX))
        }
        return rect
    }

    private var showsImageAndTitleWithSpacing: Bool {
        imageTitleSpacing > 0 && currentImage != nil && currentTitle?.isEmpty == false
    }
}
