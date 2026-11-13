//
//  CYLMultipleFilterHeaderView.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * A section header of the multiple-choice filter, loaded from CYLMultipleFilterHeaderView.xib: the section's title
 * over a thin line.
 */
@objc(CYLMultipleFilterHeaderView)
open class CYLMultipleFilterHeaderView: UICollectionReusableView {

    /**
     * An image before the title (empty in the default XIB).
     */
    @IBOutlet public weak var imageView: UIImageView!

    /**
     * The section's title.
     */
    @IBOutlet public weak var titleLabel: UILabel!

    private var separator: CALayer?

    open override func awakeFromNib() {
        super.awakeFromNib()
        let lineColor = UIColor(red: 146 / 255, green: 175 / 255, blue: 164 / 255, alpha: 1)
        separator = titleLabel.cyl_addSubLayer(withFrame: .zero, color: lineColor.cgColor)
        titleLabel.textColor = UIColor(white: 0, alpha: 0.5)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        guard let titleLabel else {
            return
        }
        var frame = titleLabel.frame
        frame.size.width = max(0, bounds.width - frame.minX)
        titleLabel.frame = frame
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        separator?.frame = CGRect(x: 0, y: frame.height - 0.5, width: frame.width, height: 0.5)
        CATransaction.commit()
    }
}
