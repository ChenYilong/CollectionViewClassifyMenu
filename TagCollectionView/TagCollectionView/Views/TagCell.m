//
//  TagCell.m
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 AK. All rights reserved.
//

#import "TagCell.h"

@interface TagCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLb;

@end
@implementation TagCell
//
//+ (instancetype)cellWithTableView:(UITableView *)tableView
//{
//    static NSString *ID = @"AssetChargeCell";
//    AssetChargeCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
//    if (cell == nil) {
//        cell =(AssetChargeCell*)[[[UINib nibWithNibName:@"AssetChargeCell" bundle:nil]instantiateWithOwner:nil options:nil  ]firstObject ];
//        cell.selectionStyle=UITableViewCellSelectionStyleNone;
//    }
//    return cell;
//}

- (void)awakeFromNib {
    
    
//    self.layer.borderColor=[UIColor grayColor].CGColor;
////
//    self.layer.borderWidth=0.5f;

    self.titleLb.layer.cornerRadius=self.titleLb.bounds.size.height*0.5;
    
    self.titleLb.layer.masksToBounds=YES;
}

-(void)layoutSubviews{
    [super layoutSubviews];

    [self layoutIfNeeded];
    
    self.titleLb.layer.cornerRadius=self.titleLb.frame.size.height*0.5;
    
    self.titleLb.layer.masksToBounds=YES;
}


-(void)setModel:(TagModel *)model{

    _model=model;
    
    
    self.titleLb.text=model.title;
    
}


@end
