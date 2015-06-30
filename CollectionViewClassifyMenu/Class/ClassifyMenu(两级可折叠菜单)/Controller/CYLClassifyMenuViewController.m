
//  CYLClassifyMenuViewController.m
//  CollectionViewClassifyMenu
//
//  Created by https://github.com/ChenYilong on 15/3/17.
//  Copyright (c)  http://weibo.com/luohanchenyilong/ . All rights reserved.
//  Single Choice Filter

static float const kControllerHeaderViewHeight                = 90.f;
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
#import "CollectionViewCell.h"
//Others
#import "UICollectionViewLeftAlignedLayout.h"
#import "CYLDBManager.h"

static NSString * const kCellIdentifier           = @"CellIdentifier";
static NSString * const kHeaderViewCellIdentifier = @"HeaderViewCellIdentifier";
typedef void(^ISLimitWidth)(BOOL yesORNo,id data);

@interface CYLClassifyMenuViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
FilterHeaderViewDelegate
>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray          *dataSource;
@property (nonatomic, assign) float            priorCellY;
@property (nonatomic, assign) NSUInteger       rowLine;
@property (nonatomic, strong) NSMutableArray   *collectionHeaderMoreBtnHideBoolArray;
@property (nonatomic, strong) NSMutableArray   *firstLineCellCountArray;
@property (nonatomic, strong) NSMutableArray   *expandSectionArray;
@property (nonatomic, strong) UIScrollView     *backgroundView;
@property (nonatomic, strong) UILabel          *titleLabel;
@property (nonatomic, strong) UISwitch         *showLineSwitch;

@end

@implementation CYLClassifyMenuViewController

#pragma mark - 💤 LazyLoad Method

- (NSMutableArray *)collectionHeaderMoreBtnHideBoolArray
{
    if (_collectionHeaderMoreBtnHideBoolArray == nil) {
        _collectionHeaderMoreBtnHideBoolArray = [[NSMutableArray alloc] init];
        __weak __typeof(self) weakSelf = self;
        [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf->_collectionHeaderMoreBtnHideBoolArray addObject:@YES];
        }];
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

#pragma mark - ♻️ LifeCycle Method

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"@iOS程序犭袁";
    self.backgroundView = [[UIScrollView alloc] initWithFrame:
                           CGRectMake(0, 0,
                                      [UIScreen mainScreen].bounds.size.width,
                                      [UIScreen mainScreen].bounds.size.height)
                           ];
    self.backgroundView.showsVerticalScrollIndicator = NO;
    self.backgroundView.alwaysBounceVertical = YES;
    self.backgroundView.backgroundColor = [UIColor colorWithRed:252.0f/255.f green:252.0f/255.f blue:252.0f/255.f alpha:2.f];
    [self.view addSubview:self.backgroundView];
    
    [self initData];
    [self addCollectionView];
    [self judgeMoreBtnShow];
    [self.backgroundView addSubview:[self addTableHeaderView]];
    self.view.backgroundColor = [UIColor blueColor];
    //如果想显示两行，请打开下面两行代码,(这两行代码必须在“[self addTableHeaderView]”之后)
//    self.showLineSwitch.on = YES;
//    [self showLineSwitchClicked:self.showLineSwitch];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.backgroundView.scrollEnabled = YES;
    [self updateViewHeight];
}

#pragma mark - 🆑 CYL Custom Method

- (void)initDefaultShowCellCount {
    for (NSUInteger index = 0; index < self.firstLineCellCountArray.count; index++) {
        NSArray *secondLineCellCountArray = [NSArray arrayWithArray:[self secondLineCellCount]];
        NSNumber *object = @([self.firstLineCellCountArray[index] intValue] +
        [secondLineCellCountArray[index] intValue]);
        [self.firstLineCellCountArray replaceObjectAtIndex:index
                                                withObject:object];
    }
}

- (void)initData {
    self.firstLineCellCountArray = nil;
    self.collectionHeaderMoreBtnHideBoolArray = nil;
    self.rowLine = 0;
    self.dataSource = [NSArray arrayWithArray:[CYLDBManager dataSource]];
}

