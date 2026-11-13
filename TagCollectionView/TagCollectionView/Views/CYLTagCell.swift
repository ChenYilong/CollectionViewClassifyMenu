//
//  CYLTagCell.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * A tag of `CYLTagView`: a capsule label with the model's title, loaded from CYLTagCell.xib.
 */
@objc(CYLTagCell)
open class CYLTagCell: UICollectionViewCell {

    @IBOutlet private weak var titleLb: UILabel!

    /**
     * The tag shown; setting it updates the title, the font for the current text size and VoiceOver.
     */
    open var model: CYLTagModel? {
        didSet {
            titleLb.text = model?.title
            titleLb.font = CYLTagModel.titleFont(for: traitCollection)
            isAccessibilityElement = true
            accessibilityLabel = model?.title
            accessibilityTraits = .button
        }
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        roundTitle()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        roundTitle()
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Keep the drawn font in sync with the size CYLTagView measured for this text size.
        titleLb.font = CYLTagModel.titleFont(for: traitCollection)
    }

    private func roundTitle() {
        titleLb.layer.cornerRadius = titleLb.bounds.height / 2
        titleLb.layer.masksToBounds = true
    }
}
