//
//  CYLTagColors.m
//  CollectionViewClassifyMenu
//

#import "CYLTagColors.h"
#import "CYLMenuStyle.h"

const CGFloat CYLTagColorsBackgroundAlpha = 0x33 / 255.0;
const CGFloat CYLTagColorsBorderAlpha = 0x88 / 255.0;

static UIColor *CYLTagColorFromHex(NSString *hex, CGFloat alpha) {
    unsigned int rgb = 0;
    [[NSScanner scannerWithString:hex] scanHexInt:&rgb];
    return [UIColor colorWithRed:((rgb >> 16) & 0xFF) / 255.0 green:((rgb >> 8) & 0xFF) / 255.0 blue:(rgb & 0xFF) / 255.0 alpha:alpha];
}

@implementation CYLTagColors

+ (instancetype)colorsWithBackgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor textColor:(UIColor *)textColor
                  selectedBackgroundColor:(UIColor *)selectedBackgroundColor {
    CYLTagColors *colors = [[self alloc] init];
    colors.backgroundColor = backgroundColor;
    colors.borderColor = borderColor;
    colors.textColor = textColor;
    colors.selectedBackgroundColor = selectedBackgroundColor;
    return colors;
}

+ (NSDictionary<NSString *, NSString *> *)paletteHexByName {
    return @{@"RED": @"F44336", @"LIGHTBLUE": @"03A9F4", @"AMBER": @"FFC107", @"ORANGE": @"FF9800", @"YELLOW": @"FFEB3B",
             @"LIME": @"CDDC39", @"BLUE": @"2196F3", @"INDIGO": @"3F51B5", @"LIGHTGREEN": @"8BC34A", @"GREY": @"9E9E9E",
             @"DEEPPURPLE": @"673AB7", @"TEAL": @"009688", @"CYAN": @"00BCD4"};
}

/// ColorFactory.COLORS, in its order.
+ (NSArray<NSString *> *)cyl_palette {
    return @[@"F44336", @"03A9F4", @"FFC107", @"FF9800", @"FFEB3B", @"CDDC39", @"2196F3", @"3F51B5", @"8BC34A", @"9E9E9E",
             @"673AB7", @"009688", @"00BCD4"];
}

+ (UIColor *)gray666666 {
    return CYLTagColorFromHex(@"666666", 1);
}

+ (UIColor *)gray727272 {
    return CYLTagColorFromHex(@"727272", 1);
}

+ (instancetype)colorsWithPaletteHex:(NSString *)hex textColor:(UIColor *)textColor selectedBackgroundColor:(UIColor *)selectedBackgroundColor {
    return [self colorsWithBackgroundColor:CYLTagColorFromHex(hex, CYLTagColorsBackgroundAlpha)
                               borderColor:CYLTagColorFromHex(hex, CYLTagColorsBorderAlpha)
                                 textColor:textColor
                   selectedBackgroundColor:selectedBackgroundColor];
}

+ (instancetype)colorsForTheme:(CYLTagColorTheme)theme seed:(NSUInteger)seed {
    switch (theme) {
        case CYLTagColorThemeRandom: {
            NSArray<NSString *> *palette = [self cyl_palette];
            return [self colorsWithPaletteHex:palette[seed % palette.count] textColor:self.gray666666 selectedBackgroundColor:self.gray727272];
        }
        case CYLTagColorThemePureCyan:
            return [self colorsWithPaletteHex:@"00BCD4" textColor:self.gray727272 selectedBackgroundColor:self.gray666666];
        case CYLTagColorThemePureTeal:
            return [self colorsWithPaletteHex:@"009688" textColor:self.gray727272 selectedBackgroundColor:self.gray666666];
        case CYLTagColorThemeNone:
        default:
            return nil;
    }
}

+ (instancetype)randomColors {
    return [self colorsForTheme:CYLTagColorThemeRandom seed:arc4random_uniform((uint32_t)[self cyl_palette].count)];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[self class] colorsWithBackgroundColor:self.backgroundColor borderColor:self.borderColor textColor:self.textColor
                           selectedBackgroundColor:self.selectedBackgroundColor];
}

- (CYLMenuStyle *)styleByApplyingToStyle:(CYLMenuStyle *)style {
    CYLMenuStyle *result = [(style ?: [CYLMenuStyle defaultStyle]) copy];
    CYLTagAppearance *normal = result.normalAppearance;
    if (self.backgroundColor) normal.backgroundColor = self.backgroundColor;
    if (self.textColor) {
        normal.textColor = self.textColor;
        result.selectedAppearance.textColor = self.textColor;
    }
    if (self.borderColor) {
        normal.borderColor = self.borderColor;
        result.selectedAppearance.borderColor = self.borderColor;
        if (normal.borderWidth <= 0) normal.borderWidth = 1;
    }
    if (self.selectedBackgroundColor) result.selectedAppearance.backgroundColor = self.selectedBackgroundColor;
    return result;
}

@end
