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
        let squareIndex = list.tags.firstIndex { $0.title == "圆角" } ?? 0
        list.scrollToItem(at: ip(squareIndex, 0), animated: false)
        list.probe.layOut()
        XCTAssertEqual(list.tagButton(at: ip(squareIndex, 0))?.layer.cornerRadius, 0)
        let first = list.tagButton(at: ip(0, 0))
        list.scrollToItem(at: ip(0, 0), animated: false)
        list.probe.layOut()
        XCTAssertEqual(list.tagButton(at: ip(0, 0))?.layer.cornerRadius ?? 0, (list.tagButton(at: ip(0, 0))?.bounds.height ?? 0) / 2, accuracy: 0.5)
        _ = first

        list.probe.tap(item: 2, section: 0)
        XCTAssertEqual(CYLAndroidSample.toastText(in: sample.view), "点击标签 id = 2，位置 = 2")

        sample.random = { _ in 0 }
        sample.textField.text = "NEW"
        sample.addTag()
        XCTAssertEqual(list.tags.last?.title, "NEW")
        XCTAssertTrue(list.tags.last?.isDeletable ?? false)
        sample.textField.text = ""
        sample.addTag()
        XCTAssertEqual(list.tags.last?.title, "添加标签")

        sample.openActivityResult()
        let sub = navigation.topViewController as? CYLTagCloudSubViewController
        XCTAssertNotNil(sub)
        sub?.finish()
        XCTAssertEqual(list.tags.last?.title, "返回结果后添加")
    }

    func testTagCloudListAndRecyclerScreens() {
        let listScreen = CYLTagCloudListViewController()
        showInNavigation(listScreen)
        listScreen.tableView.layoutIfNeeded()
        XCTAssertEqual(listScreen.tableView.numberOfRows(inSection: 0), 51)
        let cell = listScreen.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? CYLTagCloudListCell
        XCTAssertEqual(cell?.tagListView.tags.map(\.title), ["条目 1", "条目 1", "条目 1"])
        XCTAssertGreaterThan(cell?.bounds.height ?? 0, 20)
        captureScreen(named: "test-sample-tag-cloud-list")

        let recycler = CYLTagCloudRecyclerViewController()
        showInNavigation(recycler)
        recycler.tableView.layoutIfNeeded()
        XCTAssertEqual(recycler.tableView.numberOfRows(inSection: 0), 22)
        let footer = recycler.tableView.dataSource?.tableView(recycler.tableView, cellForRowAt: IndexPath(row: 21, section: 0)) as? CYLTagCloudListCell
        XCTAssertEqual(footer?.tagListView.tags.map(\.title), ["页脚 1", "页脚 2"])
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
        XCTAssertEqual(list.tagButton(at: ip(0, 0))?.imageView.image?.accessibilityLabel, "神曲")
        XCTAssertEqual(list.tagButton(at: ip(4, 0))?.imageView.image?.accessibilityLabel, "热门")
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
        XCTAssertEqual(group.value(of: .linesProgress), 0.5)
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
        group.delegate?.groupView(group, didTapTagAt: 0)
        XCTAssertEqual(imageView.tagGroups[0].tags[0].direction, .rightTopStraight)
        group.delegate?.groupView(group, didDragToPercentPosition: CGPoint(x: 0.2, y: 0.7))
        XCTAssertEqual(imageView.tagGroups[0].percentPosition, CGPoint(x: 0.2, y: 0.7))
        edit.save()
        XCTAssertTrue(saved)
        XCTAssertEqual(CYLImageTagSampleData.tagGroups.count, 1)
        XCTAssertEqual(CYLImageTagSampleData.tagGroups[0].tags.first?.title, "上衣")
        XCTAssertEqual(CYLImageTagDirection.rightBottomStraight.next, .leftCenter)

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

    func testTagContainerSample() throws {
        let sample = CYLTagContainerSampleViewController()
        showInNavigation(sample, size: CYLTestScreen.tall)
        sample.view.layoutIfNeeded()
        sample.view.layoutIfNeeded()
        let containers = sample.containers
        XCTAssertEqual(containers.count, 6)
        containers.forEach { $0.probe.layOut() }
        let first = containers[0]
        XCTAssertEqual(first.containerCornerRadius, 10)
        XCTAssertEqual(first.layer.borderWidth, 0.5)
        // tag_max_length 23: the long Chinese tag is cut.
        XCTAssertTrue(first.tagButton(at: ip(4, 0))?.titleLabel.text?.hasSuffix("...") ?? false)
        XCTAssertEqual(first.tagButton(at: ip(4, 0))?.titleLabel.text?.count, 23, "20 characters and ...")
        // The last tag names the running OS and the library, cut to 23 characters as every long tag here.
        let welcome = "Welcome to use \(UIDevice.current.systemName) \(UIDevice.current.systemVersion) CollectionViewClassifyMenu"
        XCTAssertEqual(first.tags[8].title, welcome)
        XCTAssertEqual(first.tagButton(at: ip(8, 0))?.titleLabel.text, String(welcome.prefix(20)) + "...")
        XCTAssertFalse(first.tags.contains { $0.title.localizedCaseInsensitiveContains("android") })
        let java = first.tagButton(at: ip(0, 0))
        XCTAssertTrue(java?.showsDeleteIndicator ?? false)
        XCTAssertNotNil(java?.imageView.image, "the default avatar")
        // The avatar: a circle as tall as the tag at its leading edge, the title after it.
        let avatar = java?.imageView.frame ?? .zero
        XCTAssertEqual(avatar.minX, 0, accuracy: 0.5)
        XCTAssertEqual(avatar.height, java?.bounds.height ?? 0, accuracy: 0.5)
        XCTAssertEqual(avatar.width, avatar.height, accuracy: 0.5)
        XCTAssertEqual(java?.imageView.layer.cornerRadius ?? 0, avatar.height / 2, accuracy: 0.5)
        XCTAssertGreaterThan(java?.titleLabel.frame.minX ?? 0, avatar.maxX)
        captureScreen(named: "test-sample-tag-container")

        // A cross tap only reports (onTagCrossClick).
        first.deleteItem(at: ip(1, 0))
        XCTAssertEqual(first.tags.count, 9)
        XCTAssertEqual(CYLAndroidSample.toastText(in: sample.view), "点了标签的叉！位置 = 1")
        sample.textField.text = "Kotlin"
        sample.addTag()
        XCTAssertEqual(first.tags.last?.title, "Kotlin")

        // container_gravity="right": titles as written, the cross first, each row from the right edge (first tag
        // rightmost), as the Android example shows them.
        let third = containers[2]
        XCTAssertEqual(third.tagButton(at: ip(3, 0))?.titleLabel.text, "Hello")
        let button = third.tagButton(at: ip(3, 0))
        XCTAssertLessThan(button?.deleteIndicatorHitFrame.minX ?? 1, 1)
        let frames = (0..<third.tags.count).map { third.probe.itemFrame(at: ip($0, 0)) ?? .zero }
        var rows = 0
        for (index, frame) in frames.enumerated() {
            if index == 0 || frame.minY > frames[index - 1].minY + 0.5 {
                rows += 1
                XCTAssertEqual(frame.maxX, third.bounds.width - 10, accuracy: 1, "tag \(index) starts its row at the right")
            } else {
                XCTAssertLessThan(frame.maxX, frames[index - 1].minX, "tag \(index) left of the one before it")
            }
        }
        XCTAssertGreaterThan(rows, 1)
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
        XCTAssertEqual(CYLMenuFixtures.fillRGB(of: fifth.tagButton(at: ip(0, 0))), CYLMenuFixtures.rgb(UIColor.cylMenuColor(from: "#ff0000")))
        XCTAssertFalse(fifth.allowsTapping)

        // tagcontainerLayout6: a star, a wrapping title, elevation, a cross image, no cross on the last tag.
        let sixth = containers[5]
        sixth.probe.layOut()
        XCTAssertEqual(sixth.tags.map(\.title), CYLTagContainerSampleData.list6)
        XCTAssertNotNil(sixth.tagButton(at: ip(0, 0))?.imageView.image, "the star")
        let long = try XCTUnwrap(sixth.tagButton(at: ip(1, 0)))
        let short = try XCTUnwrap(sixth.tagButton(at: ip(2, 0)))
        XCTAssertGreaterThan(long.bounds.height, short.bounds.height + 10, "the long title wraps and its tag grows")
        XCTAssertGreaterThan(long.titleLabel.frame.height, long.titleLabel.font.lineHeight * 1.5)
        XCTAssertLessThanOrEqual(long.frame.width, sixth.bounds.width - 20 + 0.5, "inside the container")
        XCTAssertEqual(long.layer.shadowOpacity, 0.25, accuracy: 0.001)
        XCTAssertEqual(long.layer.shadowOffset.height, 2, accuracy: 0.001)
        XCTAssertTrue(long.showsDeleteIndicator)
        XCTAssertFalse(short.showsDeleteIndicator, "no cross on the last tag")
        // The cross image is drawn on a one-line tag too ("Starred"), not only on the taller wrapped one.
        let starredCross = sixth.tagButton(at: ip(0, 0))?.deleteIndicatorLabel.subviews.compactMap { $0 as? UIImageView }.first
        XCTAssertGreaterThan(starredCross?.bounds.width ?? 0, 10)
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
        let teal = CYLTagColors(theme: .pureTeal, seed: 0)
        XCTAssertEqual(CYLMenuFixtures.fillRGB(of: list.tagButton(at: ip(0, 0))), CYLMenuFixtures.rgb(teal?.backgroundColor))
        list.colorTheme = .random
        list.probe.layOut()
        XCTAssertEqual(CYLMenuFixtures.fillRGB(of: list.tagButton(at: ip(1, 0))), CYLMenuFixtures.rgb(CYLTagColors(theme: .random, seed: 1)?.backgroundColor))
        XCTAssertEqual(CYLTagColors.paletteHexByName["TEAL"], "009688")
        XCTAssertNil(CYLTagColors(theme: .none, seed: 0))

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
        square.cornerRadius = 0
        square.isDeletable = true
        list.insertTag(square, at: 0)
        list.probe.layOut()
        let button = list.tagButton(at: ip(0, 0))
        XCTAssertEqual(button?.layer.cornerRadius, 0)
        XCTAssertNotNil(button?.imageView.image)
        XCTAssertNil(button?.deleteIndicatorLabel.text, "a drawn cross instead of the × (the empty accessory stays tappable)")
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
        style.maximumTitleLength = 6
        XCTAssertEqual(style.displayedTitle(forTitle: "Hello"), "Hello")
        // As AndroidTagView: 6 characters in all, the last three "..." (23: "Welcome to use Andro...").
        XCTAssertEqual(style.displayedTitle(forTitle: "Hello World"), "Hel...")
        style.maximumTitleLength = 23
        XCTAssertEqual(style.displayedTitle(forTitle: "Welcome to use AndroidTagView!"), "Welcome to use Andro...")
        style.reversesTitleCharacters = true
        style.maximumTitleLength = 0
        XCTAssertEqual(style.displayedTitle(forTitle: "你好"), "好你")
        XCTAssertEqual(CYLTag.badgeImage(text: "热", color: .red, diameter: 16).size, CGSize(width: 16, height: 16))
    }

    // MARK: Word picker (选词填入)

    /// A pan recognizer whose state and location a test sets, to drive `allowsSmearSelection`.
    private final class CYLFakeLongPress: UILongPressGestureRecognizer {
        var fakeState: UIGestureRecognizer.State = .possible
        var fakeLocation: CGPoint = .zero
        override var state: UIGestureRecognizer.State {
            get { fakeState }
            set { fakeState = newValue }
        }
        override func location(in view: UIView?) -> CGPoint { fakeLocation }
    }

    /// A drag to reorder tells the delegate once when it begins and once when it ends or is cancelled.
    func testReorderingReportsItsBeginAndEnd() {
        let list = wordPickerList("ABCDEF")
        list.allowsReordering = true
        let source = CYLTestMenuDelegate()
        list.menuDelegate = source
        let collection = list.probe.collectionView
        let frame = collection.layoutAttributesForItem(at: ip(0, 0))?.frame ?? .zero
        let recognizer = CYLFakeLongPress()
        func press(_ state: UIGestureRecognizer.State) {
            recognizer.fakeState = state
            recognizer.fakeLocation = CGPoint(x: frame.midX, y: frame.midY)
            list.perform(NSSelectorFromString("handleLongPress:"), with: recognizer)
        }
        press(.began)
        XCTAssertTrue(list.isReordering)
        XCTAssertEqual(source.reordering, [true])
        press(.changed)
        press(.ended)
        XCTAssertEqual(source.reordering, [true, false], "false once at the drop")
        press(.began)
        press(.cancelled)
        XCTAssertEqual(source.reordering, [true, false, true, false], "a cancelled drag reports false too")
        // Removed from its window in the middle of a drag: false too.
        press(.began)
        list.removeFromSuperview()
        XCTAssertEqual(source.reordering, [true, false, true, false, true, false], "removing the view ends the drag")
        XCTAssertFalse(list.isReordering)
    }

    private final class CYLFakePan: UIPanGestureRecognizer {
        var fakeState: UIGestureRecognizer.State = .possible
        var fakeLocation: CGPoint = .zero
        override var state: UIGestureRecognizer.State {
            get { fakeState }
            set { fakeState = newValue }
        }
        override func location(in view: UIView?) -> CGPoint { fakeLocation }
    }

    /// The cells of the sender's name in `text` (one cell per character), in any language.
    private func nameRange(in text: String) -> Range<Int> {
        let characters = Array(text).map(String.init)
        let name = Array(CYLWordPickerDemoViewController.sender).map(String.init)
        let start = (0...(characters.count - name.count)).first { Array(characters[$0..<($0 + name.count)]) == name }!
        return start..<(start + name.count)
    }

    private func wordPickerList(_ text: String) -> CYLTagListView {
        let list = CYLTagListView()
        list.style = .wordPicker()
        list.colorTheme = CYLTagColorTheme.none
        list.selectionMode = .multiple
        list.allowsSmearSelection = true
        list.isScrollEnabled = false
        list.setTags(withCharactersOf: text)
        list.frame = CGRect(x: 0, y: 0, width: 390, height: 400)
        let host = UIViewController()
        host.view.addSubview(list)
        show(host, size: CYLTestScreen.tall)
        list.probe.layOut()
        return list
    }

    /// One cell per character (an emoji and a space are one each), 9 equal cells per row, a space read as "Space"; a
    /// range selects in text order and the picked text is the selected characters as they stand in the text.
    func testWordPickerCellsAndPickedText() {
        let text = CYLWordPickerDemoViewController.message
        let list = wordPickerList(text)
        XCTAssertEqual(list.tags.count, text.count)
        XCTAssertEqual(list.tags.map(\.title).joined(), text)
        XCTAssertTrue(list.tags.contains { $0.title == "👋" }, "an emoji is one cell")
        let first = list.probe.itemFrame(at: ip(0, 0)) ?? .zero
        let ninth = list.probe.itemFrame(at: ip(8, 0)) ?? .zero
        let tenth = list.probe.itemFrame(at: ip(9, 0)) ?? .zero
        XCTAssertEqual(first.width, ninth.width, accuracy: 0.5, "equal cells")
        XCTAssertEqual(first.minY, ninth.minY, accuracy: 0.5, "9 per row")
        XCTAssertGreaterThan(tenth.minY, first.maxY, "the 10th starts the second row")
        let space = list.tags.firstIndex { $0.title == " " }!
        XCTAssertEqual(list.probe.cell(at: ip(space, 0))?.accessibilityLabel, "空格", "a space is read, not silent")

        // The name, from its last letter back to its first: the picked text is "Alex", in text order.
        let name = nameRange(in: text)
        list.selectItems(from: ip(name.upperBound - 1, 0), through: ip(name.lowerBound, 0))
        XCTAssertEqual(list.selectedText, CYLWordPickerDemoViewController.sender)
        list.deselectAllItems()
        XCTAssertEqual(list.selectedText, "")
    }

    /// The demo's message in every language: translated, with the name to pick, an emoji and a space; picking the name
    /// gives the name.
    func testWordPickerMessageInEveryLanguage() {
        var messages: [String] = []
        for language in ["en", "zh-Hans", "zh-Hant"] {
            CYLMenuResources.preferredLanguage = language
            let text = CYLWordPickerDemoViewController.message
            messages.append(text)
            XCTAssertTrue(text.contains(CYLWordPickerDemoViewController.sender), language)
            XCTAssertTrue(text.contains("👋"), language)
            XCTAssertTrue(text.contains(" "), language)
            let list = wordPickerList(text)
            let name = nameRange(in: text)
            list.selectItems(from: ip(name.lowerBound, 0), through: ip(name.upperBound - 1, 0))
            XCTAssertEqual(list.selectedText, CYLWordPickerDemoViewController.sender, language)
        }
        CYLMenuResources.preferredLanguage = "zh-Hans"
        XCTAssertEqual(Set(messages).count, 3, "a different text per language")
        XCTAssertFalse(messages[0].unicodeScalars.contains { (0x3400...0x9FFF).contains($0.value) }, "English has no Chinese")
    }

    /// Several smears in a row add up: each one that starts on an unselected cell adds its range to the selection. In
    /// the demo's message, "设计部" and then " Alex" (from the space before the name) give "设计部 Alex"; in Traditional
    /// Chinese "設計部 Alex"; in English, in text order, "Alex" and then " Design" give "Alex Design".
    func testSeveralSmearsAddUp() {
        let cases: [(String, [(String, String)], String)] = [
            ("zh-Hans", [("设计部", "设计部"), (" Alex", " Alex")], "设计部 Alex"),
            ("zh-Hant", [("設計部", "設計部"), (" Alex", " Alex")], "設計部 Alex"),
            ("en", [("Alex", "Alex"), (" Design", " Design")], "Alex Design"),
        ]
        for (language, smears, expected) in cases {
            CYLMenuResources.preferredLanguage = language
            let text = CYLWordPickerDemoViewController.message
            let list = wordPickerList(text)
            let collection = list.probe.collectionView
            let characters = Array(text).map(String.init)
            func cells(of word: String) -> Range<Int> {
                let letters = Array(word).map(String.init)
                let start = (0...(characters.count - letters.count)).first {
                    Array(characters[$0..<($0 + letters.count)]) == letters
                }!
                return start..<(start + letters.count)
            }
            func center(_ item: Int) -> CGPoint {
                let frame = collection.layoutAttributesForItem(at: ip(item, 0))?.frame ?? .zero
                return CGPoint(x: frame.midX, y: frame.midY)
            }
            let pan = CYLFakePan()
            for (word, _) in smears {
                let range = cells(of: word)
                for (state, item) in [(UIGestureRecognizer.State.began, range.lowerBound),
                                      (.changed, range.upperBound - 1), (.ended, range.upperBound - 1)] {
                    pan.fakeState = state
                    pan.fakeLocation = center(item)
                    list.perform(NSSelectorFromString("handleSmear:"), with: pan)
                }
            }
            XCTAssertEqual(list.selectedText, expected, language)
        }
        CYLMenuResources.preferredLanguage = "zh-Hans"
    }

    /// A drag that starts on a cell selects every cell from it to the finger; starting on a selected cell deselects;
    /// the delegate hears of each change.
    func testSmearSelectionSelectsAndDeselectsARange() {
        let list = wordPickerList("ABCDEFGHIJKL")
        let source = CYLTestMenuDelegate()
        list.menuDelegate = source
        let collection = list.probe.collectionView
        func center(_ item: Int) -> CGPoint {
            let frame = collection.layoutAttributesForItem(at: ip(item, 0))?.frame ?? .zero
            return CGPoint(x: frame.midX, y: frame.midY)
        }
        let pan = CYLFakePan()
        func smear(_ state: UIGestureRecognizer.State, at item: Int) {
            pan.fakeState = state
            pan.fakeLocation = center(item)
            list.perform(NSSelectorFromString("handleSmear:"), with: pan)
        }
        smear(.began, at: 2)
        XCTAssertEqual(source.smearing, [true], "true once when the smear begins")
        smear(.changed, at: 4)
        smear(.changed, at: 10)   // Across the row break.
        smear(.ended, at: 10)
        XCTAssertEqual(source.smearing, [true, false], "false once when it ends, not per finger move")
        XCTAssertEqual(list.selectedText, "CDEFGHIJK")
        XCTAssertGreaterThanOrEqual(source.selectionChanges, 2)
        // Back toward the start while still dragging: the range shrinks.
        smear(.began, at: 0)
        smear(.changed, at: 1)
        smear(.ended, at: 1)
        XCTAssertEqual(list.selectedText, "ABCDEFGHIJK")
        // Starting on a selected cell deselects.
        smear(.began, at: 5)
        smear(.changed, at: 7)
        smear(.ended, at: 7)
        XCTAssertEqual(list.selectedText, "ABCDEIJK")
        // Only in multiple selection: a smear in single selection changes nothing.
        list.selectionMode = .single
        list.deselectAllItems()
        smear(.began, at: 0)
        smear(.changed, at: 3)
        smear(.ended, at: 3)
        XCTAssertLessThanOrEqual(list.selectedIndexPaths.count, 1)
    }

    /// The Example: "Fill in" is off until a cell is selected, then fills the remark field with the picked text.
    func testWordPickerSheetFillsTheRemark() {
        let demo = CYLWordPickerDemoViewController()
        showInNavigation(demo, size: CYLTestScreen.tall)
        demo.view.layoutIfNeeded()
        var filled: String?
        let sheet = CYLWordPickerSheetViewController(text: CYLWordPickerDemoViewController.message) { filled = $0 }
        sheet.loadViewIfNeeded()
        XCTAssertFalse(sheet.fillButton.isEnabled, "nothing selected: Fill in is off")
        let list = sheet.tagListView!
        let name = nameRange(in: CYLWordPickerDemoViewController.message)
        list.selectItems(from: ip(name.lowerBound, 0), through: ip(name.upperBound - 1, 0))
        sheet.menu(list, didChangeSelectedItems: list.selectedIndexPaths)
        XCTAssertTrue(sheet.fillButton.isEnabled)
        sheet.fillTapped()
        XCTAssertEqual(filled, CYLWordPickerDemoViewController.sender)
    }
}

/// Counts `menu(_:didChangeSelectedItems:)` calls.
final class CYLTestMenuDelegate: NSObject, CYLMenuDelegate {
    var selectionChanges = 0
    /// `didChangeSmearing` values, in order.
    var smearing: [Bool] = []
    /// `didChangeReordering` values, in order.
    var reordering: [Bool] = []
    func menu(_ menu: Any, didChangeSelectedItems indexPaths: [IndexPath]) {
        selectionChanges += 1
    }
    func menu(_ menu: Any, didChangeSmearing smearing: Bool) {
        self.smearing.append(smearing)
    }
    func menu(_ menu: Any, didChangeReordering reordering: Bool) {
        self.reordering.append(reordering)
    }
}

