# CollectionViewClassifyMenu


##功能展示
![Example screenshot](https://github.com/ChenYilong/CollectionViewClassifyMenu/blob/master/CollectionViewClassifyMenu用法展示.gif)

##单选可折叠菜单的特性展示
![Example screenshot](https://github.com/ChenYilong/CollectionViewClassifyMenu/blob/master/单选菜单的特性展示.gif)
                  
Check out [my weibo](http://weibo.com/luohanchenyilong/) for more info.


然并卵？
请看以下应用场景：

场景一：《手机淘宝App》


筛选条件，如果数目过多，可以折叠，：比如《手机淘宝App》中商品的评价筛选


![enter image description here](https://i.imgur.com/8AM2QTc.gif)

场景二：《脉脉App》


分类菜单：比如《脉脉App》中的搜索分类筛选


![enter image description here](https://i.imgur.com/ZyJflPh.gif)


##Demo中具有两种样式


第一种是CollectionView做的两级菜单，可以折叠第二级菜单

第二种是侧边栏菜单,具有多选功能,并可将数据持久化,在下次打开app后,保留用户的筛选条件.默认保存.

数据持久化使用NSCoding,若要关闭该项功能,可在AppDelegate里清除固化数据,
 
 
清除方法已经在工程中写出:
 
 
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

YES为保存,NO为不保存.
 
 
```Objective-C
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //...
    //设NO表示,每次启动程序,清除用户上次的筛选条件,不写该行,默认保存.
    [self initFilterSetting:NO];
    return YES;
}
```




Check out [my twitter](https://twitter.com/stevechen1010) for more info.
