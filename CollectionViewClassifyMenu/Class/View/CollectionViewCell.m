//
//  CollectionViewCell.m
//  CollectionViewClassifyMenu
//
//  Created by https://github.com/ChenYilong on 15/3/17.
//  Copyright (c)  http://weibo.com/luohanchenyilong/ . All rights reserved.
//

#import "CollectionViewCell.h"
#import "UIButton+CollectionCellStyle.h"

@implementation CollectionViewCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder: (NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}
- (id)sharedInit {
    [self setup];
    return self;
}

- (void)setup {
    self.button = [CYLIndexPathButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self.contentView addSubview:self.button];
    [self.button generalStyle];
    [self.button homeStyle];
//    [self.button redStyle];
}

// Overriding this because the button's rect is partially outside the parent-view's bounds:
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([super pointInside:point withEvent:event])
    {
        NSLog(@"inside cell");
        return YES;
    }
    if ([self.button
         pointInside:[self convertPoint:point
                                 toView:self.button] withEvent:nil])
    {
        NSLog(@"inside button");
        return YES;
    }
    
    return NO;
}


@end
