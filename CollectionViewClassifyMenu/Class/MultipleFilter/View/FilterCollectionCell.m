//
//  FilterCollectionCell.m
//  http://cnblogs.com/ChenYilong/ 
//
//  Created by  https://github.com/ChenYilong  on 14-7-9.
//  Copyright (c)  http://weibo.com/luohanchenyilong/  . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYLParameterConfiguration.h"

@implementation UIImage (Stretch)

+ (UIImage *)stretchableImageNamed:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name];
    return [image stretchableImageWithLeftCapWidth:(NSUInteger)(image.size.width / 2)
                                      topCapHeight:(NSUInteger)(image.size.height / 2)];
}

@end

#import "FilterCollectionCell.h"

@implementation FilterCollectionCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.titleButton = [CYLIndexPathButton buttonWithType:UIButtonTypeCustom];
    _titleButton.userInteractionEnabled = NO;
    _titleButton.titleLabel.font = CYLTagTitleFont;
    [_titleButton setBackgroundImage:[UIImage stretchableImageNamed:@"btn_slide_normal"] forState:UIControlStateNormal];
    [_titleButton setBackgroundImage:[UIImage stretchableImageNamed:@"btn_slide_selected"] forState:UIControlStateSelected];
    [_titleButton setTitleColor:[UIColor colorWithRed:96 / 255.f green:147 / 255.f blue:130 / 255.f alpha:1.f]
 forState:UIControlStateNormal];
    [_titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.contentView addSubview:_titleButton];
}

@end




