//
//  CYLExampleListViewController.h
//  CYLMenuExample
//
//  Lists the README scenarios implemented with the core library.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYLExampleListViewController : UITableViewController
/// View controller for a row, without presenting it.
- (UIViewController *)viewControllerForRow:(NSInteger)row;
@end

NS_ASSUME_NONNULL_END
