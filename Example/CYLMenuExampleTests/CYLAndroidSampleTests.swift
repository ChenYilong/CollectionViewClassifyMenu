//
//  CYLAndroidSampleTests.swift
//  CYLMenuExampleTests
//
//  The Swift ports of three Android samples (android-tagview, TagViewGroup, AndroidTagView) and the core features
//  behind them: container borders, row alignment, color themes, a drawn cross, ripples, reordering, long presses,
//  picture tags. docs/android-tagview-api.md, docs/tagviewgroup-api.md, docs/androidtagview-api.md.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
import CYLSearchViewController
@testable import CYLMenuExample

final class CYLAndroidSampleTests: CYLMenuExampleTestCase {

    override func setUp() {
        super.setUp()
        CYLImageTagSampleData.tagGroups = CYLImageTagSampleData.initialGroups()
    }

    // MARK: android-tagview

    func testTagCloudSampleMainScreen() {
        let sample = CYLTagCloudSampleViewController()
        let navigation = showInNavigation(sample)
        sample.view.layoutIfNeeded()
        let list = sample.tagListView!
        list.probe.layOut()
        XCTAssertEqual(list.tags.count, 7 + 4 + 5 + 3 + 3 + 3)
        XCTAssertEqual(list.style.tagContentInsets, UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10))
        captureScreen(named: "test-sample-tag-cloud")

        // Round Corner 0 is square, 20 px rounded, the default a capsule.
        let squareIndex = list.tags.firstIndex { $0.title == "Round Corner" } ?? 0
        list.scrollToItem(at: ip(squareIndex, 0), animated: false)
        list.probe.layOut()
        XCTAssertEqual(list.tagButton(at: ip(squareIndex, 0))?.layer.cornerRadius, 0)
        let first = list.tagButton(at: ip(0, 0))
        list.scrollToItem(at: ip(0, 0), animated: false)
        list.probe.layOut()
        XCTAssertEqual(list.tagButton(at: ip(0, 0))?.layer.cornerRadius ?? 0, (list.tagButton(at: ip(0, 0))?.bounds.height ?? 0) / 2, accuracy: 0.5)
        _ = first

        list.probe.tap(item: 2, section: 0)
        XCTAssertEqual(CYLAndroidSample.toastText(in: sample.view), "click tag id = 2 position = 2")

        sample.random = { _ in 0 }
        sample.textField.text = "NEW"
        sample.addTag()
        XCTAssertEqual(list.tags.last?.title, "NEW")
        XCTAssertTrue(list.tags.last?.isDeletable ?? false)
        sample.textField.text = ""
        sample.addTag()
        XCTAssertEqual(list.tags.last?.title, "ADD A TAG")

