//
//  CYLFilterHeaderView.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * Receives the taps on a section header's "more" button.
 */
public protocol CYLFilterHeaderViewDelegate: AnyObject {

    /**
     * The "more" button of `headerView` was tapped; it is passed so the delegate can toggle its selection.
     */
    func filterHeaderView(_ headerView: CYLFilterHeaderView, didTapMoreButton moreButton: CYLRightImageButton)
}

/**
 * A section header of `CYLClassifyMenuViewController`: the section's title, a "more" button that expands or folds
 * the section, and a separator line at the bottom.
 */
@objc(CYLFilterHeaderView)
open class CYLFilterHeaderView: UICollectionReusableView {

    /**
     * The header's height in the menu.
     */
    public static let defaultHeight: CGFloat = 38

    private enum Metric {
        static let titleButtonWidth: CGFloat = 250
        static let moreButtonWidth: CGFloat = 72
        static let separatorHeight: CGFloat = 0.5
        static let separatorInset: CGFloat = 16
        static let titleLeadingInset: CGFloat = 16
    }

    /**
     * The section's title (and image): a `CYLTagButton` in `CYLMenuStyle.sectionTitle(leadingInset: 16)`. (Objective-C
     * name kept for the core's tests.)
     */
    @objc public let titleButton = CYLIndexPathButton(frame: .zero)

    /**
     * Expands or folds the section (a `CYLTagButton`); hidden by default. (Objective-C name kept for the core's tests.)
     */
    @objc public let moreButton = CYLRightImageButton(frame: .zero)

    /**
     * Receives the taps on `moreButton`.
     */
    public weak var delegate: CYLFilterHeaderViewDelegate?

    private let separator = UIView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        separator.backgroundColor = UIColor(red: 188 / 255, green: 188 / 255, blue: 188 / 255, alpha: 1)
        addSubview(separator)
        backgroundColor = .white

        titleButton.style = CYLMenuStyle.sectionTitle(leadingInset: Metric.titleLeadingInset)
        titleButton.frame = CGRect(x: 16, y: 0, width: Metric.titleButtonWidth, height: bounds.height)
        addSubview(titleButton)

        // The title, arrow and their looks are CYLRightImageButton's own.
        moreButton.isHidden = true
        moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        addSubview(moreButton)
        layoutButtons()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutButtons()
    }

    private func layoutButtons() {
        let width = bounds.width
        let height = bounds.height
        let moreWidth = min(Metric.moreButtonWidth, max(0, width - 28))
        let moreX = max(16, width - 12 - moreWidth)
        moreButton.frame = CGRect(x: moreX, y: 0, width: moreWidth, height: height)
        titleButton.frame = CGRect(x: 16, y: 0, width: max(0, moreX - 24), height: height)
        separator.frame = CGRect(x: Metric.separatorInset, y: max(0, height - Metric.separatorHeight),
                                 width: max(0, width - 2 * Metric.separatorInset), height: Metric.separatorHeight)
    }

    @objc private func moreButtonTapped() {
        delegate?.filterHeaderView(self, didTapMoreButton: moreButton)
    }
}
