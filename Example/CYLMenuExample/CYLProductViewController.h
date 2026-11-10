//
//  CYLProductViewController.h
//  CYLMenuExample
//
//  场景一（商品页）：只展示两行评价关键词的预览，点击进入评价页。
//

#import <UIKit/UIKit.h>
@import CollectionViewClassifyMenu;

NS_ASSUME_NONNULL_BEGIN

@interface CYLProductViewController : UIViewController
@property (nonatomic, strong, readonly) CYLTagListView *previewView;
/// Pushes the review page with the given filter selected.
- (void)showReviewsWithFilterIndex:(NSUInteger)index;
@end

NS_ASSUME_NONNULL_END
