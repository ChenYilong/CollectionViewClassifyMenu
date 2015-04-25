//
//  FilterBaseController.m
//  PiFuKeYiSheng
//
//  Created by 喻平 on 14-5-12.
//  Copyright (c) 2014年 com.pifukeyisheng. All rights reserved.
//


#import "FilterBaseController.h"
#import "UIImage+Blur.h"
#import "UIView+General.h"
#import "CYLFilterParamsTool.h"
#import "AppDelegate.h"

@interface FilterBaseController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak) IBOutlet UIImageView *blurImageView;
@end

@implementation FilterBaseController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = [UIScreen mainScreen].bounds;
    
    
    CGColorRef color = [UIColor lightGrayColor].CGColor;
    _restoreButton.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, ([UIScreen mainScreen].bounds.size.width - 50) / 2, 44);
    _okButton.frame = CGRectMake(_restoreButton.width, [UIScreen mainScreen].bounds.size.height - 44, [UIScreen mainScreen].bounds.size.width - 50 - _restoreButton.width, 44);
    
    [_restoreButton addSubLayerWithFrame:CGRectMake(0, 0, _restoreButton.frame.size.width, 0.5f) color:color];
    [_okButton addSubLayerWithFrame:CGRectMake(0, 0, _okButton.frame.size.width, 0.5f) color:color];
    [_okButton addSubLayerWithFrame:CGRectMake(0, 0, 0.5f, 44) color:color];
    _contentView.backgroundColor = [UIColor blackColor];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc] init];
    _collectionView.collectionViewLayout = layout;
    _collectionView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    [_collectionView registerClass:[FilterCollectionCell class] forCellWithReuseIdentifier:@"FilterCollectionCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"FilterHeaderView" bundle:nil]
      forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
             withReuseIdentifier:@"FilterHeaderView"];
    
    [_contentView setTarget:self action:@selector(hide)];
    
}


- (void)itemButtonClicked:(CYLIndexPathButton *)button
{
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _settingArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //NSLog(@"count-->%d", [_settingArray[section] count]);
    return [_settingArray[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FilterCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FilterCollectionCell" forIndexPath:indexPath];
    CGSize size = [self collectionView:collectionView layout:nil sizeForItemAtIndexPath:indexPath];
    cell.titleButton.frame = CGRectMake(0, 0, size.width, size.height);
    NSString *text = _dataSource[indexPath.section][indexPath.row];
    [cell.titleButton setTitle:text forState:UIControlStateNormal];
    [cell.titleButton setTitle:text forState:UIControlStateSelected];
    [cell.titleButton addTarget:self action:@selector(itemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.titleButton.selected = [_settingArray[indexPath.section][indexPath.row] boolValue];
    cell.titleButton.section = indexPath.section;
    cell.titleButton.row = indexPath.row;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind

                                 atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqual:UICollectionElementKindSectionHeader]) {
        FilterHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"FilterHeaderView" forIndexPath:indexPath];
        return view;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegateLeftAlignedLayout

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSString *text = _dataSource[indexPath.section][indexPath.row];
//    CGSize size = [text sizeWithAttributes:
//                   @{NSFontAttributeName:
//                         [UIFont systemFontOfSize:16]}];
//    float width = [self checkCellLimitWidth:ceilf(size.width)];
//    return CGSizeMake(width + 10, 30);
//}
//
//- (float)checkCellLimitWidth:(float)cellWidth {
//    float limitWidth = (self.collectionView.contentSize.width-kCollectionViewToLeftMargin-kCollectionViewToRightMargin);
//    if (cellWidth >= limitWidth) {
//        cellWidth = limitWidth;
//        return cellWidth;
//    }
//    return cellWidth;
//}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, 38);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kCollectionViewToTopMargin, kCollectionViewToLeftMargin, kCollectionViewToBottomtMargin, kCollectionViewToRightMargin);
}

- (IBAction)confirmButtonClicked:(id)sender
{
    [UIView animateWithDuration:0.3f animations:^{
        _collectionView.x = -_collectionView.width;
        _restoreButton.x = -_restoreButton.width;
        _blurImageView.x = -_blurImageView.width;
        _okButton.x = -_okButton.width;
        _contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        if (_delegate && [_delegate respondsToSelector:@selector(filterControllerDidCompleted:)]) {
            [_delegate filterControllerDidCompleted:self];
        }
    }];
}

- (IBAction)restoreButtonClicked:(id)sender
{
    //    for (NSMutableArray *setting in _settingArray) {
    //        for (int i = 0; i < setting.count; i++) {
    //            [setting replaceObjectAtIndex:i withObject:@(i == 0)];
    //        }
    //    }
    //    CYLFilterParamsTool *filterParamsTool = [[CYLFilterParamsTool alloc] init];
    //    [NSKeyedArchiver archiveRootObject:filterParamsTool toFile:filterParamsTool.filename];
    //    [_collectionView reloadData];
    [self confirmButtonClicked:nil];
}

- (void)showInView:(UIView *)view
{
    AppDelegate *delegate= (AppDelegate *)[UIApplication sharedApplication].delegate;
    // 屏幕截图
    UIImage *screen = [delegate.navigationController.view capture];
    // 生成高斯模糊背景
    UIImage *blur = [screen blurredImageWithRadius:25.0f iterations:10 tintColor:nil];
    [view addSubview:self.view];
    _blurImageView.image = blur;
    _collectionView.x = -_collectionView.width;
    _restoreButton.x = -_restoreButton.width;
    _blurImageView.x = -_blurImageView.width;
    _okButton.x = -_okButton.width;
    
    _contentView.alpha = 0;
    [UIView animateWithDuration:0.3f animations:^{
        _collectionView.x = 0;
        _restoreButton.x = 0;
        _blurImageView.x = 0;
        _okButton.x = _restoreButton.width;
        _contentView.alpha = 0.35f;
    }];
}

- (void)hide
{
    [UIView animateWithDuration:0.3f animations:^{
        _collectionView.x = -_collectionView.width;
        _restoreButton.x = -_restoreButton.width;
        _blurImageView.x = -_blurImageView.width;
        _okButton.x = -_okButton.width;
        _contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}
@end
