//
//  CYLTagListHeaderMaxLinesTests.swift
//  CYLMenuExampleTests
//
//  CYLMenuStyle.headerMaxLines: the most lines a section header's title may take. 1 (default) leaves the header frames as they
//  were; more lines (or `CYLHeaderTitleMaxLines.unlimited`) grow the header for a long title, measured at the room left of the
//  fold control, plus 12 pt.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLTagListHeaderMaxLinesTests: CYLMenuExampleTestCase {

    private let longTitle = "A very long section title that cannot fit on one line of a narrow phone screen, so it needs to wrap onto several lines"

    private func headerHeight(maxLines: Int?, title: String? = nil, rightToLeft: Bool = false,
                              folds: Bool = false) -> (height: CGFloat, lines: Int, title: CGRect, fold: CGRect?, width: CGFloat) {
        let source = CYLMenuFixtures.source(itemCount: 30, sections: 1)
        source.sections[0].title = title ?? longTitle
        let view = showTagList(source, width: 320)
        if rightToLeft {
            view.semanticContentAttribute = .forceRightToLeft
            view.probe.collectionView.semanticContentAttribute = .forceRightToLeft
        }
        let style = CYLMenuStyle()
        if let maxLines {
            style.headerMaxLines = maxLines
        }
        view.style = style
        if folds {
            view.defaultVisibleRows = 1
            view.foldStyle = .headerButton
        }
        view.reloadMenuData()
        view.layoutIfNeeded()
        view.probe.layOut()
        let header = view.probe.header(inSection: 0)!
        header.layoutIfNeeded()
        let label = view.probe.headerTitleLabel(inSection: 0)!
        let fold = view.probe.headerFoldButton(inSection: 0).map { header.convert($0.bounds, from: $0) }
        let lines = Int((label.bounds.height / label.font.lineHeight).rounded())
        let result = (header.frame.height, lines, view.probe.headerTitleFrame(inSection: 0)!, fold, header.bounds.width)
        closeHostWindow()
        withExtendedLifetime(source) {}
        return result
    }

    func testDefaultIsOneLineAndTheHeaderFramesAreUnchanged() {
        XCTAssertEqual(CYLMenuStyle().headerMaxLines, CYLHeaderTitleMaxLines.single)
        XCTAssertEqual(CYLHeaderTitleMaxLines.single, 1)
        let byDefault = headerHeight(maxLines: nil)
        let explicit = headerHeight(maxLines: CYLHeaderTitleMaxLines.single)
        XCTAssertEqual(byDefault.height, explicit.height)
        XCTAssertEqual(byDefault.height, CYLMenuStyle().headerHeight, accuracy: 0.5, "a long title stays one truncated line in 36 pt")
        XCTAssertEqual(byDefault.title, explicit.title)
        XCTAssertEqual(byDefault.lines, 1)
    }

    func testThreeLinesGrowTheHeader() {
        let one = headerHeight(maxLines: 1)
        let three = headerHeight(maxLines: 3)
        XCTAssertGreaterThan(three.height, one.height)
        XCTAssertEqual(three.lines, 3, "the title takes three lines and is cut there")
        let lineHeight = UIFont.systemFont(ofSize: 14).lineHeight
        XCTAssertEqual(three.height, ceil(lineHeight * 3) + 12, accuracy: 3, "the title's height plus 12 pt")
    }

    func testUnlimitedGrowsForALongTitleAndNeverBelowTheOldHeight() {
        let title = longTitle + ". " + longTitle
        let unlimited = headerHeight(maxLines: CYLHeaderTitleMaxLines.unlimited, title: title)
        let three = headerHeight(maxLines: 3, title: title)
        XCTAssertGreaterThan(unlimited.height, three.height)
        XCTAssertGreaterThan(unlimited.lines, 3)
        let short = headerHeight(maxLines: CYLHeaderTitleMaxLines.unlimited, title: "Short")
        XCTAssertEqual(short.height, CYLMenuStyle().headerHeight, accuracy: 0.5, "a title that fits keeps the old height")
        XCTAssertEqual(short.lines, 1)
    }

    func testTheTitleIsMeasuredLeftOfTheFoldControl() {
        let result = headerHeight(maxLines: CYLHeaderTitleMaxLines.unlimited, folds: true)
        XCTAssertNotNil(result.fold)
        XCTAssertLessThanOrEqual(result.title.maxX, result.fold?.minX ?? 0)
        let noFold = headerHeight(maxLines: CYLHeaderTitleMaxLines.unlimited)
        XCTAssertGreaterThanOrEqual(result.height, noFold.height, "less room: as many lines or more")
        // The label's own height fills the header less the 12 pt of padding: no line is cut.
        XCTAssertGreaterThanOrEqual(result.title.height + 12, result.height - 1)
    }

    func testBelowOneClampsToOne() {
        let style = CYLMenuStyle()
        style.headerMaxLines = 0
        XCTAssertEqual(style.headerMaxLines, CYLHeaderTitleMaxLines.single)
        style.headerMaxLines = -5
        XCTAssertEqual(style.headerMaxLines, CYLHeaderTitleMaxLines.single)
        XCTAssertEqual(headerHeight(maxLines: 0).height, headerHeight(maxLines: 1).height)
    }

    func testTheConfigurationKeyParsesANumberAndUnlimited() {
        XCTAssertEqual(CYLMenuStyleKey.headerMaxLines, "headerMaxLines")
        let number = CYLMenuStyle()
        number.applyConfiguration([CYLMenuStyleKey.headerMaxLines: 3])
        XCTAssertEqual(number.headerMaxLines, 3)
        let unlimited = CYLMenuStyle()
        unlimited.applyConfiguration([CYLMenuStyleKey.headerMaxLines: "unlimited"])
        XCTAssertEqual(unlimited.headerMaxLines, CYLHeaderTitleMaxLines.unlimited)
        let low = CYLMenuStyle()
        low.applyConfiguration([CYLMenuStyleKey.headerMaxLines: 0])
        XCTAssertEqual(low.headerMaxLines, CYLHeaderTitleMaxLines.single)
        let absent = CYLMenuStyle()
        absent.applyConfiguration([:])
        XCTAssertEqual(absent.headerMaxLines, CYLHeaderTitleMaxLines.single)
    }

    func testCopyKeepsIt() {
        let style = CYLMenuStyle()
        style.headerMaxLines = 4
        XCTAssertEqual((style.copy() as? CYLMenuStyle)?.headerMaxLines, 4)
        style.headerMaxLines = CYLHeaderTitleMaxLines.unlimited
        XCTAssertEqual((style.copy() as? CYLMenuStyle)?.headerMaxLines, CYLHeaderTitleMaxLines.unlimited)
    }

    func testRightToLeftStillMirrorsAGrownHeader() {
        let ltr = headerHeight(maxLines: CYLHeaderTitleMaxLines.unlimited, folds: true)
        let rtl = headerHeight(maxLines: CYLHeaderTitleMaxLines.unlimited, rightToLeft: true, folds: true)
        XCTAssertEqual(rtl.height, ltr.height, accuracy: 0.5, "the same header height in both directions")
        XCTAssertEqual(rtl.title.maxX, rtl.width - ltr.title.minX, accuracy: 1)
        XCTAssertGreaterThan(rtl.title.midX, rtl.fold?.midX ?? .infinity, "right to left: the fold control at the left")
    }
}
