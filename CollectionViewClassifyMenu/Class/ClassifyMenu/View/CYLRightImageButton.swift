//
//  CYLRightImageButton.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * The "more" button of a menu section: its title ("更多" / "收起") with the arrow image on the right, never
 * highlighted.
 */
@objc(CYLRightImageButton)
open class CYLRightImageButton: UIButton {

    private static let imageToTextMargin: CGFloat = 7

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        setTitle(CYLMenuLocalizedString("CYLMenuExpand"), for: .normal)
        setTitle(CYLMenuLocalizedString("CYLMenuCollapse"), for: .selected)
        titleLabel?.font = .systemFont(ofSize: 12)
        setTitleColor(.black, for: .normal)
        setTitleColor(.black, for: .selected)
        setImage(CYLMenuResources.image(named: "home_btn_more_normal"), for: .normal)
        setImage(CYLMenuResources.image(named: "home_btn_more_selected"), for: .selected)
    }

    /**
     * Never highlighted: the button toggles between its normal and selected looks only.
     */
    open override var isHighlighted: Bool {
        get {
            false
        }
        set {
            // Ignored, as the Objective-C version's empty -setHighlighted:.
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        guard let imageView, let titleLabel, currentImage != nil, currentTitle?.isEmpty == false,
              !imageView.frame.isEmpty, !titleLabel.frame.isEmpty else {
            return
        }
        var imageFrame = imageView.frame
        var titleFrame = titleLabel.frame
        let margin = Self.imageToTextMargin
        let groupX = min(imageFrame.minX, titleFrame.minX) - margin / 2
        titleFrame.origin.x = max(0, groupX)
        let maxTitleWidth = bounds.width - imageFrame.width - margin - titleFrame.minX
        titleFrame.size.width = max(0, min(titleFrame.width, maxTitleWidth))
        imageFrame.origin.x = titleFrame.maxX + margin
        titleLabel.frame = titleFrame
        imageView.frame = imageFrame
    }
}
