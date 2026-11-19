//
//  CYLTagListEditingTests.swift
//  CYLMenuExampleTests
//
//  CYLTagListView's editing mode (setEditing(_:animated:)): delete indicators, reordering, taps that report without
//  selecting, unfolded sections, the add control below the last section, and the editable sections.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

/**
 * Two sections of tags that can be removed, moved and added to; section 1 alone takes part in editing.
 */
private final class CYLEditableTagSource: NSObject, CYLMenuDataSource, CYLMenuDelegate {
    var sections: [[String]]
    /// Each item's stable id ("id-<first title>"), moved with it and kept by a rename.
    var identifiers: [[String]]
    var editableSections: IndexSet?
    var renames = false
    private(set) var events: [String] = []

    init(sections: [[String]]) {
        self.sections = sections
        self.identifiers = sections.map { $0.map { "id-" + $0 } }
    }

    func menuIdentifierForItem(at indexPath: IndexPath) -> String { identifiers[indexPath.section][indexPath.item] }

    override func responds(to aSelector: Selector!) -> Bool {
        // Renaming is optional: the source offers it only when `renames`.
        if aSelector == #selector(CYLMenuDataSource.menuRenameItem(at:to:)) {
            return renames
        }
        return super.responds(to: aSelector)
    }

    func menuRenameItem(at indexPath: IndexPath, to title: String) {
        sections[indexPath.section][indexPath.item] = title
    }

    func menu(_ menu: Any, didRenameItemAt indexPath: IndexPath, to title: String) {
        events.append("rename \(indexPath.item)-\(indexPath.section) \(title)")
    }

    func numberOfSectionsInMenu() -> Int { sections.count }
    func menuNumberOfItems(inSection section: Int) -> Int { sections[section].count }
    func menuTitle(forSection section: Int) -> String { "Section \(section)" }
    func menuTitleForItem(at indexPath: IndexPath) -> String { sections[indexPath.section][indexPath.item] }
    func menuSectionAllowsEditing(_ section: Int) -> Bool { editableSections?.contains(section) ?? true }
    func menuRemoveItem(at indexPath: IndexPath) {
        sections[indexPath.section].remove(at: indexPath.item)
        identifiers[indexPath.section].remove(at: indexPath.item)
    }

    func menuMoveItem(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let title = sections[sourceIndexPath.section].remove(at: sourceIndexPath.item)
        sections[destinationIndexPath.section].insert(title, at: destinationIndexPath.item)
        let identifier = identifiers[sourceIndexPath.section].remove(at: sourceIndexPath.item)
        identifiers[destinationIndexPath.section].insert(identifier, at: destinationIndexPath.item)
    }

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        events.append("select \(indexPath.item)-\(indexPath.section)")
    }

    func menu(_ menu: Any, didChangeEditing editing: Bool) {
        events.append(editing ? "edit" : "done")
    }

    func menu(_ menu: Any, didRequestNewItemWithName name: String, at indexPath: IndexPath) {
        events.append("add \(name) at \(indexPath.item)-\(indexPath.section)")
        sections[indexPath.section].insert(name, at: indexPath.item)
        identifiers[indexPath.section].insert("id-" + name, at: indexPath.item)
        (menu as? CYLTagListView)?.reloadMenuData()
    }
}

/**
 * A remote source that answers at once with fixed sections, or fails.
 */
private final class CYLFakeItemsRemoteSource: NSObject, CYLTagListRemoteSource {
    var items: [String: [CYLTagListCacheItem]]

    init(items: [String: [CYLTagListCacheItem]]) {
        self.items = items
    }

    func fetchSections(withKeys keys: [String], completion: @escaping ([String: [String]]?, Error?) -> Void) {
        completion(items.mapValues { $0.map(\.title) }, nil)
    }

    func fetchItems(withKeys keys: [String], completion: @escaping ([String: [CYLTagListCacheItem]]?, Error?) -> Void) {
        completion(items, nil)
    }
}

