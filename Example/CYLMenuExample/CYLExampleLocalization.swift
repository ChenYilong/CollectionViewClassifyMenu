//
//  CYLExampleLocalization.swift
//  CYLMenuExample
//
//  The Example's strings live in one bundle, CYLMenuExample.bundle
//  (<language>.lproj/Localizable.strings), keyed by the Chinese source text. The
//  language follows the component's: CYLMenuResources.preferredLanguage, else the
//  user's preferred languages. Every user-facing string of the Example goes through
//  CYLExampleLocalizedString (as CYLMenuLocalizedString does for the core bundle).
//

import Foundation
import CollectionViewClassifyMenu

enum CYLExampleLocalization {
    /// CYLMenuExample.bundle, nil when it is missing from the app.
    static let resourceBundle: Bundle? = Bundle.main.url(forResource: "CYLMenuExample", withExtension: "bundle")
        .flatMap(Bundle.init(url:))

    /// The .lproj of the current language: the component's preferredLanguage, else the user's languages.
    static var stringsBundle: Bundle? {
        guard let bundle = resourceBundle else { return nil }
        let preferences = CYLMenuResources.preferredLanguage.map { [$0] } ?? Locale.preferredLanguages
        guard let language = Bundle.preferredLocalizations(from: bundle.localizations, forPreferences: preferences).first,
              let path = bundle.path(forResource: language, ofType: "lproj") else { return nil }
        return Bundle(path: path)
    }
}

/// The Example's string for `key` (its Chinese source text) in the current language, from
/// CYLMenuExample.bundle; `arguments` fill its format specifiers. A key missing from a language is
/// its Chinese source text.
func CYLExampleLocalizedString(_ key: String, _ arguments: CVarArg...) -> String {
    let format = CYLExampleLocalization.stringsBundle?.localizedString(forKey: key, value: key, table: nil) ?? key
    return arguments.isEmpty ? format : String(format: format, arguments: arguments)
}
