//
//  CYLTagHeaderCell.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * Receives the taps on a group header's fold button.
 */
public protocol CYLTagHeaderCellDelegate: AnyObject {

    /**
     * The group of `headerCell` (in `section`) was opened or folded; reload the list.
     */
    func tagHeaderCell(_ headerCell: CYLTagHeaderCell, didToggleGroupInSection section: Int)
}

/**
 * The header of a `CYLTagView` group: the group's name and a button that opens or folds it, loaded from
 * CYLTagHeaderCell.xib.
 */
@objc(CYLTagHeaderCell)
open class CYLTagHeaderCell: UICollectionReusableView {

    @IBOutlet private weak var nameLb: UILabel!
    @IBOutlet private weak var btn: UIButton!

    /**
     * The group shown; setting it updates the name and the fold button's title.
     */
    open var group: CYLTagGroup? {
        didSet {
            let opened = group?.isOpened ?? false
            btn.setTitle(CYLMenuLocalizedString(opened ? "CYLMenuCollapse" : "CYLMenuExpand"), for: .normal)
            nameLb.text = group?.groupName
            nameLb.accessibilityTraits = .header
            // The fold button names the group it changes.
            btn.accessibilityHint = group?.groupName
        }
    }

    /**
     * Receives the taps on the fold button.
     */
    public weak var delegate: CYLTagHeaderCellDelegate?

    /**
     * 监听组按钮的点击 / Handle group button taps: toggle the group, then let the delegate reload.
     */
    @IBAction private func btnClick() {
        guard let group else {
            return
        }
        group.isOpened.toggle()
        delegate?.tagHeaderCell(self, didToggleGroupInSection: group.section)
    }
}
