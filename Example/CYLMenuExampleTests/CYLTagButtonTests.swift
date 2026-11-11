//
//  CYLTagButtonTests.swift
//  CYLMenuExampleTests
//
//  CYLTagButton (CYLFlatDesignTabBarItem layout) and CYLTagAppearance (CYLBadgeView box): icon and title placement,
//  position adjustments, per-state colors and fonts, the box.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLTagButtonTests: XCTestCase {

    func testTagButtonPutsTheIconBeforeTheTitle() {
        let style = CYLMenuStyle()
        style.imageTitleSpacing = 6
        let button = CYLMenuFixtures.tagButton(title: "消息", image: UIImage(systemName: "message"), style: style)
        let image = button.imageView.frame
        let title = button.titleLabel.frame
        XCTAssertEqual(title.minX - image.maxX, 6, accuracy: 0.5, "imageTitleSpacing")
        XCTAssertEqual(image.midY, title.midY, accuracy: 1, "Side by side, not stacked")
        XCTAssertEqual(image.minX, 160 - title.maxX, accuracy: 1, "The group is centered")
        XCTAssertEqual(image.size, style.imageSize)

        let font = style.titleFont(for: .normal, traitCollection: button.traitCollection)
        let expected = 2 * style.normalAppearance.margin + style.imageSize.width + 6 +
            ceil(("消息" as NSString).size(withAttributes: [.font: font]).width)
        XCTAssertEqual(CYLTagButton.width(forTitle: "消息", image: UIImage(systemName: "message"), style: style,
                                          traitCollection: button.traitCollection), expected, accuracy: 1)
    }

    func testTagButtonLayoutCenteredForIconOnlyAndTitleOnly() {
        let style = CYLMenuStyle()
        XCTAssertTrue(style.layoutCentered)
        var iconOnly = CYLMenuFixtures.tagButton(title: nil, image: UIImage(systemName: "house"), style: style)
        XCTAssertEqual(iconOnly.imageView.frame.midX, 80, accuracy: 1)
        XCTAssertTrue(iconOnly.titleLabel.frame.isEmpty)
        var titleOnly = CYLMenuFixtures.tagButton(title: "首页", image: nil, style: style)
        XCTAssertEqual(titleOnly.titleLabel.frame.midX, 80, accuracy: 1)
        XCTAssertTrue(titleOnly.imageView.frame.isEmpty)

        style.layoutCentered = false
        iconOnly = CYLMenuFixtures.tagButton(title: nil, image: UIImage(systemName: "house"), style: style)
        XCTAssertEqual(iconOnly.imageView.frame.minX, style.normalAppearance.margin, accuracy: 0.5)
        titleOnly = CYLMenuFixtures.tagButton(title: "首页", image: nil, style: style)
        XCTAssertEqual(titleOnly.titleLabel.frame.minX,
                       style.normalAppearance.margin + style.imageSize.width + style.imageTitleSpacing, accuracy: 0.5,
                       "The title keeps its place after an empty icon slot")
        XCTAssertGreaterThan(CYLTagButton.width(forTitle: "首页", image: nil, style: style, traitCollection: nil),
                             CYLTagButton.width(forTitle: "首页", image: nil, style: CYLMenuStyle(), traitCollection: nil))
    }

    func testTagButtonPositionAdjustmentsAndImageInsets() {
        let style = CYLMenuStyle()
        let plain = CYLMenuFixtures.tagButton(title: "同城", image: UIImage(systemName: "mappin"), style: style)
        style.titlePositionAdjustment = UIOffset(horizontal: 3, vertical: -2)
        style.imagePositionAdjustment = UIOffset(horizontal: -4, vertical: 1)
        style.imageInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        let moved = CYLMenuFixtures.tagButton(title: "同城", image: UIImage(systemName: "mappin"), style: style)
        XCTAssertEqual(moved.titleLabel.frame.minX - plain.titleLabel.frame.minX, 3, accuracy: 0.5)
        XCTAssertEqual(moved.titleLabel.frame.minY - plain.titleLabel.frame.minY, -2, accuracy: 0.5)
        XCTAssertEqual(moved.imageView.frame.minX - plain.imageView.frame.minX, -4, accuracy: 0.5)
        XCTAssertEqual(moved.imageView.frame.minY - plain.imageView.frame.minY, 1, accuracy: 0.5)
        XCTAssertEqual(moved.imageView.frame.width, style.imageSize.width - 4, accuracy: 0.01, "imageInsets shrink the icon in place")
    }

    func testTagButtonColorsFontsAndSelectedImagePerState() {
        let style = CYLMenuStyle()
        let font = UIFont.boldSystemFont(ofSize: 17)
        style.setTitleTextAttributes([.font: font, .foregroundColor: UIColor.red], for: .normal)
        style.setIconColor(.blue, for: .normal)
        style.setIconColor(.yellow, for: .selected)
        XCTAssertEqual(style.titleTextAttributes(for: .normal)[.foregroundColor] as? UIColor, UIColor.red)
        XCTAssertEqual(style.normalAppearance.font, font)
        XCTAssertEqual(style.iconColor(for: .disabled), style.disabledAppearance.textColor, "nil iconColor uses the text color")

        let normal = UIImage(systemName: "star")
        let selected = UIImage(systemName: "star.fill")
        let button = CYLMenuFixtures.tagButton(title: "我的", image: normal, style: style)
        button.selectedImage = selected
        XCTAssertEqual(button.titleLabel.textColor, UIColor.red)
        XCTAssertEqual(button.imageView.tintColor, UIColor.blue)
        XCTAssertTrue(button.imageView.image === normal)
        button.isSelected = true
        XCTAssertTrue(button.imageView.image === selected)
        XCTAssertEqual(button.imageView.tintColor, UIColor.yellow)
        XCTAssertEqual(button.titleLabel.textColor, style.selectedAppearance.textColor)
        button.isEnabled = false
        XCTAssertEqual(button.titleLabel.textColor, style.disabledAppearance.textColor, "Disabled wins over selected")

        style.setTitleTextAttributes(nil, for: .normal)
        XCTAssertEqual(style.normalAppearance.font, UIFont.systemFont(ofSize: 14), "nil restores the default, as CYLBadgeAppearance")
    }

    func testTagBoxFollowsCYLBadgeAppearance() {
        let appearance = CYLTagAppearance()
        appearance.cornerRadius = -3
        appearance.borderWidth = .nan
        appearance.margin = -1
        XCTAssertEqual(appearance.cornerRadius, 0)
        XCTAssertEqual(appearance.borderWidth, 0)
        XCTAssertEqual(appearance.margin, 0)
        appearance.backgroundColor = .red
        appearance.backgroundColor = nil
        XCTAssertEqual(appearance.backgroundColor, UIColor.white, "null_resettable")
        appearance.reset()
        XCTAssertEqual(appearance.margin, 10)

        let style = CYLMenuStyle()
        style.normalAppearance.cornerRadius = 0
        style.normalAppearance.borderColor = .green
        style.normalAppearance.borderWidth = 2
        style.normalAppearance.backgroundColor = .cyan
        let button = CYLMenuFixtures.tagButton(title: "首页", image: nil, style: style)
        XCTAssertEqual(button.layer.cornerRadius, 15, accuracy: 0.01, "0 is an automatic capsule")
        XCTAssertEqual(button.layer.borderWidth, 2)
        XCTAssertTrue(button.layer.borderColor == UIColor.green.cgColor)
        XCTAssertTrue(button.layer.backgroundColor == UIColor.cyan.cgColor)
        style.normalAppearance.cornerRadius = 5
        button.style = style
        button.layoutIfNeeded()
        XCTAssertEqual(button.layer.cornerRadius, 5, accuracy: 0.01)
        XCTAssertEqual((style.copy() as! CYLMenuStyle).normalAppearance.cornerRadius, 5)
        XCTAssertFalse((style.copy() as! CYLMenuStyle).normalAppearance === style.normalAppearance, "A copy has its own appearances")
    }

    func testBoldTextMakesTagsBoldAndWider() {
        let style = CYLMenuStyle()
        let regular = UITraitCollection(traitsFrom: [UITraitCollection(legibilityWeight: .regular),
                                                     UITraitCollection(preferredContentSizeCategory: .large)])
        let bold = UITraitCollection(traitsFrom: [UITraitCollection(legibilityWeight: .bold),
                                                  UITraitCollection(preferredContentSizeCategory: .large)])
        let regularFont = style.titleFont(for: .normal, traitCollection: regular)
        let boldFont = style.titleFont(for: .normal, traitCollection: bold)
        XCTAssertFalse(regularFont.fontDescriptor.symbolicTraits.contains(.traitBold))
        XCTAssertTrue(boldFont.fontDescriptor.symbolicTraits.contains(.traitBold))
        let title = "Accessibility 无障碍" as NSString
        XCTAssertGreaterThan(title.size(withAttributes: [.font: boldFont]).width,
                             title.size(withAttributes: [.font: regularFont]).width,
                             "Measured with the bold font, so bold tags do not truncate")
    }
}
