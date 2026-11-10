//
//  CYLMenuResources.m
//  CollectionViewClassifyMenu
//

#import "CYLMenuResources.h"

static NSString * const kCYLMenuStringsTable = @"CYLClassifyMenu";
static NSString * const kCYLMenuFallbackLanguage = @"en";
static NSString *CYLMenuPreferredLanguage;

@implementation CYLMenuResources

+ (NSBundle *)bundle {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *containingBundle = [NSBundle bundleForClass:self];
        NSURL *url = [containingBundle URLForResource:@"CYLClassifyMenuResources" withExtension:@"bundle"];
        if (!url) {
            url = [[NSBundle mainBundle] URLForResource:@"CYLClassifyMenuResources" withExtension:@"bundle"];
        }
        bundle = url ? [NSBundle bundleWithURL:url] : nil;
    });
    if (!bundle) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"CYLClassifyMenuResources.bundle is missing. Install the component's CocoaPods resources."];
    }
    return bundle;
}

+ (UIImage *)imageNamed:(NSString *)name {
    return [UIImage imageNamed:name inBundle:self.bundle compatibleWithTraitCollection:nil];
}

#pragma mark Localization

+ (NSArray<NSString *> *)availableLanguages {
    NSMutableArray *languages = [NSMutableArray array];
    for (NSString *language in self.bundle.localizations) {
        if (![language isEqualToString:@"Base"]) {
            [languages addObject:language];
        }
    }
    return [languages sortedArrayUsingSelector:@selector(compare:)];
}

+ (NSString *)preferredLanguage {
    @synchronized (self) {
        return CYLMenuPreferredLanguage;
    }
}

+ (void)setPreferredLanguage:(NSString *)preferredLanguage {
    @synchronized (self) {
        CYLMenuPreferredLanguage = [preferredLanguage copy];
    }
}

+ (NSString *)currentLanguage {
    NSArray<NSString *> *available = [self availableLanguages];
    NSArray<NSString *> *preferences = self.preferredLanguage
        ? @[self.preferredLanguage]
        : [NSLocale preferredLanguages];
    // The bundle picks its own lproj, so the host app's declared localizations do not matter.
    NSString *match = [NSBundle preferredLocalizationsFromArray:available forPreferences:preferences].firstObject;
    if (match && [available containsObject:match]) {
        return match;
    }
    return kCYLMenuFallbackLanguage;
}

+ (NSBundle *)cyl_bundleForLanguage:(NSString *)language {
    NSString *path = [self.bundle pathForResource:language ofType:@"lproj"];
    return path ? [NSBundle bundleWithPath:path] : nil;
}

+ (NSString *)localizedStringForKey:(NSString *)key {
    return [self localizedStringForKey:key language:[self currentLanguage]];
}

+ (NSString *)localizedStringForKey:(NSString *)key language:(NSString *)language {
    static NSString * const kMissing = @"\u0001CYLMenuMissingString";
    for (NSString *candidate in @[language ?: kCYLMenuFallbackLanguage, kCYLMenuFallbackLanguage]) {
        NSBundle *bundle = [self cyl_bundleForLanguage:candidate];
        NSString *value = [bundle localizedStringForKey:key value:kMissing table:kCYLMenuStringsTable];
        if (value.length > 0 && ![value isEqualToString:kMissing]) {
            return value;
        }
    }
    return key;
}

@end
