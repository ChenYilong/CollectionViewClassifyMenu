
//  CYLClassifyMenuViewController.m
//  CollectionViewClassifyMenu
//
//  Created by https://github.com/ChenYilong on 15/3/17.
//  Copyright (c)  http://weibo.com/luohanchenyilong/ . All rights reserved.
//  Single Choice Filter

static float const kControllerHeaderToCollectionViewMargin    = 0;
static float const kCollectionViewCellsHorizonMargin          = 12;
static float const kCollectionViewCellHeight                  = 30;
static float const kCollectionViewItemButtonImageToTextMargin = 5;

static float const kCollectionViewToLeftMargin                = 16;
static float const kCollectionViewToTopMargin                 = 12;
static float const kCollectionViewToRightMargin               = 16;
static float const kCollectionViewToBottomtMargin             = 10;

static float const kCellBtnCenterToBorderMargin               = 19;

//View Controllers
#import "CYLClassifyMenuViewController.h"
//Views
#import "CYLFilterHeaderView.h"
//Cells
#import "CYLCollectionViewCell.h"
//Others
#import "CYLCollectionViewLeftAlignedLayout.h"
#import "CYLMenuKeys.h"
#import "CYLParameterConfiguration.h"
#import "CYLMenuResources.h"

NSString *const kDataSourceSectionKey = @"Items";
NSString *const kDataSourceCellTextKey = @"Item_Title";
NSString *const kDataSourceCellPictureKey = @"Picture";

static NSString * const kCellIdentifier           = @"CellIdentifier";
static NSString * const kHeaderViewCellIdentifier = @"HeaderViewCellIdentifier";
typedef void(^ISLimitWidth)(BOOL yesORNo, id data);

@interface CYLClassifyMenuViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, CYLFilterHeaderViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray          *dataSource;
@property (nonatomic, assign) float            priorCellY;
@property (nonatomic, strong) NSMutableArray   *collectionHeaderMoreBtnHideBoolArray;
@property (nonatomic, strong) NSMutableArray   *firstRowCellCountArray;
@property (nonatomic, strong) NSMutableArray   *expandSectionArray;
@property (nonatomic, strong) UIScrollView     *backgroundView;
@property (nonatomic, strong) NSArray          *rowsCountPerSection;
@property (nonatomic, strong) NSArray          *cellsCountArrayPerRowInSections;
@property (nonatomic, assign) CGFloat          calculatedCollectionWidth;

@end

@implementation CYLClassifyMenuViewController

@synthesize defaultVisibleRows = _defaultVisibleRows;

#pragma mark - 💤 LazyLoad Method

- (NSMutableArray *)collectionHeaderMoreBtnHideBoolArray {
    if (_collectionHeaderMoreBtnHideBoolArray == nil) {
        _collectionHeaderMoreBtnHideBoolArray = [[NSMutableArray alloc] init];
        [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.collectionHeaderMoreBtnHideBoolArray addObject:@YES];
        }];
    }
    return _collectionHeaderMoreBtnHideBoolArray;
}

- (NSMutableArray *)firstRowCellCountArray {
    if (_firstRowCellCountArray == nil) {
        _firstRowCellCountArray = [NSMutableArray arrayWithCapacity:self.dataSource.count];
        [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[obj objectForKey:kDataSourceSectionKey]];
            NSUInteger secondRowCellCount = [self firstRowCellCountWithArray:items];
            [self.firstRowCellCountArray addObject:@(secondRowCellCount)];
        }];
    }
    return _firstRowCellCountArray;
}

- (NSMutableArray *)expandSectionArray {
    if (_expandSectionArray == nil) {
        _expandSectionArray = [[NSMutableArray alloc] init];
    }
    return _expandSectionArray;
}

/**
 *  lazy load _rowsCountPerSection
 *
 *  @return NSArray
 */
- (NSArray *)rowsCountPerSection {
    if (_rowsCountPerSection == nil) {
        _rowsCountPerSection = [[NSArray alloc] init];
        NSMutableArray *rowsCountPerSection = [NSMutableArray array];
        for (NSArray *rows in self.cellsCountArrayPerRowInSections) {
            [rowsCountPerSection addObject:@(rows.count)];
        }
        _rowsCountPerSection = (NSArray *)rowsCountPerSection;
    }
    return _rowsCountPerSection;
}

