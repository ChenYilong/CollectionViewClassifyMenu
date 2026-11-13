//
//  CYLTagCreateCell.swift
//  CollectionViewClassifyMenu
//
//  The "+ 新建标签" item of CYLTagListView (CYLMenuItemType.create): an outlined tag with a plus icon. A tap on it
//  asks the delegate to create a tag (menu(_:didRequestNewItemWithName:at:)); it is never selected.
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * The "+ 新建标签" item: an outlined tag with a plus icon, an action rather than a tag (never selected).
 */
open class CYLTagCreateCell: CYLTagListCell {

    private static let defaultIconSide: CGFloat = 14

    /**
     * The plus icon of the core bundle (a template image, drawn in the icon color).
     */
    public static var plusImage: UIImage {
        CYLMenuResources.imageNamed("cyl_tag_plus") ?? UIImage(systemName: "plus") ?? UIImage()
    }

    /**
     * "新建标签" for an empty name, "新建标签：<name>" otherwise, in the component's language.
     */
    public static func title(forName name: String?) -> String {
        guard let name, !name.isEmpty else {
            return CYLMenuLocalizedString("CYLMenuNewTag")
        }
        return String(format: CYLMenuLocalizedString("CYLMenuNewTagNamed"), name)
    }

    /**
     * The outlined look of the item, from a list (or section) style: the list's background, a hairline border and
     * secondary text. The metrics stay the list's.
     */
    public static func outlinedStyle(from style: CYLMenuStyle) -> CYLMenuStyle {
        let outlined = style.cylCopy()
        let normal = outlined.normalAppearance
        normal.backgroundColor = style.backgroundColor
        normal.borderColor = .separator
        normal.borderWidth = max(1 / max(1, UIScreen.main.scale), 1)
        normal.textColor = .secondaryLabel
        outlined.setIconColor(.tertiaryLabel, for: .normal)
        outlined.setTitleTextAttributes(nil, for: .normal)
        outlined.imagePlacement = .leading
        if outlined.imageSize == .zero {
            outlined.imageSize = CGSize(width: defaultIconSide, height: defaultIconSide)
        }
        return outlined
    }

    /**
     * Shows "+ 新建标签" or "+ 新建标签：<name>" in `style` (already outlined, `outlinedStyle(from:)`).
     */
    open func configure(name: String?, style: CYLMenuStyle, isEnabled: Bool) {
        configure(title: Self.title(forName: name), image: Self.plusImage, selectedImage: nil, animationURL: nil,
                  style: style, isSelected: false, isEnabled: isEnabled)
        // An action, not a tag: never "selected" for VoiceOver.
        accessibilityTraits = isEnabled ? .button : [.button, .notEnabled]
        accessibilityIdentifier = CYLTagListAccessibilityIdentifier.createItem
    }
}
