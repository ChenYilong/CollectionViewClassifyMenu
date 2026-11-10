//
//  CYLExampleLocalization.m
//  CYLMenuExample
//

#import "CYLExampleLocalization.h"
@import CollectionViewClassifyMenu;

NSString *CYLExampleLocalizedString(NSString *key) {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"CYLMenuExample" withExtension:@"bundle"];
        bundle = url ? [NSBundle bundleWithURL:url] : nil;
    });
    if (!bundle) {
        return key;
    }
    NSString *preferred = CYLMenuResources.preferredLanguage;
    NSArray<NSString *> *preferences = preferred ? @[preferred] : [NSLocale preferredLanguages];
    NSString *language = [NSBundle preferredLocalizationsFromArray:bundle.localizations forPreferences:preferences].firstObject;
    NSString *path = language ? [bundle pathForResource:language ofType:@"lproj"] : nil;
    NSBundle *strings = path ? [NSBundle bundleWithPath:path] : nil;
    // A key missing from a language is its Chinese source text.
    return [strings localizedStringForKey:key value:key table:nil] ?: key;
}
