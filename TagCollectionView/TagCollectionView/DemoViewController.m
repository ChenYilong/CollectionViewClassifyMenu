//
//  DemoViewController.m
//  TagCollectionView
//
//  Created by ak on 16/3/9.
//  Copyright © 2016年 AK. All rights reserved.
//

#import "DemoViewController.h"

#import "TagView.h"
@interface DemoViewController ()
@property(nonatomic,weak)TagView * tagV;
@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    TagView * tagV=[TagView TagView];
    
    [self.view addSubview:tagV];
    
    tagV.frame=CGRectMake(0, 20, 320,200);//self.view.bounds;
    
    self.tagV=tagV;
    
    
        NSMutableArray *groupArray = [NSMutableArray array];
        
        
        TagModel *m1 =[TagModel modelWithTitle:@"对对对"];
        
        TagModel *m2 =[TagModel modelWithTitle:@"吃饭"];
        
        TagModel *m3 =[TagModel modelWithTitle:@"睡觉"];
        
        TagModel *m4=[TagModel modelWithTitle:@"睡觉asdfsfasfds"];
        
        TagModel *m5 =[TagModel modelWithTitle:@"asdfdsfdsf睡觉"];
        
        TagModel *m6 =[TagModel modelWithTitle:@"睡sdfdsf觉"];
        
        TagModel *m7 =[TagModel modelWithTitle:@"约炮"];
        
        TagModel *m8 =[TagModel modelWithTitle:@"哈"];
        
        TagModel *m9 =[TagModel modelWithTitle:@"练武功"];
        
        TagModel *m10 =[TagModel modelWithTitle:@"打豆豆"];

        for (TagModel *model in @[m1, m2, m3, m4, m5, m6, m7, m8, m9, m10]) {
            model.title = [model.title stringByAppendingString:@" 扩展文字😀✨"];
        }
        
        TagGroup *g1=[[TagGroup alloc]init];
        
        g1.itemArr=@[m7,m2,m3,m8,m1,m4,m5,m6];
        
        g1.groupName=@"dddd打游戏了";
        
        [groupArray addObject:g1];
        
        
        TagGroup *g2=[[TagGroup alloc]init];
        
        g2.groupName=@"打游戏了";
        
        g2.itemArr=@[m2,m3,m1,m4,m5,m6,m7,m10,m9];
        
        [groupArray addObject:g2];
    
    
    self.tagV.groups=groupArray; //默认数据 当有请求时候刷新数据
    
    
    
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
