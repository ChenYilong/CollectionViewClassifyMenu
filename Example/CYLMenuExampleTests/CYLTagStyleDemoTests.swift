//
//  CYLTagStyleDemoTests.swift
//  CYLMenuExampleTests
//
//  The 样式 tab (CYLTagStyleDemoViewController): rows that restyle the tags live, animated icons, the configuration demo.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLTagStyleDemoTests: CYLMenuExampleTestCase {

    func testStyleDemoRowsRestyleTheTagsLive() {
        let demo = CYLTagStyleDemoViewController()
        showInNavigation(demo)
        demo.view.layoutIfNeeded()
        let actions = demo.actionIdentifiers()
        XCTAssertEqual(demo.tableView.numberOfSections, actions.count)
        XCTAssertEqual(demo.tableView.numberOfRows(inSection: 0), actions[0].count)
        let tags = demo.tagListView.probe
        func firstTag() -> CYLTagButton? {
            tags.layOut()
            return tags.tagButton(at: ip(1, 0))
        }
        XCTAssertNotNil(firstTag()?.imageView.image)
        XCTAssertGreaterThan(firstTag()?.title?.count ?? 0, 0)

        // A tap on the cornerRadius row: 1000 makes capsules (0 is square).
        let cornerSection = actions.firstIndex { $0.contains("cornerRadius") } ?? 0
        let cornerRow = IndexPath(row: actions[cornerSection].firstIndex(of: "cornerRadius") ?? 0, section: cornerSection)
        demo.tableView.delegate?.tableView?(demo.tableView, didSelectRowAt: cornerRow)
        XCTAssertEqual(demo.tagListView.style.normalAppearance.cornerRadius, 1000)
        XCTAssertEqual(firstTag()?.layer.cornerRadius ?? -1, (firstTag()?.bounds.height ?? 0) / 2, accuracy: 0.5)

        demo.performAction("iconColor.normal")
        XCTAssertEqual(firstTag()?.imageView.tintColor, demo.style.iconColor(for: .normal))
        captureScreen(named: "test-style-demo-capsule-icon-color")

        demo.performAction("content.iconOnly")
        XCTAssertEqual(firstTag()?.title?.count ?? 0, 0)
        XCTAssertEqual(firstTag()?.imageView.frame.midX ?? 0, (firstTag()?.bounds.width ?? 0) / 2, accuracy: 1, "layoutCentered")

        demo.performAction("reset")
        XCTAssertEqual(demo.content, .iconAndTitle)
        XCTAssertEqual(demo.tagListView.style.normalAppearance.cornerRadius, CYLTagCornerRadiusCapsule)
    }

    func testStyleDemoShowsAnimatedIconsAndOpensTheConfigurationDemo() {
        let demo = CYLTagStyleDemoViewController()
        let navigation = showInNavigation(demo)
        let tags = demo.tagListView.probe
        for library in ["lottie", "gif", "pag", "rive", "svga"] {
            demo.performAction("animation." + library)
            tags.layOut()
            XCTAssertEqual(demo.animationLibrary, library)
            XCTAssertNotNil(tags.tagButton(at: ip(0, 0))?.animationView, library)
        }
        demo.performAction("animation.off")
        tags.layOut()
        XCTAssertNil(tags.tagButton(at: ip(0, 0))?.animationView)

        demo.performAction("configuration")
        let configuration = navigation.topViewController as? CYLTagConfigurationDemoViewController
        XCTAssertNotNil(configuration)
        configuration?.loadViewIfNeeded()
        XCTAssertNotNil(configuration?.fileTagListView, "\(String(describing: configuration?.configurationError))")
        XCTAssertNotNil(configuration?.mapTagListView)
    }

    /// Flat tags next to Liquid Glass tags over a colorful background (the glass shows the colors through it).
    func testFlatAndLiquidGlassTagsSideBySide() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("Liquid Glass needs iOS 26")
        }
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        defer { CYLAnimatedItemView.liquidGlassActiveOverride = nil }
        let size = CGSize(width: 393, height: 360)
        let canvas = UIView(frame: CGRect(origin: .zero, size: size))
        let gradient = CAGradientLayer()
        gradient.frame = canvas.bounds
        gradient.colors = [UIColor.systemTeal.cgColor, UIColor.systemPurple.cgColor, UIColor.systemOrange.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        canvas.layer.addSublayer(gradient)
        show(canvas, size: size)

        var y: CGFloat = 24
        for (caption, background, radius) in [("flat", CYLTagBackgroundStyle.flat, CGFloat(1000)),
                                              ("liquidGlass", .liquidGlass, 1000),
                                              ("flat, radius 8", .flat, 8),
                                              ("liquidGlass, radius 8", .liquidGlass, 8)] {
            let label = UILabel(frame: CGRect(x: 16, y: y, width: 361, height: 18))
            label.text = "backgroundStyle: " + caption
            label.font = .preferredFont(forTextStyle: .caption1)
            label.textColor = .white
            canvas.addSubview(label)
            let style = CYLMenuStyle()
            style.backgroundStyle = background
            style.normalAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.25)
            style.selectedAppearance.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.55)
            style.normalAppearance.textColor = .white
            style.selectedAppearance.textColor = .white
            style.normalAppearance.borderWidth = 0
            style.selectedAppearance.borderWidth = 0
            style.normalAppearance.cornerRadius = radius
            style.selectedAppearance.cornerRadius = radius
            for (index, title) in ["Swift", "Kotlin", "ArkTS"].enumerated() {
                let tag = CYLMenuFixtures.tagButton(title: title, image: nil, style: style, size: CGSize(width: 100, height: 34))
                tag.frame.origin = CGPoint(x: 16 + CGFloat(index) * 112, y: y + 22)
                tag.isSelected = index == 1
                canvas.addSubview(tag)
                tag.layoutIfNeeded()
                XCTAssertEqual(tag.liquidGlassView != nil, background == .liquidGlass)
            }
            y += 82
        }
        captureScreen(named: "test-tag-background-flat-liquid-glass")
    }
}
