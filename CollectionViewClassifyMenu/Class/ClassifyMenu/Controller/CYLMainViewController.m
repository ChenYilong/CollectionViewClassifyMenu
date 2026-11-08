//
//  CYLMainViewController.m
//  CollectionViewClassifyMenu
//
//  Created by https://github.com/ChenYilong on 15/4/26.
//  Copyright (c)  http://weibo.com/luohanchenyilong/ . All rights reserved.
//

//View Controllers
#import "CYLMultipleFilterController.h"
#import "CYLMainViewController.h"
//Others
#import "CYLDemoDataSource.h"
#import "CYLMenuResources.h"
@import CollectionViewClassifyMenu;

@interface CYLMainViewController ()<CYLFilterControllerDelegate, CYLMenuDelegate>

@property (nonatomic, strong) CYLMultipleFilterController *filterController;
@property (nonatomic, strong) CYLDemoDataSource *classifySource;
@property (nonatomic, strong) CYLDemoDataSource *filterSource;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *rowsCountBydefaultSwitch;

@end

@implementation CYLMainViewController

#pragma mark - 💤 LazyLoad Method

/**
 *  懒加载filterController / Lazily create the filter controller.
 *
 *  @return filterController
 */
- (CYLMultipleFilterController *)filterController {
    if (_filterController == nil) {
        _filterController = [[CYLMultipleFilterController alloc] init];
        _filterController.delegate = self;
        _filterController.menuDataSource = self.filterSource;
        _filterController.menuDelegate = self;
        [_filterController loadViewIfNeeded];
        NSArray *stored = [[NSUserDefaults standardUserDefaults] arrayForKey:@"CYLDemoFilterSelection"];
        if (!stored) {
            stored = [self legacyFilterSelection];
        }
        if (stored) {
            NSArray<NSIndexPath *> *paths = [self cyl_validatedSelection:stored];
            if (paths) {
                [_filterController setSelectedIndexPaths:paths];
            } else {
                NSLog(@"Cannot restore demo filter settings: invalid selection.");
            }
        }
    }
    return _filterController;
}

- (NSArray *)legacyFilterSelection {
    NSString *filename = [[[CYLFilterParamsTool alloc] init] filename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        return nil;
    }
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:filename options:0 error:&error];
    NSArray *result = data ? [self cyl_selectionFromLegacyArchiveData:data] : nil;
    if (!data) {
        NSLog(@"Cannot read existing demo filter settings: %@", error);
    }
    if (result) {
        [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"CYLDemoFilterSelection"];
    }
    return result;
}

- (NSArray *)cyl_selectionFromLegacyArchiveData:(NSData *)data {
    NSError *error = nil;
    id archive = nil;
    @try {
        archive = [NSKeyedUnarchiver unarchiveTopLevelObjectWithData:data error:&error];
    } @catch (NSException *exception) {
        NSLog(@"Cannot decode existing demo filter settings: %@", exception);
        return nil;
    }
    if (![archive isKindOfClass:[CYLFilterParamsTool class]]) {
        NSLog(@"Cannot migrate existing demo filter settings: %@", error ?: @"unexpected archive type");
        return nil;
    }
    NSMutableArray *result = [NSMutableArray array];
    NSArray *sections = ((CYLFilterParamsTool *)archive).filterParamsArray;
    if (![sections isKindOfClass:[NSArray class]] || sections.count != [self.filterSource numberOfSectionsInMenu]) {
        NSLog(@"Cannot migrate existing demo filter settings: section count changed.");
        return nil;
    }
    for (NSUInteger section = 0; section < sections.count; section++) {
        NSArray *states = sections[section];
        if (![states isKindOfClass:[NSArray class]] ||
            states.count != [self.filterSource menuNumberOfItemsInSection:section]) {
            NSLog(@"Cannot migrate existing demo filter settings: item count changed in section %lu.", (unsigned long)section);
            return nil;
        }
        for (NSUInteger item = 0; item < states.count; item++) {
            if (![states[item] isKindOfClass:[NSNumber class]]) {
                NSLog(@"Cannot migrate existing demo filter settings: invalid item state.");
                return nil;
            }
            if ([states[item] boolValue]) {
                [result addObject:@[@(section), @(item)]];
            }
        }
    }
    if (![self cyl_validatedSelection:result]) {
        NSLog(@"Cannot migrate existing demo filter settings: conflicting selection.");
        return nil;
    }
    return result;
}

- (NSArray<NSIndexPath *> *)cyl_validatedSelection:(NSArray *)stored {
    NSMutableArray *paths = [NSMutableArray array];
    NSMutableIndexSet *exclusiveSections = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *otherSections = [NSMutableIndexSet indexSet];
    for (id pair in stored) {
        if (![pair isKindOfClass:[NSArray class]] || [pair count] != 2 ||
            ![pair[0] isKindOfClass:[NSNumber class]] || ![pair[1] isKindOfClass:[NSNumber class]]) {
            return nil;
        }
        NSInteger section = [pair[0] integerValue], item = [pair[1] integerValue];
        if (section < 0 || item < 0 || section >= [self.filterSource numberOfSectionsInMenu] ||
            item >= [self.filterSource menuNumberOfItemsInSection:section]) {
            return nil;
        }
        NSIndexPath *path = [NSIndexPath indexPathForItem:item inSection:section];
        BOOL exclusive = [self.filterSource menuItemIsExclusiveAtIndexPath:path];
        if ((exclusive && ([exclusiveSections containsIndex:section] || [otherSections containsIndex:section])) ||
            (!exclusive && [exclusiveSections containsIndex:section])) {
            return nil;
        }
        [(exclusive ? exclusiveSections : otherSections) addIndex:section];
        [paths addObject:path];
    }
    return paths;
}

