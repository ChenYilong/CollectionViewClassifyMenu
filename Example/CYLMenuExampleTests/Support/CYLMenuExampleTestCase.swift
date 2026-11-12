//
//  CYLMenuExampleTestCase.swift
//  CYLMenuExampleTests
//
//  The base of every test case of the Example: the language its expectations are written in, and a window.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
import CYLTabBarController
@testable import CYLMenuExample

/**
 * `IndexPath(item:section:)`, short, in the order the expectations are written: item, then section.
 */
func ip(_ item: Int, _ section: Int) -> IndexPath {
    IndexPath(item: item, section: section)
}

/**
 * A test of the Example: its expectations are written in Simplified Chinese, whatever the simulator's language, and
 * it shows its screens in a window of its own (`CYLWindowHosting`), closed after each test.
 */
class CYLMenuExampleTestCase: XCTestCase, CYLWindowHosting, CYLScreenshotCapturing, CYLConditionWaiting {

    var hostWindow: UIWindow?

    override func setUp() {
        super.setUp()
        CYLMenuResources.preferredLanguage = "zh-Hans"
    }

    override func tearDown() {
        closeHostWindow()
        CYLMenuResources.preferredLanguage = nil
        super.tearDown()
    }

    /**
     * A tag list of `source` in a window `width` points wide, loaded and laid out.
     *
     * The list keeps its data source weakly: the caller keeps `source`.
     */
    func showTagList(_ source: CYLExampleMenuSource, width: CGFloat) -> CYLTagListView {
        let view = CYLTagListView(frame: .zero)
        view.menuDataSource = source
        show(view, size: CGSize(width: width, height: 700))
        view.reloadMenuData()
        view.layoutIfNeeded()
        return view
    }

    /**
     * Records the whole window as `name` (see `CYLScreenshotCapturing`).
     */
    func captureScreen(named name: String) {
        guard let window = hostWindow else {
            return XCTFail("Nothing is shown")
        }
        captureScreenshot(of: window, named: name)
    }

    /**
     * The Example's root tab bar controller, shown as the window's root.
     */
    func showRootTabBarController() -> CYLTabBarController {
        let tabs = CYLExampleAppDelegate.makeRootTabBarController()
        show(tabs)
        tabs.view.layoutIfNeeded()
        return tabs
    }
}