- (float)cellLimitWidth:(float)cellWidth
            limitMargin:(CGFloat)limitMargin
           isLimitWidth:(ISLimitWidth)isLimitWidth {
    float limitWidth = (CGRectGetWidth(self.collectionView.frame) - kCollectionViewToLeftMargin - kCollectionViewToRightMargin - limitMargin);
    if (cellWidth >= limitWidth) {
        cellWidth = limitWidth;
        isLimitWidth?isLimitWidth(YES,@(cellWidth)):nil;
        return cellWidth;
    }
    isLimitWidth?isLimitWidth(NO,@(cellWidth)):nil;
    return cellWidth;
}

- (float)textAndImageWidth:(NSString *)text
                   content:(id)obj
                     array:(NSArray *)array {
    CGFloat contentViewWidth = CGRectGetWidth(self.collectionView.frame) - kCollectionViewToLeftMargin - kCollectionViewToRightMargin;
    __block float cellWidth = [self collectionCellWidthText:text content:obj];
    __block float cellWidthAndRightMargin;
    [self cellLimitWidth:cellWidth
             limitMargin:kCollectionViewCellsHorizonMargin
            isLimitWidth:^(BOOL yesORNo, NSNumber *data) {
                cellWidth = [data floatValue];
                if (yesORNo == YES) {
                    cellWidthAndRightMargin = contentViewWidth;
                } else {
                    if (obj == [array lastObject]) {
                        cellWidthAndRightMargin = cellWidth;
                    } else {
                        cellWidthAndRightMargin = cellWidth + kCollectionViewCellsHorizonMargin;
                    }
                }
            }];
    return cellWidthAndRightMargin;
}

- (void)judgeMoreBtnShow {
    CGFloat contentViewWidth = self.collectionView.frame.size.width -
    kCollectionViewToLeftMargin - kCollectionViewToRightMargin;
    NSMutableArray *firstLineWidthArray = [NSMutableArray array];
    __weak __typeof(self) weakSelf = self;
    [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __strong typeof(self) strongSelf = weakSelf;
        __block NSUInteger firstLineCellCount = 0;
        @autoreleasepool {
            NSArray *symptoms = [NSArray arrayWithArray:[obj objectForKey:kDataSourceSectionKey]];
            NSMutableArray *widthArray = [NSMutableArray array];
            __weak __typeof(symptoms) weakSymptoms = symptoms;
            [symptoms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *text = [obj objectForKey:kDataSourceCellTextKey];
                float cellWidthAndRightMargin = [strongSelf textAndImageWidth:text
                                                                      content:obj
                                                                        array:weakSymptoms];
                [widthArray  addObject:@(cellWidthAndRightMargin)];
                NSArray *sumArray = [NSArray arrayWithArray:widthArray];
                NSNumber* sum = [sumArray valueForKeyPath: @"@sum.self"];
                
                if ([sum floatValue] <= contentViewWidth) {
                    firstLineCellCount++;
                }
            }];
            [strongSelf.firstLineCellCountArray addObject:@(firstLineCellCount)];
            NSArray *sumArray = [NSArray arrayWithArray:widthArray];
            NSNumber* sum = [sumArray valueForKeyPath: @"@sum.self"];
            [firstLineWidthArray addObject:sum];
        }
    }];
    [firstLineWidthArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj floatValue] > contentViewWidth) {
            [self.collectionHeaderMoreBtnHideBoolArray replaceObjectAtIndex:idx withObject:@NO];
        } else {
            [self.collectionHeaderMoreBtnHideBoolArray replaceObjectAtIndex:idx withObject:@YES];        }
    }];
}

