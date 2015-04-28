//
//  FilterBaseController.m
//  http://cnblogs.com/ChenYilong/ 
//
//  Created by  https://github.com/ChenYilong  on 14-5-12.
//  Copyright (c)  http://weibo.com/luohanchenyilong/  . All rights reserved.
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
    _collectionView.showsVerticalScrollIndicator = NO;
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
