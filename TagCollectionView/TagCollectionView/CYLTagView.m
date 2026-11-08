//
//  ViewController.m
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 (year 2016) AK. All rights reserved.
//

#import "CYLTagView.h"
#import "CYLCollectionViewLeftAlignedLayout.h"
#import "CYLTagGroup.h"
#import "CYLTagModel.h"
#import "CYLTagHeaderCell.h"
#import "CYLTagCell.h"  
#import "CYLMenuResources.h"



static NSString * const  TagCelIdenty = @"CellIdentifier";
static NSString * const  HeaderCellIdenty =  @"HeaderViewCellIdentifier";


@interface CYLTagView ()<UICollectionViewDataSource,UICollectionViewDelegate,CYLTagHeaderCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, assign) CGFloat lastCollectionWidth;




@end

@implementation CYLTagView

@synthesize showHeader = _showHeader;

+(instancetype)tagView{
    CYLTagView* view=  [[[UINib  nibWithNibName:@"CYLTagView" bundle:[CYLMenuResources bundle]]instantiateWithOwner:nil options:nil] firstObject];
    return  view;
}

- (NSArray *)groups
{
//    // 默认数据 当有请求时候刷新数据 / Default data; refresh it when a request completes.
//    if (_groups == nil) {
//        
//        NSMutableArray *groupArray = [NSMutableArray array];
//   
//        
//        CYLTagModel *m1 =[CYLTagModel modelWithTitle:@"对对对"]; // Yes, yes, yes.
//        
//        CYLTagModel *m2 =[CYLTagModel modelWithTitle:@"吃饭"]; // Eat.
//        
//        CYLTagModel *m3 =[CYLTagModel modelWithTitle:@"睡觉"]; // Sleep.
//        
//        CYLTagModel *m4=[CYLTagModel modelWithTitle:@"睡觉asdfsfasfds"]; // Sleep, with extra text.
//        
//        CYLTagModel *m5 =[CYLTagModel modelWithTitle:@"asdfdsfdsf睡觉"]; // Extra text, then sleep.
//        
//        CYLTagModel *m6 =[CYLTagModel modelWithTitle:@"睡sdfdsf觉"]; // Sleep, with text in the middle.
//        
//        CYLTagModel *m7 =[CYLTagModel modelWithTitle:@"约炮"]; // Hook up.
//        
//        CYLTagModel *m8 =[CYLTagModel modelWithTitle:@"哈"]; // Ha.
//        
//        CYLTagModel *m9 =[CYLTagModel modelWithTitle:@"练武功"]; // Practice martial arts.
//        
//        CYLTagModel *m10 =[CYLTagModel modelWithTitle:@"打豆豆"]; // Play with Doudou.
//        
//        CYLTagGroup *g1=[[CYLTagGroup alloc]init];
//        
//        g1.itemArr=@[m7,m2,m3,m8,m1,m4,m5,m6];
//        
//        g1.groupName=@"dddd打游戏了"; // dddd, play games.
//        
//        [groupArray addObject:g1];
//        
//        
//        CYLTagGroup *g2=[[CYLTagGroup alloc]init];
//        
//        g2.groupName=@"打游戏了"; // Play games.
//        
//        g2.itemArr=@[m2,m3,m1,m4,m5,m6,m7,m10,m9];
//        
//        [groupArray addObject:g2];
//       
//        
//        _groups = groupArray;
//        
//        
//    }
    
    return _groups;
}


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                                             collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        [self setup];
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self setup];
}


-(void)setup{
    _showHeader = YES;
    [self setupCollectionView];
}

- (void)setShowHeader:(BOOL)showHeader {
    _showHeader = showHeader;
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
}

- (void)reloadMenuData {
    NSMutableArray *groups = [NSMutableArray array];
    id<CYLMenuDataSource> source = self.menuDataSource;
    for (NSInteger section = 0; section < [source numberOfSectionsInMenu]; section++) {
        CYLTagGroup *group = [[CYLTagGroup alloc] init];
        group.section = section;
        group.groupName = [source menuTitleForSection:section];
        NSMutableArray *items = [NSMutableArray array];
        for (NSInteger item = 0; item < [source menuNumberOfItemsInSection:section]; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            [items addObject:[CYLTagModel modelWithTitle:[source menuTitleForItemAtIndexPath:indexPath]]];
        }
        group.itemArr = items;
        [groups addObject:group];
    }
    self.groups = groups;
    [self.collectionView reloadData];
}

