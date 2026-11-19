//
//  CYLDemoDataSource.swift
//  CollectionViewClassifyMenu
//
//  The menu data of the demos: the classify menu (data.json) and the multiple-choice filter (regions and
//  dishes, each with an exclusive "全部" first). Shared by the demo app of CollectionViewClassifyMenu.xcodeproj
//  and the Swift Example (Example/CYLMenuExample), which compiles this file from here. data.json and the places
//  database keep the Simplified Chinese source titles (shared with every platform, and the queries match them); the
//  menus show them in the app's language through `localize`, the lookup of the module that compiles this file.
//

import UIKit
import CollectionViewClassifyMenu

final class CYLDemoDataSource: NSObject, CYLMenuDataSource {

    /// The key of a section's title in `sections`.
    static let sectionTitleKey = "Type"

    private(set) var sections: [[String: Any]] = []
    private(set) var hasExclusiveFirstItem = false
    /// The lookup of the module showing the menu (CYLDemoLocalizedString, CYLExampleLocalizedString); keys are the
    /// source titles.
    private(set) var localize: (String) -> String = { $0 }

    static func classifyDataSource(localize: @escaping (String) -> String = { $0 }) -> CYLDemoDataSource {
        let source = CYLDemoDataSource()
        source.localize = localize
        source.sections = CYLDBManager.dataSource()
        return source
    }

    static func filterDataSource(localize: @escaping (String) -> String = { $0 }) -> CYLDemoDataSource {
        let source = CYLDemoDataSource()
        source.localize = localize
        let all: [String: Any] = [kDataSourceCellTextKey: "全部"]
        let foods = [all] + CYLDBManager.allTags().map { [kDataSourceCellTextKey: $0] as [String: Any] }
        let regions = [all] + Self.regions().map { [kDataSourceCellTextKey: $0] as [String: Any] }
        source.sections = [
            [sectionTitleKey: "地区过滤", kDataSourceSectionKey: regions],
            [sectionTitleKey: "菜品过滤", kDataSourceSectionKey: foods],
        ]
        source.hasExclusiveFirstItem = true
        return source
    }

    static func regions() -> [String] {
        ["北京 🏙️ 扩展文字", "上海", "广州", "深圳"]  // NOLOCALIZE: source titles (the database matches them)
    }

    /// The title without the long sample suffix ("北京 🏙️ 扩展文字" → "北京").
    static func shortTitle(forTitle title: String) -> String {
        for suffix in [" 扩展文字😀✨", " 🏙️ 扩展文字"] where title.hasSuffix(suffix) {  // NOLOCALIZE: source suffixes
            return String(title.dropLast(suffix.count))
        }
        return title
    }

    /// The sample suffix of the long titles ("川菜 扩展文字😀✨"), a word of its own in the tables.
    static let sampleSuffixWord = "扩展文字"

    /// A source title in the app's language: the name and the sample suffix each looked up ("川菜 扩展文字😀✨" →
    /// "Sichuan extended text😀✨").
    func localizedTitle(_ title: String) -> String {
        let short = Self.shortTitle(forTitle: title)
        guard short != title else {
            return localize(title)
        }
        let suffix = String(title.dropFirst(short.count))
        return localize(short) + suffix.replacingOccurrences(of: Self.sampleSuffixWord, with: localize(Self.sampleSuffixWord))
    }

    /// A source title without the sample suffix, in the app's language ("北京 🏙️ 扩展文字" → "Beijing").
    func localizedShortTitle(_ title: String) -> String {
        localize(Self.shortTitle(forTitle: title))
    }

    /// The source title of an item, as data.json and the places database hold it (for queries).
    func sourceTitle(at indexPath: IndexPath) -> String {
        items(inSection: indexPath.section)[indexPath.item][kDataSourceCellTextKey] as? String ?? ""
    }

    private func items(inSection section: Int) -> [[String: Any]] {
        sections[section][kDataSourceSectionKey] as? [[String: Any]] ?? []
    }

    // MARK: CYLMenuDataSource

    func numberOfSectionsInMenu() -> Int {
        sections.count
    }

    func menuNumberOfItems(inSection section: Int) -> Int {
        items(inSection: section).count
    }

    func menuTitle(forSection section: Int) -> String {
        localize(sections[section][Self.sectionTitleKey] as? String ?? "")
    }

    func menuTitleForItem(at indexPath: IndexPath) -> String {
        localizedTitle(sourceTitle(at: indexPath))
    }

    func menuImageForItem(at indexPath: IndexPath) -> UIImage? {
        let hasImage = items(inSection: indexPath.section)[indexPath.item][kDataSourceCellPictureKey] != nil
        return hasImage ? CYLMenuResources.image(named: "home_btn_shrink") : nil
    }

    func menuImage(forSection section: Int) -> UIImage? {
        hasExclusiveFirstItem ? nil : CYLMenuResources.image(named: "home_btn_cosmetic")
    }

    func menuItemIsExclusive(at indexPath: IndexPath) -> Bool {
        hasExclusiveFirstItem && indexPath.item == 0
    }
}
