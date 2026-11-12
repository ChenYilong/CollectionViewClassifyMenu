//
//  CYLTagEditorTestCase.swift
//  CYLTagEditorExampleTests
//
//  The base of every test case of the Swift Example: the language its expectations are written in, a window, and the
//  screens it builds.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLTagEditorExample

/**
 * A test of the Swift Example: its expectations are written in Simplified Chinese, whatever the simulator's language,
 * and it shows its screens in a window of its own (`CYLWindowHosting`), closed after each test.
 */
class CYLTagEditorTestCase: XCTestCase, CYLWindowHosting, CYLScreenshotCapturing {

    var hostWindow: UIWindow?

    override func setUp() {
        super.setUp()
        CYLTagEditorLocalization.preferredLanguage = "zh-Hans"
    }

    override func tearDown() {
        closeHostWindow()
        CYLTagEditorLocalization.preferredLanguage = nil
        super.tearDown()
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
     * The tag editor, shown and laid out, with these tags, recent tags and selection.
     */
    func showEditor(tags: [String] = ["家人", "朋友", "大学同学", "iOS 开发", "摄影", "客户", "同事"],
                    recent: [String] = ["同事", "客户"],
                    selected: [String] = ["家人", "朋友"]) -> CYLTagEditorViewController {
        let editor = CYLTagEditorViewController(store: CYLTagStore(tags: tags, recentTags: recent), selectedTags: selected)
        show(editor, size: CYLTestScreen.tall)
        editor.tagListView.layoutIfNeeded()
        return editor
    }

    /**
     * The fold styles screen made from the bundled tags.json, shown and laid out.
     */
    func showFoldStyles() throws -> CYLFoldStylesViewController {
        let styles = CYLFoldStylesViewController(data: try CYLTagData.bundled())
        show(styles, size: CYLTestScreen.tall)
        styles.view.layoutIfNeeded()
        return styles
    }
}

extension CYLTagEditorViewController {

    /**
     * The titles a section shows: a create item shows the core's "新建标签" / "新建标签：<name>".
     */
    func shownTitles(inSection section: Int) -> [String] {
        (0..<menuNumberOfItems(inSection: section)).map {
            let indexPath = IndexPath(item: $0, section: section)
            let title = menuTitleForItem(at: indexPath)
            return menuItemType(at: indexPath) == .create ? CYLTagCreateCell.title(forName: title) : title
        }
    }

    /**
     * A tap on a tag, as the user makes it (through the list's collection view).
     */
    func tap(_ indexPath: IndexPath) {
        tagListView.probe.tap(indexPath)
    }
}
