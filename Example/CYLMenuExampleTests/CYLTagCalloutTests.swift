//
//  CYLTagCalloutTests.swift
//  CYLMenuExampleTests
//
//  The long-press callout (docs/tag-long-press-action.md): a long API name stays on one line at the example's width, and the
//  bubble sits above or below the pressed tag, never over it.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLTagCalloutTests: CYLMenuExampleTestCase {

    /// The example's list width on a 402 pt wide screen (the safe-area-free window of the test).
    private let screenWidth: CGFloat = 402

    private func calloutView(in window: UIView) -> UIView? {
        window.subviews.first { String(describing: type(of: $0)).contains("CYLTagCalloutView") }
    }

    private func label(of callout: UIView) -> UILabel? {
        callout.subviews.compactMap { $0 as? UILabel }.first
    }

    private func lineCount(of label: UILabel) -> Int {
        Int((label.bounds.height / label.font.lineHeight).rounded())
    }

    private func showCallout(_ text: String) -> (list: CYLTagListView, callout: UIView, label: UILabel)? {
        let source = CYLMenuFixtures.source(itemCount: 6, sections: 1)
        let list = showTagList(source, width: screenWidth)
        let indexPath = IndexPath(item: 0, section: 0)
        list.showCallout(text, at: indexPath)
        guard let window = list.window, let callout = calloutView(in: window), let label = label(of: callout) else {
            return nil
        }
        return (list, callout, label)
    }

    func testALongApiNameIsOneLineAtTheExampleWidth() throws {
        let shown = try XCTUnwrap(showCallout("setIconAnimation(bundled:size:for:)"))
        XCTAssertEqual(lineCount(of: shown.label), 1, "the closing parenthesis must not wrap")
        XCTAssertLessThanOrEqual(shown.callout.frame.maxX, screenWidth - 8 + 0.5)
        XCTAssertGreaterThanOrEqual(shown.callout.frame.minX, 8 - 0.5)
    }

    func testShortAndSpacedTextKeepsItsLines() throws {
        let short = try XCTUnwrap(showCallout("reloadData #3"))
        XCTAssertEqual(lineCount(of: short.label), 1)
        let prose = try XCTUnwrap(showCallout(String(repeating: "word ", count: 40)))
        XCTAssertGreaterThan(lineCount(of: prose.label), 1, "prose still wraps at the maximum width")
        XCTAssertLessThanOrEqual(prose.callout.frame.width, 240 + 0.5)
    }

    func testTheBubbleNeverCoversThePressedTag() throws {
        let source = CYLMenuFixtures.source(itemCount: 6, sections: 1)
        let list = showTagList(source, width: screenWidth)
        for item in 0..<3 {
            let indexPath = IndexPath(item: item, section: 0)
            list.showCallout("setIconAnimation(bundled:size:for:)", at: indexPath)
            let window = try XCTUnwrap(list.window)
            let callout = try XCTUnwrap(calloutView(in: window))
            let cell = try XCTUnwrap(list.probe.collectionView.cellForItem(at: indexPath))
            let tag = list.probe.collectionView.convert(cell.frame, to: window)
            XCTAssertFalse(callout.frame.intersects(tag), "item \(item): the bubble is above or below the pressed tag")
            list.dismissCallout()
        }
    }
}
