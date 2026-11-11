//
//  CYLTag.m
//  CollectionViewClassifyMenu
//

#import "CYLTag.h"
#import "CYLTagListView+CYLConfiguration.h"

const CGFloat CYLTagUseListValue = -1;

static BOOL CYLTagIsSet(CGFloat value) {
    return isfinite(value) && value >= 0;
}

@implementation CYLTag

- (instancetype)initWithIdentifier:(NSInteger)identifier title:(NSString *)title backgroundColor:(UIColor *)backgroundColor {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _title = [title copy] ?: @"";
        _backgroundColor = backgroundColor;
        _enabled = YES;
        _textSize = CYLTagUseListValue;
        _cornerRadius = CYLTagUseListValue;
        _borderWidth = CYLTagUseListValue;
        _deleteIndicatorSize = CYLTagUseListValue;
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSInteger)identifier title:(NSString *)title backgroundColorHex:(NSString *)backgroundColorHex {
    return [self initWithIdentifier:identifier title:title backgroundColor:backgroundColorHex ? CYLMenuColorFromString(backgroundColorHex) : nil];
}

- (instancetype)initWithIdentifier:(NSInteger)identifier title:(NSString *)title {
    return [self initWithIdentifier:identifier title:title backgroundColor:nil];
}

- (instancetype)initWithTitle:(NSString *)title {
    return [self initWithIdentifier:0 title:title backgroundColor:nil];
}

- (instancetype)initWithTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor {
    return [self initWithIdentifier:0 title:title backgroundColor:backgroundColor];
}

- (instancetype)initWithTitle:(NSString *)title backgroundColorHex:(NSString *)backgroundColorHex {
    return [self initWithIdentifier:0 title:title backgroundColorHex:backgroundColorHex];
}

+ (instancetype)tagWithTitle:(NSString *)title {
    return [[self alloc] initWithTitle:title];
}

- (void)setTitle:(NSString *)title {
    _title = [title copy] ?: @"";
}

- (id)copyWithZone:(NSZone *)zone {
    CYLTag *copy = [[[self class] allocWithZone:zone] initWithIdentifier:self.identifier title:self.title backgroundColor:self.backgroundColor];
    copy.image = self.image;
    copy.selectedImage = self.selectedImage;
    copy.animationURL = self.animationURL;
    copy.enabled = self.enabled;
    copy.deletable = self.deletable;
    copy.userInfo = self.userInfo;
    copy.style = self.style;
    copy.textColor = self.textColor;
    copy.font = self.font;
    copy.textSize = self.textSize;
    copy.highlightedBackgroundColor = self.highlightedBackgroundColor;
    copy.selectedBackgroundColor = self.selectedBackgroundColor;
    copy.badgeText = self.badgeText;
    copy.badgeColor = self.badgeColor;
    copy.backgroundImage = self.backgroundImage;
    copy.cornerRadius = self.cornerRadius;
    copy.borderWidth = self.borderWidth;
    copy.borderColor = self.borderColor;
    copy.deleteIndicatorTitle = self.deleteIndicatorTitle;
    copy.deleteIndicatorColor = self.deleteIndicatorColor;
    copy.deleteIndicatorSize = self.deleteIndicatorSize;
    return copy;
}

- (CYLTagColors *)colors {
    return [CYLTagColors colorsWithBackgroundColor:self.backgroundColor borderColor:self.borderColor textColor:self.textColor
                           selectedBackgroundColor:self.selectedBackgroundColor];
}

- (void)setColors:(CYLTagColors *)colors {
    self.backgroundColor = colors.backgroundColor;
    self.borderColor = colors.borderColor;
    self.textColor = colors.textColor;
    self.selectedBackgroundColor = colors.selectedBackgroundColor;
}

+ (UIImage *)badgeImageWithText:(NSString *)text color:(UIColor *)color diameter:(CGFloat)diameter {
    CGFloat side = MAX(1, diameter);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(side, side)];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [(color ?: [UIColor systemBlueColor]) setFill];
        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, side, side)] fill];
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:side * 0.6],
                                     NSForegroundColorAttributeName: [UIColor whiteColor]};
        CGSize size = [text sizeWithAttributes:attributes];
        [text drawAtPoint:CGPointMake((side - size.width) / 2, (side - size.height) / 2) withAttributes:attributes];
    }];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    image.accessibilityLabel = text;
    return image;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; identifier = %ld; title = %@>", NSStringFromClass([self class]), (void *)self,
                                      (long)self.identifier, self.title];
}

