#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYLMenuResources : NSObject
+ (NSBundle *)bundle;
+ (nullable UIImage *)imageNamed:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
