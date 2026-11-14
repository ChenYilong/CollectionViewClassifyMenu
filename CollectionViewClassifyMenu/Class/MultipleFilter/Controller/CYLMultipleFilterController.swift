//
//  CYLMultipleFilterController.swift
//  http://cnblogs.com/ChenYilong/
//
//  Created by  https://github.com/ChenYilong  on 14-7-10.
//  Copyright (c)  http://weibo.com/luohanchenyilong/  . All rights reserved.
//  Multiple choice filter. Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * A side panel with a multiple-choice filter: the sections and items come from `menuDataSource`; taps, the
 * confirmation and the selection are reported to `menuDelegate`. Items the data source marks exclusive ("All")
 * are selected alone in their section.
 */
@objc(CYLMultipleFilterController)
open class CYLMultipleFilterController: CYLFilterBaseController, UICollectionViewDataSource {

    private static let cellsHorizontalMargin: CGFloat = 12

    /**
     * The menu's sections and items.
     */
    @objc open weak var menuDataSource: CYLMenuDataSource!

    /**
     * Receives taps, the confirmed selection and selection changes.
     */
    @objc open weak var menuDelegate: CYLMenuDelegate!

    /**
     * The items' titles, per section.
     */
    private var titles: [[String]] = []

    /**
     * Whether each item is selected, per section (the same shape as `titles`).
     */
    private var selection: [[Bool]] = []

