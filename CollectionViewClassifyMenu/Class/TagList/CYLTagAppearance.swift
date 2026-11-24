//
//  CYLTagAppearance.swift
//  CollectionViewClassifyMenu
//
//  The box and text of a tag in one state. Every tag is treated like a CYLBadgeView (CYLTabBarController), so the
//  properties and their defaults follow CYLBadgeAppearance: background, text color, font, corner radius (in points, 0 = square
//  corners), border and margin.
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * The corner radius of a capsule: pass this constant, never the number 1000. A corner radius is in points, limited to half the tag
 * height, and 0 is square; no other value has a special meaning.
 */
public let CYLTagCornerRadiusCapsule: CGFloat = 1000

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
     * Resets `backgroundColor` to `defaultBackgroundColor` (Android `resetBackgroundColor`).
     */
    public func resetBackgroundColor() {
        backgroundColor = Self.defaultBackgroundColor
    }

    /**
     * Resets `textColor` to `defaultTextColor` (Android `resetTextColor`).
     */
    public func resetTextColor() {
        textColor = Self.defaultTextColor
    }

    /**
     * Resets `font` to `defaultFont` (Android `resetFont`).
     */
    public func resetFont() {
        font = Self.defaultFont
    }

    /**
     * Tint of template icons (like `UITabBarItemStateAppearance.iconColor`). `nil` (the default) uses `textColor`.
     * Icons rendered as original keep their colors.
     */
    public var iconColor: UIColor?

    /**
     * Corner radius in points: 0 is square corners, and a value of half the tag height or more is a capsule (the radius
     * is limited to half the height, so a large value such as 1000 is a capsule for any tag). Negative or non-finite
     * values are treated as 0. Not set by default: a capsule (see `isCornerRadiusSet`); the stored value reads 3 until it is set.
     */
    public var cornerRadius = CYLTagAppearance.defaultCornerRadius {
        didSet {
            cornerRadius = Self.sanitized(cornerRadius)
            isCornerRadiusSet = true
        }
    }

    /**
     * Whether `cornerRadius` was set. A tag whose radius was never set is a capsule in every background style (flat and Liquid
     * Glass), the default of `CYLAnimatedItemView`; a set value, 0 (square) included, is used as it is.
     */
    public internal(set) var isCornerRadiusSet = false

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
        isCornerRadiusSet = false
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
        copy.isCornerRadiusSet = isCornerRadiusSet
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
