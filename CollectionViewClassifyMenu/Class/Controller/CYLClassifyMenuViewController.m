
//  CYLClassifyMenuViewController.m
//  CollectionViewClassifyMenu
//
//  Created by chenyilong on 15/3/17.
//  Copyright (c) 2015年 chenyilong. All rights reserved.
//
#define kControllerHeaderViewHeight                90
#define kControllerHeaderToCollectionViewMargin    0
#define kCollectionViewCellsHorizonMargin          12
#define kCollectionViewCellHeight                  30
#define kCollectionViewItemButtonImageToTextMargin 5

#define kCollectionViewToLeftMargin                16
#define kCollectionViewToTopMargin                 12
#define kCollectionViewToRightMargin               16
#define kCollectionViewToBottomtMargin             10

#define kCellImageToLabelMargin                    10
#define kCellBtnCenterToBorderMargin               19

#define kDataSourceSectionKey                      @"Symptoms"
#define kDataSourceCellTextKey                     @"Patient_Name"
#define kDataSourceCellPictureKey                  @"Picture"

#import "CYLClassifyMenuViewController.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "CollectionViewCell.h"
#import "FilterHeaderView.h"

static NSString * const kCellIdentifier           = @"CellIdentifier";
static NSString * const kHeaderViewCellIdentifier = @"HeaderViewCellIdentifier";

@interface CYLClassifyMenuViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
FilterHeaderViewDelegate
>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray   *dataSource;
@property (nonatomic, assign) float            priorCellY;
@property (nonatomic, assign) int              rowLine;
@property (nonatomic, strong) NSMutableArray   *collectionHeaderMoreBtnHideBoolArray;
@property (nonatomic, strong) NSMutableArray   *firstLineCellCountArray;
@property (nonatomic, strong) NSMutableArray   *expandSectionArray;
@property (nonatomic, strong) UIScrollView     *bgScrollView;

@end

@implementation CYLClassifyMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.bgScrollView.backgroundColor = [UIColor colorWithRed:18/255.0 green:133/255.0 blue:117/255.0 alpha:1];
    [self.view addSubview:self.bgScrollView];
    
    [self initData];
    [self addCollectionView];
    [self judgeMoreBtnShow];
    // 如果想显示两行，请打开下面两行代码
    [self judgeMoreBtnShowWhenShowTwoLine];
    [self initDefaultShowCellCount];
    [self.bgScrollView addSubview:[self addTableHeaderView]];
    self.view.backgroundColor = [UIColor blueColor];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.bgScrollView.scrollEnabled = YES;
    [self updateViewHeight];
}

- (void)initDefaultShowCellCount {
    for (NSUInteger index = 0; index < self.firstLineCellCountArray.count; index++) {
        NSArray *secondLineCellCountArray = [NSArray arrayWithArray:[self getSecondLineCellCount]];
        [self.firstLineCellCountArray replaceObjectAtIndex:index withObject:@([self.firstLineCellCountArray[index] intValue]+[secondLineCellCountArray[index] intValue])];
    }
}
- (NSMutableArray *)collectionHeaderMoreBtnHideBoolArray
{
    if (_collectionHeaderMoreBtnHideBoolArray == nil) {
        _collectionHeaderMoreBtnHideBoolArray = [[NSMutableArray alloc] init];
    }
    return _collectionHeaderMoreBtnHideBoolArray;
}

- (NSMutableArray *)firstLineCellCountArray
{
    if (_firstLineCellCountArray == nil) {
        _firstLineCellCountArray = [[NSMutableArray alloc] init];
    }
    return _firstLineCellCountArray;
}

- (NSMutableArray *)expandSectionArray
{
    if (_expandSectionArray == nil) {
        _expandSectionArray = [[NSMutableArray alloc] init];
    }
    return _expandSectionArray;
}


- (void)initData {
    self.firstLineCellCountArray = [NSMutableArray array];
    self.rowLine = 0;
    self.collectionHeaderMoreBtnHideBoolArray = [NSMutableArray array];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    //    [json writeToFile:@"/Users/chenyilong/Documents/123.plist" atomically:YES];
    self.dataSource = [NSMutableArray arrayWithArray:json];
}

