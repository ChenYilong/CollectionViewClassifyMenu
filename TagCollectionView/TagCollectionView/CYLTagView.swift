//
//  CYLTagView.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * A list of tag groups, each with a header that opens or folds it. The groups come from `menuDataSource`
 * (`reloadMenuData()`); taps are reported to `menuDelegate`. Create it with `makeTagView()`, which loads
 * `CYLTagView.xib` from the component's bundle.
 */
@objc(CYLTagView)
open class CYLTagView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CYLTagHeaderCellDelegate {

    /**
     * The insets of every group's tags.
     */
    @objc public static let sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 10, right: 16)

    /**
     * The horizontal space between two tags of a row.
     */
    @objc public static let cellSpacing: CGFloat = 12

    private static let tagCellIdentifier = "CellIdentifier"
    private static let headerCellIdentifier = "HeaderViewCellIdentifier"

    @IBOutlet private weak var collectionView: UICollectionView!

    private var lastCollectionWidth: CGFloat = 0

    private var showsHeader = true

    /**
     * Whether each group shows its header (default true).
     */
    @objc(showHeader)
    open var isShowHeader: Bool {
        @objc(isShowHeader) get {
            showsHeader
        }
        @objc(setShowHeader:) set {
            showsHeader = newValue
            collectionView?.collectionViewLayout.invalidateLayout()
            collectionView?.reloadData()
        }
    }

    /**
     * 总数据group / All data groups (`CYLTagGroup`).
     */
    @objc open var groups: NSMutableArray!

    /**
     * The groups and their tags.
     */
    @objc open weak var menuDataSource: CYLMenuDataSource!

    /**
     * Receives the taps on tags.
     */
    @objc open weak var menuDelegate: CYLMenuDelegate!

    /**
     * Loads the view from CYLTagView.xib (in the component's bundle). Swift: `CYLTagView.makeTagView()`; without the
     * name Swift would import this factory as `CYLTagView()`, which does not load the nib.
     */
    @discardableResult
    @objc(tagView)
    open class func makeTagView() -> Self! {
        UINib(nibName: "CYLTagView", bundle: CYLMenuResources.bundle())
            .instantiate(withOwner: nil, options: nil).first as? Self
    }

    /**
     * A view without a nib, with its own collection view (as Objective-C's `-init` → `-initWithFrame:CGRectZero`).
     */
    public convenience init() {
        self.init(frame: .zero)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(collectionView)
        self.collectionView = collectionView
        setup()
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    /**
     * Reads the groups and their tags from the data source again.
     */
    @objc open func reloadMenuData() {
        let groups = NSMutableArray()
        if let source = menuDataSource {
            for section in 0..<source.numberOfSectionsInMenu() {
                let group = CYLTagGroup()
                group.section = section
                group.groupName = source.menuTitle(forSection: section)
                var items: [CYLTagModel] = []
                for item in 0..<source.menuNumberOfItems(inSection: section) {
                    let title = source.menuTitleForItem(at: IndexPath(item: item, section: section))
                    if let model = CYLTagModel(title: title) {
                        model.updateSize(for: traitCollection)
                        items.append(model)
                    }
                }
                group.items = items
                groups.add(group)
            }
        }
        for case let group as CYLTagGroup in groups {
            group.width = collectionView.bounds.width
        }
        self.groups = groups
        collectionView.reloadData()
    }

    // MARK: - Layout

    open override func layoutSubviews() {
        super.layoutSubviews()
        let width = collectionView.bounds.width
        if width != lastCollectionWidth {
            lastCollectionWidth = width
            for case let group as CYLTagGroup in groups ?? [] {
                group.width = width
            }
            collectionView.reloadData()
        }
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            updateTagSizes()
        }
    }

    // MARK: - CYLTagHeaderCellDelegate

    open func tagHeaderCell(_ headerCell: CYLTagHeaderCell, didToggleGroupInSection section: Int) {
        collectionView.reloadData()
    }

    // MARK: - UICollectionViewDataSource

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        groups?.count ?? 0
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let group = group(at: section) else {
            return 0
        }
        return group.isOpened ? group.items.count : group.firstRowCellCount(forContentWidth: contentWidth(of: collectionView))
    }

    open func collectionView(_ collectionView: UICollectionView,
                             cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.tagCellIdentifier, for: indexPath)
        (cell as? CYLTagCell)?.model = model(at: indexPath)
        return cell
    }

    open func collectionView(_ collectionView: UICollectionView,
                             viewForSupplementaryElementOfKind kind: String,
                             at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind, withReuseIdentifier: Self.headerCellIdentifier, for: indexPath)
            if let header = view as? CYLTagHeaderCell {
                header.delegate = self
                header.group = group(at: indexPath.section)
            }
            return view
        }
        // Only headers have a size, so UIKit never asks for another kind.
        return UICollectionReusableView(frame: .zero)
    }

    // MARK: - UICollectionViewDelegate

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        menuDelegate?.menu?(self, didSelectItemAt: indexPath)
    }

    // MARK: - UICollectionViewDelegateFlowLayout (left-aligned layout)

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let model = model(at: indexPath) else {
            return .zero
        }
        return CGSize(width: min(max(0, CGFloat(model.width)), contentWidth(of: collectionView)),
                      height: CGFloat(model.height))
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Self.cellSpacing
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard isShowHeader, let group = group(at: section) else {
            return .zero
        }
        return CGSize(width: contentWidth(of: collectionView), height: group.height)
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             insetForSectionAt section: Int) -> UIEdgeInsets {
        Self.sectionInset
    }

    // MARK: - Private

    private func setup() {
        showsHeader = true
        setupCollectionView()
    }

    private func setupCollectionView() {
        collectionView.collectionViewLayout = CYLCollectionViewLeftAlignedLayout()
        collectionView.register(UINib(nibName: "CYLTagCell", bundle: CYLMenuResources.bundle()),
                                forCellWithReuseIdentifier: Self.tagCellIdentifier)
        collectionView.register(UINib(nibName: "CYLTagHeaderCell", bundle: CYLMenuResources.bundle()),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: Self.headerCellIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 35, left: 0, bottom: 0, right: 0)
        collectionView.allowsMultipleSelection = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    /**
     * Re-measures every tag for the current text size and reloads the layout.
     */
    private func updateTagSizes() {
        for case let group as CYLTagGroup in groups ?? [] {
            for model in group.items {
                model.updateSize(for: traitCollection)
            }
            group.invalidateRowCounts()
        }
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }

    private func group(at section: Int) -> CYLTagGroup? {
        guard let groups, section < groups.count else {
            return nil
        }
        return groups[section] as? CYLTagGroup
    }

    private func model(at indexPath: IndexPath) -> CYLTagModel? {
        guard let items = group(at: indexPath.section)?.items, items.indices.contains(indexPath.row) else {
            return nil
        }
        return items[indexPath.row]
    }

    private func contentWidth(of collectionView: UICollectionView) -> CGFloat {
        max(0, collectionView.bounds.width - Self.sectionInset.left - Self.sectionInset.right)
    }
}
