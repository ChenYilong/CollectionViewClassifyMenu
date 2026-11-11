//
//  CYLTagListFoldingTests.swift
//  CYLMenuExampleTests
//
//  CYLTagListView: fold styles (footer chevron, truncate, header button, inline fold cell), heights and reloads.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLTagListFoldingTests: CYLMenuExampleTestCase {

    func testFooterChevronFoldsAndReportsHeight() {
        let source = CYLMenuFixtures.source(itemCount: 30, sections: 1)
        let view = showTagList(source, width: 320)
        let delegate = CYLRecordingMenuDelegate()
        view.menuDelegate = delegate
        view.showsSectionHeaders = false
        view.defaultVisibleRows = 2
        view.foldStyle = .footerChevron
        view.layoutIfNeeded()
        let tags = view.probe

        XCTAssertTrue(view.canFoldSection(0))
        XCTAssertGreaterThan(view.numberOfRows(inSection: 0), 2)
        let collapsed = tags.numberOfItems(inSection: 0)
        XCTAssertLessThan(collapsed, 30)
        XCTAssertEqual(collapsed, view.numberOfVisibleItems(inSection: 0))
        let collapsedHeight = view.contentHeight
        XCTAssertEqual(collapsedHeight, view.heightThatFitsWidth(320), accuracy: 1)
        XCTAssertEqual(view.intrinsicContentSize.height, collapsedHeight, accuracy: 0.5)
        XCTAssertNotNil(tags.footer(inSection: 0))
        captureScreen(named: "test-fold-footer-chevron-folded")

        view.setExpanded(true, forSection: 0, animated: false)
        XCTAssertTrue(view.isSectionExpanded(0))
        XCTAssertEqual(tags.numberOfItems(inSection: 0), 30)
        XCTAssertGreaterThan(view.contentHeight, collapsedHeight)
        XCTAssertEqual(view.contentHeight, view.heightThatFitsWidth(320), accuracy: 1)
        XCTAssertEqual(delegate.lastHeight, view.contentHeight, accuracy: 0.5)
        view.assertItemsFit()
        captureScreen(named: "test-fold-footer-chevron-expanded")

        view.setExpanded(false, forSection: 0, animated: false)
        XCTAssertEqual(tags.numberOfItems(inSection: 0), collapsed)
        XCTAssertEqual(delegate.events, ["expand 0", "collapse 0"])
    }

    func testTruncateStyleShowsRowsWithoutControls() {
        let source = CYLMenuFixtures.source(itemCount: 30, sections: 1)
        let view = showTagList(source, width: 320)
        view.showsSectionHeaders = false
        view.defaultVisibleRows = 2
        view.foldStyle = .truncate
        view.layoutIfNeeded()
        let tags = view.probe
        XCTAssertLessThan(tags.numberOfItems(inSection: 0), 30)
        XCTAssertNil(tags.footer(inSection: 0))
        XCTAssertNil(tags.header(inSection: 0))
    }

    func testHeaderButtonFoldsEachSectionIndependently() {
        let source = CYLMenuFixtures.source(itemCount: 20, sections: 2)
        let view = showTagList(source, width: 320)
        view.foldStyle = .headerButton
        view.defaultVisibleRows = 1
        view.layoutIfNeeded()
        let tags = view.probe
        let fold = tags.headerFoldButton(inSection: 0)
        XCTAssertNotNil(fold, "The fold control is a tag view (CYLTagFoldButton)")
        XCTAssertFalse(fold?.isHidden ?? true)
        XCTAssertEqual(fold?.title, view.style.expandTitle)
        XCTAssertEqual(view.foldControl.position, .topTrailing, "foldStyle sets foldControl")
        fold?.sendActions(for: .touchUpInside)
        XCTAssertTrue(view.isSectionExpanded(0))
        XCTAssertFalse(view.isSectionExpanded(1))
        XCTAssertEqual(tags.numberOfItems(inSection: 0), 20)
        XCTAssertLessThan(tags.numberOfItems(inSection: 1), 20)
        captureScreen(named: "test-fold-header-button")
    }

    func testReloadKeepsValidStateAndDropsStaleState() {
        let source = CYLMenuFixtures.source(itemCount: 30, sections: 2)
        let view = showTagList(source, width: 320)
        view.foldStyle = .headerButton
        view.selectedIndexPaths = [ip(1, 0), ip(20, 1)]
        view.setExpanded(true, forSection: 1, animated: false)
        source.sections = CYLMenuFixtures.source(itemCount: 5, sections: 1).sections
        view.reloadMenuData()
        XCTAssertEqual(view.selectedIndexPaths, [ip(1, 0)])
        XCTAssertFalse(view.isSectionExpanded(1))
        XCTAssertEqual(view.probe.collectionView.numberOfSections, 1)
    }

    // MARK: Inline fold cell

    func testInlineFoldCellIsTheLastTagAndTogglesTheSection() {
        let source = CYLMenuFixtures.source(itemCount: 14, sections: 1)
        let view = showTagList(source, width: 320)
        let delegate = CYLRecordingMenuDelegate()
        view.menuDelegate = delegate
        view.foldControl = CYLMenuFoldControl(position: .inline, content: .icon)
        view.defaultVisibleRows = 2
        view.reloadMenuData()
        view.layoutIfNeeded()
        let tags = view.probe
        tags.layOut()
        XCTAssertTrue(view.canFoldSection(0))
        XCTAssertFalse(view.isSectionExpanded(0))
        let visible = view.numberOfVisibleItems(inSection: 0)
        XCTAssertLessThan(visible, 14)
        // Folded: the visible tags, then the fold cell, all on the two visible rows.
        XCTAssertEqual(tags.numberOfItems(inSection: 0), visible + 1)
        let fold = tags.cell(at: ip(visible, 0))
        XCTAssertTrue(fold is CYLTagFoldCell, "The chevron is the last tag")
        XCTAssertEqual(fold?.accessibilityIdentifier, CYLTagListFoldControlAccessibilityIdentifier)
        XCTAssertTrue(fold?.accessibilityTraits.contains(.button) ?? false)
        XCTAssertEqual(fold?.accessibilityLabel, "分组 0 更多")
        XCTAssertTrue((fold as? CYLTagFoldCell)?.foldButton.foldControl?.usesDefaultImage ?? false, "The bundle's chevron")
        let rows = Set((0...visible).compactMap { tags.itemFrame(at: ip($0, 0))?.minY })
        XCTAssertEqual(rows.count, 2, "The fold cell ends the second row")
        view.assertItemsFit()
        captureScreen(named: "test-fold-inline-folded")
        // A tap on it expands: every tag, then the fold cell again.
        tags.tap(item: visible, section: 0)
        tags.layOut()
        XCTAssertTrue(view.isSectionExpanded(0))
        XCTAssertEqual(view.numberOfVisibleItems(inSection: 0), 14)
        XCTAssertEqual(tags.numberOfItems(inSection: 0), 15)
        XCTAssertTrue(tags.cell(at: ip(14, 0)) is CYLTagFoldCell)
        XCTAssertEqual(tags.cell(at: ip(14, 0))?.accessibilityLabel, "分组 0 收起")
        XCTAssertEqual(delegate.events, ["expand 0"], "The tap toggles the section, it selects no tag")
        view.assertItemsFit()
        captureScreen(named: "test-fold-inline-expanded")
        // And collapses again.
        tags.tap(item: 14, section: 0)
        XCTAssertFalse(view.isSectionExpanded(0))
        XCTAssertEqual(tags.numberOfItems(inSection: 0), visible + 1)
        XCTAssertEqual(delegate.events, ["expand 0", "collapse 0"])
        withExtendedLifetime(source) {}
    }

    func testInlineFoldCellIsHiddenWhenEverythingFits() {
        let source = CYLMenuFixtures.source(itemCount: 2, sections: 1)
        let view = showTagList(source, width: 390)
        view.foldControl = CYLMenuFoldControl(position: .inline, content: .icon)
        view.defaultVisibleRows = 2
        view.reloadMenuData()
        view.layoutIfNeeded()
        XCTAssertFalse(view.canFoldSection(0))
        XCTAssertEqual(view.probe.numberOfItems(inSection: 0), 2, "No fold cell")
        withExtendedLifetime(source) {}
    }
}