- (void)judgeMoreBtnShowWhenShowTwoRows {
    CGFloat contentViewWidth = CGRectGetWidth(self.collectionView.frame) - kCollectionViewToLeftMargin - kCollectionViewToRightMargin;
    NSMutableArray *twoRowsWidthArray = [NSMutableArray array];
    __weak __typeof(self) weakSelf = self;
    [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            __strong typeof(self) strongSelf = weakSelf;
            __block NSUInteger countTime = 0;
            NSArray *symptoms = [NSArray arrayWithArray:[obj objectForKey:kDataSourceSectionKey]];
            NSMutableArray *widthArray = [NSMutableArray array];
            __weak __typeof(symptoms) weakSymptoms = symptoms;
            [symptoms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *text = [obj objectForKey:kDataSourceCellTextKey];
                float cellWidthAndRightMargin = [strongSelf textAndImageWidth:text
                                                                      content:obj
                                                                        array:weakSymptoms];
                [widthArray  addObject:@(cellWidthAndRightMargin)];
                NSMutableArray *sumArray = [NSMutableArray arrayWithArray:widthArray];
                NSNumber* sum = [sumArray valueForKeyPath: @"@sum.self"];
                if ([sum floatValue] <= contentViewWidth) {
                    //未超过一行
                } else {
                    //超过一行时
                    if(countTime == 0) {
                        [widthArray removeAllObjects];
                        [self cellLimitWidth:cellWidthAndRightMargin
                                 limitMargin:kCollectionViewCellsHorizonMargin
                                isLimitWidth:^(BOOL yesORNo, NSNumber *data) {
                                    if (yesORNo == YES) {
                                        //如果cell宽度或者cell宽度加上间距超过collectionView的contentView宽度，则将cell自成一行
                                        [widthArray addObject:@(contentViewWidth)];
                                    } else {
                                        //                                        if (obj != [weakSymptoms lastObject]) {
                                        //                                            [widthArray addObject:@(cellWidthAndRightMargin+kCollectionViewCellsHorizonMargin)];
                                        //                                        } else {
                                        [widthArray addObject:@(cellWidthAndRightMargin)];
                                        //                                        }
                                    }
                                }];
                    }
                    countTime++;
                }
            }];
            NSArray *sumArray = [NSArray arrayWithArray:widthArray];
            NSNumber* sum = [sumArray valueForKeyPath: @"@sum.self"];
            [twoRowsWidthArray addObject:sum];
        }
    }];
    [twoRowsWidthArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj floatValue] > contentViewWidth) {
            [self.collectionHeaderMoreBtnHideBoolArray replaceObjectAtIndex:idx withObject:@NO];
        } else {
            [self.collectionHeaderMoreBtnHideBoolArray replaceObjectAtIndex:idx withObject:@YES];
        }
    }];
}

-(NSArray *)secondLineCellCount {
    NSMutableArray *secondLineCellCountArray = [NSMutableArray array];
    __weak __typeof(self) weakSelf = self;
    [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            __strong typeof(self) strongSelf = weakSelf;
            NSMutableArray *symptoms = [[NSMutableArray alloc] initWithArray:[obj objectForKey:kDataSourceSectionKey]];
            float firstLineCount = [strongSelf firstLineCellCountWithArray:symptoms];
            if (symptoms.count != firstLineCount) {
                NSRange range = NSMakeRange(0, firstLineCount);
                [symptoms removeObjectsInRange:range];
                float secondLineCount = [strongSelf firstLineCellCountWithArray:symptoms];
                [secondLineCellCountArray addObject:@(secondLineCount)];
            } else {
                [secondLineCellCountArray addObject:@(0)];
            }
        }
    }];
    return (NSArray *)secondLineCellCountArray;
}

- (NSUInteger)firstLineCellCountWithArray:(NSArray *)array {
    CGFloat contentViewWidth = CGRectGetWidth(self.collectionView.frame) - kCollectionViewToLeftMargin - kCollectionViewToRightMargin;
    __block NSUInteger firstLineCellCount = 0;
    NSMutableArray *widthArray = [NSMutableArray array];
    __weak __typeof(array) weakArray = array;
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            NSString *text = [obj objectForKey:kDataSourceCellTextKey];
            float cellWidthAndRightMargin = [self textAndImageWidth:text
                                                            content:obj
                                                              array:weakArray];
            [widthArray  addObject:@(cellWidthAndRightMargin)];
            NSArray *sumArray = [NSArray arrayWithArray:widthArray];
            NSNumber *sum = [sumArray valueForKeyPath:@"@sum.self"];
            //之所以要减去kCollectionViewToRightMargin，是为防止这种情况发生：https://i.imgur.com/6yFPQ8U.gif
            CGFloat firstRowWidth = [sum floatValue] - kCollectionViewToRightMargin;
            if ((firstRowWidth <= contentViewWidth)) {
                firstLineCellCount++;
            }
        }
    }];
    return firstLineCellCount;
}

- (float)collectionCellWidthText:(NSString *)text content:(NSDictionary *)content{
    float cellWidth;
    CGSize size = [text sizeWithAttributes:
                   @{NSFontAttributeName:
                         [UIFont systemFontOfSize:16]}];
    NSString *picture = [content objectForKey:kDataSourceCellPictureKey];
    BOOL shouldShowPic = [@(picture.length) boolValue];
    if(shouldShowPic) {
        cellWidth = ceilf(size.width) + kCellBtnCenterToBorderMargin * 2;
    } else {
        cellWidth = ceilf(size.width) + kCellBtnCenterToBorderMargin;
    }
    cellWidth = [self cellLimitWidth:cellWidth
                         limitMargin:0
                        isLimitWidth:nil];
    return cellWidth;
}

