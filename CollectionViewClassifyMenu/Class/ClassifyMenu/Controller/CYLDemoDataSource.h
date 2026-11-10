#import <Foundation/Foundation.h>
// The framework header in the Example (use_frameworks!), the local one in this app.
#if __has_include(<CollectionViewClassifyMenu/CYLMenuDataSource.h>)
#import <CollectionViewClassifyMenu/CYLMenuDataSource.h>
#else
#import "CYLMenuDataSource.h"
#endif

/// The demo data of the original app: the classify menu (data.json: 吃/喝/玩/逛 and their tags) and the
/// multiple-choice filter (地区过滤, 菜品过滤). Also used by the Example's database demo.
@interface CYLDemoDataSource : NSObject <CYLMenuDataSource>

+ (instancetype)classifyDataSource;
+ (instancetype)filterDataSource;
/// The regions of the filter's first section, after its exclusive "全部".
+ (NSArray<NSString *> *)regions;
/// A title without its demo suffix (" 扩展文字😀✨", " 🏙️ 扩展文字"), e.g. "川菜".
+ (NSString *)shortTitleForTitle:(NSString *)title;

@end
