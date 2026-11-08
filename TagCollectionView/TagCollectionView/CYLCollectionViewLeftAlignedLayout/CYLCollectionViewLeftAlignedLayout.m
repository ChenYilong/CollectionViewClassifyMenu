
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

@interface CYLCollectionViewLeftAlignedLayout ()
@property (nonatomic, strong) NSDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *alignedAttributes;
@end

#pragma mark -

@implementation CYLCollectionViewLeftAlignedLayout

#pragma mark - UICollectionViewLayout

- (void)prepareLayout {
    [super prepareLayout];
    NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *aligned = [NSMutableDictionary dictionary];
    NSInteger sectionCount = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < sectionCount; section++) {
        UIEdgeInsets inset = [self evaluatedSectionInsetForItemAtIndex:section];
        CGFloat spacing = [self evaluatedMinimumInteritemSpacingForItemAtIndex:section];
        CGFloat width = MAX(0, CGRectGetWidth(self.collectionView.bounds) - inset.left - inset.right);
        UICollectionViewLayoutAttributes *previous = nil;
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger item = 0; item < itemCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *attributes = [[super layoutAttributesForItemAtIndexPath:indexPath] copy];
            if (!attributes) {
                previous = nil;
                continue;
            }
            CGRect frame = attributes.frame;
            CGRect row = CGRectMake(inset.left, frame.origin.y, width, frame.size.height);
            frame.origin.x = previous && CGRectIntersectsRect(previous.frame, row)
                ? CGRectGetMaxX(previous.frame) + spacing : inset.left;
            attributes.frame = frame;
            aligned[indexPath] = attributes;
            previous = attributes;
        }
    }
    self.alignedAttributes = aligned;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    CGRect queryRect = rect;
    queryRect.origin.x = 0;
    queryRect.size.width = MAX(CGRectGetWidth(self.collectionView.bounds), self.collectionViewContentSize.width);
    NSMutableArray *result = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *original in [super layoutAttributesForElementsInRect:queryRect]) {
        UICollectionViewLayoutAttributes *attributes = original.representedElementKind
            ? [original copy] : [self layoutAttributesForItemAtIndexPath:original.indexPath];
        if (attributes && CGRectIntersectsRect(attributes.frame, rect)) {
            [result addObject:attributes];
        }
    }
    return result;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = self.alignedAttributes[indexPath];
    return attributes ? [attributes copy] : [[super layoutAttributesForItemAtIndexPath:indexPath] copy];
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
