//
//  TagModel.h
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 AK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagModel : NSObject

@property(nonatomic,copy) NSString * title;
//
//@property (nonatomic, assign) NSInteger  section;
//
//@property (nonatomic, assign) NSInteger  row;

@property (nonatomic, assign,readonly) float width;
@property (nonatomic, assign,readonly) float height;



+(instancetype)modelWithTitle:(NSString*)title;

@end
