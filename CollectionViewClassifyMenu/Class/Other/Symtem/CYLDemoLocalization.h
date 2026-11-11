//
//  CYLDemoLocalization.h
//  CollectionViewClassifyMenu
//
//  The lookup of the demo app of CollectionViewClassifyMenu.xcodeproj (not part of the pod):
//  its strings live in CYLClassifyMenuDemo.bundle (<language>.lproj/Localizable.strings), keyed by
//  the Chinese source text, never in the core's CYLClassifyMenuResources.bundle. The language follows
//  the core's (CYLMenuResources.currentLanguage), so the demo and the component always agree.
//

#import <Foundation/Foundation.h>
#if __has_include(<CollectionViewClassifyMenu/CYLMenuResources.h>)
#import <CollectionViewClassifyMenu/CYLMenuResources.h>
#else
#import "CYLMenuResources.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// The demo app's string for `key` in the current language, from CYLClassifyMenuDemo.bundle.
static inline NSString *CYLDemoLocalizedStringFromBundle(NSString *key) {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"CYLClassifyMenuDemo" withExtension:@"bundle"];
        bundle = url ? [NSBundle bundleWithURL:url] : nil;
    });
    for (NSString *language in @[[CYLMenuResources currentLanguage], @"en"]) {
        NSString *path = [bundle pathForResource:language ofType:@"lproj"];
        if (path) {
            return [[NSBundle bundleWithPath:path] localizedStringForKey:key value:key table:nil];
        }
    }
    return key;
}

/// Use this macro for every user-facing string of the demo app (as CYLMenuLocalizedString does for
/// the core bundle and CYLExampleLocalizedString for Example/CYLMenuExample).
#define CYLDemoLocalizedString(...) CYLDemoLocalizedStringFromBundle(__VA_ARGS__)

NS_ASSUME_NONNULL_END
