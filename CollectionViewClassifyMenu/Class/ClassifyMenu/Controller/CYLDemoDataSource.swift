//
//  CYLDemoDataSource.swift
//  CollectionViewClassifyMenu
//
//  The menu data of the demos: the classify menu (data.json) and the multiple-choice filter (regions and
//  dishes, each with an exclusive "全部" first). Shared by the demo app of CollectionViewClassifyMenu.xcodeproj
//  and the Swift Example (Example/CYLMenuExample), which compiles this file from here. Its titles are sample
//  data, as data.json's (AGENTS.md, localization exceptions).
//

import UIKit
import CollectionViewClassifyMenu

final class CYLDemoDataSource: NSObject, CYLMenuDataSource {

    /// The key of a section's title in `sections`.
    static let sectionTitleKey = "Type"

    private(set) var sections: [[String: Any]] = []
    private(set) var hasExclusiveFirstItem = false

    static func classifyDataSource() -> CYLDemoDataSource {
        let source = CYLDemoDataSource()
        source.sections = CYLDBManager.dataSource()
        return source
    }

    static func filterDataSource() -> CYLDemoDataSource {
        let source = CYLDemoDataSource()
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
        ["北京 🏙️ 扩展文字", "上海", "广州", "深圳"]
    }

    /// The title without the long sample suffix ("北京 🏙️ 扩展文字" → "北京").
    static func shortTitle(forTitle title: String) -> String {
        for suffix in [" 扩展文字😀✨", " 🏙️ 扩展文字"] where title.hasSuffix(suffix) {
            return String(title.dropLast(suffix.count))
        }
        return title
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
        sections[section][Self.sectionTitleKey] as? String ?? ""
    }

    func menuTitleForItem(at indexPath: IndexPath) -> String {
        items(inSection: indexPath.section)[indexPath.item][kDataSourceCellTextKey] as? String ?? ""
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
