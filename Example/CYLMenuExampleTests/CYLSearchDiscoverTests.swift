//
//  CYLSearchDiscoverTests.swift
//  CYLMenuExampleTests
//
//  The search history + discover screen (plus button): its JSON data, the folded recent searches with the inline
//  chevron, the two-per-row discover grid with the 热 icon and the More button.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLSearchDiscoverTests: CYLMenuExampleTestCase {

    func testSearchDiscoverDataComesFromTheJSONFile() throws {
        let data = try CYLSearchDiscoverData.bundled()
        XCTAssertEqual(data.recentSearches.count, 10)
        XCTAssertEqual(data.discover.count, 24)
        XCTAssertEqual(data.discoverCount, 6)
        XCTAssertEqual(data.initialTopics, Array(data.discover.prefix(6)))
        XCTAssertFalse(data.discover.filter { $0.icon == "hot" }.isEmpty, "Some topics have the 热 icon")
        var generator = CYLSeededRandomNumberGenerator(seed: 7)
        let refreshed = data.randomTopics(excluding: data.initialTopics, using: &generator)
        XCTAssertEqual(refreshed.count, 6)
        XCTAssertEqual(Set(refreshed.map(\.title)).count, 6, "No topic twice")
        XCTAssertTrue(refreshed.allSatisfy { !data.initialTopics.contains($0) }, "Another selection")
        var again = CYLSeededRandomNumberGenerator(seed: 7)
        XCTAssertEqual(data.randomTopics(excluding: data.initialTopics, using: &again), refreshed, "Seeded: repeatable")
    }

    func testSearchDiscoverScreenShowsTheDataAndHandlesTaps() throws {
        let screen = CYLSearchDiscoverViewController()
        let navigation = UINavigationController(rootViewController: UIViewController())
        show(navigation, size: CYLTestScreen.tall)
        navigation.pushViewController(screen, animated: false)
        runMainLoop(for: 0.2)
        screen.loadViewIfNeeded()
        screen.view.layoutIfNeeded()
        XCTAssertTrue(navigation.isNavigationBarHidden, "The search bar replaces the navigation bar")
        // 最近搜索: folded to two rows with the chevron as the last tag; the trash in the header.
        let recent = screen.recentList.probe
        recent.layOut()
        let visible = screen.recentList.numberOfVisibleItems(inSection: 0)
        XCTAssertLessThan(visible, screen.recentSource.searches.count)
        XCTAssertTrue(recent.cell(at: ip(visible, 0)) is CYLTagFoldCell)
        XCTAssertEqual(screen.recentList.foldControl.position, .tail)
        XCTAssertEqual(screen.recentSource.clearButton.accessibilityLabel, "清空最近搜索")
        XCTAssertFalse(screen.recentSource.clearButton.isHidden)
        // 发现: two per row, the 热 icon after a hot title, the core's More button.
        let discover = screen.discoverList.probe
        discover.layOut()
        XCTAssertEqual(discover.numberOfItems(inSection: 0), 6)
        XCTAssertEqual(screen.discoverList.style.numberOfItemsPerRow, 2)
        let hot = try XCTUnwrap(screen.discoverSource.topics.firstIndex { $0.icon == "hot" })
        let hotButton = discover.tagButton(at: ip(hot, 0))
        XCTAssertNotNil(hotButton?.image, "热 is an icon")
        if let hotButton {
            hotButton.layoutIfNeeded()
            XCTAssertGreaterThan(hotButton.imageView.frame.minX, hotButton.titleLabel.frame.minX, "Title on the left, icon on the right")
        }
        XCTAssertEqual(discover.cell(at: ip(hot, 0))?.accessibilityValue, "热门", "VoiceOver reads the icon's label as the value")
        let more = try XCTUnwrap(screen.discoverList.views(withIdentifier: CYLTagListAccessibilityIdentifier.moreButton).first as? UIButton)
        XCTAssertFalse(more.isHidden)
        XCTAssertNotNil(more.currentImage, "The bundle's cyl_more icon")
        XCTAssertNotNil(CYLMenuResources.image(named: "cyl_more"))
        XCTAssertEqual(more.accessibilityLabel, "换一批", "VoiceOver says what the More button does")
        XCTAssertEqual(more.largeContentTitle, "换一批")
        // Every tag says what a tap does; the hint's sparkles are not read.
        XCTAssertEqual(discover.cell(at: ip(0, 0))?.accessibilityHint, "轻点两下搜索")
        XCTAssertEqual(recent.cell(at: ip(0, 0))?.accessibilityHint, "轻点两下搜索")
        XCTAssertEqual(screen.hintLabel.accessibilityLabel, "按住提问，有问必答")
        // Icon-only buttons: labelled, and shown in the Large Content Viewer.
        for button in [screen.backButton, screen.cameraButton, screen.micButton, screen.recentSource.clearButton] {
            XCTAssertFalse(button.accessibilityLabel?.isEmpty ?? true)
            XCTAssertTrue(button.showsLargeContentViewer)
            XCTAssertEqual(button.largeContentTitle, button.accessibilityLabel)
        }
        XCTAssertEqual(screen.searchField.placeholder, screen.discoverSource.topics.first?.title)
        captureScreen(named: "test-search-discover")
        // The More button refreshes the topics (seeded here).
        let before = screen.discoverSource.topics
        screen.randomGenerator = CYLAnyRandomNumberGenerator(CYLSeededRandomNumberGenerator(seed: 1))
        more.sendActions(for: .touchUpInside)
        XCTAssertNotEqual(screen.discoverSource.topics, before)
        XCTAssertEqual(screen.discoverSource.topics.count, 6)
        // A topic or a recent search is searched again and moves to the front of the recent searches.
        discover.tap(item: 0, section: 0)
        let topic = screen.discoverSource.topics[0].title
        XCTAssertEqual(screen.searchField.text, topic)
        XCTAssertEqual(screen.recentSource.searches.first, topic)
        // Item 1 is always a tag (index 2 could be the fold cell on narrow rows).
        recent.tap(item: 1, section: 0)
        XCTAssertEqual(screen.recentSource.searches.first, screen.searchField.text)
        // The camera button answers with an alert instead of ignoring the tap.
        screen.cameraButton.sendActions(for: .touchUpInside)
        let alert = screen.presentedViewController as? UIAlertController
        XCTAssertEqual(alert?.title, "以图搜索")
        XCTAssertEqual(alert?.message, "演示中暂不支持以图搜索。")
        alert?.dismiss(animated: false)
        runMainLoop(for: 0.1)
        // The trash clears them.
        screen.recentSource.clearButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(screen.recentSource.searches.isEmpty)
        XCTAssertEqual(recent.collectionView.numberOfSections, 0)
    }
}
