//
//  CYLSearchCategoryScenarioTests.swift
//  CYLMenuExampleTests
//
//  Scenario 2 (Maimai search categories): the nested category tab bar at the bottom, tags that fill the search bar,
//  the job sidebar and the industry accessory.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
import CYLTabBarController
@testable import CYLMenuExample

final class CYLSearchCategoryScenarioTests: CYLMenuExampleTestCase {

    /**
     * In a window, not hidden, transparent or off screen through any of its superviews.
     */
    private func isVisible(_ view: UIView) -> Bool {
        guard let window = view.window else { return false }
        var current: UIView? = view
        while let candidate = current {
            if candidate.isHidden || candidate.alpha < 0.01 { return false }
            current = candidate.superview
        }
        return view.convert(view.bounds, to: nil).intersects(window.bounds)
    }

    func testSearchCategoriesUseABottomTabBarAndFillTheSearchBar() {
        let controller = CYLSearchCategoryViewController()
        showInNavigation(controller)
        controller.layOutSelectedCategory()
        let tabs: CYLTabBarController = controller.categoryTabBarController
        XCTAssertEqual(tabs.viewControllers?.count, 4)
        XCTAssertEqual(tabs.tabTitles, ["找人", "动态", "八卦", "职位"])
        let list = controller.tagListView
        let barFrame = tabs.tabBar.convert(tabs.tabBar.bounds, to: controller.view)
        let tagsFrame = list.convert(list.bounds, to: controller.view)
        XCTAssertGreaterThan(barFrame.minY, controller.view.bounds.height / 2, "Tab bars are always at the bottom")
        XCTAssertLessThanOrEqual(tagsFrame.maxY, barFrame.minY + 0.5, "Tags end above the tab bar")
        XCTAssertNotNil(list.window)

        XCTAssertEqual(controller.category, .people)
        XCTAssertEqual(list.probe.collectionView.numberOfSections, 4)
        XCTAssertEqual(controller.searchBar.placeholder, "搜人名,职位,公司...")
        list.probe.tap(item: 1, section: 1)
        XCTAssertEqual(controller.searchBar.text, "IDG资本")
        XCTAssertEqual(list.selectedIndexPaths, [])
        captureScreen(named: "test-scenario2-search-people")

        // A tap on the 八卦 tab, as the tab bar reports it.
        tabs.selectedIndex = CYLSearchCategory.gossip.rawValue
        if let selected = tabs.selectedViewController {
            tabs.delegate?.tabBarController?(tabs, didSelect: selected)
        }
        controller.layOutSelectedCategory()
        XCTAssertEqual(controller.category, .gossip)
        XCTAssertEqual(controller.searchBar.placeholder, "搜八卦")
        let gossip = controller.tagListView
        XCTAssertFalse(gossip === list)
        XCTAssertFalse(isVisible(list), "Only the selected category's page is shown (a tab bar controller may keep the previous page hidden in the window)")
        XCTAssertTrue(isVisible(gossip))
        XCTAssertNotNil(gossip.window)
        XCTAssertEqual(gossip.probe.collectionView.numberOfSections, 2)
        gossip.assertItemsFit()
        gossip.probe.tap(item: 2, section: 0)
        XCTAssertEqual(controller.searchBar.text, "程序猿")
    }

    func testJobCategoriesUseSidebarAndIndustryAccessory() {
        let controller = CYLSearchCategoryViewController()
        showInNavigation(controller)
        controller.select(.jobs)
        controller.layOutSelectedCategory()
        XCTAssertEqual(controller.categoryTabBarController.selectedIndex, CYLSearchCategory.jobs.rawValue)
        let list = controller.tagListView
        let tags = list.probe
        let sidebar = controller.jobCategoryTableView
        XCTAssertTrue(sidebar.superview === list.superview)
        XCTAssertEqual(list.frame.minX, sidebar.frame.maxX, accuracy: 0.5)
        XCTAssertEqual(sidebar.numberOfRows(inSection: 0), 10)
        XCTAssertEqual(tags.numberOfItems(inSection: 0), 31)
        list.assertItemsFit()

        tags.layOut()
        XCTAssertTrue(controller.industryButton.superview === tags.header(inSection: 0))
        controller.selectIndustry("金融")
        XCTAssertEqual(controller.industry, "金融")
        XCTAssertTrue(controller.industryButton.title(for: .normal)?.contains("金融") ?? false)
        captureScreen(named: "test-scenario2-search-jobs")

        sidebar.delegate?.tableView?(sidebar, didSelectRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(tags.numberOfItems(inSection: 0), 7)
        tags.tap(item: 0, section: 0)
        XCTAssertEqual(controller.searchBar.text, "测试工程师")
    }
}

extension CYLSearchCategoryViewController {

    /**
     * Lays out the selected category's page. The embedded tab bar controller adds that page's view during appearance,
     * on a later run loop pass, so the run loop works first.
     */
    func layOutSelectedCategory() {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.2))
        view.layoutIfNeeded()
        categoryTabBarController.view.layoutIfNeeded()
        categoryTabBarController.selectedViewController?.view.layoutIfNeeded()
        tagListView.layoutIfNeeded()
    }
}
