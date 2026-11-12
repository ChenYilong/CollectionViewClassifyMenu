//
//  CYLRootTabBarTests.swift
//  CYLMenuExampleTests
//
//  The Example's root tab bar (CYLTabBarController): both scenarios, the plus button and its filter scenario list.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
import CYLTabBarController
@testable import CYLMenuExample

final class CYLRootTabBarTests: CYLMenuExampleTestCase {

    func testRootTabBarHoldsBothScenarios() {
        let tabs = showRootTabBarController()
        XCTAssertEqual(tabs.viewControllers?.count, 5, "Four tabs and the plus button's")
        XCTAssertEqual(tabs.fullTabTitles, ["场景一：评价筛选", "场景二：搜索分类", "样式", "动效"])
        guard let first = tabs.viewControllers?[0] as? UINavigationController,
              let second = tabs.viewControllers?[1] as? UINavigationController else {
            return XCTFail("Every tab is a navigation controller")
        }
        XCTAssertTrue(first.viewControllers.first is CYLProductViewController)
        XCTAssertTrue(second.viewControllers.first is CYLSearchHomeViewController)
        XCTAssertGreaterThan(tabs.tabBar.frame.minY, tabs.view.bounds.height / 2, "The root tab bar is at the bottom")
        captureScreen(named: "test-root-tab-bar")

        // Scenario 2: the home page pushes the search screen, which hides the root tab bar and
        // shows its own category tab bar, also at the bottom: two tab bars with different roles.
        tabs.selectedViewController = second
        guard let home = second.viewControllers.first as? CYLSearchHomeViewController else {
            return XCTFail("Scenario 2 starts on the search home page")
        }
        home.loadViewIfNeeded()
        let search = home.openSearch()
        XCTAssertTrue(second.topViewController === search)
        XCTAssertTrue(search.hidesBottomBarWhenPushed)
        search.loadViewIfNeeded()
        XCTAssertFalse(search.categoryTabBarController === tabs)
        XCTAssertTrue(search.categoryTabBarController.parent === search)

        // The review page hides the root tab bar.
        tabs.selectedIndex = 0
        guard let product = first.viewControllers.first as? CYLProductViewController else {
            return XCTFail("Scenario 1 starts on the product page")
        }
        product.loadViewIfNeeded()
        product.showReviews(withFilterIndex: 0)
        XCTAssertTrue(first.topViewController?.hidesBottomBarWhenPushed ?? false)
    }

    func testPlusButtonOpensFilterScenariosAndOnlyTheRootTabBarHasIt() {
        let tabs = showRootTabBarController()
        XCTAssertEqual(tabs.context, CYLExampleRootTabBarContext)
        let plus = CYLPlusButtonFactory.plusButton(forContext: CYLExampleRootTabBarContext)
        XCTAssertTrue(plus is CYLExamplePlusButton)
        XCTAssertTrue(plus?.isDescendant(of: tabs.tabBar) ?? false, "In the root tab bar")
        XCTAssertGreaterThan(tabs.tabBar.frame.minY, tabs.view.bounds.height / 2, "At the bottom")
        let plusTab = tabs.navigationController(rootedIn: CYLQueryScenariosViewController.self)
        XCTAssertNotNil(plusTab)
        XCTAssertEqual(tabs.viewControllers?.firstIndex { $0 === plusTab }, Int(CYLExamplePlusButton.indexOfPlusButtonInTabBar()))
        XCTAssertTrue(CYLPlusButtonFactory.plusChildViewController(forContext: CYLExampleRootTabBarContext) === plusTab)
        plus?.sendActions(for: .touchUpInside)
        XCTAssertTrue(tabs.selectedViewController === plusTab, "The plus button selects its scenario list")
        captureScreen(named: "test-plus-query-scenarios")

        // Scenario 2's nested category tab bar has another context: no plus button there.
        let search = CYLSearchCategoryViewController()
        showInNavigation(search)
        XCTAssertNotEqual(search.categoryTabBarController.context, CYLExampleRootTabBarContext)
        XCTAssertEqual(search.categoryTabBarController.viewControllers?.count, 4)
        XCTAssertFalse(search.categoryTabBarController.tabBar.subviews.contains { $0 is CYLExamplePlusButton })

        // Grouped by scenario; every row pushes its demo without the tab bar.
        guard let scenarios = plusTab?.viewControllers.first as? CYLQueryScenariosViewController else {
            return XCTFail("The plus tab shows the scenario list")
        }
        scenarios.loadViewIfNeeded()
        XCTAssertNil(scenarios.title, "navigationItem.title only: the tab keeps its title")
        // Query parameters, menu selection, search history + discover, then the database.
        let table = scenarios.tableView!
        XCTAssertEqual(table.numberOfSections, 4)
        XCTAssertEqual(table.numberOfRows(inSection: 0), 3)
        XCTAssertEqual(table.numberOfRows(inSection: 1), 1)
        XCTAssertEqual(table.numberOfRows(inSection: 2), 1)
        XCTAssertEqual(table.numberOfRows(inSection: CYLQueryScenariosViewController.databaseSection), 3)
        XCTAssertTrue(scenarios.viewController(for: .searchDiscover) is CYLSearchDiscoverViewController)
        let reviews = scenarios.viewController(for: .reviewsDatabase) as? CYLReviewListViewController
        XCTAssertNotNil(reviews)
        XCTAssertEqual(reviews?.mode, .database)
        XCTAssertTrue(reviews?.hidesBottomBarWhenPushed ?? false)
        let menu = scenarios.viewController(for: .menuLinkage)
        XCTAssertTrue(menu is CYLMenuLinkageViewController)
        XCTAssertTrue(menu.hidesBottomBarWhenPushed)
    }
}