#pragma mark - ♻️ LifeCycle Method

- (void)viewDidLoad {
    self.classifySource = [CYLDemoDataSource classifyDataSource];
    self.filterSource = [CYLDemoDataSource filterDataSource];
    self.menuDataSource = self.classifySource;
    self.menuDelegate = self;
    self.menuHeaderView = [self makeDemoHeaderView];
    [super viewDidLoad];
    [self initLeftBarButtonItem];
    [self initWithRightNavItem];
}

- (UIView *)makeDemoHeaderView {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 90)];
    header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    header.backgroundColor = [UIColor whiteColor];
    UILabel *title = [[UILabel alloc] init];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.adjustsFontSizeToFitWidth = YES;
    title.minimumScaleFactor = 0.7;
    title.font = [UIFont boldSystemFontOfSize:18];
    title.textColor = [UIColor colorWithRed:42 / 255.0 green:185 / 255.0 blue:160 / 255.0 alpha:1];
    self.titleLabel = title;
    [header addSubview:title];

    UISwitch *toggle = [[UISwitch alloc] init];
    toggle.translatesAutoresizingMaskIntoConstraints = NO;
    [toggle addTarget:self action:@selector(rowsCountBydefaultSwitchClicked:) forControlEvents:UIControlEventValueChanged];
    self.rowsCountBydefaultSwitch = toggle;
    [header addSubview:toggle];

    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.translatesAutoresizingMaskIntoConstraints = NO;
    subtitle.adjustsFontSizeToFitWidth = YES;
    subtitle.minimumScaleFactor = 0.7;
    subtitle.font = [UIFont systemFontOfSize:12];
    subtitle.textColor = [UIColor grayColor];
    subtitle.text = @"超出默认行数,出现\"更多\"按钮,点击展开.@iOS程序犭袁 出品";
    [header addSubview:subtitle];
    [NSLayoutConstraint activateConstraints:@[
        [title.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:16],
        [title.centerYAnchor constraintEqualToAnchor:toggle.centerYAnchor],
        [title.trailingAnchor constraintLessThanOrEqualToAnchor:toggle.leadingAnchor constant:-8],
        [toggle.trailingAnchor constraintEqualToAnchor:header.trailingAnchor constant:-16],
        [toggle.topAnchor constraintEqualToAnchor:header.topAnchor constant:20],
        [subtitle.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
        [subtitle.trailingAnchor constraintEqualToAnchor:header.trailingAnchor constant:-16],
        [subtitle.topAnchor constraintEqualToAnchor:toggle.bottomAnchor constant:8]
    ]];
    [self rowsCountBydefaultSwitchClicked:toggle];
    return header;
}

- (void)rowsCountBydefaultSwitchClicked:(UISwitch *)sender {
    self.defaultVisibleRows = sender.isOn ? 2 : 1;
    NSString *title = sender.isOn ? @"默认显示两行时的效果如下所示:" : @"默认显示一行时的效果如下所示:";
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:title];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(4, 2)];
    self.titleLabel.attributedText = text;
}

- (void)initWithRightNavItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClicked:)];
    item.title = @"重置筛选条件";
    self.navigationItem.rightBarButtonItem = item;
}

/**
 * 初始化leftNavgationItem / Initialize the left navigation item.
 */
- (void)initLeftBarButtonItem {
    BOOL shouldShowModified = NO;
    for (NSIndexPath *path in self.filterController.selectedIndexPaths) {
        if (path.item != 0) {
            shouldShowModified = YES;
            break;
        }
    }
    UIImage *image;
    if (shouldShowModified) {
        image =
        [[CYLMenuResources
          imageNamed:@"navigationbar_leftBarButtonItem_itis_multiple_choice_filter_params_modified"]
         imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
        image =
        [[CYLMenuResources
          imageNamed:@"navigationbar_leftBarButtonItem_itis_multiple_choice_filter_params_normal"]
         imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(leftBarButtonClicked:)];
    self.navigationItem.leftBarButtonItem = item;
}

#pragma mark - 🎬 Actions Method

- (void)rightBarButtonClicked:(id)sender {
    [self.filterController reloadMenuData];
    [self menu:self.filterController didConfirmSelectedItems:self.filterController.selectedIndexPaths];
    [self initLeftBarButtonItem];
    [self filterControllerDidComplete:nil];
}

- (void)leftBarButtonClicked:(id)sender {
    [self.filterController refreshFilterParams];
    [self.filterController showInView:self.navigationController.view ?: self.view];
}

#pragma mark - 🔌 CYLFilterControllerDelegate Method

- (void)filterControllerDidComplete:(CYLFilterBaseController *)controller {
    [self initLeftBarButtonItem];
}

- (void)menu:(id)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (menu == self) {
        NSString *title = [self.classifySource menuTitleForItemAtIndexPath:indexPath];
        self.navigationItem.title = title;
    }
}

- (void)menu:(id)menu didConfirmSelectedItems:(NSArray<NSIndexPath *> *)indexPaths {
    NSMutableArray *stored = [NSMutableArray array];
    for (NSIndexPath *path in indexPaths) {
        [stored addObject:@[@(path.section), @(path.item)]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:stored forKey:@"CYLDemoFilterSelection"];
}

@end
