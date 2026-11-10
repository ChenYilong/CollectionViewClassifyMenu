//
//  CYLMenuResources.h
//  CollectionViewClassifyMenu
//
//  The component's single resource bundle, CYLClassifyMenuResources.bundle:
//  images, XIBs and the localized strings (<language>.lproj/CYLClassifyMenu.strings).
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Looks up a key in the component's string table, in the component's language.
#define CYLMenuLocalizedString(key, comment) [CYLMenuResources localizedStringForKey:(key)]

@interface CYLMenuResources : NSObject

+ (NSBundle *)bundle;
+ (nullable UIImage *)imageNamed:(NSString *)name;

/// Languages the bundle has strings for, e.g. @[@"en", @"zh-Hans", @"zh-Hant"].
+ (NSArray<NSString *> *)availableLanguages;

/// Language of the component's strings. nil (the default) follows the user's
/// preferred languages, even when the host app does not declare them; set it to
/// switch languages inside the app. Views created afterwards use the new language.
@property (class, nonatomic, copy, nullable) NSString *preferredLanguage;

/// The language used now: preferredLanguage when available, else the best match
/// for the user's preferred languages, else English.
+ (NSString *)currentLanguage;

/// The string for `key` in the current language; English, then the key itself,
/// when it is missing.
+ (NSString *)localizedStringForKey:(NSString *)key;

/// The string for `key` in `language`, for hosts that show several languages.
+ (NSString *)localizedStringForKey:(NSString *)key language:(NSString *)language;

@end

NS_ASSUME_NONNULL_END
