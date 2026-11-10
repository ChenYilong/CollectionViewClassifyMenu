//
//  CYLExampleAppDelegate.m
//  CYLMenuExample
//

#import "CYLExampleAppDelegate.h"
#import "CYLExampleListViewController.h"

@implementation CYLExampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    CYLExampleListViewController *list = [[CYLExampleListViewController alloc] initWithStyle:UITableViewStyleInsetGrouped];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:list];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
