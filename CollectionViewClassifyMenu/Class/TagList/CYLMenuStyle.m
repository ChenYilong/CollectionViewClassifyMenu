//
//  CYLMenuStyle.m
//  CollectionViewClassifyMenu
//

#import "CYLMenuStyle.h"
#import "CYLParameterConfiguration.h"
#import "CYLMenuResources.h"

@interface CYLMenuStyle ()
@property (nonatomic, strong, readwrite) CYLTagAppearance *normalAppearance;
@property (nonatomic, strong, readwrite) CYLTagAppearance *selectedAppearance;
@property (nonatomic, strong, readwrite) CYLTagAppearance *disabledAppearance;
@end

@implementation CYLMenuStyle

+ (instancetype)defaultStyle {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        CGFloat hairline = 1.0 / MAX(1, UIScreen.mainScreen.scale);
        _normalAppearance = [[CYLTagAppearance alloc] init];
        _normalAppearance.borderColor = [UIColor colorWithWhite:0.82 alpha:1];
        _normalAppearance.borderWidth = hairline;
        _selectedAppearance = [[CYLTagAppearance alloc] init];
        _selectedAppearance.backgroundColor = CYLAppTintColor;
        _selectedAppearance.textColor = [UIColor whiteColor];
        _selectedAppearance.borderColor = CYLAppTintColor;
        _selectedAppearance.borderWidth = hairline;
        _disabledAppearance = [[CYLTagAppearance alloc] init];
        _disabledAppearance.textColor = [UIColor colorWithWhite:0.7 alpha:1];
        _disabledAppearance.borderColor = [UIColor colorWithWhite:0.88 alpha:1];
        _disabledAppearance.borderWidth = hairline;

        _imageTitleSpacing = 4;
        _imageSize = CGSizeMake(14, 14);
        _layoutCentered = YES;
        _animationSpeed = 1;
        _adjustsFontForContentSizeCategory = YES;
        _itemHeight = 30;
        _interitemSpacing = 10;
        _lineSpacing = 10;
        _sectionInsets = UIEdgeInsetsMake(10, 16, 10, 16);
        _backgroundColor = [UIColor whiteColor];
        _headerHeight = 36;
        _headerFont = [UIFont systemFontOfSize:14];
        _headerTextColor = [UIColor grayColor];
        _headerHorizontalInset = 16;
        _foldControlColor = [UIColor grayColor];
        _expandTitle = CYLMenuLocalizedString(@"CYLMenuExpand", @"Expand a section");
        _collapseTitle = CYLMenuLocalizedString(@"CYLMenuCollapse", @"Collapse a section");
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    CYLMenuStyle *copy = [[[self class] allocWithZone:zone] init];
    copy.normalAppearance = [self.normalAppearance copy];
    copy.selectedAppearance = [self.selectedAppearance copy];
    copy.disabledAppearance = [self.disabledAppearance copy];
    copy.imageTitleSpacing = self.imageTitleSpacing;
    copy.imageSize = self.imageSize;
    copy.imageInsets = self.imageInsets;
    copy.titlePositionAdjustment = self.titlePositionAdjustment;
    copy.imagePositionAdjustment = self.imagePositionAdjustment;
    copy.layoutCentered = self.layoutCentered;
    copy.animationSize = self.animationSize;
    copy.animationSpeed = self.animationSpeed;
    copy.adjustsFontForContentSizeCategory = self.adjustsFontForContentSizeCategory;
    copy.itemHeight = self.itemHeight;
    copy.interitemSpacing = self.interitemSpacing;
    copy.lineSpacing = self.lineSpacing;
    copy.sectionInsets = self.sectionInsets;
    copy.backgroundColor = self.backgroundColor;
    copy.headerHeight = self.headerHeight;
    copy.headerFont = self.headerFont;
    copy.headerTextColor = self.headerTextColor;
    copy.headerHorizontalInset = self.headerHorizontalInset;
    copy.foldControlColor = self.foldControlColor;
    copy.foldChevronImage = self.foldChevronImage;
    copy.expandTitle = self.expandTitle;
    copy.collapseTitle = self.collapseTitle;
    return copy;
}

#pragma mark Appearances

- (CYLTagAppearance *)appearanceForState:(UIControlState)state {
    if (state & UIControlStateDisabled) {
        return self.disabledAppearance;
    }
    if (state & UIControlStateSelected) {
        return self.selectedAppearance;
    }
    return self.normalAppearance;
}

- (void)setTitleTextAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes forState:(UIControlState)state {
    CYLTagAppearance *appearance = [self appearanceForState:state];
    appearance.font = attributes[NSFontAttributeName];
    appearance.textColor = attributes[NSForegroundColorAttributeName];
}

- (NSDictionary<NSAttributedStringKey, id> *)titleTextAttributesForState:(UIControlState)state {
    CYLTagAppearance *appearance = [self appearanceForState:state];
    return @{NSFontAttributeName: appearance.font, NSForegroundColorAttributeName: appearance.textColor};
}

- (void)setIconColor:(UIColor *)iconColor forState:(UIControlState)state {
    [self appearanceForState:state].iconColor = iconColor;
}

- (UIColor *)iconColorForState:(UIControlState)state {
    CYLTagAppearance *appearance = [self appearanceForState:state];
    return appearance.iconColor ?: appearance.textColor;
}

#pragma mark Fonts

- (UIFont *)cyl_scaledFont:(UIFont *)font traits:(UITraitCollection *)traits {
    UITraitCollection *effective = traits ?: [UITraitCollection currentTraitCollection];
    if (effective.legibilityWeight == UILegibilityWeightBold) {
        // Bold Text accessibility setting.
        UIFontDescriptor *bold = [font.fontDescriptor fontDescriptorWithSymbolicTraits:font.fontDescriptor.symbolicTraits | UIFontDescriptorTraitBold];
        if (bold) {
            font = [UIFont fontWithDescriptor:bold size:font.pointSize];
        }
    }
    if (!self.adjustsFontForContentSizeCategory) {
        return font;
    }
    return [[UIFontMetrics defaultMetrics] scaledFontForFont:font
                                            maximumPointSize:font.pointSize * CYLMaximumFontScale
                               compatibleWithTraitCollection:traits];
}

- (UIFont *)titleFontForState:(UIControlState)state traitCollection:(UITraitCollection *)traitCollection {
    return [self cyl_scaledFont:[self appearanceForState:state].font traits:traitCollection];
}

- (UIFont *)headerFontForTraitCollection:(UITraitCollection *)traitCollection {
    return [self cyl_scaledFont:self.headerFont traits:traitCollection];
}

@end