        sample.openActivityResult()
        let sub = navigation.topViewController as? CYLTagCloudSubViewController
        XCTAssertNotNil(sub)
        sub?.finish()
        XCTAssertEqual(list.tags.last?.title, "ADD AFTER ACTIVITY RESULT")
    }

    func testTagCloudListAndRecyclerScreens() {
        let listScreen = CYLTagCloudListViewController()
        showInNavigation(listScreen)
        listScreen.tableView.layoutIfNeeded()
        XCTAssertEqual(listScreen.tableView.numberOfRows(inSection: 0), 51)
        let cell = listScreen.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? CYLTagCloudListCell
        XCTAssertEqual(cell?.tagListView.tags.map(\.title), ["ITEM 1", "ITEM 1", "ITEM 1"])
        XCTAssertGreaterThan(cell?.bounds.height ?? 0, 20)
        captureScreen(named: "test-sample-tag-cloud-list")

        let recycler = CYLTagCloudRecyclerViewController()
        showInNavigation(recycler)
        recycler.tableView.layoutIfNeeded()
        XCTAssertEqual(recycler.tableView.numberOfRows(inSection: 0), 22)
        let footer = recycler.tableView.dataSource?.tableView(recycler.tableView, cellForRowAt: IndexPath(row: 21, section: 0)) as? CYLTagCloudListCell
        XCTAssertEqual(footer?.tagListView.tags.map(\.title), ["FOOTER 1", "FOOTER 2"])
    }

    func testHotSearchScreen() {
        let screen = CYLHotSearchViewController()
        showInNavigation(screen)
        screen.view.layoutIfNeeded()
        let bar = screen.searchBar!
        XCTAssertEqual(bar.placeholder, "主播昵称/直播间ID/神曲名")
        XCTAssertFalse(bar.cancelButton.isHidden)
        XCTAssertEqual(bar.cancelButton.configuration?.attributedTitle.map { String($0.characters) }, "取消")
        let list = screen.tagListView!
        list.probe.layOut()
        XCTAssertEqual(list.tags.count, 10)
        XCTAssertEqual(list.probe.headerTitleLabel(inSection: 0)?.text, "热门搜索")
        let header = list.probe.header(inSection: 0)
        let bar3 = header?.subviews.first { $0.backgroundColor == CYLHotSearchViewController.orange && !$0.isHidden }
        XCTAssertNotNil(bar3, "the orange bar before 热门搜索")
        XCTAssertEqual(bar3?.frame.width, 3)
        // 神 and 热 badges, drawn by the core.
        XCTAssertNotNil(list.tagButton(at: ip(0, 0))?.imageView.image)
        XCTAssertEqual(list.tagButton(at: ip(0, 0))?.imageView.image?.accessibilityLabel, "神")
        XCTAssertEqual(list.tagButton(at: ip(4, 0))?.imageView.image?.accessibilityLabel, "热")
        XCTAssertNil(list.tagButton(at: ip(2, 0))?.imageView.image)
        XCTAssertEqual(list.tagButton(at: ip(4, 0))?.titleLabel.textColor, CYLHotSearchViewController.red)
        captureScreen(named: "test-sample-hot-search")
        list.probe.tap(item: 1, section: 0)
        XCTAssertEqual(bar.text, "他和她")
    }

    // MARK: TagViewGroup

    func testImageTagSampleMainScreen() {
        let sample = CYLImageTagSampleViewController()
        showInNavigation(sample)
        sample.view.layoutIfNeeded()
        let imageView = sample.tagImageView!
        imageView.layoutIfNeeded()
        XCTAssertEqual(imageView.groupViews.count, 2)
        let group = imageView.groupViews[0]
        group.layoutIfNeeded()
        XCTAssertEqual(group.tagViews.count, 3)
        XCTAssertTrue(group.showsRipple)
        let center = group.centerPoint
        XCTAssertEqual(center.x, imageView.bounds.width * 0.4, accuracy: 1)
        // RIGHT_TOP: from the center, the tag's bottom one vertical distance above it.
        let top = group.tagViews[0].frame
        XCTAssertEqual(top.minX, center.x, accuracy: 0.5)
        XCTAssertEqual(top.maxY, center.y - group.verticalDistance, accuracy: 0.5)
        let middle = group.tagViews[1].frame
        XCTAssertEqual(middle.maxY, center.y, accuracy: 0.5)
        XCTAssertLessThanOrEqual(middle.maxX, imageView.bounds.width + 0.5, "tags stay in the picture")
        XCTAssertEqual(group.originForTag(of: top.size, direction: .leftTopStraight).x, center.x - top.width - group.tiltDistance, accuracy: 0.5)
        XCTAssertGreaterThanOrEqual(group.tagSpaceUsed().right, middle.width)
        captureScreen(named: "test-sample-image-tag")

        imageView.toggleTagGroups(animated: false)
        XCTAssertTrue(group.isGroupHidden)
        imageView.toggleTagGroups(animated: false)
        XCTAssertFalse(group.isGroupHidden)
        XCTAssertEqual(group.linesProgress, 1)
        group.linesProgress = 0.5
        XCTAssertEqual(group.value(forKey: CYLImageTagGroupKeyLinesProgress) as? CGFloat, 0.5)
    }

    func testImageTagSampleEditAndList() {
        let edit = CYLImageTagEditViewController()
        var saved = false
        edit.onSave = { saved = true }
        showInNavigation(edit)
        edit.view.layoutIfNeeded()
        let imageView = edit.tagImageView!
        XCTAssertTrue(imageView.isEditing)
        edit.createGroup(withNames: ["上衣", "", "裤子"])
        XCTAssertEqual(imageView.tagGroups.count, 1)
        XCTAssertEqual(imageView.tagGroups[0].tags.map(\.direction), [.rightTop, .rightBottom])
        let group = imageView.groupViews[0]
        XCTAssertTrue(group.isDraggable)
        XCTAssertFalse(group.showsRipple)
        group.layoutIfNeeded()
        captureScreen(named: "test-sample-image-tag-edit")

        // A tap on a tag turns it (TagImageView.onTagClicked); a drag moves the group.
        group.delegate?.groupView?(group, didTapTagAt: 0)
        XCTAssertEqual(imageView.tagGroups[0].tags[0].direction, .rightTopStraight)
        group.delegate?.groupView?(group, didDragToPercentPosition: CGPoint(x: 0.2, y: 0.7))
        XCTAssertEqual(imageView.tagGroups[0].percentPosition, CGPoint(x: 0.2, y: 0.7))
        edit.save()
        XCTAssertTrue(saved)
        XCTAssertEqual(CYLImageTagSampleData.tagGroups.count, 1)
        XCTAssertEqual(CYLImageTagSampleData.tagGroups[0].tags.first?.title, "上衣")
        XCTAssertEqual(CYLImageTagDirectionNext(.rightBottomStraight), .leftCenter)

        CYLImageTagSampleData.tagGroups = CYLImageTagSampleData.initialGroups()
        let list = CYLImageTagListViewController()
        showInNavigation(list)
        list.tableView.layoutIfNeeded()
        XCTAssertEqual(list.tableView.numberOfRows(inSection: 0), 30)
        let cell = list.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? CYLImageTagCell
        XCTAssertEqual(cell?.tagImageView.tagGroups.first?.tags.first?.title, "很不错的鞋子")
        captureScreen(named: "test-sample-image-tag-list")
    }

    // MARK: AndroidTagView

    func testTagContainerSample() {
        let sample = CYLTagContainerSampleViewController()
        showInNavigation(sample, size: CYLTestScreen.tall)
        sample.view.layoutIfNeeded()
        sample.view.layoutIfNeeded()
        let containers = sample.containers
        XCTAssertEqual(containers.count, 5)
        containers.forEach { $0.probe.layOut() }
        let first = containers[0]
        XCTAssertEqual(first.containerCornerRadius, 10)
        XCTAssertEqual(first.layer.borderWidth, 0.5)
        // tag_max_length 23: the long Chinese tag is cut.
        XCTAssertTrue(first.tagButton(at: ip(4, 0))?.titleLabel.text?.hasSuffix("...") ?? false)
        XCTAssertEqual(first.tagButton(at: ip(4, 0))?.titleLabel.text?.count, 26)
        XCTAssertTrue(first.tagButton(at: ip(0, 0))?.showsDeleteIndicator ?? false)
        XCTAssertNotNil(first.tagButton(at: ip(0, 0))?.imageView.image, "the default avatar")
        XCTAssertGreaterThan(first.tagButton(at: ip(0, 0))?.imageView.layer.cornerRadius ?? 0, 0)
        captureScreen(named: "test-sample-tag-container")

        // A cross tap only reports (onTagCrossClick).
        first.deleteItem(at: ip(1, 0))
        XCTAssertEqual(first.tags.count, 9)
        XCTAssertEqual(CYLAndroidSample.toastText(in: sample.view), "Click TagView cross! position = 1")
        sample.textField.text = "Kotlin"
        sample.addTag()
        XCTAssertEqual(first.tags.last?.title, "Kotlin")

        // Right-to-left container: titles reversed, the cross first, rows at the trailing edge.
        let third = containers[2]
        XCTAssertEqual(third.tagButton(at: ip(3, 0))?.titleLabel.text, "olleH")
        let button = third.tagButton(at: ip(3, 0))
        XCTAssertLessThan(button?.deleteIndicatorHitFrame.minX ?? 1, 1)
        let lastFrame = third.probe.itemFrame(at: ip(5, 0)) ?? .zero
        XCTAssertEqual(lastFrame.maxX, third.bounds.width - 10, accuracy: 1)
        third.tagLongPressHandler?(1, third.tags[1])
        XCTAssertEqual(third.selectedIndexPaths, [ip(1, 0)])
        XCTAssertEqual(third.selectedTitles, ["波斯语"])
        third.probe.tap(item: 2, section: 0)
        XCTAssertEqual(third.selectedIndexPaths, [], "a tap on another tag deselects all")

        // Centered container with a ripple; random and custom colors.
        let fourth = containers[3]
        let row = (fourth.probe.itemFrame(at: ip(0, 0)) ?? .zero).union(fourth.probe.itemFrame(at: ip(1, 0)) ?? .zero)
        XCTAssertEqual(row.midX, fourth.bounds.width / 2, accuracy: 1)
        XCTAssertEqual(fourth.style.rippleDuration, 2)
        let fifth = containers[4]
        XCTAssertEqual(fifth.tagButton(at: ip(0, 0))?.layer.backgroundColor, CYLMenuColorFromString("#ff0000")?.cgColor)
        XCTAssertFalse(fifth.allowsTapping)
    }

    // MARK: Core features

    func testListContainerFeatures() {
        let list = CYLTagListView()
        list.style = .tagContainer()
        list.setTags(withTitles: ["A", "B", "C", "D", "E", "F", "G", "H"])
        show(list, size: CGSize(width: 200, height: 400))
        list.probe.layOut()
        // Themes: a pure theme colors every tag the same; random picks a palette color per item, the same every time.
        list.colorTheme = .pureTeal
        list.probe.layOut()
        let teal = CYLTagColors(for: .pureTeal, seed: 0)
        XCTAssertEqual(list.tagButton(at: ip(0, 0))?.layer.backgroundColor, teal?.backgroundColor?.cgColor)
        list.colorTheme = .random
        list.probe.layOut()
        XCTAssertEqual(list.tagButton(at: ip(1, 0))?.layer.backgroundColor, CYLTagColors(for: .random, seed: 1)?.backgroundColor?.cgColor)
        XCTAssertEqual(CYLTagColors.paletteHexByName["TEAL"], "009688")
        XCTAssertNil(CYLTagColors(for: .none, seed: 0))

        // Rows: at most one; tapping off; programmatic selection in mode none.
        list.maximumNumberOfRows = 1
        XCTAssertEqual(list.foldStyle, .truncate)
        list.probe.layOut()
        XCTAssertLessThan(list.numberOfVisibleItems(inSection: 0), 8)
        list.maximumNumberOfRows = 0
        XCTAssertEqual(list.foldStyle, CYLMenuFoldStyle.none)
        var taps = 0
        list.tagClickHandler = { _, _ in taps += 1 }
        list.allowsTapping = false
        list.probe.tap(item: 0, section: 0)
        XCTAssertEqual(taps, 0)
        list.allowsTapping = true
        list.probe.tap(item: 0, section: 0)
        XCTAssertEqual(taps, 1)
        XCTAssertEqual(list.selectionMode, CYLMenuSelectionMode.none)
        list.toggleSelection(at: ip(2, 0))
        list.toggleSelection(at: ip(3, 0))
        list.toggleSelection(at: ip(3, 0))
        XCTAssertEqual(list.selectedTitles, ["C"])
        list.removeTags(at: IndexSet([0, 1]))
        XCTAssertEqual(list.tags.map(\.title), ["C", "D", "E", "F", "G", "H"])
        XCTAssertEqual(list.selectedIndexPaths, [ip(0, 0)])

        // Reordering through the collection view, as a drag does.
        var moves: [String] = []
        list.tagMoveHandler = { from, to in moves.append("\(from)->\(to)") }
        list.allowsReordering = true
        list.reorderingSensitivity = 2
        let collection = list.probe.collectionView
        XCTAssertTrue(collection.dataSource?.collectionView?(collection, canMoveItemAt: ip(0, 0)) ?? false)
        collection.dataSource?.collectionView?(collection, moveItemAt: ip(0, 0), to: ip(2, 0))
        XCTAssertEqual(list.tags.map(\.title), ["D", "E", "C", "F", "G", "H"])
        XCTAssertEqual(moves, ["0->2"])
        XCTAssertEqual(list.selectedIndexPaths, [ip(2, 0)], "the selection moves with its tag")
        XCTAssertFalse(list.isReordering)

        // Container border, default image, square corners, drawn cross and ripple.
        list.containerBorderWidth = 2
        list.containerBorderColor = .red
        list.containerCornerRadius = 6
        XCTAssertEqual(list.layer.borderWidth, 2)
        XCTAssertEqual(list.layer.cornerRadius, 6)
        list.defaultTagImage = UIImage(systemName: "person.circle")
        let square = CYLTag(title: "Square")
        square.cornerRadius = CYLTagCornerRadiusSquare
        square.isDeletable = true
        list.insertTag(square, at: 0)
        list.probe.layOut()
        let button = list.tagButton(at: ip(0, 0))
        XCTAssertEqual(button?.layer.cornerRadius, 0)
        XCTAssertNotNil(button?.imageView.image)
        XCTAssertTrue(button?.deleteIndicatorLabel.isHidden ?? false, "a drawn cross instead of the ×")
        let cross = button?.layer.sublayers?.compactMap { $0 as? CAShapeLayer }.first { $0.path != nil && !$0.isHidden }
        XCTAssertNotNil(cross)
        let cell = list.probe.cell(at: ip(0, 0)) as? CYLTagListCell
        cell?.showRipple(at: CGPoint(x: 5, y: 5))
        XCTAssertTrue(button?.layer.sublayers?.contains { $0.name == "CYLTagRipple" } ?? false)
        list.removesItemsOnDelete = false
        list.deleteItem(at: ip(0, 0))
        XCTAssertEqual(list.tags.first?.title, "Square")
        list.removesItemsOnDelete = true
        list.deleteItem(at: ip(0, 0))
        XCTAssertEqual(list.tags.first?.title, "D")

        // Titles: cut and reversed; badges.
        let style = CYLMenuStyle()
        style.maximumTitleLength = 3
        XCTAssertEqual(style.displayedTitle(forTitle: "Hello"), "Hel...")
        style.reversesTitleCharacters = true
        style.maximumTitleLength = 0
        XCTAssertEqual(style.displayedTitle(forTitle: "你好"), "好你")
        XCTAssertEqual(CYLTag.badgeImage(withText: "热", color: .red, diameter: 16).size, CGSize(width: 16, height: 16))
    }
}
