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

final class CYLLeftAlignedLayoutSwiftTests: XCTestCase {

    func testLayoutIsUsableFromSwift() {
        let layout = CYLCollectionViewLeftAlignedLayout()
        layout.rowAlignment = 0
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
