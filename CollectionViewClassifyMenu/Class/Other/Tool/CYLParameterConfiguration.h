//
//  CYLParameterConfiguration.h
//  CollectionViewClassifyMenu
//
//  Created by 陈宜龙 (Chen Yilong) on 16/1/6.
//  Copyright © 2016年 (year 2016) chenyilong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CYLAppTintColor [UIColor colorWithRed:42 / 255.0 green:185 / 255.0 blue:160 / 255.0 alpha:1]

/*!
 * Largest multiple of the base size used for Dynamic Type, so tags stay usable
 * at accessibility sizes.
 */
static CGFloat const CYLMaximumFontScale = 2.0;

/*!
 * System font of `pointSize` scaled for the content size category of `traits`
 * (the app's current category when `traits` is nil).
 */
static inline UIFont *CYLScaledSystemFont(CGFloat pointSize, UITraitCollection *traits) {
    UIFont *font = [UIFont systemFontOfSize:pointSize];
    return [[UIFontMetrics defaultMetrics] scaledFontForFont:font
                                            maximumPointSize:pointSize * CYLMaximumFontScale
                               compatibleWithTraitCollection:traits];
}

/*!
 * Tag height that fits one line of `font` and is never below `minimumHeight`.
 */
static inline CGFloat CYLTagHeightForFont(UIFont *font, CGFloat minimumHeight) {
    return MAX(minimumHeight, ceil(font.lineHeight) + 10);
}

static CGFloat const CYLTagTitleFontSize = 16;

/*!
 * Tag font for the given traits. Use it for both measuring and drawing.
 */
static inline UIFont *CYLTagTitleFontForTraitCollection(UITraitCollection *traits) {
    return CYLScaledSystemFont(CYLTagTitleFontSize, traits);
}

#define CYLTagTitleFont CYLTagTitleFontForTraitCollection(nil)
