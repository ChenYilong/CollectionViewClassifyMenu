//
//  CYLGlassBorderTests.swift
//  CYLMenuExampleTests
//
//  A glass tag does not carry the style's DEFAULT border: under drawn Liquid Glass a border color / width the app, a configuration or a
//  preset did not set is handed over as no border (width 0), so the shared glass rim shows; an explicit border is kept; a flat tag keeps
//  the default border exactly. The selected built-in app-tint border is dropped the same way.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
import CYLAnimatedItem
@testable import CYLMenuExample

final class CYLGlassBorderTests: XCTestCase {

    override func tearDown() {
        CYLAnimatedItemView.liquidGlassActiveOverride = nil
        super.tearDown()
    }

    private func button(glass: Bool, selected: Bool = false, configure: (CYLMenuStyle) -> Void = { _ in }) -> CYLTagButton {
        CYLAnimatedItemView.liquidGlassActiveOverride = glass
        let style = CYLMenuStyle()
        style.backgroundStyle = glass ? .liquidGlass : .flat
        configure(style)
        let button = CYLMenuFixtures.tagButton(title: "A", image: nil, style: style)
        button.isSelected = selected
        button.layoutIfNeeded()
        return button
    }

    func testTheDefaultBordersAreNotExplicit() {
        let style = CYLMenuStyle()
        for appearance in [style.normalAppearance, style.selectedAppearance, style.disabledAppearance] {
            XCTAssertFalse(appearance.isBorderColorSet)
            XCTAssertFalse(appearance.isBorderWidthSet)
            XCTAssertNotNil(appearance.borderColor, "The effective default border is still there")
            XCTAssertGreaterThan(appearance.borderWidth, 0)
        }
        style.normalAppearance.borderWidth = 2
        XCTAssertTrue(style.normalAppearance.isBorderWidthSet)
        XCTAssertFalse(style.normalAppearance.isBorderColorSet)
        let copy = style.normalAppearance.copy()
        XCTAssertTrue(copy.isBorderWidthSet, "A copy keeps the explicitness")
        XCTAssertFalse(copy.isBorderColorSet)
        XCTAssertNotEqual(CYLMenuStyle().normalAppearance, style.normalAppearance)
    }

    func testAGlassTagDropsTheDefaultBorderNormalAndSelected() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("Liquid Glass needs iOS 26")
        }
        let normal = button(glass: true)
        XCTAssertEqual(normal.itemBackgroundStyle, .liquidGlass)
        XCTAssertEqual(normal.itemBorderWidth ?? 0, 0)
        XCTAssertNil(normal.itemBorderColor)
        let selected = button(glass: true, selected: true)
        XCTAssertEqual(selected.itemBorderWidth ?? 0, 0, "The built-in app-tint border is dropped under glass")
    }

    func testAnExplicitBorderIsKeptUnderGlass() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("Liquid Glass needs iOS 26")
        }
        let tag = button(glass: true) {
            $0.normalAppearance.borderColor = .systemRed
            $0.normalAppearance.borderWidth = 2
        }
        XCTAssertEqual(tag.itemBorderColor, .systemRed)
        XCTAssertEqual(tag.itemBorderWidth, 2)
        let onlyWidth = button(glass: true) { $0.normalAppearance.borderWidth = 3 }
        XCTAssertEqual(onlyWidth.itemBorderWidth, 3, "A set width draws the effective color")
    }

    func testAFlatTagKeepsTheDefaultBorder() {
        let flat = button(glass: false)
        XCTAssertGreaterThan(flat.itemBorderWidth ?? 0, 0)
        XCTAssertNotNil(flat.itemBorderColor)
        let inactive = button(glass: false) { $0.backgroundStyle = .liquidGlass }
        XCTAssertGreaterThan(inactive.itemBorderWidth ?? 0, 0, "Glass requested but not drawn: flat, default border kept")
    }

    func testResetClearsTheExplicitBorder() {
        let appearance = CYLTagAppearance()
        appearance.borderColor = .red
        appearance.borderWidth = 1
        appearance.reset()
        XCTAssertFalse(appearance.isBorderColorSet)
        XCTAssertFalse(appearance.isBorderWidthSet)
        XCTAssertNil(appearance.borderColor)
        XCTAssertEqual(appearance.borderWidth, 0)
    }
}
