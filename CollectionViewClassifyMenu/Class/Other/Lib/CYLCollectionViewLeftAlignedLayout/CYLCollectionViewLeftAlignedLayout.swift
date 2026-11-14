// Copyright (c) 2014 Giovanni Lodi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).

import UIKit

/**
 * Just a convenience protocol to keep things consistent: someone could find it confusing for a delegate object to
 * conform to `UICollectionViewDelegateFlowLayout` while using `CYLCollectionViewLeftAlignedLayout`.
 */
@objc(UICollectionViewDelegateLeftAlignedLayout)
public protocol UICollectionViewDelegateLeftAlignedLayout: UICollectionViewDelegateFlowLayout {}

/**
 * A simple `UICollectionViewFlowLayout` that aligns the cells of each row to the leading edge (or centers them, or
 * aligns them to the trailing edge) rather than justify them. Based on
 * http://stackoverflow.com/questions/13017257/how-do-you-determine-spacing-between-cells-in-uicollectionview-flowlayout
 */
@objc(CYLCollectionViewLeftAlignedLayout)
open class CYLCollectionViewLeftAlignedLayout: UICollectionViewFlowLayout {

    /**
     * Leading (the default), centered or trailing. Rows are aligned only while `scrollDirection` is vertical; a
     * horizontal layout keeps the flow layout's frames.
     */
    @objc open var rowAlignment: CYLTagRowAlignment = .leading

    // Upstream fixes merged here (mokagio/UICollectionViewLeftAlignedLayout, see docs/CYLCollectionViewLeftAlignedLayout.md):
    // PR #37 / issues #7, #30: rows are aligned only when the layout scrolls vertically.
    // PR #31, #20 / issues #26, #27, #33: rows are found by their vertical centers, with a tolerance, so fractional
    //   origins (3x screens) and full-width cells never join the previous row; frames stay inside the section insets.
    // PR #25 / issues #4, #9, #11: every attribute returned is a copy.

    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard alignsRows else {
            return super.layoutAttributesForElements(in: rect)?.map(Self.copied)
        }
        var queryRect = rect
        queryRect.origin.x = 0
        queryRect.size.width = max(collectionView?.bounds.width ?? 0, collectionViewContentSize.width)
        return super.layoutAttributesForElements(in: queryRect)?.compactMap { original in
            let attributes = original.representedElementCategory == .cell
                ? layoutAttributesForItem(at: original.indexPath) : Self.copied(original)
            return attributes.flatMap { $0.frame.intersects(rect) ? $0 : nil }
        }
    }

    /**
     * Computed from the flow layout's own attributes on every call, with no cache: a cache filled by an earlier
     * `prepare()` (for example while the view still had no size) could give cells stale, empty frames (issue #8).
     */
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath).map(Self.copied) else {
            return nil
        }
        guard alignsRows else {
            return attributes
        }
        let section = indexPath.section
        let inset = sectionInset(forSection: section)
        let spacing = minimumInteritemSpacing(forSection: section)
        let width = max(0, (collectionView?.bounds.width ?? 0) - inset.left - inset.right)
        var frame = attributes.frame
        frame.size.width = min(frame.width, width)
        // The items before this one on its row.
        var x = inset.left
        var item = indexPath.item - 1
        while item >= 0, let previous = super.layoutAttributesForItem(at: IndexPath(item: item, section: section)),
              Self.framesShareRow(previous.frame, frame) {
            x += min(previous.frame.width, width) + spacing
            item -= 1
        }
        if rowAlignment != .leading {
            // Centered or trailing: the row's width, with the items after this one.
            var rowWidth = x + frame.width - inset.left
            let count = collectionView?.numberOfItems(inSection: section) ?? 0
            item = indexPath.item + 1
            while item < count, let next = super.layoutAttributesForItem(at: IndexPath(item: item, section: section)),
                  Self.framesShareRow(next.frame, frame) {
                rowWidth += spacing + min(next.frame.width, width)
                item += 1
            }
            let free = max(0, width - rowWidth)
            x += rowAlignment == .center ? floor(free / 2) : free
        }
        // Never past the trailing inset (PR #20, issue #33), never before the leading one.
        frame.origin.x = max(inset.left, min(x, inset.left + width - frame.width))
        attributes.frame = frame
        return attributes
    }

    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        newBounds.width != collectionView?.bounds.width || super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }

    // MARK: - Private

    private var alignsRows: Bool {
        scrollDirection == .vertical
    }

    private var flowDelegate: UICollectionViewDelegateFlowLayout? {
        collectionView?.delegate as? UICollectionViewDelegateFlowLayout
    }

    private func minimumInteritemSpacing(forSection section: Int) -> CGFloat {
        guard let collectionView,
              let spacing = flowDelegate?.collectionView?(collectionView, layout: self,
                                                          minimumInteritemSpacingForSectionAt: section) else {
            return minimumInteritemSpacing
        }
        return spacing
    }

    private func sectionInset(forSection section: Int) -> UIEdgeInsets {
        guard let collectionView,
              let inset = flowDelegate?.collectionView?(collectionView, layout: self, insetForSectionAt: section) else {
            return sectionInset
        }
        return inset
    }

    /**
     * Whether two frames of the flow layout are on the same row: the flow layout centers the items of a row
     * vertically, so their centers match; items of other rows are at least half the smaller height away.
     */
    private static func framesShareRow(_ a: CGRect, _ b: CGRect) -> Bool {
        let tolerance = max(0.5, min(a.height, b.height) / 2 - 0.5)
        return abs(a.midY - b.midY) < tolerance
    }

    private static func copied(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let copy = attributes.copy() as? UICollectionViewLayoutAttributes else {
            preconditionFailure("UICollectionViewLayoutAttributes copies itself")
        }
        return copy
    }
}
