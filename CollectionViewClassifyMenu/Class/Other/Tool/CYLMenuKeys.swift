//
//  CYLMenuKeys.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import Foundation

/**
 * The key of a section's items in the dictionaries `CYLClassifyMenuViewController` builds from its data source.
 */
public let kDataSourceSectionKey: String = "Items"

/**
 * The key of an item's title in those dictionaries.
 */
public let kDataSourceCellTextKey: String = "Item_Title"

/**
 * The key of an item's picture (a `UIImage`, or a non-empty string for the bundled default) in those dictionaries.
 */
public let kDataSourceCellPictureKey: String = "Picture"

/**
 * The same keys for Objective-C, which cannot see Swift global constants: `CYLMenuKeys.dataSourceSectionKey` in
 * place of `kDataSourceSectionKey` (docs/Swift-Migration.md, "Objective-C API changes").
 */
@objc(CYLMenuKeys)
public final class CYLMenuKeys: NSObject {

    /**
     * `kDataSourceSectionKey`.
     */
    @objc public static let dataSourceSectionKey = kDataSourceSectionKey

    /**
     * `kDataSourceCellTextKey`.
     */
    @objc public static let dataSourceCellTextKey = kDataSourceCellTextKey

    /**
     * `kDataSourceCellPictureKey`.
     */
    @objc public static let dataSourceCellPictureKey = kDataSourceCellPictureKey

    private override init() {
        super.init()
    }
}
