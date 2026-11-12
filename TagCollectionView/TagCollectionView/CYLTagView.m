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
            CYLTagModel *model = [CYLTagModel modelWithTitle:[source menuTitleForItemAtIndexPath:indexPath]];
            [model updateSizeForTraitCollection:self.traitCollection];
            [items addObject:model];
        }
        group.itemArr = items;
        [groups addObject:group];
    }
    for (CYLTagGroup *group in groups) {
        group.width = CGRectGetWidth(self.collectionView.bounds);
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
        for (CYLTagGroup *group in self.groups) {
            group.width = width;
        }
        [self.collectionView reloadData];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (![previousTraitCollection.preferredContentSizeCategory isEqualToString:self.traitCollection.preferredContentSizeCategory]) {
        [self cyl_updateTagSizes];
    }
}

/// Re-measures every tag for the current text size and reloads the layout.
- (void)cyl_updateTagSizes {
    for (CYLTagGroup *group in self.groups) {
        for (CYLTagModel *model in group.itemArr) {
            [model updateSizeForTraitCollection:self.traitCollection];
        }
        // Re-assigning invalidates the group's cached row counts.
        group.itemArr = group.itemArr;
    }
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
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
    // Only headers have a size, so UIKit never asks for another kind.
    return [[UICollectionReusableView alloc] initWithFrame:CGRectZero];
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
