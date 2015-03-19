//
//  CYLClassifyMenuViewController.m
//  CollectionViewClassifyMenu
//
//  Created by chenyilong on 15/3/17.
//  Copyright (c) 2015年 chenyilong. All rights reserved.
//

#import "CYLClassifyMenuViewController.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "CollectionViewCell.h"
#import "FilterHeaderView.h"
#import "MJExtension.h"

static NSString * const kCellIdentifier = @"CellIdentifier";
static NSString * const kHeaderViewCellIdentifier = @"HeaderViewCellIdentifier";

@interface CYLClassifyMenuViewController () <UICollectionViewDataSource,UICollectionViewDelegate,FilterHeaderViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSMutableArray *leveOneMenuDatasource;
@property (nonatomic, strong) NSMutableArray *leveTwoMenuDatasource;

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
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSLog(@"%@",json);
    [json writeToFile:@"/Users/chenyilong/Documents/123.plist" atomically:YES];
    self.dataSource = [NSArray arrayWithArray:json];
    [json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //一级菜单数组
        NSString *sectionTitle = [obj objectForKey:@"Type"];
        [self.leveOneMenuDatasource addObject:sectionTitle];
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
    NSArray *symptoms = [NSArray arrayWithArray:[self.dataSource[indexPath.section] objectForKey:@"Symptoms"]];
    NSString *text = [symptoms[indexPath.row] objectForKey:@"Patient_Name"];
    [cell.button setTitle:text forState:UIControlStateNormal];
    [cell.button setTitle:text forState:UIControlStateSelected];
//    [cell.button addTarget:self action:@selector(itemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
//    cell.button.selected = [self.dataSource[indexPath.section][indexPath.row] boolValue];
//    cell.button.section = indexPath.section;
//    cell.button.row = indexPath.row;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqual:UICollectionElementKindSectionHeader]) {
        FilterHeaderView *filterHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewCellIdentifier forIndexPath:indexPath];
        filterHeaderView.delegate = self;
        NSString *sectionTitle = [self.dataSource[indexPath.section] objectForKey:@"Type"];
        filterHeaderView.titleButton.tag = indexPath.section;
        NSLog(@"‼️‼️‼️‼️‼️filterHeaderView.titleButton.tag=%@",@(filterHeaderView.titleButton.tag));
        [filterHeaderView.titleButton setTitle:sectionTitle forState:UIControlStateNormal];
        [filterHeaderView.titleButton setTitle:sectionTitle forState:UIControlStateSelected];
        return (UICollectionReusableView *)filterHeaderView;
    }
    return nil;
}

#pragma mark - FilterHeaderViewDelegateMethod
-(void)filterHeaderViewMoreBtnClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            NSLog(@"‼️‼️‼️‼️‼️点击第%@行",@(sender.tag));
            break;
        case 1:
            NSLog(@"‼️‼️‼️‼️‼️点击第%@行",@(sender.tag));

            break;
        case 2:
            NSLog(@"‼️‼️‼️‼️‼️点击第%@行",@(sender.tag));

            break;
        case 3:
            NSLog(@"‼️‼️‼️‼️‼️点击第%@行",@(sender.tag));

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
    return CGSizeMake(ceilf(size.width) + 10, 30);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, 38);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

@end
