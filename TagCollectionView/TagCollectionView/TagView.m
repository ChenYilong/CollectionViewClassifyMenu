//
//  ViewController.m
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 (year 2016) AK. All rights reserved.
//

#import "TagView.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "TagGroup.h"
#import "TagModel.h"
#import "HeaderCell.h"
#import "TagCell.h"  
#import "CYLMenuResources.h"



static NSString * const  TagCelIdenty = @"CellIdentifier";
static NSString * const  HeaderCellIdenty =  @"HeaderViewCellIdentifier";


@interface TagView ()<UICollectionViewDataSource,UICollectionViewDelegate,HeaderCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, assign) CGFloat lastCollectionWidth;




@end

@implementation TagView

@synthesize showHeader = _showHeader;

+(instancetype)TagView{
    TagView* view=  [[[UINib  nibWithNibName:@"TagView" bundle:[CYLMenuResources bundle]]instantiateWithOwner:nil options:nil] firstObject];
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
//        TagModel *m1 =[TagModel modelWithTitle:@"对对对"]; // Yes, yes, yes.
//        
//        TagModel *m2 =[TagModel modelWithTitle:@"吃饭"]; // Eat.
//        
//        TagModel *m3 =[TagModel modelWithTitle:@"睡觉"]; // Sleep.
//        
//        TagModel *m4=[TagModel modelWithTitle:@"睡觉asdfsfasfds"]; // Sleep, with extra text.
//        
//        TagModel *m5 =[TagModel modelWithTitle:@"asdfdsfdsf睡觉"]; // Extra text, then sleep.
//        
//        TagModel *m6 =[TagModel modelWithTitle:@"睡sdfdsf觉"]; // Sleep, with text in the middle.
//        
//        TagModel *m7 =[TagModel modelWithTitle:@"约炮"]; // Hook up.
//        
//        TagModel *m8 =[TagModel modelWithTitle:@"哈"]; // Ha.
//        
//        TagModel *m9 =[TagModel modelWithTitle:@"练武功"]; // Practice martial arts.
//        
//        TagModel *m10 =[TagModel modelWithTitle:@"打豆豆"]; // Play with Doudou.
//        
//        TagGroup *g1=[[TagGroup alloc]init];
//        
//        g1.itemArr=@[m7,m2,m3,m8,m1,m4,m5,m6];
//        
//        g1.groupName=@"dddd打游戏了"; // dddd, play games.
//        
//        [groupArray addObject:g1];
//        
//        
//        TagGroup *g2=[[TagGroup alloc]init];
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
        TagGroup *group = [[TagGroup alloc] init];
        group.section = section;
        group.groupName = [source menuTitleForSection:section];
        NSMutableArray *items = [NSMutableArray array];
        for (NSInteger item = 0; item < [source menuNumberOfItemsInSection:section]; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            [items addObject:[TagModel modelWithTitle:[source menuTitleForItemAtIndexPath:indexPath]]];
        }
        group.itemArr = items;
        [groups addObject:group];
    }
    self.groups = groups;
    [self.collectionView reloadData];
}

-(void)setupCollectionView{
    
    
    UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc] init];
    
    self.collectionView.collectionViewLayout=layout;
    
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TagCell" bundle:[CYLMenuResources bundle]] forCellWithReuseIdentifier:TagCelIdenty];
    

    [self.collectionView registerNib:[UINib nibWithNibName:@"HeaderCell" bundle:[CYLMenuResources bundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderCellIdenty];
    
    
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


#pragma mark HeaderCell Delegate
-(void)headerViewDidClickedNameView:(HeaderCell *)HeaderCell index:(NSInteger)idx{

    [self.collectionView reloadData];
    
}
#pragma mark - 🔌 UICollectionViewDataSource Method

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return self.groups.count;
    
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    TagGroup*group= self.groups[section];
    
    CGFloat contentWidth = MAX(0, CGRectGetWidth(collectionView.bounds) - kTagCollectionViewToLeftMargin - kTagCollectionViewToRightMargin);
    NSUInteger count= (group.isOpened ? group.itemArr.count : [group firstRowCellCountForContentWidth:contentWidth]);
    
    return  count;

}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{


    TagCell*cell= (TagCell*)[collectionView dequeueReusableCellWithReuseIdentifier:TagCelIdenty forIndexPath:indexPath];
    
    TagGroup*group= self.groups[indexPath.section];

    TagModel*model=group.itemArr[indexPath.row];
    
    
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
       
        HeaderCell* header =(HeaderCell*) [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderCellIdenty forIndexPath:indexPath];
        
        header.delegate=self;
        
        TagGroup*group= self.groups[indexPath.section];

        header.group=group;
        
        return header;
    }
    return nil;
}

#pragma mark - 🔌 UICollectionViewDelegateLeftAlignedLayout Method

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    TagGroup*group= self.groups[indexPath.section];
    
    TagModel*model=group.itemArr[indexPath.row];
    
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

    TagGroup*group= self.groups[section];
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
