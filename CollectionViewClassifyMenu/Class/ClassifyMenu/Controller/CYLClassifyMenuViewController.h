//
//  CYLClassifyMenuViewController.h
//  CollectionViewClassifyMenu
//
//  Created by https://github.com/ChenYilong on 15/3/17.
//  Copyright (c)  http://weibo.com/luohanchenyilong/ . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYLMenuDataSource.h"

@interface CYLClassifyMenuViewController : UIViewController

@property (nonatomic, weak) id<CYLMenuDataSource> menuDataSource;
@property (nonatomic, weak) id<CYLMenuDelegate> menuDelegate;
@property (nonatomic, strong) UIView *menuHeaderView;
/*!
 * A view below the tags, in the same scroll view, e.g. the results of the selected tag. It is as
 * wide as the menu; its height is its Auto Layout fitting height (or its frame height without
 * constraints). Call -updateMenuLayout after its content changes.
 */
@property (nonatomic, strong) UIView *menuFooterView;
/*!
 * The tag shown as selected (single choice), or nil. Taps are reported to the menu delegate and do
 * not change it: set it from -menu:didSelectItemAtIndexPath:.
 */
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) NSUInteger defaultVisibleRows;

- (void)reloadMenuData;
/*!
 * Lays the tags, the header and the footer out again, e.g. after the footer's content changed.
 */
- (void)updateMenuLayout;

@end
