//
//  CYLFilterParamsTool.swift
//  CollectionViewClassifyMenu
//
//  The state of the multiple filter, as Android's `CYLFilterParamsTool` (CYLMultipleFilter.kt) keeps it: the titles
//  per section, one selected flag per item (the first item of each section selected by default), the settings
//  dictionary with its "modified" flag, free-form content, and the file the settings belong to. The Swift migration had
//  removed the Objective-C original; it is back for parity with Android (docs/android-ios-api.md).
//

import Foundation

/**
 * The key of the filter settings in `CYLFilterParamsTool.filterParamsDictionary`.
 */
public let kMultipleFilterSetting = "kMultipleFilterSetting"

/**
 * The key of the "modified" flag in `CYLFilterParamsTool.filterParamsDictionary`.
 */
public let kMultipleFilterSettingModified = "kMultipleFilterSettingModified"

/**
 * The state of the multiple filter (Android `CYLFilterParamsTool`): the titles per section (`dataSources`) and a
 * selected flag per item (`filterParamsArray`, the first item of each section selected by default). Every value is
 * made on first use and can be replaced.
 */
@objc(CYLFilterParamsTool)
open class CYLFilterParamsTool: NSObject {

    /**
     * The titles, one array per section.
     */
    @objc open var dataSources: [[String]] = []

    private var storedFilterParamsArray: [[Bool]]?

    /**
     * One selected flag per item; made from `dataSources` on first use, with the first item of each section selected.
     */
    @objc open var filterParamsArray: [[Bool]] {
        get {
            if let storedFilterParamsArray {
                return storedFilterParamsArray
            }
            let made = dataSources.map { section in section.indices.map { $0 == 0 } }
            storedFilterParamsArray = made
            return made
        }
        set {
            storedFilterParamsArray = newValue
        }
    }

    private var storedFilterParamsDictionary: [String: Any]?

    /**
     * The settings (`kMultipleFilterSetting`: `filterParamsArray`) and the modified flag
     * (`kMultipleFilterSettingModified`: false), made on first use.
     */
    @objc open var filterParamsDictionary: [String: Any] {
        get {
            if let storedFilterParamsDictionary {
                return storedFilterParamsDictionary
            }
            let made: [String: Any] = [kMultipleFilterSettingModified: false, kMultipleFilterSetting: filterParamsArray]
            storedFilterParamsDictionary = made
            return made
        }
        set {
            storedFilterParamsDictionary = newValue
        }
    }

    private var storedFilterParamsContentDictionary: [String: Any]?

    /**
     * Free-form content of the filter; `["skilled": []]` by default, as the original.
     */
    @objc open var filterParamsContentDictionary: [String: Any] {
        get {
            if let storedFilterParamsContentDictionary {
                return storedFilterParamsContentDictionary
            }
            let made: [String: Any] = ["skilled": [Any]()]
            storedFilterParamsContentDictionary = made
            return made
        }
        set {
            storedFilterParamsContentDictionary = newValue
        }
    }

    private var storedFilename: String?

    /**
     * Where the settings are saved: `kMultipleFilterSetting` in the app's documents folder (Android: its files
     * folder); set it to choose another file.
     */
    @objc open var filename: String {
        get {
            if let storedFilename {
                return storedFilename
            }
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documents?.appendingPathComponent(kMultipleFilterSetting).path ?? kMultipleFilterSetting
        }
        set {
            storedFilename = newValue
        }
    }
}
