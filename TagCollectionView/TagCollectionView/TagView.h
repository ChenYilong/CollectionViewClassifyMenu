//
//  ViewController.h
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 (year 2016) AK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagGroup.h"
#import "TagModel.h"
#import "CYLMenuDataSource.h"
@interface TagView : UIView



@property(nonatomic,assign,getter=isShowHeader)BOOL showHeader;

// 总数据group / All data groups.
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, weak) id<CYLMenuDataSource> menuDataSource;
@property (nonatomic, weak) id<CYLMenuDelegate> menuDelegate;
+(instancetype)TagView;
- (void)reloadMenuData;


@end
