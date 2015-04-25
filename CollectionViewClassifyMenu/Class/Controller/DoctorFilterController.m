//
//  DoctorFilterController.m
//  PiFuKeYiSheng
//
//  Created by 喻平 on 14-7-10.
//  Copyright (c) 2014年 com.pifukeyisheng. All rights reserved.
//
#define udDoctorFilterSetting @"udDoctorFilterSetting"
#define udDoctorFilterSettingModified @"udDoctorFilterSettingModified"
#import "DoctorFilterController.h"
//#import "SelectProvinceController.h"
#import "CYLFilterParamsTool.h"
#import "CYLDBManager.h"

@interface DoctorFilterController ()
@property (nonatomic, strong) CYLFilterParamsTool *filterParamsTool;
@property (nonatomic, strong) NSString *filename;
@end

@implementation DoctorFilterController

/**
 *  懒加载_filterParamsTool
 *
 *  @return CYLFilterParamsTool
 */
- (CYLFilterParamsTool *)filterParamsTool
{
    if (_filterParamsTool == nil) {
        _filterParamsTool = [[CYLFilterParamsTool alloc] init];
    }
    return _filterParamsTool;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if([NSKeyedUnarchiver unarchiveObjectWithFile:self.filterParamsTool.filename]) {
        self.filterParamsTool = [NSKeyedUnarchiver unarchiveObjectWithFile:self.filterParamsTool.filename];
    }
       [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
    self.collectionView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
}

- (void)itemButtonClicked:(CYLIndexPathButton *)button
{
    NSMutableArray *setting = self.filterParamsTool.filterParamsArray[button.section];
    if (button.section == 0) {
        if (button.row == 1) {
//            // 如果点击的是选择医院按钮，则弹出选择医院的界面
//            SelectProvinceController *controller = [SelectProvinceController instance];
//            controller.dataSourceArray = [Util getStateData:udHospital];
//            [controller setSelectedHandler:^(NSDictionary *successedData, NSString *text) {
//                [setting replaceObjectAtIndex:1 withObject:@1];
//                [setting replaceObjectAtIndex:0 withObject:@0];
//                // 选择医院结束，将此医院保存，下次进入此界面，需显示
//                self.filterParamsTool.filterParamsContentDictionary[@"Hospital"] = text;
//                NSMutableArray *array = self.filterParamsTool.dataSources[0];
//                [array replaceObjectAtIndex:1 withObject:text];
//                [[NativeUtil appDelegate].navigationController dismissViewControllerAnimated:YES completion:nil];
//                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:button.section]];
//            }];
//            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
//            [[NativeUtil appDelegate].navigationController presentViewController:navController animated:YES completion:nil];
            return;
        } else {
            // 点击的是“全部”按钮
            [setting replaceObjectAtIndex:0 withObject:@1];
            [setting replaceObjectAtIndex:1 withObject:@0];
            NSMutableArray *array = self.filterParamsTool.dataSources[0];
            [array replaceObjectAtIndex:1 withObject:@"请选择"];
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:button.section]];
        }
    } else {
        if (button.row == 0 && button.selected) {
            return;
        }
        // 参考QuestionFilterController
        [setting replaceObjectAtIndex:button.row withObject:@(!button.selected)];
        if (button.row > 0) {
            if (!button.selected) {
                [setting replaceObjectAtIndex:0 withObject:@(0)];
            } else {
                if (![setting containsObject:@(1)]) {
                    [setting replaceObjectAtIndex:0 withObject:@(1)];
                }
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:button.section];
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        } else {
            for (int i = 0; i < setting.count; i++) {
                if (i > 0) {
                    [setting replaceObjectAtIndex:i withObject:@(0)];
                }
            }
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:button.section]];
        }
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:button.row inSection:button.section];
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

/**
 *  懒加载_filename
 *
 *  @return NSString
 */
- (NSString *)filename
{
    if (_filename == nil) {
        _filename = [[NSString alloc] init];
        NSString *Path =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
        _filename = [Path stringByAppendingPathComponent:udDoctorFilterSetting];
    }
    return _filename;
}

