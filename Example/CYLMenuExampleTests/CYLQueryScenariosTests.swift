//
//  CYLQueryScenariosTests.swift
//  CYLMenuExampleTests
//
//  The query scenarios screen (plus button): one tag list, one section per group, each section titled; a tag shows its
//  title and icon, the detail line is the long-press callout, a tap opens the demo and selects nothing.
//  NOT compiled or run when written (Windows): the Mac session builds it.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLQueryScenariosTests: CYLMenuExampleTestCase {

    private func makeScreen() -> (CYLQueryScenariosViewController, UINavigationController) {
        let screen = CYLQueryScenariosViewController()
        let navigation = showInNavigation(screen, size: CYLTestScreen.tall)
        screen.tagList.probe.layOut()
        return (screen, navigation)
    }

    func testOneTagListWithATitledSectionPerGroup() {
        let (screen, _) = makeScreen()
        let list = screen.tagList
        XCTAssertTrue(list.menuDataSource === screen)
        XCTAssertEqual(list.probe.collectionView.numberOfSections, CYLQueryScenariosViewController.databaseSection + 1)
        let counts = [3, 1, 1, CYLQueryScenariosViewController.databaseTables.count]
        for (section, count) in counts.enumerated() {
            XCTAssertEqual(screen.menuNumberOfItems(inSection: section), count)
            XCTAssertFalse(screen.menuTitle(forSection: section).isEmpty, "Every section header has a title")
        }
        XCTAssertEqual(screen.menuTitle(forSection: 0), "场景：查询参数设置（多选）")
        XCTAssertEqual(screen.menuTitle(forSection: CYLQueryScenariosViewController.databaseSection), "数据库（SQLite）")
    }

    func testATagShowsTheTitleAndAnIconAndTheDetailIsTheSubtitle() {
        let (screen, _) = makeScreen()
        XCTAssertEqual(screen.menuTitleForItem(at: ip(0, 0)), "评价筛选 · 数据库（SQLite）")
        XCTAssertEqual(screen.menuTitleForItem(at: ip(0, 3)), "reviews")
        for section in 0...CYLQueryScenariosViewController.databaseSection {
            for item in 0..<screen.menuNumberOfItems(inSection: section) {
                XCTAssertNotNil(screen.menuImageForItem(at: ip(item, section)), "An SF Symbol per tag")
                XCTAssertTrue(screen.menuSubtitleForItem(at: ip(item, section))?.contains(screen.sectionDetail(section)) ?? false)
            }
        }
        let count = screen.database.count(ofTable: "reviews")
        XCTAssertTrue(screen.menuSubtitleForItem(at: ip(0, 3))?.hasPrefix(CYLExampleLocalizedString("%ld 行", count)) ?? false,
                      "A table's long press starts with its row count")
    }

    func testFoldingAdaptiveWidthAndLongPressConfiguration() {
        let (screen, _) = makeScreen()
        let list = screen.tagList
        XCTAssertEqual(list.defaultVisibleRows, CYLQueryScenariosViewController.visibleRows)
        XCTAssertEqual(list.defaultVisibleRows, 2)
        XCTAssertEqual(list.foldControl.position, .tail)
        XCTAssertEqual(list.foldControl.content, .icon)
        XCTAssertEqual(list.selectionMode, .none)
        XCTAssertEqual(list.style.numberOfItemsPerRow, 0, "Adaptive tag width")
        XCTAssertEqual(list.style.titleMaxLines, 3)
        XCTAssertTrue(list.longPressAction === CYLTagLongPressActions.callout)
    }

    func testATapOpensTheDemoAndSelectsNothing() {
        let (screen, navigation) = makeScreen()
        screen.tagList.probe.tap(item: 0, section: 0)
        let reviews = navigation.topViewController as? CYLReviewListViewController
        XCTAssertEqual(reviews?.mode, .database)
        XCTAssertTrue(reviews?.hidesBottomBarWhenPushed ?? false)
        XCTAssertTrue(screen.tagList.selectedIndexPaths.isEmpty, "The tag does not stay selected")

        let (other, otherNavigation) = makeScreen()
        other.tagList.probe.tap(item: 0, section: 1)
        XCTAssertTrue(otherNavigation.topViewController is CYLMenuLinkageViewController)
        let (last, lastNavigation) = makeScreen()
        last.tagList.probe.tap(item: 0, section: 2)
        XCTAssertTrue(lastNavigation.topViewController is CYLSearchDiscoverViewController)
    }

    func testATapOnADatabaseTableOpensNothing() {
        let (screen, navigation) = makeScreen()
        screen.tagList.probe.tap(item: 0, section: CYLQueryScenariosViewController.databaseSection)
        XCTAssertTrue(navigation.topViewController === screen)
    }
}
