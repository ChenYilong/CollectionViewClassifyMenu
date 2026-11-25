//
//  CYLTitleAndIconFoldControlTests.swift
//  CYLMenuExampleTests
//
//  The fold control content `.titleAndIcon` ("More ⌄" / "Less ⌃"), the header control only on sections that can
//  fold, and the size cap of the control (font and 40% of the header).
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLTitleAndIconFoldControlTests: CYLMenuExampleTestCase {

    private func twoSectionSource() -> CYLExampleMenuSource {
        // Section 0 is long (folds at two rows), section 1 has two tags (cannot fold).
        CYLExampleMenuSource(sections: [
            CYLExampleMenuSection(title: "Long", titles: (0..<30).map { "Tag 0-\($0)" }),
            CYLExampleMenuSection(title: "Short", titles: ["A", "B"])
        ])
    }

    // The titles come from the localization bundles, in the simulator's language.
    private var more: String { CYLMenuLocalizedString("CYLMenuExpand") }
    private var less: String { CYLMenuLocalizedString("CYLMenuCollapse") }

    func testRawValuesAndConfigurationStrings() {
        XCTAssertEqual(CYLMenuFoldControlContent.iconAndTitle.rawValue, 0)
        XCTAssertEqual(CYLMenuFoldControlContent.title.rawValue, 1)
        XCTAssertEqual(CYLMenuFoldControlContent.icon.rawValue, 2)
        XCTAssertEqual(CYLMenuFoldControlContent.titleAndIcon.rawValue, 3)
        let always = CYLMenuFoldControl(configuration: ["position": "headerTrailing", "content": "titleAndIconAlways"])
        XCTAssertEqual(always?.content, .titleAndIcon)
        let alias = CYLMenuFoldControl(configuration: ["position": "headerTrailing", "content": "titleAndIcon"])
        XCTAssertEqual(alias?.content, .iconAndTitle, "The older alias keeps its meaning")
        XCTAssertEqual(CYLMenuFoldControl(configuration: ["content": 3])?.content, .titleAndIcon)
        XCTAssertEqual(CYLMenuFoldControl(configuration: "headerTrailing")?.content, .iconAndTitle)
    }

    func testTitleAndChevronInBothStates() {
        let control = CYLMenuFoldControl(position: .footer, content: .titleAndIcon)
        XCTAssertEqual(control.title(whenExpanded: false), more)
        XCTAssertEqual(control.title(whenExpanded: true), less)
        XCTAssertTrue(control.showsImage(whenExpanded: false))
        XCTAssertTrue(control.showsImage(whenExpanded: true))
        let button = CYLTagFoldButton(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
        button.applyFoldControl(control, color: nil, expanded: false, animated: false)
        XCTAssertEqual(button.titleLabel.text, more)
        XCTAssertNotNil(button.imageView.image)
        XCTAssertTrue(button.imageView.transform.isIdentity, "Chevron down while folded")
        button.applyFoldControl(control, color: nil, expanded: true, animated: false)
        XCTAssertEqual(button.titleLabel.text, less)
        XCTAssertNotNil(button.imageView.image)
        XCTAssertFalse(button.imageView.transform.isIdentity, "Chevron up while expanded")
        XCTAssertEqual(atan2(button.imageView.transform.b, button.imageView.transform.a), .pi, accuracy: 0.01)
    }

    func testIconAndTitleKeepsOnlyTheTurnedIconExpanded() {
        let control = CYLMenuFoldControl(position: .footer, content: .iconAndTitle)
        XCTAssertEqual(control.title(whenExpanded: false), more)
        XCTAssertNil(control.title(whenExpanded: true))
        XCTAssertTrue(control.showsImage(whenExpanded: true))
    }

    func testCustomTitlesApply() {
        let control = CYLMenuFoldControl(position: .footer, content: .titleAndIcon)
        control.title = "Show"
        control.collapseTitle = "Hide"
        XCTAssertEqual(control.title(whenExpanded: false), "Show")
        XCTAssertEqual(control.title(whenExpanded: true), "Hide")
        XCTAssertEqual((control.copy() as? CYLMenuFoldControl)?.content, .titleAndIcon)
    }

    func testHeaderControlOnlyOnSectionsThatCanFold() {
        let source = twoSectionSource()
        let view = showTagList(source, width: 320)
        view.foldControl = CYLMenuFoldControl(position: .headerTrailing, content: .titleAndIcon)
        view.defaultVisibleRows = 2
        view.reloadMenuData()
        view.layoutIfNeeded()
        let tags = view.probe
        tags.layOut()
        XCTAssertTrue(view.canFoldSection(0))
        XCTAssertFalse(view.canFoldSection(1))
        XCTAssertNotNil(tags.headerFoldButton(inSection: 0))
        XCTAssertEqual(tags.headerFoldButton(inSection: 0)?.isHidden, false)
        XCTAssertEqual(tags.headerFoldButton(inSection: 1)?.isHidden, true, "A short section has no header control")
        captureScreen(named: "test-fold-title-and-icon-header")
        withExtendedLifetime(source) {}
    }

    func testShortSectionKeepsNoSpaceForTheControlWithoutSectionTitles() {
        let source = twoSectionSource()
        let view = showTagList(source, width: 320)
        view.showsSectionHeaders = false
        view.foldControl = CYLMenuFoldControl(position: .headerTrailing, content: .titleAndIcon)
        view.defaultVisibleRows = 2
        view.reloadMenuData()
        view.layoutIfNeeded()
        let tags = view.probe
        tags.layOut()
        let long = tags.header(inSection: 0)?.bounds.height ?? 0
        let short = tags.header(inSection: 1)?.bounds.height ?? 0
        XCTAssertGreaterThan(long, 0)
        XCTAssertEqual(short, 0, "No empty header for a section that cannot fold")
        withExtendedLifetime(source) {}
    }

    func testFontIsCappedAtTheLargeCategory() {
        let capped = CYLMenuFoldControl(position: .headerTrailing, content: .titleAndIcon)
        let huge = UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)
        let large = UITraitCollection(preferredContentSizeCategory: .large)
        let limit = UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: large).pointSize
        XCTAssertLessThanOrEqual(CYLTagFoldButton.font(for: capped, traitCollection: huge).pointSize, limit)
        let small = UITraitCollection(preferredContentSizeCategory: .extraSmall)
        XCTAssertLessThan(CYLTagFoldButton.font(for: capped, traitCollection: small).pointSize, limit,
                          "Below the cap it still scales")
        // An uncapped control (a footer icon) is not limited.
        let uncapped = CYLMenuFoldControl(position: .footer, content: .iconAndTitle)
        XCTAssertGreaterThan(CYLTagFoldButton.font(for: uncapped, traitCollection: huge).pointSize, limit)
        // The measured size does not grow with the category either.
        let largeSize = CYLTagFoldButton.size(for: capped, expanded: false, traitCollection: large)
        let hugeSize = CYLTagFoldButton.size(for: capped, expanded: false, traitCollection: huge)
        XCTAssertEqual(hugeSize.width, largeSize.width, accuracy: 0.5)
        XCTAssertEqual(CYLTagFoldButton.maximumContentSizeCategory, .large)
    }

    func testHeaderControlIsAtMostFortyPercentOfANarrowHeader() {
        let source = CYLExampleMenuSource(sections: [
            CYLExampleMenuSection(title: "A section with a rather long title", titles: (0..<30).map { "Tag \($0)" })
        ])
        let view = showTagList(source, width: 200)
        let control = CYLMenuFoldControl(position: .headerTrailing, content: .titleAndIcon)
        control.title = "A very long more title that cannot fit"
        view.foldControl = control
        view.defaultVisibleRows = 2
        view.reloadMenuData()
        view.layoutIfNeeded()
        let tags = view.probe
        tags.layOut()
        guard let header = tags.header(inSection: 0), let fold = tags.headerFoldButton(inSection: 0) else {
            return XCTFail("No header control")
        }
        XCTAssertFalse(fold.isHidden)
        XCTAssertLessThanOrEqual(fold.frame.width, header.bounds.width * 0.4 + 0.5)
        XCTAssertGreaterThan(tags.headerTitleFrame(inSection: 0)?.width ?? 0, 0)
        withExtendedLifetime(source) {}
    }
}
