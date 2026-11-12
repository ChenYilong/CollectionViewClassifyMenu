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

        // A tap on the cornerRadius row: 0 makes capsules.
        let cornerRow = IndexPath(row: actions[1].firstIndex(of: "cornerRadius") ?? 0, section: 1)
        demo.tableView.delegate?.tableView?(demo.tableView, didSelectRowAt: cornerRow)
        XCTAssertEqual(demo.tagListView.style.normalAppearance.cornerRadius, 0)
        XCTAssertEqual(firstTag()?.layer.cornerRadius ?? -1, (firstTag()?.bounds.height ?? 0) / 2, accuracy: 0.5)

        demo.performAction("iconColor.normal")
        XCTAssertEqual(firstTag()?.imageView.tintColor, demo.style.iconColor(for: .normal))
        captureScreen(named: "test-style-demo-capsule-icon-color")

        demo.performAction("content.iconOnly")
        XCTAssertEqual(firstTag()?.title?.count ?? 0, 0)
        XCTAssertEqual(firstTag()?.imageView.frame.midX ?? 0, (firstTag()?.bounds.width ?? 0) / 2, accuracy: 1, "layoutCentered")

        demo.performAction("reset")
        XCTAssertEqual(demo.content, .iconAndTitle)
        XCTAssertEqual(demo.tagListView.style.normalAppearance.cornerRadius, 3)
    }

    func testStyleDemoShowsAnimatedIconsAndOpensTheConfigurationDemo() {
        let demo = CYLTagStyleDemoViewController()
        let navigation = showInNavigation(demo)
        let tags = demo.tagListView.probe
        for library in ["lottie", "gif", "pag", "rive"] {
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
}
