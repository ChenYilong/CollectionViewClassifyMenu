//
//  CYLMenuStyle.h
//  CollectionViewClassifyMenu
//
//  Appearance of CYLTagListView. Copy a preset and change what you need.
//
//  Each tag is drawn like a CYLFlatDesignTabBarItem of CYLTabBarController, laid
//  out horizontally (icon, then title) instead of vertically: per-state title
//  text attributes and icon colors, image/title position adjustments, image
//  insets and layoutCentered for icon-only or title-only tags. Its box (background,
//  border, corner radius, margin) is configured like a CYLBadgeView, through one
//  CYLTagAppearance per state.
//

#import <UIKit/UIKit.h>
#import "CYLTagAppearance.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLMenuStyle : NSObject <NSCopying>

/// Gray bordered tags, green selection. Used when no style is set.
+ (instancetype)defaultStyle;

#pragma mark Tag box and text, per state (CYLBadgeAppearance)

/// Normal tags. The appearance objects belong to the style: change their properties.
@property (nonatomic, strong, readonly) CYLTagAppearance *normalAppearance;
@property (nonatomic, strong, readonly) CYLTagAppearance *selectedAppearance;
@property (nonatomic, strong, readonly) CYLTagAppearance *disabledAppearance;

/// The appearance for UIControlStateNormal, UIControlStateSelected or
/// UIControlStateDisabled (disabled wins over selected); others give normal.
- (CYLTagAppearance *)appearanceForState:(UIControlState)state;

#pragma mark Title and icon (CYLFlatDesignTabBarItem)

/// Like `-[UITabBarItem setTitleTextAttributes:forState:]`: NSFontAttributeName and
/// NSForegroundColorAttributeName update the state's appearance font and textColor.
- (void)setTitleTextAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes forState:(UIControlState)state;
/// The state's font and text color as text attributes.
- (NSDictionary<NSAttributedStringKey, id> *)titleTextAttributesForState:(UIControlState)state;

/// Tint of template icons in a state (like `UITabBarItemStateAppearance.iconColor`);
/// nil uses the state's textColor.
- (void)setIconColor:(nullable UIColor *)iconColor forState:(UIControlState)state;
/// The effective icon tint for a state.
- (UIColor *)iconColorForState:(UIControlState)state;

/// Space between the icon and the title, 4 by default.
@property (nonatomic, assign) CGFloat imageTitleSpacing;
/// Icon size. CGSizeZero uses the image's own size. 14 x 14 by default.
@property (nonatomic, assign) CGSize imageSize;
/// Shrinks the icon from its slot without moving it, as `CYLFlatDesignTabBarItem.imageInsets`.
@property (nonatomic, assign) UIEdgeInsets imageInsets;
/// Moves the title from its computed position.
@property (nonatomic, assign) UIOffset titlePositionAdjustment;
/// Moves the icon from its computed position.
@property (nonatomic, assign) UIOffset imagePositionAdjustment;
/// For a tag with only an icon or only a title: YES (the default) centers it;
/// NO keeps it where it would be with both, the title after an empty icon slot,
/// the icon at the leading margin (as CYLFlatDesignTabBarItem.layoutCentered = NO).
@property (nonatomic, assign) BOOL layoutCentered;

/// Scale the appearance fonts for Dynamic Type (capped at 2x). Defaults to YES.
@property (nonatomic, assign) BOOL adjustsFontForContentSizeCategory;
/// Minimum tag height; grows with the font for large text sizes. 30 by default.
@property (nonatomic, assign) CGFloat itemHeight;

#pragma mark Layout
@property (nonatomic, assign) CGFloat interitemSpacing;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) UIEdgeInsets sectionInsets;
@property (nonatomic, strong) UIColor *backgroundColor;

#pragma mark Section headers
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, strong) UIFont *headerFont;
@property (nonatomic, strong) UIColor *headerTextColor;
@property (nonatomic, assign) CGFloat headerHorizontalInset;

#pragma mark Fold controls
@property (nonatomic, strong) UIColor *foldControlColor;
/// Defaults to the localized "More" from CYLClassifyMenuResources.bundle.
@property (nonatomic, copy) NSString *expandTitle;
/// Footer chevron, pointing down while folded; it turns 180° when the section expands.
/// nil uses the SF Symbol "chevron.down".
@property (nonatomic, strong, nullable) UIImage *foldChevronImage;
/// Defaults to the localized "Less" from CYLClassifyMenuResources.bundle.
@property (nonatomic, copy) NSString *collapseTitle;

/// The title font of a state for the given traits: bold for the Bold Text setting,
/// scaled for Dynamic Type when adjustsFontForContentSizeCategory is YES.
- (UIFont *)titleFontForState:(UIControlState)state traitCollection:(nullable UITraitCollection *)traitCollection;
/// Header font for the given traits, applying Dynamic Type when enabled.
- (UIFont *)headerFontForTraitCollection:(nullable UITraitCollection *)traitCollection;

@end

NS_ASSUME_NONNULL_END
