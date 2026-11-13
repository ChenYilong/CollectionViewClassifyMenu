//
//  CYLTagFoldButton.swift
//  CollectionViewClassifyMenu
//
//  Draws a CYLMenuFoldControl: a CYLTagButton (the tag view) without a border or background, with the title and the
//  chevron after it. Expanded, it shows what the control shows expanded (only the icon, turned 180°, or the collapse
//  title). CYLTagListView puts it below the section, in its header or among the tags.
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * The view of a fold control (`CYLMenuFoldControl`), a tag view whose title and icon follow the expanded state.
 */
open class CYLTagFoldButton: CYLTagButton {

    private static let iconSide: CGFloat = 12
    private static let contentMargin: CGFloat = 6
    private static let minimumHeight: CGFloat = 28
    private static let minimumTouchWidth: CGFloat = 44
    private static let imageTitleSpacing: CGFloat = 3
    private static let rotationDuration: TimeInterval = 0.25

    /**
     * The control last applied.
     */
    open private(set) var foldControl: CYLMenuFoldControl?

    /**
     * The state last applied.
     */
    open private(set) var isExpanded = false

    // MARK: - Initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityIdentifier = CYLTagListAccessibilityIdentifier.foldControl
    }

    // MARK: - API

    /**
     * Shows `foldControl` in `color` (its own color wins) for the expanded or collapsed state; the icon turns with an
     * animation when `animated` (not with Reduce Motion).
     */
    open func applyFoldControl(_ foldControl: CYLMenuFoldControl, color: UIColor?, expanded: Bool, animated: Bool) {
        apply(foldControl, style: Self.style(for: foldControl, color: color), expanded: expanded, animated: animated)
    }

    /**
     * The inline fold control (`CYLMenuFoldControlPosition.tail`): the same content as
     * `applyFoldControl(_:color:expanded:animated:)`, drawn like the tags of `itemStyle` (its normal look, outlined),
     * so it reads as the last tag; its icon and title take the control's color, else `itemStyle.foldControlColor`,
     * like the other fold controls. An icon-only control is a circle.
     */
    open func applyInlineFoldControl(_ foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: Bool,
                                     animated: Bool) {
        apply(foldControl, style: Self.inlineStyle(for: foldControl, itemStyle: itemStyle), expanded: expanded,
              animated: animated)
    }

    /**
     * The size of the inline fold control in that state: the tags' height, and at least as wide as it is high.
     */
    public static func inlineSize(for foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: Bool,
                                  traitCollection: UITraitCollection?) -> CGSize {
        let inline = inlineStyle(for: foldControl, itemStyle: itemStyle)
        let icon = foldControl.showsImage(whenExpanded: expanded) ? foldControl.image : nil
        let side = height(for: inline, traitCollection: traitCollection)
        let contentWidth = width(forTitle: foldControl.title(whenExpanded: expanded), image: icon, style: inline,
                                 traitCollection: traitCollection)
        return CGSize(width: max(side, ceil(contentWidth)), height: side)
    }

    /**
     * The size the control needs in that state (at least a 44 pt wide touch target).
     */
    public static func size(for foldControl: CYLMenuFoldControl, expanded: Bool,
                            traitCollection: UITraitCollection?) -> CGSize {
        let borderless = style(for: foldControl, color: nil)
        let icon = foldControl.showsImage(whenExpanded: expanded) ? foldControl.image : nil
        let contentWidth = width(forTitle: foldControl.title(whenExpanded: expanded), image: icon, style: borderless,
                                 traitCollection: traitCollection)
        return CGSize(width: max(minimumTouchWidth, ceil(contentWidth)),
                      height: max(minimumHeight, height(for: borderless, traitCollection: traitCollection)))
    }

    // MARK: - Private

    private static let allStates: [UIControl.State] = [.normal, .selected, .disabled]

    /**
     * A borderless tag: no background, the title then the icon, in `color`.
     */
    private static func style(for control: CYLMenuFoldControl, color: UIColor?) -> CYLMenuStyle {
        let style = CYLMenuStyle()
        let font = control.font ?? UIFont.preferredFont(forTextStyle: .footnote)
        let tint = control.color ?? color ?? .secondaryLabel
        for state in allStates {
            let appearance = style.appearance(for: state)
            appearance.backgroundColor = .clear
            appearance.borderWidth = 0
            appearance.borderColor = nil
            appearance.margin = contentMargin
            appearance.font = font
            appearance.textColor = tint
            style.setIconColor(tint, for: state)
        }
        style.imagePlacement = .trailing
        style.imageSize = CGSize(width: iconSide, height: iconSide)
        style.imageTitleSpacing = imageTitleSpacing
        style.layoutCentered = true
        style.adjustsFontForContentSizeCategory = control.font == nil
        style.itemHeight = minimumHeight
        return style
    }

    /**
     * The inline control: the tags' normal look in every state (it is never selected), the icon after the title.
     */
    private static func inlineStyle(for control: CYLMenuFoldControl, itemStyle: CYLMenuStyle) -> CYLMenuStyle {
        let style = itemStyle.cylCopy()
        let normal = itemStyle.normalAppearance
        // The same color as the other fold controls (CYLMenuStyle.foldControlColor), lighter than the tags' titles.
        let tint = control.color ?? itemStyle.foldControlColor
        for state in [UIControl.State.selected, .disabled] {
            let appearance = style.appearance(for: state)
            appearance.backgroundColor = normal.backgroundColor
            appearance.borderColor = normal.borderColor
            appearance.borderWidth = normal.borderWidth
            appearance.cornerRadius = normal.cornerRadius
            appearance.margin = normal.margin
            appearance.font = normal.font
            appearance.textColor = normal.textColor
        }
        for state in allStates {
            style.setIconColor(tint, for: state)
        }
        if let font = control.font {
            for appearance in [style.normalAppearance, style.selectedAppearance, style.disabledAppearance] {
                appearance.font = font
            }
        }
        style.imagePlacement = .trailing
        style.imageSize = CGSize(width: iconSide + 4, height: iconSide + 4)
        style.imageTitleSpacing = imageTitleSpacing
        style.layoutCentered = true
        style.numberOfItemsPerRow = 0
        return style
    }

    private func apply(_ foldControl: CYLMenuFoldControl, style: CYLMenuStyle, expanded: Bool, animated: Bool) {
        self.foldControl = foldControl
        isExpanded = expanded
        self.style = style
        title = foldControl.title(whenExpanded: expanded)
        image = foldControl.showsImage(whenExpanded: expanded) ? foldControl.image : nil
        setNeedsLayout()
        // Just under π, so that it turns the same way back and forth.
        let transform = expanded && foldControl.rotatesImageWhenExpanded
            ? CGAffineTransform(rotationAngle: .pi - 0.0001) : .identity
        if animated && !UIAccessibility.isReduceMotionEnabled {
            UIView.animate(withDuration: Self.rotationDuration) {
                self.imageView.transform = transform
            }
        } else {
            imageView.transform = transform
        }
    }
}
