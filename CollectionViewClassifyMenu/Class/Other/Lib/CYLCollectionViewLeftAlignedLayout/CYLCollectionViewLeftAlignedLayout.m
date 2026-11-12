
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

#import "CYLCollectionViewLeftAlignedLayout.h"

#pragma mark -

@implementation CYLCollectionViewLeftAlignedLayout

#pragma mark - UICollectionViewLayout

// Upstream fixes merged here (mokagio/UICollectionViewLeftAlignedLayout, see docs/CYLCollectionViewLeftAlignedLayout.md):
// PR #37 / issues #7, #30: rows are aligned only when the layout scrolls vertically.
// PR #31, #20 / issues #26, #27, #33: rows are found by their vertical centers, with a tolerance, so fractional
//   origins (3x screens) and full-width cells never join the previous row; frames stay inside the section insets.
// PR #25 / issues #4, #9, #11: every attribute returned is a copy (iOS 15+, so always).

- (BOOL)cyl_alignsRows {
    return self.scrollDirection == UICollectionViewScrollDirectionVertical;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    if (![self cyl_alignsRows]) {
        NSMutableArray *copies = [NSMutableArray array];
        for (UICollectionViewLayoutAttributes *original in [super layoutAttributesForElementsInRect:rect]) {
            [copies addObject:[original copy]];
        }
        return copies;
    }
    CGRect queryRect = rect;
    queryRect.origin.x = 0;
    queryRect.size.width = MAX(CGRectGetWidth(self.collectionView.bounds), self.collectionViewContentSize.width);
    NSMutableArray *result = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *original in [super layoutAttributesForElementsInRect:queryRect]) {
        UICollectionViewLayoutAttributes *attributes = original.representedElementCategory == UICollectionElementCategoryCell
            ? [self layoutAttributesForItemAtIndexPath:original.indexPath] : [original copy];
        if (attributes && CGRectIntersectsRect(attributes.frame, rect)) {
            [result addObject:attributes];
        }
    }
    return result;
}

/// Whether two frames of the flow layout are on the same row: the flow layout centers the items of a row vertically,
/// so their centers match; items of other rows are at least half the smaller height away.
static BOOL CYLFramesShareRow(CGRect a, CGRect b) {
    CGFloat tolerance = MAX(0.5, MIN(CGRectGetHeight(a), CGRectGetHeight(b)) / 2 - 0.5);
    return fabs(CGRectGetMidY(a) - CGRectGetMidY(b)) < tolerance;
}

/// Computed from the flow layout's own attributes on every call, with no cache: a cache filled by an earlier
/// prepareLayout (for example while the view still had no size) could give cells stale, empty frames (issue #8).
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [[super layoutAttributesForItemAtIndexPath:indexPath] copy];
    if (!attributes || ![self cyl_alignsRows]) {
        return attributes;
    }
    NSInteger section = indexPath.section;
    UIEdgeInsets inset = [self evaluatedSectionInsetForItemAtIndex:section];
    CGFloat spacing = [self evaluatedMinimumInteritemSpacingForItemAtIndex:section];
    CGFloat width = MAX(0, CGRectGetWidth(self.collectionView.bounds) - inset.left - inset.right);
    CGRect frame = attributes.frame;
    frame.size.width = MIN(CGRectGetWidth(frame), width);
    // The items before this one on its row.
    CGFloat x = inset.left;
    for (NSInteger item = indexPath.item - 1; item >= 0; item--) {
        UICollectionViewLayoutAttributes *previous = [super layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
        if (!previous || !CYLFramesShareRow(previous.frame, frame)) {
            break;
        }
        x += MIN(CGRectGetWidth(previous.frame), width) + spacing;
    }
    if (self.rowAlignment != 0) {
        // Centered or trailing: the row's width, with the items after this one.
        CGFloat rowWidth = x + CGRectGetWidth(frame) - inset.left;
        NSInteger count = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger item = indexPath.item + 1; item < count; item++) {
            UICollectionViewLayoutAttributes *next = [super layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
            if (!next || !CYLFramesShareRow(next.frame, frame)) {
                break;
            }
            rowWidth += spacing + MIN(CGRectGetWidth(next.frame), width);
        }
        CGFloat free = MAX(0, width - rowWidth);
        x += self.rowAlignment == 1 ? floor(free / 2) : free;
    }
    // Never past the trailing inset (PR #20, issue #33), never before the leading one.
    frame.origin.x = MAX(inset.left, MIN(x, inset.left + width - CGRectGetWidth(frame)));
    attributes.frame = frame;
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return CGRectGetWidth(newBounds) != CGRectGetWidth(self.collectionView.bounds)
        || [super shouldInvalidateLayoutForBoundsChange:newBounds];
}

- (CGFloat)evaluatedMinimumInteritemSpacingForItemAtIndex:(NSInteger)index
{
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        id<UICollectionViewDelegateLeftAlignedLayout> delegate = (id<UICollectionViewDelegateLeftAlignedLayout>)self.collectionView.delegate;

        return [delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:index];
    } else {
        return self.minimumInteritemSpacing;
    }
}

- (UIEdgeInsets)evaluatedSectionInsetForItemAtIndex:(NSInteger)index
{
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        id<UICollectionViewDelegateLeftAlignedLayout> delegate = (id<UICollectionViewDelegateLeftAlignedLayout>)self.collectionView.delegate;

        return [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:index];
    } else {
        return self.sectionInset;
    }
}

@end
