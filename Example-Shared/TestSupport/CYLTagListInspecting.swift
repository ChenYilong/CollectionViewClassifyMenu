//
//  CYLTagListInspecting.swift
//  Example-Shared/TestSupport
//
//  Shared by the test targets of Example/ and Example-Swift/: reads and drives the collection view of a tag list.
//

import UIKit
import XCTest
import CollectionViewClassifyMenu

/**
 * Something that shows its tags in a collection view the tests can read and tap.
 *
 * The extension turns that one collection view into every query the tests need (cells, tag buttons, headers,
 * footers, fold controls, layout frames) and into taps made as the user makes them, through the collection view's
 * delegate. Tests talk to this protocol, never to the core's private views.
 */
protocol CYLTagListInspecting {
    /**
     * The collection view that shows the tags.
     */
    var collectionView: UICollectionView { get }
}

/**
 * The only place where tests reach private views of the core, by key-value coding: the collection view of a
 * `CYLTagListView` (or of a `CYLClassifyMenuViewController`) and the subviews of its section headers and footers.
 * When the core renames one of them, only this type changes.
 */
struct CYLTagListProbe: CYLTagListInspecting {

    /**
     * The view or view controller whose `collectionView` key holds the tags.
     */
    let owner: NSObject

    init(_ owner: NSObject) {
        self.owner = owner
    }

    var collectionView: UICollectionView {
        guard let collectionView = owner.value(forKey: "collectionView") as? UICollectionView else {
            preconditionFailure("\(type(of: owner)) has no collection view")
        }
        return collectionView
    }

    /**
     * A private subview of a header or footer: `foldButton`, `titleLabel` or `iconView`.
     */
    static func subview<View: UIView>(_ key: String, of container: UIView?) -> View? {
        container?.value(forKey: key) as? View
    }
}

extension CYLTagListInspecting {

    // MARK: Taps

    /**
     * A tap on an item, as the collection view reports it.
     */
    func tap(_ indexPath: IndexPath) {
        collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }

    /**
     * A tap on item `item` of section `section`.
     */
    func tap(item: Int, section: Int) {
        tap(IndexPath(item: item, section: section))
    }

    // MARK: Items

    /**
     * Lays the collection view out, so that the queries below see the current state.
     */
    func layOut() {
        collectionView.layoutIfNeeded()
    }

    func numberOfItems(inSection section: Int) -> Int {
        collectionView.numberOfItems(inSection: section)
    }

    func cell(at indexPath: IndexPath) -> UICollectionViewCell? {
        collectionView.cellForItem(at: indexPath)
    }

    /**
     * The tag view of a visible item (`CYLTagListCell.button`).
     */
    func tagButton(at indexPath: IndexPath) -> CYLTagButton? {
        (cell(at: indexPath) as? CYLTagListCell)?.button
    }

    /**
     * The item's frame in the layout, also for an item that is not visible.
     */
    func itemFrame(at indexPath: IndexPath) -> CGRect? {
        collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath)?.frame
    }

    /**
     * Scrolls the collection view to its end.
     */
    func scrollToBottom() {
        let offset = max(0, collectionView.contentSize.height - collectionView.bounds.height)
        collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
        collectionView.layoutIfNeeded()
    }

    // MARK: Section headers and footers

    func header(inSection section: Int) -> UICollectionReusableView? {
        collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader,
                                         at: IndexPath(item: 0, section: section))
    }

    func footer(inSection section: Int) -> UICollectionReusableView? {
        collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter,
                                         at: IndexPath(item: 0, section: section))
    }

    /**
     * The fold control (`CYLTagFoldButton`) of a section header.
     */
    func headerFoldButton(inSection section: Int) -> CYLTagButton? {
        CYLTagListProbe.subview("foldButton", of: header(inSection: section))
    }

    /**
     * The fold control (`CYLTagFoldButton`) of a section footer.
     */
    func footerFoldButton(inSection section: Int) -> CYLTagButton? {
        CYLTagListProbe.subview("foldButton", of: footer(inSection: section))
    }

    func headerTitleLabel(inSection section: Int) -> UILabel? {
        CYLTagListProbe.subview("titleLabel", of: header(inSection: section))
    }

    func headerIconView(inSection section: Int) -> UIImageView? {
        CYLTagListProbe.subview("iconView", of: header(inSection: section))
    }

    // MARK: Assertions

    /**
     * Fails when an item ends after `trailingInset` from the right edge or overlaps the item before it.
     */
    func assertItemsFit(trailingInset: CGFloat, file: StaticString = #filePath, line: UInt = #line) {
        layOut()
        let maxX = collectionView.bounds.width - trailingInset + 0.5
        for section in 0..<collectionView.numberOfSections {
            var previous: CGRect?
            for item in 0..<numberOfItems(inSection: section) {
                let frame = itemFrame(at: IndexPath(item: item, section: section))
                XCTAssertNotNil(frame, file: file, line: line)
                guard let frame else { continue }
                XCTAssertLessThanOrEqual(frame.maxX, maxX, file: file, line: line)
                if let previous {
                    XCTAssertFalse(previous.intersects(frame), file: file, line: line)
                }
                previous = frame
            }
        }
    }
}

extension CYLTagListView {

    /**
     * Reads and taps this list's tags in tests.
     */
    var probe: CYLTagListProbe {
        CYLTagListProbe(self)
    }

    /**
     * Fails when a tag leaves the section insets or overlaps another tag.
     */
    func assertItemsFit(file: StaticString = #filePath, line: UInt = #line) {
        probe.assertItemsFit(trailingInset: style.sectionInsets.right, file: file, line: line)
    }
}
