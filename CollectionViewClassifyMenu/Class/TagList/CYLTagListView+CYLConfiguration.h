//
//  CYLTagListView+CYLConfiguration.h
//  CollectionViewClassifyMenu
//
//  Creating a tag list from one dictionary (a map) or a configuration file, the
//  way CYLTabBarController is created with -initWithConfiguration: and
//  -initWithConfigurationFile:error:. In code, values have their usual types; in
//  a file, strings work for every key (colors "#RRGGBB", images "system:star",
//  insets "{top, left, bottom, right}" or arrays, enum names...).
//
//      CYLTagListView *tags = [[CYLTagListView alloc] initWithConfiguration:@{
//          CYLTagListViewSelectionMode : @"multiple",
//          CYLTagListViewFoldStyle : @"footerChevron",
//          CYLTagListViewStyle : @{ CYLMenuStyleNormal : @{ CYLTagAppearanceCornerRadius : @0 } },
//          CYLTagListViewSections : @[ @{ CYLTagSectionTitle : @"Tabs",
//                                         CYLTagSectionItems : @[ @{ CYLTagItemTitle : @"Home",
//                                                                    CYLTagItemImage : @"system:house",
//                                                                    CYLTagItemAnimation : @"tab_home.json" } ] } ],
//      }];
//      CYLTagListView *fromFile = [CYLTagListView tagListViewWithConfigurationFile:@"tags.json" error:&error];
//

#import "CYLTagListView.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark Tag list keys
/// NSArray of section dictionaries (CYLTagSection… keys).
FOUNDATION_EXTERN NSString *const CYLTagListViewSections;
/// CYLMenuStyle, or a dictionary of CYLMenuStyle… keys.
FOUNDATION_EXTERN NSString *const CYLTagListViewStyle;
/// NSNumber of CYLMenuSelectionMode, or "none", "single", "multiple".
FOUNDATION_EXTERN NSString *const CYLTagListViewSelectionMode;
/// NSNumber of CYLMenuFoldStyle, or "none", "headerButton", "footerChevron", "truncate".
FOUNDATION_EXTERN NSString *const CYLTagListViewFoldStyle;
/// NSNumber, or "true" / "false".
FOUNDATION_EXTERN NSString *const CYLTagListViewAllowsEmptySelection;
FOUNDATION_EXTERN NSString *const CYLTagListViewShowsSectionHeaders;
FOUNDATION_EXTERN NSString *const CYLTagListViewScrollEnabled;
/// NSNumber.
FOUNDATION_EXTERN NSString *const CYLTagListViewDefaultVisibleRows;
/// NSArray of NSIndexPath, "section-item" strings or [section, item] arrays.
FOUNDATION_EXTERN NSString *const CYLTagListViewSelectedItems;
/// CYLMenuFoldControl, a position name ("bottom", "topTrailing"…), or a dictionary of CYLMenuFoldControlKey…
/// keys. Applied after CYLTagListViewFoldStyle.
FOUNDATION_EXTERN NSString *const CYLTagListViewFoldControl;
/// NSString: the list's title, above every section.
FOUNDATION_EXTERN NSString *const CYLTagListViewTitle;
/// NSNumber of CYLMenuTitlePosition, or "topLeading" ("leading", "left"), "topCenter" ("center").
FOUNDATION_EXTERN NSString *const CYLTagListViewTitlePosition;
/// UIImage, or an image name, "system:<SF Symbol>" or a file path: the title's icon.
FOUNDATION_EXTERN NSString *const CYLTagListViewTitleImage;
/// CYLMenuStyle, or a dictionary of CYLMenuStyle… keys applied over +[CYLTagListView defaultTitleStyle]
/// (e.g. {normal: {textColor: "#07C160", iconColor: "#07C160"}}).
FOUNDATION_EXTERN NSString *const CYLTagListViewTitleStyle;

#pragma mark Fold control keys (CYLMenuFoldControl)
/// NSNumber of CYLMenuFoldControlPosition, or "none", "bottom", "topTrailing" ("topRight"), "topLeading" ("topLeft").
FOUNDATION_EXTERN NSString *const CYLMenuFoldControlKeyPosition;
/// NSNumber of CYLMenuFoldControlContent, or "iconAndTitle" ("titleAndIcon"), "title", "icon".
FOUNDATION_EXTERN NSString *const CYLMenuFoldControlKeyContent;
/// NSString.
FOUNDATION_EXTERN NSString *const CYLMenuFoldControlKeyTitle;
FOUNDATION_EXTERN NSString *const CYLMenuFoldControlKeyCollapseTitle;
/// UIImage, or an image name, "system:<SF Symbol>" or a file path.
FOUNDATION_EXTERN NSString *const CYLMenuFoldControlKeyImage;
/// UIColor or a color string.
FOUNDATION_EXTERN NSString *const CYLMenuFoldControlKeyColor;
/// UIFont, a point size, or {size:, weight:, name:, italic:}.
FOUNDATION_EXTERN NSString *const CYLMenuFoldControlKeyFont;
/// NSNumber, or "true" / "false".
FOUNDATION_EXTERN NSString *const CYLMenuFoldControlKeyRotatesImage;

