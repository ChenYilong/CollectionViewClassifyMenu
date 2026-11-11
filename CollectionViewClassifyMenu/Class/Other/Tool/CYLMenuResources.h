//
//  CYLMenuResources.h
//  CollectionViewClassifyMenu
//
//  The component's single resource bundle, CYLClassifyMenuResources.bundle:
//  images, XIBs and the localized strings (<language>.lproj/CYLClassifyMenu.strings).
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * The core's lookups (one per kind of resource), always through CYLClassifyMenuResources.bundle: callers never
 * name the bundle. Examples have their own lookups over their own bundles (AGENTS.md, localization).
 * Looks up a key in the component's string table, in the component's language.
 */
#define CYLMenuLocalizedString(key, comment) [CYLMenuResources localizedStringForKey:(key)]
/// An image of the component's bundle (e.g. @"cyl_tag_plus").
#define CYLMenuImage(name) [CYLMenuResources imageNamed:(name)]

/*!
 * CYLMenuLocalizedString for Swift, which cannot call function-like macros: `CYLMenuLocalizedString("CYLMenuExpand")`.
 * Declared like CYLTabBarController's CYLLocalizedString().
 * The Swift name is a string literal (not NS_SWIFT_NAME), so the CYLMenuLocalizedString macro is not expanded in it.
 */
FOUNDATION_EXTERN NSString *CYLMenuLocalizedStringForKey(NSString *key) __attribute__((swift_name("CYLMenuLocalizedString(_:)")));

@interface CYLMenuResources : NSObject

+ (NSBundle *)bundle;
+ (nullable UIImage *)imageNamed:(NSString *)name;

/// Languages the bundle has strings for, e.g. @[@"en", @"zh-Hans", @"zh-Hant"].
+ (NSArray<NSString *> *)availableLanguages;

/*!
 * Language of the component's strings. nil (the default) follows the user's
 * preferred languages, even when the host app does not declare them; set it to
 * switch languages inside the app. Views created afterwards use the new language.
 */
@property (class, nonatomic, copy, nullable) NSString *preferredLanguage;

/*!
 * The language used now: preferredLanguage when available, else the best match
 * for the user's preferred languages, else English.
 */
+ (NSString *)currentLanguage;

/*!
 * The string for `key` in the current language; English, then the key itself,
 * when it is missing.
 */
+ (NSString *)localizedStringForKey:(NSString *)key;

/// The string for `key` in `language`, for hosts that show several languages.
+ (NSString *)localizedStringForKey:(NSString *)key language:(NSString *)language;

@end

NS_ASSUME_NONNULL_END
