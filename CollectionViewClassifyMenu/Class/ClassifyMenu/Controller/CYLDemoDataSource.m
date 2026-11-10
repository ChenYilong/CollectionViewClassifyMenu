#import "CYLDemoDataSource.h"
// Relative, so that it also builds in the Example, which compiles this file from here.
#import "../../Other/Tool/CYLDBManager.h"
#if __has_include(<CollectionViewClassifyMenu/CYLMenuResources.h>)
#import <CollectionViewClassifyMenu/CYLMenuResources.h>
#else
#import "CYLMenuResources.h"
#endif

@interface CYLDemoDataSource ()
@property (nonatomic, copy) NSArray<NSDictionary *> *sections;
@property (nonatomic, assign) BOOL hasExclusiveFirstItem;
@end

@implementation CYLDemoDataSource

+ (instancetype)classifyDataSource {
    CYLDemoDataSource *source = [[self alloc] init];
    source.sections = [CYLDBManager dataSource];
    return source;
}

+ (instancetype)filterDataSource {
    CYLDemoDataSource *source = [[self alloc] init];
    NSMutableArray *foods = [NSMutableArray arrayWithObject:@{kDataSourceCellTextKey: @"全部"}];
    for (NSString *title in [CYLDBManager allTags]) {
        [foods addObject:@{kDataSourceCellTextKey: title}];
    }
    NSMutableArray *regions = [NSMutableArray arrayWithObject:@{kDataSourceCellTextKey: @"全部"}];
    for (NSString *title in [self regions]) {
        [regions addObject:@{kDataSourceCellTextKey: title}];
    }
    source.sections = @[
        @{@"Type": @"地区过滤", kDataSourceSectionKey: regions},
        @{@"Type": @"菜品过滤", kDataSourceSectionKey: foods}
    ];
    source.hasExclusiveFirstItem = YES;
    return source;
}

+ (NSArray<NSString *> *)regions {
    return @[@"北京 🏙️ 扩展文字", @"上海", @"广州", @"深圳"];
}

+ (NSString *)shortTitleForTitle:(NSString *)title {
    for (NSString *suffix in @[@" 扩展文字😀✨", @" 🏙️ 扩展文字"]) {
        if ([title hasSuffix:suffix]) {
            return [title substringToIndex:title.length - suffix.length];
        }
    }
    return title;
}

- (NSInteger)numberOfSectionsInMenu {
    return self.sections.count;
}

- (NSInteger)menuNumberOfItemsInSection:(NSInteger)section {
    return [self.sections[section][kDataSourceSectionKey] count];
}

- (NSString *)menuTitleForSection:(NSInteger)section {
    return self.sections[section][@"Type"];
}

- (NSString *)menuTitleForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.sections[indexPath.section][kDataSourceSectionKey][indexPath.item][kDataSourceCellTextKey];
}

- (UIImage *)menuImageForItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL hasImage = self.sections[indexPath.section][kDataSourceSectionKey][indexPath.item][kDataSourceCellPictureKey] != nil;
    return hasImage ? [CYLMenuResources imageNamed:@"home_btn_shrink"] : nil;
}

- (UIImage *)menuImageForSection:(NSInteger)section {
    return self.hasExclusiveFirstItem ? nil : [CYLMenuResources imageNamed:@"home_btn_cosmetic"];
}

- (BOOL)menuItemIsExclusiveAtIndexPath:(NSIndexPath *)indexPath {
    return self.hasExclusiveFirstItem && indexPath.item == 0;
}

@end
