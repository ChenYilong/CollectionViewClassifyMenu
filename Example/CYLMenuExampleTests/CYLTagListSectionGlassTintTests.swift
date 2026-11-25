//
//  CYLTagListSectionGlassTintTests.swift
//  CYLMenuExampleTests
//
//  CYLTagListView: the section glass card (`sectionBackgroundStyle = .liquidGlass`) is the same glass as a tag (`CYLAnimatedItemView`;
//  an unset `sectionBackgroundColor` takes the tags' low-alpha default tint); a set color tints it (docs/tag-section-style.md).
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
import CYLAnimatedItem
@testable import CYLMenuExample

final class CYLTagListSectionGlassTintTests: CYLMenuExampleTestCase {

    override func tearDown() {
        CYLAnimatedItemView.liquidGlassActiveOverride = nil
        super.tearDown()
    }

    private func glassCard(color: UIColor?) -> UICollectionReusableView? {
        let source = CYLMenuFixtures.source(itemCount: 6, sections: 1)
        let view = showTagList(source, width: 320)
        let style = CYLMenuStyle()
        style.sectionBackgroundStyle = .liquidGlass
        if let color {
            style.sectionBackgroundColor = color
        }
        view.style = style
        view.layoutIfNeeded()
        view.probe.layOut()
        view.probe.collectionView.layoutIfNeeded()
        withExtendedLifetime(source) {}
        return view.probe.collectionView.subviews.compactMap { $0 as? UICollectionReusableView }
            .first { NSStringFromClass(type(of: $0)).contains("CYLTagListCardView") }
    }

    func testAnUnsetColorDrawsTheTagGlassWithTheCardCorners() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("UIGlassEffect needs iOS 26")
        }
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        let card = try XCTUnwrap(glassCard(color: nil))
        let host = try XCTUnwrap(card.value(forKey: "glassHost") as? CYLAnimatedItemView)
        XCTAssertFalse(host.isHidden)
        XCTAssertNotNil(host.itemLiquidGlassView, "The library's glass, like a tag")
        XCTAssertEqual(host.itemBackgroundColor, CYLMenuStyle.defaultGlassTint, "Unset: the same low-alpha default tint as a tag")
        XCTAssertEqual(host.itemGlassTintAlpha, 1)
        XCTAssertNil(card.backgroundColor, "No flat color behind the glass")
        XCTAssertEqual(card.layer.cornerRadius, CYLSectionStyleMetrics.cardCornerRadius, accuracy: 0.01)
    }

    func testASetColorStillTintsTheGlass() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("UIGlassEffect needs iOS 26")
        }
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        let card = try XCTUnwrap(glassCard(color: .systemPink))
        let host = try XCTUnwrap(card.value(forKey: "glassHost") as? CYLAnimatedItemView)
        XCTAssertFalse(host.isHidden)
        XCTAssertNotNil(host.itemLiquidGlassView, "The library's glass, tinted")
        XCTAssertEqual(host.itemBackgroundColor, .systemPink)
    }

    func testTheFlatCardKeepsItsColorWhereGlassIsInactive() throws {
        CYLAnimatedItemView.liquidGlassActiveOverride = false
        let card = try XCTUnwrap(glassCard(color: nil))
        XCTAssertNotNil(card.backgroundColor, "Flat fallback")
    }
}
