//
//  CYLTagListLayoutTests.swift
//  CYLMenuExampleTests
//
//  CYLTagListView: what the host adds (images, header icons, accessory views), style and Dynamic Type sizes, narrow
//  widths, the grid style and leading content.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLTagListLayoutTests: CYLMenuExampleTestCase {

    func testImagesHeaderIconsAndAccessoryViewsComeFromTheHost() {
        let source = CYLMenuFixtures.source(itemCount: 3, sections: 1)
        let icon = UIImage(systemName: "star.fill")
        source.sections[0].items[0].image = icon
        // Same title, so the image alone accounts for the width difference (system digits are proportional).
        source.sections[0].items[1].title = source.sections[0].items[0].title
        source.sections[0].image = icon
        let accessory = UIButton(type: .system)
        accessory.setTitle("行业: IT互联网 ▾", for: .normal)
        source.sections[0].accessoryView = accessory
        let view = showTagList(source, width: 375)
        let tags = view.probe
        tags.layOut()

        let withImage = tags.itemFrame(at: ip(0, 0))?.width ?? 0
        let withoutImage = tags.itemFrame(at: ip(1, 0))?.width ?? 0
        XCTAssertEqual(withImage - withoutImage, view.style.imageSize.width + view.style.imageTitleSpacing, accuracy: 1,
                       "The image accounts for the difference")
        XCTAssertTrue(tags.tagButton(at: ip(0, 0))?.imageView.image === icon)

        let header = tags.header(inSection: 0)
        header?.layoutIfNeeded()
        XCTAssertTrue(accessory.superview === header)
        XCTAssertLessThanOrEqual(accessory.frame.maxX, header?.bounds.width ?? 0)
        XCTAssertLessThanOrEqual(tags.headerTitleLabel(inSection: 0)?.frame.maxX ?? .infinity, accessory.frame.minX)
        XCTAssertTrue(tags.headerIconView(inSection: 0)?.image === icon)
        captureScreen(named: "test-layout-host-images-and-accessory")
    }

    func testStyleAndDynamicTypeChangeItemSize() {
        let source = CYLMenuFixtures.source(itemCount: 40, sections: 1)
        let view = showTagList(source, width: 320)
        let style = CYLMenuStyle()
        style.itemHeight = 40
        style.normalAppearance.cornerRadius = 0  // automatic capsule
        view.style = style
        view.layoutIfNeeded()
        XCTAssertEqual(view.probe.itemFrame(at: ip(0, 0))?.height ?? 0, 40, accuracy: 0.5)
        style.itemHeight = 10
        XCTAssertEqual(view.style.itemHeight, 40, accuracy: 0.01, "The view keeps its own copy")

        let large = UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)
        let largeFont = view.style.titleFont(for: .normal, traitCollection: large)
        let base = view.style.normalAppearance.font.pointSize
        XCTAssertGreaterThan(largeFont.pointSize, base)
        XCTAssertLessThanOrEqual(largeFont.pointSize, base * CYLMaximumFontScale + 0.01)
        let fixed = view.style.copy() as! CYLMenuStyle
        fixed.adjustsFontForContentSizeCategory = false
        XCTAssertEqual(fixed.titleFont(for: .normal, traitCollection: large).pointSize, base, accuracy: 0.01)
    }

    func testNarrowWidthsAndLongTitlesStayInside() {
        for width in [240.0, 320.0, 390.0] as [CGFloat] {
            let source = CYLMenuFixtures.source(itemCount: 25, sections: 3)
            source.sections[1].items[0].title = "一个非常非常非常非常非常非常非常非常非常长的标签 🧑‍🍳✨🚀"
            let view = showTagList(source, width: width)
            view.foldStyle = .headerButton
            view.layoutIfNeeded()
            view.assertItemsFit()
            for section in 0..<3 {
                view.setExpanded(true, forSection: section, animated: false)
            }
            view.assertItemsFit()
            XCTAssertEqual(view.contentHeight, view.heightThatFitsWidth(width), accuracy: 1)
            if width == 240 {
                captureScreen(named: "test-layout-narrow-240pt")
            }
        }
    }

    func testGridStyleGivesEqualWidthsAndTruncates() {
        let source = CYLExampleMenuSource(sections: [CYLExampleMenuSection(title: "发现", titles: [
            "短", "一个非常非常非常长的、肯定放不下的发现标题", "番茄工作法", "空气炸锅食谱",
        ])])
        let view = showTagList(source, width: 390)
        view.style = CYLMenuStyle.gridStyle(itemsPerRow: 2)
        view.selectionMode = .none
        view.reloadMenuData()
        view.layoutIfNeeded()
        let tags = view.probe
        tags.layOut()
        let frames = (0..<4).compactMap { tags.itemFrame(at: ip($0, 0)) }
        XCTAssertEqual(frames.count, 4)
        let insets = view.style.sectionInsets
        let expected = floor((390 - insets.left - insets.right - view.style.interitemSpacing) / 2)
        for frame in frames {
            XCTAssertEqual(frame.width, expected, accuracy: 0.5, "Every item the same width")
        }
        XCTAssertEqual(frames[0].minY, frames[1].minY, accuracy: 0.5, "Two per row")
        XCTAssertGreaterThan(frames[2].minY, frames[0].minY)
        XCTAssertEqual(frames[0].minX, insets.left, accuracy: 0.5)
        // The long title is truncated, not wrapped and not wider than its column.
        let long = tags.tagButton(at: ip(1, 0))
        XCTAssertNotNil(long)
        if let long {
            long.layoutIfNeeded()
            let full = long.titleLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 40)).width
            XCTAssertLessThan(long.titleLabel.frame.width, full)
            XCTAssertEqual(long.titleLabel.lineBreakMode, .byTruncatingTail)
            XCTAssertLessThanOrEqual(long.titleLabel.frame.maxX, expected + 0.5)
        }
        XCTAssertTrue(CYLMenuStyle.gridStyle(itemsPerRow: 2).normalAppearance.backgroundColor == .clear)
        captureScreen(named: "test-layout-grid-two-per-row")
        withExtendedLifetime(source) {}
    }

    func testLeadingContentPutsTheTitleFirstAndKeepsItsTrailingIconVisible() {
        let style = CYLMenuStyle.gridStyle(itemsPerRow: 2)
        XCTAssertEqual(style.contentAlignment, .leading)
        XCTAssertEqual(style.imagePlacement, .trailing, "Title on the left, icon on the right")
        let icon = CYLMenuFixtures.squareImage()
        let size = CGSize(width: 170, height: 32)
        // A short title: at the leading margin, the icon right after it (not centered, not at the far edge).
        let short = CYLMenuFixtures.tagButton(title: "番茄工作法", image: icon, style: style, size: size)
        XCTAssertEqual(short.titleLabel.frame.minX, 0, accuracy: 0.5)
        XCTAssertEqual(short.imageView.frame.minX, short.titleLabel.frame.maxX + style.imageTitleSpacing, accuracy: 1)
        XCTAssertLessThan(short.imageView.frame.maxX, 170 - 20, "The icon follows the title")
        // A long title: truncated so that the icon after it stays inside the tag.
        let long = CYLMenuFixtures.tagButton(title: "一个非常非常非常长的、肯定放不下的发现标题", image: icon, style: style, size: size)
        let full = long.titleLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 40)).width
        XCTAssertLessThan(long.titleLabel.frame.width, full, "Truncated with an ellipsis")
        XCTAssertLessThanOrEqual(long.imageView.frame.maxX, 170 + 0.5, "The icon stays visible")
        XCTAssertGreaterThan(long.imageView.frame.minX, long.titleLabel.frame.maxX)
        // A title alone: no empty icon slot before it.
        let alone = CYLMenuFixtures.tagButton(title: "自制酸奶", image: nil, style: style, size: size)
        XCTAssertEqual(alone.titleLabel.frame.minX, 0, accuracy: 0.5)
        // The default stays centered.
        XCTAssertEqual(CYLMenuStyle().contentAlignment, .center)
    }
}
