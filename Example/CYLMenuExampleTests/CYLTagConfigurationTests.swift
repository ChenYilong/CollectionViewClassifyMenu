//
//  CYLTagConfigurationTests.swift
//  CYLMenuExampleTests
//
//  CYLTagListView+CYLConfiguration: lists made from a map and from a configuration file, as CYLTabBarController does.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
import CYLAnimatedItem
@testable import CYLMenuExample

final class CYLTagConfigurationTests: XCTestCase {

    func testDictionaryConfigurationCreatesAndStylesTheTags() {
        let view = CYLTagListView(configuration: CYLTagConfigurationDemoViewController.mapConfiguration())
        view.frame = CGRect(x: 0, y: 0, width: 375, height: 300)
        view.layoutIfNeeded()
        XCTAssertEqual(view.selectionMode, .multiple)
        XCTAssertFalse(view.isScrollEnabled)
        XCTAssertEqual(view.selectedIndexPaths, [ip(1, 0)])
        XCTAssertNotNil(view.configurationDataSource, "The view keeps the data source it built")
        XCTAssertTrue(view.menuDataSource === view.configurationDataSource)
        // Lottie, GIF, Rive, SVGA, then an image-only item and a string item, the last two items.
        let count = view.menuDataSource?.menuNumberOfItems(inSection: 0) ?? 0
        XCTAssertEqual(count, 6)
        XCTAssertEqual(view.menuDataSource?.menuTitleForItem(at: ip(count - 1, 0)), "Text only", "A string item is a title")
        XCTAssertNotNil(view.menuDataSource?.menuImageForItem?(at: ip(count - 2, 0)), "system: images are SF Symbols")
        XCTAssertEqual(view.menuDataSource?.menuAnimationURLForItem?(at: ip(3, 0))?.pathExtension, "svga")
        XCTAssertEqual(view.style.imageSize, CGSize(width: 20, height: 20))
        XCTAssertEqual(view.style.normalAppearance.cornerRadius, 8)
        XCTAssertEqual(view.style.normalAppearance.iconColor, UIColor.systemIndigo)
    }

