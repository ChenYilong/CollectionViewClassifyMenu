//
//  CYLDBManager.swift
//  CollectionViewClassifyMenu
//
//  The demo data (data.json in the main bundle): sections of { "Type", "Items": [{ "Item_Title", "Picture"? }] }.
//  Shared by the demo app of CollectionViewClassifyMenu.xcodeproj and the Swift Example (Example/CYLMenuExample),
//  which compiles this file from here.
//

import Foundation
import CollectionViewClassifyMenu

enum CYLDBManager {

    private static let loadedDataSource: [[String: Any]] = {
        guard let url = Bundle.main.url(forResource: "data.json", withExtension: nil),
              let data = try? Data(contentsOf: url),
              let sections = (try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]] else {
            return []
        }
        return sections
    }()

    private static let loadedTags: [String] = loadedDataSource.flatMap { section -> [String] in
        let items = section[kDataSourceSectionKey] as? [[String: Any]] ?? []
        return items.compactMap { $0[kDataSourceCellTextKey] as? String }
    }

    /// The sections of data.json, read once.
    static func dataSource() -> [[String: Any]] {
        loadedDataSource
    }

    /// Every item title of every section, in order.
    static func allTags() -> [String] {
        loadedTags
    }
}
