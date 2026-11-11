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
/*!
 * Animated icon file (Lottie .json, .pag, .riv, .gif…). The view comes from CYLTabBarController's
 * animation engine (`CYLTabBarItemAnimationFactory`), found at runtime as CYLTabBarController's own
 * Core does: add the library's subspec to the app, e.g. `pod 'CYLTabBarController/Lottie'`. Without
 * it, or when the file cannot be loaded, `image` is shown.
 */
@property (nonatomic, strong, nullable) NSURL *animationURL;
/// The frame (0...1) of the animated icon shown while not selected. Default 0, the first frame.
@property (nonatomic, assign) CGFloat animationRestingProgress;
/// The animation view in the icon slot, or nil.
@property (nonatomic, strong, readonly, nullable) UIView *animationView;
/// Its `CYLTabBarItemAnimationPlayer` (play, showLastFrame, stop), whatever the library, or nil.
@property (nonatomic, strong, readonly, nullable) id animationPlayer;
/// Plays the animated icon from the start, as a tab icon plays when the tab is tapped.
- (void)playAnimation;
/// Whether CYLTabBarController's animation engine is linked into the app.
+ (BOOL)isAnimationEngineAvailable;

/// The style the tag is drawn with. Set it again after changing it.
@property (nonatomic, copy, null_resettable) CYLMenuStyle *style;

/*!
 * Width a tag needs for its content in every state (so that selecting it does not
 * resize it), before any limit on the available width.
 */
+ (CGFloat)widthForTitle:(nullable NSString *)title
                   image:(nullable UIImage *)image
                   style:(CYLMenuStyle *)style
         traitCollection:(nullable UITraitCollection *)traitCollection;

/// The same for an icon of `iconSize` (CGSizeZero for none), e.g. an animated icon.
+ (CGFloat)widthForTitle:(nullable NSString *)title
                iconSize:(CGSize)iconSize
                   style:(CYLMenuStyle *)style
         traitCollection:(nullable UITraitCollection *)traitCollection;
/// Size of the icon slot for an image, or for an animated icon when `animated` and the engine is linked.
+ (CGSize)iconSizeForImage:(nullable UIImage *)image animated:(BOOL)animated style:(CYLMenuStyle *)style;

/// Tag height: style.itemHeight, or more for large fonts.
+ (CGFloat)heightForStyle:(CYLMenuStyle *)style traitCollection:(nullable UITraitCollection *)traitCollection;

@end

NS_ASSUME_NONNULL_END
