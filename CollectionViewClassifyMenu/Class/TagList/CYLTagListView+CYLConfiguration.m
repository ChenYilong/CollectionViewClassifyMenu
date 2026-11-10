//
//  CYLTagListView+CYLConfiguration.m
//  CollectionViewClassifyMenu
//

#import "CYLTagListView+CYLConfiguration.h"
#import <objc/runtime.h>

NSString *const CYLTagListViewSections = @"sections";
NSString *const CYLTagListViewStyle = @"style";
NSString *const CYLTagListViewSelectionMode = @"selectionMode";
NSString *const CYLTagListViewFoldStyle = @"foldStyle";
NSString *const CYLTagListViewAllowsEmptySelection = @"allowsEmptySelection";
NSString *const CYLTagListViewShowsSectionHeaders = @"showsSectionHeaders";
NSString *const CYLTagListViewScrollEnabled = @"scrollEnabled";
NSString *const CYLTagListViewDefaultVisibleRows = @"defaultVisibleRows";
NSString *const CYLTagListViewSelectedItems = @"selectedItems";
NSString *const CYLTagListViewFoldControl = @"foldControl";
NSString *const CYLTagListViewTitle = @"title";
NSString *const CYLTagListViewTitlePosition = @"titlePosition";
NSString *const CYLTagListViewTitleImage = @"titleImage";
NSString *const CYLTagListViewTitleStyle = @"titleStyle";

NSString *const CYLMenuFoldControlKeyPosition = @"position";
NSString *const CYLMenuFoldControlKeyContent = @"content";
NSString *const CYLMenuFoldControlKeyTitle = @"title";
NSString *const CYLMenuFoldControlKeyCollapseTitle = @"collapseTitle";
NSString *const CYLMenuFoldControlKeyImage = @"image";
NSString *const CYLMenuFoldControlKeyColor = @"color";
NSString *const CYLMenuFoldControlKeyFont = @"font";
NSString *const CYLMenuFoldControlKeyRotatesImage = @"rotatesImageWhenExpanded";

NSString *const CYLTagSectionTitle = @"title";
NSString *const CYLTagSectionImage = @"image";
NSString *const CYLTagSectionItems = @"items";
NSString *const CYLTagSectionStyle = @"style";

NSString *const CYLTagItemTitle = @"title";
NSString *const CYLTagItemImage = @"image";
NSString *const CYLTagItemSelectedImage = @"selectedImage";
NSString *const CYLTagItemAnimation = @"animation";
NSString *const CYLTagItemAnimationOptions = @"animationOptions";
NSString *const CYLTagItemAnimationRestingProgress = @"animationRestingProgress";
NSString *const CYLTagItemEnabled = @"enabled";
NSString *const CYLTagItemExclusive = @"exclusive";
NSString *const CYLTagItemType = @"type";

NSString *const CYLMenuStyleNormal = @"normal";
NSString *const CYLMenuStyleSelected = @"selected";
NSString *const CYLMenuStyleDisabled = @"disabled";
NSString *const CYLMenuStyleImageTitleSpacing = @"imageTitleSpacing";
NSString *const CYLMenuStyleItemHeight = @"itemHeight";
NSString *const CYLMenuStyleInteritemSpacing = @"interitemSpacing";
NSString *const CYLMenuStyleLineSpacing = @"lineSpacing";
NSString *const CYLMenuStyleHeaderHeight = @"headerHeight";
NSString *const CYLMenuStyleAnimationSpeed = @"animationSpeed";
NSString *const CYLMenuStyleImageSize = @"imageSize";
NSString *const CYLMenuStyleAnimationSize = @"animationSize";
NSString *const CYLMenuStyleImageInsets = @"imageInsets";
NSString *const CYLMenuStyleSectionInsets = @"sectionInsets";
NSString *const CYLMenuStyleTitlePositionAdjustment = @"titlePositionAdjustment";
NSString *const CYLMenuStyleImagePositionAdjustment = @"imagePositionAdjustment";
NSString *const CYLMenuStyleLayoutCentered = @"layoutCentered";
NSString *const CYLMenuStyleAdjustsFontForContentSizeCategory = @"adjustsFontForContentSizeCategory";
NSString *const CYLMenuStyleBackgroundColor = @"backgroundColor";
NSString *const CYLMenuStyleHeaderTextColor = @"headerTextColor";
NSString *const CYLMenuStyleFoldControlColor = @"foldControlColor";
NSString *const CYLMenuStyleHeaderFont = @"headerFont";

