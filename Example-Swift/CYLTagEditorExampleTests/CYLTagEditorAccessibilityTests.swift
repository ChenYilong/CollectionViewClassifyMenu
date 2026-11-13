//
//  CYLTagEditorAccessibilityTests.swift
//  CYLTagEditorExampleTests
//
//  Accessibility of the Swift Example, found by identifier and label, never by coordinates; the lookups of both
//  string bundles, called from Swift.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLTagEditorExample

final class CYLTagEditorAccessibilityTests: CYLTagEditorTestCase {

    func testCoreLookupIsCallableFromSwift() {
        XCTAssertEqual(CYLMenuLocalizedString("CYLMenuNewTag"), "新建标签", "The core macro's Swift function")
        XCTAssertEqual(CYLTagEditorLocalizedString("编辑标签"), "编辑标签", "The Example's own lookup")
        CYLTagEditorLocalization.preferredLanguage = "en"
        XCTAssertEqual(CYLMenuLocalizedString("CYLMenuNewTag"), "New Tag")
        XCTAssertEqual(CYLTagEditorLocalizedString("编辑标签"), "Edit Tags")
    }

    func testEditorTagsAreAccessibilityElementsWithLabelsTraitsAndHints() {
        let editor = showEditor()
        XCTAssertEqual(editor.searchField.accessibilityLabel, "搜索标签")
        XCTAssertTrue(editor.titleLabel.accessibilityTraits.contains(.header))
        let tags = editor.tagListView.probe
        let collection = tags.collectionView
        let family = collection.view(withIdentifier: CYLTagListAccessibilityIdentifier.item, label: "家人")
        XCTAssertNotNil(family, "Tags are found by their label")
        XCTAssertTrue(family?.isAccessibilityElement ?? false)
        XCTAssertTrue(family?.accessibilityTraits.contains(.button) ?? false)
        XCTAssertTrue(family?.accessibilityTraits.contains(.selected) ?? false, "A selected tag says so")
        let photography = collection.view(withIdentifier: CYLTagListAccessibilityIdentifier.item, label: "摄影")
        XCTAssertFalse(photography?.accessibilityTraits.contains(.selected) ?? true)
        // "+ 新建标签" has its own identifier and reads as a button, never as a selected tag.
        editor.tagListView.scrollToItem(at: IndexPath(item: 7, section: 1), animated: false)
        tags.layOut()
        let create = collection.views(withIdentifier: CYLTagListAccessibilityIdentifier.createItem).first
        XCTAssertEqual(create?.accessibilityLabel, "新建标签")
        XCTAssertEqual(create?.accessibilityTraits, .button)
        // In 管理 mode VoiceOver explains that a tap deletes the tag.
        XCTAssertNil(editor.menuAccessibilityHintForItem(at: IndexPath(item: 0, section: 1)))
        editor.toggleManaging()
        XCTAssertEqual(editor.manageButton.accessibilityHint, "轻点两下完成管理")
        XCTAssertEqual(editor.menuAccessibilityHintForItem(at: IndexPath(item: 0, section: 1)), "轻点两下删除此标签")
        XCTAssertNil(editor.menuAccessibilityHintForItem(at: IndexPath(item: 0, section: 0)), "最近使用 is not managed")
        editor.tagListView.scrollToItem(at: IndexPath(item: 0, section: 1), animated: false)
        tags.layOut()
        let managed = collection.views(withIdentifier: CYLTagListAccessibilityIdentifier.item)
            .first { $0.accessibilityLabel == "家人" && $0.accessibilityHint != nil }
        XCTAssertEqual(managed?.accessibilityHint, "轻点两下删除此标签", "The core applies the data source's hint to the cell")
        captureScreen(named: "test-swift-tag-editor-managing")
    }

    func testRemarkTitleIsAHeaderThatOpensTheEditor() {
        let remark = CYLRemarkViewController(store: CYLTagStore.bundled(), tags: [])
        showInNavigation(remark, size: CYLTestScreen.tall)
        let title = remark.tagsView.views(withIdentifier: CYLTagListAccessibilityIdentifier.title).first
        XCTAssertTrue(title === remark.tagsView.titleView)
        XCTAssertEqual(title?.accessibilityLabel, "标签")
        XCTAssertTrue(title?.isAccessibilityElement ?? false)
        XCTAssertEqual(title?.accessibilityTraits, [.header, .button])
        XCTAssertEqual(title?.accessibilityHint, "编辑标签")
        XCTAssertEqual(remark.nameField.accessibilityLabel, "备注名")
        captureScreen(named: "test-swift-remark")
    }

    func testFoldStylesTitlesAndFoldControlsAreLabelled() throws {
        let styles = try showFoldStyles()
        for list in styles.tagListViews {
            let title = list.views(withIdentifier: CYLTagListAccessibilityIdentifier.title).first
            XCTAssertNotNil(title)
            guard let title, !title.isHidden else { continue }
            XCTAssertTrue(title.isAccessibilityElement, "Every visible title has a label")
            XCTAssertFalse(title.accessibilityLabel?.isEmpty ?? true)
            XCTAssertTrue(title.accessibilityTraits.contains(.header))
        }
        let iconOnly = styles.tagListViews.first { $0.title == nil && $0.titleImage != nil }
        XCTAssertEqual(iconOnly?.titleView.accessibilityLabel, "标题：仅图标", "An icon-only title needs a label of its own")
        let folds = styles.tagListViews.flatMap { $0.views(withIdentifier: CYLTagListAccessibilityIdentifier.foldControl) }
            .filter { !$0.isHidden && $0.window != nil }
        XCTAssertFalse(folds.isEmpty, "Fold controls are found by identifier")
        for fold in folds {
            XCTAssertTrue(fold.isAccessibilityElement)
            XCTAssertTrue(fold.accessibilityTraits.contains(.button))
            XCTAssertFalse(fold.accessibilityLabel?.isEmpty ?? true, "\(fold)")
        }
    }

    func testIconOnlyTitleWithoutALabelIsDecorative() {
        let list = CYLTagListView(foldControl: CYLMenuFoldControl(position: .footer, content: .icon), title: nil,
                                  titleImage: UIImage(systemName: "tag.circle"), titlePosition: .topLeading)
        if list.titleImage?.accessibilityLabel == nil {
            XCTAssertFalse(list.titleView.isAccessibilityElement, "Hidden from VoiceOver rather than read as an empty element")
        }
        list.title = "标签"
        XCTAssertTrue(list.titleView.isAccessibilityElement)
        XCTAssertEqual(list.titleView.accessibilityIdentifier, "CYLTagListTitle")
    }
}
