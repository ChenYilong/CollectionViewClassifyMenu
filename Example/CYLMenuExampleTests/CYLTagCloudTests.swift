//
//  CYLTagCloudTests.swift
//  CYLMenuExampleTests
//
//  The android-tagview API (docs/android-tagview-api.md): CYLTag and its initializers, the list's tag methods and
//  handlers, deletable tags, pressed colors, background images, per-side content insets, per-tag text sizes, the
//  Interface Builder shortcuts, the configuration keys and the 标签云 demo.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLTagCloudTests: CYLMenuExampleTestCase {

    /// A list created the android-tagview way, shown in a window.
    private func showTagCloud(width: CGFloat = 375, _ fill: (CYLTagListView) -> Void) -> CYLTagListView {
        let list = CYLTagListView()
        fill(list)
        show(list, size: CGSize(width: width, height: 700))
        list.probe.layOut()
        return list
    }

    // MARK: Tag (android-tagview's Tag)

    func testTagInitializersMatchAndroidTagView() {
        XCTAssertEqual(CYLTag(title: "A").title, "A")
        XCTAssertEqual(CYLTag(title: "A").identifier, 0)
        XCTAssertEqual(CYLTag(title: "A", backgroundColor: .red).backgroundColor, .red)
        let hex = CYLTag(title: "A", backgroundColorHex: "#00BFFF")
        let components = CYLColorComponents(hex.backgroundColor)
        XCTAssertEqual(components.blue, 1, accuracy: 0.01)
        XCTAssertEqual(components.green, 0xBF / 255.0, accuracy: 0.01)
        XCTAssertEqual(CYLTag(identifier: 4, title: "B").identifier, 4)
        XCTAssertEqual(CYLTag(identifier: 4, title: "B", backgroundColor: .blue).backgroundColor, .blue)
        XCTAssertNotNil(CYLTag(identifier: 4, title: "B", backgroundColorHex: "systemBlue").backgroundColor)
        XCTAssertNil(CYLTag(title: "C", backgroundColorHex: "not a color").backgroundColor)

        let tag = CYLTagCloudDemoViewController.detailedTag()
        XCTAssertTrue(tag.hasCustomStyle)
        XCTAssertFalse(CYLTag(title: "plain").hasCustomStyle)
        let copy = tag.copy() as! CYLTag
        XCTAssertEqual(copy.identifier, 7)
        XCTAssertTrue(copy.isDeletable)
        XCTAssertEqual(copy.cornerRadius, 20)

        // Every look property lands in the style (android-tagview's tagTextColor, layoutColor, layoutColorPress…).
        let style = tag.style(basedOn: CYLMenuStyle())
        XCTAssertEqual(style.normalAppearance.textColor, .white)
        XCTAssertEqual(style.highlightedBackgroundColor, UIColor(white: 0.33, alpha: 1))
        XCTAssertEqual(style.normalAppearance.cornerRadius, 20)
        XCTAssertEqual(style.selectedAppearance.cornerRadius, 20)
        XCTAssertEqual(style.normalAppearance.font.pointSize, 14)
        XCTAssertEqual(style.normalAppearance.borderWidth, 1)
        XCTAssertEqual(style.normalAppearance.borderColor, .white)
        let custom = CYLTagCloudDemoViewController.styledTags()[3].style(basedOn: CYLMenuStyle())
        XCTAssertEqual(custom.deleteIndicatorTitle, "⊗")
        XCTAssertEqual(custom.deleteIndicatorFont?.pointSize, 18)
        XCTAssertEqual(CYLMenuStyle().deleteIndicatorTitle, "×")
    }

    // MARK: TagView: addTag, addTags, getTags, remove, removeAllTags, listeners

    func testTagMethodsAndClickHandler() {
        var clicks: [String] = []
        let list = showTagCloud { list in
            list.addTags(withTitles: ["Asia", "Africa", "Europe"])
            list.addTag(CYLTag(identifier: 9, title: "Australia"))
            list.addTags([CYLTag(title: "Antarctica")])
            list.tagClickHandler = { index, tag in clicks.append("\(index) \(tag.title)") }
        }
        XCTAssertEqual(list.tags.map(\.title), ["Asia", "Africa", "Europe", "Australia", "Antarctica"])
        XCTAssertTrue(list.menuDataSource === list.tagDataSource)
        XCTAssertFalse(list.showsSectionHeaders, "android-tagview has no section headers")
        XCTAssertEqual(list.selectionMode, .none, "android-tagview only reports clicks")
        XCTAssertEqual(list.probe.numberOfItems(inSection: 0), 5)

        list.probe.tap(item: 3, section: 0)
        list.probe.tap(item: 3, section: 0)
        XCTAssertEqual(clicks, ["3 Australia", "3 Australia"])
        XCTAssertEqual(list.selectedIndexPaths, [])

        list.insertTag(CYLTag(title: "Oceania"), at: 0)
        XCTAssertEqual(list.tags.first?.title, "Oceania")
        list.removeTag(at: 1)
        list.removeTag(at: 99)
        XCTAssertEqual(list.tags.map(\.title), ["Oceania", "Africa", "Europe", "Australia", "Antarctica"])
        list.probe.layOut()
        XCTAssertEqual(list.probe.numberOfItems(inSection: 0), 5)

        // Selection still works when the host turns it on; removing a tag moves later selections up.
        list.selectionMode = .multiple
        list.selectedIndexPaths = [ip(1, 0), ip(3, 0)]
        list.removeTag(at: 2)
        XCTAssertEqual(list.selectedIndexPaths, [ip(1, 0), ip(2, 0)])
        list.removeAllTags()
        XCTAssertEqual(list.tags.count, 0)
        XCTAssertEqual(list.selectedIndexPaths, [])
    }

    // MARK: Deletable tags (isDeletable, deleteIcon, OnTagDeleteListener)

    func testDeleteIndicatorRemovesTheTag() {
        var deleted: [String] = []
        let delegate = CYLRecordingMenuDelegate()
        let list = showTagCloud { list in
            list.addTags(withTitles: ["Keep", "Also keep"])
            let tag = CYLTag(title: "Delete me")
            tag.isDeletable = true
            list.addTag(tag)
            list.tagDeleteHandler = { index, tag in deleted.append("\(index) \(tag.title)") }
            list.menuDelegate = delegate
        }
        let plain = list.probe.tagButton(at: ip(0, 0))
        let deletable = list.probe.tagButton(at: ip(2, 0))
        XCTAssertFalse(plain?.showsDeleteIndicator ?? true)
        XCTAssertTrue(deletable?.showsDeleteIndicator ?? false)
        XCTAssertEqual(deletable?.deleteIndicatorLabel.text, "×")
        XCTAssertFalse(deletable?.deleteIndicatorLabel.isHidden ?? true)
        // The indicator is inside the tag, after the title.
        if let button = deletable {
            XCTAssertGreaterThan(button.deleteIndicatorLabel.frame.minX, button.titleLabel.frame.maxX)
            XCTAssertLessThanOrEqual(button.deleteIndicatorLabel.frame.maxX, button.bounds.width)
        }
        let cell = list.probe.cell(at: ip(2, 0))
        XCTAssertEqual(cell?.accessibilityCustomActions?.first?.name, "删除")
        captureScreen(named: "test-tag-cloud-deletable")

        // A tap on the × (the cell's delete control) deletes; a tap on the title does not.
        let control = cell?.contentView.views(withIdentifier: CYLTagListAccessibilityIdentifier.deleteButton).first as? UIControl
        XCTAssertNotNil(control)
        XCTAssertFalse(control?.isHidden ?? true)
        control?.sendActions(for: .touchUpInside)
        XCTAssertEqual(deleted, ["2 Delete me"])
        XCTAssertEqual(delegate.events, ["delete 2-0"])
        XCTAssertEqual(list.tags.map(\.title), ["Keep", "Also keep"])
        list.probe.layOut()
        XCTAssertEqual(list.probe.numberOfItems(inSection: 0), 2)

        // Not deletable: nothing happens.
        list.deleteItem(at: ip(0, 0))
        XCTAssertEqual(list.tags.count, 2)
    }

    func testDeletableItemsOfAHostDataSourceAndAConfiguration() {
        // A configuration's section items: "deletable" removes them from the view's own data.
        let list = CYLTagListView(configuration: [
            CYLTagListKey.sections: [[CYLTagSectionKey.title: "A",
                                      CYLTagSectionKey.items: [[CYLTagItemKey.title: "x", CYLTagItemKey.deletable: true], "y"]]],
        ])
        show(list, size: CGSize(width: 375, height: 300))
        list.probe.layOut()
        XCTAssertTrue(list.probe.tagButton(at: ip(0, 0))?.showsDeleteIndicator ?? false)
        list.selectedIndexPaths = [ip(1, 0)]
        list.deleteItem(at: ip(0, 0))
        XCTAssertEqual(list.menuDataSource?.menuNumberOfItems(inSection: 0), 1)
        XCTAssertEqual(list.menuDataSource?.menuTitleForItem(at: ip(0, 0)), "y")
        XCTAssertEqual(list.selectedIndexPaths, [ip(0, 0)], "the selection moved up with its item")
    }

    // MARK: Look: pressed color, background image, text size, padding

    func testPressedColorBackgroundImageAndTextSize() {
        let list = showTagCloud { list in
            list.addTags(withTitles: ["Small"])
            list.addTags(CYLTagCloudDemoViewController.styledTags())
        }
        let probe = list.probe
        // layoutColorPress: the cell's highlight shows the pressed color.
        let blueCell = probe.cell(at: ip(1, 0))
        let blue = probe.tagButton(at: ip(1, 0))
        let normal = blue?.layer.backgroundColor
        blueCell?.isHighlighted = true
        XCTAssertTrue(blue?.isHighlighted ?? false)
        XCTAssertEqual(blue?.layer.backgroundColor, UIColor(red: 0, green: 0.5, blue: 0.7, alpha: 1).cgColor)
        blueCell?.isHighlighted = false
        XCTAssertEqual(blue?.layer.backgroundColor, normal)

        // tagTextSize: a larger text makes that tag taller than the others.
        let small = probe.itemFrame(at: ip(0, 0))?.height ?? 0
        let large = probe.itemFrame(at: ip(2, 0))?.height ?? 0
        XCTAssertGreaterThan(large, small)
        XCTAssertEqual(probe.tagButton(at: ip(2, 0))?.titleLabel.font.pointSize ?? 0, 22, accuracy: 6, "scaled for Dynamic Type")

        // background: drawn behind the title.
        let image = probe.tagButton(at: ip(3, 0))
        let background = image?.subviews.compactMap { $0 as? UIImageView }.first { $0.image != nil && $0 !== image?.imageView }
        XCTAssertNotNil(background)
        XCTAssertEqual(background?.frame, image?.bounds)
        // contentHeight follows the per-tag heights, also after the collection view laid itself out first.
        list.layoutIfNeeded()
        XCTAssertEqual(list.contentHeight, list.heightThatFitsWidth(375), accuracy: 1)
    }

    func testSpacingShortcutsAndContentInsets() {
        let list = showTagCloud { list in
            list.lineSpacing = 20
            list.interitemSpacing = 20
            list.tagContentInsets = UIEdgeInsets(top: 3, left: 20, bottom: 3, right: 20)
            list.addTags(withTitles: ["One", "Two"])
        }
        XCTAssertEqual(list.style.lineSpacing, 20)
        XCTAssertEqual(list.style.interitemSpacing, 20)
        XCTAssertEqual(list.style.selectedAppearance.contentInsets, UIEdgeInsets(top: 3, left: 20, bottom: 3, right: 20))
        XCTAssertEqual(list.style.normalAppearance.margin, 20)
        let first = list.probe.itemFrame(at: ip(0, 0)) ?? .zero
        let second = list.probe.itemFrame(at: ip(1, 0)) ?? .zero
        XCTAssertEqual(second.minX - first.maxX, 20, accuracy: 0.5)
        let title = list.probe.tagButton(at: ip(0, 0))?.titleLabel.frame ?? .zero
        XCTAssertEqual(title.minX, 20, accuracy: 1)
        XCTAssertEqual(first.width - title.maxX, 20, accuracy: 1)

        // The Interface Builder setters (IBInspectable) edit one side each.
        list.tagContentInsetTop = 12
        list.tagContentInsetBottom = 12
        list.tagContentInsetLeft = 4
        list.tagContentInsetRight = 6
        XCTAssertEqual(list.tagContentInsets, UIEdgeInsets(top: 12, left: 4, bottom: 12, right: 6))
        XCTAssertEqual(list.tagContentInsetTop, 12)
        list.probe.layOut()
        let font = list.style.titleFont(for: .normal, traitCollection: list.traitCollection)
        XCTAssertEqual(list.probe.itemFrame(at: ip(0, 0))?.height ?? 0, max(30, ceil(font.lineHeight) + 24), accuracy: 0.5)
        XCTAssertEqual(CYLMenuStyle().tagContentInsets, UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
    }

    // MARK: Configuration and the demo

    func testTagsFromAConfiguration() {
        let list = CYLTagListView(configuration: CYLTagCloudDemoViewController.mapConfiguration())
        show(list, size: CGSize(width: 375, height: 300))
        list.probe.layOut()
        XCTAssertEqual(list.tags.map(\.title), ["Asia", "Europe", "Africa", "Australia"])
        XCTAssertEqual(list.tags[2].identifier, 3)
        XCTAssertTrue(list.tags[2].isDeletable)
        XCTAssertNotNil(list.tags[3].image)
        XCTAssertEqual(list.style.lineSpacing, 5)
        XCTAssertEqual(list.style.tagContentInsets, UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10))
        let africa = list.probe.tagButton(at: ip(2, 0))
        XCTAssertEqual(africa?.style.highlightedBackgroundColor, UIColor.cylMenuColor(from: "#88363636"))
        XCTAssertEqual(CYLColorComponents(africa?.titleLabel.textColor), CYLColorComponents(.white))

        let style = CYLMenuStyle(configuration: [
            CYLMenuStyleKey.deleteIndicatorTitle: "✕",
            CYLMenuStyleKey.deleteIndicatorColor: "#FF0000",
            CYLMenuStyleKey.deleteIndicatorFont: 16,
            CYLMenuStyleKey.normal: [CYLTagAppearanceKey.contentInsets: [1, 2, 3, 4], CYLTagAppearanceKey.backgroundImage: "system:star"],
        ])
        XCTAssertEqual(style.deleteIndicatorTitle, "✕")
        XCTAssertEqual(style.deleteIndicatorColor, UIColor.cylMenuColor(from: "#FF0000"))
        XCTAssertEqual(style.deleteIndicatorFont?.pointSize, 16)
        XCTAssertEqual(style.normalAppearance.contentInsets, UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4))
        XCTAssertNotNil(style.normalAppearance.backgroundImage)
    }

    func testTagCloudDemo() {
        let demo = CYLTagCloudDemoViewController()
        showInNavigation(demo)
        demo.view.layoutIfNeeded()
        let list = demo.codeTagListView!
        list.probe.layOut()
        XCTAssertEqual(list.tags.count, CYLTagCloudDemoViewController.continents.count + 5)
        list.assertItemsFit()
        captureScreen(named: "test-tag-cloud-android-api")

        list.probe.tap(item: 0, section: 0)
        XCTAssertEqual(demo.eventLabel.text, "点击第 0 个「Asia」")
        let detailed = CYLTagCloudDemoViewController.continents.count
        list.deleteItem(at: ip(detailed, 0))
        XCTAssertEqual(demo.eventLabel.text, "删除第 7 个「Tag Text」")
        XCTAssertFalse(list.tags.contains { $0.title == "Tag Text" })
        demo.view.layoutIfNeeded()
        XCTAssertEqual(list.bounds.height, list.heightThatFitsWidth(list.bounds.width), accuracy: 1)

        // Reached from the 样式 tab.
        let styles = CYLTagStyleDemoViewController()
        let navigation = showInNavigation(styles)
        styles.performAction("tagCloud")
        XCTAssertTrue(navigation.topViewController is CYLTagCloudDemoViewController)
    }
}