NSString *const CYLTagAppearanceBackgroundColor = @"backgroundColor";
NSString *const CYLTagAppearanceTextColor = @"textColor";
NSString *const CYLTagAppearanceFont = @"font";
NSString *const CYLTagAppearanceIconColor = @"iconColor";
NSString *const CYLTagAppearanceCornerRadius = @"cornerRadius";
NSString *const CYLTagAppearanceBorderColor = @"borderColor";
NSString *const CYLTagAppearanceBorderWidth = @"borderWidth";
NSString *const CYLTagAppearanceMargin = @"margin";

NSErrorDomain const CYLMenuConfigurationErrorDomain = @"CYLMenuConfigurationErrorDomain";

/// Directory of the configuration file, added by +configurationWithContentsOfFile:error: so that
/// relative file names resolve next to it.
static NSString *const kCYLConfigurationBaseURL = @"__CYLConfigurationBaseURL";

#pragma mark - Values

static NSNumber *CYLNumber(id value) {
    if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    }
    if ([value isKindOfClass:[NSString class]]) {
        NSString *string = [[value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] lowercaseString];
        if ([@[@"true", @"yes", @"on"] containsObject:string]) return @YES;
        if ([@[@"false", @"no", @"off"] containsObject:string]) return @NO;
        NSScanner *scanner = [NSScanner scannerWithString:string];
        double number = 0;
        if ([scanner scanDouble:&number] && scanner.isAtEnd) return @(number);
    }
    return nil;
}

static NSArray<NSNumber *> *CYLNumbers(id value, NSUInteger count) {
    NSArray *parts = nil;
    if ([value isKindOfClass:[NSArray class]]) {
        parts = value;
    } else if ([value isKindOfClass:[NSString class]]) {
        NSString *trimmed = [[value stringByReplacingOccurrencesOfString:@"{" withString:@""] stringByReplacingOccurrencesOfString:@"}" withString:@""];
        trimmed = [[trimmed stringByReplacingOccurrencesOfString:@"[" withString:@""] stringByReplacingOccurrencesOfString:@"]" withString:@""];
        parts = [trimmed componentsSeparatedByString:@","];
    }
    if (parts.count != count) {
        return nil;
    }
    NSMutableArray *numbers = [NSMutableArray array];
    for (id part in parts) {
        NSNumber *number = CYLNumber(part);
        if (number == nil) return nil;
        [numbers addObject:number];
    }
    return numbers;
}

static NSValue *CYLInsets(id value) {
    if ([value isKindOfClass:[NSValue class]] && ![value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSDictionary class]]) {
        return [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake([CYLNumber(value[@"top"]) doubleValue], [CYLNumber(value[@"left"]) doubleValue],
                                                               [CYLNumber(value[@"bottom"]) doubleValue], [CYLNumber(value[@"right"]) doubleValue])];
    }
    NSArray<NSNumber *> *n = CYLNumbers(value, 4);
    return n ? [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(n[0].doubleValue, n[1].doubleValue, n[2].doubleValue, n[3].doubleValue)] : nil;
}

static NSValue *CYLSize(id value) {
    if ([value isKindOfClass:[NSValue class]] && ![value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSDictionary class]]) {
        return [NSValue valueWithCGSize:CGSizeMake([CYLNumber(value[@"width"]) doubleValue], [CYLNumber(value[@"height"]) doubleValue])];
    }
    NSNumber *side = CYLNumber(value);
    if (side != nil) return [NSValue valueWithCGSize:CGSizeMake(side.doubleValue, side.doubleValue)];
    NSArray<NSNumber *> *n = CYLNumbers(value, 2);
    return n ? [NSValue valueWithCGSize:CGSizeMake(n[0].doubleValue, n[1].doubleValue)] : nil;
}

static NSValue *CYLOffset(id value) {
    if ([value isKindOfClass:[NSValue class]] && ![value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSDictionary class]]) {
        return [NSValue valueWithUIOffset:UIOffsetMake([CYLNumber(value[@"horizontal"]) doubleValue], [CYLNumber(value[@"vertical"]) doubleValue])];
    }
    NSArray<NSNumber *> *n = CYLNumbers(value, 2);
    return n ? [NSValue valueWithUIOffset:UIOffsetMake(n[0].doubleValue, n[1].doubleValue)] : nil;
}

