//
//  CylTagListExampleUITests.swift
//  CylTagListExampleUITests
//
//  The React Native example on iOS, driven through accessibility (labels and identifiers, never coordinates): the
//  playback controls, a tag tap, the classify menu with the filter, and the conditions restored after a relaunch.
//

import XCTest

final class CylTagListExampleUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    /// Text views whose label matches a format like "BEGINSWITH %@".
    private func text(_ predicate: String, _ value: String) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label \(predicate) %@", value)).firstMatch
    }

    /// A tag of the native list: a cell with the core's identifier `CYLTagListItem`, not a text of the places list.
    private func element(labelBeginningWith prefix: String) -> XCUIElement {
        app.cells.matching(NSPredicate(format: "identifier == 'CYLTagListItem' AND label BEGINSWITH %@", prefix)).firstMatch
    }

    private func attach(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testTagListControlsAndClassifyMenu() {
        // A clean start: the conditions of earlier runs are cleared through the page's own reset below.
        app.launch()

        // Tags tab: the 2x step and a tag tap reaching JavaScript.
        app.buttons["speed-2"].firstMatch.tap()
        XCTAssertTrue(text("==", "Speed 2.00x").waitForExistence(timeout: 5))
        element(labelBeginningWith: "Search").tap()
        XCTAssertTrue(text("BEGINSWITH", "Selected: Search").waitForExistence(timeout: 5))
        attach("tags")

        // Classify tab (CYLTabBarController's tab bar): every place, then 川菜.
        app.buttons["Classify"].firstMatch.tap()
        let reset = app.buttons["Reset"].firstMatch
        XCTAssertTrue(reset.waitForExistence(timeout: 10))
        reset.tap()
        XCTAssertTrue(text("==", "All · All · All · 83").waitForExistence(timeout: 5))
        element(labelBeginningWith: "川菜").tap()
        XCTAssertTrue(text("ENDSWITH", " · All · All · 3").waitForExistence(timeout: 5))

        // The filter sheet: 广州, then OK.
        app.buttons["Filter"].firstMatch.tap()
        let guangzhou = element(labelBeginningWith: "广州")
        XCTAssertTrue(guangzhou.waitForExistence(timeout: 5))
        guangzhou.tap()
        attach("filter-sheet")
        app.buttons["OK"].firstMatch.tap()
        XCTAssertTrue(text("ENDSWITH", " · 广州 · All · 1").waitForExistence(timeout: 5))
        attach("classify-filter")

        // Saved in the database: a relaunch restores the conditions.
        app.terminate()
        app.launch()
        app.buttons["Classify"].firstMatch.tap()
        XCTAssertTrue(text("ENDSWITH", " · 广州 · All · 1").waitForExistence(timeout: 10))
        app.buttons["Reset"].firstMatch.tap()
        XCTAssertTrue(text("==", "All · All · All · 83").waitForExistence(timeout: 5))
    }
}
