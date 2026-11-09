# CollectionViewClassifyMenu


## 功能展示
![Example screenshot](https://github.com/ChenYilong/CollectionViewClassifyMenu/blob/master/CollectionViewClassifyMenu用法展示.gif)

## 单选可折叠菜单的特性展示
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


## Demo中具有两种样式


第一种是CollectionView做的两级菜单，可以折叠第二级菜单

第二种是侧边栏菜单，具有多选功能。示例应用保存筛选条件；组件本身不读取或持久化业务数据。

以下 NSCoding 用法是旧版本的历史说明；当前示例使用 `NSUserDefaults`，由宿主处理选择结果。旧版本若要关闭持久化，可在 AppDelegate 里清除固化数据。
 
 
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

## CocoaPods

The component supports iOS 15.0 and later. Until a versioned release is
published, add the current branch to your Podfile:

```ruby
pod 'CollectionViewClassifyMenu', :git => 'https://github.com/ChenYilong/CollectionViewClassifyMenu.git', :branch => 'master'
```

The pod contains the reusable menus, XIBs and images, but **not** demo data.
The existing copyright notices continue to apply.

两个示例分别通过本地 Pod 引用同一个组件：

```sh
pod install
open CollectionViewClassifyMenu.xcworkspace

cd TagCollectionView
pod install
open TagCollectionView.xcworkspace
```

### Interface-oriented usage / 面向接口使用

Implement `CYLMenuDataSource` in the host and retain it for as long as the
menu is in use. The component holds the data source and delegate weakly.
The host provides section and item titles, optional image and exclusive-item
flags, handles selections, and decides whether and how to persist them.

```objc
@import CollectionViewClassifyMenu;

// self implements CYLMenuDataSource and CYLMenuDelegate.
CYLClassifyMenuViewController *menu = [[CYLClassifyMenuViewController alloc] init];
menu.menuDataSource = self;
menu.menuDelegate = self;
menu.defaultVisibleRows = 2;  // Default: 1.
// Present or embed menu as a child view controller.
```

The required data source methods are `numberOfSectionsInMenu`,
`menuNumberOfItemsInSection:`, `menuTitleForSection:` and
`menuTitleForItemAtIndexPath:`. Set an optional `menuHeaderView` before loading
the view. After changing host data, call `reloadMenuData`. The filter
controller uses the same protocols; `selectedIndexPaths` and
`setSelectedIndexPaths:` allow the host to save and restore selections.
`reloadMenuData` resets filter selections to each section's first exclusive
item, if one is supplied.

`CYLTagView` also accepts the same protocols and supports both `[[CYLTagView alloc]
initWithFrame:]` and `+[CYLTagView tagView]`. See the
two demo controllers for complete implementations.

### Naming migration / 命名迁移

This naming change is **source and runtime incompatible** with the old names.
Update imports, type references, custom XIB/storyboard classes, and any
`NSClassFromString` calls when integrating the new version:

| Old name | New name |
| --- | --- |
| `CollectionViewCell` | `CYLCollectionViewCell` |
| `FilterBaseController`, `FilterCollectionCell` | `CYLFilterBaseController`, `CYLFilterCollectionCell` |
| `UICollectionViewLeftAlignedLayout` | `CYLCollectionViewLeftAlignedLayout` |
| `TagView`, `TagGroup`, `TagModel` | `CYLTagView`, `CYLTagGroup`, `CYLTagModel` |
| `HeaderCell`, `TagCell` | `CYLTagHeaderCell`, `CYLTagCell` |
| `FilterControllerDelegate`, `FilterHeaderViewDelegate`, `HeaderCellDelegate` | `CYLFilterControllerDelegate`, `CYLFilterHeaderViewDelegate`, `CYLTagHeaderCellDelegate` |
| `+[TagView TagView]` | `+[CYLTagView tagView]` |
| `filterControllerDidCompleted:` | `filterControllerDidComplete:` |
| `filterHeaderViewMoreBtnClicked:`, `moreBtnClicked:` | `filterHeaderViewDidTapMoreButton:`, `moreButtonTapped:` |
| `headerViewDidClickedNameView:index:` | `headerViewDidTapNameView:index:` |
| `cyl_setBoarderWith:color:` | `cyl_setBorderWidth:color:` |

Category headers use names such as `UIView+CYLGeneral.h`; category methods use
the `cyl_` prefix. `NSArray` and `NSDictionary` no longer override the system
`descriptionWithLocale:` for logging; call `cyl_descriptionWithLocale:`
explicitly when the old custom format is desired.

### Button layout without deprecated insets / 按钮布局

iOS 15 deprecates `titleEdgeInsets`, `imageEdgeInsets` and
`adjustsImageWhenHighlighted`. The component no longer uses them:
`CYLIndexPathButton` offers `cyl_imageTitleSpacing` and
`cyl_titleLeadingInset`, and `CYLRightImageButton` places its image after the
title by overriding the content rects. Image helpers use
`UIGraphicsImageRenderer`. If you set edge insets on these buttons yourself,
use the new properties instead.

### Release / 发布

```sh
scripts/pod-lint.sh lib
scripts/pod-lint.sh version
scripts/pod-lint.sh bump 0.1.1  # Commit the updated podspec first.
scripts/pod-lint.sh check-tag 0.1.1
# Create and push a matching Git tag, then explicitly:
scripts/pod-lint.sh push
```

The push command requires a matching tag on `origin` and an authenticated
CocoaPods trunk account. It is not run automatically. The `0.1.0` podspec
does not imply that a CocoaPods release or Git tag already exists.

设计分析与未覆盖场景见 `docs/component-architecture.md`；issue 进度见
`docs/issue-progress.md`。
