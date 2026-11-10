//
//  CYLExampleLocalization.h
//  CYLMenuExample
//
//  The Example's strings live in one bundle, CYLMenuExample.bundle
//  (<language>.lproj/Localizable.strings), keyed by the Chinese source text. The
//  language follows the component's: CYLMenuResources.preferredLanguage, else the
//  user's preferred languages.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// The Example's string for `key` (its Chinese source text) in the current language,
/// from CYLMenuExample.bundle.
FOUNDATION_EXTERN NSString *CYLExampleLocalizedStringFromBundle(NSString *key);

/// Use this macro, not the function, for every user-facing string: it maps a key to the
/// Example's bundle in one place (as CYLMenuLocalizedString does for the core bundle).
/// Variadic, so that a comma inside the key expression (an array literal) cannot split it.
#define CYLExampleLocalizedString(...) CYLExampleLocalizedStringFromBundle(__VA_ARGS__)

NS_ASSUME_NONNULL_END
