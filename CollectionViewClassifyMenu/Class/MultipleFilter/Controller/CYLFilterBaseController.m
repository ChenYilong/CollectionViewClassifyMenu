//
//  CYLFilterBaseController.m
//  http://cnblogs.com/ChenYilong/
//
//  Created by  https://github.com/ChenYilong  on 14-5-12.
//  Copyright (c)  http://weibo.com/luohanchenyilong/  . All rights reserved.
//


#import "CYLFilterBaseController.h"
#import "UIImage+CYLBlur.h"
#import "UIView+CYLGeneral.h"
#import "CYLFilterParamsTool.h"
#import "CYLMenuResources.h"

@interface CYLFilterBaseController ()<UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UIImageView *blurImageView;
@property (nonatomic, strong) CALayer *restoreTopLine;
@property (nonatomic, strong) CALayer *okTopLine;
@property (nonatomic, strong) CALayer *okLeadingLine;
/// YES while the side panel is on screen; controls the buttons' x positions.
@property (nonatomic, assign, getter=isPanelVisible) BOOL panelVisible;

@end

@implementation CYLFilterBaseController

- (instancetype)init {
    return [super initWithNibName:@"CYLFilterBaseController" bundle:[CYLMenuResources bundle]];
}

#pragma mark - ♻️ LifeCycle Method

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.panelVisible = YES;
    CGColorRef color = [UIColor lightGrayColor].CGColor;
    self.restoreTopLine = [_restoreButton cyl_addSubLayerWithFrame:CGRectZero color:color];
    self.okTopLine = [_okButton cyl_addSubLayerWithFrame:CGRectZero color:color];
    self.okLeadingLine = [_okButton cyl_addSubLayerWithFrame:CGRectZero color:color];
    _contentView.backgroundColor = [UIColor blackColor];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.delegate = self;
    CYLCollectionViewLeftAlignedLayout *layout = [[CYLCollectionViewLeftAlignedLayout alloc] init];
    _collectionView.collectionViewLayout = layout;
    _collectionView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    [_collectionView registerClass:[CYLFilterCollectionCell class] forCellWithReuseIdentifier:@"CYLFilterCollectionCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"CYLMultipleFilterHeaderView" bundle:[CYLMenuResources bundle]]
      forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
             withReuseIdentifier:@"CYLMultipleFilterHeaderView"];
    [_contentView cyl_setTarget:self action:@selector(hide)];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self cyl_layoutBottomButtons];
}

/// Sizes the bottom buttons from the panel's actual width rather than the screen.
- (void)cyl_layoutBottomButtons {
    CGFloat panelWidth = CGRectGetWidth(_collectionView.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat restoreWidth = floor(panelWidth / 2);
    CGFloat okWidth = MAX(0, panelWidth - restoreWidth);
    CGFloat restoreX = self.isPanelVisible ? 0 : -restoreWidth;
    CGFloat okX = self.isPanelVisible ? restoreWidth : -okWidth;
    _restoreButton.frame = CGRectMake(restoreX, height - 44, restoreWidth, 44);
    _okButton.frame = CGRectMake(okX, height - 44, okWidth, 44);
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.restoreTopLine.frame = CGRectMake(0, 0, restoreWidth, 0.5f);
    self.okTopLine.frame = CGRectMake(0, 0, okWidth, 0.5f);
    self.okLeadingLine.frame = CGRectMake(0, 0, 0.5f, 44);
    [CATransaction commit];
}

#pragma mark - 🔌 UICollectionViewDelegateFlowLayout Method

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), 38);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kCollectionViewToTopMargin, kCollectionViewToLeftMargin, kCollectionViewToBottomtMargin, kCollectionViewToRightMargin);
}

#pragma mark - 🎬 Actions Method

- (void)itemButtonClicked:(CYLIndexPathButton *)button {
    
}

- (void)changeXOfSubviewsInCollectionViewWhenShow {
    self.panelVisible = NO;
    [_collectionView cyl_setX:-_collectionView.cyl_width];
    [_restoreButton cyl_setX:-_restoreButton.cyl_width];
    [_blurImageView cyl_setX:-_blurImageView.cyl_width];
    [_okButton cyl_setX:-_okButton.cyl_width];
}

- (void)changeXOfSubviewsInCollectionViewWhenHide {
    self.panelVisible = YES;
    [_collectionView cyl_setX:0];
    [_restoreButton cyl_setX:0];
    [_blurImageView cyl_setX:0];
    [_okButton cyl_setX:_restoreButton.cyl_width];
}

- (IBAction)confirmButtonClicked:(id)sender {
    [UIView animateWithDuration:0.3f animations:^{
        [self changeXOfSubviewsInCollectionViewWhenShow];
        self.contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        id<CYLFilterControllerDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(filterControllerDidComplete:)]) {
            [delegate filterControllerDidComplete:self];
        }
    }];
}

- (IBAction)restoreButtonClicked:(id)sender {
    [self confirmButtonClicked:nil];
}

- (void)showInView:(UIView *)view {
    // 屏幕截图 / Capture the host view.
    self.view.frame = view.bounds;
    [self.view layoutIfNeeded];
    UIImage *screen = [view cyl_captureWithWidth:CGRectGetWidth(_collectionView.bounds)];
    // 生成高斯模糊背景 / Generate a Gaussian-blurred background.
    UIImage *blur = [screen cyl_blurredImageWithRadius:25.0f iterations:10 tintColor:nil];
    [view addSubview:self.view];
    _blurImageView.image = blur;
    [self changeXOfSubviewsInCollectionViewWhenShow];
    _contentView.alpha = 0;
    [UIView animateWithDuration:0.3f animations:^{
        [self changeXOfSubviewsInCollectionViewWhenHide];
        self.contentView.alpha = 0.35f;
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.3f animations:^{
        [self changeXOfSubviewsInCollectionViewWhenShow];
        self.contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

@end
