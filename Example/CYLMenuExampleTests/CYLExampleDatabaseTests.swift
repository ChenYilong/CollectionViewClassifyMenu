//
//  CYLExampleDatabaseTests.swift
//  CYLMenuExampleTests
//
//  CYLExampleDatabase (SQLite): the demo data, bound values and transactions, database review filtering, and the
//  ported classify menu demo that queries it.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLExampleDatabaseTests: CYLMenuExampleTestCase {

    private func makeDatabase() throws -> CYLExampleDatabase {
        try CYLExampleDatabase(path: ":memory:")
    }

    func testExampleDatabaseHoldsTheDemoData() throws {
        let database = try makeDatabase()
        XCTAssertEqual(database.count(ofTable: "reviews"), CYLReviewStore.shared().reviews.count)
        XCTAssertGreaterThan(database.count(ofTable: "review_keywords"), 0)
        XCTAssertGreaterThan(database.count(ofTable: "places"), 40)
        // The rows are the shared database's (docs/cross-platform.md): the same on every platform.
        XCTAssertNotNil(CYLExampleDatabase.sharedDatabaseURL, "cyl_places.sqlite is bundled")
        XCTAssertEqual(database.count(ofTable: "places"), 83)
        let first = try database.rows(forSQL: "SELECT name, region, rating, price FROM places ORDER BY rating DESC, id LIMIT 1").first
        XCTAssertEqual(first?["name"] as? String, "日式拉面 · 北京")
        XCTAssertEqual((first?["price"] as? NSNumber)?.intValue, 93)
        let review = try database.rows(forSQL: "SELECT text FROM reviews WHERE id = 0").first
        XCTAssertEqual(review?["text"] as? String, CYLReviewStore.shared().reviews.first?.text, "The reviews of CYLReviewStore, in order")
        let counts = try database.rows(forSQL: "SELECT COUNT(DISTINCT tag) AS n, COUNT(DISTINCT region) AS r, COUNT(DISTINCT category) AS c FROM places").first
        XCTAssertEqual((counts?["c"] as? NSNumber)?.intValue, 4, "吃喝玩逛 of data.json")
        XCTAssertEqual((counts?["r"] as? NSNumber)?.intValue, 4, "The filter's regions")
        XCTAssertGreaterThan((counts?["n"] as? NSNumber)?.intValue ?? 0, 20, "Every tag of data.json")

        // Bound values, never formatted into the SQL; the display string shows them quoted.
        let row = try database.rows(forSQL: "SELECT ? AS text, ? AS number", arguments: ["it's", NSNumber(value: 2.5)]).first
        XCTAssertEqual(row?["text"] as? String, "it's")
        XCTAssertEqual((row?["number"] as? NSNumber)?.doubleValue ?? 0, 2.5, accuracy: 0.001)
        let query = CYLExampleSQLQuery(sql: "SELECT * FROM t WHERE a = ? AND b = ?", arguments: ["it's", NSNumber(value: 3)])
        XCTAssertEqual(query.displayString(), "SELECT * FROM t WHERE a = 'it''s' AND b = 3")
        XCTAssertThrowsError(try database.rows(forSQL: "SELECT * FROM missing")) { error in
            XCTAssertEqual((error as NSError).domain, CYLExampleDatabaseErrorDomain)
        }

        // A failed transaction leaves nothing behind.
        database.inTransaction { db in
            db.saveSelection([ip(1, 0)], forScenario: "test")
            return false
        }
        XCTAssertTrue(database.saveSelection([ip(3, 0), ip(2, 1)], forScenario: "test"))
        XCTAssertEqual(database.savedSelection(forScenario: "test"), [ip(3, 0), ip(2, 1)])
        XCTAssertNil(database.savedSelection(forScenario: "other"))
    }

    func testDatabaseReviewFilteringMatchesMemoryFiltering() throws {
        let store = CYLReviewStore.shared()
        let query = CYLDatabaseReviewQuery(database: try makeDatabase())
        XCTAssertEqual(query.mode, .database)
        let combinations: [[String]] = [[], ["good"], ["good", "photo"], ["followup"], ["neutral"], ["bad"],
                                        ["keyword:质量不错"], ["good", "keyword:质量不错", "keyword:划算"], ["photo", "followup"]]
        for identifiers in combinations {
            let filters = identifiers.map { store.filter(withIdentifier: $0)! }
            var fromDatabase: [CYLReview]?
            query.fetchReviewsMatching(filters) { reviews in fromDatabase = reviews }
            XCTAssertNotNil(fromDatabase, "Synchronous")
            XCTAssertEqual(fromDatabase, store.reviewsMatchingAll(filters), "\(identifiers)")
        }
        let sql = CYLDatabaseReviewQuery.query(for: [store.filter(withIdentifier: "good")!, store.filter(withIdentifier: "keyword:划算")!])
        XCTAssertTrue(sql.sql.contains("r.rating = ? AND EXISTS"), sql.sql)
        XCTAssertEqual(sql.arguments as NSArray, [NSNumber(value: CYLReviewRating.good.rawValue), "划算"] as NSArray)

        let controller = CYLReviewListViewController(selectedFilterIndex: 0, mode: .database)
        showInNavigation(controller)
        XCTAssertEqual(controller.modeControl.numberOfSegments, 3)
        controller.selectFilterIndexes([1, 4])
        XCTAssertEqual(controller.visibleReviews, store.reviewsMatchingAll(controller.selectedFilters))
        XCTAssertTrue(controller.statusLabel.text?.contains("SELECT r.id FROM reviews r WHERE") ?? false, controller.statusLabel.text ?? "")
        captureScreen(named: "test-database-review-filter")
    }

    func testPortedClassifyMenuDemoQueriesTheDatabase() throws {
        let database = try makeDatabase()
        let menu = CYLMenuLinkageViewController(database: database)
        showInNavigation(menu)
        menu.view.layoutIfNeeded()
        let places = database.count(ofTable: "places")
        XCTAssertEqual(menu.results.count, places, "Every condition is 全部 at first")
        XCTAssertNil(menu.selectedIndexPath)
        XCTAssertFalse(menu.lastQuery.sql.contains("WHERE"))

        // Classify menu (single choice): a tag, highlighted, and only its places.
        let sichuan = ip(1, 0)
        menu.selectClassifyItem(at: sichuan)
        let tag = menu.selectedTag ?? ""
        XCTAssertTrue(tag.hasPrefix("川菜"), tag)
        XCTAssertEqual(menu.selectedIndexPath, sichuan)
        XCTAssertGreaterThan(menu.results.count, 0)
        XCTAssertTrue(menu.results.allSatisfy { $0["tag"] as? String == tag })
        let tags = CYLTagListProbe(menu)
        tags.layOut()
        let button = tags.cell(at: sichuan)?.value(forKey: "button") as? UIButton
        XCTAssertTrue(button?.isSelected ?? false, "The selected tag is highlighted (core: selectedIndexPath)")
        XCTAssertTrue(button?.accessibilityTraits.contains(.selected) ?? false)
        // The results are the menu's footer, below the tags, in the scroll view.
        let footer: UIView = menu.menuFooterView
        XCTAssertGreaterThanOrEqual(footer.frame.minY, tags.collectionView.frame.maxY - 0.5)
        XCTAssertGreaterThan(footer.frame.height, 40)
        let scroll = footer.superview as? UIScrollView
        XCTAssertGreaterThanOrEqual(scroll?.contentSize.height ?? 0, footer.frame.maxY - 0.5)
        XCTAssertTrue(menu.statusLabel.text?.contains("tag = '") ?? false, menu.statusLabel.text ?? "")

        // Multiple filter: regions (and dishes), ANDed with the tag.
        menu.confirmFilterSelection([ip(2, 0), ip(0, 1)])
        XCTAssertEqual(menu.selectedRegions, ["上海"])
        XCTAssertEqual(menu.selectedDishes, [])
        let expected = try database.rows(forSQL: "SELECT name FROM places WHERE tag = ? AND region = ?", arguments: [tag, "上海"])
        XCTAssertEqual(menu.results.count, expected.count)
        XCTAssertTrue(menu.results.allSatisfy { $0["region"] as? String == "上海" })
        XCTAssertTrue(menu.lastQuery.sql.contains("tag = ? AND region IN (?)"), menu.lastQuery.sql)
        captureScreen(named: "test-database-menu-linkage")

        // Saved in the database: a new visit restores the conditions and the results.
        let again = CYLMenuLinkageViewController(database: database)
        showInNavigation(again)
        XCTAssertEqual(again.selectedIndexPath, sichuan)
        XCTAssertEqual(again.selectedRegions, ["上海"])
        XCTAssertEqual(again.results.count, menu.results.count)

        // Tapping the tag again clears it; reset brings every place back.
        again.selectClassifyItem(at: sichuan)
        XCTAssertNil(again.selectedTag)
        again.confirmFilterSelection([ip(0, 0), ip(2, 1), ip(3, 1)])
        XCTAssertEqual(again.selectedDishes.count, 2)
        XCTAssertTrue(again.results.allSatisfy { again.selectedDishes.contains($0["tag"] as? String ?? "") })
        again.resetConditions()
        XCTAssertEqual(again.results.count, places)
        XCTAssertNil(database.savedSelection(forScenario: CYLMenuLinkageClassifyScenario))
    }
}
