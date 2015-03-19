//
//  FilterHeaderView.m
//  PiFuKeYiSheng
//
//  Created by 喻平 on 14-7-9.
//  Copyright (c) 2014年 com.pifukeyisheng. All rights reserved.
//

#import "FilterHeaderView.h"
#define kTitleButtonWidth 250.f
#define kMoreButtonWidth 320.f-kTitleButtonWidth
float CYLFilterHeaderViewHeigt = 38;
@interface FilterHeaderView()

@end
@implementation FilterHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    //仅修改self.titleButton的宽度,xyh值不变
    self.titleButton.frame = CGRectMake(self.titleButton.frame.origin.x, self.titleButton.frame.origin.y, kTitleButtonWidth, self.titleButton.frame.size.height);
    self.titleButton.layer.borderColor = [UIColor redColor].CGColor;
    self.titleButton.layer.borderWidth = 1.f;
    self.titleButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    //仅修改self.moreButton的宽度,xyh值不变
    self.moreButton.frame = CGRectMake(self.moreButton.frame.origin.x, self.moreButton.frame.origin.y, kMoreButtonWidth, self.moreButton.frame.size.height);
    self.moreButton.layer.borderColor = [UIColor redColor].CGColor;
    self.moreButton.layer.borderWidth = 1.f;
    self.moreButton.titleLabel.textAlignment = NSTextAlignmentRight;
}

- (IBAction)moreBtnClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(filterHeaderViewMoreBtnClicked:)]) {
        [self.delegate filterHeaderViewMoreBtnClicked:self.titleButton];
    }
}
@end
