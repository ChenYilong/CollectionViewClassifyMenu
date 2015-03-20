//
//  CYLClassifyMenuViewController.m
//  CollectionViewClassifyMenu
//
//  Created by chenyilong on 15/3/17.
//  Copyright (c) 2015年 chenyilong. All rights reserved.
//
#define kCollectionViewCellsHorizonMargin 5
#define kCollectionViewCellHeight 30

#define kCollectionViewToLeftMargin 10
#define kCollectionViewToTopMargin 10
#define kCollectionViewToRightMargin 10
#define kCollectionViewToBottomtMargin 10

#import "CYLClassifyMenuViewController.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "CollectionViewCell.h"
#import "FilterHeaderView.h"
#import "MJExtension.h"

static NSString * const kCellIdentifier = @"CellIdentifier";
static NSString * const kHeaderViewCellIdentifier = @"HeaderViewCellIdentifier";

@interface CYLClassifyMenuViewController () <UICollectionViewDataSource,UICollectionViewDelegate,FilterHeaderViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *leveOneMenuDatasource;
@property (nonatomic, strong) NSMutableArray *leveTwoMenuDatasource;
@property (nonatomic, strong) NSMutableArray *collectionHeaderFrames;
@property (nonatomic, strong) NSMutableArray *collectionContentViewFrames;
@property (nonatomic, strong) NSMutableArray *collectionFirstRowFrames;
@property (nonatomic, strong) NSMutableArray *collectionOffFirstRowFrames;
@property (nonatomic, strong) NSMutableArray *moreAllCellArray;

@property (nonatomic, assign) float priorCellY;
@property (nonatomic, strong) NSMutableArray *collectionHeaderMoreBtnBoolArray;

@end

