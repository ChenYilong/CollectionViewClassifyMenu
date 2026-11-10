//
//  CYLTagHeaderCell.m
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 (year 2016) AK. All rights reserved.
//

#import "CYLTagHeaderCell.h"
@interface CYLTagHeaderCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLb;
@property (weak, nonatomic) IBOutlet UIButton *btn;

- (IBAction)btnClick;

@end

@implementation CYLTagHeaderCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}



/**
 *  监听组按钮的点击 / Handle group button taps.
 */
- (IBAction)btnClick {
    

    
    // 1.修改组模型的标记(状态取反) / Toggle the group's expanded state.
    self.group.opened = !self.group.isOpened;
    
    // 2.刷新表格 / Reload the collection.
    if ([self.delegate respondsToSelector:@selector(headerViewDidTapNameView:index:)]) {
        
        [self.delegate headerViewDidTapNameView:self index:self.group.section];
        
    }
}


-(void)setGroup:(CYLTagGroup *)group{
    _group=group;

    if (group.isOpened) {
        
        [self.btn setTitle:NSLocalizedString(@"Fold", @"Collapse tag group") forState:UIControlStateNormal];
    }
    else{
        
        [self.btn setTitle:NSLocalizedString(@"More", @"Expand tag group") forState:UIControlStateNormal];
    }
    
    self.nameLb.text=group.groupName;
    
}
@end
