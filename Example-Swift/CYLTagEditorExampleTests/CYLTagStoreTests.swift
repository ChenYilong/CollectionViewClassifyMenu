//
//  CYLTagStoreTests.swift
//  CYLTagEditorExampleTests
//
//  The tag model: CYLTagStore (search, create, recent tags) and CYLTagData (tags.json per language).
//

import XCTest
import CollectionViewClassifyMenu
@testable import CYLTagEditorExample

final class CYLTagStoreTests: CYLTagEditorTestCase {

    func testStoreSearchesAndCreatesTags() {
        let store = CYLTagStore(tags: ["iOS 开发", "上海同事", "同事", "Swift 读书会", "iOS 开发"], recentTags: ["同事", "missing"])
        XCTAssertEqual(store.tags, ["iOS 开发", "上海同事", "同事", "Swift 读书会"], "Duplicates removed")
        XCTAssertEqual(store.recentTags, ["同事"], "Unknown recent tags dropped")
        XCTAssertEqual(store.tags(matching: "ios"), ["iOS 开发"], "Case-insensitive")
        XCTAssertEqual(store.tags(matching: "同事"), ["同事", "上海同事"], "Tags starting with the text first")
        XCTAssertEqual(store.tags(matching: "  "), [])
        XCTAssertTrue(store.canCreate("ios"), "Only an exact name exists already, as in the chat app")
        XCTAssertFalse(store.canCreate("iOS 开发"))
        XCTAssertFalse(store.canCreate("   "))
        XCTAssertEqual(store.createTag(named: "  ios "), "ios")
        XCTAssertEqual(store.tags.last, "ios")
        XCTAssertEqual(store.createTag(named: "ios"), "ios", "An existing tag is returned")
        XCTAssertEqual(store.tags.filter { $0 == "ios" }.count, 1)
        XCTAssertNil(store.createTag(named: ""))
        store.markUsed(["ios", "iOS 开发"])
        XCTAssertEqual(store.recentTags, ["ios", "iOS 开发", "同事"])
        store.deleteTag("iOS 开发")
        XCTAssertEqual(store.recentTags, ["ios", "同事"])
        XCTAssertFalse(store.contains("iOS 开发"))
    }

    func testDemoTagsAreLoadedFromTheJSONFileOfTheLanguage() throws {
        var loaded: [String: CYLTagData] = [:]
        for language in ["zh-Hans", "zh-Hant", "en"] {
            CYLTagEditorLocalization.preferredLanguage = language
            let data = try CYLTagData.bundled()
            XCTAssertEqual(data.version, 1)
            XCTAssertGreaterThan(data.tags.count, 30, language)
            XCTAssertEqual(Set(data.tags).count, data.tags.count, "No duplicates in \(language)")
            XCTAssertTrue(Set(data.recentTags).isSubset(of: data.tags), language)
            XCTAssertTrue(Set(data.selectedTags).isSubset(of: data.tags), language)
            XCTAssertFalse(CYLTagStore(data: data).tags(matching: "ios").isEmpty, "\"ios\" finds a tag in \(language) (search screenshot)")
            loaded[language] = data
        }
        XCTAssertEqual(loaded["zh-Hans"]?.tags.first, "家人")
        XCTAssertEqual(loaded["zh-Hant"]?.tags[4], "大學同學")
        XCTAssertEqual(loaded["en"]?.tags.first, "Family")
        XCTAssertEqual(loaded["en"]?.selectedTags, ["Family", "College Classmates", "Book Club"])
        XCTAssertEqual(Set(loaded.values.map { $0.tags.count }).count, 1, "The same tags in every language")

        // The app's store is made from the file of its language.
        CYLTagEditorLocalization.preferredLanguage = "en"
        XCTAssertEqual(CYLTagStore.bundled().tags, loaded["en"]?.tags)
        XCTAssertEqual(CYLTagStore.bundled().recentTags, loaded["en"]?.recentTags)
    }

    func testTagDataParsingErrors() {
        XCTAssertThrowsError(try CYLTagData.decode(Data("{\"tags\": 1}".utf8)))
        XCTAssertThrowsError(try CYLTagData.bundled(bundle: Bundle(for: CYLTagStoreTests.self))) { error in
            guard case CYLTagData.LoadingError.fileNotFound = error else {
                return XCTFail("\(error)")
            }
        }
        let json = #"{"version": 1, "tags": ["家人", "朋友"], "recentTags": ["朋友"], "selectedTags": [], "comment": "ignored"}"#
        XCTAssertEqual(try CYLTagData.decode(Data(json.utf8)).tags, ["家人", "朋友"])
    }
}