private final class CYLFakeRemoteSource: NSObject, CYLTagListRemoteSource {
    var sections: [String: [String]]?
    private(set) var fetchCount = 0

    init(sections: [String: [String]]?) {
        self.sections = sections
    }

    func fetchSections(withKeys keys: [String], completion: @escaping ([String: [String]]?, Error?) -> Void) {
        fetchCount += 1
        completion(sections, sections == nil ? NSError(domain: "CYLFake", code: 1) : nil)
    }
}

final class CYLTagListEditingTests: CYLMenuExampleTestCase {

    private func makeList(_ source: CYLEditableTagSource) -> CYLTagListView {
        let view = CYLTagListView(frame: .zero)
        view.menuDataSource = source
        view.menuDelegate = source
        view.selectionMode = .multiple
        show(view, size: CGSize(width: 320, height: 700))
        view.reloadMenuData()
        view.layoutIfNeeded()
        return view
    }

    private func cell(_ view: CYLTagListView, _ item: Int, _ section: Int) -> CYLTagListCell? {
        view.layoutIfNeeded()
        let collection = view.subviews.compactMap { $0 as? UICollectionView }.first
        collection?.layoutIfNeeded()
        return collection?.cellForItem(at: IndexPath(item: item, section: section)) as? CYLTagListCell
    }

    func testEditingShowsDeleteIndicatorsAndTheAddControlOnlyWhileEditing() {
        let source = CYLEditableTagSource(sections: [["Recent A", "Recent B"], ["Family", "Friends", "Clients"]])
        source.editableSections = [1]
        let view = makeList(source)
        XCTAssertFalse(view.isEditing)
        XCTAssertFalse(cell(view, 0, 1)?.isDeletable ?? true, "no delete indicator before editing")
        let heightBefore = view.contentHeight

        view.setEditing(true, animated: false)
        XCTAssertTrue(view.isEditing)
        XCTAssertEqual(source.events, ["edit"])
        XCTAssertTrue(cell(view, 0, 1)?.isDeletable ?? false, "an editable section shows the delete indicator")
        XCTAssertFalse(cell(view, 0, 0)?.isDeletable ?? true, "a section outside editing does not")
        XCTAssertTrue(view.addItemView.isDescendant(of: view), "the add control is shown")
        XCTAssertGreaterThan(view.addItemView.frame.height, 0)
        XCTAssertGreaterThan(view.contentHeight, heightBefore, "the add control adds to the content height")

        view.setEditing(false, animated: false)
        XCTAssertFalse(view.addItemView.isDescendant(of: view), "leaving editing hides it")
        XCTAssertEqual(view.contentHeight, heightBefore, accuracy: 0.5)
        XCTAssertFalse(cell(view, 0, 1)?.isDeletable ?? true)
        XCTAssertEqual(source.events, ["edit", "done"])
    }

