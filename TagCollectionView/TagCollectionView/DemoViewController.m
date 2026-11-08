//
//  DemoViewController.m
//  TagCollectionView
//
//  Created by ak on 16/3/9.
//  Copyright © 2016年 (year 2016) AK. All rights reserved.
//

#import "DemoViewController.h"

#import "TagView.h"
@interface DemoViewController () <CYLMenuDataSource, CYLMenuDelegate>
@property(nonatomic,weak)TagView * tagV;
@property(nonatomic,copy)NSArray<NSArray<NSString *> *> *sections;
@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    TagView * tagV=[TagView TagView];
    
    [self.view addSubview:tagV];
    
    tagV.frame=CGRectMake(0, 20, 320,200);//self.view.bounds;
    
    self.tagV=tagV;
    
    
    self.sections = @[
        @[@"约炮", @"吃饭", @"睡觉", @"哈", @"对对对", @"睡觉asdfsfasfds", @"asdfdsfdsf睡觉", @"睡sdfdsf觉"],
        @[@"吃饭", @"睡觉", @"对对对", @"睡觉asdfsfasfds", @"asdfdsfdsf睡觉", @"睡sdfdsf觉", @"约炮", @"打豆豆", @"练武功"]
    ];
    self.tagV.menuDataSource = self;
    self.tagV.menuDelegate = self;
    [self.tagV reloadMenuData];
    
    
    
}

- (NSInteger)numberOfSectionsInMenu {
    return self.sections.count;
}

- (NSInteger)menuNumberOfItemsInSection:(NSInteger)section {
    return self.sections[section].count;
}

- (NSString *)menuTitleForSection:(NSInteger)section {
    return section == 0 ? @"dddd打游戏了" : @"打游戏了";
}

- (NSString *)menuTitleForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.sections[indexPath.section][indexPath.item] stringByAppendingString:@" 扩展文字😀✨"];
}

- (void)menu:(id)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", [self menuTitleForItemAtIndexPath:indexPath]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
