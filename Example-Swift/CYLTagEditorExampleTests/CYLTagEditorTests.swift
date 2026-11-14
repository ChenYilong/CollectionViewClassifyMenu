//
//  CYLTagEditorTests.swift
//  CYLTagEditorExampleTests
//
//  The 编辑标签 sheet: recent and own tags, "+ 新建标签", search and create, done, managing, the remark screen.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLTagEditorExample

final class CYLTagEditorTests: CYLTagEditorTestCase {

    private let createItem = IndexPath(item: 7, section: 1)

    func testEditorShowsRecentAndMyTagsWithTheSelection() {
        let editor = showEditor()
        XCTAssertEqual(editor.sections.map(\.kind), [.recent, .mine])
        XCTAssertEqual(editor.menuTitle(forSection: 0), "最近使用")
        XCTAssertEqual(editor.menuTitle(forSection: 1), "我的标签")
        XCTAssertEqual(editor.shownTitles(inSection: 0), ["同事", "客户"])
        XCTAssertEqual(editor.shownTitles(inSection: 1).last, "新建标签", "\"+ 新建标签\" after the last tag")
        XCTAssertEqual(editor.menuItemType(at: createItem), .create, "The core's create item")
        XCTAssertTrue(editor.menuAccessoryView(forSection: 1) === editor.manageButton, "\"管理\" in the header of 我的标签")
        XCTAssertNil(editor.menuAccessoryView(forSection: 0))
        XCTAssertEqual(Set(editor.tagListView.selectedIndexPaths), [IndexPath(item: 0, section: 1), IndexPath(item: 1, section: 1)])
        XCTAssertTrue(editor.isDoneEnabled, "Green with a selection")
        XCTAssertTrue(editor.doneButton.isEnabled)
        captureScreen(named: "test-swift-tag-editor")

        // A tag selected in 最近使用 is selected in 我的标签 too, and the other way round.
        editor.tap(IndexPath(item: 1, section: 0))                        // 客户
        XCTAssertEqual(editor.selectedTags, ["家人", "朋友", "客户"])
        XCTAssertTrue(editor.tagListView.selectedIndexPaths.contains(IndexPath(item: 5, section: 1)))
        editor.tap(IndexPath(item: 5, section: 1))                        // 客户 again, in 我的标签
        XCTAssertEqual(editor.selectedTags, ["家人", "朋友"])
        XCTAssertFalse(editor.tagListView.selectedIndexPaths.contains(IndexPath(item: 1, section: 0)))
    }

    func testNewTagItemIsAnOutlinedActionNotASelectableTag() {
        let editor = showEditor()
        XCTAssertEqual(editor.menuItemType(at: createItem), .create)
        XCTAssertEqual(editor.menuTitleForItem(at: createItem), "", "No name: the core shows \"新建标签\"")
        let tags = editor.tagListView.probe
        editor.tagListView.scrollToItem(at: createItem, animated: false)
        tags.layOut()
        // Core: CYLTagCreateCell, a CYLTagListCell with the bundle's plus icon, the localized title, outlined.
        let cell = tags.cell(at: createItem)
        XCTAssertTrue(cell is CYLTagCreateCell)
        XCTAssertTrue(cell is CYLTagListCell)
        let button = tags.tagButton(at: createItem)
        XCTAssertEqual(button?.title, "新建标签")
        XCTAssertNotNil(button?.image)
        XCTAssertNotNil(CYLMenuResources.image(named: "cyl_tag_plus"), "The plus icon is in the core bundle")
        XCTAssertEqual(button?.layer.borderWidth, 1, "Drawn outlined")
        XCTAssertFalse(cell?.accessibilityTraits.contains(.selected) ?? true)
        XCTAssertTrue(tags.collectionView.bounds.intersects(tags.cell(at: createItem)?.frame ?? .zero), "Scrolled to the last item")
        // A tap does not select it (the core never selects create items); it asks for a name.
        editor.tap(createItem)
        XCTAssertFalse(editor.tagListView.selectedIndexPaths.contains(createItem))
        XCTAssertEqual(editor.selectedTags, ["家人", "朋友"])
        XCTAssertTrue(editor.presentedViewController is UIAlertController, "The new tag's name is asked for")
    }

