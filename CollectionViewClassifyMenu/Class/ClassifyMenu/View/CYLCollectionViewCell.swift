//
//  CYLCollectionViewCell.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * A tag cell of `CYLClassifyMenuViewController`: one button that fills the cell.
 */
@objc(CYLCollectionViewCell)
open class CYLCollectionViewCell: UICollectionViewCell {

    /**
     * The tag's button, as large as the cell. (Objective-C name kept: the core's tests read it by key.)
     */
    @objc public let button = CYLIndexPathButton(type: .custom)

    /**
     * The section of the tag the cell shows.
     */
    public var section = 0

    /**
     * The row (item) of the tag the cell shows.
     */
    public var row = 0

    /**
     * Whether the cell's tag is shown (kept for layouts that hide tags).
     */
    public var shouldShow = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        button.frame = contentView.bounds
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(button)
        button.cyl_chengNiStyle()
    }
}
