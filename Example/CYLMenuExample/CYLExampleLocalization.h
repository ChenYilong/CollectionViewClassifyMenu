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

/// The Example's string for `key` (its Chinese source text) in the current language.
FOUNDATION_EXTERN NSString *CYLExampleLocalizedString(NSString *key);

NS_ASSUME_NONNULL_END