static UIColor *CYLColor(id value) {
    if ([value isKindOfClass:[UIColor class]]) return value;
    if (![value isKindOfClass:[NSString class]]) return nil;
    NSString *string = [value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    if ([string hasPrefix:@"#"]) {
        NSString *hex = [string substringFromIndex:1];
        if (hex.length == 3) {
            hex = [NSString stringWithFormat:@"%C%C%C%C%C%C", [hex characterAtIndex:0], [hex characterAtIndex:0],
                   [hex characterAtIndex:1], [hex characterAtIndex:1], [hex characterAtIndex:2], [hex characterAtIndex:2]];
        }
        unsigned long long rgba = 0;
        if ((hex.length != 6 && hex.length != 8) || ![[NSScanner scannerWithString:hex] scanHexLongLong:&rgba]) return nil;
        if (hex.length == 6) rgba = (rgba << 8) | 0xFF;
        return [UIColor colorWithRed:((rgba >> 24) & 0xFF) / 255.0 green:((rgba >> 16) & 0xFF) / 255.0
                                blue:((rgba >> 8) & 0xFF) / 255.0 alpha:(rgba & 0xFF) / 255.0];
    }
    // A UIColor class property name: "systemBlue" or "systemBlueColor".
    NSString *name = [string hasSuffix:@"Color"] ? string : [string stringByAppendingString:@"Color"];
    SEL selector = NSSelectorFromString(name);
    if ([UIColor respondsToSelector:selector]) {
        id color = ((id (*)(id, SEL))[UIColor methodForSelector:selector])([UIColor class], selector);
        return [color isKindOfClass:[UIColor class]] ? color : nil;
    }
    return nil;
}

static UIFont *CYLFont(id value) {
    if ([value isKindOfClass:[UIFont class]]) return value;
    NSNumber *size = CYLNumber(value);
    if (size != nil) return [UIFont systemFontOfSize:size.doubleValue];
    if (![value isKindOfClass:[NSDictionary class]]) return nil;
    CGFloat pointSize = [CYLNumber(value[@"size"]) doubleValue] ?: 14;
    NSDictionary<NSString *, NSNumber *> *weights = @{@"ultralight": @(UIFontWeightUltraLight), @"thin": @(UIFontWeightThin),
        @"light": @(UIFontWeightLight), @"regular": @(UIFontWeightRegular), @"medium": @(UIFontWeightMedium),
        @"semibold": @(UIFontWeightSemibold), @"bold": @(UIFontWeightBold), @"heavy": @(UIFontWeightHeavy), @"black": @(UIFontWeightBlack)};
    UIFont *font = nil;
    if ([value[@"name"] isKindOfClass:[NSString class]]) {
        font = [UIFont fontWithName:value[@"name"] size:pointSize];
    }
    if (!font) {
        NSString *weightName = [value[@"weight"] isKindOfClass:[NSString class]] ? [value[@"weight"] lowercaseString] : nil;
        NSNumber *weight = (weightName ? weights[weightName] : nil) ?: @(UIFontWeightRegular);
        font = [UIFont systemFontOfSize:pointSize weight:weight.doubleValue];
    }
    if ([CYLNumber(value[@"italic"]) boolValue]) {
        UIFontDescriptor *italic = [font.fontDescriptor fontDescriptorWithSymbolicTraits:font.fontDescriptor.symbolicTraits | UIFontDescriptorTraitItalic];
        if (italic) font = [UIFont fontWithDescriptor:italic size:pointSize];
    }
    return font;
}

NSURL *CYLMenuAnimationURLWithOptions(NSURL *fileURL, NSDictionary<NSString *, id> *options) {
    if (![fileURL isKindOfClass:[NSURL class]]) return nil;
    if (![options isKindOfClass:[NSDictionary class]] || options.count == 0) return fileURL;
    NSURLComponents *components = [NSURLComponents componentsWithURL:fileURL resolvingAgainstBaseURL:YES];
    if (!components) return fileURL;
    NSMutableCharacterSet *allowed = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowed removeCharactersInString:@"&=+#?"];
    NSMutableArray<NSString *> *names = [NSMutableArray array];
    for (id name in options) {
        if ([name isKindOfClass:[NSString class]] && [(NSString *)name length] > 0) [names addObject:name];
    }
    [names sortUsingSelector:@selector(compare:)];
    NSMutableArray<NSString *> *items = [NSMutableArray array];
    for (NSString *name in names) {
        id value = options[name];
        NSString *string = [value isKindOfClass:[NSString class]] ? value : ([value isKindOfClass:[NSNumber class]] ? [value stringValue] : nil);
        NSString *encodedName = [name stringByAddingPercentEncodingWithAllowedCharacters:allowed];
        NSString *encodedValue = [string stringByAddingPercentEncodingWithAllowedCharacters:allowed];
        if (encodedName.length > 0 && encodedValue.length > 0) {
            [items addObject:[NSString stringWithFormat:@"%@=%@", encodedName, encodedValue]];
        }
    }
    components.percentEncodedFragment = items.count > 0 ? [items componentsJoinedByString:@"&"] : nil;
    return components.URL ?: fileURL;
}

