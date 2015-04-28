# CollectionViewClassifyMenu
CollectionView做的两级菜单，可以折叠第二级菜单
侧边栏菜单,具有多选功能,并可将数据持久化,在下次打开app后,保留用户的筛选条件.

若要关闭该项功能,可在AppDelegate里清除固化数据,
 
方法已经在工程中写出:
 
 
```Objective-C
- (void)initFilterSetting:(BOOL)restore
{
    if (!restore) {
        CYLFilterParamsTool *filterParamsTool = [[CYLFilterParamsTool alloc] init];
        [NSKeyedArchiver archiveRootObject:filterParamsTool toFile:filterParamsTool.filename];
    }
}
```

用法如下
 
 
```Objective-C
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //...
    [self initFilterSetting:YES];
    return YES;
}
```




##功能展示
![Example screenshot](https://github.com/ChenYilong/CollectionViewClassifyMenu/blob/master/CollectionViewClassifyMenu用法展示.gif)

##单选可折叠菜单的特性展示
![Example screenshot](https://github.com/ChenYilong/CollectionViewClassifyMenu/blob/master/单选菜单的特性展示.gif)
                  
Check out [my weibo](http://weibo.com/luohanchenyilong/) for more info.

Check out [my twitter](https://twitter.com/stevechen1010) for more info.
