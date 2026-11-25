//
//  CYLTagListHeaderBoardTests.swift
//  CYLMenuExampleTests
//
//  CYLTagListView: the section header font (17 semibold), the short gap between a header and the board (insetGrouped, no divider) and
//  `sectionBoardInset` (docs/tag-section-style.md): the header title and the tags share one column, the board extends outward from it.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLTagListHeaderBoardTests: CYLMenuExampleTestCase {

    private let width: CGFloat = 320
    private let padding = CYLSectionStyleMetrics.headerBoardTitlePadding
    private let spacing = CYLSectionStyleMetrics.headerBoardSpacing

    private func shown(_ source: CYLExampleMenuSource, rightToLeft: Bool = false, foldsInHeader: Bool = false,
                       configure: (CYLMenuStyle) -> Void = { _ in }) -> CYLTagListView {
        let view = showTagList(source, width: width)
        if rightToLeft {
            view.semanticContentAttribute = .forceRightToLeft
            view.probe.collectionView.semanticContentAttribute = .forceRightToLeft
        }
        let style = CYLMenuStyle()
        configure(style)
        view.style = style
        if foldsInHeader {
            view.defaultVisibleRows = 1
            view.foldStyle = .headerButton
            view.reloadMenuData()
        }
        view.layoutIfNeeded()
        view.probe.layOut()
        return view
    }

    private func headerFrame(_ view: CYLTagListView, section: Int) -> CGRect {
        view.probe.collectionView.collectionViewLayout.layoutAttributesForSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader, at: ip(0, section))?.frame ?? .null
    }

    private func boardFrame(_ view: CYLTagListView, section: Int) -> CGRect {
        view.probe.collectionView.collectionViewLayout.layoutAttributesForDecorationView(
            ofKind: "CYLTagListSectionCard", at: ip(0, section))?.frame ?? .null
    }

    private func lineHeight(_ view: CYLTagListView) -> CGFloat {
        ceil(view.style.headerFont(for: view.traitCollection).lineHeight)
    }

    // MARK: Header font

    func testTheDefaultHeaderFontIs17Semibold() {
        XCTAssertEqual(CYLMenuStyle().headerFont, UIFont.systemFont(ofSize: 17, weight: .semibold))
        let source = CYLMenuFixtures.source(itemCount: 4, sections: 1)
        let view = shown(source)
        XCTAssertEqual(view.probe.headerTitleLabel(inSection: 0)?.font.pointSize ?? 0, 17, accuracy: 0.01)
        let set = CYLMenuStyle()
        set.headerFont = .systemFont(ofSize: 20, weight: .bold)
        XCTAssertEqual(set.headerFont, UIFont.systemFont(ofSize: 20, weight: .bold), "An app's font wins")
        withExtendedLifetime(source) {}
    }

    // MARK: Short gap between the header and the board

    func testWithoutADividerTheHeaderIsSizedToItsTextAndTheBoardStartsFourBelow() {
        let source = CYLMenuFixtures.source(itemCount: 6, sections: 2)
        let view = shown(source)
        for section in 0..<2 {
            let header = headerFrame(view, section: section)
            XCTAssertEqual(header.height, lineHeight(view) + padding, accuracy: 0.01, "The title's line height plus 8")
            XCTAssertEqual(boardFrame(view, section: section).minY, header.maxY + spacing, accuracy: 0.01,
                           "The board starts 4 below the header")
        }
        let board = boardFrame(view, section: 0)
        XCTAssertEqual(headerFrame(view, section: 1).minY, board.maxY + view.style.sectionInsets.bottom, accuracy: 0.01,
                       "The space below the board is unchanged")
        XCTAssertEqual(view.contentHeight, view.heightThatFitsWidth(width), accuracy: 1)
        withExtendedLifetime(source) {}
    }

    func testWithTheDividerAndInThePlainStyleNothingChanges() {
        let source = CYLMenuFixtures.source(itemCount: 6, sections: 2)
        let divider = shown(source) { $0.headerSeparatorStyle = .line }
        let header = headerFrame(divider, section: 0)
        XCTAssertEqual(header.height, max(CYLMenuStyle().headerHeight, lineHeight(divider) + 12), accuracy: 0.01, "The old reservation")
        XCTAssertEqual(boardFrame(divider, section: 0).minY, header.maxY + divider.style.sectionInsets.top, accuracy: 0.01,
                       "The board starts after the section's top inset")
        closeHostWindow()

        let plain = shown(source) { $0.sectionStyle = .plain }
        XCTAssertEqual(headerFrame(plain, section: 0).height, max(CYLMenuStyle().headerHeight, lineHeight(plain) + 12), accuracy: 0.01)
        XCTAssertEqual(plain.probe.itemFrame(at: ip(0, 0))?.minY ?? 0, headerFrame(plain, section: 0).maxY + plain.style.sectionInsets.top,
                       accuracy: 0.01)
        closeHostWindow()
        withExtendedLifetime(source) {}
    }

    func testAnExplicitHeaderHeightWinsAsTheMinimum() {
        let source = CYLMenuFixtures.source(itemCount: 6, sections: 1)
        let tall = shown(source) { $0.headerHeight = 44 }
        XCTAssertEqual(headerFrame(tall, section: 0).height, 44, accuracy: 0.01)
        XCTAssertEqual(boardFrame(tall, section: 0).minY, 44 + spacing, accuracy: 0.01)
        closeHostWindow()
        let same = shown(source) { $0.headerHeight = 36 }
        XCTAssertEqual(headerFrame(same, section: 0).height, 36, accuracy: 0.01, "Setting the default value still counts as set")
        closeHostWindow()
        // A copy and the configuration key keep the "was set" state.
        let copied = shown(source) { _ in }
        let style = CYLMenuStyle()
        style.headerHeight = 40
        copied.style = style.copy() as! CYLMenuStyle
        copied.layoutIfNeeded()
        copied.probe.layOut()
        XCTAssertEqual(headerFrame(copied, section: 0).height, 40, accuracy: 0.01)
        closeHostWindow()
        let configured = shown(source) { $0.applyConfiguration(["headerHeight": 50]) }
        XCTAssertEqual(headerFrame(configured, section: 0).height, 50, accuracy: 0.01)
        withExtendedLifetime(source) {}
    }

    func testTheHeaderIsNeverBelowItsFoldControl() {
        let source = CYLMenuFixtures.source(itemCount: 30, sections: 1)
        let view = shown(source, foldsInHeader: true)
        let header = headerFrame(view, section: 0)
        let fold = view.probe.headerFoldButton(inSection: 0)
        XCTAssertNotNil(fold)
        XCTAssertGreaterThanOrEqual(header.height + 0.5, fold?.bounds.height ?? .infinity)
        withExtendedLifetime(source) {}
    }

    // MARK: sectionBoardInset

    func testTheTitleAlignsWithTheTagsAndTheFoldControlEndsAtTheirTrailingEdge() {
        let source = CYLMenuFixtures.source(itemCount: 30, sections: 1)
        for style in [CYLSectionStyle.plain, .insetGrouped] {
            let view = shown(source, foldsInHeader: true) { $0.sectionStyle = style }
            let tags = view.probe
            let first = tags.itemFrame(at: ip(0, 0))!
            XCTAssertEqual(tags.headerTitleFrame(inSection: 0)?.minX ?? 0, first.minX, accuracy: 1.0, "title x == first tag x (\(style))")
            let header = tags.header(inSection: 0)!
            let fold = header.convert(tags.headerFoldButton(inSection: 0)!.bounds, from: tags.headerFoldButton(inSection: 0)!)
            // The control's own 6 pt margin lines its content up with the edge (CYLTagListHeaderView).
            XCTAssertEqual(fold.maxX - 6, view.tagColumn(inSection: 0).maxX, accuracy: 1.0, "the fold control ends at the tags' edge (\(style))")
            closeHostWindow()
        }
        withExtendedLifetime(source) {}
    }

    func testTheBoardExtendsOutwardFromTheTagColumnBySectionBoardInset() {
        let source = CYLMenuFixtures.source(itemCount: 8, sections: 1)
        let reference = shown(source)
        let tagColumn = reference.tagColumn(inSection: 0)
        let referenceFrames = (0..<8).map { reference.probe.itemFrame(at: ip($0, 0)) }
        XCTAssertNil(reference.style.sectionBoardInset, "Unset by default")
        let board = boardFrame(reference, section: 0)
        XCTAssertEqual(board.minX, tagColumn.minX - 12, accuracy: 0.01, "nil: sectionContentInsets leading, the board as today")
        XCTAssertEqual(board.maxX, tagColumn.maxX + 12, accuracy: 0.01)
        XCTAssertEqual(board.minX, 16, accuracy: 0.01)
        closeHostWindow()
        for inset: CGFloat in [0, 6, 20] {
            let view = shown(source) { $0.sectionBoardInset = inset }
            XCTAssertEqual(view.tagColumn(inSection: 0), tagColumn, "The board never changes the tag column")
            XCTAssertEqual((0..<8).map { view.probe.itemFrame(at: ip($0, 0)) }, referenceFrames, "No tag moves")
            let frame = boardFrame(view, section: 0)
            XCTAssertEqual(frame.minX, tagColumn.minX - inset, accuracy: 0.01, "inset \(inset), left")
            XCTAssertEqual(frame.maxX, tagColumn.maxX + inset, accuracy: 0.01, "inset \(inset), right: the same value")
            XCTAssertEqual(view.boardColumn(inSection: 0).minX, frame.minX, accuracy: 0.01)
            XCTAssertEqual(view.boardColumn(inSection: 0).width, frame.width, accuracy: 0.01)
            closeHostWindow()
        }
        withExtendedLifetime(source) {}
    }

    func testSectionBoardInsetOverridesTheSidesOfSectionContentInsetsButNotTopAndBottom() {
        let source = CYLMenuFixtures.source(itemCount: 8, sections: 1)
        let view = shown(source) {
            $0.sectionContentInsets = UIEdgeInsets(top: 20, left: 12, bottom: 18, right: 12)
            $0.sectionBoardInset = 0
        }
        let board = boardFrame(view, section: 0)
        let tags = view.probe
        XCTAssertEqual(board.minX, view.tagColumn(inSection: 0).minX, accuracy: 0.01, "0 hugs the tags")
        XCTAssertEqual(board.minY, tags.itemFrame(at: ip(0, 0))!.minY - 20, accuracy: 0.5, "top from sectionContentInsets")
        let last = (0..<8).compactMap { tags.itemFrame(at: ip($0, 0))?.maxY }.max() ?? 0
        XCTAssertEqual(board.maxY, last + 18, accuracy: 0.5, "bottom from sectionContentInsets")
        withExtendedLifetime(source) {}
    }

    func testTheBandAndTheDividerShareTheBoardEdges() {
        let source = CYLMenuFixtures.source(itemCount: 6, sections: 1)
        let view = shown(source) {
            $0.sectionBoardInset = 4
            $0.headerBackgroundColor = CYLSectionStyleColors.headerBand
            $0.headerSeparatorStyle = .line
        }
        let board = boardFrame(view, section: 0)
        let header = view.probe.header(inSection: 0)!
        let band = (header.value(forKey: "bandView") as! UIView).frame
        let line = (header.value(forKey: "separatorView") as! UIView).frame
        XCTAssertEqual(band.minX, board.minX, accuracy: 0.01)
        XCTAssertEqual(band.maxX, board.maxX, accuracy: 0.01)
        XCTAssertEqual(line.minX, board.minX, accuracy: 0.01)
        XCTAssertEqual(line.maxX, board.maxX, accuracy: 0.01)
        withExtendedLifetime(source) {}
    }

    func testRightToLeftMirrorsTheTitleAndTheBoard() {
        let source = CYLMenuFixtures.source(itemCount: 8, sections: 1)
        func frames(rightToLeft: Bool) -> (title: CGRect, board: CGRect) {
            let view = shown(source, rightToLeft: rightToLeft) { $0.sectionBoardInset = 4 }
            let board = view.probe.collectionView.subviews.compactMap { $0 as? UICollectionReusableView }
                .first { NSStringFromClass(type(of: $0)).contains("CYLTagListCardView") }?.frame ?? .null
            let result = (view.probe.headerTitleFrame(inSection: 0) ?? .null, board)
            closeHostWindow()
            return result
        }
        let ltr = frames(rightToLeft: false)
        let rtl = frames(rightToLeft: true)
        XCTAssertEqual(rtl.title.maxX, width - ltr.title.minX, accuracy: 1, "The title starts at the tags' leading (right) edge")
        XCTAssertEqual(rtl.board.minX, width - ltr.board.maxX, accuracy: 0.5)
        XCTAssertEqual(rtl.board.width, ltr.board.width, accuracy: 0.5)
        withExtendedLifetime(source) {}
    }

    func testTheConfigurationKeyParsesAndACopyKeepsIt() {
        XCTAssertEqual(CYLMenuStyleKey.sectionBoardInset, "sectionBoardInset")
        let style = CYLMenuStyle(configuration: ["sectionBoardInset": 5])
        XCTAssertEqual(style.sectionBoardInset, 5)
        XCTAssertEqual((style.copy() as? CYLMenuStyle)?.sectionBoardInset, 5)
        let zero = CYLMenuStyle(configuration: ["sectionBoardInset": 0])
        XCTAssertEqual(zero.sectionBoardInset, 0, "0 is a set value, not nil")
        XCTAssertNil(CYLMenuStyle(configuration: [:]).sectionBoardInset)
        XCTAssertNil((CYLMenuStyle().copy() as? CYLMenuStyle)?.sectionBoardInset)
    }
}
