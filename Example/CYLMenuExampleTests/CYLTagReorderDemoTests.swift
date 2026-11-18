//
//  CYLTagReorderDemoTests.swift
//  CYLMenuExampleTests
//
//  Drag to reorder: the first row of the 样式 tab opens the Android example's drag screen (AndroidTagView's sample),
//  whose first two containers move their tags.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLTagReorderDemoTests: CYLMenuExampleTestCase {

    func testTheStyleTabOpensTheAndroidStyleDragScreenFirst() {
        let style = CYLTagStyleDemoViewController()
        let navigation = showInNavigation(style)
        XCTAssertEqual(style.actionIdentifiers().first, ["sample.reorder"], "drag to reorder is the first row of the 样式 tab")
        style.performAction("sample.reorder")
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
        XCTAssertTrue(navigation.topViewController is CYLTagContainerSampleViewController,
                      "the Android example's drag screen (AndroidTagView's sample)")
    }

    /// The first two containers drag (container_enable_drag); a drop moves the tag.
    func testDraggingATagReordersTheFirstContainers() {
        let sample = CYLTagContainerSampleViewController()
        showInNavigation(sample, size: CYLTestScreen.tall)
        sample.view.layoutIfNeeded()
        XCTAssertEqual(sample.containers.map(\.allowsReordering), [true, true, false, false, false, false])
        let list = sample.containers[0]
        list.probe.layOut()
        let collection = list.probe.collectionView
        XCTAssertTrue(collection.dataSource?.collectionView?(collection, canMoveItemAt: ip(0, 0)) ?? false)
        var moves: [String] = []
        list.tagMoveHandler = { from, to in moves.append("\(from)->\(to)") }

        // A drag ends with the collection view moving the item, as here: "Java" from the front to the fourth place.
        collection.dataSource?.collectionView?(collection, moveItemAt: ip(0, 0), to: ip(3, 0))
        XCTAssertEqual(Array(list.tags.map(\.title).prefix(4)), ["C++", "Python", "Swift", "Java"])
        XCTAssertEqual(moves, ["0->3"])
    }

    /// While a tag is dragged, each slot gets the width of the tag shown in it, so no title is cut.
    func testSlotsTakeTheWidthsOfTheTagsShownInThemDuringADrag() {
        let sample = CYLTagContainerSampleViewController()
        showInNavigation(sample, size: CYLTestScreen.tall)
        sample.view.layoutIfNeeded()
        let list = sample.containers[0]
        list.probe.layOut()
        let collection = list.probe.collectionView
        let layout = collection.collectionViewLayout
        func width(_ item: Int) -> CGFloat {
            list.collectionView(collection, layout: layout, sizeForItemAt: ip(item, 0)).width
        }
        let before = (0..<4).map(width)  // Java, C++, Python, Swift
        XCTAssertNotEqual(before[0], before[2], "the tags differ in width")

        // The drag proposes the fourth place for "Java": the layout now shows C++, Python, Swift, Java.
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
