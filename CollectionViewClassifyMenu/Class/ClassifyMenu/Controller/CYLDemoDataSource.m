#import "CYLDemoDataSource.h"
#import "CYLDBManager.h"
#import "CYLMenuResources.h"

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
    source.sections = @[
        @{@"Type": @"地区过滤", kDataSourceSectionKey: @[
            @{kDataSourceCellTextKey: @"全部"},
            @{kDataSourceCellTextKey: @"北京 🏙️ 扩展文字"}
        ]},
        @{@"Type": @"菜品过滤", kDataSourceSectionKey: foods}
    ];
    source.hasExclusiveFirstItem = YES;
    return source;
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