/**
 *  lazy load _cellsCountArrayPerRowInSections
 *
 *  @return NSArray
 */
- (NSArray *)cellsCountArrayPerRowInSections {
    if (_cellsCountArrayPerRowInSections == nil) {
        _cellsCountArrayPerRowInSections = [[NSArray alloc] init];
        NSMutableArray *cellsCountArrayPerRowInSections = [NSMutableArray array];
        [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[obj objectForKey:kDataSourceSectionKey]];
            NSArray *cellsInPerRowWhenLayoutWithArray = [self cellsInPerRowWhenLayoutWithArray:items];
            [cellsCountArrayPerRowInSections addObject:cellsInPerRowWhenLayoutWithArray];
        }];
        _cellsCountArrayPerRowInSections = (NSArray *)cellsCountArrayPerRowInSections;
    }
    return _cellsCountArrayPerRowInSections;
}

#pragma mark - ♻️ LifeCycle Method

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"CYLTagView", @"Menu title");
    self.backgroundView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.showsVerticalScrollIndicator = NO;
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.alwaysBounceVertical = YES;
    self.backgroundView.backgroundColor = [UIColor colorWithRed:252.0f / 255.f green:252.0f / 255.f blue:252.0f / 255.f alpha:2.f];
    [self.view addSubview:self.backgroundView];
    
    [self initData];
    [self addCollectionView];
    [self cyl_judgeMoreButtonShowWhenDefaultRowsCount:self.defaultVisibleRows];
    if (self.menuHeaderView) {
        [self.backgroundView addSubview:self.menuHeaderView];
    }
    self.view.backgroundColor = [UIColor blueColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.backgroundView.scrollEnabled = YES;
    [self updateViewHeight];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (![previousTraitCollection.preferredContentSizeCategory isEqualToString:self.traitCollection.preferredContentSizeCategory]) {
        // Text size changed: measure every tag again on the next layout pass.
        self.calculatedCollectionWidth = 0;
        [self.view setNeedsLayout];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = CGRectGetWidth(self.collectionView.bounds);
    if (width > 0 && width != self.calculatedCollectionWidth) {
        self.calculatedCollectionWidth = width;
        self.firstRowCellCountArray = nil;
        self.collectionHeaderMoreBtnHideBoolArray = nil;
        self.rowsCountPerSection = nil;
        self.cellsCountArrayPerRowInSections = nil;
        [self cyl_judgeMoreButtonShowWhenDefaultRowsCount:self.defaultVisibleRows];
        [self.collectionView reloadData];
        [self updateViewHeight];
    }
}

#pragma mark - 🆑 CYL Custom Method

- (void)initData {
    self.firstRowCellCountArray = nil;
    self.collectionHeaderMoreBtnHideBoolArray = nil;
    self.rowsCountPerSection = nil;
    self.cellsCountArrayPerRowInSections = nil;
    NSMutableArray *sections = [NSMutableArray array];
    id<CYLMenuDataSource> source = self.menuDataSource;
    NSInteger sectionCount = [source numberOfSectionsInMenu];
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSMutableArray *items = [NSMutableArray array];
        NSInteger count = [source menuNumberOfItemsInSection:section];
        for (NSInteger item = 0; item < count; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObject:[source menuTitleForItemAtIndexPath:indexPath]
                                                                             forKey:kDataSourceCellTextKey];
            UIImage *image = [source respondsToSelector:@selector(menuImageForItemAtIndexPath:)]
                ? [source menuImageForItemAtIndexPath:indexPath] : nil;
            if (image) {
                entry[kDataSourceCellPictureKey] = image;
            }
            [items addObject:entry];
        }
        [sections addObject:@{@"Type": [source menuTitleForSection:section], kDataSourceSectionKey: items}];
    }
    self.dataSource = sections;
}

