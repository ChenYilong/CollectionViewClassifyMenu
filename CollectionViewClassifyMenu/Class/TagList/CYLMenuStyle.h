//
//  CYLMenuStyle.h
//  CollectionViewClassifyMenu
//
//  Appearance of CYLTagListView. Copy a preset and change what you need.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYLMenuStyle : NSObject <NSCopying>

/// Gray bordered tags, green selection. Used when no style is set.
+ (instancetype)defaultStyle;

#pragma mark Items
/// Base font; scaled for Dynamic Type when adjustsFontForContentSizeCategory is YES.
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) BOOL adjustsFontForContentSizeCategory;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) UIColor *disabledTextColor;
@property (nonatomic, strong) UIColor *itemBackgroundColor;
@property (nonatomic, strong) UIColor *selectedItemBackgroundColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *selectedBorderColor;
@property (nonatomic, assign) CGFloat borderWidth;
/// Negative values make fully rounded (capsule) tags.
@property (nonatomic, assign) CGFloat cornerRadius;
/// Minimum item height; grows with the font for large text sizes.
@property (nonatomic, assign) CGFloat itemHeight;
/// Horizontal space between an item's border and its content.
@property (nonatomic, assign) CGFloat itemHorizontalPadding;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) CGFloat imageTitleSpacing;

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
@property (nonatomic, copy) NSString *expandTitle;
@property (nonatomic, copy) NSString *collapseTitle;

/// Item font for the given traits, applying Dynamic Type when enabled.
- (UIFont *)itemFontForTraitCollection:(nullable UITraitCollection *)traitCollection;
/// Header font for the given traits, applying Dynamic Type when enabled.
- (UIFont *)headerFontForTraitCollection:(nullable UITraitCollection *)traitCollection;

@end

NS_ASSUME_NONNULL_END
