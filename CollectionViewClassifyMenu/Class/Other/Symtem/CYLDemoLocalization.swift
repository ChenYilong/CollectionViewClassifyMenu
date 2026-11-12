//
//  CYLDemoLocalization.swift
//  CollectionViewClassifyMenu
//
//  The lookup of the demo app of CollectionViewClassifyMenu.xcodeproj (not part of the pod): its strings live in
//  CYLClassifyMenuDemo.bundle (<language>.lproj/Localizable.strings), keyed by the Chinese source text, never in
//  the core's CYLClassifyMenuResources.bundle. The language follows the core's (CYLMenuResources.currentLanguage()),
//  so the demo and the component always agree. Use it for every user-facing string of the demo app, as
//  CYLMenuLocalizedString does for the core bundle.
//

import Foundation
import CollectionViewClassifyMenu

enum CYLDemoLocalization {
    /// CYLClassifyMenuDemo.bundle, nil when the app does not contain it.
    static let bundle: Bundle? = Bundle.main.url(forResource: "CYLClassifyMenuDemo", withExtension: "bundle").flatMap(Bundle.init(url:))

    /// The .lproj of the current language, else English.
    static var languageBundle: Bundle? {
        for language in [CYLMenuResources.currentLanguage(), "en"] {
            if let path = bundle?.path(forResource: language, ofType: "lproj"), let lproj = Bundle(path: path) {
                return lproj
            }
        }
        return nil
    }
}

/// The demo app's string for `key` in the current language, from CYLClassifyMenuDemo.bundle; `arguments` fill its
/// format specifiers.
func CYLDemoLocalizedString(_ key: String, _ arguments: CVarArg...) -> String {
    let format = CYLDemoLocalization.languageBundle?.localizedString(forKey: key, value: key, table: nil) ?? key
    return arguments.isEmpty ? format : String(format: format, arguments: arguments)
}
