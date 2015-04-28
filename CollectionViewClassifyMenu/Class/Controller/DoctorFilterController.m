//
//  DoctorFilterController.m
//  PiFuKeYiSheng
//
//  Created by  https://github.com/ChenYilong  on 14-7-10.
//  Copyright (c)  http://weibo.com/luohanchenyilong/  . All rights reserved.
//
#define udDoctorFilterSetting         @"udDoctorFilterSetting"
#define udDoctorFilterSettingModified @"udDoctorFilterSettingModified"
#import "DoctorFilterController.h"
//#import "SelectProvinceController.h"
#import "CYLFilterParamsTool.h"
#import "CYLDBManager.h"

@interface DoctorFilterController ()
@property (nonatomic, strong) CYLFilterParamsTool *filterParamsTool;
@property (nonatomic, strong) NSString            *filename;
@property (nonatomic, assign) NSUInteger          secondSectionTagsCount;

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
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:self.filterParamsTool.filename];
        if (!fileExists) {
            CYLFilterParamsTool *filterParamsTool = [[CYLFilterParamsTool alloc] init];
            [NSKeyedArchiver archiveRootObject:filterParamsTool toFile:filterParamsTool.filename];
        } else {
        _filterParamsTool = [NSKeyedUnarchiver unarchiveObjectWithFile:_filterParamsTool.filename];
        }
    }
    return _filterParamsTool;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUInteger allSecondSectionTagsCount = [[self.collectionView indexPathsForVisibleItems] count];
    if (allSecondSectionTagsCount >0) {
        [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
    }
    self.collectionView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
}

/**
 *  懒加载_secondSectionTagsCount
 *
 *  @return int
 */
- (NSUInteger)secondSectionTagsCount
{
    if (_secondSectionTagsCount == 0) {
        NSMutableArray *types = [NSMutableArray arrayWithObject:@"全部"];
        [types addObjectsFromArray:[[CYLDBManager sharedCYLDBManager] getAllSkillTags]];
        _secondSectionTagsCount = [types count];
    }
    return _secondSectionTagsCount;
}

-(void)refreshFilterParams {
    self.filterParamsTool = nil;
    NSUInteger allSecondSectionTagsCount = [[self.collectionView indexPathsForVisibleItems] count];
    if (allSecondSectionTagsCount >0) {
        [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
    }
}

- (void)itemButtonClicked:(CYLIndexPathButton *)button
{
    //button.selected是指button原来的状态
    //是否修改要看,数组第一个值是否是0,默认是1
    NSMutableArray *setting = self.filterParamsTool.filterParamsArray[button.section];
    if (button.section == 0) {
        if (button.row == 1) {
            //            // 如果点击的是选择地区按钮，则弹出选择地区的界面
            //            SelectProvinceController *controller = [SelectProvinceController instance];
            //            controller.dataSourceArray = [Util getStateData:udHospital];
            //            [controller setSelectedHandler:^(NSDictionary *successedData, NSString *text) {
            //                [setting replaceObjectAtIndex:1 withObject:@1];
            //                [setting replaceObjectAtIndex:0 withObject:@0];
            //                // 选择地区结束，将此地区保存，下次进入此界面，需显示
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
            [self.filterParamsTool.filterParamsContentDictionary removeObjectForKey:@"Hospital"];
        }
    } else {
        [self clickedInSecondSection:button withSetting:setting];
        
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:button.row inSection:button.section];
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (void)clickedInSecondSection:(CYLIndexPathButton *)button withSetting:(NSMutableArray *)setting{
    NSString *text = self.filterParamsTool.dataSources[button.section][button.row];
    if (button.row == 0) {
        if (button.selected ) {
            return;
        } else  {
            //处于修改状态
            [self.filterParamsTool.filterParamsContentDictionary
             removeObjectForKey:@"skilled"];
        }
    }
    [setting replaceObjectAtIndex:button.row withObject:@(!button.selected)];
    if (button.row > 0) {
        if (!button.selected) {
            [setting replaceObjectAtIndex:0 withObject:@(0)];
            if([self.filterParamsTool.filterParamsContentDictionary[@"skilled"] count] == 0) {
                self.filterParamsTool.filterParamsContentDictionary[@"skilled"] = [NSMutableArray array];
            }
            if(![text isEqualToString:@"全部"])
                [self.filterParamsTool.filterParamsContentDictionary[@"skilled"] addObject:text];
        } else {
            if (![setting containsObject:@(1)]) {
                [setting replaceObjectAtIndex:0 withObject:@(1)];
                [self.filterParamsTool.filterParamsContentDictionary
                 removeObjectForKey:@"skilled"];
            }
            if([self.filterParamsTool.filterParamsContentDictionary[@"skilled"] containsObject:text])
                [self.filterParamsTool.filterParamsContentDictionary[@"skilled"] removeObject:text];
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
/**
 *  懒加载_filename
 *
 *  @return NSString
 */
- (NSString *)filename
{
    if (_filename == nil) {
        _filename = [[NSString alloc] init];
        NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
        _filename = [Path stringByAppendingPathComponent:udDoctorFilterSetting];
    }
    return _filename;
}

- (void)confirmButtonClicked:(id)sender
{
    [super confirmButtonClicked:sender];
    self.filterParamsTool.filterParamsDictionary[udDoctorFilterSetting] = self.filterParamsTool.filterParamsArray;
    BOOL modified = NO;
    for (NSArray *array in self.filterParamsTool.filterParamsArray) {
        if ([[array firstObject] boolValue] == NO) {
            modified = YES;
            break;
        }
    }
    if (modified == NO) {
        //删除选择的地区
        if(self.filterParamsTool.filterParamsContentDictionary[@"Hospital"] != [NSNull null]&&self.filterParamsTool.filterParamsContentDictionary[@"Hospital"]) {
            [self.filterParamsTool.filterParamsContentDictionary removeObjectForKey:@"Hospital"];
        }
        if ([self.filterParamsTool.filterParamsContentDictionary  count] >0) {
            [self.filterParamsTool.filterParamsContentDictionary removeObjectForKey:@"skilled"];
        }
    } else {
        //        //有筛选条件
        //        BOOL firstModified = [[self.filterParamsTool.filterParamsArray[0] firstObject] boolValue];
        //        BOOL secondModified = [[self.filterParamsTool.filterParamsArray[1] firstObject] boolValue];
        //        if (firstModified&&!secondModified) {
        //            if ([self.filterParamsTool.filterParamsContentDictionary  count] >0) {
        //                [self.filterParamsTool.filterParamsContentDictionary removeObjectForKey:@"skilled"];
        //            }
        //        } else if(!firstModified&&secondModified) {
        //            // 删除选择的地区
        //            if(self.filterParamsTool.filterParamsContentDictionary[@"Hospital"] != [NSNull null]&&self.filterParamsTool.filterParamsContentDictionary[@"Hospital"]) {
        //                [self.filterParamsTool.filterParamsContentDictionary removeObjectForKey:@"Hospital"];
        //            }
        //        }
    }
    self.filterParamsTool.filterParamsDictionary[udDoctorFilterSettingModified] = @(modified);
    [NSKeyedArchiver archiveRootObject:self.filterParamsTool toFile:self.filename];
}

- (void)restoreButtonClicked:(id)sender
{
    [super confirmButtonClicked:sender];
    self.filterParamsTool = [[CYLFilterParamsTool alloc] init];
    [NSKeyedArchiver archiveRootObject:self.filterParamsTool toFile:self.filterParamsTool.filename];
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