    // MARK: - Life cycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        reloadMenuData()
    }

    // MARK: - API

    /**
     * Reloads the list from the current selection, without asking the data source again.
     */
    @objc open func refreshFilterParams() {
        if isViewLoaded {
            collectionView.reloadData()
        }
    }

    /**
     * Reads the sections and items from the data source again; each section starts with its first exclusive item
     * selected.
     */
    @objc open func reloadMenuData() {
        var titles: [[String]] = []
        var selection: [[Bool]] = []
        if let source = menuDataSource {
            let hasExclusive = source.responds(to: #selector(CYLMenuDataSource.menuItemIsExclusive(at:)))
            for section in 0..<source.numberOfSectionsInMenu() {
                var items: [String] = []
                var states: [Bool] = []
                var selectedExclusive = false
                for item in 0..<source.menuNumberOfItems(inSection: section) {
                    let indexPath = IndexPath(item: item, section: section)
                    items.append(source.menuTitleForItem(at: indexPath))
                    let exclusive = hasExclusive && source.menuItemIsExclusive?(at: indexPath) == true
                    states.append(exclusive && !selectedExclusive)
                    selectedExclusive = selectedExclusive || exclusive
                }
                titles.append(items)
                selection.append(states)
            }
        }
        self.titles = titles
        self.selection = selection
        if isViewLoaded {
            collectionView.reloadData()
        }
    }

    /**
     * The selected items, section by section.
     */
    @discardableResult
    @objc open func selectedIndexPaths() -> [IndexPath]! {
        selection.enumerated().flatMap { section, states in
            states.indices.filter { states[$0] }.map { IndexPath(item: $0, section: section) }
        }
    }

    /**
     * Selects exactly these items. Raises `NSInvalidArgumentException` for an item outside the menu, or when an
     * exclusive item would share its section with another selected item; validate before calling it from Swift,
     * which cannot catch the exception.
     */
    @objc open func setSelectedIndexPaths(_ indexPaths: [IndexPath]!) {
        loadViewIfNeeded()
        let indexPaths = indexPaths ?? []
        let source = menuDataSource
        let hasExclusive = source?.responds(to: #selector(CYLMenuDataSource.menuItemIsExclusive(at:))) == true
        var exclusiveSections = IndexSet()
        var otherSections = IndexSet()
        for path in indexPaths {
            guard titles.indices.contains(path.section), titles[path.section].indices.contains(path.item) else {
                NSException(name: .invalidArgumentException, reason: "Invalid menu selection: \(path)", userInfo: nil)
                    .raise()
                return
            }
            let exclusive = hasExclusive && source?.menuItemIsExclusive?(at: path) == true
            if (exclusive && (exclusiveSections.contains(path.section) || otherSections.contains(path.section)))
                || (!exclusive && exclusiveSections.contains(path.section)) {
                NSException(name: .invalidArgumentException,
                            reason: "Exclusive selection conflicts in section \(path.section)", userInfo: nil).raise()
                return
            }
            if exclusive {
                exclusiveSections.insert(path.section)
            } else {
                otherSections.insert(path.section)
            }
        }
        selection = selection.map { Array(repeating: false, count: $0.count) }
        for path in indexPaths {
            selection[path.section][path.item] = true
        }
        collectionView.reloadData()
    }

    // MARK: - Actions

    open override func confirmButtonClicked(_ sender: Any?) {
        menuDelegate?.menu?(self, didConfirmSelectedItems: selectedIndexPaths())
        super.confirmButtonClicked(sender)
    }

    open override func restoreButtonClicked(_ sender: Any?) {
        reloadMenuData()
        confirmButtonClicked(sender)
    }

    // MARK: - UICollectionViewDataSource

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        titles.count
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        titles.indices.contains(section) ? titles[section].count : 0
    }

    open func collectionView(_ collectionView: UICollectionView,
                             viewForSupplementaryElementOfKind kind: String,
                             at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind, withReuseIdentifier: "CYLMultipleFilterHeaderView", for: indexPath)
            (view as? CYLMultipleFilterHeaderView)?.titleLabel.text = menuDataSource?.menuTitle(forSection: indexPath.section)
            return view
        }
        // Only headers have a size, so UIKit never asks for another kind.
        return UICollectionReusableView(frame: .zero)
    }

    open func collectionView(_ collectionView: UICollectionView,
                             cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reused = collectionView.dequeueReusableCell(withReuseIdentifier: "CYLFilterCollectionCell", for: indexPath)
        guard let cell = reused as? CYLFilterCollectionCell else {
            return reused
        }
        let button = cell.titleButton
        let text = title(at: indexPath)
        button.setTitle(text, for: .normal)
        button.setTitle(text, for: .selected)
        button.titleLabel?.font = tagFont()
        button.isSelected = isSelected(at: indexPath)
        button.section = indexPath.section
        button.row = indexPath.row
        // The cell is the tappable element (the button ignores touches): describe it to VoiceOver.
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = text
        cell.accessibilityTraits = button.isSelected ? [.button, .selected] : .button
        return cell
    }

    // MARK: - UICollectionViewDelegate

    @objc(collectionView:didSelectItemAtIndexPath:)
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard selection.indices.contains(indexPath.section) else {
            return
        }
        var setting = selection[indexPath.section]
        let source = menuDataSource
        let hasExclusive = source?.responds(to: #selector(CYLMenuDataSource.menuItemIsExclusive(at:))) == true
        func isExclusive(_ item: Int) -> Bool {
            hasExclusive && source?.menuItemIsExclusive?(at: IndexPath(item: item, section: indexPath.section)) == true
        }
        if isExclusive(indexPath.item) {
            setting = setting.indices.map { $0 == indexPath.item }
        } else {
            setting[indexPath.item].toggle()
            for item in setting.indices where isExclusive(item) {
                setting[item] = false
            }
            if hasExclusive && !setting.contains(true) {
                // Nothing left selected: fall back to the section's first exclusive item ("All").
                if let first = setting.indices.first(where: isExclusive) {
                    setting[first] = true
                }
            }
        }
        selection[indexPath.section] = setting
        self.collectionView.reloadSections(IndexSet(integer: indexPath.section))
        menuDelegate?.menu?(self, didSelectItemAt: indexPath)
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    @objc(collectionView:layout:sizeForItemAtIndexPath:)
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
        let font = tagFont()
        let size = (title(at: indexPath) as NSString).size(withAttributes: [.font: font])
        return CGSize(width: limitedCellWidth(ceil(size.width)), height: CYLTagMetrics.tagHeight(for: font, minimumHeight: 30))
    }

    @objc(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Self.cellsHorizontalMargin
    }

    // MARK: - Traits

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if isViewLoaded,
           previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.reloadData()
        }
    }

    // MARK: - Private

    private func title(at indexPath: IndexPath) -> String {
        titles.indices.contains(indexPath.section) && titles[indexPath.section].indices.contains(indexPath.row)
            ? titles[indexPath.section][indexPath.row] : ""
    }

    private func isSelected(at indexPath: IndexPath) -> Bool {
        selection.indices.contains(indexPath.section) && selection[indexPath.section].indices.contains(indexPath.row)
            && selection[indexPath.section][indexPath.row]
    }

    private func tagFont() -> UIFont {
        CYLTagMetrics.titleFont(for: collectionView?.traitCollection ?? traitCollection)
    }

    private func limitedCellWidth(_ cellWidth: CGFloat) -> CGFloat {
        let limitWidth = max(0, collectionView.bounds.width - Self.sectionInset.left - Self.sectionInset.right)
        return min(cellWidth + 16, limitWidth)
    }
}