- (UIView *)addTableHeaderView
{
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kControllerHeaderViewHeight)];
    tableHeaderView.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 35, tableHeaderView.frame.size.width, 20)];
    self.titleLabel = titleLabel;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textColor = [UIColor colorWithRed:0 green:150.0/255.0 blue:136.0/255.0 alpha:1.0];
    NSString *title = @"默认显示一行时的效果如下所示:";
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:title];
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor redColor]
                 range:NSMakeRange(4, 2)];
    titleLabel.attributedText = text;
    [tableHeaderView addSubview:titleLabel];
    CGSize size = [title sizeWithAttributes:
                   @{NSFontAttributeName:
                         titleLabel.font}];
    float cellWidth = ceilf(size.width);
    //仅修改titleLabel的宽度,xyh值不变
    titleLabel.frame = CGRectMake(CGRectGetMinX(titleLabel.frame),
                                  CGRectGetMidY(titleLabel.frame),
                                  cellWidth,
                                  CGRectGetHeight(titleLabel.frame)
                                  );
    UISwitch *showLineSwitch = [[UISwitch alloc] init];
    showLineSwitch.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame) + 10,
                                      25, 30, 20);
    [tableHeaderView addSubview:showLineSwitch];
    [showLineSwitch addTarget:self action:@selector(showLineSwitchClicked:) forControlEvents:UIControlEventAllEvents];
    self.showLineSwitch = showLineSwitch;
    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.frame = CGRectMake(titleLabel.frame.origin.x,
                                     CGRectGetMaxY(titleLabel.frame) + 10,
                                     [UIScreen mainScreen].bounds.size.width,
                                     14
                                     );
    subtitleLabel.font = [UIFont systemFontOfSize:12];
    subtitleLabel.textColor = [UIColor grayColor];
    subtitleLabel.text = @"超出默认行数,出现\"更多\"按钮,点击展开.@iOS程序犭袁 出品";
    [tableHeaderView addSubview:subtitleLabel];
    return tableHeaderView;
}

- (void)addCollectionView {
    CGRect collectionViewFrame = CGRectMake(0, kControllerHeaderViewHeight + kControllerHeaderToCollectionViewMargin, [UIScreen mainScreen].bounds.size.width,
                                            [UIScreen mainScreen].bounds.size.height-40);
    UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame
                                             collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[CollectionViewCell class]
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
    //仅修改self.collectionView的高度,xyw值不变
    self.collectionView.frame = CGRectMake(CGRectGetMinX(self.collectionView.frame),
                                           CGRectGetMinY(self.collectionView.frame),
                                           CGRectGetWidth(self.collectionView.frame),
                                           self.collectionView.contentSize.height +
                                           kCollectionViewToTopMargin +
                                           kCollectionViewToBottomtMargin);
    self.backgroundView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,
                                                 self.collectionView.contentSize.height +
                                                 kControllerHeaderViewHeight +
                                                 kCollectionViewToTopMargin +
                                                 kCollectionViewToBottomtMargin +
                                                 64);
}

- (void)showLineSwitchClicked:(UISwitch *)sender {
    [self initData];
    [self judgeMoreBtnShow];
    NSString *title;
    if(sender.isOn) {
        title = @"默认显示两行时的效果如下所示:";
        [self judgeMoreBtnShowWhenShowTwoRows];
        [self initDefaultShowCellCount];
    } else {
        title = @"默认显示一行时的效果如下所示:";
    }
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:title];
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor redColor]
                 range:NSMakeRange(4, 2)];
    self.titleLabel.attributedText = text;
    [self.collectionView reloadData];
    __weak __typeof(self) weakSelf = self;
    [self.collectionView performBatchUpdates:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.collectionView reloadData];
    } completion:^(BOOL finished) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf updateViewHeight];
    }];
}

#pragma mark - 🔌 UICollectionViewDataSource Method

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.dataSource count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    NSArray *symptoms = [NSArray arrayWithArray:[self.dataSource[section] objectForKey:kDataSourceSectionKey]];
    for (NSNumber *i in self.expandSectionArray) {
        if (section == [i integerValue]) {
            return [symptoms count];
        }
    }
    return [self.firstLineCellCountArray[section] integerValue];
}

