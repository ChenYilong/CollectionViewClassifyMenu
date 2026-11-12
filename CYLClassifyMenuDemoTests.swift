//
//  CYLClassifyMenuDemoTests.swift
//  CollectionViewClassifyMenuTests
//
//  Tests of the demo app of CollectionViewClassifyMenu.xcodeproj (module CYLClassifyMenuDemo): the filter selection
//  migration of CYLMainViewController, its header, and its own localization lookup. The core tests are in
//  CYLCollectionViewClassifyMenuLayoutTests.m.
//

import XCTest
import CollectionViewClassifyMenu
@testable import CYLClassifyMenuDemo

/// A filter source with an exclusive first item per section.
private final class CYLDemoTestMenuSource: NSObject, CYLMenuDataSource {
    let sections: [[String]]

    init(sections: [[String]]) {
        self.sections = sections
    }

    func numberOfSectionsInMenu() -> Int { sections.count }
    func menuNumberOfItems(inSection section: Int) -> Int { sections[section].count }
    func menuTitle(forSection section: Int) -> String { "Section \(section)" }
    func menuTitleForItem(at indexPath: IndexPath) -> String { sections[indexPath.section][indexPath.item] }
    func menuItemIsExclusive(at indexPath: IndexPath) -> Bool { indexPath.item == 0 }
}

final class CYLClassifyMenuDemoTests: XCTestCase {

    func testLegacyFilterSelectionMigrationValidatesArchivedStates() throws {
        let source = CYLDemoTestMenuSource(sections: [["All", "One"], ["All", "Two"]])
        let controller = CYLFilterDemoViewController()
        controller.filterSource = source
        let legacy = CYLFilterParamsTool()
        legacy.filterParamsArray = NSMutableArray(array: [NSMutableArray(array: [0, 1]), NSMutableArray(array: [1, 0])])
        var archive = try NSKeyedArchiver.archivedData(withRootObject: legacy, requiringSecureCoding: false)
        XCTAssertEqual(controller.selection(fromLegacyArchiveData: archive), [[0, 1], [1, 0]])
        XCTAssertNil(controller.selection(fromLegacyArchiveData: Data("invalid".utf8)))
        XCTAssertNil(controller.validatedSelection([[-1, 0]]))
        XCTAssertNil(controller.validatedSelection([[0, 0], [0, 1]]))
        (legacy.filterParamsArray[0] as! NSMutableArray)[1] = "bad"
        archive = try NSKeyedArchiver.archivedData(withRootObject: legacy, requiringSecureCoding: false)
        XCTAssertNil(controller.selection(fromLegacyArchiveData: archive))
    }

    /// The two features have a tab each (Classify, Filter); the plus button's page is About.
    func testClassifyAndFilterHaveTabsOfTheirOwn() throws {
        let tabs = try XCTUnwrap(CYLAppDelegate.makeTabBarController())
        tabs.loadViewIfNeeded()
        let roots = (tabs.viewControllers ?? []).compactMap { ($0 as? UINavigationController)?.viewControllers.first }
        XCTAssertTrue(roots.contains { $0 is CYLMainViewController }, "a Classify tab")
        XCTAssertTrue(roots.contains { $0 is CYLFilterDemoViewController }, "a Filter tab")
        XCTAssertFalse(roots.contains { $0 is CYLMainViewController && $0 is CYLFilterDemoViewController })
        let classify = try XCTUnwrap(roots.first { $0 is CYLMainViewController })
        classify.loadViewIfNeeded()
        XCTAssertNil(classify.navigationItem.leftBarButtonItem, "the Classify tab has no filter button")
    }

