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
#import "CYLParameterConfiguration.h"

@interface CYLMultipleFilterController () <UICollectionViewDataSource>

@property (nonatomic, strong) CYLFilterParamsTool *filterParamsTool;

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
    }
    return _filterParamsTool;
}

/**
 *  lazy load _secondSectionTagsCount
 *
 *  @return int
 */
#pragma mark - ♻️ LifeCycle Method

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.dataSource = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
    [self reloadMenuData];
}

- (void)refreshFilterParams {
    if (self.isViewLoaded) {
        [self.collectionView reloadData];
    }
}

- (void)reloadMenuData {
    NSMutableArray *sections = [NSMutableArray array];
    NSMutableArray *selected = [NSMutableArray array];
    id<CYLMenuDataSource> source = self.menuDataSource;
    for (NSInteger section = 0; section < [source numberOfSectionsInMenu]; section++) {
        NSMutableArray *items = [NSMutableArray array];
        NSMutableArray *states = [NSMutableArray array];
        BOOL selectedExclusive = NO;
        for (NSInteger item = 0; item < [source menuNumberOfItemsInSection:section]; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            [items addObject:[source menuTitleForItemAtIndexPath:indexPath]];
            BOOL exclusive = [source respondsToSelector:@selector(menuItemIsExclusiveAtIndexPath:)] &&
                             [source menuItemIsExclusiveAtIndexPath:indexPath];
            [states addObject:@(exclusive && !selectedExclusive)];
            selectedExclusive |= exclusive;
        }
        [sections addObject:items];
        [selected addObject:states];
    }
    self.filterParamsTool.dataSources = sections;
    self.filterParamsTool.filterParamsArray = selected;
    if (self.isViewLoaded) {
        [self.collectionView reloadData];
    }
}

- (NSArray<NSIndexPath *> *)selectedIndexPaths {
    NSMutableArray *paths = [NSMutableArray array];
    [self.filterParamsTool.filterParamsArray enumerateObjectsUsingBlock:^(NSArray *section, NSUInteger sectionIndex, BOOL *stop) {
        [section enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger item, BOOL *itemStop) {
            if (value.boolValue) {
                [paths addObject:[NSIndexPath indexPathForItem:item inSection:sectionIndex]];
            }
        }];
    }];
    return paths;
}

- (void)setSelectedIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self loadViewIfNeeded];
    NSMutableIndexSet *exclusiveSections = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *otherSections = [NSMutableIndexSet indexSet];
    id<CYLMenuDataSource> source = self.menuDataSource;
    BOOL hasExclusive = [source respondsToSelector:@selector(menuItemIsExclusiveAtIndexPath:)];
    for (NSIndexPath *path in indexPaths) {
        if (path.section >= self.filterParamsTool.dataSources.count ||
            path.item >= [self.filterParamsTool.dataSources[path.section] count]) {
            [NSException raise:NSInvalidArgumentException format:@"Invalid menu selection: %@", path];
        }
        BOOL exclusive = hasExclusive && [source menuItemIsExclusiveAtIndexPath:path];
        if ((exclusive && ([exclusiveSections containsIndex:path.section] || [otherSections containsIndex:path.section])) ||
            (!exclusive && [exclusiveSections containsIndex:path.section])) {
            [NSException raise:NSInvalidArgumentException format:@"Exclusive selection conflicts in section %ld", (long)path.section];
        }
        [(exclusive ? exclusiveSections : otherSections) addIndex:path.section];
    }
    for (NSMutableArray *section in self.filterParamsTool.filterParamsArray) {
        for (NSUInteger index = 0; index < section.count; index++) {
            section[index] = @NO;
        }
    }
    for (NSIndexPath *path in indexPaths) {
        self.filterParamsTool.filterParamsArray[path.section][path.item] = @YES;
    }
    [self.collectionView reloadData];
}

#pragma mark - 🎬 Actions Method

- (void)confirmButtonClicked:(id)sender {
    if ([self.menuDelegate respondsToSelector:@selector(menu:didConfirmSelectedItems:)]) {
        [self.menuDelegate menu:self didConfirmSelectedItems:self.selectedIndexPaths];
    }
    [super confirmButtonClicked:sender];
}

- (void)restoreButtonClicked:(id)sender {
    [self reloadMenuData];
    [self confirmButtonClicked:sender];
}