    func testEditingTapReportsWithoutSelectingAndDeleteRemoves() {
        let source = CYLEditableTagSource(sections: [["Family", "Friends", "Clients"]])
        let view = makeList(source)
        view.setEditing(true, animated: false)
        let collection = view.subviews.compactMap { $0 as? UICollectionView }.first!
        view.collectionView(collection, didSelectItemAt: IndexPath(item: 1, section: 0))
        XCTAssertEqual(source.events.last, "select 1-0", "a tap still reports the item, so the host can open it")
        XCTAssertTrue(view.selectedIndexPaths.isEmpty, "but does not select it while editing")

        view.deleteItem(at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(source.sections[0], ["Friends", "Clients"], "the delete indicator removes the item")
    }

    func testEditingUnfoldsAndAddsThroughTheAddControl() {
        let source = CYLEditableTagSource(sections: [(0..<30).map { "Tag \($0)" }])
        let view = makeList(source)
        view.showsSectionHeaders = false
        view.defaultVisibleRows = 2
        view.foldStyle = .footerChevron
        view.layoutIfNeeded()
        XCTAssertTrue(view.canFoldSection(0))
        XCTAssertLessThan(view.numberOfVisibleItems(inSection: 0), 30)

        view.setEditing(true, animated: false)
        XCTAssertFalse(view.canFoldSection(0), "editing shows every item")
        XCTAssertEqual(view.numberOfVisibleItems(inSection: 0), 30)

        view.addItemView.textField.text = "  Book Club  "
        view.addItemView.submit()
        XCTAssertEqual(source.events.last, "add Book Club at 30-0", "trimmed, at the end of the editable section")
        XCTAssertEqual(source.sections[0].last, "Book Club")
        XCTAssertEqual(view.addItemView.textField.text, "", "the field is cleared")

        view.setEditing(false, animated: false)
        XCTAssertTrue(view.canFoldSection(0), "folding comes back after editing")
    }

    func testEditingEnablesReorderingOfEditableSections() {
        let source = CYLEditableTagSource(sections: [["Recent A", "Recent B"], ["Family", "Friends"]])
        source.editableSections = [1]
        let view = makeList(source)
        XCTAssertFalse(view.allowsReordering)
        view.setEditing(true, animated: false)
        let collection = view.subviews.compactMap { $0 as? UICollectionView }.first!
        XCTAssertTrue(view.collectionView(collection, canMoveItemAt: IndexPath(item: 0, section: 1)),
                      "an editable section's tags can be dragged while editing")
        XCTAssertFalse(view.collectionView(collection, canMoveItemAt: IndexPath(item: 0, section: 0)),
                       "the other sections' cannot")
        view.setEditing(false, animated: false)
        XCTAssertFalse(view.collectionView(collection, canMoveItemAt: IndexPath(item: 0, section: 1)))
    }

    func testEditsAreSavedInEveryCachePolicy() {
        for policy in [CYLTagListCachePolicy.database, .userDefaults, .sandboxFile] {
            let name = "CYLTagListEditingTests.\(policy.rawValue)"
            CYLTagListStore(policy: policy, name: name).removeAllTitles()
            let source = CYLEditableTagSource(sections: [["Recent A"], ["Family", "Friends", "Clients"]])
            source.editableSections = [1]
            let view = makeList(source)
            view.cacheName = name
            view.cachePolicy = policy
            XCTAssertNil(view.cachedTitles(inSection: 1), "nothing saved yet, policy \(policy.rawValue)")
            view.setEditing(true, animated: false)
            let collection = view.subviews.compactMap { $0 as? UICollectionView }.first!
            view.collectionView(collection, moveItemAt: IndexPath(item: 2, section: 1), to: IndexPath(item: 0, section: 1))
            XCTAssertEqual(view.cachedTitles(inSection: 1), ["Clients", "Family", "Friends"], "a drag is saved")
            view.deleteItem(at: IndexPath(item: 1, section: 1))
            view.addItemView.textField.text = "Book Club"
            view.addItemView.submit()
            XCTAssertNil(view.cachedTitles(inSection: 0), "a section outside editing is not saved")
            // A new store of the same policy and name reads it back, as after a relaunch.
            let reopened = CYLTagListStore(policy: policy, name: name)
            XCTAssertEqual(reopened.cachedTitles(forSection: "1"), ["Clients", "Friends", "Book Club"],
                           "policy \(policy.rawValue)")
            reopened.saveTitles([], forSection: "1")
            XCTAssertEqual(reopened.cachedTitles(forSection: "1"), [], "an emptied section differs from none")
            reopened.removeAllTitles()
            XCTAssertNil(reopened.cachedTitles(forSection: "1"))
            closeHostWindow()
        }
    }

    func testFinishingEditingReportsTheEditedSectionsForUploading() {
        let source = CYLEditableTagSource(sections: [["Recent A"], ["Family", "Friends", "Clients"]])
        source.editableSections = [1]
        let view = makeList(source)
        var reported: [String: [String]]?
        view.editingFinishHandler = { reported = $0 }
        view.setEditing(true, animated: false)
        let collection = view.subviews.compactMap { $0 as? UICollectionView }.first!
        view.collectionView(collection, moveItemAt: IndexPath(item: 2, section: 1), to: IndexPath(item: 0, section: 1))
        XCTAssertNil(reported, "nothing before editing ends")
        view.setEditing(false, animated: false)
        XCTAssertEqual(reported, ["1": ["Clients", "Family", "Friends"]], "the edited section, in its new order")
    }

    private func loads(policy: CYLTagListLoadPolicy, cached: [String]?, remote: [String]?) -> (events: [String], stored: [String]?) {
        let name = "CYLTagListEditingTests.load"
        let store = CYLTagListStore(policy: .userDefaults, name: name)
        store.removeAllTitles()
        if let cached {
            store.saveTitles(cached, forSection: "mine")
        }
        let view = CYLTagListView(frame: .zero)
        view.cache = store
        let fake = CYLFakeRemoteSource(sections: remote.map { ["mine": $0] })
        view.remoteSource = fake
        view.loadPolicy = policy
        var events: [String] = []
        let done = expectation(description: "loaded")
        done.isInverted = true
        view.loadSections(withKeys: ["mine"]) { sections, origin in
            events.append("\(origin == .cache ? "cache" : "network") \(sections["mine"]?.joined(separator: ",") ?? "-")")
        }
        wait(for: [done], timeout: 0.2)
        let stored = store.cachedTitles(forSection: "mine")
        store.removeAllTitles()
        return (events, stored)
    }

    func testLoadPoliciesOrderTheCacheAndTheServer() {
        let refreshed = loads(policy: .cacheThenNetwork, cached: ["A", "B"], remote: ["B", "A", "C"])
        XCTAssertEqual(refreshed.events, ["cache A,B", "network B,A,C"], "the default: the cache, then the server")
        XCTAssertEqual(refreshed.stored, ["B", "A", "C"], "a download is saved to the cache")
        XCTAssertEqual(loads(policy: .cacheThenNetwork, cached: ["A"], remote: nil).events, ["cache A"], "a failed download")
        XCTAssertEqual(loads(policy: .cacheFirst, cached: ["A"], remote: ["B"]).events, ["cache A"], "a full cache: no download")
        XCTAssertEqual(loads(policy: .cacheFirst, cached: nil, remote: ["B"]).events, ["network B"])
        XCTAssertEqual(loads(policy: .networkFirst, cached: ["A"], remote: ["B"]).events, ["network B"])
        XCTAssertEqual(loads(policy: .networkFirst, cached: ["A"], remote: nil).events, ["cache A"], "the cache when it fails")
        XCTAssertEqual(CYLTagListView(frame: .zero).loadPolicy, .cacheThenNetwork, "the core's default")
    }

    func testRenamingShowsTwoIconsRenamesAndKeepsTheIdentifier() {
        let name = "CYLTagListEditingTests.rename"
        CYLTagListStore(policy: .userDefaults, name: name).removeAllTitles()
        let source = CYLEditableTagSource(sections: [["Recent A"], ["Family", "Friends", "Clients"]])
        source.editableSections = [1]
        let view = makeList(source)
        view.cacheName = name
        view.cachePolicy = .userDefaults
        view.setEditing(true, animated: false)
        XCTAssertFalse(cell(view, 0, 1)?.isRenamable ?? true, "no rename indicator without menuRenameItem")
        source.renames = true
        view.reloadMenuData()
        let renamable = cell(view, 0, 1)
        XCTAssertTrue(renamable?.isRenamable ?? false, "a pencil before the cross")
        XCTAssertFalse(renamable?.button.editingIndicatorsView.isHidden ?? true, "drawn by the two-icon stack view")
        XCTAssertEqual(renamable?.button.editingIndicatorsView.itemViews.count, 2)
        XCTAssertGreaterThan(renamable?.button.renameIndicatorHitFrame.width ?? 0, 0)
        if let icons = renamable?.button.editingIndicatorsView.itemViews, icons.count == 2, let stack = renamable?.button.editingIndicatorsView {
            stack.layoutIfNeeded()
            let gap = icons[1].convert(icons[1].bounds, to: stack).minX - icons[0].convert(icons[0].bounds, to: stack).maxX
            XCTAssertEqual(gap, 10, accuracy: 0.5, "the default space between the two icons is the style's")
            XCTAssertEqual(icons[1].convert(icons[1].bounds, to: stack).maxX, stack.bounds.maxX, accuracy: 0.5,
                           "the icons fill the stack: no gap after the cross")
        }
        let wider = CYLMenuStyle()
        wider.editingIndicatorSpacing = 20
        XCTAssertEqual(CYLTagButton.width(forTitle: "Family", iconSize: .zero, showsDeleteIndicator: true, showsRenameIndicator: true,
                                          style: wider, traitCollection: nil)
                       - CYLTagButton.width(forTitle: "Family", iconSize: .zero, showsDeleteIndicator: true, showsRenameIndicator: true,
                                            style: CYLMenuStyle(), traitCollection: nil), 10, accuracy: 0.5,
                       "editingIndicatorSpacing widens the tag by the extra space")
        let padded = CYLMenuStyle()
        padded.editingIndicatorInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 6)
        XCTAssertEqual(CYLTagButton.width(forTitle: "Family", iconSize: .zero, showsDeleteIndicator: true, showsRenameIndicator: true,
                                          style: padded, traitCollection: nil)
                       - CYLTagButton.width(forTitle: "Family", iconSize: .zero, showsDeleteIndicator: true, showsRenameIndicator: true,
                                            style: CYLMenuStyle(), traitCollection: nil), 12, accuracy: 0.5,
                       "editingIndicatorInsets (left 10 + right 6 instead of 4 + 0) widens the tag")
        XCTAssertEqual(CYLMenuStyle().editingIndicatorInsets, UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0), "the default margins")
        XCTAssertFalse(cell(view, 0, 0)?.isRenamable ?? true, "not outside the editable sections")
        XCTAssertTrue(renamable?.renamesOnTitleTap ?? false, "a tap on the title renames too, by default")
        let titleArea = renamable?.contentView.subviews.first { $0.accessibilityIdentifier == CYLTagListAccessibilityIdentifier.renameTitle }
        XCTAssertGreaterThan(titleArea?.frame.width ?? 0, 0)
        (titleArea as? UIControl)?.sendActions(for: .touchUpInside)
        XCTAssertEqual(view.renamingIndexPath, IndexPath(item: 0, section: 1), "the title tap starts renaming")
        view.finishRenaming(to: "Family")
        XCTAssertNil(view.renamingIndexPath, "an unchanged name only ends renaming")
        view.renamesOnTitleTapWhileEditing = false
        XCTAssertFalse(cell(view, 0, 1)?.renamesOnTitleTap ?? true)
        view.renamesOnTitleTapWhileEditing = true

