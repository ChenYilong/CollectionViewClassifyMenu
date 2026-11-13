//
//  CYLFilterBaseController.swift
//  http://cnblogs.com/ChenYilong/
//
//  Created by  https://github.com/ChenYilong  on 14-5-12.
//  Copyright (c)  http://weibo.com/luohanchenyilong/  . All rights reserved.
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * Told when a filter panel closes.
 */
public protocol CYLFilterControllerDelegate: AnyObject {

    /**
     * The panel closed after Apply or Reset (not after a tap outside it).
     */
    func filterControllerDidComplete(_ controller: CYLFilterBaseController)
}

/**
 * 问题筛选和医生筛选的基础类 / Base class of the filter panels: a list over a blurred capture of the host view, with
 * Reset and Apply buttons at the bottom, loaded from CYLFilterBaseController.xib. Subclasses fill the list
 * (`CYLMultipleFilterController`).
 */
@objc(CYLFilterBaseController)
open class CYLFilterBaseController: UIViewController, UICollectionViewDelegateFlowLayout {

    /**
     * The insets of the list's sections: the panel leaves 50 points of the host view visible on the left.
     */
    public static let sectionInset = UIEdgeInsets(top: 12, left: 50, bottom: 15, right: 5)

    /**
     * The list.
     */
    @IBOutlet public weak var collectionView: UICollectionView!

    /**
     * The dimmed area outside the panel; a tap on it closes the panel.
     */
    @IBOutlet public weak var contentView: UIView!

    /**
     * Reset.
     */
    @IBOutlet public weak var restoreButton: UIButton!

    /**
     * Apply.
     */
    @IBOutlet public weak var okButton: UIButton!

    @IBOutlet private weak var blurImageView: UIImageView!

    /**
     * Told when the panel closes after Apply or Reset.
     */
    public weak var delegate: CYLFilterControllerDelegate?

    private var restoreTopLine: CALayer?
    private var okTopLine: CALayer?
    private var okLeadingLine: CALayer?

    /**
     * True while the side panel is on screen; controls the buttons' x positions.
     */
    private var isPanelVisible = true

    /**
     * A panel loaded from CYLFilterBaseController.xib in the component's bundle (also Objective-C's `-init`).
     */
    @objc public convenience init() {
        self.init(nibName: "CYLFilterBaseController", bundle: CYLMenuResources.bundle())
    }

    // MARK: - Life cycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        isPanelVisible = true
        let color = UIColor.lightGray.cgColor
        // Localized from CYLClassifyMenuResources.bundle; the XIB titles are placeholders.
        restoreButton.setTitle(CYLMenuLocalizedString("CYLFilterReset"), for: .normal)
        okButton.setTitle(CYLMenuLocalizedString("CYLFilterConfirm"), for: .normal)
        restoreTopLine = restoreButton.cyl_addSubLayer(withFrame: .zero, color: color)
        okTopLine = okButton.cyl_addSubLayer(withFrame: .zero, color: color)
        okLeadingLine = okButton.cyl_addSubLayer(withFrame: .zero, color: color)
        contentView.backgroundColor = .black
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.collectionViewLayout = CYLCollectionViewLeftAlignedLayout()
        collectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        collectionView.register(CYLFilterCollectionCell.self, forCellWithReuseIdentifier: "CYLFilterCollectionCell")
        collectionView.register(UINib(nibName: "CYLMultipleFilterHeaderView", bundle: CYLMenuResources.bundle()),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "CYLMultipleFilterHeaderView")
        contentView.cyl_setTarget(self, action: #selector(hide))
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutBottomButtons()
    }

    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        view.setNeedsLayout()
    }

    // MARK: - Showing and hiding

    /**
     * Shows the panel over `view`: captures it, blurs the capture behind the panel and slides the panel in.
     */
    open func show(in view: UIView) {
        // 屏幕截图 / Capture the host view.
        self.view.frame = view.bounds
        self.view.layoutIfNeeded()
        let screen = view.cyl_capture(withWidth: collectionView.bounds.width)
        // 生成高斯模糊背景 / Generate a Gaussian-blurred background.
        let blur = screen?.cyl_blurredImage(withRadius: 25, iterations: 10, tintColor: nil)
        view.addSubview(self.view)
        blurImageView.image = blur
        moveSubviewsOut()
        contentView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.moveSubviewsIn()
            self.contentView.alpha = 0.35
        }
    }

    /**
     * Apply: slides the panel out, removes it and tells the delegate.
     */
    @IBAction open func confirmButtonClicked(_ sender: Any?) {
        UIView.animate(withDuration: 0.3, animations: {
            self.moveSubviewsOut()
            self.contentView.alpha = 0
        }, completion: { _ in
            self.view.removeFromSuperview()
            self.delegate?.filterControllerDidComplete(self)
        })
    }

    /**
     * Reset: closes the panel like Apply; subclasses reset their selection first.
     */
    @IBAction open func restoreButtonClicked(_ sender: Any?) {
        confirmButtonClicked(nil)
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 38)
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             insetForSectionAt section: Int) -> UIEdgeInsets {
        Self.sectionInset
    }

    // MARK: - Private

    /**
     * Sizes the bottom buttons from the panel's actual width rather than the screen, above the bottom safe area (the
     * home indicator), with the list ending where they begin.
     */
    private func layoutBottomButtons() {
        let panelWidth = collectionView.bounds.width
        let height = view.bounds.height - view.safeAreaInsets.bottom
        var listFrame = collectionView.frame
        listFrame.size.height = max(0, height - 44 - listFrame.minY)
        collectionView.frame = listFrame
        let restoreWidth = floor(panelWidth / 2)
        let okWidth = max(0, panelWidth - restoreWidth)
        let restoreX = isPanelVisible ? 0 : -restoreWidth
        let okX = isPanelVisible ? restoreWidth : -okWidth
        restoreButton.frame = CGRect(x: restoreX, y: height - 44, width: restoreWidth, height: 44)
        okButton.frame = CGRect(x: okX, y: height - 44, width: okWidth, height: 44)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        restoreTopLine?.frame = CGRect(x: 0, y: 0, width: restoreWidth, height: 0.5)
        okTopLine?.frame = CGRect(x: 0, y: 0, width: okWidth, height: 0.5)
        okLeadingLine?.frame = CGRect(x: 0, y: 0, width: 0.5, height: 44)
        CATransaction.commit()
    }

    private func moveSubviewsOut() {
        isPanelVisible = false
        collectionView.cyl_setX(-collectionView.cyl_width())
        restoreButton.cyl_setX(-restoreButton.cyl_width())
        blurImageView.cyl_setX(-blurImageView.cyl_width())
        okButton.cyl_setX(-okButton.cyl_width())
    }

    private func moveSubviewsIn() {
        isPanelVisible = true
        collectionView.cyl_setX(0)
        restoreButton.cyl_setX(0)
        blurImageView.cyl_setX(0)
        okButton.cyl_setX(restoreButton.cyl_width())
    }

    @objc private func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            self.moveSubviewsOut()
            self.contentView.alpha = 0
        }, completion: { _ in
            self.view.removeFromSuperview()
        })
    }
}