- (BOOL)shouldCollectionCellPictureShowWithIndex:(NSIndexPath *)indexPath {
    NSMutableArray *symptoms = [NSMutableArray arrayWithArray:[self.dataSource[indexPath.section] objectForKey:kDataSourceSectionKey]];
    NSString *picture = [symptoms[indexPath.row] objectForKey:kDataSourceCellPictureKey];
    NSUInteger pictureLength = [@(picture.length) intValue];
    if(pictureLength > 0) {
        return YES;
    }
    return NO;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell =
    (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier
                                                                    forIndexPath:indexPath];
    cell.button.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    NSMutableArray *symptoms = [NSMutableArray arrayWithArray:[self.dataSource[indexPath.section]
                                                               objectForKey:kDataSourceSectionKey]];
    NSString *text = [symptoms[indexPath.row] objectForKey:kDataSourceCellTextKey];
    BOOL shouldShowPic = [self shouldCollectionCellPictureShowWithIndex:indexPath];
    if(shouldShowPic) {
        [cell.button setImage:[UIImage imageNamed:@"home_btn_shrink"]
                     forState:UIControlStateNormal];
        CGFloat spacing = kCollectionViewItemButtonImageToTextMargin;
        cell.button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
        cell.button.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
    } else {
        [cell.button setImage:nil forState:UIControlStateNormal];
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

#pragma mark - 🎬 Actions Method

- (void)itemButtonClicked:(CYLIndexPathButton *)button {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:button.row inSection:button.section];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
}

#pragma mark - 🔌 UICollectionViewDelegate Method

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //二级菜单数组
    NSArray *symptoms = [NSArray arrayWithArray:[self.dataSource[indexPath.section]
                                                 objectForKey:kDataSourceSectionKey]];
    NSString *sectionTitle = [self.dataSource[indexPath.section] objectForKey:@"Type"];
    BOOL shouldShowPic = [self shouldCollectionCellPictureShowWithIndex:indexPath];
    NSString *cellTitle = [symptoms[indexPath.row] objectForKey:kDataSourceCellTextKey];
    NSString *message = shouldShowPic?[NSString stringWithFormat:@"★%@",cellTitle]:cellTitle;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:sectionTitle
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];
    [alert show];
    NSUInteger delaySeconds = 1;
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySeconds * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    });
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
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
        [filterHeaderView.titleButton setTitle:sectionTitle forState:UIControlStateNormal];
        [filterHeaderView.titleButton setTitle:sectionTitle forState:UIControlStateSelected];
        switch (indexPath.section) {
            case 0:
                [filterHeaderView.titleButton setImage:[UIImage imageNamed:@"home_btn_cosmetic"]
                                              forState:UIControlStateNormal];
                break;
            case 1:
                [filterHeaderView.titleButton setImage:[UIImage imageNamed:@"home_btn_cosmetic"]
                                              forState:UIControlStateNormal];
                break;
            case 2:
                [filterHeaderView.titleButton setImage:[UIImage imageNamed:@"home_btn_cosmetic"]
                                              forState:UIControlStateNormal];
                break;
            case 3:
                [filterHeaderView.titleButton setImage:[UIImage imageNamed:@"home_btn_cosmetic"]
                                              forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        for (NSNumber *i in self.expandSectionArray) {
            if (indexPath.section == [i integerValue]) {
                filterHeaderView.moreButton.selected = YES;
            }
        }
        return (UICollectionReusableView *)filterHeaderView;
    }
    return nil;
}

#pragma mark - 🔌 FilterHeaderViewDelegateMethod Method

-(void)filterHeaderViewMoreBtnClicked:(UIButton *)sender {
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
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *symptoms = [NSArray arrayWithArray:[self.dataSource[indexPath.section] objectForKey:kDataSourceSectionKey]];
    NSString *text = [symptoms[indexPath.row] objectForKey:kDataSourceCellTextKey];
    float cellWidth = [self collectionCellWidthText:text content:symptoms[indexPath.row]];
    return CGSizeMake(cellWidth, kCollectionViewCellHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kCollectionViewCellsHorizonMargin;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, 38);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kCollectionViewToTopMargin, kCollectionViewToLeftMargin, kCollectionViewToBottomtMargin, kCollectionViewToRightMargin);
}

@end
