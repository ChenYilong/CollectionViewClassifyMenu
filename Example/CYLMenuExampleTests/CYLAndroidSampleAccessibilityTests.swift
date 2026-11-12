//
//  CYLAndroidSampleAccessibilityTests.swift
//  CYLMenuExampleTests
//
//  The Android sample ports in every language (English is the samples' own text), and what VoiceOver, Voice Control
//  and Switch Control users get instead of long presses, drags and taps on a picture: the core's custom actions on
//  tags and tag groups, the dot and the picture as elements, badges read as values, Dynamic Type on picture tags.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
import CYLSearchViewController
@testable import CYLMenuExample

final class CYLAndroidSampleAccessibilityTests: CYLMenuExampleTestCase {

    override func setUp() {
        super.setUp()
        CYLImageTagSampleData.tagGroups = CYLImageTagSampleData.initialGroups()
    }

    private func actionNames(_ element: NSObject?) -> [String] {
        element?.accessibilityCustomActions?.map(\.name) ?? []
    }

    @discardableResult
    private func perform(_ name: String, on element: NSObject?) -> Bool {
        guard let action = element?.accessibilityCustomActions?.first(where: { $0.name == name }) else {
            XCTFail("no action \(name)")
            return false
        }
        return action.actionHandler?(action) ?? false
    }

    // MARK: Languages

    func testSamplesInEnglishUseTheAndroidSamplesText() {
        CYLMenuResources.preferredLanguage = "en"
        let sample = CYLTagCloudSampleViewController()
        showInNavigation(sample)
        sample.view.layoutIfNeeded()
        XCTAssertEqual(sample.title, "TagView Sample")
        XCTAssertEqual(sample.textField.placeholder, "INPUT TAG TEXT")
        XCTAssertEqual(sample.textField.accessibilityLabel, "Tag text")
        XCTAssertEqual(sample.navigationItem.rightBarButtonItem?.accessibilityLabel, "View on GitHub")
        let add = sample.view.views(withIdentifier: "sample.addTag").first as? UIButton
        XCTAssertEqual(add?.configuration?.title, "ADD A TAG")
        let list = sample.tagListView!
        XCTAssertTrue(list.tags.contains { $0.title == "Round Corner" })
        list.probe.layOut()
        list.probe.tap(item: 2, section: 0)
        XCTAssertEqual(CYLAndroidSample.toastText(in: sample.view), "click tag id = 2 position = 2")
        captureScreen(named: "test-sample-tag-cloud-english")

        let hot = CYLHotSearchViewController()
        showInNavigation(hot)
        hot.view.layoutIfNeeded()
        XCTAssertEqual(hot.searchBar.cancelButtonTitle, "Cancel")
        XCTAssertEqual(hot.tagListView.tagDataSource.sectionTitle, "Hot searches")
        XCTAssertEqual(hot.tagListView.tags.first?.badgeText, "♪")
        XCTAssertEqual(hot.tagListView.tags.first?.badgeAccessibilityLabel, "Hit song")
        captureScreen(named: "test-sample-hot-search-english")

        let edit = CYLImageTagEditViewController()
        showInNavigation(edit)
        XCTAssertEqual(edit.title, "Create tags")
        XCTAssertEqual((edit.view.views(withIdentifier: "sample.save").first as? UIButton)?.configuration?.title, "Save")

        let containers = CYLTagContainerSampleViewController()
        showInNavigation(containers)
        containers.view.layoutIfNeeded()
        XCTAssertEqual(containers.title, "Sample")
        containers.containers[0].probe.layOut()
        containers.containers[0].probe.tap(item: 0, section: 0)
        XCTAssertEqual(CYLAndroidSample.toastText(in: containers.view), "click-position:0, text:Java")
        captureScreen(named: "test-sample-tag-container-english")
    }

    func testSamplesInTraditionalChinese() {
        CYLMenuResources.preferredLanguage = "zh-Hant"
        let sample = CYLTagCloudSampleViewController()
        sample.loadViewIfNeeded()
        XCTAssertEqual(sample.title, "標籤視圖示例")
        XCTAssertTrue(sample.tagListView.tags.contains { $0.title == "圓角" })
        XCTAssertEqual(CYLHotSearchViewController.Badge.trending.text, "熱")
        XCTAssertEqual(CYLHotSearchViewController.Badge.trending.accessibilityLabel, "熱門")
        let image = CYLImageTagSampleViewController()
        image.loadViewIfNeeded()
        XCTAssertEqual(image.title, "圖片標籤")
        XCTAssertEqual(image.tagImageView.imageView.accessibilityLabel, "鞋子圖片")
        XCTAssertEqual(CYLMenuLocalizedString("CYLMenuMoveTagLater"), "後移")
    }

