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
    var editableSections: IndexSet?
    private(set) var events: [String] = []

    init(sections: [[String]]) {
        self.sections = sections
    }

    func numberOfSectionsInMenu() -> Int { sections.count }
    func menuNumberOfItems(inSection section: Int) -> Int { sections[section].count }
    func menuTitle(forSection section: Int) -> String { "Section \(section)" }
    func menuTitleForItem(at indexPath: IndexPath) -> String { sections[indexPath.section][indexPath.item] }
    func menuSectionAllowsEditing(_ section: Int) -> Bool { editableSections?.contains(section) ?? true }
    func menuRemoveItem(at indexPath: IndexPath) { sections[indexPath.section].remove(at: indexPath.item) }

    func menuMoveItem(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let title = sections[sourceIndexPath.section].remove(at: sourceIndexPath.item)
        sections[destinationIndexPath.section].insert(title, at: destinationIndexPath.item)
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
        (menu as? CYLTagListView)?.reloadMenuData()
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
}
