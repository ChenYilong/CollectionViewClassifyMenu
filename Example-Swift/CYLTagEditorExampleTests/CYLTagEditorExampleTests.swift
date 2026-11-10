//
//  CYLTagEditorExampleTests.swift
//  CYLTagEditorExampleTests
//

import XCTest
import CollectionViewClassifyMenu
@testable import CYLTagEditorExample

final class CYLTagEditorExampleTests: XCTestCase {

    private var window: UIWindow?

    override func setUp() {
        super.setUp()
        // The simulator's language is usually English; the expectations use the Chinese strings.
        CYLTagEditorLocalization.preferredLanguage = "zh-Hans"
    }

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

    private func makeEditor(tags: [String] = ["家人", "朋友", "大学同学", "iOS 开发", "摄影", "客户", "同事"],
                            recent: [String] = ["同事", "客户"],
                            selected: [String] = ["家人", "朋友"]) -> CYLTagEditorViewController {
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

    /// The titles shown: a create item shows the core's "新建标签" / "新建标签：<name>".
    private func titles(_ editor: CYLTagEditorViewController, section: Int) -> [String] {
        (0..<editor.menuNumberOfItems(inSection: section)).map {
            let indexPath = IndexPath(item: $0, section: section)
            let title = editor.menuTitleForItem(at: indexPath)
            return editor.menuItemType(at: indexPath) == .create ? CYLTagCreateCell.title(forName: title) : title
        }
    }

    // MARK: Store

    func testStoreSearchesAndCreatesTags() {
        let store = CYLTagStore(tags: ["iOS 开发", "上海同事", "同事", "Swift 读书会", "iOS 开发"], recentTags: ["同事", "missing"])
        XCTAssertEqual(store.tags, ["iOS 开发", "上海同事", "同事", "Swift 读书会"], "Duplicates removed")
        XCTAssertEqual(store.recentTags, ["同事"], "Unknown recent tags dropped")
        XCTAssertEqual(store.tags(matching: "ios"), ["iOS 开发"], "Case-insensitive")
        XCTAssertEqual(store.tags(matching: "同事"), ["同事", "上海同事"], "Tags starting with the text first")
        XCTAssertEqual(store.tags(matching: "  "), [])
        XCTAssertTrue(store.canCreate("ios"), "Only an exact name exists already, as in the chat app")
        XCTAssertFalse(store.canCreate("iOS 开发"))
        XCTAssertFalse(store.canCreate("   "))
        XCTAssertEqual(store.createTag(named: "  ios "), "ios")
        XCTAssertEqual(store.tags.last, "ios")
        XCTAssertEqual(store.createTag(named: "ios"), "ios", "An existing tag is returned")
        XCTAssertEqual(store.tags.filter { $0 == "ios" }.count, 1)
        XCTAssertNil(store.createTag(named: ""))
        store.markUsed(["ios", "iOS 开发"])
        XCTAssertEqual(store.recentTags, ["ios", "iOS 开发", "同事"])
        store.deleteTag("iOS 开发")
        XCTAssertEqual(store.recentTags, ["ios", "同事"])
        XCTAssertFalse(store.contains("iOS 开发"))
    }

    // MARK: Editor

    func testEditorShowsRecentAndMyTagsWithTheSelection() {
        let editor = makeEditor()
        XCTAssertEqual(editor.sections.map(\.kind), [.recent, .mine])
        XCTAssertEqual(editor.menuTitle(forSection: 0), "最近使用")
        XCTAssertEqual(editor.menuTitle(forSection: 1), "我的标签")
        XCTAssertEqual(titles(editor, section: 0), ["同事", "客户"])
        XCTAssertEqual(titles(editor, section: 1).last, "新建标签", "\"+ 新建标签\" after the last tag")
        XCTAssertEqual(editor.menuItemType(at: IndexPath(item: 7, section: 1)), .create, "The core's create item")
        XCTAssertTrue(editor.menuAccessoryView(forSection: 1) === editor.manageButton, "\"管理\" in the header of 我的标签")
        XCTAssertNil(editor.menuAccessoryView(forSection: 0))
        XCTAssertEqual(Set(editor.tagListView.selectedIndexPaths), [IndexPath(item: 0, section: 1), IndexPath(item: 1, section: 1)])
        XCTAssertTrue(editor.isDoneEnabled, "Green with a selection")
        XCTAssertTrue(editor.doneButton.isEnabled)

        // A tag selected in 最近使用 is selected in 我的标签 too, and the other way round.
        tap(editor, IndexPath(item: 1, section: 0))                        // 客户
        XCTAssertEqual(editor.selectedTags, ["家人", "朋友", "客户"])
        XCTAssertTrue(editor.tagListView.selectedIndexPaths.contains(IndexPath(item: 5, section: 1)))
        tap(editor, IndexPath(item: 5, section: 1))                        // 客户 again, in 我的标签
        XCTAssertEqual(editor.selectedTags, ["家人", "朋友"])
        XCTAssertFalse(editor.tagListView.selectedIndexPaths.contains(IndexPath(item: 1, section: 0)))
    }

    func testNewTagItemIsAnOutlinedActionNotASelectableTag() {
        let editor = makeEditor()
        let create = IndexPath(item: 7, section: 1)
        XCTAssertEqual(editor.menuItemType(at: create), .create)
        XCTAssertEqual(editor.menuTitleForItem(at: create), "", "No name: the core shows \"新建标签\"")
        let collection = editor.tagListView.value(forKey: "collectionView") as! UICollectionView
        editor.tagListView.scrollToItem(at: create, animated: false)
        collection.layoutIfNeeded()
        // Core: CYLTagCreateCell, a CYLTagListCell with the bundle's plus icon, the localized title, outlined.
        let cell = collection.cellForItem(at: create)
        XCTAssertTrue(cell is CYLTagCreateCell)
        XCTAssertTrue(cell is CYLTagListCell)
        let button = (cell as? CYLTagListCell)?.button
        XCTAssertEqual(button?.title, "新建标签")
        XCTAssertNotNil(button?.image)
        XCTAssertNotNil(CYLMenuResources.imageNamed("cyl_tag_plus"), "The plus icon is in the core bundle")
        XCTAssertEqual(button?.layer.borderWidth, 1, "Drawn outlined")
        XCTAssertFalse(cell?.accessibilityTraits.contains(.selected) ?? true)
        XCTAssertTrue(collection.bounds.intersects(collection.cellForItem(at: create)?.frame ?? .zero), "Scrolled to the last item")
        // A tap does not select it (the core never selects create items); it asks for a name.
        tap(editor, create)
        XCTAssertFalse(editor.tagListView.selectedIndexPaths.contains(create))
        XCTAssertEqual(editor.selectedTags, ["家人", "朋友"])
        XCTAssertTrue(editor.presentedViewController is UIAlertController, "The new tag's name is asked for")
    }

    func testSearchOffersToCreateTheTagAndCreatingSelectsIt() {
        let editor = makeEditor()
        editor.setQuery("ios")
        XCTAssertEqual(editor.sections.map(\.kind), [.results])
        XCTAssertEqual(editor.menuTitle(forSection: 0), "搜索结果")
        XCTAssertEqual(titles(editor, section: 0), ["iOS 开发", "新建标签：ios"])
        XCTAssertFalse(editor.isDoneEnabled, "\"完成\" is off while searching")
        XCTAssertFalse(editor.doneButton.isEnabled)

        editor.setQuery("iOS 开发")
        XCTAssertEqual(titles(editor, section: 0), ["iOS 开发"], "No \"新建\" for an existing tag")
        tap(editor, IndexPath(item: 0, section: 0))
        XCTAssertEqual(editor.selectedTags, ["家人", "朋友", "iOS 开发"], "Selecting a search result")

        editor.setQuery("ios")
        tap(editor, IndexPath(item: 1, section: 0))                        // + 新建标签：ios
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
        XCTAssertEqual(titles(editor, section: 0), ["新建标签：没有"], "Only the action when nothing matches")
        XCTAssertFalse(editor.textFieldShouldReturn(editor.searchField))
        XCTAssertTrue(editor.store.contains("没有"), "The keyboard's search key creates it")
    }

    func testDoneReturnsTheSelectionAndRecordsRecentTags() {
        let editor = makeEditor(selected: [])
        XCTAssertFalse(editor.isDoneEnabled, "Nothing selected, nothing changed")
        tap(editor, IndexPath(item: 3, section: 1))                        // iOS 开发
        XCTAssertTrue(editor.isDoneEnabled)
        var result: [String]?
        editor.onDone = { result = $0 }
        editor.done()
        XCTAssertEqual(result, ["iOS 开发"])
        XCTAssertEqual(editor.store.recentTags.first, "iOS 开发")
    }

    func testManagingDeletesTags() {
        let editor = makeEditor()
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
        let store = CYLTagStore.bundled()
        let remark = CYLRemarkViewController(store: store, tags: [])
        let navigation = UINavigationController(rootViewController: remark)
        host(navigation)
        XCTAssertNil(remark.title, "navigationItem only")
        XCTAssertEqual(remark.menuTitleForItem(at: IndexPath(item: 0, section: 0)), "添加标签")
        let editor = remark.editTags(animated: false)
        XCTAssertTrue(remark.presentedViewController === editor)
        XCTAssertEqual(editor.store.recentTags, ["同事", "客户", "读书会"], "From tags.json")
        editor.onDone?(["家人", "摄影"])
        XCTAssertEqual(remark.tags, ["家人", "摄影"])
        XCTAssertEqual(remark.menuNumberOfItems(inSection: 0), 2)
        XCTAssertEqual(remark.tagsView.selectionMode, .none)
    }

    // MARK: Data (local JSON per language)

    func testDemoTagsAreLoadedFromTheJSONFileOfTheLanguage() throws {
        var loaded: [String: CYLTagData] = [:]
        for language in ["zh-Hans", "zh-Hant", "en"] {
            CYLTagEditorLocalization.preferredLanguage = language
            let data = try CYLTagData.bundled()
            XCTAssertEqual(data.version, 1)
            XCTAssertGreaterThan(data.tags.count, 30, language)
            XCTAssertEqual(Set(data.tags).count, data.tags.count, "No duplicates in \(language)")
            XCTAssertTrue(Set(data.recentTags).isSubset(of: data.tags), language)
            XCTAssertTrue(Set(data.selectedTags).isSubset(of: data.tags), language)
            XCTAssertFalse(CYLTagStore(data: data).tags(matching: "ios").isEmpty, "\"ios\" finds a tag in \(language) (search screenshot)")
            loaded[language] = data
        }
        XCTAssertEqual(loaded["zh-Hans"]?.tags.first, "家人")
        XCTAssertEqual(loaded["zh-Hant"]?.tags[4], "大學同學")
        XCTAssertEqual(loaded["en"]?.tags.first, "Family")
        XCTAssertEqual(loaded["en"]?.selectedTags, ["Family", "College Classmates", "Book Club"])
        let counts = Set(loaded.values.map { $0.tags.count })
        XCTAssertEqual(counts.count, 1, "The same tags in every language")

        // The app's store is made from the file of its language.
        CYLTagEditorLocalization.preferredLanguage = "en"
        XCTAssertEqual(CYLTagStore.bundled().tags, loaded["en"]?.tags)
        XCTAssertEqual(CYLTagStore.bundled().recentTags, loaded["en"]?.recentTags)
    }

    func testTagDataParsingErrors() {
        XCTAssertThrowsError(try CYLTagData.decode(Data("{\"tags\": 1}".utf8)))
        XCTAssertThrowsError(try CYLTagData.bundled(bundle: Bundle(for: CYLTagEditorExampleTests.self))) { error in
            guard case CYLTagData.LoadingError.fileNotFound = error else {
                return XCTFail("\(error)")
            }
        }
        let json = #"{"version": 1, "tags": ["家人", "朋友"], "recentTags": ["朋友"], "selectedTags": [], "comment": "ignored"}"#
        XCTAssertEqual(try CYLTagData.decode(Data(json.utf8)).tags, ["家人", "朋友"])
    }

    // MARK: Fold styles (core: CYLMenuFoldControl, title, configuration files)

    func testFoldStylesAreMadeWithParametersAndFromConfigurationFiles() throws {
        let data = try CYLTagData.bundled()
        XCTAssertEqual(data.groups?.count, 6, "Grouped tags in tags.json")
        let styles = CYLFoldStylesViewController(data: data)
        host(styles)
        styles.view.layoutIfNeeded()
        let demos = styles.demos()
        XCTAssertTrue(styles.configurationErrors.isEmpty, "\(styles.configurationErrors) (YAML and XML need CYLTabBarController's parser)")
        XCTAssertEqual(styles.tagListViews.count, demos.count + CYLFoldStylesViewController.configurationFiles.count)
        // Every position and content.
        let made = styles.tagListViews.prefix(demos.count)
        XCTAssertEqual(made.map { $0.foldControl.position }, demos.map { $0.foldControl.position })
        XCTAssertEqual(Set(made.map { $0.foldControl.position }), [.bottom, .topTrailing, .topLeading])
        XCTAssertEqual(Set(made.map { $0.foldControl.content }), [.icon, .iconAndTitle, .title])
        XCTAssertEqual(made.first?.foldStyle, .footerChevron, "foldControl sets foldStyle")
        XCTAssertEqual(made.first?.title, "底部箭头（淘宝评价筛选）")
        XCTAssertEqual(made.last?.titlePosition, .topCenter)
        XCTAssertEqual(made.last?.titleLabel.textAlignment, .center)
        // From the files: JSON, plist, YAML and XML.
        let files = Array(styles.tagListViews.suffix(4))
        XCTAssertEqual(files.map { $0.foldControl.position }, [.bottom, .topTrailing, .topLeading, .bottom])
        XCTAssertEqual(files.map { $0.foldControl.content }, [.iconAndTitle, .title, .icon, .title])
        XCTAssertEqual(files[3].titlePosition, .topCenter)
        XCTAssertTrue(files.allSatisfy { ($0.title ?? "").count > 0 })
        XCTAssertTrue(files.allSatisfy { $0.selectionMode == .multiple && !$0.isScrollEnabled })
        for list in styles.tagListViews {
            XCTAssertGreaterThan(list.contentHeight, 0, list.title ?? "")
            XCTAssertGreaterThan(list.frame.minY, -1)
        }
    }

    func testFoldControlTurnsItsChevronAndKeepsOnlyTheIconWhenExpanded() throws {
        let styles = CYLFoldStylesViewController(data: try CYLTagData.bundled())
        host(styles)
        styles.view.layoutIfNeeded()
        // "底部：文字 + 箭头": "更多 ⌄", then only the chevron, turned 180°.
        let list = styles.tagListViews[1]
        XCTAssertTrue(list.canFoldSection(0))
        let collection = list.value(forKey: "collectionView") as! UICollectionView
        collection.layoutIfNeeded()
        var footer = collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: 0))
        var fold = footer?.value(forKey: "foldButton") as? CYLTagButton
        XCTAssertNotNil(fold, "A tag view (CYLTagFoldButton) below the section")
        XCTAssertEqual(fold?.title, "更多")
        XCTAssertNotNil(fold?.image)
        XCTAssertEqual(fold?.layer.borderWidth, 0, "Borderless")
        XCTAssertTrue(fold?.imageView.transform.isIdentity ?? false)
        let heightBefore = list.contentHeight
        fold?.sendActions(for: .touchUpInside)
        list.layoutIfNeeded()
        XCTAssertTrue(list.isSectionExpanded(0))
        XCTAssertGreaterThan(list.contentHeight, heightBefore)
        footer = collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: 0))
        fold = footer?.value(forKey: "foldButton") as? CYLTagButton
        XCTAssertNil(fold?.title, "Expanded: only the chevron")
        XCTAssertEqual(fold?.imageView.transform.a ?? 0, -1, accuracy: 0.01, "Turned 180°")

        // "左上角": the control before the section title.
        let leading = styles.tagListViews[5]
        let leadingCollection = leading.value(forKey: "collectionView") as! UICollectionView
        leadingCollection.layoutIfNeeded()
        let header = leadingCollection.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0))
        let headerFold = header?.value(forKey: "foldButton") as? UIView
        let headerTitle = header?.value(forKey: "titleLabel") as? UIView
        XCTAssertNotNil(headerFold)
        XCTAssertLessThan(headerFold?.frame.minX ?? .infinity, headerTitle?.frame.minX ?? 0, "At the leading edge, before the title")
    }

    func testCoreFoldControlDefaultsAreLocalized() {
        let control = CYLMenuFoldControl(position: .bottom, content: .iconAndTitle)
        XCTAssertEqual(control.title, "更多")
        XCTAssertEqual(control.collapseTitle, "收起")
        XCTAssertTrue(control.usesDefaultImage)
        XCTAssertNotNil(CYLMenuResources.imageNamed("cyl_fold_chevron"), "The chevron is in the core bundle")
        XCTAssertEqual(control.title(whenExpanded: false), "更多")
        XCTAssertNil(control.title(whenExpanded: true), "Icon and title: only the icon when expanded")
        XCTAssertEqual(CYLMenuFoldControl(position: .topTrailing, content: .title).title(whenExpanded: true), "收起")
        XCTAssertEqual(CYLTagCreateCell.title(forName: ""), "新建标签")
        XCTAssertEqual(CYLTagCreateCell.title(forName: "ios"), "新建标签：ios")
        CYLTagEditorLocalization.preferredLanguage = "en"
        XCTAssertEqual(CYLMenuFoldControl(position: .bottom, content: .iconAndTitle).title, "More")
        XCTAssertEqual(CYLTagCreateCell.title(forName: "ios"), "New tag: ios")
        CYLTagEditorLocalization.preferredLanguage = "zh-Hant"
        XCTAssertEqual(CYLTagCreateCell.title(forName: ""), "新增標籤")
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
