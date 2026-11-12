//
//  CYLTagColors.h
//  CollectionViewClassifyMenu
//
//  The four colors of a tag (background, border, text, selected background) and the color themes that make them,
//  as AndroidTagView's ColorFactory: a random Material color, pure cyan or pure teal, each a 0x33 background and a 0x88
//  border of the same color.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CYLMenuStyle;

/*!
 * AndroidTagView's tag_theme.
 */
typedef NS_ENUM(NSInteger, CYLTagColorTheme) {
    /*!
     * The style's own colors (ColorFactory.NONE, the default).
     */
    CYLTagColorThemeNone = -1,
    /*!
     * A Material color per tag (ColorFactory.RANDOM), the same one for a tag every time it is drawn.
     */
    CYLTagColorThemeRandom = 0,
    CYLTagColorThemePureCyan = 1,
    CYLTagColorThemePureTeal = 2,
};

/*!
 * ColorFactory's alphas of a theme's background ("33") and border ("88").
 */
FOUNDATION_EXTERN const CGFloat CYLTagColorsBackgroundAlpha;
FOUNDATION_EXTERN const CGFloat CYLTagColorsBorderAlpha;

@interface CYLTagColors : NSObject <NSCopying>

+ (instancetype)colorsWithBackgroundColor:(nullable UIColor *)backgroundColor
                              borderColor:(nullable UIColor *)borderColor
                                textColor:(nullable UIColor *)textColor
                  selectedBackgroundColor:(nullable UIColor *)selectedBackgroundColor;

@property (nonatomic, strong, nullable) UIColor *backgroundColor;
@property (nonatomic, strong, nullable) UIColor *borderColor;
@property (nonatomic, strong, nullable) UIColor *textColor;
@property (nonatomic, strong, nullable) UIColor *selectedBackgroundColor;

/*!
 * The colors of a theme; for the random theme, the palette color at `seed` modulo the palette's size (ColorFactory's
 * onRandomBuild picks one at random). nil for CYLTagColorThemeNone.
 */
+ (nullable instancetype)colorsForTheme:(CYLTagColorTheme)theme seed:(NSUInteger)seed;
/*!
 * A random palette color (onRandomBuild).
 */
+ (instancetype)randomColors;
/*!
 * The palette color `hex` ("F44336") as a theme makes it (0x33 background, 0x88 border); `textColor` and
 * `selectedBackgroundColor` are the two grays.
 */
+ (instancetype)colorsWithPaletteHex:(NSString *)hex textColor:(UIColor *)textColor selectedBackgroundColor:(UIColor *)selectedBackgroundColor;
/*!
 * ColorFactory's palette: RED, LIGHTBLUE, AMBER, ORANGE, YELLOW, LIME, BLUE, INDIGO, LIGHTGREEN, GREY, DEEPPURPLE,
 * TEAL, CYAN, as "RRGGBB".
 */
@property (class, nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *paletteHexByName;
/*!
 * ColorFactory's SHARP666666 and SHARP727272.
 */
@property (class, nonatomic, strong, readonly) UIColor *gray666666;
@property (class, nonatomic, strong, readonly) UIColor *gray727272;

/*!
 * A copy of `style` with these colors: background, border (a hairline when the style had none) and text in the normal
 * state, the selected background in the selected state.
 */
- (CYLMenuStyle *)styleByApplyingToStyle:(CYLMenuStyle *)style;

@end

NS_ASSUME_NONNULL_END