    func testConfigurationStringValuesAreConverted() {
        let normal: [String: Any] = [
            CYLTagAppearanceKey.textColor: "#FF0000",
            CYLTagAppearanceKey.borderColor: "systemBlue",
            CYLTagAppearanceKey.font: ["size": 15, "weight": "bold"] as [String: Any],
            CYLTagAppearanceKey.margin: "6",
        ]
        let style: [String: Any] = [
            CYLMenuStyleKey.imageInsets: "{1, 2, 3, 4}",
            CYLMenuStyleKey.titlePositionAdjustment: [2, -1],
            CYLMenuStyleKey.imageSize: ["width": 18, "height": 16],
            CYLMenuStyleKey.layoutCentered: "no",
            CYLMenuStyleKey.normal: normal,
        ]
        let sections: [[String: Any]] = [
            [CYLTagSectionKey.title: "A", CYLTagSectionKey.items: ["x", "y"]],
            [CYLTagSectionKey.title: "B", CYLTagSectionKey.items: [[CYLTagItemKey.title: "z", CYLTagItemKey.enabled: "false"]]],
        ]
        let view = CYLTagListView(configuration: [
            CYLTagListKey.selectionMode: "single",
            CYLTagListKey.foldStyle: "footerChevron",
            CYLTagListKey.defaultVisibleRows: "2",
            CYLTagListKey.showsSectionHeaders: "false",
            CYLTagListKey.selectedItems: ["1-0"],
            CYLTagListKey.style: style,
            CYLTagListKey.sections: sections,
        ])
        XCTAssertEqual(view.selectionMode, .single)
        XCTAssertEqual(view.foldStyle, .footerChevron)
        XCTAssertEqual(view.defaultVisibleRows, 2)
        XCTAssertFalse(view.showsSectionHeaders)
        XCTAssertEqual(view.selectedIndexPaths, [ip(0, 1)], "\"section-item\"")
        XCTAssertEqual(view.style.imageInsets, UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4))
        XCTAssertEqual(view.style.titlePositionAdjustment, UIOffset(horizontal: 2, vertical: -1))
        XCTAssertEqual(view.style.imageSize, CGSize(width: 18, height: 16))
        XCTAssertFalse(view.style.layoutCentered)
        let text = CYLColorComponents(view.style.normalAppearance.textColor)
        XCTAssertEqual(text.red, 1, accuracy: 0.01)
        XCTAssertEqual(text.green, 0, accuracy: 0.01)
        XCTAssertEqual(view.style.normalAppearance.borderColor, UIColor.systemBlue)
        XCTAssertEqual(view.style.normalAppearance.font.pointSize, 15, accuracy: 0.01)
        XCTAssertTrue(view.style.normalAppearance.font.fontDescriptor.symbolicTraits.contains(.traitBold))
        XCTAssertEqual(view.style.normalAppearance.margin, 6)
        XCTAssertEqual(view.menuDataSource?.menuItemIsEnabled?(at: ip(0, 1)), false)
    }

    func testConfigurationFileCreatesAnimatedTags() throws {
        let file = CYLTagConfigurationDemoViewController.configurationFilePath()
        let configuration = try CYLTagListView.configuration(contentsOfFile: file)
        XCTAssertFalse(configuration.isEmpty)
        let view = try CYLTagListView(configurationFile: file)
        XCTAssertEqual(view.selectionMode, .single)
        XCTAssertFalse(view.allowsEmptySelection)
        XCTAssertEqual(view.foldStyle, .footerChevron)
        XCTAssertEqual(view.selectedIndexPaths, [ip(0, 0)])
        XCTAssertEqual(view.style.normalAppearance.cornerRadius, 1000, "A capsule")
        for item in 0..<4 {
            let url = view.menuDataSource?.menuAnimationURLForItem?(at: ip(item, 0))
            XCTAssertNotNil(url, "item \(item)")
            XCTAssertTrue(FileManager.default.fileExists(atPath: url?.path ?? ""), "\(String(describing: url)) resolves next to the file or in the app")
        }
        XCTAssertThrowsError(try CYLTagListView(configurationFile: "missing.json")) { error in
            let error = error as NSError
            XCTAssertEqual(error.domain, CYLMenuConfigurationError.errorDomain)
            XCTAssertEqual(error.code, CYLMenuConfigurationError.Code.fileNotFound.rawValue)
        }
    }

    // MARK: - Tag background style (Liquid Glass) and minimumTagSize

    func testBackgroundStyleAndMinimumTagSizeAreReadFromTheStyleConfiguration() {
        func style(_ values: [String: Any]) -> CYLMenuStyle {
            CYLTagListView(configuration: [CYLTagListKey.style: values,
                                           CYLTagListKey.sections: [[CYLTagSectionKey.items: ["x"]]]]).style
        }
        XCTAssertEqual(style([:]).backgroundStyle, .flat, "flat is the default")
        XCTAssertEqual(style([CYLMenuStyleKey.backgroundStyle: "liquidGlass"]).backgroundStyle, .liquidGlass)
        XCTAssertEqual(style([CYLMenuStyleKey.backgroundStyle: "LiquidGlass"]).backgroundStyle, .liquidGlass, "case-insensitive")
        XCTAssertEqual(style([CYLMenuStyleKey.backgroundStyle: 1]).backgroundStyle, .liquidGlass, "the raw value")
        XCTAssertEqual(style([CYLMenuStyleKey.backgroundStyle: "frosted"]).backgroundStyle, .flat, "unknown is flat")
        XCTAssertEqual(style([CYLMenuStyleKey.minimumTagSize: "{69, 29}"]).minimumTagSize, CGSize(width: 69, height: 29))
        XCTAssertEqual(style([CYLMenuStyleKey.minimumTagSize: ["width": 69, "height": 29]]).minimumTagSize,
                       CGSize(width: 69, height: 29))
        XCTAssertEqual(style([:]).minimumTagSize, .zero)

        let source = CYLMenuStyle()
        source.backgroundStyle = .liquidGlass
        source.minimumTagSize = CGSize(width: 69, height: 29)
        let copy = source.copy() as? CYLMenuStyle
        XCTAssertEqual(copy?.backgroundStyle, .liquidGlass, "a copied style keeps the background style")
        XCTAssertEqual(copy?.minimumTagSize, CGSize(width: 69, height: 29))
    }

    func testLiquidGlassFallsBackToFlatWhereTheSystemDrawsNone() {
        CYLAnimatedItemView.liquidGlassActiveOverride = false
        defer { CYLAnimatedItemView.liquidGlassActiveOverride = nil }
        let style = CYLMenuStyle()
        style.backgroundStyle = .liquidGlass
        style.normalAppearance.backgroundColor = .systemOrange
        XCTAssertEqual(style.backgroundStyle, .liquidGlass, "the parameter is kept")
        XCTAssertEqual(style.resolvedBackgroundStyle, .flat, "but ignored where glass is unavailable")
        let button = CYLMenuFixtures.tagButton(title: "Tag", image: nil, style: style)
        XCTAssertNil(button.liquidGlassView)
        XCTAssertNotNil(button.layer.backgroundColor, "the flat background color is drawn")
    }

    func testTheDefaultRadiusIsTheCapsuleConstantInEveryStyleAndASetRadiusCustomizesIt() throws {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        defer { CYLAnimatedItemView.liquidGlassActiveOverride = nil }
        XCTAssertEqual(CYLMenuStyle().normalAppearance.cornerRadius, CYLAnimatedItemCornerRadiusCapsule)
        for background in [CYLTagBackgroundStyle.liquidGlass, .flat] {
            let style = CYLMenuStyle()
            style.backgroundStyle = background
            let button = CYLMenuFixtures.tagButton(title: "Tag", image: nil, style: style, size: CGSize(width: 100, height: 34))
            button.layoutIfNeeded()
            XCTAssertEqual(button.layer.cornerRadius, 17, "\(background): the default is a capsule")
            style.normalAppearance.cornerRadius = 6
            button.style = style
            button.layoutIfNeeded()
            XCTAssertEqual(button.layer.cornerRadius, 6, "a set radius customizes it")
            style.normalAppearance.cornerRadius = 0
            button.style = style
            button.layoutIfNeeded()
            XCTAssertEqual(button.layer.cornerRadius, 0, "0 is square")
        }
    }

    func testLiquidGlassBackgroundIsDrawnWhereTheSystemDrawsIt() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("UIGlassEffect needs iOS 26")
        }
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        defer { CYLAnimatedItemView.liquidGlassActiveOverride = nil }
        let style = CYLMenuStyle()
        style.backgroundStyle = .liquidGlass
        style.normalAppearance.backgroundColor = .systemOrange
        style.normalAppearance.cornerRadius = 12
        XCTAssertEqual(style.resolvedBackgroundStyle, .liquidGlass)
        let button = CYLMenuFixtures.tagButton(title: "Tag", image: nil, style: style)
        let glass = try XCTUnwrap(button.liquidGlassView as? UIVisualEffectView, "a glass view behind the content")
        XCTAssertTrue(glass.effect is UIGlassEffect)
        var tintAlpha: CGFloat = -1
        (glass.effect as? UIGlassEffect)?.tintColor?.getRed(nil, green: nil, blue: nil, alpha: &tintAlpha)
        XCTAssertEqual(tintAlpha, 0.75, accuracy: 0.01, "the state's backgroundColor tints it, translucent (alpha x 0.75)")
        XCTAssertNil(button.layer.backgroundColor, "the flat color is not drawn under glass")
        XCTAssertEqual(glass.frame, button.bounds)
        XCTAssertEqual(glass.layer.cornerRadius, button.layer.cornerRadius, "clipped to the resolved radius")
        XCTAssertFalse(glass.isUserInteractionEnabled)

        // Back to flat: the glass goes, the color returns.
        style.backgroundStyle = .flat
        button.style = style
        XCTAssertNil(button.liquidGlassView)
        XCTAssertNotNil(button.layer.backgroundColor)
    }

    func testMinimumTagSizeGrowsATagThatIsSmaller() {
        let style = CYLMenuStyle()
        let plainWidth = CYLTagButton.width(forTitle: "A", iconSize: .zero, style: style, traitCollection: nil)
        let plainHeight = CYLTagButton.height(forTitle: "A", iconSize: .zero, style: style, traitCollection: nil)
        XCTAssertLessThan(plainWidth, 69)
        style.minimumTagSize = CGSize(width: 69, height: plainHeight + 10)
        XCTAssertEqual(CYLTagButton.width(forTitle: "A", iconSize: .zero, style: style, traitCollection: nil), 69)
        XCTAssertEqual(CYLTagButton.height(forTitle: "A", iconSize: .zero, style: style, traitCollection: nil), plainHeight + 10)
        let longTitle = String(repeating: "wide ", count: 20)
        XCTAssertGreaterThan(CYLTagButton.width(forTitle: longTitle, iconSize: .zero, style: style, traitCollection: nil), 69,
                             "a larger tag is not shrunk")
    }
}
