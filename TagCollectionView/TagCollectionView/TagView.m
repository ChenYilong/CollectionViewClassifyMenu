//
//  ViewController.m
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 AK. All rights reserved.
//

#import "TagView.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "TagGroup.h"
#import "TagModel.h"
#import "HeaderCell.h"
#import "TagCell.h"  



static NSString * const  TagCelIdenty = @"CellIdentifier";
static NSString * const  HeaderCellIdenty =  @"HeaderViewCellIdentifier";


@interface TagView ()<UICollectionViewDataSource,UICollectionViewDelegate,HeaderCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, assign) CGFloat lastCollectionWidth;




@end

@implementation TagView

+(instancetype)TagView{
    TagView* view=  [[[UINib  nibWithNibName:@"TagView" bundle:nil]instantiateWithOwner:nil options:nil] firstObject];
    return  view;
}

- (NSArray *)groups
{
//    //默认数据 当有请求时候刷新数据
//    if (_groups == nil) {
//        
//        NSMutableArray *groupArray = [NSMutableArray array];
//   
//        
//        TagModel *m1 =[TagModel modelWithTitle:@"对对对"];
//        
//        TagModel *m2 =[TagModel modelWithTitle:@"吃饭"];
//        
//        TagModel *m3 =[TagModel modelWithTitle:@"睡觉"];
//        
//        TagModel *m4=[TagModel modelWithTitle:@"睡觉asdfsfasfds"];
//        
//        TagModel *m5 =[TagModel modelWithTitle:@"asdfdsfdsf睡觉"];
//        
//        TagModel *m6 =[TagModel modelWithTitle:@"睡sdfdsf觉"];
//        
//        TagModel *m7 =[TagModel modelWithTitle:@"约炮"];
//        
//        TagModel *m8 =[TagModel modelWithTitle:@"哈"];
//        
//        TagModel *m9 =[TagModel modelWithTitle:@"练武功"];
//        
//        TagModel *m10 =[TagModel modelWithTitle:@"打豆豆"];
//        
//        TagGroup *g1=[[TagGroup alloc]init];
//        
//        g1.itemArr=@[m7,m2,m3,m8,m1,m4,m5,m6];
//        
//        g1.groupName=@"dddd打游戏了";
//        
//        [groupArray addObject:g1];
//        
//        
//        TagGroup *g2=[[TagGroup alloc]init];
//        
//        g2.groupName=@"打游戏了";
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
    
    if (self==[super initWithCoder:aDecoder]) {
        
        
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self==[super initWithFrame:frame]) {
        //todo: 通过代码添加控件...
        [self setup];
        
    }
    return self;
}

-(void)awakeFromNib{
    [self setup];
}


-(void)setup{
    [self setupCollectionView];
}

-(void)setupCollectionView{
    
    
    UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc] init];
    
    self.collectionView.collectionViewLayout=layout;
    
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TagCell" bundle:nil] forCellWithReuseIdentifier:TagCelIdenty];
    

    [self.collectionView registerNib:[UINib nibWithNibName:@"HeaderCell" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderCellIdenty];
    
    
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
    
    CGFloat contentWidth = MAX(0, CGRectGetWidth(collectionView.bounds) - kCollectionViewToLeftMargin - kCollectionViewToRightMargin);
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
    
    TagGroup*group= self.groups[indexPath.section];
    
    TagModel*model=group.itemArr[indexPath.row];

    NSLog(@"%@",model.title);
    
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
    
    CGFloat contentWidth = MAX(0, CGRectGetWidth(collectionView.bounds) - kCollectionViewToLeftMargin - kCollectionViewToRightMargin);
    return CGSizeMake(MIN(MAX(0, model.width), contentWidth), model.height);
    
}

//itemSpacing
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return kCollectionViewCellsHorizonMargin;
}


//SizeForHeader
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {

    TagGroup*group= self.groups[section];

//    if (self.isShowHeader==NO) {
//    
//        return CGSizeMake(0, 0);
//    
//    }
    
    return CGSizeMake(MAX(0, CGRectGetWidth(collectionView.bounds) - kCollectionViewToLeftMargin - kCollectionViewToRightMargin), group.height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(kCollectionViewToTopMargin, kCollectionViewToLeftMargin, kCollectionViewToBottomtMargin, kCollectionViewToRightMargin);
}


@end