-(void)setupCollectionView{
    
    
    CYLCollectionViewLeftAlignedLayout *layout = [[CYLCollectionViewLeftAlignedLayout alloc] init];
    
    self.collectionView.collectionViewLayout=layout;
    
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CYLTagCell" bundle:[CYLMenuResources bundle]] forCellWithReuseIdentifier:TagCelIdenty];
    

    [self.collectionView registerNib:[UINib nibWithNibName:@"CYLTagHeaderCell" bundle:[CYLMenuResources bundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderCellIdenty];
    
    
    self.collectionView.contentInset = UIEdgeInsetsMake(35, 0, 0, 0);
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
//    self.collectionView.scrollsToTop = NO;
//    self.collectionView.scrollEnabled = NO;
}



-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.collectionView.bounds);
    if (width != self.lastCollectionWidth) {
        self.lastCollectionWidth = width;
        [self.collectionView reloadData];
    }
}


#pragma mark CYLTagHeaderCell Delegate
-(void)headerViewDidTapNameView:(CYLTagHeaderCell *)headerCell index:(NSInteger)idx{

    [self.collectionView reloadData];
    
}
#pragma mark - 🔌 UICollectionViewDataSource Method

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return self.groups.count;
    
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    CYLTagGroup*group= self.groups[section];
    
    CGFloat contentWidth = MAX(0, CGRectGetWidth(collectionView.bounds) - kTagCollectionViewToLeftMargin - kTagCollectionViewToRightMargin);
    NSUInteger count= (group.isOpened ? group.itemArr.count : [group firstRowCellCountForContentWidth:contentWidth]);
    
    return  count;

}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{


    CYLTagCell*cell= (CYLTagCell*)[collectionView dequeueReusableCellWithReuseIdentifier:TagCelIdenty forIndexPath:indexPath];
    
    CYLTagGroup*group= self.groups[indexPath.section];

    CYLTagModel*model=group.itemArr[indexPath.row];
    
    
    cell.model=model;
    
    return  cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.menuDelegate respondsToSelector:@selector(menu:didSelectItemAtIndexPath:)]) {
        [self.menuDelegate menu:self didSelectItemAtIndexPath:indexPath];
    }
    
//    NSLog(@"\n index:sec%lu row%lu \n model:sec%lu row%lu %@",indexPath.section,indexPath.row,model.section,model.row,model.title);
    
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
       
        CYLTagHeaderCell* header =(CYLTagHeaderCell*) [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderCellIdenty forIndexPath:indexPath];
        
        header.delegate=self;
        
        CYLTagGroup*group= self.groups[indexPath.section];

        header.group=group;
        
        return header;
    }
    return nil;
}

#pragma mark - 🔌 UICollectionViewDelegateLeftAlignedLayout Method

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    CYLTagGroup*group= self.groups[indexPath.section];
    
    CYLTagModel*model=group.itemArr[indexPath.row];
    
    CGFloat contentWidth = MAX(0, CGRectGetWidth(collectionView.bounds) - kTagCollectionViewToLeftMargin - kTagCollectionViewToRightMargin);
    return CGSizeMake(MIN(MAX(0, model.width), contentWidth), model.height);
    
}

//itemSpacing
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return kTagCollectionViewCellsHorizonMargin;
}


//SizeForHeader
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {

    CYLTagGroup*group= self.groups[section];
    if (!self.isShowHeader) {
        return CGSizeZero;
    }
    
    return CGSizeMake(MAX(0, CGRectGetWidth(collectionView.bounds) - kTagCollectionViewToLeftMargin - kTagCollectionViewToRightMargin), group.height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(kTagCollectionViewToTopMargin, kTagCollectionViewToLeftMargin, kTagCollectionViewToBottomtMargin, kTagCollectionViewToRightMargin);
}


@end
