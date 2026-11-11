//
//  CYLTagFoldButton.h
//  CollectionViewClassifyMenu
//
//  Draws a CYLMenuFoldControl: a CYLTagButton (the tag view) without a border or background, with the
//  title and the chevron after it. Expanded, it shows what the control shows expanded (only the icon,
//  turned 180°, or the collapse title). CYLTagListView puts it below the section or in its header.
//

#import "CYLTagButton.h"
#import "CYLMenuFoldControl.h"
#import "CYLTagListAccessibility.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLTagFoldButton : CYLTagButton

@property (nonatomic, copy, readonly, nullable) CYLMenuFoldControl *foldControl;
@property (nonatomic, assign, readonly, getter=isExpanded) BOOL expanded;

/// Shows `foldControl` in `color` (its own color wins) for the expanded or collapsed state; the icon
/// turns with an animation when `animated` (not with Reduce Motion).
- (void)applyFoldControl:(CYLMenuFoldControl *)foldControl
                   color:(nullable UIColor *)color
                expanded:(BOOL)expanded
                animated:(BOOL)animated;

/// The size the control needs in that state.
+ (CGSize)sizeForFoldControl:(CYLMenuFoldControl *)foldControl
                    expanded:(BOOL)expanded
             traitCollection:(nullable UITraitCollection *)traitCollection;

@end

NS_ASSUME_NONNULL_END
