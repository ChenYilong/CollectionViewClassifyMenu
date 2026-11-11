//
//  CYLTag.h
//  CollectionViewClassifyMenu
//
//  One tag as a value the host creates and adds (android-tagview's Tag), and CYLTagDataSource, the data source that
//  holds such tags. CYLTagListView's tag methods (-addTag:, -addTagsWithTitles:, -removeTagAtIndex:…) use one:
//
//      CYLTagListView *tagListView = [[CYLTagListView alloc] init];
//      tagListView.lineSpacing = 5;
//      tagListView.interitemSpacing = 3;
//      [tagListView addTagsWithTitles:@[@"Asia", @"Europe", @"Africa"]];
//      CYLTag *tag = [[CYLTag alloc] initWithTitle:@"Tag Text"];
//      tag.textColor = UIColor.whiteColor;
//      tag.backgroundColor = [UIColor colorWithWhite:0.87 alpha:1];
//      tag.highlightedBackgroundColor = [UIColor colorWithWhite:0.33 alpha:1];
//      tag.cornerRadius = 20;
//      tag.textSize = 14;
//      tag.borderWidth = 1;
//      tag.borderColor = UIColor.whiteColor;
//      tag.deletable = YES;
//      [tagListView addTag:tag];
//

#import <UIKit/UIKit.h>
#import "CYLMenuDataSource.h"
#import "CYLMenuStyle.h"
#import "CYLTagColors.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * For the CGFloat properties of CYLTag: use the list's value (the default).
 */
FOUNDATION_EXTERN const CGFloat CYLTagUseListValue;

@interface CYLTag : NSObject <NSCopying>

/*!
 * A tag with the list's look.
 */
- (instancetype)initWithTitle:(NSString *)title;
/*!
 * With its background color.
 */
- (instancetype)initWithTitle:(NSString *)title backgroundColor:(nullable UIColor *)backgroundColor;
/*!
 * With its background color as "#RGB", "#RRGGBB", "#RRGGBBAA" or a UIColor name ("systemBlue").
 */
- (instancetype)initWithTitle:(NSString *)title backgroundColorHex:(nullable NSString *)backgroundColorHex;
/*!
 * With an identifier of the host's (android-tagview's Tag.id).
 */
- (instancetype)initWithIdentifier:(NSInteger)identifier title:(NSString *)title;
- (instancetype)initWithIdentifier:(NSInteger)identifier title:(NSString *)title backgroundColor:(nullable UIColor *)backgroundColor;
- (instancetype)initWithIdentifier:(NSInteger)identifier title:(NSString *)title backgroundColorHex:(nullable NSString *)backgroundColorHex;
+ (instancetype)tagWithTitle:(NSString *)title;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/*!
 * The host's identifier, 0 by default.
 */
@property (nonatomic, assign) NSInteger identifier;
@property (nonatomic, copy) NSString *title;
/*!
 * Icons, as the data source's -menuImageForItemAtIndexPath: and -menuSelectedImageForItemAtIndexPath:.
 */
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) UIImage *selectedImage;
/*!
 * An animated icon (Lottie .json, .pag, .riv, .gif), as -menuAnimationURLForItemAtIndexPath:.
 */
@property (nonatomic, strong, nullable) NSURL *animationURL;
/*!
 * YES by default; a disabled tag is dimmed and ignores taps.
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
/*!
 * Shows a delete indicator ("×") after the title; a tap on it removes the tag (android-tagview's isDeletable).
 */
@property (nonatomic, assign, getter=isDeletable) BOOL deletable;
/*!
 * A round badge before the title with this text, e.g. "热" or "神" in a search app's hot list; drawn in `badgeColor`
 * (the title color by default) with white text, when the tag has no `image`.
 */
@property (nonatomic, copy, nullable) NSString *badgeText;
@property (nonatomic, strong, nullable) UIColor *badgeColor;
/*!
 * A round badge image: `text` in white on a `color` circle `diameter` points wide (rendered as original).
 */
+ (UIImage *)badgeImageWithText:(NSString *)text color:(UIColor *)color diameter:(CGFloat)diameter;
/*!
 * Anything the host wants to keep with the tag.
 */