        let collection = view.subviews.compactMap { $0 as? UICollectionView }.first!
        view.collectionView(collection, moveItemAt: IndexPath(item: 1, section: 1), to: IndexPath(item: 0, section: 1))
        view.beginRenaming(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(view.renamingIndexPath, IndexPath(item: 0, section: 1))
        XCTAssertTrue(view.addItemView.isRenaming)
        XCTAssertEqual(view.addItemView.textField.text, "Friends", "the field shows the title to rename")
        view.addItemView.textField.text = "Best Friends"
        view.addItemView.submit()
        XCTAssertNil(view.renamingIndexPath)
        XCTAssertFalse(view.addItemView.isRenaming, "the control adds tags again")
        XCTAssertEqual(source.sections[1], ["Best Friends", "Family", "Clients"])
        XCTAssertEqual(source.events.last, "rename 0-1 Best Friends")
        let items = CYLTagListStore(policy: .userDefaults, name: name).cachedItems(forSection: "1")
        XCTAssertEqual(items?.map(\.identifier), ["id-Friends", "id-Family", "id-Clients"], "reordered and renamed, the same ids")
        XCTAssertEqual(items?.map(\.title), ["Best Friends", "Family", "Clients"])
        var finished: [String: [CYLTagListCacheItem]]?
        let delegate = CYLItemsRecorder { finished = $0 }
        view.menuDelegate = delegate
        view.setEditing(false, animated: false)
        XCTAssertEqual(finished?["1"]?.first, CYLTagListCacheItem(identifier: "id-Friends", title: "Best Friends"))
        CYLTagListStore(policy: .userDefaults, name: name).removeAllTitles()
    }