#pragma mark Section keys
FOUNDATION_EXTERN NSString *const CYLTagSectionTitle;
/// UIImage, or an image name, "system:<SF Symbol>" or a file path.
FOUNDATION_EXTERN NSString *const CYLTagSectionImage;
/// NSArray of item dictionaries (CYLTagItem… keys), or of strings (titles).
FOUNDATION_EXTERN NSString *const CYLTagSectionItems;
/// CYLMenuStyle, or a dictionary of CYLMenuStyle… keys applied over the list's style: the look of this
/// section's tags (see -menuStyleForSection:), e.g. dark tags for white icons.
FOUNDATION_EXTERN NSString *const CYLTagSectionStyle;

#pragma mark Item keys
FOUNDATION_EXTERN NSString *const CYLTagItemTitle;
/// UIImage, or an image name, "system:<SF Symbol>" or a file path.
FOUNDATION_EXTERN NSString *const CYLTagItemImage;
FOUNDATION_EXTERN NSString *const CYLTagItemSelectedImage;
/// NSURL, or a URL string, a file path or a file name (in the main bundle, or next to the
/// configuration file): a Lottie .json, .pag, .riv or .gif animated icon.
FOUNDATION_EXTERN NSString *const CYLTagItemAnimation;
/// NSDictionary of strings (numbers are converted): options read by the animation's library, written into the
/// animation URL with CYLMenuAnimationURLWithOptions(). For Rive, as in CYLTabBarController: "artboard",
/// "stateMachine", "input", "triggerInput", "animation", "duration", "legacy"...
FOUNDATION_EXTERN NSString *const CYLTagItemAnimationOptions;
/// NSNumber 0...1: the frame shown while not selected (see -menuAnimationRestingProgressForItemAtIndexPath:).
FOUNDATION_EXTERN NSString *const CYLTagItemAnimationRestingProgress;
/// NSNumber, or "true" / "false". Default YES / NO.
FOUNDATION_EXTERN NSString *const CYLTagItemEnabled;
FOUNDATION_EXTERN NSString *const CYLTagItemExclusive;
/// NSNumber of CYLMenuItemType, or "tag" (default), "create" ("+ 新建标签"; its title is the name to create).
FOUNDATION_EXTERN NSString *const CYLTagItemType;

#pragma mark Style keys (CYLMenuStyle)
/// Dictionaries of CYLTagAppearance… keys, for each state.
FOUNDATION_EXTERN NSString *const CYLMenuStyleNormal;
FOUNDATION_EXTERN NSString *const CYLMenuStyleSelected;
FOUNDATION_EXTERN NSString *const CYLMenuStyleDisabled;
/// Numbers.
FOUNDATION_EXTERN NSString *const CYLMenuStyleImageTitleSpacing;
FOUNDATION_EXTERN NSString *const CYLMenuStyleItemHeight;
FOUNDATION_EXTERN NSString *const CYLMenuStyleInteritemSpacing;
FOUNDATION_EXTERN NSString *const CYLMenuStyleLineSpacing;
FOUNDATION_EXTERN NSString *const CYLMenuStyleHeaderHeight;
FOUNDATION_EXTERN NSString *const CYLMenuStyleAnimationSpeed;
/// CGSize: NSValue, "{width, height}", [w, h] or {width:, height:}.
FOUNDATION_EXTERN NSString *const CYLMenuStyleImageSize;
FOUNDATION_EXTERN NSString *const CYLMenuStyleAnimationSize;
/// UIEdgeInsets: NSValue, "{top, left, bottom, right}", [t, l, b, r] or {top:, left:, bottom:, right:}.
FOUNDATION_EXTERN NSString *const CYLMenuStyleImageInsets;
FOUNDATION_EXTERN NSString *const CYLMenuStyleSectionInsets;
/// UIOffset: NSValue, "{horizontal, vertical}", [h, v] or {horizontal:, vertical:}.
FOUNDATION_EXTERN NSString *const CYLMenuStyleTitlePositionAdjustment;
FOUNDATION_EXTERN NSString *const CYLMenuStyleImagePositionAdjustment;
/// NSNumber, or "true" / "false".
FOUNDATION_EXTERN NSString *const CYLMenuStyleLayoutCentered;
FOUNDATION_EXTERN NSString *const CYLMenuStyleAdjustsFontForContentSizeCategory;
/// UIColor, or "#RGB", "#RRGGBB", "#RRGGBBAA" or a UIColor name ("systemBlue").
FOUNDATION_EXTERN NSString *const CYLMenuStyleBackgroundColor;
FOUNDATION_EXTERN NSString *const CYLMenuStyleHeaderTextColor;
FOUNDATION_EXTERN NSString *const CYLMenuStyleFoldControlColor;
/// UIFont, a point size, or {size:, weight: "semibold", name: "Menlo", italic: true}.
FOUNDATION_EXTERN NSString *const CYLMenuStyleHeaderFont;