    /// The Filter tab lists the demo places of the selected regions and dishes.
    func testFilterTabListsTheMatchingPlaces() throws {
        UserDefaults.standard.removeObject(forKey: CYLFilterDemoViewController.filterSelectionKey)
        let filter = CYLFilterDemoViewController()
        filter.loadViewIfNeeded()
        XCTAssertEqual(filter.results.count, CYLDemoPlaces.all.count)
        XCTAssertNotNil(filter.navigationItem.leftBarButtonItem, "the filter button")
        let source = try XCTUnwrap(filter.filterSource)
        let beijing = IndexPath(item: 1, section: 0)
        let region = source.menuTitleForItem(at: beijing)
        filter.menu(filter.filterController, didConfirmSelectedItems: [beijing, IndexPath(item: 0, section: 1)])
        XCTAssertFalse(filter.results.isEmpty)
        XCTAssertTrue(filter.results.allSatisfy { $0.region == region })
        XCTAssertEqual(filter.results, CYLDemoPlaces.places(regions: [region], dishes: []))
        XCTAssertEqual(CYLDemoPlaces.all.count, 83, "the shared database: the same places as the Android example")
        XCTAssertEqual(CYLDemoPlaces.all.first?.name, "日式拉面 · 北京", "the shared database's first place by rating")
        XCTAssertEqual(filter.lastQuery.displayString(),
                       "SELECT name, category, tag, region, rating, price FROM places WHERE region IN ('\(region)') ORDER BY rating DESC, id")
        UserDefaults.standard.removeObject(forKey: CYLFilterDemoViewController.filterSelectionKey)
    }

    func testDemoHeaderFitsANarrowScreen() throws {
        let demo = CYLMainViewController()
        demo.loadViewIfNeeded()
        let title = try XCTUnwrap(demo.titleLabel)
        let toggle = try XCTUnwrap(demo.rowsCountBydefaultSwitch)
        let header = try XCTUnwrap(toggle.superview)
        header.frame = CGRect(x: 0, y: 0, width: 320, height: header.frame.height)
        header.layoutIfNeeded()
        XCTAssertLessThanOrEqual(toggle.frame.maxX, header.bounds.width)
        XCTAssertLessThanOrEqual(title.frame.maxX, toggle.frame.minX)
        XCTAssertTrue(title.accessibilityTraits.contains(.header))
        XCTAssertFalse(toggle.accessibilityLabel?.isEmpty ?? true, "The switch has a label of its own")
    }

    func testDemoLookupReadsItsOwnBundle() {
        let saved = CYLMenuResources.preferredLanguage
        defer { CYLMenuResources.preferredLanguage = saved }
        CYLMenuResources.preferredLanguage = "en"
        XCTAssertEqual(CYLDemoLocalizedString("重置筛选条件"), "Reset filters")
        XCTAssertEqual(CYLMenuLocalizedString("重置筛选条件"), "重置筛选条件", "Demo strings are not in the core bundle")
        XCTAssertEqual(CYLMenuLocalizedString("CYLMenuNewTag"), "New Tag", "The core's Swift lookup")
        CYLMenuResources.preferredLanguage = "zh-Hant"
        XCTAssertEqual(CYLDemoLocalizedString("重置筛选条件"), "重設篩選條件")
    }

    func testSharedDemoDataSourceReadsTheDemoData() {
        XCTAssertFalse(CYLDBManager.dataSource().isEmpty, "data.json of the main bundle")
        XCTAssertFalse(CYLDBManager.allTags().isEmpty)
        let filter = CYLDemoDataSource.filterDataSource()
        XCTAssertEqual(filter.numberOfSectionsInMenu(), 2)
        XCTAssertEqual(filter.menuNumberOfItems(inSection: 0), CYLDemoDataSource.regions().count + 1)
        XCTAssertTrue(filter.menuItemIsExclusive(at: IndexPath(item: 0, section: 1)))
        XCTAssertEqual(CYLDemoDataSource.shortTitle(forTitle: "北京 🏙️ 扩展文字"), "北京")
        let classify = CYLDemoDataSource.classifyDataSource()
        XCTAssertEqual(classify.numberOfSectionsInMenu(), CYLDBManager.dataSource().count)
    }
}
