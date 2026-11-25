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
        let light = UITraitCollection(userInterfaceStyle: .light)
        let dark = UITraitCollection(userInterfaceStyle: .dark)
        XCTAssertEqual(CYLTagAppearance.defaultBackgroundColor.resolvedColor(with: light), UIColor.white.resolvedColor(with: light),
                       "light mode: white, as before")
        XCTAssertEqual(CYLTagAppearance.defaultBackgroundColor.resolvedColor(with: dark), UIColor.secondarySystemBackground.resolvedColor(with: dark),
                       "dark mode: the secondary system background, so the dynamic label tint stays readable")
        XCTAssertEqual(CYLTagAppearance.defaultTextColor.resolvedColor(with: dark), UIColor.label.resolvedColor(with: dark))
        XCTAssertEqual(CYLTagAppearance.defaultTextColor.resolvedColor(with: light), UIColor(white: 0.25, alpha: 1).resolvedColor(with: light))
        appearance.reset()
        XCTAssertEqual(appearance.margin, 10)

        let style = CYLMenuStyle()
        style.normalAppearance.cornerRadius = 1000
        style.normalAppearance.borderColor = .green
        style.normalAppearance.borderWidth = 2
        style.normalAppearance.backgroundColor = .cyan
        let button = CYLMenuFixtures.tagButton(title: "首页", image: nil, style: style)
        XCTAssertEqual(button.layer.cornerRadius, 15, accuracy: 0.01, "a radius of half the height or more is a capsule")
        style.normalAppearance.cornerRadius = 0
        let square = CYLMenuFixtures.tagButton(title: "首页", image: nil, style: style)
        XCTAssertEqual(square.layer.cornerRadius, 0, "0 is square corners, no special meaning")
        style.normalAppearance.cornerRadius = 6
        let rounded = CYLMenuFixtures.tagButton(title: "首页", image: nil, style: style)
        XCTAssertEqual(rounded.layer.cornerRadius, 6, accuracy: 0.01, "a plain number of points")
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

    func testTagButtonBadge() {
        let button = CYLTagButton(title: "消息", image: UIImage(systemName: "message"))
        button.frame.size = CGSize(width: 120, height: 40)
        button.layoutIfNeeded()
        XCTAssertNil(button.badgeValue)
        XCTAssertTrue(button.badgeLabel.isHidden, "nil hides the badge")
        XCTAssertNil(button.accessibilityValue)
        XCTAssertEqual(button.badgeColor, .systemRed, "The default color")

        button.badgeValue = ""
        button.layoutIfNeeded()
        XCTAssertFalse(button.badgeLabel.isHidden)
        XCTAssertNil(button.badgeLabel.text, "A dot has no text")
        XCTAssertEqual(button.badgeLabel.frame.size, CGSize(width: 8, height: 8))
        let icon = button.imageView.frame
        XCTAssertEqual(button.badgeLabel.frame.midX, icon.maxX, accuracy: 1, "At the icon's trailing edge")
        XCTAssertEqual(button.badgeLabel.frame.midY, icon.minY, accuracy: 1, "At the icon's top edge")
        XCTAssertEqual(button.accessibilityValue, CYLMenuLocalizedString("CYLTagBadgeDot"))
        XCTAssertFalse(button.accessibilityValue?.isEmpty ?? true)

        button.badgeValue = "99+"
        button.badgeColor = .blue
        button.layoutIfNeeded()
        XCTAssertEqual(button.badgeLabel.text, "99+")
        XCTAssertEqual(button.badgeLabel.backgroundColor, .blue)
        XCTAssertGreaterThan(button.badgeLabel.frame.width, button.badgeLabel.frame.height, "A capsule")
        XCTAssertTrue(button.bounds.contains(button.badgeLabel.frame), "Kept inside the tag")
        XCTAssertEqual(button.accessibilityValue, "99+")
        button.accessibilityValue = "custom"
        XCTAssertEqual(button.accessibilityValue, "custom", "A value that was set wins")
        button.badgeColor = nil
        XCTAssertEqual(button.badgeColor, .systemRed, "nil restores the default")

        let titleOnly = CYLTagButton(title: "消息", image: nil)
        titleOnly.badgeValue = "1"
        titleOnly.layoutIfNeeded()
        XCTAssertEqual(titleOnly.badgeLabel.frame.minX, min(titleOnly.titleLabel.frame.maxX
                       - titleOnly.badgeLabel.frame.height / 2, titleOnly.bounds.width - titleOnly.badgeLabel.frame.width),
                       accuracy: 1, "At the title's corner when there is no icon")
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

    // MARK: - Unset colors (null_resettable), spec: item explicit > stack explicit > subclass built-in > component built-in

    func testUntouchedAppearanceReportsUnsetAndEffectiveBuiltIns() {
        let appearance = CYLTagAppearance()
        XCTAssertFalse(appearance.isBackgroundColorSet)
        XCTAssertFalse(appearance.isTextColorSet)
        XCTAssertFalse(appearance.isIconColorSet)
        XCTAssertNil(appearance.explicitTextColor)
        XCTAssertEqual(appearance.textColor, CYLTagAppearance.defaultTextColor, "reads the effective built-in, never nil")
        XCTAssertEqual(appearance.iconColor, appearance.textColor, "an unset icon color follows the effective text color")
        appearance.textColor = .red
        XCTAssertTrue(appearance.isTextColorSet)
        XCTAssertEqual(appearance.explicitTextColor, .red)
        XCTAssertEqual(appearance.iconColor, .red, "the icon follows an explicit text color")
        appearance.iconColor = .blue
        XCTAssertEqual(appearance.explicitIconColor, .blue)
        XCTAssertEqual(appearance.iconColor, .blue, "explicit icon color wins over the text color")
        appearance.iconColor = nil
        appearance.textColor = nil
        appearance.backgroundColor = .green
        appearance.backgroundColor = nil
        XCTAssertFalse(appearance.isTextColorSet, "nil resets")
        XCTAssertFalse(appearance.isIconColorSet)
        XCTAssertFalse(appearance.isBackgroundColorSet)
        XCTAssertEqual(appearance.textColor, CYLTagAppearance.defaultTextColor)
        XCTAssertEqual(appearance.backgroundColor, CYLTagAppearance.defaultBackgroundColor)
    }

    func testExplicitWinsOverBuiltInInLightAndDark() {
        let light = UITraitCollection(userInterfaceStyle: .light)
        let dark = UITraitCollection(userInterfaceStyle: .dark)
        let appearance = CYLTagAppearance()
        for traits in [light, dark] {
            XCTAssertEqual(appearance.textColor.resolvedColor(with: traits), CYLTagAppearance.defaultTextColor.resolvedColor(with: traits),
                           "unset: the built-in, resolved with the traits at use time")
        }
        appearance.textColor = .systemPink
        for traits in [light, dark] {
            XCTAssertEqual(appearance.textColor.resolvedColor(with: traits), UIColor.systemPink.resolvedColor(with: traits), "explicit wins")
        }
        XCTAssertEqual(appearance.backgroundColor.resolvedColor(with: light), UIColor.white.resolvedColor(with: light))
        XCTAssertEqual(appearance.backgroundColor.resolvedColor(with: dark), UIColor.secondarySystemBackground.resolvedColor(with: dark))
    }

    func testCopyAndEqualityCarryTheUnsetState() {
        let untouched = CYLTagAppearance()
        let copy = untouched.copy()
        XCTAssertFalse(copy.isTextColorSet, "a copy of an untouched appearance stays unset, not the resolved color")
        XCTAssertFalse(copy.isBackgroundColorSet)
        XCTAssertFalse(copy.isIconColorSet)
        XCTAssertTrue(copy == untouched)
        let explicitDefault = CYLTagAppearance()
        explicitDefault.textColor = CYLTagAppearance.defaultTextColor
        XCTAssertFalse(explicitDefault == untouched, "set to the built-in's value is still explicit, so not equal to unset")
        XCTAssertTrue(explicitDefault.copy().isTextColorSet)

        let style = CYLMenuStyle()
        let styleCopy = style.copy() as! CYLMenuStyle
        XCTAssertFalse(styleCopy.disabledAppearance.isIconColorSet)
        XCTAssertFalse(styleCopy.normalAppearance.isTextColorSet)
        XCTAssertNil(styleCopy.explicitIconColor(for: .normal))
        styleCopy.setIconColor(.orange, for: .normal)
        XCTAssertEqual(styleCopy.explicitIconColor(for: .normal), UIColor.orange)
        XCTAssertNil(style.explicitIconColor(for: .normal), "the copy is independent")
        styleCopy.setIconColor(nil, for: .normal)
        XCTAssertNil(styleCopy.explicitIconColor(for: .normal), "nil resets")
    }

    func testCopyOfUntouchedStyleStillFollowsLaterDefaults() {
        // A stack-like default: the style copy made before a value is set on the original keeps no stale resolved color.
        let original = CYLTagAppearance()
        let copy = original.copy()
        original.textColor = .brown
        XCTAssertFalse(copy.isTextColorSet)
        XCTAssertEqual(copy.textColor, CYLTagAppearance.defaultTextColor)
        // Setting a value on the copy after copying wins, and resetting it returns to the built-in again.
        copy.textColor = .purple
        XCTAssertEqual(copy.textColor, .purple)
        copy.textColor = nil
        XCTAssertEqual(copy.textColor, CYLTagAppearance.defaultTextColor)
    }

    func testTagButtonPassesExplicitIconColorElseTheTagBuiltIn() {
        let style = CYLMenuStyle()
        style.normalAppearance.textColor = nil
        style.setIconColor(nil, for: .normal)
        let builtIn = CYLMenuFixtures.tagButton(title: "首页", image: UIImage(systemName: "message"), style: style)
        XCTAssertEqual(builtIn.titleLabel.textColor, CYLTagAppearance.defaultTextColor, "the tag's built-in text color, as before")
        XCTAssertEqual(builtIn.imageView.tintColor?.resolvedColor(with: builtIn.traitCollection), CYLTagAppearance.defaultTextColor.resolvedColor(with: builtIn.traitCollection), "the icon follows the built-in text color, as before")
        style.setIconColor(.systemTeal, for: .normal)
        let explicit = CYLMenuFixtures.tagButton(title: "首页", image: UIImage(systemName: "message"), style: style)
        XCTAssertEqual(explicit.imageView.tintColor?.resolvedColor(with: explicit.traitCollection), UIColor.systemTeal.resolvedColor(with: explicit.traitCollection), "an explicit icon color wins over the tag built-in")
        XCTAssertEqual(explicit.titleLabel.textColor, CYLTagAppearance.defaultTextColor, "the title is not affected by the icon color")
    }

    // MARK: - Liquid Glass tint: an unset background is ignored

    private func glassTint(of button: CYLTagButton, _ traits: UITraitCollection) -> UIColor? {
        guard #available(iOS 26.0, *), let glass = (button.liquidGlassView as? UIVisualEffectView)?.effect as? UIGlassEffect else { return nil }
        return glass.tintColor?.resolvedColor(with: traits)
    }

    func testGlassIgnoresAnUnsetBackgroundAndUsesTheFrostedDefault() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("Liquid Glass needs iOS 26") }
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        defer { CYLAnimatedItemView.liquidGlassActiveOverride = nil }
        let light = UITraitCollection(userInterfaceStyle: .light)
        let dark = UITraitCollection(userInterfaceStyle: .dark)
        let style = CYLMenuStyle()
        style.backgroundStyle = .liquidGlass
        let normal = CYLMenuFixtures.tagButton(title: "A", image: nil, style: style)
        XCTAssertEqual(normal.itemBackgroundColor, CYLMenuStyle.defaultGlassTint, "unset background: the low-alpha default tint")
        XCTAssertEqual(normal.itemGlassTintAlpha, 1, "its own alpha is the tint")
        XCTAssertEqual(CYLMenuFixtures.rgb(glassTint(of: normal, light)), CYLMenuFixtures.rgb(UIColor(red: 225 / 255, green: 222 / 255, blue: 220 / 255, alpha: 1)))
        var alpha: CGFloat = 0
        glassTint(of: normal, light)?.getRed(nil, green: nil, blue: nil, alpha: &alpha)
        XCTAssertEqual(alpha, CYLMenuStyle.defaultGlassTintAlphaLight, accuracy: 0.01)
        // The glass takes its tint resolved with the button's own traits: a dark-mode button for the dark values.
        let darkNormal = CYLMenuFixtures.tagButton(title: "A", image: nil, style: style)
        // In a dark window: a detached view reports the light trait whatever its override says.
        let darkWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        darkWindow.overrideUserInterfaceStyle = .dark
        darkWindow.isHidden = false
        darkWindow.addSubview(darkNormal)
        defer { darkWindow.isHidden = true }
        darkNormal.style = style
        darkNormal.layoutIfNeeded()
        XCTAssertEqual(CYLMenuFixtures.rgb(glassTint(of: darkNormal, dark)), CYLMenuFixtures.rgb(.white))
        glassTint(of: darkNormal, dark)?.getRed(nil, green: nil, blue: nil, alpha: &alpha)
        XCTAssertEqual(alpha, CYLMenuStyle.defaultGlassTintAlphaDark, accuracy: 0.01)
        let disabled = CYLMenuFixtures.tagButton(title: "A", image: nil, style: style)
        disabled.isEnabled = false
        XCTAssertEqual(disabled.itemBackgroundColor, CYLMenuStyle.defaultGlassTint)
        // Reset back to unset is unset again.
        style.normalAppearance.backgroundColor = .red
        normal.style = style
        XCTAssertEqual(normal.itemBackgroundColor, .red)
        style.normalAppearance.backgroundColor = nil
        normal.style = style
        XCTAssertEqual(normal.itemBackgroundColor, CYLMenuStyle.defaultGlassTint)
    }

    func testGlassTintsWithAnExplicitBackgroundAndASelectedTagKeepsAlphaOne() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("Liquid Glass needs iOS 26") }
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        defer { CYLAnimatedItemView.liquidGlassActiveOverride = nil }
        let light = UITraitCollection(userInterfaceStyle: .light)
        let style = CYLMenuStyle()
        style.backgroundStyle = .liquidGlass
        style.normalAppearance.backgroundColor = UIColor.blue.withAlphaComponent(0.4)
        let normal = CYLMenuFixtures.tagButton(title: "A", image: nil, style: style)
        XCTAssertEqual(normal.itemBackgroundColor, UIColor.blue.withAlphaComponent(0.4))
        var alpha: CGFloat = 0
        glassTint(of: normal, light)?.getRed(nil, green: nil, blue: nil, alpha: &alpha)
        XCTAssertEqual(alpha, 0.4 * 0.75, accuracy: 0.01, "an explicit color tints at alpha x 0.75, as before")
        let selected = CYLMenuFixtures.tagButton(title: "A", image: nil, style: style)
        selected.isSelected = true
        XCTAssertNotNil(selected.itemBackgroundColor, "the selected tint is explicit")
        XCTAssertEqual(selected.itemGlassTintAlpha, 1)
        glassTint(of: selected, light)?.getRed(nil, green: nil, blue: nil, alpha: &alpha)
        XCTAssertEqual(alpha, 1, accuracy: 0.01, "the selected tag's tint alpha stays 1")
        // The pressed color is explicit too.
        style.highlightedBackgroundColor = .green
        let pressed = CYLMenuFixtures.tagButton(title: "A", image: nil, style: style)
        pressed.isHighlighted = true
        XCTAssertEqual(pressed.itemBackgroundColor, .green)
    }

    func testFlatTagsStillResolveTheBuiltInBackground() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        defer { CYLAnimatedItemView.liquidGlassActiveOverride = nil }
        for look in [CYLMenuStyle(), CYLMenuStyle.tagCloud(), CYLMenuStyle.tagContainer(), CYLMenuStyle.wordPicker(), CYLMenuStyle.gridStyle(itemsPerRow: 3),
                     CYLMenuStyle.classifyMenuTag(.chengNi), CYLMenuStyle.classifyMenuTag(.general)] {
            XCTAssertEqual(look.backgroundStyle, .flat)
            let button = CYLMenuFixtures.tagButton(title: "A", image: nil, style: look)
            XCTAssertEqual(button.itemBackgroundColor, look.normalAppearance.backgroundColor, "flat: the effective color, set or built-in")
        }
        let plain = CYLMenuFixtures.tagButton(title: "A", image: nil, style: CYLMenuStyle())
        for traits in [UITraitCollection(userInterfaceStyle: .light), UITraitCollection(userInterfaceStyle: .dark)] {
            XCTAssertEqual(plain.itemBackgroundColor?.resolvedColor(with: traits), CYLTagAppearance.defaultBackgroundColor.resolvedColor(with: traits))
        }
        // Glass requested where the system draws none: flat, so the built-in color still fills the tag.
        CYLAnimatedItemView.liquidGlassActiveOverride = false
        let style = CYLMenuStyle()
        style.backgroundStyle = .liquidGlass
        let fallback = CYLMenuFixtures.tagButton(title: "A", image: nil, style: style)
        XCTAssertEqual(fallback.itemBackgroundColor, CYLTagAppearance.defaultBackgroundColor)
    }

    /// WCAG contrast of the default 0.25-gray text (dark: label) on the frosted default tint over matching backdrops (the tint composited
    /// over the backdrop; the real glass adds blur and highlights that this ignores). Mismatched ones (light text mode over black, dark over white) are not asserted.
    func testDefaultTextContrastOnTheFrostedTint() {
        func linear(_ value: CGFloat) -> CGFloat { value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4) }
        func luminance(_ c: [CGFloat]) -> CGFloat { 0.2126 * linear(c[0]) + 0.7152 * linear(c[1]) + 0.0722 * linear(c[2]) }
        func contrast(_ a: [CGFloat], _ b: [CGFloat]) -> CGFloat {
            let (x, y) = (luminance(a), luminance(b))
            return (max(x, y) + 0.05) / (min(x, y) + 0.05)
        }
        func over(_ tint: [CGFloat], _ alpha: CGFloat, _ backdrop: [CGFloat]) -> [CGFloat] { (0..<3).map { tint[$0] * alpha + backdrop[$0] * (1 - alpha) } }
        let blue: [CGFloat] = [0, 122 / 255, 1], white: [CGFloat] = [1, 1, 1], black: [CGFloat] = [0, 0, 0]
        let lightTint: [CGFloat] = [225 / 255, 222 / 255, 220 / 255], gray: [CGFloat] = [0.25, 0.25, 0.25]
        for (name, backdrop) in [("blue", blue), ("white", white)] {
            XCTAssertGreaterThanOrEqual(contrast(gray, over(lightTint, 0.5, backdrop)), 3, "light text on frosted tint over \(name)")
        }
        for (name, backdrop) in [("blue", blue), ("black", black)] {
            XCTAssertGreaterThanOrEqual(contrast(white, over(white, 0.14, backdrop)), 3, "dark label on frosted tint over \(name)")
        }
    }
}