@implementation CYLClassifyMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    self.view.backgroundColor = [UIColor blueColor];
    [self addCollectionView];
}
- (void)initData {
    // 1.定义一个字典
    //    面部皮肤问题
    //    常见皮肤问题
    //    儿童皮肤问题
    //    皮肤美容与护理
    self.leveOneMenuDatasource = [NSMutableArray array];
    self.leveTwoMenuDatasource = [NSMutableArray array];
    self.collectionHeaderFrames = [NSMutableArray array];
    self.collectionContentViewFrames = [NSMutableArray array];
    self.moreAllCellArray = [NSMutableArray array];
    
    self.collectionHeaderMoreBtnBoolArray = [NSMutableArray array];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSLog(@"%@",json);
    [json writeToFile:@"/Users/chenyilong/Documents/123.plist" atomically:YES];
    self.dataSource = [NSMutableArray arrayWithArray:json];
    [json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //一级菜单数组
        NSString *sectionTitle = [obj objectForKey:@"Type"];
        [self.leveOneMenuDatasource addObject:sectionTitle];
        [self.collectionHeaderMoreBtnBoolArray addObject:@NO];
    }];
}
- (void)addCollectionView {
    CGRect collectionViewFrame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-40);
    UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:layout];
    //    layout.headerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, CYLFilterHeaderViewHeigt);  //设置head大小
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerNib:[UINib nibWithNibName:@"FilterHeaderView" bundle:nil]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:kHeaderViewCellIdentifier];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    //  在 Nib 中已经注册，就无需再代码中继续注册，否则会crash于此处：collectionView:layout:sizeForItemAtIndexPath:
    self.collectionView.scrollsToTop = NO;
    //    self.collectionView.scrollEnabled = NO;
    [self.view addSubview:self.collectionView];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.dataSource count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //二级菜单数组
    NSArray *symptoms = [NSArray arrayWithArray:[self.dataSource[section] objectForKey:@"Symptoms"]];
    return [symptoms count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.button.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    NSMutableArray *symptoms = [NSMutableArray arrayWithArray:[self.dataSource[indexPath.section] objectForKey:@"Symptoms"]];
    NSString *text = [symptoms[indexPath.row] objectForKey:@"Patient_Name"];
    [cell.button setTitle:text forState:UIControlStateNormal];
    [cell.button setTitle:text forState:UIControlStateSelected];
    //    [cell.button addTarget:self action:@selector(itemButtonClicked:)
    //    forControlEvents:UIControlEventTouchUpInside]; cell.button.selected =
    //    [self.dataSource[indexPath.section][indexPath.row] boolValue];
    cell.button.section = indexPath.section;
    cell.button.row = indexPath.row;

    float cellMargin= (cell.frame.origin.y-self.priorCellY);
    if (cellMargin==88) {
        self.priorCellY =MAXFLOAT;
    }
    if((cell.frame.origin.y-self.priorCellY)>0)
    {
        if ((indexPath.section!=0)||(indexPath.row!=0)) {
            NSLog(@"‼️‼️‼️‼️‼️第%@行 两行以上",@(indexPath.section));
            self.collectionHeaderMoreBtnBoolArray[indexPath.section] = @YES;
    }
        // 删除模型数据
//        [symptoms removeObjectAtIndex:indexPath.row];
        
        // 删UI(刷新UI)
//        [collectionView deleteItemsAtIndexPaths:@[indexPath]];

        // 删UI(刷新UI)
//        [collectionView deleteItemsAtIndexPaths:@[indexPath]];

    }
    self.priorCellY = cell.frame.origin.y;
//    switch (indexPath.section) {
//        case 0:
//          
//            self.priorCellY = cell.frame.origin.y;
//            break;
//        case 1:
//            self.priorCellY = MAXFLOAT;
//            if(([@(cell.frame.origin.y) floatValue]-self.priorCellY)>0)
//            {
//                NSLog(@"‼️‼️‼️‼️‼️第%@行 两行以上",@(indexPath.section));
//            }
//            self.priorCellY = cell.frame.origin.y;
//
//            break;
//        case 2:
//            self.priorCellY = MAXFLOAT;
//            if((cell.frame.origin.y-self.priorCellY)>0)
//            {
//                NSLog(@"‼️‼️‼️‼️‼️第%@行 两行以上",@(indexPath.section));
//            }
//            self.priorCellY = cell.frame.origin.y;
//
//            break;
//        case 3:
//            self.priorCellY = MAXFLOAT;
//            if((cell.frame.origin.y-self.priorCellY)>0)
//            {
//                NSLog(@"‼️‼️‼️‼️‼️第%@行 两行以上",@(indexPath.section));
//            }
//            self.priorCellY = cell.frame.origin.y;
//
//            break;
//        default:
//            break;
//    }
    NSLog(@"‼️‼️‼️‼️‼️这个 cell 在第%@行,y=%@",@(indexPath.row),@(cell.frame.origin.y));

    return cell;
}
//- (void)getCellFrame:(NSIndexPath *)indexPath { CGRect offFirstRowRect =
    //    CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat
    //    height#>);
    //    NSArray *offFirstRowCells = [NSArray array];
    //    offFirstRowCells = [self.collectionView.collectionViewLayout layoutAttributesForElementsInRect:firstRowRect];
//}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqual:UICollectionElementKindSectionHeader]) {
        FilterHeaderView *filterHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewCellIdentifier forIndexPath:indexPath];
        filterHeaderView.delegate = self;
        NSString *sectionTitle = [self.dataSource[indexPath.section] objectForKey:@"Type"];
        filterHeaderView.titleButton.tag = indexPath.section;
        [filterHeaderView.titleButton setTitle:sectionTitle forState:UIControlStateNormal];
        [filterHeaderView.titleButton setTitle:sectionTitle forState:UIControlStateSelected];
        filterHeaderView.titleButton.selected = NO;
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

        CGRect frame = CGRectMake(CGRectGetMinX(filterHeaderView.frame),CGRectGetMinY(filterHeaderView.frame),CGRectGetWidth(filterHeaderView.frame),CGRectGetHeight(filterHeaderView.frame));
        NSValue *frameObj = [NSValue value:&frame withObjCType:@encode(CGRect)];
        [self.collectionHeaderFrames addObject:frameObj];
        if([self.collectionHeaderMoreBtnBoolArray[indexPath.section] boolValue] == YES) {
            filterHeaderView.moreButton.hidden = NO;
        }
        NSLog(@"‼️‼️‼️‼️‼️self.collectionHeaderFrames 有成员%@",@([(NSArray *)self.collectionHeaderFrames count]));
