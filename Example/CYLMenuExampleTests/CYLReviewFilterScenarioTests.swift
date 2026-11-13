//
//  CYLReviewFilterScenarioTests.swift
//  CYLMenuExampleTests
//
//  Scenario 1 (Taobao review filter): memory and network filtering, the fold chevron, the product page preview.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLReviewFilterScenarioTests: CYLMenuExampleTestCase {

    private var store: CYLReviewStore {
        CYLReviewStore.shared()
    }

    private func waitForQuery(of controller: CYLReviewListViewController) {
        waitUntil { !controller.query.isLoading }
    }

    private func rows(of controller: CYLReviewListViewController) -> Int {
        controller.tableView.numberOfRows(inSection: 0)
    }

    private func status(of controller: CYLReviewListViewController) -> String {
        controller.statusLabel.text ?? ""
    }

    func testMemoryFilteringMatchesEverySelectedTagImmediately() {
        let controller = CYLReviewListViewController(selectedFilterIndex: 0)
        showInNavigation(controller)
        let filter: CYLTagListView = controller.filterView
        let tags = filter.probe
        XCTAssertEqual(controller.mode, .memory)
        XCTAssertEqual(filter.selectionMode, .multiple)
        XCTAssertEqual(filter.selectedIndexPaths, [ip(0, 0)])
        XCTAssertEqual(rows(of: controller), store.reviews.count)
        XCTAssertNil(controller.tableView.tableHeaderView, "The filter sits above the list, not in it")
        XCTAssertGreaterThan(tags.collectionView.visibleCells.count, 0)

        tags.tap(item: 1, section: 0)  // 好评
        XCTAssertEqual(filter.selectedIndexPaths, [ip(1, 0)], "Selecting a condition clears 全部")
        let good = store.reviewsMatchingAll([store.filters[1]])
        XCTAssertEqual(rows(of: controller), good.count, "Refreshed synchronously")
        XCTAssertTrue(status(of: controller).contains("点击「好评("))

        tags.tap(item: 4, section: 0)  // 有图: both must match
        let both = store.reviewsMatchingAll([store.filters[1], store.filters[4]])
        XCTAssertLessThan(both.count, good.count)
        XCTAssertEqual(controller.selectedFilters.map(\.identifier), ["good", "photo"])
        XCTAssertEqual(controller.visibleReviews, both)
        XCTAssertEqual(rows(of: controller), both.count)
        XCTAssertTrue(status(of: controller).contains("匹配 \(both.count) 条"), status(of: controller))
        captureScreen(named: "test-scenario1-memory-filter-good-photo")

        tags.tap(item: 4, section: 0)  // deselect 有图
        XCTAssertTrue(status(of: controller).contains("取消「有图("))
        XCTAssertEqual(rows(of: controller), good.count)
        tags.tap(item: 1, section: 0)  // deselect the last condition
        XCTAssertEqual(filter.selectedIndexPaths, [ip(0, 0)], "Nothing selected shows 全部")
        XCTAssertEqual(rows(of: controller), store.reviews.count)

        tags.tap(item: 3, section: 0)  // 差评(0) is disabled.
        XCTAssertEqual(filter.selectedIndexPaths, [ip(0, 0)])
        tags.tap(item: 6, section: 0)
        tags.tap(item: 0, section: 0)  // 全部 clears the conditions
        XCTAssertEqual(filter.selectedIndexPaths, [ip(0, 0)])
        XCTAssertEqual(rows(of: controller), store.reviews.count)
    }

    func testNetworkFilteringRefreshesWhenTheResponseArrives() {
        let controller = CYLReviewListViewController(selectedFilterIndex: 0, mode: .network)
        guard let network = controller.query as? CYLNetworkReviewQuery else {
            return XCTFail("The network scenario uses CYLNetworkReviewQuery")
        }
        network.latency = 0.3
        showInNavigation(controller)
        let tags = controller.filterView.probe
        XCTAssertTrue(network.isLoading, "The first page is requested from the server")
        waitForQuery(of: controller)
        XCTAssertEqual(rows(of: controller), store.reviews.count)

        tags.tap(item: 1, section: 0)  // 好评
        XCTAssertTrue(network.isLoading)
        XCTAssertEqual(rows(of: controller), store.reviews.count, "The list waits for the server")
        XCTAssertTrue(status(of: controller).contains("加载中"))
        XCTAssertEqual(network.lastRequestURL?.absoluteString, "https://api.example.com/reviews?filter=good")
        waitForQuery(of: controller)
        let good = store.reviewsMatchingAll([store.filters[1]])
        XCTAssertEqual(rows(of: controller), good.count)
        XCTAssertTrue(status(of: controller).contains("服务器返回 \(good.count) 条"), status(of: controller))

        // Two quick changes: only the response to the last request is shown.
        let dropped = network.droppedResponseCount
        tags.tap(item: 4, section: 0)
        tags.tap(item: 4, section: 0)
        waitForQuery(of: controller)
        waitUntil { network.droppedResponseCount > dropped }
        XCTAssertEqual(controller.visibleReviews, good)

        // The server receives every condition.
        let url = CYLNetworkReviewQuery.requestURL(for: [store.filters[1], store.filters[6]])
        XCTAssertTrue(url.query?.contains("filter=good") ?? false)
        XCTAssertEqual(CYLReviewServer.reviews(forRequestURL: url), store.reviewsMatchingAll([store.filters[1], store.filters[6]]))
    }

    func testFilteringModesAreSeparateScenarios() {
        let controller = CYLReviewListViewController(selectedFilterIndex: 0)
        showInNavigation(controller)
        XCTAssertTrue(controller.navigationItem.titleView === controller.modeControl)
        XCTAssertEqual(controller.modeControl.titleForSegment(at: 0), "内存筛选")
        XCTAssertEqual(controller.modeControl.titleForSegment(at: 1), "网络筛选")
        XCTAssertTrue(controller.query is CYLMemoryReviewQuery)
        XCTAssertTrue(status(of: controller).contains("内存筛选"))
        controller.modeControl.selectedSegmentIndex = 1
        controller.modeControl.sendActions(for: .valueChanged)
        XCTAssertEqual(controller.mode, .network)
        XCTAssertTrue(controller.query is CYLNetworkReviewQuery)
        XCTAssertTrue(status(of: controller).contains("网络筛选"))
        waitForQuery(of: controller)
    }

    func testFoldChevronFoldsToTwoRowsAndTurns() {
        let controller = CYLReviewListViewController(selectedFilterIndex: 0)
        showInNavigation(controller)
        let filter: CYLTagListView = controller.filterView
        let tags = filter.probe
        tags.layOut()
        XCTAssertTrue(filter.canFoldSection(0))
        let total = filter.menuDataSource?.menuNumberOfItems(inSection: 0) ?? 0
        let folded = tags.numberOfItems(inSection: 0)
        XCTAssertLessThan(folded, total, "Folded to two rows")
        let footer = tags.footer(inSection: 0)
        guard let chevron = tags.footerFoldButton(inSection: 0) else {
            return XCTFail("The footer has a fold control")
        }
        XCTAssertEqual(filter.foldControl.position, .footer)
        XCTAssertEqual(filter.foldControl.content, .icon, "Taobao: the chevron alone")
        XCTAssertTrue(chevron.imageView.transform.isIdentity, "Points down while folded")
        let foldedHeight = filter.frame.height
        captureScreen(named: "test-scenario1-review-filter-folded")

        chevron.sendActions(for: .touchUpInside)
        controller.view.layoutIfNeeded()
        XCTAssertTrue(filter.isSectionExpanded(0))
        XCTAssertEqual(tags.numberOfItems(inSection: 0), total, "Every row is shown")
        XCTAssertTrue(tags.footer(inSection: 0) === footer, "The footer stays, so its chevron can turn")
        XCTAssertEqual(chevron.imageView.transform.a, -1, accuracy: 0.01, "Turned 180°")
        XCTAssertGreaterThan(filter.frame.height, foldedHeight)
        captureScreen(named: "test-scenario1-review-filter-expanded")

        chevron.sendActions(for: .touchUpInside)
        controller.view.layoutIfNeeded()
        XCTAssertEqual(tags.numberOfItems(inSection: 0), folded)
        XCTAssertEqual(chevron.imageView.transform.a, 1, accuracy: 0.01)
        XCTAssertEqual(filter.frame.height, foldedHeight, accuracy: 1)
    }

    func testReviewPagePreselectsAndRevealsKeywordFilter() {
        let last = store.filters.count - 1
        let controller = CYLReviewListViewController(selectedFilterIndex: last)
        showInNavigation(controller)
        XCTAssertEqual(controller.filterView.selectedIndexPaths, [ip(last, 0)])
        XCTAssertGreaterThan(controller.filterView.numberOfVisibleItems(inSection: 0), last)
        XCTAssertEqual(rows(of: controller), store.reviewsMatching(store.filters[last]).count)
    }

    func testProductPreviewShowsTwoRowsAndOpensReviews() {
        let controller = CYLProductViewController()
        let navigation = showInNavigation(controller)
        let preview = controller.previewView
        XCTAssertEqual(preview.selectionMode, .none)
        XCTAssertEqual(preview.foldStyle, .truncate)
        let total = preview.menuDataSource?.menuNumberOfItems(inSection: 0) ?? 0
        if preview.numberOfRows(inSection: 0) > 2 {
            XCTAssertLessThan(preview.numberOfVisibleItems(inSection: 0), total, "Only two rows are previewed")
        } else {
            XCTAssertEqual(preview.numberOfVisibleItems(inSection: 0), total)
        }
        XCTAssertEqual(preview.frame.height, preview.heightThatFitsWidth(preview.bounds.width), accuracy: 1)
        captureScreen(named: "test-scenario1-product-preview")

        preview.probe.tap(item: 1, section: 0)
        let reviews = navigation.topViewController as? CYLReviewListViewController
        XCTAssertNotNil(reviews)
        reviews?.loadViewIfNeeded()
        XCTAssertEqual(reviews?.selectedFilters.count, 1)
        XCTAssertTrue(reviews?.selectedFilters.first?.isKeyword ?? false)
        XCTAssertEqual(preview.selectedIndexPaths, [])
    }
}