    func testLoadItemsKeepsIdentifiersFromTheServer() {
        let name = "CYLTagListEditingTests.items"
        let store = CYLTagListStore(policy: .sandboxFile, name: name)
        store.removeAllTitles()
        store.saveItems([CYLTagListCacheItem(identifier: "t1", title: "Family")], forSection: "mine")
        XCTAssertEqual(store.cachedTitles(forSection: "mine"), ["Family"], "the titles follow the items")
        let view = CYLTagListView(frame: .zero)
        view.cache = store
        let renamedOnServer = [CYLTagListCacheItem(identifier: "t2", title: "Work"), CYLTagListCacheItem(identifier: "t1", title: "Home")]
        view.remoteSource = CYLFakeItemsRemoteSource(items: ["mine": renamedOnServer])
        var events: [String] = []
        let wait = expectation(description: "loaded")
        wait.isInverted = true
        view.loadItems(withKeys: ["mine"]) { items, origin in
            events.append("\(origin == .cache ? "cache" : "network") \(items["mine"]?.map(\.description).joined(separator: ",") ?? "-")")
        }
        self.wait(for: [wait], timeout: 0.2)
        XCTAssertEqual(events, ["cache t1:Family", "network t2:Work,t1:Home"])
        XCTAssertEqual(store.cachedItems(forSection: "mine"), renamedOnServer, "the server's items are saved with their ids")
        store.saveTitles(["A"], forSection: "mine")
        XCTAssertEqual(store.cachedItems(forSection: "mine")?.first?.identifier, "A", "plain titles: each title is its id")
        store.removeAllTitles()
    }
}