#pragma mark - 🔌 UICollectionViewDelegate Method

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqual:UICollectionElementKindSectionHeader]) {
        CYLMultipleFilterHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CYLMultipleFilterHeaderView" forIndexPath:indexPath];
        view.titleLabel.text = [self.menuDataSource menuTitleForSection:indexPath.section];
        return view;
    }
    // Only headers have a size, so UIKit never asks for another kind.
    return [[UICollectionReusableView alloc] initWithFrame:CGRectZero];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CYLFilterCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CYLFilterCollectionCell" forIndexPath:indexPath];
    NSString *text = self.filterParamsTool.dataSources[indexPath.section][indexPath.row];
    [cell.titleButton setTitle:text forState:UIControlStateNormal];
    [cell.titleButton setTitle:text forState:UIControlStateSelected];
    cell.titleButton.titleLabel.font = [self cyl_tagFont];
    cell.titleButton.selected = [self.filterParamsTool.filterParamsArray[indexPath.section][indexPath.row] boolValue];
    cell.titleButton.section = indexPath.section;
    cell.titleButton.row = indexPath.row;
    // The cell is the tappable element (the button ignores touches): describe it to VoiceOver.
    cell.isAccessibilityElement = YES;
    cell.accessibilityLabel = text;
    cell.accessibilityTraits = UIAccessibilityTraitButton | (cell.titleButton.selected ? UIAccessibilityTraitSelected : 0);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *setting = self.filterParamsTool.filterParamsArray[indexPath.section];
    id<CYLMenuDataSource> source = self.menuDataSource;
    BOOL hasExclusive = [source respondsToSelector:@selector(menuItemIsExclusiveAtIndexPath:)];
    BOOL exclusive = hasExclusive && [source menuItemIsExclusiveAtIndexPath:indexPath];
    BOOL wasSelected = [setting[indexPath.item] boolValue];
    if (exclusive) {
        for (NSUInteger item = 0; item < setting.count; item++) {
            setting[item] = @(item == indexPath.item);
        }
    } else {
        setting[indexPath.item] = @(!wasSelected);
        for (NSUInteger item = 0; item < setting.count; item++) {
            NSIndexPath *other = [NSIndexPath indexPathForItem:item inSection:indexPath.section];
            if (hasExclusive && [source menuItemIsExclusiveAtIndexPath:other]) {
                setting[item] = @NO;
            }
        }
        if (![setting containsObject:@YES] && hasExclusive) {
            for (NSUInteger item = 0; item < setting.count; item++) {
                NSIndexPath *other = [NSIndexPath indexPathForItem:item inSection:indexPath.section];
                if ([source menuItemIsExclusiveAtIndexPath:other]) {
                    setting[item] = @YES;
                    break;
                }
            }
        }
    }
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
    if ([self.menuDelegate respondsToSelector:@selector(menu:didSelectItemAtIndexPath:)]) {
        [self.menuDelegate menu:self didSelectItemAtIndexPath:indexPath];
    }
}

#pragma mark - 🔌 UICollectionViewDataSource Method

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.filterParamsTool.dataSources count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.filterParamsTool.dataSources[section] count];
}

#pragma mark - 🔌 UICollectionViewDelegateLeftAlignedLayout Method

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = self.filterParamsTool.dataSources[indexPath.section][indexPath.row];
    UIFont *font = [self cyl_tagFont];
    CGSize size = [text sizeWithAttributes:
                   @{NSFontAttributeName:
                         font}];
    float width = [self checkCellLimitWidth:ceilf(size.width)] ;
    return CGSizeMake(width, CYLTagHeightForFont(font, 30));
}

- (UIFont *)cyl_tagFont {
    return CYLTagTitleFontForTraitCollection(self.collectionView.traitCollection ?: self.traitCollection);
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (self.isViewLoaded &&
        ![previousTraitCollection.preferredContentSizeCategory isEqualToString:self.traitCollection.preferredContentSizeCategory]) {
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView reloadData];
    }
}

- (float)checkCellLimitWidth:(float)cellWidth {
    CGFloat limitWidth = MAX(0, CGRectGetWidth(self.collectionView.bounds) - kCollectionViewToLeftMargin - kCollectionViewToRightMargin);
    return MIN(cellWidth + 16, limitWidth);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kCollectionViewCellsHorizonMargin;
}

@end
