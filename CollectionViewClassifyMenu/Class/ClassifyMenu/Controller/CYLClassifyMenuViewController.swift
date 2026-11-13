//
//  CYLClassifyMenuViewController.swift
//  http://cnblogs.com/ChenYilong/
//
//  Created by  https://github.com/ChenYilong  on 14-7-10.
//  Copyright (c)  http://weibo.com/luohanchenyilong/  . All rights reserved.
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * A single-choice classify menu: sections of tags from `menuDataSource`, each folded to `defaultVisibleRows` rows
 * with a "more" button, an optional header above and footer below the tags in one scroll view. Taps are reported to
 * `menuDelegate`.
 */
@objc(CYLClassifyMenuViewController)
open class CYLClassifyMenuViewController: UIViewController, UICollectionViewDataSource,
                                          UICollectionViewDelegateFlowLayout, CYLFilterHeaderViewDelegate {

    private enum Metric {
        static let headerToCollectionViewMargin: CGFloat = 0
        static let cellsHorizontalMargin: CGFloat = 12
        static let cellHeight: CGFloat = 30
        static let itemButtonImageToTextMargin: CGFloat = 5
        static let collectionViewToLeftMargin: CGFloat = 16
        static let collectionViewToTopMargin: CGFloat = 12
        static let collectionViewToRightMargin: CGFloat = 16
        static let collectionViewToBottomMargin: CGFloat = 10
        static let cellButtonCenterToBorderMargin: CGFloat = 19
    }

    private static let cellIdentifier = "CellIdentifier"
    private static let headerViewCellIdentifier = "HeaderViewCellIdentifier"
    private static let sectionTypeKey = "Type"

    // MARK: - API

    /**
     * The menu's sections and tags.
     */
    @objc open weak var menuDataSource: CYLMenuDataSource!

    /**
     * Receives the taps on tags.
     */
    @objc open weak var menuDelegate: CYLMenuDelegate!

    /**
     * A view above the tags, in the same scroll view.
     */
    @objc open var menuHeaderView: UIView!

    /**
     * A view below the tags, in the same scroll view, e.g. the results of the selected tag. It is as
     * wide as the menu; its height is its Auto Layout fitting height (or its frame height without
     * constraints). Call -updateMenuLayout after its content changes.
     */
    @objc open var menuFooterView: UIView! {
        willSet {
            if menuFooterView !== newValue {
                menuFooterView?.removeFromSuperview()
            }
        }
        didSet {
            updateMenuLayout()
        }
    }

    /**
     * The tag shown as selected (single choice), or nil. Taps are reported to the menu delegate and do
     * not change it: set it from -menu:didSelectItemAtIndexPath:.
     */
    @objc open var selectedIndexPath: IndexPath! {
        didSet {
            guard isViewLoaded else {
                return
            }
            for indexPath in collectionView?.indexPathsForVisibleItems ?? [] {
                if let cell = collectionView?.cellForItem(at: indexPath) as? CYLCollectionViewCell {
                    updateSelection(of: cell, at: indexPath)
                }
            }
        }
    }

    private var defaultVisibleRowsStorage: UInt = 0

    /**
     * The rows each section shows before its "more" button (at least 1, the default).
     */
    @objc open var defaultVisibleRows: UInt {
        get {
            defaultVisibleRowsStorage == 0 ? 1 : defaultVisibleRowsStorage
        }
        set {
            defaultVisibleRowsStorage = max(1, newValue)
            if isViewLoaded {
                updateMoreButtons(defaultRowsCount: defaultVisibleRowsStorage)
                collectionView?.reloadData()
                updateViewHeight()
            }
        }
    }

    // MARK: - State
    //
    // The state keeps its Objective-C names and Foundation types as @objc members: the core's Objective-C tests
    // (CYLCollectionViewClassifyMenuLayoutTests) read and replace it through key-value coding.

    @objc private var collectionView: UICollectionView!
    private var backgroundView: UIScrollView!
    private var calculatedCollectionWidth: CGFloat = 0

    /**
     * The sections as dictionaries: `Type` (the title) and `kDataSourceSectionKey` (the items, each a dictionary with
     * `kDataSourceCellTextKey` and, when it has one, `kDataSourceCellPictureKey`).
     */
    @objc private var dataSource: NSArray = []

    /**
     * The expanded sections (NSNumber).
     */
    @objc private var expandSectionArray: NSMutableArray = []

    private var moreButtonHiddenStorage: NSMutableArray?
    private var firstRowCellCountStorage: NSMutableArray?
    private var rowsCountStorage: NSArray?
    private var cellsCountPerRowStorage: NSArray?

    /**
     * Per section: whether the "more" button is hidden (NSNumber); nil recomputes it.
     */
    @objc private var collectionHeaderMoreBtnHideBoolArray: NSMutableArray! {
        get {
            if let moreButtonHiddenStorage {
                return moreButtonHiddenStorage
            }
            let values = NSMutableArray(array: Array(repeating: NSNumber(value: true), count: dataSource.count))
            moreButtonHiddenStorage = values
            return values
        }
        set {
            moreButtonHiddenStorage = newValue
        }
    }

    /**
     * Per section: the tags shown while folded (NSNumber); nil recomputes the first row's count.
     */
    @objc private var firstRowCellCountArray: NSMutableArray! {
        get {
            if let firstRowCellCountStorage {
                return firstRowCellCountStorage
            }
            let values = NSMutableArray()
            for section in dataSource {
                values.add(NSNumber(value: cellsInPerRow(items: items(of: section)).first ?? 0))
            }
            firstRowCellCountStorage = values
            return values
        }
        set {
            firstRowCellCountStorage = newValue
        }
    }

    /**
     * Per section: its number of rows (NSNumber); nil recomputes it.
     */
    @objc private var rowsCountPerSection: NSArray! {
        get {
            if let rowsCountStorage {
                return rowsCountStorage
            }
            let values = (cellsCountArrayPerRowInSections as? [NSArray] ?? []).map { NSNumber(value: $0.count) } as NSArray
            rowsCountStorage = values
            return values
        }
        set {
            rowsCountStorage = newValue
        }
    }

    /**
     * Per section: the number of tags in each row (arrays of NSNumber); nil recomputes it.
     */
    @objc private var cellsCountArrayPerRowInSections: NSArray! {
        get {
            if let cellsCountPerRowStorage {
                return cellsCountPerRowStorage
            }
            let values = NSMutableArray()
            for section in dataSource {
                values.add(cellsInPerRow(items: items(of: section)).map { NSNumber(value: $0) })
            }
            cellsCountPerRowStorage = values
            return values
        }
        set {
            cellsCountPerRowStorage = newValue
        }
    }

    // MARK: - Initializers

    /**
     * A menu without a nib (as Objective-C's `-init` → `-initWithNibName:nil bundle:nil`).
     */
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    // MARK: - Life cycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        // The navigation item's title, not `title`: in a tab bar, `title` would replace the tab's own title.
        navigationItem.title = CYLMenuLocalizedString("CYLMenuTitle")
        let backgroundView = UIScrollView(frame: view.bounds)
        backgroundView.showsVerticalScrollIndicator = false
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.alwaysBounceVertical = true
        backgroundView.backgroundColor = UIColor(red: 252 / 255, green: 252 / 255, blue: 252 / 255, alpha: 2)
        view.addSubview(backgroundView)
        self.backgroundView = backgroundView

        initData()
        addCollectionView()
        updateMoreButtons(defaultRowsCount: defaultVisibleRows)
        if let menuHeaderView {
            backgroundView.addSubview(menuHeaderView)
        }
        if let menuFooterView {
            backgroundView.addSubview(menuFooterView)
        }
        view.backgroundColor = .blue
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundView?.isScrollEnabled = true
        updateViewHeight()
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            // Text size changed: measure every tag again on the next layout pass.
            calculatedCollectionWidth = 0
            view.setNeedsLayout()
        }
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = collectionView?.bounds.width ?? 0
        if width > 0 && width != calculatedCollectionWidth {
            calculatedCollectionWidth = width
            clearLayoutCaches()
            updateMoreButtons(defaultRowsCount: defaultVisibleRows)
            collectionView?.reloadData()
            updateViewHeight()
        }
    }

    /**
     * Reads the sections and tags from the data source again and folds every section.
     */
    @objc open func reloadMenuData() {
        initData()
        if isViewLoaded {
            expandSectionArray = []
            updateMoreButtons(defaultRowsCount: defaultVisibleRows)
            collectionView?.reloadData()
            updateViewHeight()
        }
    }

    /**
     * Lays the tags, the header and the footer out again, e.g. after the footer's content changed.
     */
    @objc open func updateMenuLayout() {
        if isViewLoaded {
            updateViewHeight()
        }
    }

    // MARK: - UICollectionViewDataSource

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        dataSource.count
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if expandSectionArray.contains(NSNumber(value: section)) {
            return items(of: dataSource[section]).count
        }
        return (firstRowCellCountArray[section] as? NSNumber)?.intValue ?? 0
    }

    open func collectionView(_ collectionView: UICollectionView,
                             cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reused = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellIdentifier, for: indexPath)
        guard let cell = reused as? CYLCollectionViewCell, let button = cell.button else {
            return reused
        }
        let item = items(of: dataSource[indexPath.section])[indexPath.row]
        let text = item[kDataSourceCellTextKey] as? String
        if let image = image(for: item) {
            button.setImage(image, for: .normal)
            button.cyl_imageTitleSpacing = Metric.itemButtonImageToTextMargin
        } else {
            button.setImage(nil, for: .normal)
            button.cyl_imageTitleSpacing = 0
        }
        button.titleLabel?.font = tagFont()
        button.setTitle(text, for: .normal)
        button.setTitle(text, for: .selected)
        button.addTarget(self, action: #selector(itemButtonClicked(_:)), for: .touchUpInside)
        button.section = indexPath.section
        button.row = indexPath.row
        updateSelection(of: cell, at: indexPath)
        return cell
    }

    open func collectionView(_ collectionView: UICollectionView,
                             viewForSupplementaryElementOfKind kind: String,
                             at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            // Only headers have a size, so UIKit never asks for another kind.
            return UICollectionReusableView(frame: .zero)
        }
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: Self.headerViewCellIdentifier, for: indexPath)
        guard let header = view as? CYLFilterHeaderView else {
            return view
        }
        let section = indexPath.section
        let sectionTitle = (dataSource[section] as? NSDictionary)?[Self.sectionTypeKey] as? String
        header.moreButton.isHidden = (collectionHeaderMoreBtnHideBoolArray[section] as? NSNumber)?.boolValue ?? true
        header.delegate = self
        header.titleButton.tag = section
        header.moreButton.tag = section
        header.moreButton.isSelected = expandSectionArray.contains(NSNumber(value: section))
        // The title is a heading, not a control; the fold button names its section.
        header.titleButton.accessibilityTraits = .header
        header.moreButton.accessibilityHint = sectionTitle
        header.titleButton.setTitle(sectionTitle, for: .normal)
        header.titleButton.setTitle(sectionTitle, for: .selected)
        let sectionImage = menuDataSource?.menuImage?(forSection: section)
        header.titleButton.setImage(sectionImage, for: .normal)
        return header
    }

    // MARK: - UICollectionViewDelegate

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        menuDelegate?.menu?(self, didSelectItemAt: indexPath)
    }

    // MARK: - CYLFilterHeaderViewDelegate

    open func filterHeaderViewDidTapMoreButton(_ sender: Any!) {
        guard let sender = sender as? UIButton else {
            return
        }
        sender.isSelected.toggle()
        if sender.isSelected {
            expandSectionArray.add(NSNumber(value: sender.tag))
        } else {
            expandSectionArray.remove(NSNumber(value: sender.tag))
        }
        self.collectionView?.performBatchUpdates({ [weak self] in
            self?.collectionView?.reloadSections(IndexSet(integer: sender.tag))
        }, completion: { [weak self] _ in
            self?.updateViewHeight()
        })
    }

    // MARK: - UICollectionViewDelegateFlowLayout (left-aligned layout)

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = items(of: dataSource[indexPath.section])[indexPath.row]
        return CGSize(width: cellWidth(for: item), height: cellHeight())
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Metric.cellsHorizontalMargin
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: max(0, collectionView.bounds.width - 50), height: 38)
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: Metric.collectionViewToTopMargin, left: Metric.collectionViewToLeftMargin,
                     bottom: Metric.collectionViewToBottomMargin, right: Metric.collectionViewToRightMargin)
    }

    // MARK: - Actions

    @objc private func itemButtonClicked(_ button: CYLIndexPathButton) {
        let indexPath = IndexPath(item: button.row, section: button.section)
        collectionView(collectionView, didSelectItemAt: indexPath)
    }

    // MARK: - Data

    private func initData() {
        clearLayoutCaches()
        let sections = NSMutableArray()
        if let source = menuDataSource {
            for section in 0..<source.numberOfSectionsInMenu() {
                let items = NSMutableArray()
                for item in 0..<source.menuNumberOfItems(inSection: section) {
                    let indexPath = IndexPath(item: item, section: section)
                    let entry = NSMutableDictionary(object: source.menuTitleForItem(at: indexPath),
                                                    forKey: kDataSourceCellTextKey as NSString)
                    if let image = source.menuImageForItem?(at: indexPath) {
                        entry[kDataSourceCellPictureKey] = image
                    }
                    items.add(entry)
                }
                sections.add([Self.sectionTypeKey: source.menuTitle(forSection: section), kDataSourceSectionKey: items])
            }
        }
        dataSource = sections
    }

    private func clearLayoutCaches() {
        firstRowCellCountArray = nil
        collectionHeaderMoreBtnHideBoolArray = nil
        rowsCountPerSection = nil
        cellsCountArrayPerRowInSections = nil
    }

    private func items(of section: Any) -> [NSDictionary] {
        ((section as? NSDictionary)?[kDataSourceSectionKey] as? NSArray) as? [NSDictionary] ?? []
    }

    /**
     * The item's image: a UIImage from -menuImageForItemAtIndexPath:, or the bundled default for legacy dictionaries
     * that store a non-empty string.
     */
    private func image(for item: NSDictionary) -> UIImage? {
        let picture = item[kDataSourceCellPictureKey]
        if let image = picture as? UIImage {
            return image
        }
        if let name = picture as? String, !name.isEmpty {
            return CYLMenuResources.imageNamed("home_btn_shrink")
        }
        return nil
    }

    // MARK: - Layout

    private func addCollectionView() {
        let frame = CGRect(x: 0, y: (menuHeaderView?.frame.height ?? 0) + Metric.headerToCollectionViewMargin,
                           width: view.bounds.width, height: max(0, view.bounds.height - 40))
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: CYLCollectionViewLeftAlignedLayout())
        collectionView.autoresizingMask = .flexibleWidth
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.register(CYLCollectionViewCell.self, forCellWithReuseIdentifier: Self.cellIdentifier)
        collectionView.allowsMultipleSelection = true
        collectionView.register(CYLFilterHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: Self.headerViewCellIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        collectionView.scrollsToTop = false
        collectionView.isScrollEnabled = false
        backgroundView.addSubview(collectionView)
        self.collectionView = collectionView
    }

    private func updateViewHeight() {
        // Objective-C sent these to nil before the view was loaded; the same calls do nothing here.
        guard let collectionView, let backgroundView else {
            return
        }
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.collectionViewLayout.prepare()
        // 仅修改self.collectionView的高度,xyw值不变 / Change only the collection view's height.
        var frame = collectionView.frame
        frame.size.height = collectionView.contentSize.height + Metric.collectionViewToTopMargin
            + Metric.collectionViewToBottomMargin
        collectionView.frame = frame
        let footerHeight = layoutFooter(belowY: collectionView.frame.maxY)
        backgroundView.contentSize = CGSize(
            width: backgroundView.bounds.width,
            height: collectionView.contentSize.height + (menuHeaderView?.frame.height ?? 0)
                + Metric.collectionViewToTopMargin + Metric.collectionViewToBottomMargin + footerHeight + 64)
    }

    /**
     * Places the footer at `y`, as wide as the menu, and returns its height.
     */
    private func layoutFooter(belowY y: CGFloat) -> CGFloat {
        guard let footer = menuFooterView, let backgroundView, backgroundView.bounds.width > 0 else {
            // Not laid out yet: viewDidLoad and the first layout pass place it.
            return 0
        }
        if footer.superview !== backgroundView {
            backgroundView.addSubview(footer)
        }
        let width = backgroundView.bounds.width
        var height = footer.frame.height
        if !footer.constraints.isEmpty || !footer.subviews.isEmpty {
            let fitting = footer.systemLayoutSizeFitting(
                CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            if fitting.height > 0 {
                height = fitting.height
            }
        }
        footer.translatesAutoresizingMaskIntoConstraints = true
        footer.frame = CGRect(x: 0, y: y, width: width, height: ceil(height))
        return footer.frame.height
    }

    /**
     * Shows each section's "more" button when it has more rows than `defaultRowsCount`, and folds it to those rows.
     * Objective-C name kept for the core's tests, which call it.
     */
    @objc(cyl_judgeMoreButtonShowWhenDefaultRowsCount:)
    private func updateMoreButtons(defaultRowsCount: UInt) {
        let limit = Int(defaultRowsCount)
        let hidden = collectionHeaderMoreBtnHideBoolArray ?? NSMutableArray()
        for (section, rows) in (rowsCountPerSection ?? []).enumerated() where section < hidden.count {
            hidden[section] = NSNumber(value: ((rows as? NSNumber)?.intValue ?? 0) <= limit)
        }
        let counts = firstRowCellCountArray ?? NSMutableArray()
        for (section, cellsPerRow) in (cellsCountArrayPerRowInSections ?? []).enumerated() where section < counts.count {
            let perRow = (cellsPerRow as? [NSNumber] ?? []).map(\.intValue)
            counts[section] = NSNumber(value: perRow.prefix(limit).reduce(0, +))
        }
    }

    private func updateSelection(of cell: CYLCollectionViewCell, at indexPath: IndexPath) {
        let selected = selectedIndexPath == indexPath
        cell.button?.isSelected = selected
        cell.button?.accessibilityTraits = selected ? [.button, .selected] : .button
    }

    private func cellsInPerRow(items: [NSDictionary]) -> [Int] {
        let availableWidth = max(0, (collectionView?.bounds.width ?? 0) - Metric.collectionViewToLeftMargin
                                    - Metric.collectionViewToRightMargin)
        var usedWidth: CGFloat = 0
        var count = 0
        var cellCounts: [Int] = []
        for item in items {
            let width = cellWidth(for: item)
            if count > 0 && usedWidth + Metric.cellsHorizontalMargin + width > availableWidth {
                cellCounts.append(count)
                count = 0
                usedWidth = 0
            }
            usedWidth += (count > 0 ? Metric.cellsHorizontalMargin : 0) + width
            count += 1
        }
        if count > 0 {
            cellCounts.append(count)
        }
        return cellCounts
    }

    private func tagFont() -> UIFont {
        CYLTagTitleFontForTraitCollection(collectionView?.traitCollection ?? traitCollection)
    }

    private func cellHeight() -> CGFloat {
        CYLTagHeightForFont(tagFont(), Metric.cellHeight)
    }

    private func cellWidth(for item: NSDictionary) -> CGFloat {
        let text = item[kDataSourceCellTextKey] as? String ?? ""
        let size = (text as NSString).size(withAttributes: [.font: tagFont()])
        let margin = image(for: item) != nil ? Metric.cellButtonCenterToBorderMargin * 2
                                             : Metric.cellButtonCenterToBorderMargin
        let width = Float(ceil(size.width) + margin)
        let limitWidth = Float(max(0, (collectionView?.bounds.width ?? 0) - Metric.collectionViewToLeftMargin
                                      - Metric.collectionViewToRightMargin))
        return CGFloat(min(width, limitWidth))
    }
}
