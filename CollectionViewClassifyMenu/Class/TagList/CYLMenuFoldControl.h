//
//  CYLMenuFoldControl.h
//  CollectionViewClassifyMenu
//
//  The fold control of CYLTagListView ("更多 ⌄"), given when the view is created: where it is
//  (below the section as in a shopping app's review filter, or at the top trailing/leading edge of the
//  section header as in the original classify menu) and what it shows (icon and title, title only,
//  icon only). Expanded, a control with an icon keeps only the icon, turned 180°; a title-only control
//  shows its collapse title. It is drawn by CYLTagFoldButton, a borderless CYLTagButton.
//
//      CYLTagListView *filter = [[CYLTagListView alloc] initWithFoldControl:
//          [CYLMenuFoldControl foldControlWithPosition:CYLMenuFoldControlPositionBottom
//                                              content:CYLMenuFoldControlContentIcon]];
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Where the fold control of a foldable section is.
typedef NS_ENUM(NSInteger, CYLMenuFoldControlPosition) {
    /// No fold control: every row is shown.
    CYLMenuFoldControlPositionNone = 0,
    /// Centered below the section, like a shopping app's review filter.
    CYLMenuFoldControlPositionBottom,
    /// At the trailing edge of the section header, like the original classify menu.
    CYLMenuFoldControlPositionTopTrailing,
    /// At the leading edge of the section header, before the section title.
    CYLMenuFoldControlPositionTopLeading,
};

/// What the fold control shows while the section is collapsed.
typedef NS_ENUM(NSInteger, CYLMenuFoldControlContent) {
    /// "更多 ⌄"; expanded, only the icon, turned.
    CYLMenuFoldControlContentIconAndTitle = 0,
    /// "更多"; expanded, the collapse title ("收起").
    CYLMenuFoldControlContentTitle,
    /// "⌄"; expanded, the same icon, turned.
    CYLMenuFoldControlContentIcon,
};

@interface CYLMenuFoldControl : NSObject <NSCopying>

+ (instancetype)foldControlWithPosition:(CYLMenuFoldControlPosition)position content:(CYLMenuFoldControlContent)content;
/// No fold control.
+ (instancetype)noFoldControl;

@property (nonatomic, assign) CYLMenuFoldControlPosition position;
@property (nonatomic, assign) CYLMenuFoldControlContent content;
/// Shown while collapsed (with a title). Default: the localized "更多" (CYLMenuExpand).
@property (nonatomic, copy, null_resettable) NSString *title;
/// Shown while expanded by a title-only control. Default: the localized "收起" (CYLMenuCollapse).
@property (nonatomic, copy, null_resettable) NSString *collapseTitle;
/// The icon, pointing down while collapsed. Default: the core's chevron (cyl_fold_chevron), drawn in `color`.
@property (nonatomic, strong, null_resettable) UIImage *image;
/// YES while `image` is the default chevron (no image was set).
@property (nonatomic, assign, readonly) BOOL usesDefaultImage;
/// Title and icon color. Nil (the default) uses CYLMenuStyle.foldControlColor.
@property (nonatomic, strong, nullable) UIColor *color;
/// Nil (the default): the footnote text style, scaled with Dynamic Type.
@property (nonatomic, strong, nullable) UIFont *font;
/// The icon turns 180° when expanded. Default YES.
@property (nonatomic, assign) BOOL rotatesImageWhenExpanded;

/// Whether the control shows its icon and its title in the expanded or collapsed state.
- (BOOL)showsImageWhenExpanded:(BOOL)expanded;
- (BOOL)showsTitleWhenExpanded:(BOOL)expanded;
/// The title shown in that state, or nil.
- (nullable NSString *)titleWhenExpanded:(BOOL)expanded;

@end

NS_ASSUME_NONNULL_END
