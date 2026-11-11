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

/*!
 * Where a tag's icon goes relative to its title.
 */
typedef NS_ENUM(NSInteger, CYLTagImagePlacement) {
    /*!
     * Icon, then title (the default).
     */
    CYLTagImagePlacementLeading = 0,
    /*!
     * Title, then icon, e.g. "更多 ⌄".
     */
    CYLTagImagePlacementTrailing,
};

/*!
 * Where a tag's content (its icon and title, in the order of CYLTagImagePlacement) sits in the tag.
 */
typedef NS_ENUM(NSInteger, CYLTagContentAlignment) {
    /*!
     * Centered in the tag (the default).
     */
    CYLTagContentAlignmentCenter = 0,
    /*!
     * At the leading margin: the title (or the icon) starts there and the other follows it, e.g. a search
     * suggestion "苹果官方社区… [热]" whose title is truncated so the icon after it stays visible.
     */
    CYLTagContentAlignmentLeading,
};

/*!
 * How the tags of a row line up (android-tagview's AndroidTagView container_gravity).
 */
typedef NS_ENUM(NSInteger, CYLTagRowAlignment) {
    /*!
     * From the leading edge (the default).
     */
    CYLTagRowAlignmentLeading = 0,
    CYLTagRowAlignmentCenter,
    CYLTagRowAlignmentTrailing,
};

/*!
 * Where a deletable tag's delete indicator is.
 */
typedef NS_ENUM(NSInteger, CYLTagDeleteIndicatorPlacement) {
    /*!
     * After the title (the default).
     */
    CYLTagDeleteIndicatorPlacementTrailing = 0,
    /*!
     * Before the content, as AndroidTagView's cross in right-to-left tags.
     */
    CYLTagDeleteIndicatorPlacementLeading,
};

@interface CYLMenuStyle : NSObject <NSCopying>

/*!
 * Gray bordered tags, green selection. Used when no style is set.
 */
+ (instancetype)defaultStyle;

#pragma mark Tag box and text, per state (CYLBadgeAppearance)

/*!
 * Normal tags. The appearance objects belong to the style: change their properties.
 */
@property (nonatomic, strong, readonly) CYLTagAppearance *normalAppearance;
@property (nonatomic, strong, readonly) CYLTagAppearance *selectedAppearance;
@property (nonatomic, strong, readonly) CYLTagAppearance *disabledAppearance;

/*!
 * The appearance for UIControlStateNormal, UIControlStateSelected or
 * UIControlStateDisabled (disabled wins over selected); others give normal.
 */
- (CYLTagAppearance *)appearanceForState:(UIControlState)state;

/*!
 * The background of a tag while a finger is on it (as android-tagview's layoutColorPress). nil (the default)
 * keeps the state's background.
 */
@property (nonatomic, strong, nullable) UIColor *highlightedBackgroundColor;
/*!
 * The content insets of every state's appearance at once (as android-tagview's textPadding…); reading it gives the
 * normal appearance's. {5, 10, 5, 10} by default.
 */
@property (nonatomic, assign) UIEdgeInsets tagContentInsets;

#pragma mark Delete indicator (deletable tags)
/*!
 * Shown after the title of a deletable tag (`menuItemIsDeletableAtIndexPath:`, CYLTag.deletable); a tap on it deletes
 * the tag. Defaults to "×" (as android-tagview's deleteIcon).
 */
@property (nonatomic, copy) NSString *deleteIndicatorTitle;
/*!
 * Its color; nil (the default) uses the state's text color.
 */
@property (nonatomic, strong, nullable) UIColor *deleteIndicatorColor;
/*!
 * Its font; nil (the default) uses the state's title font. Scaled for Dynamic Type as the title is.
 */
@property (nonatomic, strong, nullable) UIFont *deleteIndicatorFont;

/*!
 * Draws the delete indicator as a cross of two lines this wide instead of `deleteIndicatorTitle` (AndroidTagView's
 * tag_cross_line_width); 0 (the default) draws the title.
 */
@property (nonatomic, assign) CGFloat deleteIndicatorLineWidth;
/*!
 * The width of the delete indicator's area (tag_cross_width); 0 (the default) fits the title, or the font's line height
 * for a drawn cross.
 */