@property (nonatomic, strong, nullable) id userInfo;

#pragma mark Look (over the list's style)
/*!
 * The style this tag starts from instead of the list's; the properties below apply over it. nil by default.
 */
@property (nonatomic, copy, nullable) CYLMenuStyle *style;
/*!
 * The title color (android-tagview's tagTextColor); nil for the style's.
 */
@property (nonatomic, strong, nullable) UIColor *textColor;
/*!
 * The title font; nil for a system font of `textSize`, or the style's.
 */
@property (nonatomic, strong, nullable) UIFont *font;
/*!
 * The title's point size (android-tagview's tagTextSize), a system font; CYLTagUseListValue for the style's. A larger
 * text makes the tag taller.
 */
@property (nonatomic, assign) CGFloat textSize;
/*!
 * android-tagview's layoutColor and layoutColorPress; nil for the style's.
 */
@property (nonatomic, strong, nullable) UIColor *backgroundColor;
@property (nonatomic, strong, nullable) UIColor *highlightedBackgroundColor;
/*!
 * The background while selected (AndroidTagView's tagSelectedBackgroundColor); nil for the style's.
 */
@property (nonatomic, strong, nullable) UIColor *selectedBackgroundColor;
/*!
 * Sets backgroundColor, borderColor, textColor and selectedBackgroundColor at once (AndroidTagView's color array), or
 * reads them.
 */
@property (nonatomic, copy, null_resettable) CYLTagColors *colors;
/*!
 * Drawn behind the title, stretched (android-tagview's background); nil for none.
 */
@property (nonatomic, strong, nullable) UIImage *backgroundImage;
/*!
 * The corner radius (android-tagview's radius); 0 is a capsule, CYLTagUseListValue the style's.
 */
@property (nonatomic, assign) CGFloat cornerRadius;
/*!
 * The border (android-tagview's layoutBorderSize and layoutBorderColor); CYLTagUseListValue / nil for the style's.
 */
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong, nullable) UIColor *borderColor;
/*!
 * The delete indicator (android-tagview's deleteIcon, deleteIndicatorColor and deleteIndicatorSize); nil /
 * CYLTagUseListValue for the style's ("×" in the title color and font).
 */
@property (nonatomic, copy, nullable) NSString *deleteIndicatorTitle;
@property (nonatomic, strong, nullable) UIColor *deleteIndicatorColor;
@property (nonatomic, assign) CGFloat deleteIndicatorSize;

/*!
 * Whether any look property is set: NO draws the tag with the base style itself.
 */
@property (nonatomic, assign, readonly) BOOL hasCustomStyle;
/*!
 * A copy of `style` (or of `baseStyle` when it is nil) with this tag's look applied: the colors to the normal state,
 * the font, corner radius and border to every state.
 */
- (CYLMenuStyle *)styleWithBaseStyle:(CYLMenuStyle *)baseStyle;

@end

/*!
 * A data source of CYLTag objects in one section without a title. CYLTagListView's tag methods create and use one
 * (`tagDataSource`); it can also be given to any list as its menuDataSource (keep a strong reference to it).
 */
@interface CYLTagDataSource : NSObject <CYLMenuDataSource>

- (instancetype)initWithTags:(nullable NSArray<CYLTag *> *)tags;

@property (nonatomic, copy) NSArray<CYLTag *> *tags;
/*!
 * The style tags with their own look start from (CYLTagListView keeps it equal to its style).
 */
@property (nonatomic, copy, null_resettable) CYLMenuStyle *baseStyle;

- (void)addTag:(CYLTag *)tag;
- (void)addTags:(NSArray<CYLTag *> *)tags;
- (void)insertTag:(CYLTag *)tag atIndex:(NSUInteger)index;
/*!
 * Out-of-range indexes are ignored.
 */
- (void)removeTagAtIndex:(NSUInteger)index;
- (void)removeAllTags;
/*!
 * Moves a tag; out-of-range indexes are ignored.
 */
- (void)moveTagAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
/*!
 * Builds every tag's style again; call it after changing a tag's look (CYLTagListView's -reloadMenuData does).
 */
- (void)invalidateStyles;

@end

NS_ASSUME_NONNULL_END