static NSURL *CYLFileURL(id value, NSURL *baseURL) {
    if ([value isKindOfClass:[NSURL class]]) return value;
    if (![value isKindOfClass:[NSString class]] || [value length] == 0) return nil;
    NSString *string = value;
    // "file.riv#artboard=HOME": resolve the file, then keep the options.
    NSRange hash = [string rangeOfString:@"#"];
    if (hash.location != NSNotFound && hash.location > 0 && [NSURL URLWithString:string].scheme.length <= 1) {
        NSURL *file = CYLFileURL([string substringToIndex:hash.location], baseURL);
        NSURLComponents *components = file ? [NSURLComponents componentsWithURL:file resolvingAgainstBaseURL:YES] : nil;
        components.percentEncodedFragment = [string substringFromIndex:hash.location + 1];
        return components.URL ?: file;
    }
    NSURL *URL = [NSURL URLWithString:string];
    if (URL.scheme.length > 1) return URL;
    if (string.isAbsolutePath) return [NSURL fileURLWithPath:string];
    NSFileManager *files = [NSFileManager defaultManager];
    NSMutableArray<NSURL *> *candidates = [NSMutableArray array];
    if (baseURL) [candidates addObject:[baseURL URLByAppendingPathComponent:string]];
    if (NSBundle.mainBundle.resourceURL) [candidates addObject:[NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:string]];
    for (NSURL *candidate in candidates) {
        if ([files fileExistsAtPath:candidate.path]) return candidate;
    }
    NSString *name = string.stringByDeletingPathExtension;
    NSString *extension = string.pathExtension.length > 0 ? string.pathExtension : nil;
    return [NSBundle.mainBundle URLForResource:name withExtension:extension];
}

static UIImage *CYLImage(id value, NSURL *baseURL) {
    if ([value isKindOfClass:[UIImage class]]) return value;
    if (![value isKindOfClass:[NSString class]] || [value length] == 0) return nil;
    NSString *string = value;
    if ([string hasPrefix:@"system:"]) {
        return [UIImage systemImageNamed:[string substringFromIndex:7]];
    }
    UIImage *image = [UIImage imageNamed:string];
    if (image) return image;
    NSURL *URL = CYLFileURL(string, baseURL);
    return URL.isFileURL ? [UIImage imageWithContentsOfFile:URL.path] : nil;
}

static NSInteger CYLEnum(id value, NSDictionary<NSString *, NSNumber *> *names, NSInteger fallback) {
    if ([value isKindOfClass:[NSNumber class]]) return [value integerValue];
    if ([value isKindOfClass:[NSString class]]) {
        NSNumber *number = names[[value lowercaseString]] ?: CYLNumber(value);
        if (number != nil) return number.integerValue;
    }
    return fallback;
}

#pragma mark - Data source built from a configuration

@interface CYLTagListConfigurationSource : NSObject <CYLMenuDataSource>
@property (nonatomic, copy) NSArray<NSDictionary *> *sections;
@property (nonatomic, strong, nullable) NSURL *baseURL;
/// The view whose style a section style dictionary starts from.
@property (nonatomic, weak, nullable) CYLTagListView *owner;
/// Section -> @[list style it was made from, section style], so the same object is returned until the list's style changes.
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSArray *> *sectionStyles;
@end

@implementation CYLTagListConfigurationSource

- (NSArray *)itemsInSection:(NSInteger)section {
    id items = self.sections[section][CYLTagSectionItems];
    return [items isKindOfClass:[NSArray class]] ? items : @[];
}

- (NSDictionary *)itemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self itemsInSection:indexPath.section][indexPath.item];
    return [item isKindOfClass:[NSDictionary class]] ? item : @{CYLTagItemTitle: [item description] ?: @""};
}

- (NSInteger)numberOfSectionsInMenu {
    return self.sections.count;
}

- (NSInteger)menuNumberOfItemsInSection:(NSInteger)section {
    return [self itemsInSection:section].count;
}

- (NSString *)menuTitleForSection:(NSInteger)section {
    return [self.sections[section][CYLTagSectionTitle] description] ?: @"";
}

- (NSString *)menuTitleForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [[self itemAtIndexPath:indexPath][CYLTagItemTitle] description] ?: @"";
}

- (UIImage *)menuImageForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CYLImage([self itemAtIndexPath:indexPath][CYLTagItemImage], self.baseURL);
}

- (UIImage *)menuSelectedImageForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CYLImage([self itemAtIndexPath:indexPath][CYLTagItemSelectedImage], self.baseURL);
}

