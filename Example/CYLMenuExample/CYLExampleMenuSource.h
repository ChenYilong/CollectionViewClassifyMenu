//
//  CYLExampleMenuSource.h
//  CYLMenuExample
//
//  A host-owned CYLMenuDataSource built from plain arrays. Everything the menu
//  shows comes from here; the core library holds no business data.
//

#import <UIKit/UIKit.h>
@import CollectionViewClassifyMenu;

NS_ASSUME_NONNULL_BEGIN

@interface CYLExampleMenuItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) UIImage *selectedImage;
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
@property (nonatomic, assign, getter=isExclusive) BOOL exclusive;
/// Free-form value for the host, such as a filter key.
@property (nonatomic, strong, nullable) id value;
+ (instancetype)itemWithTitle:(NSString *)title;
@end

@interface CYLExampleMenuSection : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) UIView *accessoryView;
@property (nonatomic, copy) NSArray<CYLExampleMenuItem *> *items;
+ (instancetype)sectionWithTitle:(NSString *)title items:(NSArray<CYLExampleMenuItem *> *)items;
/// Convenience: one plain item per title.
+ (instancetype)sectionWithTitle:(NSString *)title titles:(NSArray<NSString *> *)titles;
@end

@interface CYLExampleMenuSource : NSObject <CYLMenuDataSource>
@property (nonatomic, copy) NSArray<CYLExampleMenuSection *> *sections;
+ (instancetype)sourceWithSections:(NSArray<CYLExampleMenuSection *> *)sections;
- (CYLExampleMenuItem *)itemAtIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
