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
// CYLAnimatedItemCornerRadiusCapsule (the capsule radius) and the rule for Liquid Glass: the module choice of CYLTagButton.swift, since
// Swift Package Manager does not see another file's imports.
#if canImport(CYLAnimatedItemViews)
import CYLAnimatedItem
import CYLAnimatedItemViews
#elseif canImport(CYLAnimatedItem)
import CYLAnimatedItem
#else
import CYLTabBarController
#endif
/**
 * The box and text of a tag in one state (`CYLMenuStyle.normalAppearance`…). A final class: the style copies it.
 */
public final class CYLTagAppearance {

    /**
     * The default background: white in light mode, the secondary system background in dark mode (a dynamic color), so the list's one dynamic
     * tint (`UIColor.label`: the default of the text, the fold chevron, the More and clear icons, the header title) stays readable on it.
     */
    public static let defaultBackgroundColor = UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
    }

    /**
     * The default title color: dark gray in light mode, the label color in dark mode (a dynamic color).
     */
    public static let defaultTextColor = UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor.label : UIColor(white: 0.25, alpha: 1)
    }

    /**
     * The default title font: the system font of 14 points.
     */
    public static let defaultFont = UIFont.systemFont(ofSize: 14)

    private static let defaultCornerRadius: CGFloat = CYLAnimatedItemCornerRadiusCapsule
    private static let defaultContentInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)

    // The EXPLICIT colors: nil is "not set" (UIKit's null_resettable). The built-ins are functions of the traits and are never stored.
    private var explicitBackground: UIColor?
    private var explicitText: UIColor?
    private var explicitIcon: UIColor?

    /**
     * Background color, `null_resettable`: reads the EFFECTIVE value (the explicit color, else `defaultBackgroundColor`, never nil);
     * assigning nil resets to the built-in. `explicitBackgroundColor` / `isBackgroundColorSet` tell whether one was set.
     */
    public var backgroundColor: UIColor! {
        get { explicitBackground ?? Self.defaultBackgroundColor }
        set { explicitBackground = newValue }
    }

    /**
     * The color set on `backgroundColor`; nil when unset (the class built-in applies).
     */
    public var explicitBackgroundColor: UIColor? { explicitBackground }

    /**
     * True when `backgroundColor` was set to a color (and not reset).
     */
    public var isBackgroundColorSet: Bool { explicitBackground != nil }

    /**
     * Title color, `null_resettable`: reads the EFFECTIVE value (the explicit color, else `defaultTextColor`, never nil);
     * assigning nil resets to the built-in.
     */
    public var textColor: UIColor! {
        get { explicitText ?? Self.defaultTextColor }
        set { explicitText = newValue }
    }

    /**
     * The color set on `textColor`; nil when unset.
     */
    public var explicitTextColor: UIColor? { explicitText }

    /**
     * True when `textColor` was set to a color (and not reset).
     */
    public var isTextColorSet: Bool { explicitText != nil }

    /**
     * Title font, the system font of 14 points by default. Scaled for Dynamic Type when the style's
     * `adjustsFontForContentSizeCategory` is true.
     */
    public var font = CYLTagAppearance.defaultFont

    /**
     * Resets `backgroundColor` to `defaultBackgroundColor` (Android `resetBackgroundColor`).
     */
    public func resetBackgroundColor() {
        explicitBackground = nil
    }

    /**
     * Resets `textColor` to `defaultTextColor` (Android `resetTextColor`).
     */
    public func resetTextColor() {
        explicitText = nil
    }

    /**
     * Resets `font` to `defaultFont` (Android `resetFont`).
     */
    public func resetFont() {
        font = Self.defaultFont
    }

    /**
     * Tint of template icons (like `UITabBarItemStateAppearance.iconColor`), `null_resettable`: reads the EFFECTIVE value (the explicit
     * icon color, else the effective `textColor`, never nil); assigning nil resets so that the icon follows the text again.
     * Icons rendered as original keep their colors.
     */
    public var iconColor: UIColor! {
        get { explicitIcon ?? textColor }
        set { explicitIcon = newValue }
    }

    /**
     * The color set on `iconColor`; nil when unset.
     */
    public var explicitIconColor: UIColor? { explicitIcon }

    /**
     * True when `iconColor` was set to a color (and not reset).
     */
    public var isIconColorSet: Bool { explicitIcon != nil }

    /**
     * Corner radius in points: 0 is square corners, and a value of half the tag height or more is a capsule (the radius
     * is limited to half the height, so a large value such as 1000 is a capsule for any tag). Negative or non-finite
     * values are treated as 0. `CYLAnimatedItemCornerRadiusCapsule` by default.
     */
    public var cornerRadius = CYLTagAppearance.defaultCornerRadius {
        didSet {
            cornerRadius = Self.sanitized(cornerRadius)
        }
    }

    // The border, like the background: the built-in (a default of the style, never explicit) and the EXPLICIT values the app, a
    // configuration or a preset set. Under Liquid Glass only an explicit border is drawn (`glassBorderColor` / `glassBorderWidth`).
    private var builtInBorderColor: UIColor?
    private var builtInBorderWidth: CGFloat = 0
    private var explicitBorderColorStorage: UIColor??
    private var explicitBorderWidthStorage: CGFloat?

    /**
     * Border color, `nil` (no border) by default. Drawn only when `borderWidth` > 0. Reads the effective value (the explicit one, else the
     * style's built-in); assigning marks it explicit, also `nil` ("no border").
     */
    public var borderColor: UIColor? {
        get { explicitBorderColorStorage ?? builtInBorderColor }
        set { explicitBorderColorStorage = .some(newValue) }
    }

    /**
     * Border width, 0 by default. Negative or non-finite values are treated as 0. Assigning marks it explicit.
     */
    public var borderWidth: CGFloat {
        get { explicitBorderWidthStorage ?? builtInBorderWidth }
        set { explicitBorderWidthStorage = Self.sanitized(newValue) }
    }

    /**
     * True when `borderColor` / `borderWidth` was assigned (an app, a configuration, a preset), not the style's built-in default.
     */
    public var isBorderColorSet: Bool { explicitBorderColorStorage != nil }
    public var isBorderWidthSet: Bool { explicitBorderWidthStorage != nil }

    /**
     * The border drawn under Liquid Glass: the effective border when the app set the color or the width, else none (the built-in
     * border is not handed to the glass, so the shared glass rim shows).
     */
    public var glassBorderColor: UIColor? {
        isBorderColorSet || isBorderWidthSet ? borderColor : nil
    }
    public var glassBorderWidth: CGFloat {
        isBorderColorSet || isBorderWidthSet ? borderWidth : 0
    }

    /**
     * Sets the style's built-in border, which is not explicit (the style's initializer).
     */
    func applyBuiltInBorder(color: UIColor?, width: CGFloat) {
        builtInBorderColor = color
        builtInBorderWidth = Self.sanitized(width)
    }

    /**
     * Takes `other`'s border with its explicitness (the fold cell copying a tag's border).
     */
    func copyBorder(from other: CYLTagAppearance) {
        builtInBorderColor = other.builtInBorderColor
        builtInBorderWidth = other.builtInBorderWidth
        explicitBorderColorStorage = other.explicitBorderColorStorage
        explicitBorderWidthStorage = other.explicitBorderWidthStorage
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
        explicitBackground = nil
        explicitText = nil
        font = Self.defaultFont
        explicitIcon = nil
        cornerRadius = Self.defaultCornerRadius
        builtInBorderColor = nil
        builtInBorderWidth = 0
        explicitBorderColorStorage = nil
        explicitBorderWidthStorage = nil
        contentInsets = Self.defaultContentInsets
        backgroundImage = nil
    }

    /**
     * An independent copy.
     */
    public func copy() -> CYLTagAppearance {
        let copy = CYLTagAppearance()
        // The UNSET state is copied, not the resolved color: a copy of an untouched appearance keeps following the built-ins.
        copy.explicitBackground = explicitBackground
        copy.explicitText = explicitText
        copy.font = font
        copy.explicitIcon = explicitIcon
        copy.cornerRadius = cornerRadius
        copy.copyBorder(from: self)
        copy.contentInsets = contentInsets
        copy.backgroundImage = backgroundImage
        return copy
    }

    private static func sanitized(_ value: CGFloat) -> CGFloat {
        value.isFinite && value > 0 ? value : 0
    }
}

extension CYLTagAppearance: Equatable {

    /**
     * Equal when every property is equal; an unset color is not equal to a color set to the same value as the built-in.
     */
    public static func == (lhs: CYLTagAppearance, rhs: CYLTagAppearance) -> Bool {
        lhs.explicitBackground == rhs.explicitBackground && lhs.explicitText == rhs.explicitText
            && lhs.explicitIcon == rhs.explicitIcon && lhs.font == rhs.font && lhs.cornerRadius == rhs.cornerRadius
            && lhs.borderColor == rhs.borderColor && lhs.borderWidth == rhs.borderWidth
            && lhs.isBorderColorSet == rhs.isBorderColorSet && lhs.isBorderWidthSet == rhs.isBorderWidthSet
            && lhs.contentInsets == rhs.contentInsets && lhs.backgroundImage == rhs.backgroundImage
    }
}