    func testSearchOffersToCreateTheTagAndCreatingSelectsIt() {
        let editor = showEditor()
        editor.setQuery("ios")
        XCTAssertEqual(editor.sections.map(\.kind), [.results])
        XCTAssertEqual(editor.menuTitle(forSection: 0), "搜索结果")
        XCTAssertEqual(editor.shownTitles(inSection: 0), ["iOS 开发", "新建标签：ios"])
        XCTAssertFalse(editor.isDoneEnabled, "\"完成\" is off while searching")
        XCTAssertFalse(editor.doneButton.isEnabled)
        captureScreen(named: "test-swift-tag-editor-search")

        editor.setQuery("iOS 开发")
        XCTAssertEqual(editor.shownTitles(inSection: 0), ["iOS 开发"], "No \"新建\" for an existing tag")
        editor.tap(IndexPath(item: 0, section: 0))
        XCTAssertEqual(editor.selectedTags, ["家人", "朋友", "iOS 开发"], "Selecting a search result")

        editor.setQuery("ios")
        editor.tap(IndexPath(item: 1, section: 0))                        // + 新建标签：ios
        XCTAssertEqual(editor.store.tags.last, "ios")
        XCTAssertEqual(editor.selectedTags, ["家人", "朋友", "iOS 开发", "ios"])
        XCTAssertEqual(editor.query, "", "The search ends")
        XCTAssertEqual(editor.searchField.text, "")
        XCTAssertEqual(editor.sections.map(\.kind), [.recent, .mine])
        let created = editor.indexPath(of: "ios")
        XCTAssertEqual(created?.section, 1)
        XCTAssertTrue(editor.tagListView.selectedIndexPaths.contains(created!), "The new tag is selected")
        XCTAssertTrue(editor.isDoneEnabled)

        editor.setQuery("没有")
        XCTAssertEqual(editor.shownTitles(inSection: 0), ["新建标签：没有"], "Only the action when nothing matches")
        XCTAssertFalse(editor.textFieldShouldReturn(editor.searchField))
        XCTAssertTrue(editor.store.contains("没有"), "The keyboard's search key creates it")
    }

    func testDoneReturnsTheSelectionAndRecordsRecentTags() {
        let editor = showEditor(selected: [])
        XCTAssertFalse(editor.isDoneEnabled, "Nothing selected, nothing changed")
        editor.tap(IndexPath(item: 3, section: 1))                        // iOS 开发
        XCTAssertTrue(editor.isDoneEnabled)
        var result: [String]?
        editor.onDone = { result = $0 }
        editor.done()
        XCTAssertEqual(result, ["iOS 开发"])
        XCTAssertEqual(editor.store.recentTags.first, "iOS 开发")
    }

    func testManagingDeletesTags() {
        let editor = showEditor()
        editor.toggleManaging()
        XCTAssertTrue(editor.isManaging)
        XCTAssertEqual(editor.manageButton.title(for: .normal), "退出管理")
        XCTAssertFalse(editor.menuItemIsSelectable(at: IndexPath(item: 0, section: 1)), "Taps delete instead of selecting")
        editor.deleteTag("家人")
        XCTAssertFalse(editor.store.contains("家人"))
        XCTAssertEqual(editor.selectedTags, ["朋友"])
        editor.toggleManaging()
        XCTAssertEqual(editor.manageButton.title(for: .normal), "管理")
    }

    func testRemarkScreenShowsTheChosenTags() {
        let remark = CYLRemarkViewController(store: CYLTagStore.bundled(), tags: [])
        showInNavigation(remark, size: CYLTestScreen.tall)
        XCTAssertNil(remark.title, "navigationItem only")
        XCTAssertEqual(remark.menuTitleForItem(at: IndexPath(item: 0, section: 0)), "添加标签")
        XCTAssertEqual(remark.tagsView.title, "标签", "\"标签 ›\" is the list's encapsulated title")
        XCTAssertEqual(remark.tagsView.titleStyle.imagePlacement, .trailing)
        let editor = remark.editTags(animated: false)
        XCTAssertTrue(remark.presentedViewController === editor)
        XCTAssertEqual(editor.store.recentTags, ["同事", "客户", "读书会"], "From tags.json")
        editor.onDone?(["家人", "摄影"])
        XCTAssertEqual(remark.tags, ["家人", "摄影"])
        XCTAssertEqual(remark.menuNumberOfItems(inSection: 0), 2)
        XCTAssertEqual(remark.tagsView.selectionMode, .none)
    }

    func testEnglishStrings() {
        CYLTagEditorLocalization.preferredLanguage = "en"
        let editor = showEditor()
        XCTAssertEqual(editor.menuTitle(forSection: 1), "My Tags")
        XCTAssertEqual(editor.shownTitles(inSection: 1).last, "New Tag")
        editor.setQuery("ios")
        XCTAssertEqual(editor.shownTitles(inSection: 0).last, "New tag: ios")
        XCTAssertEqual(CYLMenuResources.preferredLanguage, "en", "The component follows the Example's language")
    }
}