    // MARK: Tag lists

    func testTagsGetMoveAndLongPressActionsInsteadOfDragsAndPresses() {
        let sample = CYLTagContainerSampleViewController()
        showInNavigation(sample)
        sample.view.layoutIfNeeded()
        let first = sample.containers[0]
        first.probe.layOut()
        // Deletable, reorderable, long press deletes after a question.
        let cell0 = first.probe.cell(at: ip(0, 0))
        XCTAssertEqual(actionNames(cell0), ["删除", "后移", "删除"], "delete, move later, the long press named by the host")
        let cell1 = first.probe.cell(at: ip(1, 0))
        XCTAssertEqual(actionNames(cell1), ["删除", "前移", "后移", "删除"])

        var moves: [String] = []
        first.tagMoveHandler = { from, to in moves.append("\(from)->\(to)") }
        XCTAssertTrue(perform("后移", on: cell0))
        XCTAssertEqual(moves, ["0->1"])
        XCTAssertEqual(first.tags.prefix(2).map(\.title), ["C++", "Java"])
        runMainLoop(for: 0.1)

        // The third container's long press selects.
        let third = sample.containers[2]
        third.probe.layOut()
        let persian = third.probe.cell(at: ip(1, 0))
        XCTAssertEqual(actionNames(persian), ["删除", "选择或取消选择"], "not reorderable")
        perform("选择或取消选择", on: persian)
        XCTAssertEqual(third.selectedTitles, ["波斯语"])

        // No handler: no long-press action; the default name otherwise.
        let plain = sample.containers[3]
        plain.probe.layOut()
        XCTAssertEqual(actionNames(plain.probe.cell(at: ip(0, 0))), [])
        plain.tagLongPressHandler = { _, _ in }
        XCTAssertEqual(actionNames(plain.probe.cell(at: ip(0, 0))), ["长按"])
    }

    func testBadgesAreReadAsTheTagsValue() {
        let screen = CYLHotSearchViewController()
        showInNavigation(screen)
        screen.view.layoutIfNeeded()
        let list = screen.tagListView!
        list.probe.layOut()
        let song = list.probe.cell(at: ip(0, 0))
        XCTAssertEqual(song?.accessibilityLabel, "入戏太深混合串烧版")
        XCTAssertEqual(song?.accessibilityValue, "神曲")
        XCTAssertEqual(list.probe.cell(at: ip(4, 0))?.accessibilityValue, "热门")
        XCTAssertNil(list.probe.cell(at: ip(2, 0))?.accessibilityValue)
        XCTAssertTrue(list.probe.headerTitleLabel(inSection: 0)?.accessibilityTraits.contains(.header) ?? false)
    }

    // MARK: Tags on a picture

    func testPictureAndTagGroupsAreAccessibilityElements() {
        let sample = CYLImageTagSampleViewController()
        showInNavigation(sample)
        sample.view.layoutIfNeeded()
        let imageView = sample.tagImageView!
        imageView.layoutIfNeeded()
        let picture = imageView.imageView
        XCTAssertTrue(picture.isAccessibilityElement)
        XCTAssertEqual(picture.accessibilityLabel, "鞋子图片")
        XCTAssertEqual(picture.accessibilityHint, "轻点两下显示或隐藏标签")
        XCTAssertTrue(picture.accessibilityTraits.contains(.button))
        XCTAssertTrue(picture.accessibilityTraits.contains(.image))

        let group = imageView.groupViews[0]
        group.layoutIfNeeded()
        let dot = group.circleAccessibilityElement
        XCTAssertEqual(dot.accessibilityLabel, "标签组：头层牛皮、英伦加绒青年棕色保暖鞋子。和PLAYBOY/花花公子")
        XCTAssertTrue(dot.accessibilityTraits.contains(.button))
        XCTAssertEqual(dot.accessibilityFrameInContainerSpace.midX, group.centerPoint.x, accuracy: 0.5)
        XCTAssertEqual(actionNames(dot), ["长按"], "not draggable outside edit mode")
        let elements = group.accessibilityElements as? [NSObject]
        XCTAssertEqual(elements?.count, 4, "the dot, then three tags")
        XCTAssertTrue(elements?.first === dot)
        XCTAssertEqual(group.tagViews[0].accessibilityLabel, "头层牛皮")
        XCTAssertTrue(group.tagViews[0].accessibilityTraits.contains(.button))

        XCTAssertTrue(dot.accessibilityActivate())
        XCTAssertEqual(CYLAndroidSample.toastText(in: sample.view), "点击中心圆")

        // Activating the picture toggles the groups, as a tap does; hidden groups have no elements.
        XCTAssertTrue(picture.accessibilityActivate())
        runMainLoop(for: UIAccessibility.isReduceMotionEnabled ? 0.05 : 1.2)
        XCTAssertTrue(group.isGroupHidden)
        XCTAssertEqual((group.accessibilityElements ?? []).count, 0)
        imageView.toggleTagGroups(animated: false)
    }