@property (nonatomic, assign) CGFloat deleteIndicatorWidth;
/*!
 * Space between the area's edges and a drawn cross (tag_cross_area_padding). 0 by default.
 */
@property (nonatomic, assign) CGFloat deleteIndicatorPadding;
/*!
 * After the title (the default) or before the content.
 */
@property (nonatomic, assign) CYLTagDeleteIndicatorPlacement deleteIndicatorPlacement;

#pragma mark Touch ripple (AndroidTagView)
/*!
 * A circle that grows from the touch point while a tag is pressed (tag_ripple_color); nil (the default) for none.
 */
@property (nonatomic, strong, nullable) UIColor *rippleColor;
/*!
 * Its opacity at the start, 0...1 (tag_ripple_alpha). 0.2 by default.
 */
@property (nonatomic, assign) CGFloat rippleAlpha;
/*!
 * How long it grows, in seconds (tag_ripple_duration). 1 by default.
 */
@property (nonatomic, assign) NSTimeInterval rippleDuration;

#pragma mark Titles
/*!
 * Titles longer than this many characters are cut and end with "..." (tag_max_length); 0 (the default) keeps them.
 */
@property (nonatomic, assign) NSUInteger maximumTitleLength;
/*!
 * Shows each title's characters in reverse order (AndroidTagView's tag_support_letters_rlt). NO by default.
 */
@property (nonatomic, assign) BOOL reversesTitleCharacters;
/*!
 * The title as a tag shows it: cut to `maximumTitleLength`, reversed when `reversesTitleCharacters`.
 */
- (NSString *)displayedTitleForTitle:(nullable NSString *)title;

#pragma mark Rows and section headers
/*!
 * How the tags of a row line up: leading (the default), centered or trailing.
 */
@property (nonatomic, assign) CYLTagRowAlignment rowAlignment;
/*!
 * A bar before each section title, as in a "| 热门搜索" header; nil (the default) for none.
 */
@property (nonatomic, strong, nullable) UIColor *headerIndicatorColor;
/*!
 * The bar's size, {3, 16} by default.
 */
@property (nonatomic, assign) CGSize headerIndicatorSize;
/*!
 * Rounds the icon's corners (AndroidTagView's round avatars): half the icon's size or more makes it a circle. 0 by default.
 */
@property (nonatomic, assign) CGFloat imageCornerRadius;

#pragma mark Title and icon (CYLFlatDesignTabBarItem)

/*!
 * Like `-[UITabBarItem setTitleTextAttributes:forState:]`: NSFontAttributeName and
 * NSForegroundColorAttributeName update the state's appearance font and textColor.
 */
- (void)setTitleTextAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes forState:(UIControlState)state;
/*!
 * The state's font and text color as text attributes.
 */
- (NSDictionary<NSAttributedStringKey, id> *)titleTextAttributesForState:(UIControlState)state;

/*!
 * Tint of template icons in a state (like `UITabBarItemStateAppearance.iconColor`);
 * nil uses the state's textColor.
 */
- (void)setIconColor:(nullable UIColor *)iconColor forState:(UIControlState)state;
/*!
 * The effective icon tint for a state.
 */
- (UIColor *)iconColorForState:(UIControlState)state;

/*!
 * Space between the icon and the title, 4 by default.
 */
@property (nonatomic, assign) CGFloat imageTitleSpacing;
/*!
 * Icon size. CGSizeZero uses the image's own size. 14 x 14 by default.
 */
@property (nonatomic, assign) CGSize imageSize;
/*!
 * Shrinks the icon from its slot without moving it, as `CYLFlatDesignTabBarItem.imageInsets`.
 */
@property (nonatomic, assign) UIEdgeInsets imageInsets;
/*!
 * Moves the title from its computed position.
 */
@property (nonatomic, assign) UIOffset titlePositionAdjustment;
/*!
 * Moves the icon from its computed position.
 */
@property (nonatomic, assign) UIOffset imagePositionAdjustment;
/*!
 * The icon before (default) or after the title.
 */
