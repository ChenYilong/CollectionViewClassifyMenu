//
//  HeaderCell.m
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 AK. All rights reserved.
//

#import "HeaderCell.h"
@interface HeaderCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLb;
@property (weak, nonatomic) IBOutlet UIButton *btn;

- (IBAction)btnClick;

@end

@implementation HeaderCell


- (void)awakeFromNib {
    // Initialization code
}



/**
 *  监听组按钮的点击
 */
- (IBAction)btnClick {
    

    
    // 1.修改组模型的标记(状态取反)
    self.group.opened = !self.group.isOpened;
    
    // 2.刷新表格
    if ([self.delegate respondsToSelector:@selector(headerViewDidClickedNameView:index:)]) {
        
        [self.delegate headerViewDidClickedNameView:self index:self.group.section];
        
    }
}


-(void)setGroup:(TagGroup *)group{
    _group=group;

    if (group.isOpened) {
        
        [self.btn setTitle:@"Fold" forState:UIControlStateNormal];
    }
    else{
        
        [self.btn setTitle:@"More" forState:UIControlStateNormal];
    }
    
    self.nameLb.text=group.groupName;
    
}
@end
