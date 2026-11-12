//
//  CYLTagAppearance.h
//  CollectionViewClassifyMenu
//
//  The box and text of a tag in one state. Every tag is treated like a
//  CYLBadgeView (CYLTabBarController), so the properties and their defaults
//  follow CYLBadgeAppearance: background, text color, font, corner radius
//  (0 = automatic capsule), border and margin.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * A corner radius that keeps the corners square (0 means a capsule), as android-tagview's radius 0.
 */
FOUNDATION_EXTERN const CGFloat CYLTagCornerRadiusSquare;

@interface CYLTagAppearance : NSObject <NSCopying>

/*!
 * Background color. White by default; set nil to restore it.
 */
@property (null_resettable, nonatomic, strong) UIColor *backgroundColor;
/*!
 * Title color. Dark gray by default; set nil to restore it.
 */
@property (null_resettable, nonatomic, strong) UIColor *textColor;
/*!
 * Title font. `[UIFont systemFontOfSize:14]` by default; set nil to restore it.
 * Scaled for Dynamic Type when the style's adjustsFontForContentSizeCategory is YES.
 */
@property (null_resettable, nonatomic, strong) UIFont *font;
/*!
 * Tint of template icons (like `UITabBarItemStateAppearance.iconColor`).
 * nil (the default) uses textColor. Icons rendered as original keep their colors.
 */
@property (nullable, nonatomic, strong) UIColor *iconColor;
/*!
 * Corner radius. 0 means automatic: half the tag height (a capsule), as for
 * CYLBadgeAppearance. Negative or non-finite values are treated as 0.
 */
@property (nonatomic, assign) CGFloat cornerRadius;
/*!
 * Border color, nil (no border) by default. Drawn only when borderWidth > 0.
 */
@property (nullable, nonatomic, strong) UIColor *borderColor;
/*!
 * Border width, 0 by default. Negative or non-finite values are treated as 0.
 */
@property (nonatomic, assign) CGFloat borderWidth;
/*!
 * Horizontal space between the border and the content, 10 by default: the left and right of `contentInsets`.
 * Setting it sets both; reading it gives the larger. Negative or non-finite values are treated as 0.
 */
@property (nonatomic, assign) CGFloat margin;
/*!
 * Space between the border and the content on each side, {5, 10, 5, 10} by default (as android-tagview's
 * textPaddingTop / Left / Bottom / Right). The left and right widen the tag; the top and bottom make it taller
 * than the style's itemHeight only when the font needs it. Negative or non-finite values are treated as 0.
 */
@property (nonatomic, assign) UIEdgeInsets contentInsets;
/*!
 * Drawn behind the content, stretched to the tag (as android-tagview's Tag.background); use a resizable image
 * for caps. nil (the default) for none: the background color only.
 */
@property (nullable, nonatomic, strong) UIImage *backgroundImage;

/*!
 * Restores every property to its built-in default.
 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END