- (NSURL *)menuAnimationURLForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [self itemAtIndexPath:indexPath];
    return CYLMenuAnimationURLWithOptions(CYLFileURL(item[CYLTagItemAnimation], self.baseURL), item[CYLTagItemAnimationOptions]);
}

- (UIImage *)menuImageForSection:(NSInteger)section {
    return CYLImage(self.sections[section][CYLTagSectionImage], self.baseURL);
}

- (NSNumber *)menuAnimationRestingProgressForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CYLNumber([self itemAtIndexPath:indexPath][CYLTagItemAnimationRestingProgress]);
}

- (CYLMenuStyle *)menuStyleForSection:(NSInteger)section {
    id value = section < (NSInteger)self.sections.count ? self.sections[section][CYLTagSectionStyle] : nil;
    if ([value isKindOfClass:[CYLMenuStyle class]]) return value;
    if (![value isKindOfClass:[NSDictionary class]]) return nil;
    CYLMenuStyle *base = self.owner.style ?: [CYLMenuStyle defaultStyle];
    NSArray *cached = self.sectionStyles[@(section)];
    if (cached && cached[0] == base) return cached[1];
    CYLMenuStyle *style = [base copy];
    [style applyConfiguration:value];
    if (!self.sectionStyles) self.sectionStyles = [NSMutableDictionary dictionary];
    self.sectionStyles[@(section)] = @[base, style];
    return style;
}

- (BOOL)menuItemIsEnabledAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *enabled = CYLNumber([self itemAtIndexPath:indexPath][CYLTagItemEnabled]);
    return enabled != nil ? enabled.boolValue : YES;
}

- (BOOL)menuItemIsExclusiveAtIndexPath:(NSIndexPath *)indexPath {
    return [CYLNumber([self itemAtIndexPath:indexPath][CYLTagItemExclusive]) boolValue];
}

- (CYLMenuItemType)menuItemTypeAtIndexPath:(NSIndexPath *)indexPath {
    return CYLEnum([self itemAtIndexPath:indexPath][CYLTagItemType], @{@"tag": @(CYLMenuItemTypeTag), @"create": @(CYLMenuItemTypeCreate),
                                                                       @"new": @(CYLMenuItemTypeCreate)}, CYLMenuItemTypeTag);
}

@end

#pragma mark - Fold control

@implementation CYLMenuFoldControl (CYLConfiguration)

