//
//  CYLTagListHeaderRoomTests.swift
//  CYLMenuExampleTests
//
//  CYLTagListView: the room inside a section header (docs/tag-section-style.md): the inner width between the header insets, one spacing
//  between adjacent views, the fold control capped at 0.4 of the inner width (0.3 next to More / clear / an accessory view) and
//  the same width collapsed and expanded, an accessory view at most 0.3, and only the title shrinks and wraps.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

private final class CYLRoomSource: NSObject, CYLMenuDataSource {
    var title = "Recent searches that go on and on and on"
    var more = false
    var clear = false
    var accessory: UIView?
    func numberOfSectionsInMenu() -> Int { 1 }
    func menuNumberOfItems(inSection section: Int) -> Int { 24 }
    func menuTitle(forSection section: Int) -> String { title }
    func menuTitleForItem(at indexPath: IndexPath) -> String { "Tag \(indexPath.item)" }
    func menuShowsMoreButton(inSection section: Int) -> Bool { more }
    func menuShowsClearButton(forSection section: Int) -> Bool { clear }
    func menuAccessoryView(forSection section: Int) -> UIView? { accessory }
}

final class CYLTagListHeaderRoomTests: CYLMenuExampleTestCase {

    private let width: CGFloat = 320

    private struct Shot {
        var height: CGFloat
        var title: CGRect
        var fold: CGRect?
        var header: CGRect
    }

    private func shot(_ source: CYLRoomSource, folds: Bool, expanded: Bool = false, maxLines: Int? = nil,
                      rightToLeft: Bool = false) -> Shot {
        let view = CYLTagListView(frame: .zero)
        view.menuDataSource = source
        view.showsSectionHeaders = true
        show(view, size: CGSize(width: width, height: 700))
        view.reloadMenuData()
        view.layoutIfNeeded()
        if rightToLeft {
            view.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
            view.probe.collectionView.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        }
        let style = CYLMenuStyle()
        if let maxLines {
            style.headerMaxLines = maxLines
        }
        view.style = style
        if folds {
            view.defaultVisibleRows = 1
            view.foldControl = CYLMenuFoldControl(configuration: ["position": "headerTrailing", "content": "titleAndIconAlways"])!
        }
        view.reloadMenuData()
        if folds && expanded {
            view.probe.headerFoldButton(inSection: 0)?.sendActions(for: .touchUpInside)
        }
        view.layoutIfNeeded()
        view.probe.layOut()
        let header = view.probe.header(inSection: 0)!
        header.layoutIfNeeded()
        let result = Shot(height: header.frame.height, title: view.probe.headerTitleFrame(inSection: 0)!,
                          fold: view.probe.headerFoldButton(inSection: 0).map { header.convert($0.bounds, from: $0) },
                          header: header.bounds)
        closeHostWindow()
        withExtendedLifetime(source) {}
        return result
    }

    private func accessory(width: CGFloat) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 20))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                              multiplier: 1, constant: width))
        return view
    }

    func testNoFoldTheTitleTakesTheInnerWidth() {
        let result = shot(CYLRoomSource(), folds: false)
        XCTAssertNil(result.fold)
        XCTAssertGreaterThan(result.title.width, width - 80)
        XCTAssertLessThanOrEqual(result.title.maxX, result.header.maxX)
    }

    func testFoldOnlyIsCappedAtFortyPercentOfTheInnerWidthAndTheTitleKeepsTheRest() throws {
        let result = shot(CYLRoomSource(), folds: true)
        let fold = try XCTUnwrap(result.fold)
        let inner = result.header.width - (result.title.minX * 2)
        XCTAssertLessThanOrEqual(fold.width, inner * 0.4 + 0.5)
        XCTAssertLessThanOrEqual(result.title.maxX, fold.minX + 0.5, "The title never overlaps the fold control")
        XCTAssertGreaterThan(result.title.width, 0)
    }

    func testFoldWithMoreClearAndAccessoryAllFitAndOnlyTheTitleShrinks() throws {
        let source = CYLRoomSource()
        source.more = true
        source.clear = true
        source.accessory = accessory(width: 200)
        let result = shot(source, folds: true)
        let fold = try XCTUnwrap(result.fold)
        let inner = result.header.width - (result.title.minX * 2)
        XCTAssertLessThanOrEqual(fold.width, inner * 0.3 + 0.5, "0.3 when shared")
        XCTAssertGreaterThan(fold.width, 20, "The fold control gets room")
        XCTAssertLessThanOrEqual(result.title.maxX, fold.minX + 0.5)
        XCTAssertLessThanOrEqual(fold.maxX, result.header.maxX + 0.5)
        XCTAssertGreaterThan(result.title.width, 0)
    }

    func testCollapsedAndExpandedFoldControlsHaveTheSameRoom() throws {
        let collapsed = shot(CYLRoomSource(), folds: true, expanded: false)
        let expanded = shot(CYLRoomSource(), folds: true, expanded: true)
        XCTAssertEqual(try XCTUnwrap(collapsed.fold).width, try XCTUnwrap(expanded.fold).width, accuracy: 0.5)
        XCTAssertEqual(collapsed.title.width, expanded.title.width, accuracy: 0.5)
    }

    func testMaxLinesGrowTheHeaderWithTheSameRoomTheLayoutUses() {
        let source = CYLRoomSource()
        source.title = String(repeating: "A long section title ", count: 8)
        let one = shot(source, folds: true, maxLines: 1)
        let two = shot(source, folds: true, maxLines: 2)
        let unlimited = shot(source, folds: true, maxLines: CYLHeaderTitleMaxLines.unlimited)
        XCTAssertGreaterThan(two.height, one.height)
        XCTAssertGreaterThanOrEqual(unlimited.height, two.height)
        XCTAssertGreaterThanOrEqual(unlimited.title.height + 8, unlimited.height - 1, "No line is cut: the height fits the wrapped title")
    }

    func testRightToLeftMirrorsTheRoom() throws {
        let ltr = shot(CYLRoomSource(), folds: true)
        let rtl = shot(CYLRoomSource(), folds: true, rightToLeft: true)
        XCTAssertEqual(try XCTUnwrap(rtl.fold).width, try XCTUnwrap(ltr.fold).width, accuracy: 0.5)
        XCTAssertEqual(rtl.title.width, ltr.title.width, accuracy: 0.5)
        XCTAssertGreaterThan(rtl.title.midX, try XCTUnwrap(rtl.fold).midX, "Right to left: the fold control at the left")
    }

    func testTheDefaultShortTitleHeaderIsUnchanged() {
        let source = CYLRoomSource()
        source.title = "Recent"
        let result = shot(source, folds: false)
        XCTAssertEqual(result.height, ceil(CYLMenuStyle().headerFont.lineHeight) + CYLSectionStyleMetrics.headerBoardTitlePadding,
                       accuracy: 0.5)
    }
}
