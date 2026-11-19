//
//  CYLFilterCollectionCell.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * A tag of the multiple-choice filter: a tag (`CYLTagButton` in `CYLMenuStyle.filterTag()`) that fills the cell and
 * shows the selection; the cell takes the touches and is the accessibility element.
 */
@objc(CYLFilterCollectionCell)
open class CYLFilterCollectionCell: UICollectionViewCell {

    /**
     * The tag. (Objective-C name kept: the core's tests read it by key.)
     */
    @objc public let titleButton = CYLIndexPathButton(frame: .zero)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        titleButton.frame = contentView.bounds
        titleButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleButton.isUserInteractionEnabled = false
        titleButton.isAccessibilityElement = false
        titleButton.style = CYLMenuStyle.filterTag()
        contentView.addSubview(titleButton)
    }
}
