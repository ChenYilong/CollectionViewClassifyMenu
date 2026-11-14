//
//  CYLTagColors.swift
//  CollectionViewClassifyMenu
//
//  The four colors of a tag (background, border, text, selected background) and the color themes that make them, as
//  AndroidTagView's ColorFactory: a random Material color, pure cyan or pure teal, each a 0x33 background and a 0x88
//  border of the same color.
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * AndroidTagView's tag_theme.
 */
@objc public enum CYLTagColorTheme: Int {
    /**
     * The style's own colors (ColorFactory.NONE, the default).
     */
    case none = -1
    /**
     * A Material color per tag (ColorFactory.RANDOM), the same one for a tag every time it is drawn.
     */
    case random = 0
    /**
     * ColorFactory.PURE_CYAN.
     */
    case pureCyan = 1
    /**
     * ColorFactory.PURE_TEAL.
     */
    case pureTeal = 2
}

/**
 * The four colors of a tag; `nil` keeps the style's color.
 */
public struct CYLTagColors: Equatable {

    /**
     * ColorFactory's alpha of a theme's background ("33").
     */
    public static let backgroundAlpha: CGFloat = 0x33 / 255

    /**
     * ColorFactory's alpha of a theme's border ("88").
     */
    public static let borderAlpha: CGFloat = 0x88 / 255

    /**
     * ColorFactory's palette: RED, LIGHTBLUE, AMBER, ORANGE, YELLOW, LIME, BLUE, INDIGO, LIGHTGREEN, GREY, DEEPPURPLE,
     * TEAL, CYAN, as "RRGGBB".
     */
    public static let paletteHexByName = Dictionary(uniqueKeysWithValues: zip(paletteNames, palette))

    /**
     * ColorFactory's SHARP666666.
     */
    public static var gray666666: UIColor {
        color(hex: "666666", alpha: 1)
    }

    /**
     * ColorFactory's SHARP727272.
     */
    public static var gray727272: UIColor {
        color(hex: "727272", alpha: 1)
    }

    /**
     * ColorFactory.COLORS, in its order.
     */
    private static let palette = ["F44336", "03A9F4", "FFC107", "FF9800", "FFEB3B", "CDDC39", "2196F3", "3F51B5",
                                  "8BC34A", "9E9E9E", "673AB7", "009688", "00BCD4"]
    private static let paletteNames = ["RED", "LIGHTBLUE", "AMBER", "ORANGE", "YELLOW", "LIME", "BLUE", "INDIGO",
                                       "LIGHTGREEN", "GREY", "DEEPPURPLE", "TEAL", "CYAN"]

    /**
     * The background.
     */
    public var backgroundColor: UIColor?

    /**
     * The border.
     */
    public var borderColor: UIColor?

    /**
     * The title.
     */
    public var textColor: UIColor?

    /**
     * The background while selected.
     */
    public var selectedBackgroundColor: UIColor?

    /**
     * Colors; `nil` keeps the style's.
     */
    public init(backgroundColor: UIColor? = nil, borderColor: UIColor? = nil, textColor: UIColor? = nil,
                selectedBackgroundColor: UIColor? = nil) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.textColor = textColor
        self.selectedBackgroundColor = selectedBackgroundColor
    }

    /**
     * The palette color `hex` ("F44336") as a theme makes it (0x33 background, 0x88 border), with these text and
     * selected background colors.
     */
    public init(paletteHex hex: String, textColor: UIColor, selectedBackgroundColor: UIColor) {
        self.init(backgroundColor: Self.color(hex: hex, alpha: Self.backgroundAlpha),
                  borderColor: Self.color(hex: hex, alpha: Self.borderAlpha), textColor: textColor,
                  selectedBackgroundColor: selectedBackgroundColor)
    }

    /**
     * The colors of a theme; for the random theme, the palette color at `seed` modulo the palette's size
     * (ColorFactory's onRandomBuild picks one at random). `nil` for `.none`.
     */
    public init?(theme: CYLTagColorTheme, seed: Int) {
        switch theme {
        case .random:
            let count = Self.palette.count
            self.init(paletteHex: Self.palette[((seed % count) + count) % count], textColor: Self.gray666666,
                      selectedBackgroundColor: Self.gray727272)
        case .pureCyan:
            self.init(paletteHex: "00BCD4", textColor: Self.gray727272, selectedBackgroundColor: Self.gray666666)
        case .pureTeal:
            self.init(paletteHex: "009688", textColor: Self.gray727272, selectedBackgroundColor: Self.gray666666)
        case .none:
            return nil
        }
    }

    /**
     * A random palette color (onRandomBuild).
     */
    public static func random() -> CYLTagColors {
        CYLTagColors(paletteHex: palette.randomElement() ?? "F44336", textColor: gray666666,
                     selectedBackgroundColor: gray727272)
    }

    /**
     * A copy of `style` with these colors: background, border (a hairline when the style had none) and text in the
     * normal state, the text, border and background in the selected state.
     */
    public func styleByApplying(to style: CYLMenuStyle) -> CYLMenuStyle {
        let result = style.cylCopy()
        let normal = result.normalAppearance
        let selected = result.selectedAppearance
        if let backgroundColor {
            normal.backgroundColor = backgroundColor
        }
        if let textColor {
            normal.textColor = textColor
            selected.textColor = textColor
        }
        if let borderColor {
            normal.borderColor = borderColor
            selected.borderColor = borderColor
            if normal.borderWidth <= 0 {
                normal.borderWidth = 1
            }
        }
        if let selectedBackgroundColor {
            selected.backgroundColor = selectedBackgroundColor
        }
        return result
    }

    private static func color(hex: String, alpha: CGFloat) -> UIColor {
        let rgb = UInt32(hex, radix: 16) ?? 0
        return UIColor(red: CGFloat((rgb >> 16) & 0xFF) / 255, green: CGFloat((rgb >> 8) & 0xFF) / 255,
                       blue: CGFloat(rgb & 0xFF) / 255, alpha: alpha)
    }
}
