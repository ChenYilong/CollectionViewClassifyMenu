//
//  CYLTagListSelectionTests.swift
//  CYLMenuExampleTests
//
//  CYLTagListView: selection modes, exclusive, disabled and vetoed items, programmatic selection, reuse.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLTagListSelectionTests: CYLMenuExampleTestCase {

    func testSingleSelectionReplacesWithinSectionAndReportsDeselect() {
        let source = CYLMenuFixtures.source(itemCount: 4, sections: 2)
        let view = showTagList(source, width: 375)
        let delegate = CYLRecordingMenuDelegate()
        view.menuDelegate = delegate
        XCTAssertEqual(view.selectionMode, .single)

        view.probe.tap(item: 0, section: 0)
        view.probe.tap(item: 2, section: 0)
        view.probe.tap(item: 1, section: 1)
        XCTAssertEqual(view.selectedIndexPaths, [ip(2, 0), ip(1, 1)])
        XCTAssertEqual(delegate.events, ["select 0-0", "deselect 0-0", "select 2-0", "select 1-1"])
        XCTAssertEqual(delegate.changeCount, 3, "One change notification per tap that changed the selection")
        captureScreen(named: "test-selection-single")

        view.probe.tap(item: 2, section: 0)
        XCTAssertEqual(view.selectedIndexPaths, [ip(1, 1)], "Empty selection is allowed by default")

        view.allowsEmptySelection = false
        view.probe.tap(item: 1, section: 1)
        XCTAssertEqual(view.selectedIndexPaths, [ip(1, 1)], "The last selection stays")
    }

    func testMultipleSelectionHonoursExclusiveItems() {
        let source = CYLMenuFixtures.source(itemCount: 4, sections: 1)
        source.sections[0].items[0].isExclusive = true
        let view = showTagList(source, width: 375)
        view.selectionMode = .multiple
        view.selectedIndexPaths = [ip(0, 0)]

        view.probe.tap(item: 1, section: 0)
        view.probe.tap(item: 2, section: 0)
        XCTAssertEqual(view.selectedIndexPaths, [ip(1, 0), ip(2, 0)])
        captureScreen(named: "test-selection-multiple")
        view.probe.tap(item: 0, section: 0)
        XCTAssertEqual(view.selectedIndexPaths, [ip(0, 0)])
    }

    func testNoneModeReportsTapsWithoutKeepingSelection() {
        let source = CYLMenuFixtures.source(itemCount: 3, sections: 1)
        let view = showTagList(source, width: 375)
        let delegate = CYLRecordingMenuDelegate()
        view.menuDelegate = delegate
        view.selectionMode = .none
        view.probe.tap(item: 1, section: 0)
        view.selectItem(at: ip(2, 0))
        XCTAssertEqual(view.selectedIndexPaths, [])
        XCTAssertEqual(delegate.events, ["select 1-0"])
    }

    func testDisabledAndVetoedItemsAreIgnored() {
        let source = CYLMenuFixtures.source(itemCount: 3, sections: 1)
        source.sections[0].items[1].isEnabled = false
        let view = showTagList(source, width: 375)
        let delegate = CYLRecordingMenuDelegate()
        delegate.blockedIndexPath = ip(2, 0)
        view.menuDelegate = delegate
        view.probe.tap(item: 1, section: 0)
        view.probe.tap(item: 2, section: 0)
        XCTAssertEqual(view.selectedIndexPaths, [])
        XCTAssertEqual(delegate.events, [])
    }

    func testProgrammaticSelectionValidatesAndDoesNotCallDelegate() {
        let source = CYLMenuFixtures.source(itemCount: 3, sections: 1)
        let view = showTagList(source, width: 375)
        let delegate = CYLRecordingMenuDelegate()
        view.menuDelegate = delegate
        view.selectItem(at: ip(1, 0))
        XCTAssertEqual(view.selectedIndexPaths, [ip(1, 0)])
        view.deselectItem(at: ip(1, 0))
        XCTAssertEqual(view.selectedIndexPaths, [])
        view.selectedIndexPaths = [ip(2, 0)]
        view.deselectAllItems()
        XCTAssertEqual(view.selectedIndexPaths, [])
        // Not ported: -[CYLTagListView setSelectedIndexPaths:] raises NSInvalidArgumentException for an index path
        // outside the data (the Objective-C test checked it with XCTAssertThrowsSpecificNamed); Swift cannot catch an
        // Objective-C exception, so that assertion is left out.
        XCTAssertEqual(delegate.events, [])
    }

    func testSelectedCellsUseSelectedStyleAfterReuse() {
        let style = CYLMenuStyle()
        style.selectedAppearance.backgroundColor = .red
        let source = CYLMenuFixtures.source(itemCount: 200, sections: 1)
        let view = showTagList(source, width: 320)
        view.style = style
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        view.layoutIfNeeded()
        view.selectedIndexPaths = [ip(0, 0)]
        let tags = view.probe
        tags.scrollToBottom()
        tags.collectionView.setContentOffset(.zero, animated: false)
        tags.layOut()
        for indexPath in tags.collectionView.indexPathsForVisibleItems {
            let red = tags.tagButton(at: indexPath)?.layer.backgroundColor == UIColor.red.cgColor
            XCTAssertEqual(red, indexPath.item == 0, "\(indexPath)")
        }
    }
}
