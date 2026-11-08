//
//  ViewController.h
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 AK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagGroup.h"
#import "TagModel.h"
@interface TagView : UIView



@property(nonatomic,assign,getter=isShowHeader)BOOL showHeader;

//总数据group
@property (nonatomic, strong) NSMutableArray *groups;
+(instancetype)TagView;


@end