- (BOOL)hasCustomStyle {
    return self.style || self.textColor || self.font || CYLTagIsSet(self.textSize) || self.backgroundColor ||
           self.highlightedBackgroundColor || self.selectedBackgroundColor || self.backgroundImage || CYLTagIsSet(self.cornerRadius) ||
           CYLTagIsSet(self.borderWidth) || self.borderColor || self.deleteIndicatorTitle || self.deleteIndicatorColor ||
           CYLTagIsSet(self.deleteIndicatorSize);
}

- (CYLMenuStyle *)styleWithBaseStyle:(CYLMenuStyle *)baseStyle {
    CYLMenuStyle *style = [(self.style ?: baseStyle ?: [CYLMenuStyle defaultStyle]) copy];
    CYLTagAppearance *normal = style.normalAppearance;
    NSArray<CYLTagAppearance *> *all = @[normal, style.selectedAppearance, style.disabledAppearance];
    if (self.textColor) normal.textColor = self.textColor;
    if (self.backgroundColor) normal.backgroundColor = self.backgroundColor;
    if (self.backgroundImage) normal.backgroundImage = self.backgroundImage;
    if (self.borderColor) {
        normal.borderColor = self.borderColor;
        if (!CYLTagIsSet(self.borderWidth) && normal.borderWidth <= 0) normal.borderWidth = 1;
    }
    UIFont *font = self.font ?: (CYLTagIsSet(self.textSize) && self.textSize > 0 ? [UIFont systemFontOfSize:self.textSize] : nil);
    for (CYLTagAppearance *appearance in all) {
        if (font) appearance.font = font;
        if (CYLTagIsSet(self.cornerRadius)) appearance.cornerRadius = self.cornerRadius;
        if (CYLTagIsSet(self.borderWidth)) appearance.borderWidth = self.borderWidth;
    }
    if (self.highlightedBackgroundColor) style.highlightedBackgroundColor = self.highlightedBackgroundColor;
    if (self.selectedBackgroundColor) style.selectedAppearance.backgroundColor = self.selectedBackgroundColor;
    if (self.deleteIndicatorTitle) style.deleteIndicatorTitle = self.deleteIndicatorTitle;
    if (self.deleteIndicatorColor) style.deleteIndicatorColor = self.deleteIndicatorColor;
    if (CYLTagIsSet(self.deleteIndicatorSize) && self.deleteIndicatorSize > 0) {
        style.deleteIndicatorFont = [UIFont systemFontOfSize:self.deleteIndicatorSize];
    }
    return style;
}

@end

@interface CYLTagDataSource ()
@property (nonatomic, strong) NSMutableArray<CYLTag *> *mutableTags;
/// Tag -> its style built from `baseStyle`, so that the same object is returned until something changes.
@property (nonatomic, strong) NSMapTable<CYLTag *, CYLMenuStyle *> *styles;
@end

@implementation CYLTagDataSource

@synthesize baseStyle = _baseStyle;

- (instancetype)init {
    return [self initWithTags:nil];
}