- (void)reloadMenuData {
    [self initData];
    if (self.isViewLoaded) {
        self.expandSectionArray = nil;
        [self cyl_judgeMoreButtonShowWhenDefaultRowsCount:self.defaultVisibleRows];
        [self.collectionView reloadData];
        [self updateViewHeight];
    }
}
- (float)cellLimitWidth:(float)cellWidth
            limitMargin:(CGFloat)limitMargin
           isLimitWidth:(ISLimitWidth)isLimitWidth {
    float limitWidth = MAX(0, CGRectGetWidth(self.collectionView.bounds) - kCollectionViewToLeftMargin - kCollectionViewToRightMargin - limitMargin);
    if (cellWidth >= limitWidth) {
        cellWidth = limitWidth;
        isLimitWidth ? isLimitWidth(YES, @(cellWidth)) : nil;
        return cellWidth;
    }
    isLimitWidth ? isLimitWidth(NO, @(cellWidth)) : nil;
    return cellWidth;
}

- (NSUInteger)defaultVisibleRows {
    return _defaultVisibleRows ?: 1;
}

- (void)setDefaultVisibleRows:(NSUInteger)defaultVisibleRows {
    _defaultVisibleRows = MAX(1, defaultVisibleRows);
    if (self.isViewLoaded) {
        [self cyl_judgeMoreButtonShowWhenDefaultRowsCount:_defaultVisibleRows];
        [self.collectionView reloadData];
        [self updateViewHeight];
    }
}

- (void)cyl_judgeMoreButtonShowWhenDefaultRowsCount:(NSUInteger)defaultRowsCount {
    [self.rowsCountPerSection enumerateObjectsUsingBlock:^(id  __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
        if ([obj integerValue] > defaultRowsCount) {
            [self.collectionHeaderMoreBtnHideBoolArray replaceObjectAtIndex:idx withObject:@NO];
        } else {
            [self.collectionHeaderMoreBtnHideBoolArray replaceObjectAtIndex:idx withObject:@YES];
        }
    }];
    
    [self.cellsCountArrayPerRowInSections enumerateObjectsUsingBlock:^(id  __nonnull cellsCountArrayPerRow, NSUInteger idx, BOOL * __nonnull stop) {
        NSUInteger __block sum = 0;
        [cellsCountArrayPerRow enumerateObjectsUsingBlock:^(NSNumber  * __nonnull cellsCount, NSUInteger cellsCountArrayPerRowIdx, BOOL * __nonnull stop) {
            if (cellsCountArrayPerRowIdx < defaultRowsCount) {
                sum += [cellsCount integerValue];
            } else {
                //|break;| Stop enumerating ;if wanna continue use |return| to Skip this object
                *stop = YES;
                return;
            }
        }];
        [self.firstRowCellCountArray replaceObjectAtIndex:idx withObject:@(sum)];
    }];
}

- (NSUInteger)firstRowCellCountWithArray:(NSArray *)array {
    return [[[self cellsInPerRowWhenLayoutWithArray:array] firstObject] unsignedIntegerValue];
}

- (NSMutableArray *)cellsInPerRowWhenLayoutWithArray:(NSArray *)array {
    CGFloat availableWidth = MAX(0, CGRectGetWidth(self.collectionView.bounds) - kCollectionViewToLeftMargin - kCollectionViewToRightMargin);
    CGFloat usedWidth = 0;
    NSUInteger count = 0;
    NSMutableArray *cellCount = [NSMutableArray array];
    for (NSDictionary *item in array) {
        CGFloat width = [self collectionCellWidthText:item[kDataSourceCellTextKey] content:item];
        if (count > 0 && usedWidth + kCollectionViewCellsHorizonMargin + width > availableWidth) {
            [cellCount addObject:@(count)];
            count = 0;
            usedWidth = 0;
        }
        usedWidth += (count > 0 ? kCollectionViewCellsHorizonMargin : 0) + width;
        count++;
    }
    if (count > 0) [cellCount addObject:@(count)];
    return cellCount;
}

- (UIFont *)cyl_tagFont {
    return CYLTagTitleFontForTraitCollection(self.collectionView.traitCollection ?: self.traitCollection);
}

