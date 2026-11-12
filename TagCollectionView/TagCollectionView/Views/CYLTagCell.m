//
//  CYLTagCell.m
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 (year 2016) AK. All rights reserved.
//

#import "CYLTagCell.h"

@interface CYLTagCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLb;

@end
@implementation CYLTagCell
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
    [super awakeFromNib];
    
    
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


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    // Keep the drawn font in sync with the size CYLTagView measured for this text size.
    self.titleLb.font = [CYLTagModel titleFontForTraitCollection:self.traitCollection];
}

-(void)setModel:(CYLTagModel *)model{

    _model=model;
    
    
    self.titleLb.text=model.title;
    self.isAccessibilityElement = YES;
    self.accessibilityLabel = model.title;
    self.accessibilityTraits = UIAccessibilityTraitButton;
    self.titleLb.font=[CYLTagModel titleFontForTraitCollection:self.traitCollection];
    
}


@end