- (instancetype)initWithTags:(NSArray<CYLTag *> *)tags {
    self = [super init];
    if (self) {
        _mutableTags = [NSMutableArray arrayWithArray:tags ?: @[]];
        _styles = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}

- (NSArray<CYLTag *> *)tags {
    return [self.mutableTags copy];
}

- (void)setTags:(NSArray<CYLTag *> *)tags {
    self.mutableTags = [NSMutableArray arrayWithArray:tags ?: @[]];
    [self invalidateStyles];
}

- (CYLMenuStyle *)baseStyle {
    return _baseStyle ?: [CYLMenuStyle defaultStyle];
}

- (void)setBaseStyle:(CYLMenuStyle *)baseStyle {
    _baseStyle = [baseStyle copy];
    [self invalidateStyles];
}

- (void)addTag:(CYLTag *)tag {
    if (tag) [self.mutableTags addObject:tag];
}

- (void)addTags:(NSArray<CYLTag *> *)tags {
    if (tags.count > 0) [self.mutableTags addObjectsFromArray:tags];
}

- (void)insertTag:(CYLTag *)tag atIndex:(NSUInteger)index {
    if (tag) [self.mutableTags insertObject:tag atIndex:MIN(index, self.mutableTags.count)];
}

- (void)removeTagAtIndex:(NSUInteger)index {
    if (index < self.mutableTags.count) {
        [self.styles removeObjectForKey:self.mutableTags[index]];
        [self.mutableTags removeObjectAtIndex:index];
    }
}

- (void)moveTagAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    if (fromIndex >= self.mutableTags.count || toIndex >= self.mutableTags.count || fromIndex == toIndex) {
        return;
    }
    CYLTag *tag = self.mutableTags[fromIndex];
    [self.mutableTags removeObjectAtIndex:fromIndex];
    [self.mutableTags insertObject:tag atIndex:toIndex];
}

- (void)menuMoveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section == 0 && destinationIndexPath.section == 0) {
        [self moveTagAtIndex:(NSUInteger)sourceIndexPath.item toIndex:(NSUInteger)destinationIndexPath.item];
    }
}

- (void)removeAllTags {
    [self.mutableTags removeAllObjects];
    [self invalidateStyles];
}

- (void)invalidateStyles {
    [self.styles removeAllObjects];
}

- (CYLTag *)cyl_tagAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 && indexPath.item >= 0 && indexPath.item < (NSInteger)self.mutableTags.count
        ? self.mutableTags[indexPath.item] : nil;
}

#pragma mark CYLMenuDataSource

- (NSInteger)numberOfSectionsInMenu {
    return 1;
}

- (NSInteger)menuNumberOfItemsInSection:(NSInteger)section {
    return section == 0 ? (NSInteger)self.mutableTags.count : 0;
}

- (NSString *)menuTitleForSection:(NSInteger)section {
    return self.sectionTitle ?: @"";
}

- (NSString *)menuTitleForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self cyl_tagAtIndexPath:indexPath].title ?: @"";
}

- (UIImage *)menuImageForItemAtIndexPath:(NSIndexPath *)indexPath {
    CYLTag *tag = [self cyl_tagAtIndexPath:indexPath];
    if (!tag.image && tag.badgeText.length > 0) {
        CGFloat side = MAX(self.baseStyle.imageSize.width, self.baseStyle.imageSize.height);
        tag.image = [CYLTag badgeImageWithText:tag.badgeText color:tag.badgeColor ?: tag.textColor diameter:side > 0 ? side : 16];
    }
    return tag.image;
}

- (UIImage *)menuSelectedImageForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self cyl_tagAtIndexPath:indexPath].selectedImage;
}

- (NSURL *)menuAnimationURLForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self cyl_tagAtIndexPath:indexPath].animationURL;
}

- (BOOL)menuItemIsEnabledAtIndexPath:(NSIndexPath *)indexPath {
    CYLTag *tag = [self cyl_tagAtIndexPath:indexPath];
    return tag ? tag.enabled : YES;
}

- (BOOL)menuItemIsDeletableAtIndexPath:(NSIndexPath *)indexPath {
    return [self cyl_tagAtIndexPath:indexPath].deletable;
}

- (void)menuRemoveItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self cyl_tagAtIndexPath:indexPath]) {
        [self removeTagAtIndex:(NSUInteger)indexPath.item];
    }
}

- (CYLMenuStyle *)menuStyleForItemAtIndexPath:(NSIndexPath *)indexPath {
    CYLTag *tag = [self cyl_tagAtIndexPath:indexPath];
    if (!tag.hasCustomStyle) {
        return nil;
    }
    CYLMenuStyle *style = [self.styles objectForKey:tag];
    if (!style) {
        style = [tag styleWithBaseStyle:self.baseStyle];
        [self.styles setObject:style forKey:tag];
    }
    return style;
}

@end