@property (nonatomic, assign) CYLTagImagePlacement imagePlacement;
/*!
 * For a tag with only an icon or only a title: YES (the default) centers it;
 * NO keeps it where it would be with both, the title after an empty icon slot,
 * the icon at the leading margin (as CYLFlatDesignTabBarItem.layoutCentered = NO).
 */
@property (nonatomic, assign) BOOL layoutCentered;
/*!
 * Where the icon and title sit together: CYLTagContentAlignmentCenter (the default) centers them;
 * CYLTagContentAlignmentLeading puts them at the leading margin, without an empty icon slot before a title
 * alone. A title too long for the tag is truncated with an ellipsis, so its icon stays visible.
 */
@property (nonatomic, assign) CYLTagContentAlignment contentAlignment;

/*!
 * Size of animated icons (`menuAnimationURLForItemAtIndexPath:`). CGSizeZero (the default) uses imageSize.
 */
@property (nonatomic, assign) CGSize animationSize;
/*!
 * Playback speed of animated icons, as `CYLTabBarController.tabBarItemAnimationSpeed`; 1 (the default)
 * is the file's own speed.
 */
@property (nonatomic, assign) CGFloat animationSpeed;

/*!
 * Scale the appearance fonts for Dynamic Type (capped at 2x). Defaults to YES.
 */
@property (nonatomic, assign) BOOL adjustsFontForContentSizeCategory;
/*!
 * Minimum tag height; grows with the font for large text sizes. 30 by default.
 */
@property (nonatomic, assign) CGFloat itemHeight;
/*!
 * Grid layout: 0 (the default) lays the tags out one after another, each as wide as its title; a number above 0
 * gives every tag the same width, that many per row (the content width minus the spacing between them, divided
 * evenly), and truncates a longer title with an ellipsis ("…"), like a search app's suggestions, two per row.
 */
@property (nonatomic, assign) NSUInteger numberOfItemsPerRow;

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
/*!
 * Defaults to the localized "More" from CYLClassifyMenuResources.bundle.
 */
@property (nonatomic, copy) NSString *expandTitle;
/*!
 * Footer chevron, pointing down while folded; it turns 180° when the section expands.
 * nil uses the SF Symbol "chevron.down".
 */
@property (nonatomic, strong, nullable) UIImage *foldChevronImage;
/*!
 * Defaults to the localized "Less" from CYLClassifyMenuResources.bundle.
 */
@property (nonatomic, copy) NSString *collapseTitle;

#pragma mark The More button
/*!
 * The icon of the More button in a section header (`menuShowsMoreButtonInSection:`). nil (the default) uses the
 * bundle's "cyl_more", three dots like the "ellipsis" icon of CYLTabBarController's More tab.
 */
@property (nonatomic, strong, nullable) UIImage *moreButtonImage;
/*!
 * The color of the More button. Defaults to the secondary label color.
 */
@property (nonatomic, strong) UIColor *moreButtonColor;

/*!
 * A grid of plain titles, like a search app's suggestions: `numberOfItemsPerRow` items per row, each as wide as
 * the others, no background and no border, the content at the leading edge (CYLTagContentAlignmentLeading) in the
 * body font: the title, then its icon if it has one (CYLTagImagePlacementTrailing, such as a "热" icon), the title
 * truncated with an ellipsis. Change it like any other style.
 */
+ (instancetype)gridStyleWithNumberOfItemsPerRow:(NSUInteger)numberOfItemsPerRow NS_SWIFT_NAME(gridStyle(itemsPerRow:));

/*!
 * The title font of a state for the given traits: bold for the Bold Text setting,
 * scaled for Dynamic Type when adjustsFontForContentSizeCategory is YES.
 */
- (UIFont *)titleFontForState:(UIControlState)state traitCollection:(nullable UITraitCollection *)traitCollection;
/*!
 * The delete indicator's font for the given traits (deleteIndicatorFont, or the state's title font).
 */
- (UIFont *)deleteIndicatorFontForState:(UIControlState)state traitCollection:(nullable UITraitCollection *)traitCollection;
/*!
 * Header font for the given traits, applying Dynamic Type when enabled.
 */
- (UIFont *)headerFontForTraitCollection:(nullable UITraitCollection *)traitCollection;

@end

NS_ASSUME_NONNULL_END
