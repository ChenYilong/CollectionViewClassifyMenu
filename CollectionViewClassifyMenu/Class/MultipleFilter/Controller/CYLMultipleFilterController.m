//
//  CYLMultipleFilterController.m
//  http://cnblogs.com/ChenYilong/
//
//  Created by  https://github.com/ChenYilong  on 14-7-10.
//  Copyright (c)  http://weibo.com/luohanchenyilong/  . All rights reserved.
//  Multiple Choice Save Filter

static float const kCollectionViewCellsHorizonMargin = 12;

//View Controllers
#import "CYLMultipleFilterController.h"
//Others
#import "CYLFilterParamsTool.h"
#import "CYLDBManager.h"
#import "CYLParameterConfiguration.h"

@interface CYLMultipleFilterController ()

@property (nonatomic, strong) CYLFilterParamsTool *filterParamsTool;
@property (nonatomic, strong) NSString            *filename;
@property (nonatomic, assign) NSUInteger          secondSectionTagsCount;

@end

@implementation CYLMultipleFilterController

#pragma mark - 💤 LazyLoad Method

/**
 *  lazy load _filterParamsTool
 *
 *  @return CYLFilterParamsTool
 */
- (CYLFilterParamsTool *)filterParamsTool {
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

/**
 *  lazy load _secondSectionTagsCount
 *
 *  @return int
 */
- (NSUInteger)secondSectionTagsCount {
    if (_secondSectionTagsCount == 0) {
        NSMutableArray *types = [NSMutableArray arrayWithObject:@"全部"];
        [types addObjectsFromArray:[CYLDBManager allTags]];
        _secondSectionTagsCount = [types count];
    }
    return _secondSectionTagsCount;
}

/**
 *  lazy load _filename
 *
 *  @return NSString
 */
- (NSString *)filename {
    if (_filename == nil) {
        _filename = [[NSString alloc] init];
        NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _filename = [Path stringByAppendingPathComponent:kMultipleFilterSetting];
    }
    return _filename;
}

#pragma mark - ♻️ LifeCycle Method

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
    //【Fixed Bug】以下两行代码意在解决iphone 6p self.collectionView刷新不及时的bug
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
    NSUInteger allSecondSectionTagsCount = [[self.collectionView indexPathsForVisibleItems] count];
    if (allSecondSectionTagsCount >0) {
        [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
    }
}

- (void)refreshFilterParams {
    self.filterParamsTool = nil;
    NSUInteger allSecondSectionTagsCount = [[self.collectionView indexPathsForVisibleItems] count];
    if (allSecondSectionTagsCount >0) {
        [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
    }
}

#pragma mark - 🎬 Actions Method

- (void)confirmButtonClicked:(id)sender {
    [super confirmButtonClicked:sender];
    self.filterParamsTool.filterParamsDictionary[kMultipleFilterSetting] = self.filterParamsTool.filterParamsArray;
    BOOL modified = NO;
    for (NSArray *array in self.filterParamsTool.filterParamsArray) {
        if ([[array firstObject] boolValue] == NO) {
            modified = YES;
            break;
        }
    }
    self.filterParamsTool.filterParamsDictionary[kMultipleFilterSettingModified] = @(modified);
    [NSKeyedArchiver archiveRootObject:self.filterParamsTool toFile:self.filename];
}

- (void)restoreButtonClicked:(id)sender {
    [super confirmButtonClicked:sender];
    self.filterParamsTool = [[CYLFilterParamsTool alloc] init];
    [NSKeyedArchiver archiveRootObject:self.filterParamsTool toFile:self.filterParamsTool.filename];
}

- (void)clickedInFirstSection:(NSIndexPath *)indexPath
                   withButton:(CYLIndexPathButton *)button
                  withsetting:(NSMutableArray *)setting {
    if (indexPath.row == 1) {
        NSString *area = @"北京";
        [setting replaceObjectAtIndex:1 withObject:@1];
        [setting replaceObjectAtIndex:0 withObject:@0];
        // 选择医院结束，将此医院保存，下次进入此界面，需显示
        self.filterParamsTool.filterParamsContentDictionary[@"Hospital"] = area;
        NSMutableArray *array = self.filterParamsTool.dataSources[0];
        [array replaceObjectAtIndex:1 withObject:area];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
        
        NSString *message = @"点击选择地区按钮，\n弹出选择地区的界面\n这里默认选北京";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [alert show];
        NSUInteger delaySeconds = 1.5;
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySeconds * NSEC_PER_SEC));
        dispatch_after(when, dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
        return;
    } else {
        // 点击的是“全部”按钮
        [setting replaceObjectAtIndex:0 withObject:@1];
        [setting replaceObjectAtIndex:1 withObject:@0];
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.filterParamsTool.dataSources[0]];
        [array replaceObjectAtIndex:1 withObject:@"请选择"];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
        [self.filterParamsTool.filterParamsContentDictionary removeObjectForKey:@"Hospital"];
    }
}

