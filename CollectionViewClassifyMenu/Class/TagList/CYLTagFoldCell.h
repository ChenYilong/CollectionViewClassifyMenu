//
//  CYLTagFoldCell.h
//  CollectionViewClassifyMenu
//
//  The inline fold control of CYLTagListView (CYLMenuFoldControlPositionInline): a cell among the tags, after the
//  last visible tag while folded and after the last tag while expanded. A tap on it expands or collapses the section.
//

#import <UIKit/UIKit.h>
#import "CYLTagFoldButton.h"
#import "CYLTagListAccessibility.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * A collection view cell that shows a fold control like a tag (CYLTagFoldButton's inline look). It is one
 * accessibility element (identifier CYLTagListFoldControl), a button whose label says which section it changes.
 */
@interface CYLTagFoldCell : UICollectionViewCell

/*!
 * The control drawn in the cell; the collection view handles its taps.
 */
@property (nonatomic, strong, readonly) CYLTagFoldButton *foldButton;

/*!
 * Shows `foldControl` for the expanded or collapsed state, drawn like the tags of `itemStyle`.
 */
- (void)configureWithFoldControl:(CYLMenuFoldControl *)foldControl
                       itemStyle:(CYLMenuStyle *)itemStyle
                        expanded:(BOOL)expanded
                        animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
