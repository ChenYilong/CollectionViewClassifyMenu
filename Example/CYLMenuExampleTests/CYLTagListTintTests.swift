//
//  CYLTagListTintTests.swift
//  CYLMenuExampleTests
//
//  CYLTagListView: the tint of the built-in views (header title, section icon, fold and More controls), legible on what is behind
//  them: black or white by the background's luminance, the system mode over a transparent list (docs/tag-section-style.md).
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLTagListTintTests: CYLMenuExampleTestCase {

    private func luma(_ color: UIColor?, _ style: UIUserInterfaceStyle) -> CGFloat {
        let components = CYLColorComponents(color?.resolvedColor(with: UITraitCollection(userInterfaceStyle: style)))
        return 0.299 * components.red + 0.587 * components.green + 0.114 * components.blue
    }

    private func resolved(_ color: UIColor?, _ style: UIUserInterfaceStyle) -> UIColor? {
        color?.resolvedColor(with: UITraitCollection(userInterfaceStyle: style))
    }

    func testALightBackgroundGetsADarkTintInBothModes() {
        let style = CYLMenuStyle()
        style.backgroundColor = UIColor(white: 0.97, alpha: 1)
        for mode in [UIUserInterfaceStyle.light, .dark] {
            XCTAssertLessThan(luma(style.resolvedHeaderTextColor, mode), CYLTintContrast.luminanceThreshold, "\(mode.rawValue)")
            XCTAssertLessThan(luma(style.resolvedFoldControlColor(inHeader: true), mode), CYLTintContrast.luminanceThreshold)
            XCTAssertLessThan(luma(style.resolvedMoreButtonColor, mode), CYLTintContrast.luminanceThreshold)
        }
    }

    func testADarkBackgroundGetsALightTintInBothModes() {
        let style = CYLMenuStyle()
        style.backgroundColor = UIColor(white: 0.1, alpha: 1)
        for mode in [UIUserInterfaceStyle.light, .dark] {
            XCTAssertGreaterThan(luma(style.resolvedHeaderTextColor, mode), CYLTintContrast.luminanceThreshold, "\(mode.rawValue)")
            XCTAssertGreaterThan(luma(style.resolvedFoldControlColor(inHeader: false), mode), CYLTintContrast.luminanceThreshold)
        }
    }

    func testTheGroupedBackgroundDecidesWhenTheAppSetNone() {
        let style = CYLMenuStyle()
        style.sectionStyle = .insetGrouped
        XCTAssertLessThan(luma(style.resolvedHeaderTextColor, .light), CYLTintContrast.luminanceThreshold, "#F2F2F7: dark tint")
        XCTAssertGreaterThan(luma(style.resolvedHeaderTextColor, .dark), CYLTintContrast.luminanceThreshold, "black: light tint")
        // A plain list the app never configured paints white, so its tint stays dark even in dark mode.
        let plain = CYLMenuStyle()
        XCTAssertLessThan(luma(plain.resolvedHeaderTextColor, .dark), CYLTintContrast.luminanceThreshold)
    }

    func testATransparentListFollowsTheSystemMode() {
        let style = CYLMenuStyle()
        style.backgroundColor = .clear
        XCTAssertEqual(resolved(style.resolvedHeaderTextColor, .light), resolved(UIColor.label, .light))
        XCTAssertEqual(resolved(style.resolvedHeaderTextColor, .dark), resolved(UIColor.label, .dark))
        XCTAssertNotEqual(resolved(style.resolvedHeaderTextColor, .light), resolved(style.resolvedHeaderTextColor, .dark))
    }

    func testASetTintWinsAndASetIndividualColorWinsOverTheTint() {
        let style = CYLMenuStyle()
        style.backgroundColor = .black
        style.tintColor = .systemPink
        for mode in [UIUserInterfaceStyle.light, .dark] {
            XCTAssertEqual(resolved(style.resolvedHeaderTextColor, mode), resolved(.systemPink, mode))
            XCTAssertEqual(resolved(style.resolvedFoldControlColor(inHeader: true), mode), resolved(.systemPink, mode))
            XCTAssertEqual(resolved(style.resolvedMoreButtonColor, mode), resolved(.systemPink, mode))
        }
        style.headerTextColor = .systemTeal
        style.foldControlColor = .systemOrange
        XCTAssertEqual(style.resolvedHeaderTextColor, .systemTeal)
        XCTAssertEqual(style.resolvedFoldControlColor(inHeader: true), .systemOrange)
        XCTAssertEqual(resolved(style.resolvedMoreButtonColor, .light), resolved(.systemPink, .light))
        let copy = style.copy() as! CYLMenuStyle
        XCTAssertEqual(copy.resolvedHeaderTextColor, .systemTeal)
        XCTAssertEqual(copy.tintColor, .systemPink)
    }

    func testTheBandColorIsWhatTheHeaderIsDrawnOn() {
        let style = CYLMenuStyle()
        style.backgroundColor = .white
        style.headerBackgroundColor = UIColor(white: 0.1, alpha: 1)
        XCTAssertGreaterThan(luma(style.resolvedHeaderTextColor, .light), CYLTintContrast.luminanceThreshold, "on a dark band")
        XCTAssertGreaterThan(luma(style.resolvedFoldControlColor(inHeader: true), .light), CYLTintContrast.luminanceThreshold)
        XCTAssertLessThan(luma(style.resolvedFoldControlColor(inHeader: false), .light), CYLTintContrast.luminanceThreshold,
                          "A fold control below the card is on the list")
        style.headerBackgroundColor = UIColor(white: 0, alpha: 0.2)
        XCTAssertLessThan(luma(style.resolvedHeaderTextColor, .light), CYLTintContrast.luminanceThreshold,
                          "A translucent band shows the list")
    }

    func testAShownListDrawsItsTitleAndFoldControlWithTheTint() {
        let source = CYLMenuFixtures.source(itemCount: 30, sections: 1)
        let view = showTagList(source, width: 320)
        let style = CYLMenuStyle()
        style.backgroundColor = UIColor(white: 0.1, alpha: 1)
        view.style = style
        view.defaultVisibleRows = 1
        view.foldStyle = .headerButton
        view.overrideUserInterfaceStyle = .light
        view.layoutIfNeeded()
        let tags = view.probe
        tags.layOut()
        let title = tags.headerTitleLabel(inSection: 0)
        XCTAssertGreaterThan(luma(title?.textColor.resolvedColor(with: title?.traitCollection ?? .current), .light),
                             CYLTintContrast.luminanceThreshold, "A light title on a dark list in light mode")
        let fold = tags.headerFoldButton(inSection: 0)
        fold?.layoutIfNeeded()
        let foldTitle = CYLTagListProbe.subview("titleLabel", of: fold) as UILabel?
        XCTAssertGreaterThan(luma(foldTitle?.textColor.resolvedColor(with: foldTitle?.traitCollection ?? .current), .light),
                             CYLTintContrast.luminanceThreshold)
        withExtendedLifetime(source) {}
    }

    func testAShownTransparentListReResolvesWhenTheModeChanges() {
        let source = CYLMenuFixtures.source(itemCount: 4, sections: 1)
        let view = showTagList(source, width: 320)
        let style = CYLMenuStyle()
        style.backgroundColor = .clear
        view.style = style
        view.layoutIfNeeded()
        let title = view.probe.headerTitleLabel(inSection: 0)
        func shownLuma() -> CGFloat {
            let color = title?.textColor.resolvedColor(with: title?.traitCollection ?? .current)
            let components = CYLColorComponents(color)
            return 0.299 * components.red + 0.587 * components.green + 0.114 * components.blue
        }
        view.overrideUserInterfaceStyle = .light
        view.layoutIfNeeded()
        let light = shownLuma()
        view.overrideUserInterfaceStyle = .dark
        view.layoutIfNeeded()
        let dark = shownLuma()
        XCTAssertLessThan(light, CYLTintContrast.luminanceThreshold)
        XCTAssertGreaterThan(dark, CYLTintContrast.luminanceThreshold, "No reload: the dynamic tint follows the mode")
        withExtendedLifetime(source) {}
    }

    func testTheTintKeyParses() {
        let style = CYLMenuStyle(configuration: ["tintColor": "#FF0000"])
        XCTAssertEqual(CYLColorComponents(style.tintColor), CYLColorComponents(UIColor(red: 1, green: 0, blue: 0, alpha: 1)))
        style.applyConfiguration(["tintColor": NSNull()])
        XCTAssertNil(style.tintColor)
    }
}
