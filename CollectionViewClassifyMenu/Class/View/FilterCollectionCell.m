//
//  FilterCollectionCell.m
//  PiFuKeYiSheng
//
//  Created by  https://github.com/ChenYilong  on 14-7-9.
//  Copyright (c)  http://weibo.com/luohanchenyilong/  . All rights reserved.
//
#import <UIKit/UIKit.h>
@implementation UIImage (Stretch)
+ (UIImage *)stretchableImageNamed:(NSString *)name
{
    UIImage *image = [UIImage imageNamed:name];
    return [image stretchableImageWithLeftCapWidth:(int)(image.size.width / 2)
                                      topCapHeight:(int)(image.size.height / 2)];
}
@end
#import "FilterCollectionCell.h"

@implementation FilterCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)setup
{
    self.titleButton = [CYLIndexPathButton buttonWithType:UIButtonTypeCustom];
    _titleButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_titleButton setBackgroundImage:[UIImage stretchableImageNamed:@"btn_slide_normal"] forState:UIControlStateNormal];
    [_titleButton setBackgroundImage:[UIImage stretchableImageNamed:@"btn_slide_selected"] forState:UIControlStateSelected];
    [_titleButton setTitleColor:[UIColor colorWithRed:96/255.f green:147/255.f blue:130/255.f alpha:1.f]
 forState:UIControlStateNormal];
    [_titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.contentView addSubview:_titleButton];
}
@end