extension CYLTagListEditingTests {
    func testAnExternalEditorRenamesAndAdds() {
        let source = CYLEditableTagSource(sections: [["Family", "Friends"]])
        source.renames = true
        let view = makeList(source)
        view.showsAddItemViewWhileEditing = false
        var request: (IndexPath, String)?
        view.renameRequestHandler = { request = ($0, $1) }
        view.setEditing(true, animated: false)
        XCTAssertFalse(view.addItemView.isDescendant(of: view), "no built-in field")
        view.beginRenaming(at: IndexPath(item: 1, section: 0))
        XCTAssertEqual(request?.0, IndexPath(item: 1, section: 0))
        XCTAssertEqual(request?.1, "Friends", "the host's editor gets the title")
        XCTAssertFalse(view.addItemView.isDescendant(of: view), "still no built-in field while the host renames")
        view.finishRenaming(to: "Pals")
        XCTAssertEqual(source.sections[0], ["Family", "Pals"])
        view.beginRenaming(at: IndexPath(item: 0, section: 0))
        view.cancelRenaming()
        XCTAssertNil(view.renamingIndexPath)
        XCTAssertEqual(source.sections[0], ["Family", "Pals"], "cancelling changes nothing")
        view.submitNewItem(named: "  Clients ")
        XCTAssertEqual(source.sections[0], ["Family", "Pals", "Clients"], "the host's field adds, trimmed")
    }
}


/**
 * Two sections; the first shows the header's clear button, and the taps are recorded.
 */
