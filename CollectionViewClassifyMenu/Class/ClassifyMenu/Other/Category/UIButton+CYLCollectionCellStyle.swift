//
//  UIButton+CYLCollectionCellStyle.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * The looks of a classify-menu tag button (`UIButton.cylApply(_:)`).
 */
public enum CYLCollectionCellButtonStyle: CaseIterable, Sendable {
    /**
     * White with a 1 pt border and 5 pt corners.
     */
    case general
    /**
     * Green text and border; filled green while highlighted.
     */
    case home
    /**
     * Red text and border; filled green while highlighted.
     */
    case red
    /**
     * A light green capsule; the app's tint while selected or highlighted (the menu's default).
     */
    case chengNi
}

public extension UIButton {

    /**
     * Applies one of the classify menu's tag looks.
     */
    func cylApply(_ style: CYLCollectionCellButtonStyle) {
        let green = UIColor(red: 18 / 255, green: 133 / 255, blue: 117 / 255, alpha: 1)
        switch style {
        case .general:
            layer.cornerRadius = 5
            backgroundColor = .white
            layer.borderWidth = 1
            layer.masksToBounds = true
        case .home:
            titleLabel?.font = CYLTagMetrics.titleFont(for: nil)
            setTitleColor(green, for: .normal)
            setTitleColor(green.withAlphaComponent(0.7), for: .selected)
            setTitleColor(.white, for: .highlighted)
            setBackgroundImage(Self.cylImage(filledWith: green), for: .highlighted)
            layer.borderColor = green.cgColor
        case .red:
            let red = UIColor(red: 160 / 255, green: 15 / 255, blue: 85 / 255, alpha: 1)
            titleLabel?.font = CYLTagMetrics.titleFont(for: nil)
            setTitleColor(red, for: .normal)
            setTitleColor(.white, for: .highlighted)
            setBackgroundImage(Self.cylImage(filledWith: green), for: .highlighted)
            layer.borderColor = red.cgColor
        case .chengNi:
            layer.cornerRadius = 13
            layer.masksToBounds = true
            let mint = UIColor(red: 230 / 255, green: 255 / 255, blue: 244 / 255, alpha: 1)
            setBackgroundImage(Self.cylImage(filledWith: mint), for: .normal)
            titleLabel?.font = CYLTagMetrics.titleFont(for: nil)
            setTitleColor(UIColor(red: 42 / 255, green: 185 / 255, blue: 160 / 255, alpha: 1), for: .normal)
            setTitleColor(.white, for: .highlighted)
            let highlighted = CYLMenuResources.image(named: "tag_btn_background_highlighted")
            setBackgroundImage(highlighted, for: .highlighted)
            setTitleColor(.white, for: .selected)
            setTitleColor(.white, for: [.selected, .highlighted])
            setBackgroundImage(highlighted, for: .selected)
            setBackgroundImage(highlighted, for: [.selected, .highlighted])
        }
    }

    /**
     * A 1 × 1 pt image filled with `color`, for stretchable button backgrounds.
     */
    static func cylImage(filledWith color: UIColor) -> UIImage {
        let format = UIGraphicsImageRendererFormat.preferred()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1), format: format).image { context in
            color.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
    }
}
