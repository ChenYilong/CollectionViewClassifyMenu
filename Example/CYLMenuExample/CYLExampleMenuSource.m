//
//  CYLExampleMenuSource.m
//  CYLMenuExample
//

#import "CYLExampleMenuSource.h"

@implementation CYLExampleMenuItem

+ (instancetype)itemWithTitle:(NSString *)title {
    CYLExampleMenuItem *item = [[self alloc] init];
    item.title = title;
    item.enabled = YES;
    return item;
}

@end

@implementation CYLExampleMenuSection

+ (instancetype)sectionWithTitle:(NSString *)title items:(NSArray<CYLExampleMenuItem *> *)items {
    CYLExampleMenuSection *section = [[self alloc] init];
    section.title = title;
    section.items = items;
    return section;
}

+ (instancetype)sectionWithTitle:(NSString *)title titles:(NSArray<NSString *> *)titles {
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:titles.count];
    for (NSString *itemTitle in titles) {
        [items addObject:[CYLExampleMenuItem itemWithTitle:itemTitle]];
    }
    return [self sectionWithTitle:title items:items];
}

@end

@implementation CYLExampleMenuSource

+ (instancetype)sourceWithSections:(NSArray<CYLExampleMenuSection *> *)sections {
    CYLExampleMenuSource *source = [[self alloc] init];
    source.sections = sections;
    return source;
}

- (CYLExampleMenuItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
    return self.sections[indexPath.section].items[indexPath.item];
}

- (NSInteger)numberOfSectionsInMenu {
    return self.sections.count;
}

- (NSInteger)menuNumberOfItemsInSection:(NSInteger)section {
    return self.sections[section].items.count;
}

- (NSString *)menuTitleForSection:(NSInteger)section {
    return self.sections[section].title;
}

- (NSString *)menuTitleForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self itemAtIndexPath:indexPath].title;
}

- (UIImage *)menuImageForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self itemAtIndexPath:indexPath].image;
}

- (UIImage *)menuSelectedImageForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self itemAtIndexPath:indexPath].selectedImage;
}

- (UIImage *)menuImageForSection:(NSInteger)section {
    return self.sections[section].image;
}

- (UIView *)menuAccessoryViewForSection:(NSInteger)section {
    return self.sections[section].accessoryView;
}

- (BOOL)menuItemIsEnabledAtIndexPath:(NSIndexPath *)indexPath {
    return [self itemAtIndexPath:indexPath].isEnabled;
}

- (BOOL)menuItemIsExclusiveAtIndexPath:(NSIndexPath *)indexPath {
    return [self itemAtIndexPath:indexPath].isExclusive;
}

@end