- (CGFloat)cyl_cellHeight {
    return CYLTagHeightForFont([self cyl_tagFont], kCollectionViewCellHeight);
}

- (float)collectionCellWidthText:(NSString *)text content:(NSDictionary *)content {
    float cellWidth;
    CGSize size = [text sizeWithAttributes:
                   @{NSFontAttributeName:
                         [self cyl_tagFont]}];
    BOOL shouldShowPic = [self cyl_imageForItem:content] != nil;
    if (shouldShowPic) {
        cellWidth = ceilf(size.width) + kCellBtnCenterToBorderMargin * 2;
    } else {
        cellWidth = ceilf(size.width) + kCellBtnCenterToBorderMargin;
    }
    cellWidth = [self cellLimitWidth:cellWidth
                         limitMargin:0
                        isLimitWidth:nil];
    return cellWidth;
}

- (void)addCollectionView {
    CGRect collectionViewFrame = CGRectMake(0, CGRectGetHeight(self.menuHeaderView.frame) + kControllerHeaderToCollectionViewMargin, CGRectGetWidth(self.view.bounds),
                                            MAX(0, CGRectGetHeight(self.view.bounds) - 40));
    CYLCollectionViewLeftAlignedLayout *layout = [[CYLCollectionViewLeftAlignedLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame
                                             collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[CYLCollectionViewCell class]
            forCellWithReuseIdentifier:kCellIdentifier];
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[CYLFilterHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewCellIdentifier];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    self.collectionView.scrollsToTop = NO;
    self.collectionView.scrollEnabled = NO;
    [self.backgroundView addSubview:self.collectionView];
}

- (void)updateViewHeight {
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView.collectionViewLayout prepareLayout];
    // 仅修改self.collectionView的高度,xyw值不变 / Change only the collection view's height.
    self.collectionView.frame = CGRectMake(CGRectGetMinX(self.collectionView.frame),
                                           CGRectGetMinY(self.collectionView.frame),
                                           CGRectGetWidth(self.collectionView.frame),
                                           self.collectionView.contentSize.height +
                                           kCollectionViewToTopMargin +
                                           kCollectionViewToBottomtMargin);
    self.backgroundView.contentSize = CGSizeMake(CGRectGetWidth(self.backgroundView.bounds),
                                                 self.collectionView.contentSize.height +
                                                 CGRectGetHeight(self.menuHeaderView.frame) +
                                                 kCollectionViewToTopMargin +
                                                 kCollectionViewToBottomtMargin +
                                                 64);
}

#pragma mark - 🔌 UICollectionViewDataSource Method

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.dataSource count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSArray *items = [NSArray arrayWithArray:[self.dataSource[section] objectForKey:kDataSourceSectionKey]];
    for (NSNumber *i in self.expandSectionArray) {
        if (section == [i integerValue]) {
            return [items count];
        }
    }
    return [self.firstRowCellCountArray[section] integerValue];
}