    func testEditModeGivesMoveTurnAndDeleteWithoutGestures() {
        let edit = CYLImageTagEditViewController()
        showInNavigation(edit)
        edit.view.layoutIfNeeded()
        edit.createGroup(withNames: ["上衣", "裤子"])
        let imageView = edit.tagImageView!
        imageView.layoutIfNeeded()
        let group = imageView.groupViews[0]
        group.layoutIfNeeded()
        let dot = group.circleAccessibilityElement
        XCTAssertEqual(actionNames(dot), ["删除标签组", "上移", "下移", "左移", "右移"])
        XCTAssertEqual(group.tagViews[0].accessibilityHint, "轻点两下改变方向")

        var drags: [CGPoint] = []
        imageView.dragHandler = { _, position in drags.append(position) }
        XCTAssertTrue(perform("右移", on: dot))
        XCTAssertEqual(group.percentPosition.x, 0.55, accuracy: 0.001)
        XCTAssertEqual(imageView.tagGroups[0].percentPosition.x, 0.55, accuracy: 0.001, "saved like a drag")
        XCTAssertTrue(perform("上移", on: dot))
        XCTAssertEqual(group.percentPosition.y, 0.45, accuracy: 0.001)
        XCTAssertEqual(drags.count, 2)

        // Activating a tag turns it, and the hint stays on the new view.
        let before = imageView.tagGroups[0].tags[0].direction
        group.delegate?.groupView?(group, didTapTagAt: 0)
        XCTAssertEqual(imageView.tagGroups[0].tags[0].direction, CYLImageTagDirectionNext(before))
        XCTAssertEqual(group.tagViews[0].accessibilityHint, "轻点两下改变方向")

        // The delete action asks first, as the long press does.
        perform("删除标签组", on: dot)
        runMainLoop(for: 0.3)
        XCTAssertEqual((edit.presentedViewController as? UIAlertController)?.title, "删除标签组")
        edit.dismiss(animated: false)

        imageView.isEditing = false
        XCTAssertNil(group.tagViews[0].accessibilityHint)
        XCTAssertEqual(actionNames(dot), ["删除标签组"])
    }

    func testPictureTagsGrowWithDynamicType() throws {
        guard #available(iOS 17.0, *) else { throw XCTSkip("traitOverrides needs iOS 17") }
        let sample = CYLImageTagSampleViewController()
        let navigation = showInNavigation(sample)
        sample.view.layoutIfNeeded()
        let label = try XCTUnwrap(sample.tagImageView.groupViews[0].tagViews[0] as? CYLImageTagLabel)
        let base = label.font.pointSize
        XCTAssertTrue(label.adjustsFontForContentSizeCategory)
        navigation.view.window?.traitOverrides.preferredContentSizeCategory = .accessibilityExtraExtraLarge
        navigation.view.window?.layoutIfNeeded()
        runMainLoop(for: 0.1)
        sample.tagImageView.layoutIfNeeded()
        XCTAssertGreaterThan(label.font.pointSize, base)
        XCTAssertGreaterThanOrEqual(label.bounds.height, label.font.lineHeight, "the group remeasured the tag")
        // The two groups no longer cover each other: the second moves for display only, its position is kept.
        let groups = sample.tagImageView.groupViews
        XCTAssertEqual(groups.count, 2)
        XCTAssertFalse(groups[0].occupiedFrame.intersects(groups[1].occupiedFrame),
                       "\(groups[0].occupiedFrame) / \(groups[1].occupiedFrame)")
        XCTAssertTrue(sample.tagImageView.bounds.contains(groups[1].occupiedFrame.insetBy(dx: 0.5, dy: 0.5)) ||
                      groups[1].displayOffset == .zero, "a moved group stays inside the picture")
        XCTAssertEqual(groups[1].percentPosition, CGPoint(x: 0.3, y: 0.2), "the data does not change")
        captureScreen(named: "test-sample-image-tag-large-text")
        navigation.view.window?.traitOverrides.preferredContentSizeCategory = .large
        runMainLoop(for: 0.1)
        sample.tagImageView.layoutIfNeeded()
        XCTAssertFalse(groups[0].occupiedFrame.intersects(groups[1].occupiedFrame), "apart at the default size too")
    }
}