+ (instancetype)foldControlWithConfiguration:(id)configuration {
    if ([configuration isKindOfClass:[CYLMenuFoldControl class]]) {
        return [configuration copy];
    }
    CYLMenuFoldControl *control = [CYLMenuFoldControl noFoldControl];
    if ([configuration isKindOfClass:[NSString class]] || [configuration isKindOfClass:[NSNumber class]]) {
        // A position alone: the content that suits it (an icon below, a title in the header).
        [control applyConfiguration:@{CYLMenuFoldControlKeyPosition: configuration}];
        control.content = control.position == CYLMenuFoldControlPositionBottom ? CYLMenuFoldControlContentIcon : CYLMenuFoldControlContentIconAndTitle;
        return control;
    }
    if (![configuration isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    [control applyConfiguration:configuration];
    return control;
}

- (void)applyConfiguration:(NSDictionary<NSString *, id> *)configuration {
    if (![configuration isKindOfClass:[NSDictionary class]]) return;
    id value;
    if ((value = configuration[CYLMenuFoldControlKeyPosition])) {
        self.position = CYLEnum(value, @{@"none": @(CYLMenuFoldControlPositionNone), @"bottom": @(CYLMenuFoldControlPositionBottom),
                                         @"toptrailing": @(CYLMenuFoldControlPositionTopTrailing), @"topright": @(CYLMenuFoldControlPositionTopTrailing),
                                         @"topleading": @(CYLMenuFoldControlPositionTopLeading), @"topleft": @(CYLMenuFoldControlPositionTopLeading)},
                                self.position);
    }
    if ((value = configuration[CYLMenuFoldControlKeyContent])) {
        self.content = CYLEnum(value, @{@"iconandtitle": @(CYLMenuFoldControlContentIconAndTitle), @"titleandicon": @(CYLMenuFoldControlContentIconAndTitle),
                                        @"title": @(CYLMenuFoldControlContentTitle), @"icon": @(CYLMenuFoldControlContentIcon)}, self.content);
    }
    if ([configuration[CYLMenuFoldControlKeyTitle] isKindOfClass:[NSString class]]) self.title = configuration[CYLMenuFoldControlKeyTitle];
    if ([configuration[CYLMenuFoldControlKeyCollapseTitle] isKindOfClass:[NSString class]]) self.collapseTitle = configuration[CYLMenuFoldControlKeyCollapseTitle];
    if ((value = CYLImage(configuration[CYLMenuFoldControlKeyImage], configuration[kCYLConfigurationBaseURL]))) self.image = value;
    if ((value = CYLColor(configuration[CYLMenuFoldControlKeyColor]))) self.color = value;
    if ((value = CYLFont(configuration[CYLMenuFoldControlKeyFont]))) self.font = value;
    if ((value = CYLNumber(configuration[CYLMenuFoldControlKeyRotatesImage]))) self.rotatesImageWhenExpanded = [value boolValue];
}

@end

#pragma mark - Style

@implementation CYLTagAppearance (CYLConfiguration)

- (void)applyConfiguration:(NSDictionary<NSString *, id> *)configuration {
    if (![configuration isKindOfClass:[NSDictionary class]]) return;
    id value;
    if ((value = configuration[CYLTagAppearanceBackgroundColor])) self.backgroundColor = CYLColor(value);
    if ((value = configuration[CYLTagAppearanceTextColor])) self.textColor = CYLColor(value);
    if ((value = configuration[CYLTagAppearanceFont])) self.font = CYLFont(value);
    if ((value = configuration[CYLTagAppearanceIconColor])) self.iconColor = CYLColor(value);
    if ((value = configuration[CYLTagAppearanceBorderColor])) self.borderColor = CYLColor(value);
    if ((value = CYLNumber(configuration[CYLTagAppearanceCornerRadius]))) self.cornerRadius = [value doubleValue];
    if ((value = CYLNumber(configuration[CYLTagAppearanceBorderWidth]))) self.borderWidth = [value doubleValue];
    if ((value = CYLNumber(configuration[CYLTagAppearanceMargin]))) self.margin = [value doubleValue];
}

@end

@implementation CYLMenuStyle (CYLConfiguration)

+ (instancetype)styleWithConfiguration:(NSDictionary<NSString *, id> *)configuration {
    CYLMenuStyle *style = [self defaultStyle];
    [style applyConfiguration:configuration];
    return style;
}

- (void)applyConfiguration:(NSDictionary<NSString *, id> *)configuration {
    if (![configuration isKindOfClass:[NSDictionary class]]) return;
    [self.normalAppearance applyConfiguration:configuration[CYLMenuStyleNormal]];
    [self.selectedAppearance applyConfiguration:configuration[CYLMenuStyleSelected]];
    [self.disabledAppearance applyConfiguration:configuration[CYLMenuStyleDisabled]];
    id value;
    if ((value = CYLNumber(configuration[CYLMenuStyleImageTitleSpacing]))) self.imageTitleSpacing = [value doubleValue];
    if ((value = CYLNumber(configuration[CYLMenuStyleItemHeight]))) self.itemHeight = [value doubleValue];
    if ((value = CYLNumber(configuration[CYLMenuStyleInteritemSpacing]))) self.interitemSpacing = [value doubleValue];
    if ((value = CYLNumber(configuration[CYLMenuStyleLineSpacing]))) self.lineSpacing = [value doubleValue];
    if ((value = CYLNumber(configuration[CYLMenuStyleHeaderHeight]))) self.headerHeight = [value doubleValue];
    if ((value = CYLNumber(configuration[CYLMenuStyleAnimationSpeed]))) self.animationSpeed = [value doubleValue];
    if ((value = CYLNumber(configuration[CYLMenuStyleLayoutCentered]))) self.layoutCentered = [value boolValue];
    if ((value = CYLNumber(configuration[CYLMenuStyleAdjustsFontForContentSizeCategory]))) self.adjustsFontForContentSizeCategory = [value boolValue];
    if ((value = CYLSize(configuration[CYLMenuStyleImageSize]))) self.imageSize = [value CGSizeValue];
    if ((value = CYLSize(configuration[CYLMenuStyleAnimationSize]))) self.animationSize = [value CGSizeValue];
    if ((value = CYLInsets(configuration[CYLMenuStyleImageInsets]))) self.imageInsets = [value UIEdgeInsetsValue];
    if ((value = CYLInsets(configuration[CYLMenuStyleSectionInsets]))) self.sectionInsets = [value UIEdgeInsetsValue];
    if ((value = CYLOffset(configuration[CYLMenuStyleTitlePositionAdjustment]))) self.titlePositionAdjustment = [value UIOffsetValue];
    if ((value = CYLOffset(configuration[CYLMenuStyleImagePositionAdjustment]))) self.imagePositionAdjustment = [value UIOffsetValue];
    if ((value = CYLColor(configuration[CYLMenuStyleBackgroundColor]))) self.backgroundColor = value;
    if ((value = CYLColor(configuration[CYLMenuStyleHeaderTextColor]))) self.headerTextColor = value;
    if ((value = CYLColor(configuration[CYLMenuStyleFoldControlColor]))) self.foldControlColor = value;
    if ((value = CYLFont(configuration[CYLMenuStyleHeaderFont]))) self.headerFont = value;
}

@end

#pragma mark - Tag list

@implementation CYLTagListView (CYLConfiguration)

- (instancetype)initWithConfiguration:(NSDictionary<NSString *, id> *)configuration {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        [self applyConfiguration:configuration];
    }
    return self;
}

+ (instancetype)tagListViewWithConfiguration:(NSDictionary<NSString *, id> *)configuration {
    return [[self alloc] initWithConfiguration:configuration];
}

- (id<CYLMenuDataSource>)configurationDataSource {
    return objc_getAssociatedObject(self, @selector(configurationDataSource));
}

- (void)applyConfiguration:(NSDictionary<NSString *, id> *)configuration {
    if (![configuration isKindOfClass:[NSDictionary class]]) return;
    NSURL *baseURL = configuration[kCYLConfigurationBaseURL];
    id value;
    if ((value = configuration[CYLTagListViewStyle])) {
        if ([value isKindOfClass:[CYLMenuStyle class]]) {
            self.style = value;
        } else {
            CYLMenuStyle *style = [self.style copy];
            [style applyConfiguration:value];
            self.style = style;
        }
    }
    if ((value = configuration[CYLTagListViewSelectionMode])) {
        self.selectionMode = CYLEnum(value, @{@"none": @(CYLMenuSelectionModeNone), @"single": @(CYLMenuSelectionModeSingle),
                                              @"multiple": @(CYLMenuSelectionModeMultiple)}, self.selectionMode);
    }
    if ((value = configuration[CYLTagListViewFoldStyle])) {
        self.foldStyle = CYLEnum(value, @{@"none": @(CYLMenuFoldStyleNone), @"headerbutton": @(CYLMenuFoldStyleHeaderButton),
                                          @"footerchevron": @(CYLMenuFoldStyleFooterChevron), @"truncate": @(CYLMenuFoldStyleTruncate)}, self.foldStyle);
    }
    if ((value = configuration[CYLTagListViewFoldControl])) {
        if ([value isKindOfClass:[NSDictionary class]] && [baseURL isKindOfClass:[NSURL class]]) {
            // A relative image file of the control resolves next to the configuration file.
            NSMutableDictionary *withBase = [value mutableCopy];
            withBase[kCYLConfigurationBaseURL] = baseURL;
            value = withBase;
        }
        CYLMenuFoldControl *control = [CYLMenuFoldControl foldControlWithConfiguration:value];
        if (control) {
            self.foldControl = control;
        }
    }
    if ((value = configuration[CYLTagListViewTitlePosition])) {
        self.titlePosition = CYLEnum(value, @{@"topleading": @(CYLMenuTitlePositionTopLeading), @"leading": @(CYLMenuTitlePositionTopLeading),
                                              @"left": @(CYLMenuTitlePositionTopLeading), @"topcenter": @(CYLMenuTitlePositionTopCenter),
                                              @"center": @(CYLMenuTitlePositionTopCenter)}, self.titlePosition);
    }
    if ((value = configuration[CYLTagListViewTitleStyle])) {
        if ([value isKindOfClass:[CYLMenuStyle class]]) {
            self.titleStyle = value;
        } else {
            CYLMenuStyle *titleStyle = [[CYLTagListView defaultTitleStyle] copy];
            [titleStyle applyConfiguration:value];
            self.titleStyle = titleStyle;
        }
    }
    if ((value = CYLImage(configuration[CYLTagListViewTitleImage], [baseURL isKindOfClass:[NSURL class]] ? baseURL : nil))) {
        self.titleImage = value;
    }
    if ([configuration[CYLTagListViewTitle] isKindOfClass:[NSString class]]) {
        self.title = configuration[CYLTagListViewTitle];
    }
    if ((value = CYLNumber(configuration[CYLTagListViewAllowsEmptySelection]))) self.allowsEmptySelection = [value boolValue];
    if ((value = CYLNumber(configuration[CYLTagListViewShowsSectionHeaders]))) self.showsSectionHeaders = [value boolValue];
    if ((value = CYLNumber(configuration[CYLTagListViewScrollEnabled]))) self.scrollEnabled = [value boolValue];
    if ((value = CYLNumber(configuration[CYLTagListViewDefaultVisibleRows]))) self.defaultVisibleRows = [value unsignedIntegerValue];
    if ([configuration[CYLTagListViewSections] isKindOfClass:[NSArray class]]) {
        CYLTagListConfigurationSource *source = [[CYLTagListConfigurationSource alloc] init];
        source.sections = configuration[CYLTagListViewSections];
        source.baseURL = [baseURL isKindOfClass:[NSURL class]] ? baseURL : nil;
        source.owner = self;
        // The view holds its data source weakly: keep this one alive with the view.
        objc_setAssociatedObject(self, @selector(configurationDataSource), source, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.menuDataSource = source;
        [self reloadMenuData];
    }
    if ([configuration[CYLTagListViewSelectedItems] isKindOfClass:[NSArray class]]) {
        NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
        for (id item in configuration[CYLTagListViewSelectedItems]) {
            NSIndexPath *indexPath = [item isKindOfClass:[NSIndexPath class]] ? item : nil;
            if (!indexPath) {
                NSArray<NSNumber *> *pair = [item isKindOfClass:[NSString class]]
                    ? CYLNumbers([item stringByReplacingOccurrencesOfString:@"-" withString:@","], 2) : CYLNumbers(item, 2);
                if (pair) indexPath = [NSIndexPath indexPathForItem:pair[1].integerValue inSection:pair[0].integerValue];
            }
            if (indexPath) [indexPaths addObject:indexPath];
        }
        self.selectedIndexPaths = indexPaths;
    }
}

+ (NSDictionary<NSString *, id> *)configurationWithContentsOfFile:(NSString *)filePath error:(NSError **)error {
    NSURL *URL = CYLFileURL(filePath, nil);
    if (!URL.isFileURL || ![[NSFileManager defaultManager] fileExistsAtPath:URL.path]) {
        if (error) *error = [NSError errorWithDomain:CYLMenuConfigurationErrorDomain code:CYLMenuConfigurationErrorFileNotFound
                                            userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No configuration file at %@", filePath]}];
        return nil;
    }
    NSString *extension = URL.pathExtension.lowercaseString;
    id contents = nil;
    NSError *readError = nil;
    if ([@[@"json", @"plist", @""] containsObject:extension]) {
        NSData *data = [NSData dataWithContentsOfURL:URL options:0 error:&readError];
        if (data) {
            contents = [extension isEqualToString:@"plist"]
                ? [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&readError]
                : [NSJSONSerialization JSONObjectWithData:data options:0 error:&readError];
            if (!contents && extension.length == 0) {
                contents = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:NULL];
            }
        }
    } else {
        // JSON5, YAML, TOML, INI, .properties, XML…: CYLTabBarController's configuration parser, when it is linked
        // (found at runtime: this library does not depend on CYLTabBarController). The values are read below by this
        // project's rules.
        Class parser = NSClassFromString(@"CYLTabBarConfigurationParser");
        // By name: the parser's method is not declared here (no dependency on CYLTabBarController).
        SEL read = NSSelectorFromString(@"dictionaryWithContentsOfFile:error:");
        if (![parser respondsToSelector:read]) {
            parser = NSClassFromString(@"CYLTabBarController");
            read = @selector(configurationWithContentsOfFile:error:);
        }
        if (![parser respondsToSelector:read]) {
            if (error) *error = [NSError errorWithDomain:CYLMenuConfigurationErrorDomain code:CYLMenuConfigurationErrorUnsupportedFormat
                                                userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Reading .%@ files needs CYLTabBarController; use JSON or a property list.", extension]}];
            return nil;
        }
        contents = ((id (*)(id, SEL, NSString *, NSError **))[parser methodForSelector:read])(parser, read, URL.path, &readError);
    }
    if (![contents isKindOfClass:[NSDictionary class]]) {
        if (error) *error = readError ?: [NSError errorWithDomain:CYLMenuConfigurationErrorDomain code:CYLMenuConfigurationErrorInvalidContents
                                                         userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@ does not hold a dictionary", filePath]}];
        return nil;
    }
    NSMutableDictionary *configuration = [contents mutableCopy];
    configuration[kCYLConfigurationBaseURL] = URL.URLByDeletingLastPathComponent;
    return configuration;
}

- (instancetype)initWithConfigurationFile:(NSString *)filePath error:(NSError **)error {
    NSDictionary *configuration = [[self class] configurationWithContentsOfFile:filePath error:error];
    if (!configuration) {
        return nil;
    }
    return [self initWithConfiguration:configuration];
}

+ (instancetype)tagListViewWithConfigurationFile:(NSString *)filePath error:(NSError **)error {
    return [[self alloc] initWithConfigurationFile:filePath error:error];
}

@end
