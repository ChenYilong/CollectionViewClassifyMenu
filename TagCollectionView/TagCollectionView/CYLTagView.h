//
//  ViewController.h
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 (year 2016) AK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYLTagGroup.h"
#import "CYLTagModel.h"
#import "CYLMenuDataSource.h"
@interface CYLTagView : UIView



@property(nonatomic,assign,getter=isShowHeader)BOOL showHeader;

// 总数据group / All data groups.
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, weak) id<CYLMenuDataSource> menuDataSource;
@property (nonatomic, weak) id<CYLMenuDelegate> menuDelegate;
/// Loads the view from CYLTagView.xib (in the component's bundle). Swift: `CYLTagView.makeTagView()`; without the
/// name Swift would import this factory as `CYLTagView()`, which does not load the nib.
+(instancetype)tagView NS_SWIFT_NAME(makeTagView());
- (void)reloadMenuData;


@end
