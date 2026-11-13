//
//  CYLFilterCollectionCell.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * A tag of the multiple-choice filter: a button that fills the cell and shows the selection (the cell takes the
 * touches).
 */
@objc(CYLFilterCollectionCell)
open class CYLFilterCollectionCell: UICollectionViewCell {

    /**
     * The tag's button. (Objective-C name kept: the core's tests read it by key.)
     */
    @objc public let titleButton = CYLIndexPathButton(type: .custom)

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
        titleButton.titleLabel?.font = CYLTagTitleFontForTraitCollection(nil)
        titleButton.setBackgroundImage(Self.stretchableImage(named: "btn_slide_normal"), for: .normal)
        titleButton.setBackgroundImage(Self.stretchableImage(named: "btn_slide_selected"), for: .selected)
        titleButton.setTitleColor(UIColor(red: 96 / 255, green: 147 / 255, blue: 130 / 255, alpha: 1), for: .normal)
        titleButton.setTitleColor(.white, for: .selected)
        contentView.addSubview(titleButton)
    }

    private static func stretchableImage(named name: String) -> UIImage? {
        guard let image = CYLMenuResources.imageNamed(name) else {
            return nil
        }
        let insets = UIEdgeInsets(top: floor(image.size.height / 2), left: floor(image.size.width / 2),
                                  bottom: floor(image.size.height / 2), right: floor(image.size.width / 2))
        return image.resizableImage(withCapInsets: insets, resizingMode: .stretch)
    }
}
