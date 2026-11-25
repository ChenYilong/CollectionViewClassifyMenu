//
//  CYLIconContrastTests.swift
//  CYLMenuExampleTests
//
//  CYLIconContrast: an explicit, static icon color too dark for dark Liquid Glass is lifted to 3:1 (hue and saturation kept);
//  everything else is unchanged (docs/tag-liquid-glass.md).
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLIconContrastTests: CYLMenuExampleTestCase {

    private let light = UITraitCollection(userInterfaceStyle: .light)
    private let dark = UITraitCollection(userInterfaceStyle: .dark)

    private func rgb(_ color: UIColor) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.resolvedColor(with: dark).getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    private func hue(_ color: UIColor) -> CGFloat {
        let c = rgb(color)
        return CYLIconContrast.hslFromRGB(red: c.r, green: c.g, blue: c.b).hue
    }

    private func contrast(_ color: UIColor, glassTint: UIColor? = nil, tintAlpha: CGFloat? = nil) -> CGFloat {
        let c = rgb(color)
        let luminance = CYLTintContrast.relativeLuminance(red: c.r, green: c.g, blue: c.b)
        return CYLIconContrast.contrastRatio(luminance, CYLIconContrast.glassReferenceLuminance(glassTint: glassTint, tintAlpha: tintAlpha))
    }

    /// The contrast against the bright-backdrop reference (the glass over the saturated blue).
    private func brightContrast(_ color: UIColor, glassTint: UIColor? = nil, tintAlpha: CGFloat? = nil) -> CGFloat {
        let c = rgb(color)
        let luminance = CYLTintContrast.relativeLuminance(red: c.r, green: c.g, blue: c.b)
        let reference = CYLIconContrast.glassReferenceLuminance(glassTint: glassTint, tintAlpha: tintAlpha,
                                                                over: CYLIconContrast.brightBackdropReference)
        return CYLIconContrast.contrastRatio(luminance, reference)
    }

    /// A system color resolved with the light traits, as a static color.
    private func staticLight(_ color: UIColor) -> UIColor { color.resolvedColor(with: light) }

    func testTheConstants() {
        XCTAssertEqual(CYLIconContrast.minimumContrastRatio, 3)
        XCTAssertEqual(CYLIconContrast.frostedGlassWhiteAlpha, 0.14)
        XCTAssertEqual(CYLIconContrast.defaultGlassTintShare, 0.75)
        // White at 0.14 over black is about #242424.
        let reference = CYLIconContrast.glassReferenceLuminance(glassTint: nil, tintAlpha: nil)
        XCTAssertEqual(reference, CYLTintContrast.relativeLuminance(red: 36 / 255, green: 36 / 255, blue: 36 / 255), accuracy: 0.002)
        XCTAssertEqual(CYLIconContrast.glassReferenceLuminance(glassTint: .clear, tintAlpha: nil), reference, "alpha 0 is the frosted default")
        // The bright reference: sRGB (0.29, 0.48, 0.88); the frosted glass is white at 0.14 over it.
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        CYLIconContrast.brightBackdropReference.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 0.29, accuracy: 0.0001)
        XCTAssertEqual(g, 0.48, accuracy: 0.0001)
        XCTAssertEqual(b, 0.88, accuracy: 0.0001)
        XCTAssertEqual(CYLIconContrast.lightnessStep, 0.005)
        let over = CYLTintContrast.relativeLuminance(red: 0.29 * 0.86 + 0.14, green: 0.48 * 0.86 + 0.14, blue: 0.88 * 0.86 + 0.14)
        XCTAssertEqual(CYLIconContrast.glassReferenceLuminance(glassTint: nil, tintAlpha: nil, over: CYLIconContrast.brightBackdropReference),
                       over, accuracy: 0.001)
        XCTAssertGreaterThan(over, reference, "the bright backdrop is the lighter reference")
    }

    func testStaticTealRedAndBlueReach3To1OnBothReferencesWithTheirHue() {
        for system in [UIColor.systemTeal, .systemRed, .systemBlue] {
            let icon = staticLight(system)
            let lifted = CYLIconContrast.liftedIconColor(icon, glassTint: nil, tintAlpha: nil)
            XCTAssertGreaterThanOrEqual(contrast(lifted), CYLIconContrast.minimumContrastRatio - 0.01, "dark reference: \(system)")
            XCTAssertGreaterThanOrEqual(brightContrast(lifted), CYLIconContrast.minimumContrastRatio - 0.01, "bright reference: \(system)")
            XCTAssertEqual(hue(lifted), hue(icon), accuracy: 0.02, "hue kept: \(system)")
            let lightness = CYLIconContrast.hslFromRGB(red: rgb(lifted).r, green: rgb(lifted).g, blue: rgb(lifted).b).lightness
            XCTAssertLessThanOrEqual(lightness, 1)
        }
    }

    func testADarkStaticColorIsLiftedAndNeverAboveWhite() {
        let darkTeal = UIColor(red: 0.0, green: 0.25, blue: 0.25, alpha: 1)
        let lifted = CYLIconContrast.liftedIconColor(darkTeal, glassTint: nil, tintAlpha: nil)
        XCTAssertLessThan(contrast(darkTeal), 3)
        XCTAssertGreaterThanOrEqual(contrast(lifted), 2.99)
        XCTAssertGreaterThanOrEqual(brightContrast(lifted), 2.99)
        XCTAssertEqual(hue(lifted), hue(darkTeal), accuracy: 0.01)
        // Black cannot keep a hue: it is lifted to a gray, capped at white.
        let black = CYLIconContrast.liftedIconColor(.black, glassTint: nil, tintAlpha: nil)
        XCTAssertGreaterThanOrEqual(contrast(black), 2.99)
        XCTAssertGreaterThanOrEqual(brightContrast(black), 2.99)
        XCTAssertLessThanOrEqual(rgb(black).r, 1)
    }

    func testAnExplicitGlassTintIsTheReferenceTimesTheAlphaRule() {
        let tint = UIColor(red: 0.2, green: 0.6, blue: 1, alpha: 0.8)
        let lifted = CYLIconContrast.liftedIconColor(staticLight(.systemBlue), glassTint: tint, tintAlpha: nil)
        XCTAssertGreaterThanOrEqual(contrast(lifted, glassTint: tint), 2.99)
        XCTAssertGreaterThanOrEqual(brightContrast(lifted, glassTint: tint), 2.99)
        // The selected tag tints at alpha 1: a brighter reference, so the lift is at least as strong.
        let selected = CYLIconContrast.liftedIconColor(staticLight(.systemBlue), glassTint: tint, tintAlpha: 1)
        XCTAssertGreaterThanOrEqual(contrast(selected, glassTint: tint, tintAlpha: 1), 2.99)
        XCTAssertGreaterThanOrEqual(brightContrast(selected, glassTint: tint, tintAlpha: 1), 2.99)
        let expected = CYLTintContrast.relativeLuminance(red: 0.2 * 0.6, green: 0.6 * 0.6, blue: 0.6)
        XCTAssertEqual(CYLIconContrast.glassReferenceLuminance(glassTint: tint, tintAlpha: nil), expected, accuracy: 0.001)
    }

    func testUnchangedCases() {
        // Already passing: returned as the same color.
        XCTAssertEqual(CYLIconContrast.liftedIconColor(.white, glassTint: nil, tintAlpha: nil), .white)
        // A near-white passes BOTH references.
        let bright = UIColor(red: 0.95, green: 0.97, blue: 1, alpha: 1)
        XCTAssertGreaterThanOrEqual(contrast(bright), 3)
        XCTAssertGreaterThanOrEqual(brightContrast(bright), 3)
        XCTAssertTrue(CYLIconContrast.liftedIconColor(bright, glassTint: nil, tintAlpha: nil) === bright)
        // Dynamic (light and dark differ): unchanged, the system picks the dark value.
        XCTAssertTrue(CYLIconContrast.liftedIconColor(.systemTeal, glassTint: nil, tintAlpha: nil) === UIColor.systemTeal)
        let custom = UIColor { $0.userInterfaceStyle == .dark ? UIColor(white: 0.05, alpha: 1) : .black }
        XCTAssertTrue(CYLIconContrast.liftedIconColor(custom, glassTint: nil, tintAlpha: nil) === custom)
        // A dynamic color that is the same in both modes counts as static.
        let same = UIColor { _ in UIColor(red: 0, green: 0.2, blue: 0.2, alpha: 1) }
        XCTAssertFalse(CYLIconContrast.liftedIconColor(same, glassTint: nil, tintAlpha: nil) === same)
    }

    func testWhiteIsTheCapWhenAnHueCannotReach3To1OnTheBrightReference() {
        // A very light glass tint over the bright blue leaves a reference no icon below white may beat; the lift never goes above white.
        let tint = UIColor(white: 1, alpha: 1)
        let lifted = CYLIconContrast.liftedIconColor(staticLight(.systemTeal), glassTint: tint, tintAlpha: 1)
        XCTAssertLessThanOrEqual(rgb(lifted).r, 1)
        XCTAssertLessThanOrEqual(rgb(lifted).g, 1)
        XCTAssertLessThanOrEqual(rgb(lifted).b, 1)
    }

    func testThePureFunctionGivesTheSameOutputForTheSameInput() {
        let icon = staticLight(.systemTeal)
        let first = CYLIconContrast.liftedIconColor(icon, glassTint: nil, tintAlpha: nil)
        let second = CYLIconContrast.liftedIconColor(icon, glassTint: nil, tintAlpha: nil)
        XCTAssertEqual(rgb(first).r, rgb(second).r)
        XCTAssertEqual(rgb(first).g, rgb(second).g)
        XCTAssertEqual(rgb(first).b, rgb(second).b)
        // Not affected by the current traits.
        UITraitCollection(userInterfaceStyle: .light).performAsCurrent {
            let again = CYLIconContrast.liftedIconColor(icon, glassTint: nil, tintAlpha: nil)
            XCTAssertEqual(rgb(again).r, rgb(first).r)
        }
    }

    // MARK: - CYLTagButton

    private var windows: [UIWindow] = []

    override func tearDown() {
        windows.forEach { $0.isHidden = true }
        windows.removeAll()
        super.tearDown()
    }

    private func button(glass: Bool, mode: UIUserInterfaceStyle, icon: UIColor) -> CYLTagButton {
        let style = CYLMenuStyle()
        style.backgroundStyle = glass ? .liquidGlass : .flat
        style.setIconColor(icon, for: .normal)
        let button = CYLTagButton(title: "A", image: UIImage(systemName: "list.bullet")?.withRenderingMode(.alwaysTemplate))
        // In a window of that mode: a detached view reports the light trait whatever its override says, so the dark rule would never run.
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        window.overrideUserInterfaceStyle = mode
        window.isHidden = false
        button.frame = CGRect(x: 0, y: 0, width: 120, height: 36)
        window.addSubview(button)
        windows.append(window)
        button.overrideUserInterfaceStyle = mode
        button.style = style
        button.layoutIfNeeded()
        return button
    }

    private func tint(of button: CYLTagButton, _ style: UIUserInterfaceStyle) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        button.imageView.tintColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: style)).getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    func testADarkGlassTagLiftsAStaticDarkTealIconAndAFlatOrLightTagDoesNot() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        defer { CYLAnimatedItemView.liquidGlassActiveOverride = nil }
        let darkTeal = UIColor(red: 0.0, green: 0.3, blue: 0.3, alpha: 1)
        let glass = button(glass: true, mode: .dark, icon: darkTeal)
        let lifted = tint(of: glass, .dark)
        XCTAssertGreaterThan(lifted.g, 0.3 + 0.05, "lifted")
        XCTAssertEqual(CYLIconContrast.hslFromRGB(red: lifted.r, green: lifted.g, blue: lifted.b).hue,
                       CYLIconContrast.hslFromRGB(red: 0, green: 0.3, blue: 0.3).hue, accuracy: 0.01)
        let flat = button(glass: false, mode: .dark, icon: darkTeal)
        XCTAssertEqual(tint(of: flat, .dark).g, 0.3, accuracy: 0.002, "flat: as set")
        let lightMode = button(glass: true, mode: .light, icon: darkTeal)
        XCTAssertEqual(tint(of: lightMode, .light).g, 0.3, accuracy: 0.002, "light mode: as set")
        // No explicit icon color: the built-in follows the text color, untouched.
        let style = CYLMenuStyle()
        style.backgroundStyle = .liquidGlass
        let builtIn = CYLTagButton(title: "A", image: UIImage(systemName: "list.bullet")?.withRenderingMode(.alwaysTemplate))
        builtIn.overrideUserInterfaceStyle = .dark
        builtIn.style = style
        XCTAssertNotNil(builtIn.imageView.tintColor)
    }
}