- (void)judgeMoreBtnShow {
    NSMutableArray *firstLineWidthArray = [NSMutableArray array];
    [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __block int firstLineCellCount = 0;

        NSArray *symptoms = [NSArray arrayWithArray:[obj objectForKey:kDataSourceSectionKey]];
        NSMutableArray *widthArray = [NSMutableArray array];
        [symptoms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *text = [obj objectForKey:kDataSourceCellTextKey];
            float cellWidth = [self getCollectionCellWidthText:text content:obj];
            float textAndImageWidth;
            if (obj == [symptoms lastObject]) {
                textAndImageWidth = cellWidth;
            } else {
                textAndImageWidth = cellWidth+kCollectionViewCellsHorizonMargin;
            }
            [widthArray  addObject:@(textAndImageWidth)];
            NSArray *sumArray = [NSArray arrayWithArray:widthArray];
            NSNumber* sum = [sumArray valueForKeyPath: @"@sum.self"];
            if ([sum intValue]-kCollectionViewCellsHorizonMargin<(self.collectionView.frame.size.width-kCollectionViewToLeftMargin-kCollectionViewToRightMargin)||[sum intValue]==(self.collectionView.frame.size.width-kCollectionViewToLeftMargin-kCollectionViewToRightMargin)) {
                firstLineCellCount ++;
            }
        }];
        [self.firstLineCellCountArray addObject:@(firstLineCellCount)];
        NSArray *sumArray = [NSArray arrayWithArray:widthArray];
        NSNumber* sum = [sumArray valueForKeyPath: @"@sum.self"];
        [firstLineWidthArray addObject:sum];
    }];
    
    [firstLineWidthArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj intValue]> (self.collectionView.frame.size.width-kCollectionViewToLeftMargin-kCollectionViewToRightMargin)) {
            [self.collectionHeaderMoreBtnHideBoolArray addObject:@NO];
        } else {
            [self.collectionHeaderMoreBtnHideBoolArray addObject:@YES];
        }
    }];

}


- (void)judgeMoreBtnShowWhenShowTwoLine {
    NSMutableArray *twoLineWidthArray = [NSMutableArray array];
    [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __block int countTime = 0;
        NSArray *symptoms = [NSArray arrayWithArray:[obj objectForKey:kDataSourceSectionKey]];
        NSMutableArray *widthArray = [NSMutableArray array];
        [symptoms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *text = [obj objectForKey:kDataSourceCellTextKey];
            float cellWidth = [self getCollectionCellWidthText:text content:obj];
            float textAndImageWidth;
            if (obj == [symptoms lastObject]) {
                textAndImageWidth = cellWidth;
            } else {
                textAndImageWidth = cellWidth+kCollectionViewCellsHorizonMargin;
            }
            [widthArray  addObject:@(textAndImageWidth)];
            NSMutableArray *sumArray = [NSMutableArray arrayWithArray:widthArray];
            NSNumber* sum = [sumArray valueForKeyPath: @"@sum.self"];
            if ([sum intValue]-kCollectionViewCellsHorizonMargin<(self.collectionView.frame.size.width-kCollectionViewToLeftMargin-kCollectionViewToRightMargin)||[sum intValue]==(self.collectionView.frame.size.width-kCollectionViewToLeftMargin-kCollectionViewToRightMargin)) {
                //未超过一行
            } else {
                //超过一行时
                if(countTime==0) {
                [widthArray removeAllObjects];
                [widthArray addObject:@(textAndImageWidth)];
                }
                countTime++;
            }
        }];

        NSArray *sumArray = [NSArray arrayWithArray:widthArray];
        NSNumber* sum = [sumArray valueForKeyPath: @"@sum.self"];
        [twoLineWidthArray addObject:sum];
    }];
    
    [twoLineWidthArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj intValue]> (self.collectionView.frame.size.width-kCollectionViewToLeftMargin-kCollectionViewToRightMargin)) {
            [self.collectionHeaderMoreBtnHideBoolArray replaceObjectAtIndex:idx withObject:@NO];
        } else {
            [self.collectionHeaderMoreBtnHideBoolArray replaceObjectAtIndex:idx withObject:@YES];
        }
    }];
}


-(NSArray *)getSecondLineCellCount {
    NSMutableArray *secondLineCellCountArray = [NSMutableArray array];
    [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __block int firstLineCellCount = 0;
        NSMutableArray *symptoms = [[NSMutableArray alloc] initWithArray:[obj objectForKey:kDataSourceSectionKey]];
        
       float firstLineCount = [self getFirstLineCellCountWithArray:symptoms];
        if (symptoms.count != firstLineCount) {
            NSRange range = NSMakeRange(0, firstLineCount);
            [symptoms removeObjectsInRange:range];
            float secondLineCount = [self getFirstLineCellCountWithArray:symptoms];
            [secondLineCellCountArray addObject:@(secondLineCount)];
        } else {
            [secondLineCellCountArray addObject:@(0)];
        }
    }];
    return (NSArray *)secondLineCellCountArray;

}

