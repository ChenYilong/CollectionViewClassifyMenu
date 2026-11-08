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
#import "CYLMenuResources.h"

@interface FilterBaseController ()<UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UIImageView *blurImageView;

@end

@implementation FilterBaseController

- (instancetype)init {
    return [super initWithNibName:@"FilterBaseController" bundle:[CYLMenuResources bundle]];
}

#pragma mark - ♻️ LifeCycle Method

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [UIScreen mainScreen].bounds;
    CGColorRef color = [UIColor lightGrayColor].CGColor;
    _restoreButton.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, ([UIScreen mainScreen].bounds.size.width - 50) / 2, 44);
    _okButton.frame = CGRectMake(_restoreButton.cyl_width, [UIScreen mainScreen].bounds.size.height - 44, [UIScreen mainScreen].bounds.size.width - 50 - _restoreButton.cyl_width, 44);
    [_restoreButton cyl_addSubLayerWithFrame:CGRectMake(0, 0, _restoreButton.frame.size.width, 0.5f) color:color];
    [_okButton cyl_addSubLayerWithFrame:CGRectMake(0, 0, _okButton.frame.size.width, 0.5f) color:color];
    [_okButton cyl_addSubLayerWithFrame:CGRectMake(0, 0, 0.5f, 44) color:color];
    _contentView.backgroundColor = [UIColor blackColor];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.delegate = self;
    UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc] init];
    _collectionView.collectionViewLayout = layout;
    _collectionView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    [_collectionView registerClass:[FilterCollectionCell class] forCellWithReuseIdentifier:@"FilterCollectionCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"CYLMultipleFilterHeaderView" bundle:[CYLMenuResources bundle]]
      forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
             withReuseIdentifier:@"CYLMultipleFilterHeaderView"];
    [_contentView cyl_setTarget:self action:@selector(hide)];
}

#pragma mark - 🔌 UICollectionViewDelegateFlowLayout Method

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, 38);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kCollectionViewToTopMargin, kCollectionViewToLeftMargin, kCollectionViewToBottomtMargin, kCollectionViewToRightMargin);
}

#pragma mark - 🎬 Actions Method

- (void)itemButtonClicked:(CYLIndexPathButton *)button {
    
}

- (void)changeXOfSubviewsInCollectionViewWhenShow {
    [_collectionView cyl_setX:-_collectionView.cyl_width];
    [_restoreButton cyl_setX:-_restoreButton.cyl_width];
    [_blurImageView cyl_setX:-_blurImageView.cyl_width];
    [_okButton cyl_setX:-_okButton.cyl_width];
}

- (void)changeXOfSubviewsInCollectionViewWhenHide {
    [_collectionView cyl_setX:0];
    [_restoreButton cyl_setX:0];
    [_blurImageView cyl_setX:0];
    [_okButton cyl_setX:_restoreButton.cyl_width];
}

- (IBAction)confirmButtonClicked:(id)sender {
    [UIView animateWithDuration:0.3f animations:^{
        [self changeXOfSubviewsInCollectionViewWhenShow];
        _contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        if (_delegate && [_delegate respondsToSelector:@selector(filterControllerDidCompleted:)]) {
            [_delegate filterControllerDidCompleted:self];
        }
    }];
}

- (IBAction)restoreButtonClicked:(id)sender {
    [self confirmButtonClicked:nil];
}

- (void)showInView:(UIView *)view {
    // 屏幕截图 / Capture the host view.
    UIImage *screen = [view cyl_capture];
    // 生成高斯模糊背景 / Generate a Gaussian-blurred background.
    UIImage *blur = [screen cyl_blurredImageWithRadius:25.0f iterations:10 tintColor:nil];
    [view addSubview:self.view];
    _blurImageView.image = blur;
    [self changeXOfSubviewsInCollectionViewWhenShow];
    _contentView.alpha = 0;
    [UIView animateWithDuration:0.3f animations:^{
        [self changeXOfSubviewsInCollectionViewWhenHide];
        _contentView.alpha = 0.35f;
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.3f animations:^{
        [self changeXOfSubviewsInCollectionViewWhenShow];
        _contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

@end
