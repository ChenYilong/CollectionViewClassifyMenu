//
//  CYLMenuStyle.m
//  CollectionViewClassifyMenu
//

#import "CYLMenuStyle.h"
#import "CYLParameterConfiguration.h"

@implementation CYLMenuStyle

+ (instancetype)defaultStyle {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _font = [UIFont systemFontOfSize:14];
        _adjustsFontForContentSizeCategory = YES;
        _textColor = [UIColor colorWithWhite:0.25 alpha:1];
        _selectedTextColor = [UIColor whiteColor];
        _disabledTextColor = [UIColor colorWithWhite:0.7 alpha:1];
        _itemBackgroundColor = [UIColor whiteColor];
        _selectedItemBackgroundColor = CYLAppTintColor;
        _borderColor = [UIColor colorWithWhite:0.82 alpha:1];
        _selectedBorderColor = CYLAppTintColor;
        _borderWidth = 1.0 / MAX(1, UIScreen.mainScreen.scale);
        _cornerRadius = 3;
        _itemHeight = 30;
        _itemHorizontalPadding = 10;
        _imageSize = CGSizeMake(14, 14);
        _imageTitleSpacing = 4;
        _interitemSpacing = 10;
        _lineSpacing = 10;
        _sectionInsets = UIEdgeInsetsMake(10, 16, 10, 16);
        _backgroundColor = [UIColor whiteColor];
        _headerHeight = 36;
        _headerFont = [UIFont systemFontOfSize:14];
        _headerTextColor = [UIColor grayColor];
        _headerHorizontalInset = 16;
        _foldControlColor = [UIColor grayColor];
        _expandTitle = @"更多";
        _collapseTitle = @"收起";
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    CYLMenuStyle *copy = [[[self class] allocWithZone:zone] init];
    copy.font = self.font;
    copy.adjustsFontForContentSizeCategory = self.adjustsFontForContentSizeCategory;
    copy.textColor = self.textColor;
    copy.selectedTextColor = self.selectedTextColor;
    copy.disabledTextColor = self.disabledTextColor;
    copy.itemBackgroundColor = self.itemBackgroundColor;
    copy.selectedItemBackgroundColor = self.selectedItemBackgroundColor;
    copy.borderColor = self.borderColor;
    copy.selectedBorderColor = self.selectedBorderColor;
    copy.borderWidth = self.borderWidth;
    copy.cornerRadius = self.cornerRadius;
    copy.itemHeight = self.itemHeight;
    copy.itemHorizontalPadding = self.itemHorizontalPadding;
    copy.imageSize = self.imageSize;
    copy.imageTitleSpacing = self.imageTitleSpacing;
    copy.interitemSpacing = self.interitemSpacing;
    copy.lineSpacing = self.lineSpacing;
    copy.sectionInsets = self.sectionInsets;
    copy.backgroundColor = self.backgroundColor;
    copy.headerHeight = self.headerHeight;
    copy.headerFont = self.headerFont;
    copy.headerTextColor = self.headerTextColor;
    copy.headerHorizontalInset = self.headerHorizontalInset;
    copy.foldControlColor = self.foldControlColor;
    copy.expandTitle = self.expandTitle;
    copy.collapseTitle = self.collapseTitle;
    return copy;
}

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

- (UIFont *)itemFontForTraitCollection:(UITraitCollection *)traitCollection {
    return [self cyl_scaledFont:self.font traits:traitCollection];
}

- (UIFont *)headerFontForTraitCollection:(UITraitCollection *)traitCollection {
    return [self cyl_scaledFont:self.headerFont traits:traitCollection];
}

@end
