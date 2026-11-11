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

@interface CYLTagAppearance : NSObject <NSCopying>

/// Background color. White by default; set nil to restore it.
@property (null_resettable, nonatomic, strong) UIColor *backgroundColor;
/// Title color. Dark gray by default; set nil to restore it.
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
/// Border color, nil (no border) by default. Drawn only when borderWidth > 0.
@property (nullable, nonatomic, strong) UIColor *borderColor;
/// Border width, 0 by default. Negative or non-finite values are treated as 0.
@property (nonatomic, assign) CGFloat borderWidth;
/*!
 * Horizontal space between the border and the content, 10 by default.
 * Negative or non-finite values are treated as 0.
 */
@property (nonatomic, assign) CGFloat margin;

/// Restores every property to its built-in default.
- (void)reset;

@end

NS_ASSUME_NONNULL_END
