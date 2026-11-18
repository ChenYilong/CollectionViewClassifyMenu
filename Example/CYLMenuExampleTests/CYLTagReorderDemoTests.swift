//
//  CYLTagReorderDemoTests.swift
//  CYLMenuExampleTests
//
//  The drag-to-reorder demo: the first row of the 样式 tab opens it, its tags can move, and the order below follows.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLTagReorderDemoTests: CYLMenuExampleTestCase {

    func testTheStyleTabOpensTheReorderDemoFirst() {
        let style = CYLTagStyleDemoViewController()
        let navigation = showInNavigation(style)
        XCTAssertEqual(style.actionIdentifiers().first, ["sample.reorder"], "drag to reorder is the first row of the 样式 tab")
        style.performAction("sample.reorder")
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
        XCTAssertTrue(navigation.topViewController is CYLTagReorderDemoViewController)
    }

    func testDraggingATagReordersTheTagsAndTheShownOrder() {
        let demo = CYLTagReorderDemoViewController()
        showInNavigation(demo)
        demo.view.layoutIfNeeded()
        let list = demo.tagListView!
        XCTAssertTrue(list.allowsReordering)
        let collection = list.probe.collectionView
        XCTAssertTrue(collection.dataSource?.collectionView?(collection, canMoveItemAt: ip(0, 0)) ?? false)

        // A drag ends with the collection view moving the item, as here: "Swift" from the front to the fourth place.
        collection.dataSource?.collectionView?(collection, moveItemAt: ip(0, 0), to: ip(3, 0))
        XCTAssertEqual(list.tags.map(\.title), ["Kotlin", "ArkTS", "Dart", "Swift", "TypeScript", "Objective-C", "Java", "C++", "Rust", "Go"])
        XCTAssertEqual(demo.titles, list.tags.map(\.title))
        XCTAssertTrue(demo.orderLabel.text?.contains("Kotlin · ArkTS · Dart · Swift") ?? false)

        demo.reset()
        XCTAssertEqual(list.tags.map(\.title), CYLTagReorderDemoViewController.initialTitles)
        XCTAssertEqual(demo.titles, CYLTagReorderDemoViewController.initialTitles)
    }

    /// While a tag is dragged, each slot gets the width of the tag shown in it, so no title is cut ("Kot…").
    func testSlotsTakeTheWidthsOfTheTagsShownInThemDuringADrag() {
        let demo = CYLTagReorderDemoViewController()
        showInNavigation(demo)
        demo.view.layoutIfNeeded()
        let list = demo.tagListView!
        let collection = list.probe.collectionView
        let layout = collection.collectionViewLayout
        func width(_ item: Int) -> CGFloat {
            list.collectionView(collection, layout: layout, sizeForItemAt: ip(item, 0)).width
        }
        let before = (0..<4).map(width)  // Swift, Kotlin, ArkTS, Dart
        XCTAssertNotEqual(before[0], before[3], "the tags differ in width")

        // The drag proposes the fourth place for "Swift": the layout now shows Kotlin, ArkTS, Dart, Swift.
        let target = list.collectionView(collection, targetIndexPathForMoveOfItemFromOriginalIndexPath: ip(0, 0),
                                         atCurrentIndexPath: ip(0, 0), toProposedIndexPath: ip(3, 0))
        XCTAssertEqual(target, ip(3, 0))
        XCTAssertEqual((0..<4).map(width), [before[1], before[2], before[3], before[0]])

        // Dropped: the data follows, and after the next pass the measurements are in the new order.
        collection.dataSource?.collectionView?(collection, moveItemAt: ip(0, 0), to: ip(3, 0))
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.2))
        XCTAssertEqual((0..<4).map(width), [before[1], before[2], before[3], before[0]])
    }

    /// The Android example's About tab, ported: the Style tab's last sample row names the three sources and licenses.
    func testTheAboutRowNamesTheThreeAndroidLibrariesAndTheirLicenses() {
        let style = CYLTagStyleDemoViewController()
        let navigation = showInNavigation(style)
        XCTAssertTrue(style.actionIdentifiers().contains { $0.last == "sample.about" })
        style.performAction("sample.about")
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
        let about = navigation.topViewController as? CYLAndroidSamplesAboutViewController
        about?.loadViewIfNeeded()
        let text = about?.textView.text ?? ""
        for source in ["kaedea/android-tagview", "whilu/AndroidTagView", "shellljx/TagViewGroup", "Apache License 2.0", "GPL-3.0"] {
            XCTAssertTrue(text.contains(source), source)
        }
    }
}