/// The item's image: a UIImage from -menuImageForItemAtIndexPath:, or the
/// bundled default for legacy dictionaries that store a non-empty string.
- (UIImage *)cyl_imageForItem:(NSDictionary *)item {
    id picture = item[kDataSourceCellPictureKey];
    if ([picture isKindOfClass:[UIImage class]]) {
        return picture;
    }
    if ([picture isKindOfClass:[NSString class]] && [picture length] > 0) {
        return [CYLMenuResources imageNamed:@"home_btn_shrink"];
    }
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CYLCollectionViewCell *cell =
    (CYLCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier
                                                                    forIndexPath:indexPath];
    NSMutableArray *items = [NSMutableArray arrayWithArray:[self.dataSource[indexPath.section]
                                                            objectForKey:kDataSourceSectionKey]];
    NSString *text = [items[indexPath.row] objectForKey:kDataSourceCellTextKey];
    UIImage *image = [self cyl_imageForItem:items[indexPath.row]];
    if (image) {
        [cell.button setImage:image forState:UIControlStateNormal];
        cell.button.cyl_imageTitleSpacing = kCollectionViewItemButtonImageToTextMargin;
    } else {
        [cell.button setImage:nil forState:UIControlStateNormal];
        cell.button.cyl_imageTitleSpacing = 0;
    }
    cell.button.titleLabel.font = [self cyl_tagFont];
    [cell.button setTitle:text forState:UIControlStateNormal];
    [cell.button setTitle:text forState:UIControlStateSelected];
    [cell.button addTarget:self action:@selector(itemButtonClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    cell.button.section = indexPath.section;
    cell.button.row = indexPath.row;
    return cell;
}

#pragma mark - 🎬 Actions Method

- (void)itemButtonClicked:(CYLIndexPathButton *)button {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:button.row inSection:button.section];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
}

#pragma mark - 🔌 UICollectionViewDelegate Method

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.menuDelegate respondsToSelector:@selector(menu:didSelectItemAtIndexPath:)]) {
        [self.menuDelegate menu:self didSelectItemAtIndexPath:indexPath];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqual:UICollectionElementKindSectionHeader]) {
        CYLFilterHeaderView *filterHeaderView =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                           withReuseIdentifier:kHeaderViewCellIdentifier
                                                  forIndexPath:indexPath];
        filterHeaderView.moreButton.hidden =
        [self.collectionHeaderMoreBtnHideBoolArray[indexPath.section] boolValue];
        filterHeaderView.delegate = self;
        NSString *sectionTitle = [self.dataSource[indexPath.section] objectForKey:@"Type"];
        filterHeaderView.titleButton.tag = indexPath.section;
        filterHeaderView.moreButton.tag = indexPath.section;
        filterHeaderView.moreButton.selected = NO;
        // The title is a heading, not a control; the fold button names its section.
        filterHeaderView.titleButton.accessibilityTraits = UIAccessibilityTraitHeader;
        filterHeaderView.moreButton.accessibilityHint = sectionTitle;
        [filterHeaderView.titleButton setTitle:sectionTitle forState:UIControlStateNormal];
        [filterHeaderView.titleButton setTitle:sectionTitle forState:UIControlStateSelected];
        id<CYLMenuDataSource> source = self.menuDataSource;
        UIImage *sectionImage = [source respondsToSelector:@selector(menuImageForSection:)]
            ? [source menuImageForSection:indexPath.section] : nil;
        [filterHeaderView.titleButton setImage:sectionImage forState:UIControlStateNormal];
        for (NSNumber *i in self.expandSectionArray) {
            if (indexPath.section == [i integerValue]) {
                filterHeaderView.moreButton.selected = YES;
            }
        }
        return (UICollectionReusableView *)filterHeaderView;
    }
    // Only headers have a size, so UIKit never asks for another kind.
    return [[UICollectionReusableView alloc] initWithFrame:CGRectZero];
}

#pragma mark - 🔌 FilterHeaderViewDelegateMethod Method

- (void)filterHeaderViewDidTapMoreButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.expandSectionArray addObject:@(sender.tag)];
    } else {
        [self.expandSectionArray removeObject:@(sender.tag)];
    }
    __weak __typeof(self) weakSelf = self;
    [self.collectionView performBatchUpdates:^{
        __strong typeof(self) strongSelf = weakSelf;
        NSIndexSet *section = [NSIndexSet indexSetWithIndex:sender.tag];
        [strongSelf.collectionView reloadSections:section];
    } completion:^(BOOL finished) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf updateViewHeight];
    }];
}

#pragma mark - 🔌 UICollectionViewDelegateLeftAlignedLayout Method

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *items = [NSArray arrayWithArray:[self.dataSource[indexPath.section] objectForKey:kDataSourceSectionKey]];
    NSString *text = [items[indexPath.row] objectForKey:kDataSourceCellTextKey];
    float cellWidth = [self collectionCellWidthText:text content:items[indexPath.row]];
    return CGSizeMake(cellWidth, [self cyl_cellHeight]);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kCollectionViewCellsHorizonMargin;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(MAX(0, CGRectGetWidth(collectionView.bounds) - 50), 38);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kCollectionViewToTopMargin, kCollectionViewToLeftMargin, kCollectionViewToBottomtMargin, kCollectionViewToRightMargin);
}

@end