- (void)clickedInSecondSection:(NSIndexPath *)indexPath
                    withButton:(CYLIndexPathButton *)button
                   withSetting:(NSMutableArray *)setting {
    NSString *text = self.filterParamsTool.dataSources[indexPath.section][indexPath.row];
    if (indexPath.row == 0) {
        if (button.selected ) {
            return;
        } else {
            //处于修改状态
            [self.filterParamsTool.filterParamsContentDictionary
             removeObjectForKey:@"skilled"];
        }
    }
    [setting replaceObjectAtIndex:indexPath.row withObject:@(!button.selected)];
    if (indexPath.row > 0) {
        if (!button.selected) {
            [setting replaceObjectAtIndex:0 withObject:@(0)];
            if ([self.filterParamsTool.filterParamsContentDictionary[@"skilled"] count] == 0) {
                self.filterParamsTool.filterParamsContentDictionary[@"skilled"] = [NSMutableArray array];
            }
            if (![text isEqualToString:@"全部"]) {
                [self.filterParamsTool.filterParamsContentDictionary[@"skilled"] addObject:text];
            }
        } else {
            if (![setting containsObject:@(1)]) {
                [setting replaceObjectAtIndex:0 withObject:@(1)];
                [self.filterParamsTool.filterParamsContentDictionary
                 removeObjectForKey:@"skilled"];
            }
            if ([self.filterParamsTool.filterParamsContentDictionary[@"skilled"] containsObject:text]) {
                [self.filterParamsTool.filterParamsContentDictionary[@"skilled"] removeObject:text];
            }
        }
        NSIndexPath *allBtnIndexPath = [NSIndexPath indexPathForItem:0 inSection:button.section];
        [self.collectionView reloadItemsAtIndexPaths:@[allBtnIndexPath]];
    } else {
        for (NSUInteger i = 0; i < setting.count; i++) {
            if (i > 0) {
                [setting replaceObjectAtIndex:i withObject:@(0)];
            }
        }
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
    }
}

#pragma mark - 🔌 UICollectionViewDelegate Method

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqual:UICollectionElementKindSectionHeader]) {
        CYLMultipleFilterHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CYLMultipleFilterHeaderView" forIndexPath:indexPath];
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FilterCollectionCell" forIndexPath:indexPath];
    CGSize size = [self collectionView:collectionView layout:nil sizeForItemAtIndexPath:indexPath];
    cell.titleButton.frame = CGRectMake(0, 0, size.width, size.height);
    NSString *text = self.filterParamsTool.dataSources[indexPath.section][indexPath.row];
    [cell.titleButton setTitle:text forState:UIControlStateNormal];
    [cell.titleButton setTitle:text forState:UIControlStateSelected];
    cell.titleButton.selected = [self.filterParamsTool.filterParamsArray[indexPath.section][indexPath.row] boolValue];
    cell.titleButton.section = indexPath.section;
    cell.titleButton.row = indexPath.row;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterCollectionCell *cell =
    (FilterCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //button.selected是指button原来的状态
    //是否修改要看,数组第一个值是否是0,默认是1
    NSMutableArray *setting = self.filterParamsTool.filterParamsArray[indexPath.section];
    if (indexPath.section == 0) {
        [self clickedInFirstSection:indexPath withButton:cell.titleButton withsetting:setting];
    } else if (indexPath.section == 1) {
        [self clickedInSecondSection:indexPath withButton:cell.titleButton withSetting:setting];
    }
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - 🔌 UICollectionViewDataSource Method

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.filterParamsTool.dataSources count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 1) {
        NSMutableArray *types = [NSMutableArray arrayWithObject:@"全部"];
        [types addObjectsFromArray:[CYLDBManager allTags]];
        return [types count];
    }
    return 2;
}

#pragma mark - 🔌 UICollectionViewDelegateLeftAlignedLayout Method

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = self.filterParamsTool.dataSources[indexPath.section][indexPath.row];
    CGSize size = [text sizeWithAttributes:
                   @{NSFontAttributeName:
                         CYLTagTitleFont}];
    float width = [self checkCellLimitWidth:ceilf(size.width)] ;
    return CGSizeMake(width, 30);
}

- (float)checkCellLimitWidth:(float)cellWidth {
    float limitWidth = (self.collectionView.contentSize.width - kCollectionViewToLeftMargin - kCollectionViewToRightMargin);
    if (cellWidth >= limitWidth) {
        cellWidth = limitWidth - kCollectionViewCellsHorizonMargin;
        return cellWidth;
    }
    return cellWidth + 16 ;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kCollectionViewCellsHorizonMargin;
}

@end
