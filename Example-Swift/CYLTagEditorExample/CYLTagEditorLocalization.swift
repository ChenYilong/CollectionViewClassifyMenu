//
//  CYLTagEditorLocalization.swift
//  CYLTagEditorExample
//
//  The Example's strings live in CYLTagEditorExample.bundle (one .lproj per language); every
//  lookup goes through CYLTagEditorLocalizedString, never NSLocalizedString. Keys are the
//  Simplified Chinese text.
//

import Foundation
import CollectionViewClassifyMenu

enum CYLTagEditorLocalization {
    /// The language of the Example and of the component (e.g. "en"), as an in-app setting would
    /// choose; nil follows the system.
    static var preferredLanguage: String? {
        didSet {
            CYLMenuResources.preferredLanguage = preferredLanguage
            cachedBundle = nil
        }
    }

    private static var cachedBundle: Bundle?

    static var resourceBundle: Bundle {
        if let bundle = cachedBundle {
            return bundle
        }
        let base = Bundle.main.url(forResource: "CYLTagEditorExample", withExtension: "bundle").flatMap(Bundle.init(url:)) ?? .main
        let available = base.localizations
        let preferred = preferredLanguage.map { [$0] } ?? Locale.preferredLanguages
        let language = Bundle.preferredLocalizations(from: available, forPreferences: preferred).first ?? "zh-Hans"
        let bundle = base.path(forResource: language, ofType: "lproj").flatMap(Bundle.init(path:)) ?? base
        cachedBundle = bundle
        return bundle
    }
}

/// A string of CYLTagEditorExample.bundle; `arguments` fill its format specifiers.
func CYLTagEditorLocalizedString(_ key: String, _ arguments: CVarArg...) -> String {
    let format = CYLTagEditorLocalization.resourceBundle.localizedString(forKey: key, value: key, table: nil)
    return arguments.isEmpty ? format : String(format: format, arguments: arguments)
}
