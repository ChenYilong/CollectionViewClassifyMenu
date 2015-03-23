//
//  CYLIndexPathButton.h
//  CollectionViewClassifyMenu
//
//  Created by chenyilong on 15/3/19.
//  Copyright (c) 2015年 chenyilong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYLIndexPathButton : UIButton
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) BOOL isShowImage;
@end