private final class CYLClearableSource: NSObject, CYLMenuDataSource, CYLMenuDelegate {
    var sections = [["Coworkers", "Clients"], ["Family"]]
    private(set) var cleared: [Int] = []
    func numberOfSectionsInMenu() -> Int { sections.count }
    func menuNumberOfItems(inSection section: Int) -> Int { sections[section].count }
    func menuTitle(forSection section: Int) -> String { section == 0 ? "Recent" : "My Tags" }
    func menuTitleForItem(at indexPath: IndexPath) -> String { sections[indexPath.section][indexPath.item] }
    func menuShowsClearButton(forSection section: Int) -> Bool { section == 0 }
    func menu(_ menu: Any, didTapClearButtonInSection section: Int) { cleared.append(section) }
}

extension CYLTagListEditingTests {
    func testTheHeaderClearButtonIsBuiltInAndAlignedWithTheTitle() {
        let source = CYLClearableSource()
        let view = CYLTagListView(frame: .zero)
        view.menuDataSource = source
        view.menuDelegate = source
        view.showsSectionHeaders = true
        show(view, size: CGSize(width: 320, height: 500))
        view.reloadMenuData()
        view.layoutIfNeeded()
        var handled: [Int] = []
        view.clearButtonHandler = { handled.append($0) }
        func clearButton(inSection section: Int) -> UIButton? {
            view.probe.header(inSection: section)?.subviews.compactMap { $0 as? UIButton }
                .first { $0.accessibilityIdentifier == CYLTagListAccessibilityIdentifier.clearButton }
        }
        let button = clearButton(inSection: 0)
        XCTAssertNotNil(button)
        XCTAssertFalse(button?.isHidden ?? true, "shown for the section that asks for it")
        XCTAssertNotNil(button?.currentImage, "the bundle's trash icon")
        XCTAssertEqual(button?.accessibilityLabel, CYLMenuLocalizedString("CYLMenuClearSection") + " Recent")
        XCTAssertTrue(clearButton(inSection: 1)?.isHidden ?? true, "hidden elsewhere")
        // The rule: its top and bottom are the title text's.
        if let button, let header = view.probe.header(inSection: 0) {
            let labels = header.subviews.flatMap { [$0] + $0.subviews }.compactMap { $0 as? UILabel }
            let title = labels.first { $0.text == "Recent" }
            XCTAssertNotNil(title)
            if let title {
                let text = title.convert(title.bounds, to: header)
                XCTAssertEqual(button.frame.minY, text.minY, accuracy: 0.5, "top aligned with the title")
                XCTAssertEqual(button.frame.maxY, text.maxY, accuracy: 0.5, "bottom aligned with the title")
            }
            XCTAssertTrue(button.point(inside: CGPoint(x: button.bounds.midX, y: button.bounds.midY - 20), with: nil),
                          "a 44 point tap area")
        }
        button?.sendActions(for: .touchUpInside)
        XCTAssertEqual(source.cleared, [0], "the delegate hears the tap")
        XCTAssertEqual(handled, [0], "and the closure")
        XCTAssertNotNil(CYLMenuResources.image(named: "cyl_trash"), "the icon is in the core bundle")
        let folder = CYLMenuResources.imagesBundle
        XCTAssertEqual(folder?.bundleURL.lastPathComponent, "CYLClassifyMenuImages.bundle", "new images live in a folder bundle")
        XCTAssertNotNil(folder.flatMap { UIImage(named: "cyl_trash", in: $0, compatibleWith: nil) }, "the trash icon is a file there")
    }
}

/**
 * Records `menu(_:didFinishEditingWithItems:)`.
 */
private final class CYLItemsRecorder: NSObject, CYLMenuDelegate {
    let handler: ([String: [CYLTagListCacheItem]]) -> Void

    init(_ handler: @escaping ([String: [CYLTagListCacheItem]]) -> Void) {
        self.handler = handler
    }

    func menu(_ menu: Any, didFinishEditingWithItems items: [String: [CYLTagListCacheItem]]) {
        handler(items)
    }
}
