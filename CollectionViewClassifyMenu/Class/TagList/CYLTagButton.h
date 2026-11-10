//
//  CYLTagButton.h
//  CollectionViewClassifyMenu
//
//  One tag: CYLFlatDesignTabBarButton (CYLTabBarController) laid out
//  horizontally, the icon before the title, in a box styled like a CYLBadgeView.
//  CYLTagListView puts one in every cell; it can also be used on its own.
//

#import <UIKit/UIKit.h>
#import "CYLMenuStyle.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLTagButton : UIControl

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, strong, nullable) UIImage *image;
/// Shown while selected; nil keeps `image` (as CYLFlatDesignTabBarItem.selectedImage).
@property (nonatomic, strong, nullable) UIImage *selectedImage;
/// The style the tag is drawn with. Set it again after changing it.
@property (nonatomic, copy, null_resettable) CYLMenuStyle *style;

/// Width a tag needs for its content in every state (so that selecting it does not
/// resize it), before any limit on the available width.
+ (CGFloat)widthForTitle:(nullable NSString *)title
                   image:(nullable UIImage *)image
                   style:(CYLMenuStyle *)style
         traitCollection:(nullable UITraitCollection *)traitCollection;

/// Tag height: style.itemHeight, or more for large fonts.
+ (CGFloat)heightForStyle:(CYLMenuStyle *)style traitCollection:(nullable UITraitCollection *)traitCollection;

@end

NS_ASSUME_NONNULL_END
