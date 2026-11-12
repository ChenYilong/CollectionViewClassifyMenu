//
//  CYLTagListAccessibilityTests.swift
//  CYLMenuExampleTests
//
//  VoiceOver: tags and fold controls are elements with labels and traits; the Example's own controls are labelled.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLTagListAccessibilityTests: CYLMenuExampleTestCase {

    func testVoiceOverDescribesTagsAndFoldControls() {
        let source = CYLMenuFixtures.source(itemCount: 30, sections: 1)
        source.sections[0].items[2].isEnabled = false
        let view = showTagList(source, width: 320)
        view.foldStyle = .footerChevron
        view.defaultVisibleRows = 2
        view.selectedIndexPaths = [ip(1, 0)]
        view.layoutIfNeeded()
        let tags = view.probe
        tags.layOut()
        for item in 0..<3 {
            let cell = tags.cell(at: ip(item, 0))
            XCTAssertTrue(cell?.isAccessibilityElement ?? false)
            XCTAssertEqual(cell?.accessibilityLabel, source.sections[0].items[item].title)
            let traits = cell?.accessibilityTraits ?? []
            XCTAssertTrue(traits.contains(.button))
            XCTAssertEqual(traits.contains(.selected), item == 1)
            XCTAssertEqual(traits.contains(.notEnabled), item == 2)
        }
        tags.tap(item: 0, section: 0)
        XCTAssertTrue(tags.cell(at: ip(0, 0))?.accessibilityTraits.contains(.selected) ?? false,
                      "Selection changes are reflected in the traits")

        XCTAssertTrue(tags.headerTitleLabel(inSection: 0)?.accessibilityTraits.contains(.header) ?? false)
        XCTAssertEqual(tags.footerFoldButton(inSection: 0)?.accessibilityLabel, "分组 0 更多")
        view.setExpanded(true, forSection: 0, animated: false)
        tags.layOut()
        // Thirty expanded tags are taller than the view: scroll the footer into view.
        tags.scrollToBottom()
        XCTAssertNotNil(tags.footer(inSection: 0))
        XCTAssertEqual(tags.footerFoldButton(inSection: 0)?.accessibilityLabel, "分组 0 收起")

        view.foldStyle = .headerButton
        tags.layOut()
        XCTAssertEqual(tags.headerFoldButton(inSection: 0)?.accessibilityLabel, "分组 0 收起")
    }

    func testExampleControlsHaveSpokenLabels() {
        let controller = CYLSearchCategoryViewController()
        showInNavigation(controller)
        XCTAssertEqual(controller.industryButton.accessibilityLabel, "行业 IT互联网")
        XCTAssertEqual(controller.industryButton.accessibilityHint, "选择行业")
        controller.selectIndustry("金融")
        XCTAssertEqual(controller.industryButton.accessibilityLabel, "行业 金融")
    }
}
