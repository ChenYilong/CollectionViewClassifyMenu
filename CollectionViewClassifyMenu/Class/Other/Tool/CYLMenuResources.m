#import "CYLMenuResources.h"

@implementation CYLMenuResources

+ (NSBundle *)bundle {
    NSBundle *containingBundle = [NSBundle bundleForClass:self];
    NSURL *url = [containingBundle URLForResource:@"CYLClassifyMenuResources" withExtension:@"bundle"];
    if (!url) {
        url = [[NSBundle mainBundle] URLForResource:@"CYLClassifyMenuResources" withExtension:@"bundle"];
    }
    NSBundle *bundle = url ? [NSBundle bundleWithURL:url] : nil;
    if (!bundle) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"CYLClassifyMenuResources.bundle is missing. Install the component's CocoaPods resources."];
    }
    return bundle;
}

+ (UIImage *)imageNamed:(NSString *)name {
    return [UIImage imageNamed:name inBundle:self.bundle compatibleWithTraitCollection:nil];
}

@end
