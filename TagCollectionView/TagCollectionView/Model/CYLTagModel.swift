//
//  CYLTagModel.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * A tag of `CYLTagView`: its title and the size it needs at a text size (Dynamic Type).
 */
@objc(CYLTagModel)
open class CYLTagModel: NSObject {

    private static let titleFontSize: CGFloat = 17
    private static let minimumHeight: CGFloat = 35
    private static let horizontalPadding: CGFloat = 50

    /**
     * The tag's text; setting it measures the tag again for the app's current text size.
     */
    @objc open var title: String {
        didSet {
            updateSize(for: nil)
        }
    }

    /**
     * The width the tag needs, after the last `updateSize(for:)`. Dynamic: subclasses (also in Objective-C) may
     * override the getter.
     */
    @objc open private(set) dynamic var width: CGFloat = 0

    /**
     * The height the tag needs, after the last `updateSize(for:)`.
     */
    @objc open private(set) dynamic var height: CGFloat = 0

    /**
     * A tag measured for the app's current text size.
     */
    @objc public init(title: String) {
        self.title = title
        super.init()
        updateSize(for: nil)
    }

    /**
     * The font used to draw and measure the title for the given traits (nil: the app's current text size).
     */
    @objc(titleFontForTraitCollection:)
    open class func titleFont(for traitCollection: UITraitCollection?) -> UIFont {
        CYLTagMetrics.scaledSystemFont(ofSize: titleFontSize, traitCollection: traitCollection)
    }

    /**
     * Recalculates `width` and `height` for the content size category of `traitCollection`; nil uses the app's
     * current category.
     */
    @objc(updateSizeForTraitCollection:)
    open func updateSize(for traitCollection: UITraitCollection?) {
        let font = Self.titleFont(for: traitCollection)
        let size = (title as NSString).size(withAttributes: [.font: font])
        width = ceil(size.width) + Self.horizontalPadding
        height = CYLTagMetrics.tagHeight(for: font, minimumHeight: Self.minimumHeight)
    }
}