- (void)confirmButtonClicked:(id)sender
{
    self.filterParamsTool.filterParamsDictionary[udDoctorFilterSetting] = self.filterParamsTool.filterParamsArray;
    BOOL modified = NO;
    for (NSArray *array in self.filterParamsTool.filterParamsArray) {
        if ([[array firstObject] boolValue] == NO) {
            modified = YES;
            break;
        }
    }
    if (modified == NO) {
        // 删除选择的医院
        if(self.filterParamsTool.filterParamsContentDictionary[@"Hospital"] != [NSNull null]&&self.filterParamsTool.filterParamsContentDictionary[@"Hospital"]) {
            [self.filterParamsTool.filterParamsContentDictionary removeObjectForKey:@"Hospital"];
        }
    } else {
        //有筛选条件
        
        //=================NSKeyedArchiver========================
        //----Save
        //这一句是将路径和文件名合成文件完整路径
        [NSKeyedArchiver archiveRootObject:self.filterParamsTool toFile:self.filename];
        
    }
    self.filterParamsTool.filterParamsDictionary[udDoctorFilterSettingModified] = @(modified);
    [super confirmButtonClicked:sender];
}

- (void)restoreButtonClicked:(id)sender
{
    self.filterParamsTool = [[CYLFilterParamsTool alloc] init];
    [NSKeyedArchiver archiveRootObject:self.filterParamsTool toFile:self.filterParamsTool.filename];
    [self confirmButtonClicked:nil];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqual:UICollectionElementKindSectionHeader]) {
        FilterHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"FilterHeaderView" forIndexPath:indexPath];
        switch (indexPath.section) {
            case 0:
                view.imageView.image = [UIImage imageNamed:@"icon_slide_sort"];
                view.titleLabel.text = @"地区过滤";
                break;
            case 1:
                view.imageView.image = [UIImage imageNamed:@"icon_slide_people"];
                view.titleLabel.text = @"菜品过滤";
                break;
            default:
                break;
        }
        return view;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.filterParamsTool.dataSources count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 1) {
        NSMutableArray *types = [NSMutableArray arrayWithObject:@"全部"];
        [types addObjectsFromArray:[[CYLDBManager sharedCYLDBManager] getAllSkillTags]];
        return [types count];
    }
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FilterCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FilterCollectionCell" forIndexPath:indexPath];
    CGSize size = [self collectionView:collectionView layout:nil sizeForItemAtIndexPath:indexPath];
    cell.titleButton.frame = CGRectMake(0, 0, size.width, size.height);
    NSString *text = self.filterParamsTool.dataSources[indexPath.section][indexPath.row];
    [cell.titleButton setTitle:text forState:UIControlStateNormal];
    [cell.titleButton setTitle:text forState:UIControlStateSelected];
    [cell.titleButton addTarget:self action:@selector(itemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    cell.titleButton.selected = [self.filterParamsTool.filterParamsArray[indexPath.section][indexPath.row] boolValue];
    if (indexPath.section == 1) {
        if (![text isEqualToString:@"全部"]) {
        if(cell.titleButton.selected) {
            if (![self.filterParamsTool.filterParamsContentDictionary[@"skilled"] containsObject:text]) {
            [self.filterParamsTool.filterParamsContentDictionary[@"skilled"] addObject:text];
            }
        } else {
            if ([self.filterParamsTool.filterParamsContentDictionary[@"skilled"] containsObject:text]) {
            [self.filterParamsTool.filterParamsContentDictionary[@"skilled"] removeObject:text];
        }
        }
    }
    }
    cell.titleButton.section = indexPath.section;
    cell.titleButton.row = indexPath.row;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = self.filterParamsTool.dataSources[indexPath.section][indexPath.row];
    CGSize size = [text sizeWithAttributes:
                   @{NSFontAttributeName:
                         [UIFont systemFontOfSize:16]}];
    float width = [self checkCellLimitWidth:ceilf(size.width)] ;
    return CGSizeMake(width, 30);
}

- (float)checkCellLimitWidth:(float)cellWidth {
    float limitWidth = (self.collectionView.contentSize.width-kCollectionViewToLeftMargin-kCollectionViewToRightMargin);
    if (cellWidth >= limitWidth) {
        cellWidth = limitWidth;
        return cellWidth;
    }
    return cellWidth +16 ;
}
@end
