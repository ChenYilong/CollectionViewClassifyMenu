//
//  CYLTagAppearance.swift
//  CollectionViewClassifyMenu
//
//  The box and text of a tag in one state. Every tag is treated like a CYLBadgeView (CYLTabBarController), so the
//  properties and their defaults follow CYLBadgeAppearance: background, text color, font, corner radius (0 = automatic
//  capsule), border and margin.
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * A corner radius that keeps the corners square (0 means a capsule), as android-tagview's radius 0.
 */
public let CYLTagCornerRadiusSquare: CGFloat = 0.001

/**
 * The box and text of a tag in one state (`CYLMenuStyle.normalAppearance`…). A final class: the style copies it.
 */
public final class CYLTagAppearance {

    /**
     * The default background: white.
     */
    public static let defaultBackgroundColor = UIColor.white

    /**
     * The default title color: dark gray.
     */
    public static let defaultTextColor = UIColor(white: 0.25, alpha: 1)

    /**
     * The default title font: the system font of 14 points.
     */
    public static let defaultFont = UIFont.systemFont(ofSize: 14)

    private static let defaultCornerRadius: CGFloat = 3
    private static let defaultContentInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)

    /**
     * Background color. White by default.
     */
    public var backgroundColor = CYLTagAppearance.defaultBackgroundColor

    /**
     * Title color. Dark gray by default.
     */
    public var textColor = CYLTagAppearance.defaultTextColor

    /**
     * Title font, the system font of 14 points by default. Scaled for Dynamic Type when the style's
     * `adjustsFontForContentSizeCategory` is true.
     */
    public var font = CYLTagAppearance.defaultFont

    /**
     * Tint of template icons (like `UITabBarItemStateAppearance.iconColor`). `nil` (the default) uses `textColor`.
     * Icons rendered as original keep their colors.
     */
    public var iconColor: UIColor?

    /**
     * Corner radius. 0 means automatic: half the tag height (a capsule), as for CYLBadgeAppearance. Negative or
     * non-finite values are treated as 0. 3 by default.
     */
    public var cornerRadius = CYLTagAppearance.defaultCornerRadius {
        didSet {
            cornerRadius = Self.sanitized(cornerRadius)
        }
    }

    /**
     * Border color, `nil` (no border) by default. Drawn only when `borderWidth` > 0.
     */
    public var borderColor: UIColor?

    /**
     * Border width, 0 by default. Negative or non-finite values are treated as 0.
     */
    public var borderWidth: CGFloat = 0 {
        didSet {
            borderWidth = Self.sanitized(borderWidth)
        }
    }

    /**
     * Space between the border and the content on each side, {5, 10, 5, 10} by default (as android-tagview's
     * textPaddingTop / Left / Bottom / Right). The left and right widen the tag; the top and bottom make it taller than
     * the style's `itemHeight` only when the font needs it. Negative or non-finite values are treated as 0.
     */
    public var contentInsets = CYLTagAppearance.defaultContentInsets {
        didSet {
            let insets = contentInsets
            let sanitized = UIEdgeInsets(top: Self.sanitized(insets.top), left: Self.sanitized(insets.left),
                                         bottom: Self.sanitized(insets.bottom), right: Self.sanitized(insets.right))
            if sanitized != insets {
                contentInsets = sanitized
            }
        }
    }

    /**
     * Horizontal space between the border and the content, 10 by default: the left and right of `contentInsets`.
     * Setting it sets both; reading it gives the larger. Negative or non-finite values are treated as 0.
     */
    public var margin: CGFloat {
        get {
            max(contentInsets.left, contentInsets.right)
        }
        set {
            let value = Self.sanitized(newValue)
            contentInsets.left = value
            contentInsets.right = value
        }
    }

    /**
     * Drawn behind the content, stretched to the tag (as android-tagview's Tag.background); use a resizable image for
     * caps. `nil` (the default) for none: the background color only.
     */
    public var backgroundImage: UIImage?

    /**
     * An appearance with the built-in defaults.
     */
    public init() {}

    /**
     * Restores every property to its built-in default.
     */
    public func reset() {
        backgroundColor = Self.defaultBackgroundColor
        textColor = Self.defaultTextColor
        font = Self.defaultFont
        iconColor = nil
        cornerRadius = Self.defaultCornerRadius
        borderColor = nil
        borderWidth = 0
        contentInsets = Self.defaultContentInsets
        backgroundImage = nil
    }

    /**
     * An independent copy.
     */
    public func copy() -> CYLTagAppearance {
        let copy = CYLTagAppearance()
        copy.backgroundColor = backgroundColor
        copy.textColor = textColor
        copy.font = font
        copy.iconColor = iconColor
        copy.cornerRadius = cornerRadius
        copy.borderColor = borderColor
        copy.borderWidth = borderWidth
        copy.contentInsets = contentInsets
        copy.backgroundImage = backgroundImage
        return copy
    }

    private static func sanitized(_ value: CGFloat) -> CGFloat {
        value.isFinite && value > 0 ? value : 0
    }
}