//
//        CGRect collectionHeaderFrame = self.collectionHeaderFrames[indexPath.section];
//        CGRect firstRowRect =
//        CGRectMake(kCollectionViewToLeftMargin,
//                   CGRectGetMaxY(collectionHeaderFrame)+kCollectionViewToTopMargin,
//                   self.collectionView.contentSize.width,
//                   kCollectionViewToTopMargin+kCollectionViewCellHeight);
//        [self.collectionFirstRowFrames addObject:firstRowRect];
//        int lastSection = [self.dataSource count] - 1;
//        
//        
//        if (!(indexPath.section == 0)) {
//            CGRect priorSection = self.collectionHeaderFrames[indexPath.section-1];
//            CGRect offFirstRowRect = CGRectMake(kCollectionViewToLeftMargin, CGRectGetMaxY(firstRowRect),self.collectionView.contentSize.width,priorSection.origin.y - CGRectGetMaxY(firstRowRect));
//            [self.collectionOffFirstRowFrames addObject:offFirstRowRect];
//        } else {
//            float firstOffFirstRowHeight= self.collectionView.contentSize.height - CGRectGetMaxY(self.collectionHeaderFrames.lastObject);
//            CGRect = CGRectMake(kCollectionViewToLeftMargin, CGRectGetMaxY(firstRowRect), self.collectionView.contentSize.width, lastOffFirstRowHeight);
//            [self.collectionOffFirstRowFrames addObject:];
//        }
//        NSArray *offFirstRowCells = [NSArray array];
//        offFirstRowCells = [self.collectionView.collectionViewLayout layoutAttributesForElementsInRect:firstRowRect];
        
        return (UICollectionReusableView *)filterHeaderView;
    }
    return nil;
}

#pragma mark - FilterHeaderViewDelegateMethod
-(void)filterHeaderViewMoreBtnClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    switch (sender.tag) {
        case 0:
            //            NSLog(@"‼️‼️‼️‼️‼️点击第%@行",@(sender.tag));
            
            break;
        case 1:
            //            NSLog(@"‼️‼️‼️‼️‼️点击第%@行",@(sender.tag));
            break;
        case 2:
            //            NSLog(@"‼️‼️‼️‼️‼️点击第%@行",@(sender.tag));
            break;
        case 3:
            //            NSLog(@"‼️‼️‼️‼️‼️点击第%@行",@(sender.tag));
            break;
        default:
            break;
    }
}

#pragma mark - UICollectionViewDelegateLeftAlignedLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *symptoms = [NSArray arrayWithArray:[self.dataSource[indexPath.section] objectForKey:@"Symptoms"]];
    NSString *text = [symptoms[indexPath.row] objectForKey:@"Patient_Name"];
    
    CGSize size = [text sizeWithAttributes:
                   @{NSFontAttributeName:
                         [UIFont systemFontOfSize:16]}];
    return CGSizeMake(ceilf(size.width) + 10, kCollectionViewCellHeight);
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
    switch (section) {
        case 0:
            return UIEdgeInsetsMake(kCollectionViewToTopMargin, kCollectionViewToLeftMargin, kCollectionViewToBottomtMargin, kCollectionViewToRightMargin);

            break;
            
        default:
            return UIEdgeInsetsMake(kCollectionViewToTopMargin, kCollectionViewToLeftMargin, kCollectionViewToBottomtMargin, kCollectionViewToRightMargin);

            break;
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"‼️‼️‼️‼️‼️didSelectItemAtIndexPath");
    // 删除模型数据
    [self.dataSource removeObjectAtIndex:indexPath.item];
    
    // 删UI(刷新UI)
    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
}
@end