- (int)getFirstLineCellCountWithArray:(NSArray *)array {
    __block int firstLineCellCount = 0;
    NSMutableArray *widthArray = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *text = [obj objectForKey:kDataSourceCellTextKey];
        float cellWidth = [self getCollectionCellWidthText:text content:obj];
        float textAndImageWidth;
        if (obj == [array lastObject]) {
            textAndImageWidth = cellWidth;
        } else {
            textAndImageWidth = cellWidth+kCollectionViewCellsHorizonMargin;
        }
        [widthArray  addObject:@(textAndImageWidth)];
        NSArray *sumArray = [NSArray arrayWithArray:widthArray];
        NSNumber* sum = [sumArray valueForKeyPath: @"@sum.self"];
        if ([sum intValue]-kCollectionViewCellsHorizonMargin<(self.collectionView.frame.size.width-kCollectionViewToLeftMargin-kCollectionViewToRightMargin)||[sum intValue]==(self.collectionView.frame.size.width-kCollectionViewToLeftMargin-kCollectionViewToRightMargin)) {
            firstLineCellCount ++;
        }
    }];
    return firstLineCellCount;
}

- (float)getCollectionCellWidthText:(NSString *)text content:(NSDictionary *)content{
    float cellWidth;
    CGSize size = [text sizeWithAttributes:
                   @{NSFontAttributeName:
                         [UIFont systemFontOfSize:16]}];
    BOOL shouldShowPic;
    
    NSString *picture = [content objectForKey:kDataSourceCellPictureKey];
    int pictureLength = [@(picture.length) intValue];
    if(pictureLength>0) {
        shouldShowPic = YES;
    } else {
        shouldShowPic = NO;
    }
    
    if(shouldShowPic) {
        cellWidth = ceilf(size.width) + kCellBtnCenterToBorderMargin*2;
    } else {
        cellWidth = ceilf(size.width) + kCellBtnCenterToBorderMargin;
    }
    return cellWidth;
}

- (UIView *)addTableHeaderView
{
    UIView *vw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kControllerHeaderViewHeight)];
    vw.backgroundColor = [UIColor whiteColor];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(16, 35, vw.frame.size.width, 20)];
    lbl.font = [UIFont boldSystemFontOfSize:18];
    lbl.textColor = [UIColor colorWithRed:0 green:150.0/255.0 blue:136.0/255.0 alpha:1.0];
    lbl.text = @"默认显示两行时的效果如下所示!";
    [vw addSubview:lbl];
    
    UILabel *lbl2 = [[UILabel alloc] init];
    //仅修改lbl2的x,ywh值不变
    lbl2.frame = CGRectMake(lbl.frame.origin.x, lbl2.frame.origin.y, lbl2.frame.size.width, lbl2.frame.size.height);
    //仅修改lbl2的y,xwh值不变
    lbl2.frame = CGRectMake(lbl2.frame.origin.x, CGRectGetMaxY(lbl.frame) + 10, lbl2.frame.size.width, lbl2.frame.size.height);
    //仅修改lbl2的宽度,xyh值不变
    lbl2.frame = CGRectMake(lbl2.frame.origin.x, lbl2.frame.origin.y, lbl.frame.size.width, lbl2.frame.size.height);
    //仅修改lbl2的高度,xyw值不变
    lbl2.frame = CGRectMake(lbl2.frame.origin.x, lbl2.frame.origin.y, lbl2.frame.size.width, 14);
    lbl2.font = [UIFont systemFontOfSize:12];
    lbl2.textColor = [UIColor grayColor];
    lbl2.text = @"下面是本店的分类列表";
    [vw addSubview:lbl2];
    return vw;
}

- (void)addCollectionView {
    CGRect collectionViewFrame = CGRectMake(0, kControllerHeaderViewHeight+kControllerHeaderToCollectionViewMargin, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-40);
    UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:layout];
    //    layout.headerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, CYLFilterHeaderViewHeigt);  //设置head大小
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[FilterHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewCellIdentifier];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    self.collectionView.scrollsToTop = NO;
    self.collectionView.scrollEnabled = NO;
    [self.bgScrollView addSubview:self.collectionView];
}

- (void)updateViewHeight {
    //仅修改self.collectionView的高度,xyw值不变
    self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x, self.collectionView.frame.origin.y, self.collectionView.frame.size.width, self.collectionView.contentSize.height+kCollectionViewToTopMargin+kCollectionViewToBottomtMargin);
    
    self.bgScrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,  self.collectionView.contentSize.height+kControllerHeaderViewHeight+kCollectionViewToTopMargin+kCollectionViewToBottomtMargin);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.dataSource count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *symptoms = [NSArray arrayWithArray:[self.dataSource[section] objectForKey:kDataSourceSectionKey]];
    for (NSNumber *ii in self.expandSectionArray) {
        if (section == [ii integerValue]) {
            return [symptoms count];
        }
    }
    return [self.firstLineCellCountArray[section] integerValue];
}

