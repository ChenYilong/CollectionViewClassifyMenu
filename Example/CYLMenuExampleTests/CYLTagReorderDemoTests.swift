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

/// A host that records what an action asks of it (the long-press action contract, docs/tag-long-press-action.md).
private final class CYLRecordingLongPressHost: CYLTagLongPressHost {
    var log: [String] = []
    var canReorder = false
    var startsMovement = true
    var subtitles: [Int: String] = [:]

    func subtitleForItem(at indexPath: IndexPath) -> String? { subtitles[indexPath.item] }
    func showCallout(_ text: String, at indexPath: IndexPath) { log.append("callout \(indexPath.item) \(text)") }
    func dismissCallout() { log.append("dismiss") }
    func canReorderItem(at indexPath: IndexPath) -> Bool { canReorder }
    func beginReordering(at indexPath: IndexPath) -> Bool {
        log.append("beginReordering \(indexPath.item)")
        return startsMovement
    }
    func endReordering(destination: IndexPath?, moved: Bool) { log.append("endReordering \(moved)") }
    func cancelReordering() { log.append("cancelReordering") }
    func reportLongPress(at indexPath: IndexPath) { log.append("report \(indexPath.item)") }
}

/// The long-press action of a list: the default keeps the behavior before the API (reordering where the list can reorder,
/// else the long press is reported; the reordering itself is the tests above), and the built-in, combined and custom
/// actions replace it.
final class CYLTagLongPressActionTests: XCTestCase {

    private func press(_ action: CYLTagLongPressAction, _ host: CYLRecordingLongPressHost, item: Int) -> Bool {
        let path = IndexPath(item: item, section: 0)
        return action.canBegin(host: host, at: path) && action.begin(host: host, at: path)
    }

    func testTheDefaultReportsWhereTheListCannotReorderAndReordersWhereItCan() {
        let host = CYLRecordingLongPressHost()
        let action = CYLTagLongPressActions.makeDefault()
        XCTAssertFalse(press(action, host, item: 1))
        XCTAssertEqual(host.log, ["report 1"])
        host.log = []
        host.canReorder = true
        XCTAssertTrue(press(action, host, item: 2))
        action.end(host: host, destination: IndexPath(item: 0, section: 0), moved: false)
        XCTAssertEqual(host.log, ["beginReordering 2", "endReordering false"])
    }

    func testReorderThatUIKitDoesNotStartIsOnlyALongPress() {
        let host = CYLRecordingLongPressHost()
        host.canReorder = true
        host.startsMovement = false
        XCTAssertFalse(press(CYLTagLongPressActions.makeDefault(), host, item: 0))
        XCTAssertEqual(host.log, ["beginReordering 0", "report 0"])
    }

    func testCalloutNeedsASubtitleAndReports() {
        let host = CYLRecordingLongPressHost()
        host.subtitles = [1: "about y"]
        let action = CYLTagLongPressActions.first([CYLTagLongPressActions.callout, CYLTagLongPressActions.report])
        XCTAssertFalse(press(action, host, item: 0))
        XCTAssertEqual(host.log, ["report 0"], "no subtitle: the next action takes the press")
        host.log = []
        XCTAssertFalse(press(action, host, item: 1))
        XCTAssertEqual(host.log, ["callout 1 about y", "report 1"])
    }

    func testNoneAndHandlerReplaceTheBuiltInBehavior() {
        let host = CYLRecordingLongPressHost()
        XCTAssertFalse(press(CYLTagLongPressActions.none, host, item: 0))
        XCTAssertTrue(host.log.isEmpty)
        var seen: [Int] = []
        let handler = CYLTagLongPressActions.handler { host, indexPath in
            seen.append(indexPath.item)
            host.showCallout("item \(indexPath.item)", at: indexPath)
        }
        XCTAssertFalse(press(handler, host, item: 2))
        XCTAssertEqual(seen, [2])
        XCTAssertEqual(host.log, ["callout 2 item 2"], "no built-in action ran: nothing was reported")
    }

    func testFirstGivesTheEndAndTheCancelToTheActionThatBegan() {
        let host = CYLRecordingLongPressHost()
        host.canReorder = true
        let action = CYLTagLongPressActions.first([CYLTagLongPressActions.reorder, CYLTagLongPressActions.callout])
        XCTAssertTrue(press(action, host, item: 0))
        action.cancel(host: host)
        action.end(host: host, destination: nil, moved: true)
        XCTAssertEqual(host.log, ["beginReordering 0", "cancelReordering"], "the end after the cancel reaches nothing")
    }

    func testAConfigurationNamesTheSubtitle() {
        let list = CYLTagListView(configuration: [
            CYLTagListKey.longPressAction: "callout",
            CYLTagListKey.sections: [[CYLTagSectionKey.items: [[CYLTagItemKey.title: "a", CYLTagItemKey.subtitle: "about a"], "b"]]],
        ])
        let source = list.menuDataSource
        XCTAssertEqual(source?.menuSubtitleForItem?(at: IndexPath(item: 0, section: 0)), "about a")
        XCTAssertNil(source?.menuSubtitleForItem?(at: IndexPath(item: 1, section: 0)) ?? nil)
    }
}
