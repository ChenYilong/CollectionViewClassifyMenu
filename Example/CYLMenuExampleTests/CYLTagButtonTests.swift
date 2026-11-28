//
//  CYLTagButtonTests.swift
//  CYLMenuExampleTests
//
//  CYLTagButton (CYLFlatDesignTabBarItem layout) and CYLTagAppearance (CYLBadgeView box): icon and title placement,
//  position adjustments, per-state colors and fonts, the box.
//

import XCTest
import UIKit
import CYLTabBarController
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
        appearance.reset()
        XCTAssertEqual(appearance.backgroundColor, CYLTagAppearance.defaultBackgroundColor, "reset restores the default")
        XCTAssertEqual(CYLTagAppearance.defaultBackgroundColor, UIColor.white)
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

    // MARK: - On its own: the icon above the title, the badge, the convenience initializers

    func testTagButtonPutsTheIconAboveOrBelowTheTitle() {
        let style = CYLMenuStyle()
        style.imagePlacement = .top
        style.imageSize = CGSize(width: 24, height: 24)
        style.imageTitleSpacing = 4
        XCTAssertEqual(CYLTagImagePlacement.top.rawValue, 2)
        XCTAssertEqual(CYLTagImagePlacement.bottom.rawValue, 3)
        XCTAssertEqual(CYLTagImagePlacement.trailing.rawValue, 1, "Existing raw values are kept")
        let height = CYLTagButton.height(for: style, traitCollection: nil)
        let font = style.titleFont(for: .normal, traitCollection: nil)
        let insets = style.normalAppearance.contentInsets
        XCTAssertGreaterThanOrEqual(height, 24 + 4 + ceil(font.lineHeight) + insets.top + insets.bottom,
                                    "The icon slot and the spacing are part of the height")
        let button = CYLMenuFixtures.tagButton(title: "消息", image: UIImage(systemName: "message"), style: style,
                                               size: CGSize(width: 120, height: height))
        let image = button.imageView.frame
        let title = button.titleLabel.frame
        XCTAssertEqual(title.minY - image.maxY, 4, accuracy: 0.5, "imageTitleSpacing between them")
        XCTAssertEqual(image.midX, 60, accuracy: 1, "The icon is centered")
        XCTAssertEqual(title.midX, 60, accuracy: 1, "The title is centered")
        XCTAssertEqual(image.size, style.imageSize)
        XCTAssertEqual(CYLTagButton.width(forTitle: "消息", iconSize: style.imageSize, style: style, traitCollection: nil),
                       ceil(max(24, ceil(("消息" as NSString).size(withAttributes: [.font: font]).width))
                            + insets.left + insets.right), accuracy: 1, "The wider of the two, not their sum")

        style.imagePlacement = .bottom
        button.style = style
        button.layoutIfNeeded()
        XCTAssertEqual(button.imageView.frame.minY - button.titleLabel.frame.maxY, 4, accuracy: 0.5,
                       "The icon below the title")
    }

    func testTagButtonIconOnlyAndTitleOnlyReserveNoSpacing() {
        let style = CYLMenuStyle()
        let insets = style.normalAppearance.contentInsets
        let iconOnly = CYLTagButton(title: nil, image: UIImage(systemName: "house"))
        XCTAssertEqual(iconOnly.intrinsicContentSize.width, style.imageSize.width + insets.left + insets.right,
                       accuracy: 0.5, "No spacing for the missing title")
        style.imagePlacement = .top
        iconOnly.style = style
        iconOnly.frame.size = iconOnly.intrinsicContentSize
        iconOnly.layoutIfNeeded()
        XCTAssertTrue(iconOnly.titleLabel.frame.isEmpty)
        XCTAssertEqual(iconOnly.imageView.frame.midY, iconOnly.bounds.midY, accuracy: 1, "A lone icon is centered")
        let titleOnly = CYLTagButton(title: "首页", image: nil)
        titleOnly.style = style
        titleOnly.frame.size = titleOnly.intrinsicContentSize
        titleOnly.layoutIfNeeded()
        XCTAssertTrue(titleOnly.imageView.frame.isEmpty)
        XCTAssertEqual(titleOnly.titleLabel.frame.midY, titleOnly.bounds.midY, accuracy: 1, "A lone title is centered")
        XCTAssertEqual(CYLTagButton.height(forTitle: "首页", iconSize: .zero, style: style, traitCollection: nil),
                       max(style.itemHeight, ceil(style.titleFont(for: .normal, traitCollection: nil).lineHeight)
                           + insets.top + insets.bottom), accuracy: 0.5, "No spacing for the missing icon")
    }

    /// The badge is the base class's (`CYLAnimatedItemView.badgeValue`, drawn by CYLBadge on `badgeAnchorView`); the tag
    /// keeps `badgeAnchorView` on its icon, or on its title when it has no icon, and VoiceOver reads the value.
    func testTagButtonBadge() {
        let button = CYLTagButton(title: "消息", image: UIImage(systemName: "message"))
        button.frame.size = CGSize(width: 120, height: 40)
        button.layoutIfNeeded()
        XCTAssertNil(button.badgeValue)
        XCTAssertFalse(button.isShowingBadge, "nil hides the badge")
        XCTAssertNil(button.accessibilityValue)

        button.badgeValue = ""
        button.layoutIfNeeded()
        XCTAssertTrue(button.isShowingBadge, "An empty string shows a dot")
        XCTAssertEqual(button.badgeAnchorView.frame, button.imageView.frame, "The anchor is the icon")
        XCTAssertFalse(button.accessibilityValue?.isEmpty ?? true, "VoiceOver reads CYLBadge's localized description of the dot")

        button.badgeValue = "99+"
        button.layoutIfNeeded()
        XCTAssertTrue(button.isShowingBadge)
        XCTAssertTrue(button.accessibilityValue?.contains("99+") ?? false, "CYLBadge's description holds the value")
        button.accessibilityValue = "custom"
        XCTAssertTrue(button.accessibilityValue?.contains("custom") ?? false, "A value that was set is read first")

        let titleOnly = CYLTagButton(title: "消息", image: nil)
        titleOnly.frame.size = CGSize(width: 120, height: 40)
        titleOnly.badgeValue = "1"
        titleOnly.layoutIfNeeded()
        XCTAssertEqual(titleOnly.badgeAnchorView.frame, titleOnly.titleLabel.frame, "The anchor is the title when there is no icon")
    }

    func testTagButtonConvenienceInitializers() {
        let url = URL(fileURLWithPath: "/no/such/file.json")
        let button = CYLTagButton(title: "首页", image: UIImage(systemName: "house"), animationURL: url)
        XCTAssertEqual(button.title, "首页")
        XCTAssertEqual(button.animationURL, url)
        XCTAssertNil(button.animationView, "A missing file shows the image")
        XCTAssertEqual(button.bounds.size, button.intrinsicContentSize, "Sized to fit")
        XCTAssertEqual(button.sizeThatFits(.zero), button.intrinsicContentSize)
        XCTAssertGreaterThan(button.intrinsicContentSize.width, 0)
        XCTAssertTrue(button.isAccessibilityElement)
        XCTAssertEqual(button.accessibilityLabel, "首页")
        XCTAssertTrue(button.accessibilityTraits.contains(.button))
        XCTAssertFalse(button.accessibilityTraits.contains(.selected))
        button.isSelected = true
        XCTAssertTrue(button.accessibilityTraits.contains(.selected))
        button.isEnabled = false
        XCTAssertTrue(button.accessibilityTraits.contains(.notEnabled))
        let image = UIImage(systemName: "star")
        image?.accessibilityLabel = "Favorites"
        XCTAssertEqual(CYLTagButton(title: nil, image: image).accessibilityLabel, "Favorites",
                       "An icon-only tag reads its icon's label")
        XCTAssertFalse(CYLTagButton(frame: .zero).accessibilityTraits.contains(.selected),
                       "A tag inside a list keeps the traits its host gives it")
    }

    /**
     * CYLAnimatedItemView's display priority, inherited (https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md),
     * with the engines this example adds: a file that cannot play shows the static image, the component's placeholder
     * only without one, and a title alone never grows an icon.
     */
    func testTagButtonDisplayPriorityWhenTheAnimationCannotPlay() {
        let missing = URL(fileURLWithPath: "/no/such/file.json")
        let unknown = FileManager.default.temporaryDirectory.appendingPathComponent("cyl-tag.unknown-type")
        try? Data("not an animation".utf8).write(to: unknown)
        let image = UIImage(systemName: "house")
        for url in [missing, unknown] {
            let withImage = CYLTagButton(title: "首页", image: image, animationURL: url)
            withImage.layoutIfNeeded()
            XCTAssertNil(withImage.animationView, url.lastPathComponent)
            XCTAssertTrue(withImage.imageView.image === image, "The static image wins over the placeholder")
            XCTAssertFalse(withImage.imageView.isHidden)
            let withoutImage = CYLTagButton(title: "首页", image: nil, animationURL: url)
            withoutImage.layoutIfNeeded()
            if CYLAnimatedItemView.defaultPlaceholderImage != nil {
                XCTAssertNotNil(withoutImage.imageView.image, "No static image: the component's placeholder")
            }
            withoutImage.playAnimation()
        }
        let titleOnly = CYLTagButton(title: "首页", image: nil)
        titleOnly.layoutIfNeeded()
        XCTAssertNil(titleOnly.imageView.image, "A title without an icon never shows a placeholder")
    }

    /// `CYLMenuStyle.imageFillsTagHeight` (AndroidTagView's avatar): the image a circle as tall as the tag at its
    /// leading edge, the title after it; the measured width and height follow, and a copied style keeps it.
    func testImageFillsTheTagHeightAtTheLeadingEdge() {
        let style = CYLMenuStyle.tagContainer()
        style.imageFillsTagHeight = true
        XCTAssertTrue((style.copy() as? CYLMenuStyle)?.imageFillsTagHeight ?? false)
        let icon = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40)).image { _ in
            UIColor.systemYellow.setFill()
            UIRectFill(CGRect(x: 0, y: 0, width: 40, height: 40))
        }
        let button = CYLTagButton(title: "Java", image: icon)
        button.style = style
        button.showsDeleteIndicator = true
        let size = button.intrinsicContentSize
        let plainHeight = CYLTagButton.height(forTitle: "Java", iconSize: .zero, style: style, traitCollection: nil)
        XCTAssertEqual(size.height, plainHeight, accuracy: 0.5, "the image takes no extra height")
        let font = style.titleFont(for: .normal, traitCollection: nil)
        let title = ceil(("Java" as NSString).size(withAttributes: [.font: font]).width)
        XCTAssertGreaterThanOrEqual(size.width, plainHeight + title + style.normalAppearance.contentInsets.right,
                                    "room for the image, the title and the right inset")
        button.frame = CGRect(origin: .zero, size: size)
        button.layoutIfNeeded()
        XCTAssertEqual(button.imageView.frame, CGRect(x: 0, y: 0, width: size.height, height: size.height))
        XCTAssertEqual(button.imageView.layer.cornerRadius, size.height / 2, accuracy: 0.01)
        XCTAssertTrue(button.imageView.layer.masksToBounds)
        XCTAssertGreaterThanOrEqual(button.titleLabel.frame.minX, size.height + style.imageTitleSpacing - 0.5)
        XCTAssertLessThanOrEqual(button.titleLabel.frame.maxX, button.deleteIndicatorHitFrame.minX + 0.5,
                                 "the title ends before the cross")
        XCTAssertEqual(button.titleLabel.text, "Java")
    }

    /// AndroidTagView's tag_text_wrap, tag_elevation and cross drawable: `titleWraps`, `elevation` and
    /// `deleteIndicatorImage`; a copied style keeps them.
    func testWrappingTitleElevationAndCrossImage() {
        let style = CYLMenuStyle.tagContainer()
        style.titleWraps = true
        style.elevation = 4
        let cross = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image { _ in UIRectFill(CGRect(x: 0, y: 0, width: 10, height: 10)) }
        style.deleteIndicatorImage = cross
        let copy = style.copy() as? CYLMenuStyle
        XCTAssertEqual(copy?.titleWraps, true)
        XCTAssertEqual(copy?.elevation, 4)
        XCTAssertTrue(copy?.deleteIndicatorImage === cross)

        let title = "A long tag that wraps onto a second line instead of leaving the container"
        let one = CYLTagButton.height(forTitle: title, iconSize: .zero, style: style, traitCollection: nil)
        let wrapped = CYLTagButton.height(forTitle: title, iconSize: .zero, width: 200, showsDeleteIndicator: true,
                                          style: style, traitCollection: nil)
        XCTAssertGreaterThan(wrapped, one + 10, "the title takes several lines at 200 pt")
        style.titleWraps = false
        XCTAssertEqual(CYLTagButton.height(forTitle: title, iconSize: .zero, width: 200, showsDeleteIndicator: true,
                                           style: style, traitCollection: nil), one, "no wrapping: one line")
        style.titleWraps = true

        let button = CYLTagButton(title: title, image: nil)
        button.style = style
        button.showsDeleteIndicator = true
        button.frame = CGRect(x: 0, y: 0, width: 200, height: wrapped)
        button.layoutIfNeeded()
        XCTAssertEqual(button.titleLabel.numberOfLines, 0)
        XCTAssertGreaterThan(button.titleLabel.frame.height, button.titleLabel.font.lineHeight * 1.5)
        XCTAssertLessThanOrEqual(button.titleLabel.frame.maxX, button.deleteIndicatorHitFrame.minX + 0.5)
        XCTAssertFalse(button.layer.masksToBounds, "the shadow is outside the bounds")
        XCTAssertEqual(button.layer.shadowOpacity, 0.25, accuracy: 0.001)
        XCTAssertNotNil(button.layer.shadowPath)
        XCTAssertNil(button.deleteIndicatorLabel.text, "the image replaces the indicator title")
        let crossView = button.deleteIndicatorLabel.subviews.compactMap { $0 as? UIImageView }.first
        XCTAssertTrue(crossView?.image === cross)
        XCTAssertFalse(crossView?.isHidden ?? true)
        XCTAssertGreaterThan(crossView?.bounds.width ?? 0, 0)
    }
}