- (BOOL)shouldCollectionCellPictureShowWithIndex:(NSIndexPath *)indexPath {
    NSMutableArray *symptoms = [NSMutableArray arrayWithArray:[self.dataSource[indexPath.section] objectForKey:kDataSourceSectionKey]];
    NSString *picture = [symptoms[indexPath.row] objectForKey:kDataSourceCellPictureKey];
    int pictureLength = [@(picture.length) intValue];
    if(pictureLength>0) {
        return YES;
    }
    return NO;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.button.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    NSMutableArray *symptoms = [NSMutableArray arrayWithArray:[self.dataSource[indexPath.section] objectForKey:kDataSourceSectionKey]];
    NSString *text = [symptoms[indexPath.row] objectForKey:kDataSourceCellTextKey];
    BOOL shouldShowPic = [self shouldCollectionCellPictureShowWithIndex:indexPath];
    if(shouldShowPic) {
        [cell.button setImage:[UIImage imageNamed:@"home_btn_shrink"] forState:UIControlStateNormal];
        [cell.button setImage:[UIImage imageNamed:@"home_btn_shrink"] forState:UIControlStateHighlighted];
        CGFloat spacing = kCollectionViewItemButtonImageToTextMargin;
        cell.button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
        cell.button.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
    } else {
        [cell.button setImage:nil forState:UIControlStateNormal];
        [cell.button setImage:nil forState:UIControlStateHighlighted];
        cell.button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        cell.button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    [cell.button setTitle:text forState:UIControlStateNormal];
    [cell.button setTitle:text forState:UIControlStateSelected];
    [cell.button addTarget:self action:@selector(itemButtonClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    cell.button.section = indexPath.section;
    cell.button.row = indexPath.row;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqual:UICollectionElementKindSectionHeader]) {
        FilterHeaderView *filterHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewCellIdentifier forIndexPath:indexPath];
        filterHeaderView.moreButton.hidden = [self.collectionHeaderMoreBtnHideBoolArray[indexPath.section] boolValue];
        filterHeaderView.delegate = self;
        NSString *sectionTitle = [self.dataSource[indexPath.section] objectForKey:@"Type"];
        filterHeaderView.titleButton.tag = indexPath.section;
        filterHeaderView.moreButton.tag = indexPath.section;
        filterHeaderView.moreButton.selected = NO;
        [filterHeaderView.titleButton setTitle:sectionTitle forState:UIControlStateNormal];
        [filterHeaderView.titleButton setTitle:sectionTitle forState:UIControlStateSelected];
        switch (indexPath.section) {
            case 0:
                [filterHeaderView.titleButton setImage:[UIImage imageNamed:@"home_btn_face"] forState:UIControlStateNormal];
                break;
            case 1:
                [filterHeaderView.titleButton setImage:[UIImage imageNamed:@"home_btn_common"] forState:UIControlStateNormal];
                break;
            case 2:
                [filterHeaderView.titleButton setImage:[UIImage imageNamed:@"home_btn_child"] forState:UIControlStateNormal];
                break;
            case 3:
                [filterHeaderView.titleButton setImage:[UIImage imageNamed:@"home_btn_cosmetic"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        for (NSNumber *ii in self.expandSectionArray) {
            if (indexPath.section == [ii integerValue]) {
                filterHeaderView.moreButton.selected = YES;
            }
        }
        return (UICollectionReusableView *)filterHeaderView;
    }
    return nil;
}

- (void)itemButtonClicked:(CYLIndexPathButton *)button
{
    //二级菜单数组
    NSArray *symptoms = [NSArray arrayWithArray:[self.dataSource[button.section] objectForKey:kDataSourceSectionKey]];
    NSString *sectionTitle = [self.dataSource[button.section] objectForKey:@"Type"];
    NSString *cellTitle = [symptoms[button.row] objectForKey:kDataSourceCellTextKey];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:cellTitle message:sectionTitle delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - FilterHeaderViewDelegateMethod
-(void)filterHeaderViewMoreBtnClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.expandSectionArray addObject:[NSNumber numberWithInteger:sender.tag]];
    } else {
        [self.expandSectionArray removeObject:[NSNumber numberWithInteger:sender.tag]];
    }
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag]];
    } completion:^(BOOL finished) {
        [self updateViewHeight];
    }];
}

#pragma mark - UICollectionViewDelegateLeftAlignedLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *symptoms = [NSArray arrayWithArray:[self.dataSource[indexPath.section] objectForKey:kDataSourceSectionKey]];
    NSString *text = [symptoms[indexPath.row] objectForKey:kDataSourceCellTextKey];
    float cellWidth = [self getCollectionCellWidthText:text content:symptoms[indexPath.row]];
    return CGSizeMake(cellWidth, kCollectionViewCellHeight);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kCollectionViewCellsHorizonMargin;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, 38);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kCollectionViewToTopMargin, kCollectionViewToLeftMargin, kCollectionViewToBottomtMargin, kCollectionViewToRightMargin);
}

@end
