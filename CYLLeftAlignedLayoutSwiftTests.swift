//
//  CYLLeftAlignedLayoutSwiftTests.swift
//  CollectionViewClassifyMenuTests
//
//  Upstream issue #21 of mokagio/UICollectionViewLeftAlignedLayout ("a Swift port"): the layout is used from Swift
//  with non-optional types. The layout's own tests are in CYLCollectionViewLeftAlignedLayoutTests.m.
//

import XCTest
import CollectionViewClassifyMenu

private final class CYLSwiftLayoutSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateLeftAlignedLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 12 }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 60 + CGFloat(indexPath.item % 4) * 25, height: 30)
    }
}

/**
 * Counts the lookups of item attributes made from outside the layout.
 */
private final class CYLCountingLayout: CYLCollectionViewLeftAlignedLayout {
    var itemLookups = 0

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        itemLookups += 1
        return super.layoutAttributesForItem(at: indexPath)
    }
}

private final class CYLLargeLayoutSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    let count: Int

    init(count: Int) {
        self.count = count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 40 + CGFloat(indexPath.item % 7) * 30, height: 30)
    }
}

final class CYLLeftAlignedLayoutSwiftTests: XCTestCase {

    /**
     * Moved from CYLCollectionViewClassifyMenuLayoutTests.m (Objective-C cannot subclass the Swift layout): one
     * lookup per item, so finding an item's row never asks the layout for the previous items again.
     */
    func testLargeTagSetDoesNotRecursivelyRecomputePreviousItems() {
        let layout = CYLCountingLayout()
        let source = CYLLargeLayoutSource(count: 1200)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 240), collectionViewLayout: layout)
        collectionView.dataSource = source
        collectionView.delegate = source
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        layout.itemLookups = 0
        for item in 0..<source.count {
            XCTAssertNotNil(layout.layoutAttributesForItem(at: IndexPath(item: item, section: 0)))
        }
        XCTAssertEqual(layout.itemLookups, source.count)
        let frames = (0..<source.count).compactMap { layout.layoutAttributesForItem(at: IndexPath(item: $0, section: 0))?.frame }
        for (index, frame) in frames.enumerated().dropFirst() {
            XCTAssertFalse(frame.intersects(frames[index - 1]), "Items \(index - 1) and \(index) overlap")
        }
    }

    func testLayoutIsUsableFromSwift() {
        let layout = CYLCollectionViewLeftAlignedLayout()
        layout.rowAlignment = .leading
        layout.sectionInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        layout.minimumInteritemSpacing = 6
        let source = CYLSwiftLayoutSource()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 400), collectionViewLayout: layout)
        collectionView.dataSource = source
        collectionView.delegate = source
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.layoutIfNeeded()
        let frames: [CGRect] = (0..<12).compactMap { layout.layoutAttributesForItem(at: IndexPath(item: $0, section: 0))?.frame }
        XCTAssertEqual(frames.count, 12)
        XCTAssertEqual(frames.first?.minX ?? -1, 12, accuracy: 0.01)
        for (index, frame) in frames.enumerated() {
            XCTAssertLessThanOrEqual(frame.maxX, 320 - 12 + 0.01)
            if index > 0, abs(frames[index - 1].midY - frame.midY) < 1 {
                XCTAssertEqual(frame.minX, frames[index - 1].maxX + 6, accuracy: 0.01)
            } else {
                XCTAssertEqual(frame.minX, 12, accuracy: 0.01)
            }
        }
        let elements: [UICollectionViewLayoutAttributes] = layout.layoutAttributesForElements(in: collectionView.bounds) ?? []
        XCTAssertFalse(elements.isEmpty)
    }
}
