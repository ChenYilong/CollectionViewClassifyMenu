//
//  CYLTagMetrics.swift
//  CollectionViewClassifyMenu
//
//  Fonts and heights of the classify menu's tags (was CYLParameterConfiguration.h, created by 陈宜龙 (Chen Yilong) on
//  16/1/6). Translated from Objective-C to Swift (2026, docs/Swift-Migration.md): the inline functions and macros are
//  class members, which Swift and the core's Objective-C tests both call.
//

import UIKit

/**
 * Fonts and heights of tags: the title font scaled for Dynamic Type (capped at `maximumFontScale`) and the height a
 * tag needs for one line of a font.
 */
@objc(CYLTagMetrics)
public final class CYLTagMetrics: NSObject {

    /**
     * Largest multiple of the base size used for Dynamic Type, so tags stay usable at accessibility sizes.
     */
    @objc public static let maximumFontScale: CGFloat = 2

    /**
     * The point size of the tags' title font at the default content size.
     */
    @objc public static let titleFontSize: CGFloat = 16

    /**
     * The vertical padding a tag adds to one line of its font.
     */
    private static let verticalPadding: CGFloat = 10

    private override init() {
        super.init()
    }

    /**
     * System font of `pointSize` scaled for the content size category of `traitCollection` (the app's current
     * category when it is `nil`), at most `maximumFontScale` times larger.
     */
    @objc(scaledSystemFontOfSize:traitCollection:)
    public static func scaledSystemFont(ofSize pointSize: CGFloat, traitCollection: UITraitCollection?) -> UIFont {
        UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: pointSize),
                                         maximumPointSize: pointSize * maximumFontScale,
                                         compatibleWith: traitCollection)
    }

    /**
     * Tag height that fits one line of `font` and is never below `minimumHeight`.
     */
    @objc(tagHeightForFont:minimumHeight:)
    public static func tagHeight(for font: UIFont, minimumHeight: CGFloat) -> CGFloat {
        max(minimumHeight, ceil(font.lineHeight) + verticalPadding)
    }

    /**
     * Tag title font for the given traits. Use it for both measuring and drawing.
     */
    @objc(titleFontForTraitCollection:)
    public static func titleFont(for traitCollection: UITraitCollection?) -> UIFont {
        scaledSystemFont(ofSize: titleFontSize, traitCollection: traitCollection)
    }
}
