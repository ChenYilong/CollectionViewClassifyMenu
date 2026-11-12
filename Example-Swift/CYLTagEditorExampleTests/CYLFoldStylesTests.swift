//
//  CYLFoldStylesTests.swift
//  CYLTagEditorExampleTests
//
//  The 折叠样式 tab and the core it shows: CYLMenuFoldControl positions and contents, titles that are tag views,
//  lists made from configuration files.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLTagEditorExample

final class CYLFoldStylesTests: CYLTagEditorTestCase {

    func testFoldStylesAreMadeWithParametersAndFromConfigurationFiles() throws {
        let data = try CYLTagData.bundled()
        XCTAssertEqual(data.groups?.count, 6, "Grouped tags in tags.json")
        let styles = try showFoldStyles()
        let demos = styles.demos()
        XCTAssertTrue(styles.configurationErrors.isEmpty, "\(styles.configurationErrors) (YAML and XML need CYLTabBarController's parser)")
        XCTAssertEqual(styles.tagListViews.count, demos.count + CYLFoldStylesViewController.configurationFiles.count)
        captureScreen(named: "test-swift-fold-styles")
        // Every position and content.
        let made = styles.tagListViews.prefix(demos.count)
        XCTAssertEqual(made.map { $0.foldControl.position }, demos.map { $0.foldControl.position })
        XCTAssertEqual(Set(made.map { $0.foldControl.position }), [.bottom, .topTrailing, .topLeading])
        XCTAssertEqual(Set(made.map { $0.foldControl.content }), [.icon, .iconAndTitle, .title])
        XCTAssertEqual(made.first?.foldStyle, .footerChevron, "foldControl sets foldStyle")
        XCTAssertEqual(made.first?.title, "底部箭头（淘宝评价筛选）")
        XCTAssertTrue(made.allSatisfy { $0.title != nil || $0.titleImage != nil }, "Every demo sets the encapsulated title")
        // From the files: JSON, plist, YAML and XML.
        let files = Array(styles.tagListViews.suffix(4))
        XCTAssertEqual(files.map { $0.foldControl.position }, [.bottom, .topTrailing, .topLeading, .bottom])
        XCTAssertEqual(files.map { $0.foldControl.content }, [.iconAndTitle, .title, .icon, .title])
        XCTAssertEqual(files[3].titlePosition, .topCenter)
        XCTAssertTrue(files.allSatisfy { $0.titleImage != nil }, "titleImage from every file")
        XCTAssertEqual(files[0].titleLabel.textColor, UIColor(red: 7 / 255, green: 193 / 255, blue: 96 / 255, alpha: 1), "titleStyle from the JSON file")
        XCTAssertTrue(files.allSatisfy { ($0.title ?? "").count > 0 })
        XCTAssertTrue(files.allSatisfy { $0.selectionMode == .multiple && !$0.isScrollEnabled })
        for list in styles.tagListViews {
            XCTAssertGreaterThan(list.contentHeight, 0, list.title ?? "")
            XCTAssertGreaterThan(list.frame.minY, -1)
        }
    }

    func testTitleIsATagViewWithIconAndTitleStyles() throws {
        let styles = try showFoldStyles()
        let demos = styles.demos()
        func list(_ title: String?) -> CYLTagListView {
            styles.tagListViews[demos.firstIndex { $0.title == title }!]
        }
        // The core's default title look: the bold headline font, as before.
        let leading = list("标题：图标 + 文字（左上角）")
        XCTAssertTrue(leading.titleView is CYLTagButton, "The title reuses the tag view")
        XCTAssertEqual(leading.titleView.title, "标题：图标 + 文字（左上角）")
        XCTAssertNotNil(leading.titleView.image)
        // The same font (the tag view scales its own copy for Dynamic Type, so compare name and size).
        let headline = UIFont.preferredFont(forTextStyle: .headline)
        XCTAssertEqual(leading.titleLabel.font.fontName, headline.fontName)
        XCTAssertEqual(leading.titleLabel.font.pointSize, headline.pointSize, accuracy: 0.5)
        XCTAssertTrue(leading.titleView.accessibilityTraits.contains(.header))
        XCTAssertEqual(leading.titleView.frame.minX, leading.style.sectionInsets.left, accuracy: 0.5, "Top leading")
        XCTAssertLessThan(leading.titleView.imageView.frame.maxX, leading.titleLabel.frame.minX, "Icon, then title, side by side")
        XCTAssertEqual(leading.titleView.imageView.frame.midY, leading.titleLabel.frame.midY, accuracy: 1)
        // Icon only, title only.
        let iconOnly = list(nil)
        XCTAssertNil(iconOnly.title)
        XCTAssertNotNil(iconOnly.titleImage)
        XCTAssertGreaterThan(iconOnly.titleView.frame.height, 0, "An icon alone is a title")
        let centered = list("标题：仅文字（居中）")
        XCTAssertNil(centered.titleImage)
        XCTAssertEqual(centered.titleView.frame.midX, centered.bounds.midX, accuracy: 1, "Centered")
        // Colors through titleStyle; the icon after the title.
        let green = list("标题：图标 + 文字（居中、绿色）")
        XCTAssertEqual(green.titleLabel.textColor, CYLTagEditorViewController.green)
        XCTAssertEqual(green.titleView.frame.midX, green.bounds.midX, accuracy: 1)
        let trailing = list("标题：文字 + 图标（图标在后）")
        XCTAssertEqual(trailing.titleStyle.imagePlacement, .trailing)
        XCTAssertGreaterThan(trailing.titleView.imageView.frame.minX, trailing.titleLabel.frame.maxX)
        // No title and no icon: no title area.
        let plain = CYLTagListView(foldControl: nil)
        plain.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        plain.layoutIfNeeded()
        XCTAssertTrue(plain.titleView.isHidden)
        plain.title = "评价"
        XCTAssertFalse(plain.titleView.isHidden)
    }

    func testFoldControlTurnsItsChevronAndKeepsOnlyTheIconWhenExpanded() throws {
        let styles = try showFoldStyles()
        // "底部：文字 + 箭头": "更多 ⌄", then only the chevron, turned 180°.
        let list = styles.tagListViews[1]
        let tags = list.probe
        XCTAssertTrue(list.canFoldSection(0))
        tags.layOut()
        var fold = tags.footerFoldButton(inSection: 0)
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
        fold = tags.footerFoldButton(inSection: 0)
        XCTAssertNil(fold?.title, "Expanded: only the chevron")
        XCTAssertEqual(fold?.imageView.transform.a ?? 0, -1, accuracy: 0.01, "Turned 180°")

        // "左上角": the control before the section title.
        let leading = styles.tagListViews[5].probe
        leading.layOut()
        let headerFold = leading.headerFoldButton(inSection: 0)
        XCTAssertNotNil(headerFold)
        XCTAssertLessThan(headerFold?.frame.minX ?? .infinity, leading.headerTitleLabel(inSection: 0)?.frame.minX ?? 0,
                          "At the leading edge, before the title")
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
}