#pragma mark Appearance keys (CYLTagAppearance, as CYLBadgeAppearance)
FOUNDATION_EXTERN NSString *const CYLTagAppearanceBackgroundColor;
FOUNDATION_EXTERN NSString *const CYLTagAppearanceTextColor;
FOUNDATION_EXTERN NSString *const CYLTagAppearanceFont;
FOUNDATION_EXTERN NSString *const CYLTagAppearanceIconColor;
FOUNDATION_EXTERN NSString *const CYLTagAppearanceCornerRadius;
FOUNDATION_EXTERN NSString *const CYLTagAppearanceBorderColor;
FOUNDATION_EXTERN NSString *const CYLTagAppearanceBorderWidth;
FOUNDATION_EXTERN NSString *const CYLTagAppearanceMargin;

FOUNDATION_EXTERN NSErrorDomain const CYLMenuConfigurationErrorDomain;
typedef NS_ERROR_ENUM(CYLMenuConfigurationErrorDomain, CYLMenuConfigurationError) {
    CYLMenuConfigurationErrorFileNotFound = 1,
    CYLMenuConfigurationErrorInvalidContents,
    CYLMenuConfigurationErrorUnsupportedFormat,
};

/// An animation URL with options, encoded exactly as CYLTabBarController's CYLTabBarAnimationURLWithOptions()
/// does ("name=value&…" in the fragment, percent-encoded and sorted by name), so that its animation libraries read
/// them, e.g. which artboard and state machine of a Rive file a tag plays. Returns fileURL when there are no options,
/// and nil when fileURL is nil.
///
///     item.animationURL = CYLMenuAnimationURLWithOptions(iconsURL, @{ @"artboard" : @"CHAT",
///                                                                     @"stateMachine" : @"CHAT_Interactivity",
///                                                                     @"input" : @"active" });
FOUNDATION_EXTERN NSURL *_Nullable CYLMenuAnimationURLWithOptions(NSURL *_Nullable fileURL, NSDictionary<NSString *, id> *_Nullable options);

@interface CYLTagListView (CYLConfiguration)

/// Creates a tag list from one dictionary holding everything (see the keys above). The view
/// keeps the data source it builds from CYLTagListViewSections.
- (instancetype)initWithConfiguration:(NSDictionary<NSString *, id> *)configuration;
+ (instancetype)tagListViewWithConfiguration:(NSDictionary<NSString *, id> *)configuration;
/// Applies a configuration to an existing view; keys that are missing keep their values.
- (void)applyConfiguration:(NSDictionary<NSString *, id> *)configuration;

/// Reads a configuration file: a path, a file URL string, or a file name in the main bundle
/// (e.g. @"tags.json" or @"Configurations.bundle/tags.plist"). JSON and property lists (XML or binary)
/// are read directly; the other formats of CYLTabBarController's CYLTabBarConfigurationParser (JSON5,
/// YAML, TOML, INI, .properties, XML, Protocol Buffers text…) are read by it when CYLTabBarController is
/// linked. The values are then read by this project's rules (strings for every key, see above).
/// Relative file names inside resolve next to the file.
+ (nullable NSDictionary<NSString *, id> *)configurationWithContentsOfFile:(NSString *)filePath error:(NSError *_Nullable *_Nullable)error;
- (nullable instancetype)initWithConfigurationFile:(NSString *)filePath error:(NSError *_Nullable *_Nullable)error;
+ (nullable instancetype)tagListViewWithConfigurationFile:(NSString *)filePath error:(NSError *_Nullable *_Nullable)error;

/// The data source built from CYLTagListViewSections, or nil.
@property (nonatomic, strong, readonly, nullable) id<CYLMenuDataSource> configurationDataSource;

@end

@interface CYLMenuStyle (CYLConfiguration)
/// A default style with the configuration's values (CYLMenuStyle… keys).
+ (instancetype)styleWithConfiguration:(NSDictionary<NSString *, id> *)configuration;
- (void)applyConfiguration:(NSDictionary<NSString *, id> *)configuration;
@end

@interface CYLMenuFoldControl (CYLConfiguration)
/// A fold control from a dictionary of CYLMenuFoldControlKey… keys, or from a position name.
+ (nullable instancetype)foldControlWithConfiguration:(id)configuration;
- (void)applyConfiguration:(NSDictionary<NSString *, id> *)configuration;
@end

@interface CYLTagAppearance (CYLConfiguration)
- (void)applyConfiguration:(NSDictionary<NSString *, id> *)configuration;
@end

NS_ASSUME_NONNULL_END
