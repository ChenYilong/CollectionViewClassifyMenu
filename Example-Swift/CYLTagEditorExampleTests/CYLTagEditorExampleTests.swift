//
//  CYLTagEditorExampleTests.swift
//  CYLTagEditorExampleTests
//

import XCTest
import CollectionViewClassifyMenu
@testable import CYLTagEditorExample

final class CYLTagEditorExampleTests: XCTestCase {

    private var window: UIWindow?

    override func tearDown() {
        window = nil
        CYLTagEditorLocalization.preferredLanguage = nil
        super.tearDown()
    }

    private func host(_ controller: UIViewController) {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.view.layoutIfNeeded()
        self.window = window
    }

    private func makeEditor(tags: [String] = ["nz", "家人", "留学", "iOS", "英语", "创业", "_lanepro"],
                            recent: [String] = ["_lanepro", "创业"],
                            selected: [String] = ["nz", "家人"]) -> CYLTagEditorViewController {
        let editor = CYLTagEditorViewController(store: CYLTagStore(tags: tags, recentTags: recent), selectedTags: selected)
        host(editor)
        editor.tagListView.layoutIfNeeded()
        return editor
    }

    /// A tap on a tag, as the user makes it (through the list's collection view).
    private func tap(_ editor: CYLTagEditorViewController, _ indexPath: IndexPath) {
        let collection = editor.tagListView.value(forKey: "collectionView") as! UICollectionView
        collection.delegate?.collectionView?(collection, didSelectItemAt: indexPath)
    }

    private func titles(_ editor: CYLTagEditorViewController, section: Int) -> [String] {
        (0..<editor.menuNumberOfItems(inSection: section)).map { editor.menuTitleForItem(at: IndexPath(item: $0, section: section)) }
    }

    // MARK: Store

    func testStoreSearchesAndCreatesTags() {
        let store = CYLTagStore(tags: ["iOS", "nz 租房", "租房", "Swift 高手", "iOS"], recentTags: ["租房", "missing"])
        XCTAssertEqual(store.tags, ["iOS", "nz 租房", "租房", "Swift 高手"], "Duplicates removed")
        XCTAssertEqual(store.recentTags, ["租房"], "Unknown recent tags dropped")
        XCTAssertEqual(store.tags(matching: "ios"), ["iOS"], "Case-insensitive")
        XCTAssertEqual(store.tags(matching: "租房"), ["租房", "nz 租房"], "Tags starting with the text first")
        XCTAssertEqual(store.tags(matching: "  "), [])
        XCTAssertTrue(store.canCreate("ios"), "Another case is another tag, as in the chat app")
        XCTAssertFalse(store.canCreate("iOS"))
        XCTAssertFalse(store.canCreate("   "))
        XCTAssertEqual(store.createTag(named: "  ios "), "ios")
        XCTAssertEqual(store.tags.last, "ios")
        XCTAssertEqual(store.createTag(named: "ios"), "ios", "An existing tag is returned")
        XCTAssertEqual(store.tags.filter { $0 == "ios" }.count, 1)
        XCTAssertNil(store.createTag(named: ""))
        store.markUsed(["ios", "iOS"])
        XCTAssertEqual(store.recentTags, ["ios", "iOS", "租房"])
        store.deleteTag("iOS")
        XCTAssertEqual(store.recentTags, ["ios", "租房"])
        XCTAssertFalse(store.contains("iOS"))
    }

    // MARK: Editor

    func testEditorShowsRecentAndMyTagsWithTheSelection() {
        let editor = makeEditor()
        XCTAssertEqual(editor.sections.map(\.kind), [.recent, .mine])
        XCTAssertEqual(editor.menuTitle(forSection: 0), "最近使用")
        XCTAssertEqual(editor.menuTitle(forSection: 1), "我的标签")
        XCTAssertEqual(titles(editor, section: 0), ["_lanepro", "创业"])
        XCTAssertEqual(titles(editor, section: 1).last, "新建标签", "\"+ 新建标签\" after the last tag")
        XCTAssertNotNil(editor.menuImageForItem(at: IndexPath(item: 7, section: 1)), "with a plus")
        XCTAssertTrue(editor.menuAccessoryView(forSection: 1) === editor.manageButton, "\"管理\" in the header of 我的标签")
        XCTAssertNil(editor.menuAccessoryView(forSection: 0))
        XCTAssertEqual(Set(editor.tagListView.selectedIndexPaths), [IndexPath(item: 0, section: 1), IndexPath(item: 1, section: 1)])
        XCTAssertTrue(editor.isDoneEnabled, "Green with a selection")
        XCTAssertTrue(editor.doneButton.isEnabled)

        // A tag selected in 最近使用 is selected in 我的标签 too, and the other way round.
        tap(editor, IndexPath(item: 1, section: 0))                        // 创业
        XCTAssertEqual(editor.selectedTags, ["nz", "家人", "创业"])
        XCTAssertTrue(editor.tagListView.selectedIndexPaths.contains(IndexPath(item: 5, section: 1)))
        tap(editor, IndexPath(item: 5, section: 1))                        // 创业 again, in 我的标签
        XCTAssertEqual(editor.selectedTags, ["nz", "家人"])
        XCTAssertFalse(editor.tagListView.selectedIndexPaths.contains(IndexPath(item: 1, section: 0)))
    }

