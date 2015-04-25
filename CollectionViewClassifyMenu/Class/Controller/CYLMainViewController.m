

//
//  CYLMainViewController.m
//  CollectionViewClassifyMenu
//
//  Created by chenyilong on 15/4/26.
//  Copyright (c) 2015年 chenyilong. All rights reserved.
//
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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initLeftBarButtonItem];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLeftBarButtonItem];
    
}

/**
 * 初始化leftNavgationItem
 */
- (void)initLeftBarButtonItem
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    if([NSKeyedUnarchiver unarchiveObjectWithFile:self.filterParamsTool.filename]) {
        self.filterParamsTool = [NSKeyedUnarchiver unarchiveObjectWithFile:self.filterParamsTool.filename];
    }
    BOOL udDoctorFilterSettingModifiedBool = [self.filterParamsTool.filterParamsDictionary objectForKey:udDoctorFilterSettingModified];
    UIImage *image;
     if (udDoctorFilterSettingModifiedBool) {
         image = [UIImage imageNamed:@"icon_filter"];
     } else {
         image = [UIImage imageNamed:@"question_filter_setted"];
     }
    button.frame = CGRectMake(0, 0, 50, 44);
    [button setImage:image forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button addTarget:self action:@selector(leftBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.parentViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:self action:@selector(leftBarButtonClicked:)];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)leftBarButtonClicked:(id)sender
{
    if (self.filterController == nil) {
        self.filterController = [[DoctorFilterController alloc] initWithNibName:@"FilterBaseController" bundle:nil];
        _filterController.delegate = self;
    }
    [_filterController.collectionView reloadItemsAtIndexPaths:[_filterController.collectionView indexPathsForVisibleItems]];
    AppDelegate *delegate= (AppDelegate *)[UIApplication sharedApplication].delegate;
    [_filterController showInView:delegate.navigationController.view];
}
@end
