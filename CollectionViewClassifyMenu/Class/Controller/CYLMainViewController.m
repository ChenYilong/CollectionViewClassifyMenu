

//
//  CYLMainViewController.m
//  CollectionViewClassifyMenu
//
//  Created by https://github.com/ChenYilong on 15/4/26.
//  Copyright (c)  http://weibo.com/luohanchenyilong/ . All rights reserved.
//


#import <UIKit/UIKit.h>
@implementation UIImage (YPGeneral)
+ (UIImage *)imageWithColor:(UIColor *)color
{
    return [UIImage imageWithColor:color size:CGSizeMake(1, 1)];
}
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end


#define udDoctorFilterSettingModified @"udDoctorFilterSettingModified"

#import "CYLMainViewController.h"
#import "DoctorFilterController.h"
#import "AppDelegate.h"
#import "CYLFilterParamsTool.h"


@interface CYLMainViewController ()<FilterControllerDelegate>
@property (nonatomic, strong) DoctorFilterController *filterController;
@property (nonatomic, strong) CYLFilterParamsTool *filterParamsTool;

@end

@implementation CYLMainViewController

/**
 *  懒加载filterController
 *
 *  @return filterController
 */
- (DoctorFilterController *)filterController
{
    if (_filterController == nil) {
        _filterController = [[DoctorFilterController alloc] initWithNibName:@"FilterBaseController" bundle:nil];
        _filterController.delegate = self;
    }
    return _filterController;
}
/**
 *  懒加载_filterParamsTool
 *
 *  @return CYLFilterParamsTool
 */
- (CYLFilterParamsTool *)filterParamsTool
{
    if (_filterParamsTool == nil) {
        _filterParamsTool = [[CYLFilterParamsTool alloc] init];
        _filterParamsTool = [NSKeyedUnarchiver unarchiveObjectWithFile:self.filterParamsTool.filename];
    }
    return _filterParamsTool;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:18], NSForegroundColorAttributeName : [UIColor whiteColor]}];
     [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:(51)/255.f green:(171)/255.f blue:(160)/255.f alpha:1.f]] forBarMetrics:UIBarMetricsDefault];
    [self initLeftBarButtonItem];
    [self initWithRightNavItem];
    
}
- (void)initWithRightNavItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClicked:)];
    item.title = @"重置筛选条件";
    self.navigationItem.rightBarButtonItem = item;
}

- (void)rightBarButtonClicked:(id)sender {
    self.filterParamsTool = [[CYLFilterParamsTool alloc] init];
    [NSKeyedArchiver archiveRootObject:self.filterParamsTool toFile:self.filterParamsTool.filename];
    [self initLeftBarButtonItem];
    [self filterControllerDidCompleted:nil];
}

/**
 * 初始化leftNavgationItem
 */
- (void)initLeftBarButtonItem
{
    self.filterParamsTool = nil;
    BOOL shouldShowModified = [self.filterParamsTool.filterParamsDictionary[udDoctorFilterSettingModified] boolValue];
    UIImage *image;
    if (shouldShowModified) {
        image =
        [[UIImage
          imageNamed:@"navigationbar_leftBarButtonItem_itis_multiple_choice_filter_params_modified"]
         imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
        image =
        [[UIImage
          imageNamed:@"navigationbar_leftBarButtonItem_itis_multiple_choice_filter_params_normal"]
         imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(leftBarButtonClicked:)];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)leftBarButtonClicked:(id)sender
{
    [_filterController refreshFilterParams];
    AppDelegate *delegate= (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.filterController showInView:delegate.navigationController.view];
}

#pragma mark - FilterControllerDelegate
- (void)filterControllerDidCompleted:(FilterBaseController *)controller
{
    self.filterParamsTool = nil;
    [self initLeftBarButtonItem];
    self.filterParamsTool = nil;
    NSString *message =  @"展示全部";
    NSString *areaMessage = @"🔵不筛选地区";
    NSString *foodMessage = @"🔴不筛选食物";
    NSString *area = self.filterParamsTool.filterParamsContentDictionary[@"Hospital"];
    id dicValue = area;
    if((dicValue) && (dicValue != [NSNull null])) {
        areaMessage = [NSString stringWithFormat:@"🔵筛选地区:%@",area];;
    }
    NSMutableArray *messageArray = self.filterParamsTool.filterParamsContentDictionary[@"skilled"];
    if(self.filterParamsTool.filterParamsContentDictionary[@"skilled"] && self.filterParamsTool.filterParamsContentDictionary[@"skilled"] != [NSNull null]) {
        __weak __typeof(messageArray) weakMessageArray = messageArray;
        [messageArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            obj =  [@"🔴" stringByAppendingString:obj];
            [weakMessageArray replaceObjectAtIndex:idx withObject:obj];
        }];
        NSString *skilled = [messageArray componentsJoinedByString:@"\n"];
        if (skilled.length >0) {
            foodMessage = skilled;
        }
    }
    message = [NSString stringWithFormat:@"%@\n%@",areaMessage,foodMessage];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    NSUInteger delaySeconds = 1;
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySeconds * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    });
}
@end
