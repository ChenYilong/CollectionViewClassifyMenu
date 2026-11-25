//
//  CYLTagListSectionStyleTests.swift
//  CYLMenuExampleTests
//
//  CYLTagListView: the section style (docs/tag-section-style.md): the card (`insetGrouped`), the header band and the header divider,
//  independent options; the column that narrows the tags; light and dark mode with no app code; the configuration keys.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
import CYLAnimatedItem
@testable import CYLMenuExample

final class CYLTagListSectionStyleTests: CYLMenuExampleTestCase {

    private let width: CGFloat = 320

    override func tearDown() {
        CYLAnimatedItemView.liquidGlassActiveOverride = nil
        super.tearDown()
    }

    private func shown(_ source: CYLExampleMenuSource, width: CGFloat? = nil,
                       configure: (CYLMenuStyle) -> Void) -> CYLTagListView {
        let view = showTagList(source, width: width ?? self.width)
        let style = CYLMenuStyle()
        configure(style)
        view.style = style
        view.layoutIfNeeded()
        view.probe.layOut()
        return view
    }

    private func cardAttributes(_ view: CYLTagListView, section: Int) -> UICollectionViewLayoutAttributes? {
        view.probe.collectionView.collectionViewLayout.layoutAttributesForDecorationView(
            ofKind: "CYLTagListSectionCard", at: ip(0, section))
    }

    private func cardViews(_ view: CYLTagListView) -> [UICollectionReusableView] {
        view.probe.collectionView.layoutIfNeeded()
        return view.probe.collectionView.subviews.compactMap { $0 as? UICollectionReusableView }
            .filter { NSStringFromClass(type(of: $0)).contains("CYLTagListCardView") }
    }

    private func resolved(_ color: UIColor?, _ style: UIUserInterfaceStyle) -> UIColor? {
        color?.resolvedColor(with: UITraitCollection(userInterfaceStyle: style))
    }

    // MARK: Card

    func testPlainStyleDrawsNoCardBandOrDivider() {
        let source = CYLMenuFixtures.source(itemCount: 6, sections: 2)
        let view = shown(source) { _ in }
        XCTAssertEqual(view.style.sectionStyle, .plain)
        XCTAssertEqual(view.style.headerSeparatorStyle, .none)
        XCTAssertNil(view.style.headerBackgroundColor)
        XCTAssertNil(cardAttributes(view, section: 0))
        XCTAssertTrue(cardViews(view).isEmpty)
        let header = view.probe.header(inSection: 0)
        XCTAssertEqual(header?.value(forKey: "bandView") as? UIView, header?.value(forKey: "bandView") as? UIView)
        XCTAssertTrue((header?.value(forKey: "bandView") as? UIView)?.isHidden ?? false)
        XCTAssertTrue((header?.value(forKey: "separatorView") as? UIView)?.isHidden ?? false)
        withExtendedLifetime(source) {}
    }

