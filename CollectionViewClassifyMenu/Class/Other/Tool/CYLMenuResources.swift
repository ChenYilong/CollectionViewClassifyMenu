//
//  CYLMenuResources.swift
//  CollectionViewClassifyMenu
//
//  The component's single resource bundle, CYLClassifyMenuResources.bundle: images, XIBs and the localized strings
//  (<language>.lproj/CYLClassifyMenu.strings).
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md). Swift has no macros: the core's lookup is the
//  function `CYLMenuLocalizedString(_:)`, as each example has its own lookup function over its own bundle (AGENTS.md,
//  localization). The Objective-C selectors stay for the core's Objective-C tests.
//

import UIKit

/**
 * Looks up a key in the component's string table, in the component's language (`CYLMenuResources.currentLanguage`):
 * the core's lookup, always through CYLClassifyMenuResources.bundle.
 */
public func CYLMenuLocalizedString(_ key: String) -> String {
    CYLMenuResources.localizedString(forKey: key)
}

/**
 * The core's resource lookups (one per kind of resource), always through CYLClassifyMenuResources.bundle: callers
 * never name the bundle.
 */
@objc(CYLMenuResources)
public final class CYLMenuResources: NSObject {

    private static let bundleName = "CYLClassifyMenuResources"
    private static let stringsTable = "CYLClassifyMenu"
    private static let fallbackLanguage = "en"
    private static let missingString = "__CYLMenuMissingString__"
    private static let lock = NSLock()
    private static var storedPreferredLanguage: String?

    /**
     * The bundle, next to the component's code (CocoaPods resources) or in the main bundle.
     */
    @objc public static let bundle: Bundle = {
        let containing = Bundle(for: CYLMenuResources.self)
        let url = containing.url(forResource: bundleName, withExtension: "bundle")
            ?? Bundle.main.url(forResource: bundleName, withExtension: "bundle")
        guard let url, let bundle = Bundle(url: url) else {
            preconditionFailure("CYLClassifyMenuResources.bundle is missing. Install the component's CocoaPods resources.")
        }
        return bundle
    }()

    private override init() {
        super.init()
    }

    /**
     * An image of the component's bundle (e.g. "cyl_tag_plus").
     */
    @objc(imageNamed:)
    public static func image(named name: String) -> UIImage? {
        UIImage(named: name, in: bundle, compatibleWith: nil)
    }

    // MARK: - Localization

    /**
     * Languages the bundle has strings for, e.g. ["en", "zh-Hans", "zh-Hant"].
     */
    @objc public static var availableLanguages: [String] {
        bundle.localizations.filter { $0 != "Base" }.sorted()
    }

    /**
     * Language of the component's strings. `nil` (the default) follows the user's preferred languages, even when the
     * host app does not declare them; set it to switch languages inside the app. Views created afterwards use the new
     * language.
     */
    @objc public static var preferredLanguage: String? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return storedPreferredLanguage
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            storedPreferredLanguage = newValue
        }
    }

    /**
     * The language used now: `preferredLanguage` when available, else the best match for the user's preferred
     * languages, else English.
     */
    @objc public static var currentLanguage: String {
        let available = availableLanguages
        let preferences = preferredLanguage.map { [$0] } ?? Locale.preferredLanguages
        // The bundle picks its own lproj, so the host app's declared localizations do not matter.
        if let match = Bundle.preferredLocalizations(from: available, forPreferences: preferences).first,
           available.contains(match) {
            return match
        }
        return fallbackLanguage
    }

    /**
     * The string for `key` in the current language; English, then the key itself, when it is missing.
     */
    @objc(localizedStringForKey:)
    public static func localizedString(forKey key: String) -> String {
        localizedString(forKey: key, language: currentLanguage)
    }

    /**
     * The string for `key` in `language`, for hosts that show several languages; English, then the key itself, when
     * it is missing.
     */
    @objc(localizedStringForKey:language:)
    public static func localizedString(forKey key: String, language: String) -> String {
        for candidate in [language, fallbackLanguage] {
            guard let path = bundle.path(forResource: candidate, ofType: "lproj"), let strings = Bundle(path: path) else {
                continue
            }
            let value = strings.localizedString(forKey: key, value: missingString, table: stringsTable)
            if !value.isEmpty && value != missingString {
                return value
            }
        }
        return key
    }
}