    func testNewTagItemIsAnOutlinedActionNotASelectableTag() {
        let editor = makeEditor()
        let create = IndexPath(item: 7, section: 1)
        XCTAssertFalse(editor.menuItemIsSelectable(at: create))
        XCTAssertTrue(editor.menuItemIsSelectable(at: IndexPath(item: 0, section: 1)))
        // Core: the item's own style (outlined), over the list's.
        let style = editor.menuStyleForItem(at: create)
        XCTAssertNotNil(style)
        XCTAssertEqual(style?.normalAppearance.borderWidth, 1)
        XCTAssertNil(editor.menuStyleForItem(at: IndexPath(item: 0, section: 1)))
        let collection = editor.tagListView.value(forKey: "collectionView") as! UICollectionView
        editor.tagListView.scrollToItem(at: create, animated: false)
        collection.layoutIfNeeded()
        let button = collection.cellForItem(at: create)?.value(forKey: "button") as? CYLTagButton
        XCTAssertEqual(button?.layer.borderWidth, 1, "Drawn outlined")
        XCTAssertTrue(collection.bounds.intersects(collection.cellForItem(at: create)?.frame ?? .zero), "Scrolled to the last item")
        // A tap does not select it (core: menuItemIsSelectable); it asks for a name.
        tap(editor, create)
        XCTAssertFalse(editor.tagListView.selectedIndexPaths.contains(create))
        XCTAssertEqual(editor.selectedTags, ["nz", "家人"])
        XCTAssertTrue(editor.presentedViewController is UIAlertController, "The new tag's name is asked for")
    }

    func testSearchOffersToCreateTheTagAndCreatingSelectsIt() {
        let editor = makeEditor()
        editor.setQuery("ios")
        XCTAssertEqual(editor.sections.map(\.kind), [.results])
        XCTAssertEqual(editor.menuTitle(forSection: 0), "搜索结果")
        XCTAssertEqual(titles(editor, section: 0), ["iOS", "新建标签：ios"])
        XCTAssertFalse(editor.isDoneEnabled, "\"完成\" is off while searching")
        XCTAssertFalse(editor.doneButton.isEnabled)

        editor.setQuery("iOS")
        XCTAssertEqual(titles(editor, section: 0), ["iOS"], "No \"新建\" for an existing tag")
        tap(editor, IndexPath(item: 0, section: 0))
        XCTAssertEqual(editor.selectedTags, ["nz", "家人", "iOS"], "Selecting a search result")

        editor.setQuery("ios")
        tap(editor, IndexPath(item: 1, section: 0))                        // + 新建标签：ios
        XCTAssertEqual(editor.store.tags.last, "ios")
        XCTAssertEqual(editor.selectedTags, ["nz", "家人", "iOS", "ios"])
        XCTAssertEqual(editor.query, "", "The search ends")
        XCTAssertEqual(editor.searchField.text, "")
        XCTAssertEqual(editor.sections.map(\.kind), [.recent, .mine])
        let created = editor.indexPath(of: "ios")
        XCTAssertEqual(created?.section, 1)
        XCTAssertTrue(editor.tagListView.selectedIndexPaths.contains(created!), "The new tag is selected")
        XCTAssertTrue(editor.isDoneEnabled)

        editor.setQuery("没有")
        XCTAssertEqual(titles(editor, section: 0), ["新建标签：没有"], "Only the action when nothing matches")
        XCTAssertFalse(editor.textFieldShouldReturn(editor.searchField))
        XCTAssertTrue(editor.store.contains("没有"), "The keyboard's search key creates it")
    }

    func testDoneReturnsTheSelectionAndRecordsRecentTags() {
        let editor = makeEditor(selected: [])
        XCTAssertFalse(editor.isDoneEnabled, "Nothing selected, nothing changed")
        tap(editor, IndexPath(item: 3, section: 1))                        // iOS
        XCTAssertTrue(editor.isDoneEnabled)
        var result: [String]?
        editor.onDone = { result = $0 }
        editor.done()
        XCTAssertEqual(result, ["iOS"])
        XCTAssertEqual(editor.store.recentTags.first, "iOS")
    }

    func testManagingDeletesTags() {
        let editor = makeEditor()
        editor.toggleManaging()
        XCTAssertTrue(editor.isManaging)
        XCTAssertEqual(editor.manageButton.title(for: .normal), "退出管理")
        XCTAssertFalse(editor.menuItemIsSelectable(at: IndexPath(item: 0, section: 1)), "Taps delete instead of selecting")
        editor.deleteTag("nz")
        XCTAssertFalse(editor.store.contains("nz"))
        XCTAssertEqual(editor.selectedTags, ["家人"])
        editor.toggleManaging()
        XCTAssertEqual(editor.manageButton.title(for: .normal), "管理")
    }

    func testRemarkScreenShowsTheChosenTags() {
        let store = CYLTagStore.demo()
        let remark = CYLRemarkViewController(store: store, tags: [])
        let navigation = UINavigationController(rootViewController: remark)
        host(navigation)
        XCTAssertNil(remark.title, "navigationItem only")
        XCTAssertEqual(remark.menuTitleForItem(at: IndexPath(item: 0, section: 0)), "添加标签")
        let editor = remark.editTags(animated: false)
        XCTAssertTrue(remark.presentedViewController === editor)
        XCTAssertEqual(editor.store.recentTags, ["_lanepro", "创业"])
        editor.onDone?(["nz", "留学"])
        XCTAssertEqual(remark.tags, ["nz", "留学"])
        XCTAssertEqual(remark.menuNumberOfItems(inSection: 0), 2)
        XCTAssertEqual(remark.tagsView.selectionMode, .none)
    }

    func testEnglishStrings() {
        CYLTagEditorLocalization.preferredLanguage = "en"
        let editor = makeEditor()
        XCTAssertEqual(editor.menuTitle(forSection: 1), "My Tags")
        XCTAssertEqual(titles(editor, section: 1).last, "New Tag")
        editor.setQuery("ios")
        XCTAssertEqual(titles(editor, section: 0).last, "New tag: ios")
        XCTAssertEqual(CYLMenuResources.preferredLanguage, "en", "The component follows the Example's language")
    }
}