    func testCardContainsEveryTagFrameAndSpansTheColumn() {
        let source = CYLMenuFixtures.source(itemCount: 14, sections: 3)
        let view = shown(source) { $0.sectionStyle = .insetGrouped }
        let tags = view.probe
        let padding = CYLSectionStyleMetrics.cardPadding
        let column = view.contentColumn(inSection: 0)
        XCTAssertEqual(column.minX, 16, accuracy: 0.01)
        XCTAssertEqual(column.width, width - 32, accuracy: 0.01)
        for section in 0..<3 {
            guard let card = cardAttributes(view, section: section)?.frame else {
                XCTFail("section \(section) has no card")
                continue
            }
            XCTAssertEqual(card.minX, column.minX, accuracy: 0.01)
            XCTAssertEqual(card.width, column.width, accuracy: 0.01)
            var top = CGFloat.infinity, bottom = -CGFloat.infinity
            for item in 0..<tags.numberOfItems(inSection: section) {
                let frame = tags.itemFrame(at: ip(item, section))!
                XCTAssertTrue(card.insetBy(dx: padding - 0.5, dy: padding - 0.5).contains(frame),
                              "The card holds the tag \(item) of section \(section) with the padding")
                top = min(top, frame.minY)
                bottom = max(bottom, frame.maxY)
            }
            XCTAssertEqual(card.minY, top - padding, accuracy: 0.5)
            XCTAssertEqual(card.maxY, bottom + padding, accuracy: 0.5)
            let header = tags.collectionView.collectionViewLayout.layoutAttributesForSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader, at: ip(0, section))?.frame
            XCTAssertLessThanOrEqual(header?.maxY ?? .infinity, card.minY, "The header sits above the card")
        }
        XCTAssertGreaterThanOrEqual(cardViews(view).count, 1)
        let color = cardViews(view).first?.backgroundColor
        XCTAssertEqual(resolved(color, .light), resolved(UIColor.secondarySystemGroupedBackground, .light))
        XCTAssertEqual(cardViews(view).first?.layer.cornerRadius ?? 0, CYLSectionStyleMetrics.cardCornerRadius, accuracy: 0.01)
        captureScreen(named: "test-section-style-card")
        withExtendedLifetime(source) {}
    }

    func testCardNarrowsTheTagColumnAndAddsItsPadding() {
        let source = CYLMenuFixtures.source(itemCount: 12, sections: 2)
        let plain = shown(source) { _ in }
        let plainHeight = plain.contentHeight
        let plainRows = plain.numberOfRows(inSection: 0)
        closeHostWindow()
        let grouped = shown(source) { $0.sectionStyle = .insetGrouped }
        let padding = CYLSectionStyleMetrics.cardPadding
        let column = grouped.contentColumn(inSection: 0)
        let tagColumn = grouped.tagColumn(inSection: 0)
        XCTAssertEqual(tagColumn.minX, column.minX + padding, accuracy: 0.01)
        XCTAssertEqual(tagColumn.width, column.width - 2 * padding, accuracy: 0.01)
        grouped.assertItemsFit()
        let maxX = grouped.probe.itemFrame(at: ip(0, 0)).map { _ in width - 16 - padding + 0.5 } ?? 0
        for item in 0..<grouped.probe.numberOfItems(inSection: 0) {
            let frame = grouped.probe.itemFrame(at: ip(item, 0))!
            XCTAssertLessThanOrEqual(frame.maxX, maxX, "Rows are counted at the reduced width")
            XCTAssertGreaterThanOrEqual(frame.minX, tagColumn.minX - 0.01)
        }
        XCTAssertGreaterThanOrEqual(grouped.numberOfRows(inSection: 0), plainRows)
        XCTAssertGreaterThanOrEqual(grouped.contentHeight, plainHeight + 4 * padding - 0.5, "Two sections add their padding")
        XCTAssertEqual(grouped.contentHeight, grouped.heightThatFitsWidth(width), accuracy: 1)
        withExtendedLifetime(source) {}
    }

    func testFoldDecisionsUseTheCardColumn() {
        // Some count of tags fits in two rows plain and needs a third row in the narrower card column.
        var found = false
        for count in 4...30 where !found {
            let source = CYLMenuFixtures.source(itemCount: count, sections: 1)
            let plain = shown(source, width: 350) { $0.sectionStyle = .plain }
            plain.defaultVisibleRows = 2
            plain.foldStyle = .footerChevron
            plain.layoutIfNeeded()
            let plainCanFold = plain.canFoldSection(0), plainRows = plain.numberOfRows(inSection: 0)
            closeHostWindow()
            let grouped = shown(source, width: 350) { $0.sectionStyle = .insetGrouped }
            grouped.defaultVisibleRows = 2
            grouped.foldStyle = .footerChevron
            grouped.layoutIfNeeded()
            if !plainCanFold && grouped.canFoldSection(0) {
                found = true
                XCTAssertEqual(plainRows, 2)
                XCTAssertEqual(grouped.numberOfRows(inSection: 0), 3)
                XCTAssertLessThan(grouped.numberOfVisibleItems(inSection: 0), count)
                XCTAssertEqual(grouped.contentHeight, grouped.heightThatFitsWidth(350), accuracy: 1)
                grouped.setExpanded(true, forSection: 0, animated: false)
                XCTAssertEqual(grouped.contentHeight, grouped.heightThatFitsWidth(350), accuracy: 1)
                XCTAssertEqual(grouped.probe.numberOfItems(inSection: 0), count)
            }
            closeHostWindow()
            withExtendedLifetime(source) {}
        }
        XCTAssertTrue(found, "A list that does not fold plain folds in the card column")
    }

    func testHeaderTitleAlignsWithTheTagsInsideTheCard() {
        let source = CYLMenuFixtures.source(itemCount: 6, sections: 1)
        let plain = shown(source) { _ in }
        let plainX = plain.probe.headerTitleFrame(inSection: 0)?.minX ?? 0
        closeHostWindow()
        let grouped = shown(source) { $0.sectionStyle = .insetGrouped }
        let groupedX = grouped.probe.headerTitleFrame(inSection: 0)?.minX ?? 0
        XCTAssertEqual(groupedX - plainX, CYLSectionStyleMetrics.cardPadding, accuracy: 0.5,
                       "The title moves in to the tags' leading edge")
        let firstTag = grouped.probe.itemFrame(at: ip(0, 0))!
        XCTAssertEqual(grouped.tagColumn(inSection: 0).minX, firstTag.minX, accuracy: 0.5)
        withExtendedLifetime(source) {}
    }

    func testRightToLeftMirrorsTheCard() {
        let source = CYLMenuFixtures.source(itemCount: 10, sections: 1)
        let view = showTagList(source, width: width)
        view.semanticContentAttribute = .forceRightToLeft
        view.probe.collectionView.semanticContentAttribute = .forceRightToLeft
        let style = CYLMenuStyle()
        style.sectionStyle = .insetGrouped
        view.style = style
        view.layoutIfNeeded()
        view.probe.layOut()
        guard let card = cardViews(view).first else { return XCTFail("no card") }
        let padding = CYLSectionStyleMetrics.cardPadding
        for item in 0..<view.probe.numberOfItems(inSection: 0) {
            guard let cell = view.probe.cell(at: ip(item, 0)) else { continue }
            XCTAssertTrue(card.frame.insetBy(dx: padding - 0.5, dy: padding - 0.5).contains(cell.frame),
                          "The card holds the tag \(item) in a right-to-left layout")
        }
        XCTAssertEqual(card.frame.minX, 16, accuracy: 0.5)
        XCTAssertEqual(card.frame.maxX, width - 16, accuracy: 0.5)
        withExtendedLifetime(source) {}
    }

    // MARK: Header band

    func testHeaderBandSpansTheColumnAndInsetsAPlainTitle() {
        let source = CYLMenuFixtures.source(itemCount: 4, sections: 1)
        let plain = shown(source) { _ in }
        let plainX = plain.probe.headerTitleFrame(inSection: 0)?.minX ?? 0
        let plainHeader = plain.probe.header(inSection: 0)?.frame
        closeHostWindow()
        let view = shown(source) {
            $0.headerBackgroundColor = CYLSectionStyleColors.headerBand
            $0.headerCornerRadius = 6
        }
        let header = view.probe.header(inSection: 0)!
        let band = header.value(forKey: "bandView") as! UIView
        XCTAssertFalse(band.isHidden)
        XCTAssertEqual(band.frame.minX, 16, accuracy: 0.01)
        XCTAssertEqual(band.frame.width, width - 32, accuracy: 0.01)
        XCTAssertEqual(band.frame.height, header.bounds.height, accuracy: 0.01)
        XCTAssertEqual(band.layer.cornerRadius, 6, accuracy: 0.01)
        XCTAssertEqual(header.frame, plainHeader, "The band adds no height")
        let x = view.probe.headerTitleFrame(inSection: 0)?.minX ?? 0
        XCTAssertEqual(x - plainX, 16 + CYLSectionStyleMetrics.headerBandPadding - 16, accuracy: 0.5,
                       "The title is the band's leading edge plus headerContentInsets.left")
        XCTAssertEqual(view.style.sectionStyle, .plain, "The band does not need the card")
        XCTAssertNil(cardAttributes(view, section: 0))
        captureScreen(named: "test-section-style-header-band")
        withExtendedLifetime(source) {}
    }

    // MARK: Header divider

    func testHeaderDividerIsTheColumnWideHairlineAtTheHeaderBottom() {
        let source = CYLMenuFixtures.source(itemCount: 4, sections: 2)
        let plain = shown(source) { _ in }
        let plainHeaders = (0..<2).map { plain.probe.header(inSection: $0)?.frame }
        let plainHeight = plain.contentHeight
        closeHostWindow()
        let view = shown(source) { $0.headerSeparatorStyle = .line }
        for section in 0..<2 {
            let header = view.probe.header(inSection: section)!
            let line = header.value(forKey: "separatorView") as! UIView
            XCTAssertFalse(line.isHidden)
            XCTAssertEqual(line.frame.minX, 16, accuracy: 0.01, "The column's leading edge, not the title's x")
            XCTAssertEqual(line.frame.maxX, width - 16, accuracy: 0.01)
            XCTAssertEqual(line.frame.height, CYLSectionStyleMetrics.separatorThickness, accuracy: 0.01)
            XCTAssertEqual(line.frame.maxY, header.bounds.height, accuracy: 0.01)
            XCTAssertEqual(header.frame, plainHeaders[section], "The divider adds no height")
        }
        XCTAssertEqual(view.contentHeight, plainHeight, accuracy: 0.01)
        XCTAssertEqual(resolved(view.style.resolvedHeaderSeparatorColor, .light), resolved(UIColor.separator, .light))

        let inset = shown(source) {
            $0.headerSeparatorStyle = .line
            $0.headerSeparatorInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 4)
            $0.headerSeparatorThickness = 2
            $0.headerSeparatorColor = .systemRed
        }
        let line = inset.probe.header(inSection: 0)?.value(forKey: "separatorView") as! UIView
        XCTAssertEqual(line.frame.minX, 24, accuracy: 0.01)
        XCTAssertEqual(line.frame.maxX, width - 20, accuracy: 0.01)
        XCTAssertEqual(line.frame.height, 2, accuracy: 0.01)
        XCTAssertEqual(line.backgroundColor, .systemRed)
        withExtendedLifetime(source) {}
    }

    func testTheOptionsCombineFreely() {
        let source = CYLMenuFixtures.source(itemCount: 8, sections: 2)
        let view = shown(source) {
            $0.sectionStyle = .insetGrouped
            $0.headerBackgroundColor = CYLSectionStyleColors.headerBand
            $0.headerSeparatorStyle = .line
        }
        XCTAssertEqual(cardViews(view).count, 2)
        let header = view.probe.header(inSection: 0)!
        XCTAssertFalse((header.value(forKey: "bandView") as! UIView).isHidden)
        XCTAssertFalse((header.value(forKey: "separatorView") as! UIView).isHidden)
        XCTAssertEqual(view.contentHeight, view.heightThatFitsWidth(width), accuracy: 1)
        captureScreen(named: "test-section-style-combined")
        withExtendedLifetime(source) {}
    }

    // MARK: Light and dark mode

    func testUnsetColorsResolveDifferentlyInLightAndDark() {
        let colors: [(String, UIColor)] = [("card", CYLSectionStyleColors.card), ("band", CYLSectionStyleColors.headerBand),
                                           ("grouped", CYLSectionStyleColors.groupedBackground),
                                           ("separator", CYLSectionStyleColors.separator)]
        for (name, color) in colors {
            XCTAssertNotEqual(resolved(color, .light), resolved(color, .dark), "\(name) follows the mode")
        }
        let band = CYLColorComponents(resolved(CYLSectionStyleColors.headerBand, .light))
        XCTAssertEqual(band.red, 0xEF / 255.0, accuracy: 0.003)
        XCTAssertEqual(band.blue, 0xF4 / 255.0, accuracy: 0.003)
        let style = CYLMenuStyle()
        XCTAssertEqual(resolved(style.resolvedSectionBackgroundColor, .dark), resolved(UIColor.secondarySystemGroupedBackground, .dark))
        XCTAssertEqual(resolved(style.resolvedHeaderSeparatorColor, .dark), resolved(UIColor.separator, .dark))
        // A color the app sets wins in both modes.
        style.sectionBackgroundColor = .systemPink
        style.headerSeparatorColor = .systemTeal
        XCTAssertEqual(resolved(style.resolvedSectionBackgroundColor, .light), resolved(.systemPink, .light))
        XCTAssertEqual(resolved(style.resolvedSectionBackgroundColor, .dark), resolved(.systemPink, .dark))
        XCTAssertEqual(style.resolvedHeaderSeparatorColor, .systemTeal)
    }

    func testListBackgroundIsGroupedOnlyWhenTheAppNeverSetIt() {
        let style = CYLMenuStyle()
        XCTAssertEqual(style.resolvedBackgroundColor, .white)
        style.sectionStyle = .insetGrouped
        XCTAssertEqual(style.resolvedBackgroundColor, UIColor.systemGroupedBackground)
        XCTAssertEqual((style.copy() as! CYLMenuStyle).resolvedBackgroundColor, UIColor.systemGroupedBackground)
        style.backgroundColor = .systemYellow
        XCTAssertEqual(style.resolvedBackgroundColor, .systemYellow)
        XCTAssertEqual((style.copy() as! CYLMenuStyle).resolvedBackgroundColor, .systemYellow)
        let source = CYLMenuFixtures.source(itemCount: 3, sections: 1)
        let view = shown(source) { $0.sectionStyle = .insetGrouped }
        XCTAssertEqual(view.backgroundColor, UIColor.systemGroupedBackground)
        withExtendedLifetime(source) {}
    }

    func testAShownListFollowsTheModeWithoutAppCode() {
        let source = CYLMenuFixtures.source(itemCount: 6, sections: 1)
        let view = shown(source) {
            $0.sectionStyle = .insetGrouped
            $0.headerBackgroundColor = CYLSectionStyleColors.headerBand
            $0.headerSeparatorStyle = .line
        }
        let header = view.probe.header(inSection: 0)!
        let band = header.value(forKey: "bandView") as! UIView
        let line = header.value(forKey: "separatorView") as! UIView
        let card = cardViews(view).first!
        func snapshot() -> [UIColor?] {
            [band, line, card, view].map { $0.backgroundColor?.resolvedColor(with: $0.traitCollection) }
        }
        view.overrideUserInterfaceStyle = .light
        view.layoutIfNeeded()
        let light = snapshot()
        view.overrideUserInterfaceStyle = .dark
        view.layoutIfNeeded()
        let dark = snapshot()
        for index in 0..<4 {
            XCTAssertNotNil(light[index])
            XCTAssertNotEqual(light[index], dark[index], "view \(index) changes with the mode, no reload")
        }
        captureScreen(named: "test-section-style-dark")
        withExtendedLifetime(source) {}
    }

    // MARK: Card background style (Liquid Glass)

    func testGlassCardFallsBackFlatWithIdenticalFrames() {
        let source = CYLMenuFixtures.source(itemCount: 10, sections: 2)
        let flat = shown(source) { $0.sectionStyle = .insetGrouped }
        let flatFrames = (0..<2).map { cardAttributes(flat, section: $0)?.frame }
        let flatHeight = flat.contentHeight
        closeHostWindow()

        CYLAnimatedItemView.liquidGlassActiveOverride = false
        let fallback = shown(source) {
            $0.sectionStyle = .insetGrouped
            $0.sectionBackgroundStyle = .liquidGlass
        }
        XCTAssertEqual(fallback.style.resolvedSectionBackgroundStyle, .flat)
        XCTAssertEqual((0..<2).map { cardAttributes(fallback, section: $0)?.frame }, flatFrames)
        XCTAssertEqual(fallback.contentHeight, flatHeight, accuracy: 0.01)
        let card = cardViews(fallback).first!
        XCTAssertNotNil(card.backgroundColor, "A flat card keeps its color")
        XCTAssertNil((card.value(forKey: "glassHost") as? CYLAnimatedItemView)?.itemLiquidGlassView)
        closeHostWindow()

        CYLAnimatedItemView.liquidGlassActiveOverride = true
        let glass = shown(source) {
            $0.sectionStyle = .insetGrouped
            $0.sectionBackgroundStyle = .liquidGlass
        }
        XCTAssertEqual((0..<2).map { cardAttributes(glass, section: $0)?.frame }, flatFrames, "The glass moves no frame")
        XCTAssertEqual(glass.contentHeight, flatHeight, accuracy: 0.01)
        if #available(iOS 26.0, *) {
            XCTAssertEqual(glass.style.resolvedSectionBackgroundStyle, .liquidGlass)
            let host = cardViews(glass).first?.value(forKey: "glassHost") as? CYLAnimatedItemView
            XCTAssertNotNil(host?.itemLiquidGlassView, "The card is the library's Liquid Glass")
            XCTAssertEqual(host?.itemCornerRadius, CYLSectionStyleMetrics.cardCornerRadius)
            XCTAssertNil(cardViews(glass).first?.backgroundColor)
            captureScreen(named: "test-section-style-glass-card")
        }
        withExtendedLifetime(source) {}
    }

    // MARK: Configuration and copies

    func testConfigurationKeysParse() {
        let style = CYLMenuStyle(configuration: [
            "sectionStyle": "insetGrouped", "sectionBackgroundColor": "#112233", "sectionBackgroundStyle": "liquidGlass",
            "sectionCornerRadius": 14, "sectionContentInsets": [1, 2, 3, 4],
            "headerBackgroundColor": "#EFEFF4", "headerCornerRadius": 5, "headerContentInsets": [0, 9, 0, 8],
            "headerSeparatorStyle": "line", "headerSeparatorColor": "#445566", "headerSeparatorThickness": 1,
            "headerSeparatorInsets": [0, 6, 0, 7],
        ])
        XCTAssertEqual(style.sectionStyle, .insetGrouped)
        XCTAssertEqual(CYLColorComponents(style.sectionBackgroundColor), CYLColorComponents(UIColor(red: 0x11 / 255, green: 0x22 / 255, blue: 0x33 / 255, alpha: 1)))
        XCTAssertEqual(style.sectionBackgroundStyle, .liquidGlass)
        XCTAssertEqual(style.sectionCornerRadius, 14)
        XCTAssertEqual(style.sectionContentInsets, UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4))
        XCTAssertNotNil(style.headerBackgroundColor)
        XCTAssertEqual(style.headerCornerRadius, 5)
        XCTAssertEqual(style.headerContentInsets, UIEdgeInsets(top: 0, left: 9, bottom: 0, right: 8))
        XCTAssertEqual(style.headerSeparatorStyle, .line)
        XCTAssertNotNil(style.headerSeparatorColor)
        XCTAssertEqual(style.headerSeparatorThickness, 1)
        XCTAssertEqual(style.headerSeparatorInsets, UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 7))

        // The opt-out keys, and a null color that clears a set one.
        style.applyConfiguration(["sectionStyle": "plain", "headerSeparatorStyle": "none", "sectionBackgroundStyle": "flat",
                                  "sectionBackgroundColor": NSNull()])
        XCTAssertEqual(style.sectionStyle, .plain)
        XCTAssertEqual(style.headerSeparatorStyle, .none)
        XCTAssertEqual(style.sectionBackgroundStyle, .flat)
        XCTAssertNil(style.sectionBackgroundColor)
        let defaults = CYLMenuStyle()
        XCTAssertEqual(defaults.sectionCornerRadius, 10)
        XCTAssertEqual(defaults.sectionContentInsets, UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
        XCTAssertEqual(defaults.headerSeparatorThickness, 0.5)
        XCTAssertEqual(defaults.headerSeparatorInsets, .zero)
        XCTAssertEqual(defaults.headerCornerRadius, 0)
    }

    func testACopyKeepsEverySectionOption() {
        let style = CYLMenuStyle()
        style.sectionStyle = .insetGrouped
        style.sectionBackgroundColor = .systemPink
        style.sectionBackgroundStyle = .liquidGlass
        style.sectionCornerRadius = 3
        style.sectionContentInsets = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
        style.headerBackgroundColor = .systemBlue
        style.headerCornerRadius = 4
        style.headerContentInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 6)
        style.headerSeparatorStyle = .line
        style.headerSeparatorColor = .systemGreen
        style.headerSeparatorThickness = 3
        style.headerSeparatorInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 8)
        let copy = style.copy() as! CYLMenuStyle
        XCTAssertEqual(copy.sectionStyle, .insetGrouped)
        XCTAssertEqual(copy.sectionBackgroundColor, .systemPink)
        XCTAssertEqual(copy.sectionBackgroundStyle, .liquidGlass)
        XCTAssertEqual(copy.sectionCornerRadius, 3)
        XCTAssertEqual(copy.sectionContentInsets, style.sectionContentInsets)
        XCTAssertEqual(copy.headerBackgroundColor, .systemBlue)
        XCTAssertEqual(copy.headerCornerRadius, 4)
        XCTAssertEqual(copy.headerContentInsets, style.headerContentInsets)
        XCTAssertEqual(copy.headerSeparatorStyle, .line)
        XCTAssertEqual(copy.headerSeparatorColor, .systemGreen)
        XCTAssertEqual(copy.headerSeparatorThickness, 3)
        XCTAssertEqual(copy.headerSeparatorInsets, style.headerSeparatorInsets)
    }
}
