//
//  CYLMultipleFilterHeaderView.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md). The title is a CYLTagButton since 2026-11-17,
//  so a section's icon and title are drawn with the same component as every tag (docs/issue-progress.md, "every icon +
//  title component is CYLTagButton").
//

import UIKit

/**
 * A section header of the multiple-choice filter, loaded from CYLMultipleFilterHeaderView.xib: the section's title
 * (`titleButton`, a `CYLTagButton`, with an optional icon before it) over a thin line.
 */
@objc(CYLMultipleFilterHeaderView)
open class CYLMultipleFilterHeaderView: UICollectionReusableView {

    private enum Metric {
        static let titleX: CGFloat = 50
        static let iconX: CGFloat = 6
        static let iconSide: CGFloat = 24
    }

    /**
     * The section's title, and its icon (`image`) when it has one: a `CYLTagButton` in a section-title style, read by
     * VoiceOver as a header labeled with the title.
     */
    @objc public let titleButton: CYLTagButton = CYLIndexPathButton(frame: .zero)

    private let separator = CALayer()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        let style = CYLMenuStyle.sectionTitle(fontSize: 16, textColor: UIColor(white: 0, alpha: 0.5))
        style.imageSize = CGSize(width: Metric.iconSide, height: Metric.iconSide)
        // The icon in the leading 50 pt, the title at 50 pt with or without it (as the XIB's label and image view).
        style.imageTitleSpacing = Metric.titleX - Metric.iconX - Metric.iconSide
        titleButton.style = style
        titleButton.isUserInteractionEnabled = false
        titleButton.isAccessibilityElement = true
        titleButton.accessibilityTraits = .header
        addSubview(titleButton)
        separator.backgroundColor = UIColor(red: 146 / 255, green: 175 / 255, blue: 164 / 255, alpha: 1).cgColor
        layer.addSublayer(separator)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        let titleX = titleButton.image == nil && titleButton.animationURL == nil ? Metric.titleX : Metric.iconX
        titleButton.frame = CGRect(x: titleX, y: 0, width: max(0, bounds.width - titleX), height: bounds.height)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        separator.frame = CGRect(x: Metric.titleX, y: bounds.height - 0.5, width: max(0, bounds.width - Metric.titleX),
                                 height: 0.5)
        CATransaction.commit()
    }
}
