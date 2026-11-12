//
//  CYLTagModel.h
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 (year 2016) AK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYLTagModel : NSObject

@property(nonatomic,copy) NSString * title;

@property (nonatomic, assign,readonly) float width;
@property (nonatomic, assign,readonly) float height;



+(instancetype)modelWithTitle:(NSString*)title;

/*!
 * Font used to draw and measure the title for the given traits (Dynamic Type).
 */
+ (UIFont *)titleFontForTraitCollection:(UITraitCollection *)traitCollection;

/*!
 * Recalculates `width` and `height` for the content size category of
 * `traitCollection`; nil uses the app's current category.
 */
- (void)updateSizeForTraitCollection:(UITraitCollection *)traitCollection;

@end
