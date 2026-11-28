//
//  CYLTagFoldTailStyleTests.swift
//  CYLMenuExampleTests
//
//  The tail fold control (the inline fold cell, the last tag of a section) takes the same style strategy as every other tag: the
//  same backgroundStyle, explicit background color (nil while unset), corner radius and border from the one configuration, in a
//  glass list and in a flat list. `foldControlColor` only tints its icon.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
import CYLAnimatedItem
@testable import CYLMenuExample

final class CYLTagFoldTailStyleTests: CYLMenuExampleTestCase {

    override func tearDown() {
        CYLAnimatedItemView.liquidGlassActiveOverride = nil
        super.tearDown()
    }

    private func buttons(glass: Bool, background: UIColor? = nil,
                         configure: (CYLMenuStyle) -> Void = { _ in }) throws -> (tag: CYLTagButton, tail: CYLTagButton) {
        CYLAnimatedItemView.liquidGlassActiveOverride = glass
        let source = CYLMenuFixtures.source(itemCount: 14, sections: 1)
        let view = showTagList(source, width: 320)
        let style = CYLMenuStyle()
        style.backgroundStyle = glass ? .liquidGlass : .flat
        if let background {
            style.normalAppearance.backgroundColor = background
        }
        configure(style)
        view.style = style
        view.foldControl = CYLMenuFoldControl(position: .tail, content: .icon)
        view.defaultVisibleRows = 2
        view.reloadMenuData()
        view.layoutIfNeeded()
        view.probe.layOut()
        let visible = view.numberOfVisibleItems(inSection: 0)
        let tail = try XCTUnwrap((view.probe.cell(at: ip(visible, 0)) as? CYLTagFoldCell)?.foldButton, "The tail control")
        let tag = try XCTUnwrap(view.probe.tagButton(at: ip(0, 0)), "A plain tag")
        withExtendedLifetime(source) {}
        return (tag, tail)
    }

    private func assertSameStyle(_ pair: (tag: CYLTagButton, tail: CYLTagButton), file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(pair.tail.itemBackgroundStyle, pair.tag.itemBackgroundStyle, "backgroundStyle", file: file, line: line)
        XCTAssertEqual(pair.tail.itemBackgroundColor, pair.tag.itemBackgroundColor, "explicit background color", file: file, line: line)
        XCTAssertEqual(pair.tail.itemCornerRadius, pair.tag.itemCornerRadius, "corner radius", file: file, line: line)
        XCTAssertEqual(pair.tail.itemBorderWidth, pair.tag.itemBorderWidth, "border width", file: file, line: line)
        XCTAssertEqual(pair.tail.itemBorderColor, pair.tag.itemBorderColor, "border color", file: file, line: line)
    }

    func testTheTailControlSharesTheGlassStyleOfAPlainTag() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("Liquid Glass needs iOS 26")
        }
        let pair = try buttons(glass: true)
        XCTAssertEqual(pair.tag.itemBackgroundStyle, .liquidGlass)
        XCTAssertNil(pair.tail.itemBackgroundColor, "Unset: nil, the item's shared low-alpha default tint")
        assertSameStyle(pair)
    }

    func testTheTailControlSharesTheExplicitGlassTintAndTheGeometry() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("Liquid Glass needs iOS 26")
        }
        let pair = try buttons(glass: true, background: .systemTeal) {
            $0.normalAppearance.cornerRadius = 9
            $0.normalAppearance.borderWidth = 2
            $0.normalAppearance.borderColor = .systemRed
        }
        XCTAssertEqual(pair.tail.itemBackgroundColor, .systemTeal)
        XCTAssertEqual(pair.tail.itemCornerRadius, 9 as CGFloat?)
        assertSameStyle(pair)
    }

    func testTheTailControlSharesTheFlatStyleOfAPlainTag() throws {
        let pair = try buttons(glass: false)
        XCTAssertEqual(pair.tag.itemBackgroundStyle, .flat)
        assertSameStyle(pair)
        let colored = try buttons(glass: false, background: .systemYellow) {
            $0.normalAppearance.cornerRadius = 6
            $0.normalAppearance.borderWidth = 1
            $0.normalAppearance.borderColor = .systemBlue
        }
        assertSameStyle(colored)
    }

    func testFoldControlColorOnlyTintsTheIcon() throws {
        let plain = try buttons(glass: false)
        let tinted = try buttons(glass: false) { $0.foldControlColor = .systemPink }
        XCTAssertEqual(tinted.tail.itemBackgroundColor, plain.tail.itemBackgroundColor)
        XCTAssertEqual(tinted.tail.itemCornerRadius, plain.tail.itemCornerRadius)
        XCTAssertEqual(tinted.tail.itemBorderWidth, plain.tail.itemBorderWidth)
        assertSameStyle(tinted)
    }
}
