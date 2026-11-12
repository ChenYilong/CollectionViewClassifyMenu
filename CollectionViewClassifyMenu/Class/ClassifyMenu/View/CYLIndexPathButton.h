//
//  CYLIndexPathButton.h
//  CollectionViewClassifyMenu
//
//  Created by https://github.com/ChenYilong on 15/3/19.
//  Copyright (c)  http://weibo.com/luohanchenyilong/ . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYLIndexPathButton : UIButton

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) NSInteger row;

/*!
 * Space between the image and the title when both are shown. Replaces the
 * deprecated image/title edge insets. Defaults to 0.
 */
@property (nonatomic, assign) CGFloat cyl_imageTitleSpacing;

/*!
 * Extra leading space before the title. Replaces a left title edge inset.
 * Defaults to 0.
 */
@property (nonatomic, assign) CGFloat cyl_titleLeadingInset;

@end
