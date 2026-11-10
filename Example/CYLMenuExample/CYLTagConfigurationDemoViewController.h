//
//  CYLTagConfigurationDemoViewController.h
//  CYLMenuExample
//
//  标签的两种初始化方式（参照 CYLTabBarController 的 -initWithConfiguration: 与
//  -initWithConfigurationFile:error:）：配置文件（JSON）与字典（map）。图标使用
//  CYLTabBarController 的动效引擎（Lottie、PAG、Rive、GIF）。
//

#import <UIKit/UIKit.h>
@import CollectionViewClassifyMenu;

NS_ASSUME_NONNULL_BEGIN

@interface CYLTagConfigurationDemoViewController : UIViewController
/// Created with +tagListViewWithConfigurationFile:error: from Configurations/animated-tags.json.
@property (nonatomic, strong, readonly, nullable) CYLTagListView *fileTagListView;
/// Created with -initWithConfiguration: from a dictionary.
@property (nonatomic, strong, readonly) CYLTagListView *mapTagListView;
@property (nonatomic, strong, readonly, nullable) NSError *configurationError;
/// Path of the configuration file in the app.
+ (NSString *)configurationFilePath;
/// The dictionary of the map example.
+ (NSDictionary<NSString *, id> *)mapConfiguration;
@end

NS_ASSUME_NONNULL_END
