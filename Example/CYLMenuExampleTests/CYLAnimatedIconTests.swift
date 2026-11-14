//
//  CYLAnimatedIconTests.swift
//  CYLMenuExampleTests
//
//  Animated icons through CYLTabBarController's animation engine: URL options, GIF / Lottie / PAG / Rive views, the
//  animation demo and its per-section styles.
//

import CryptoKit
import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLAnimatedIconTests: CYLMenuExampleTestCase {

    func testAnimationOptionsAreEncodedAsCYLTabBarControllerDoes() {
        let file = URL(fileURLWithPath: "/tmp/icons.riv")
        XCTAssertEqual(file.cylAddingAnimationOptions([:]), file)
        let url = file.cylAddingAnimationOptions(["stateMachine": "State Machine 1", "artboard": "A&B", "duration": 2])
        XCTAssertEqual(url.path, file.path)
        XCTAssertEqual(url.fragment, "artboard=A%26B&duration=2&stateMachine=State%20Machine%201", "Sorted, percent-encoded")

        let items: [[String: Any]] = [
            [CYLTagItemKey.title: "a", CYLTagItemKey.animation: "CYLMenuExample.bundle/Animations/Rive/icons.riv",
             CYLTagItemKey.animationOptions: ["artboard": "CHAT", "input": "active"]],
            [CYLTagItemKey.title: "b", CYLTagItemKey.animation: "CYLMenuExample.bundle/Animations/Rive/icons.riv#artboard=USER"],
        ]
        let sections: [[String: Any]] = [[CYLTagSectionKey.items: items]]
        let view = CYLTagListView(configuration: [CYLTagListKey.sections: sections])
        let first = view.menuDataSource?.menuAnimationURLForItem?(at: ip(0, 0))
        let second = view.menuDataSource?.menuAnimationURLForItem?(at: ip(1, 0))
        XCTAssertEqual(first?.fragment, "artboard=CHAT&input=active")
        XCTAssertEqual(second?.fragment, "artboard=USER", "A fragment in a file name is kept")
        XCTAssertTrue(FileManager.default.fileExists(atPath: first?.path ?? ""))
        XCTAssertTrue(FileManager.default.fileExists(atPath: second?.path ?? ""))
        XCTAssertNotNil(UIImage(named: "img_tab_home_0"), "Lottie image assets are found by name, as in CYLTabBarController's Example")
    }

    func testAnimatedIconsUseCYLTabBarControllerAnimationEngine() {
        XCTAssertTrue(CYLTagButton.isAnimationEngineAvailable, "CYLTabBarController/CYLTabBarItemAnimation is linked")
        let resources = Bundle.main.resourceURL!
        let files = [
            "GIF": "CYLMenuExample.bundle/Animations/GIF/tab_star.gif",
            "Lottie": "CYLMenuExample.bundle/Animations/Lottie/tab_home_animate.json",
            "PAG": "pag-ios/0.pag",
            "Rive": "CYLMenuExample.bundle/Animations/Rive/check.riv",
        ]
        for (library, path) in files {
            let url = resources.appendingPathComponent(path)
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), "\(library) file in the app")
            let button = CYLMenuFixtures.tagButton(title: library, image: UIImage(systemName: "star"), style: CYLMenuStyle())
            button.animationURL = url
            button.layoutIfNeeded()
            XCTAssertNotNil(button.animationView, "\(library) view from CYLTabBarItemAnimationFactory")
            XCTAssertNotNil(button.animationPlayer, "\(library) player")
            XCTAssertTrue(button.imageView.isHidden, "\(library) takes the icon slot")
            let animationFrame = button.animationView?.frame ?? .zero
            XCTAssertEqual(animationFrame.size, button.style.imageSize, "\(library) \(NSCoder.string(for: animationFrame))")
            XCTAssertEqual(button.titleLabel.frame.minX - animationFrame.maxX, button.style.imageTitleSpacing, accuracy: 0.5)
            button.isSelected = true
            button.playAnimation()
            button.isSelected = false
        }
        let missing = CYLMenuFixtures.tagButton(title: "x", image: UIImage(systemName: "star"), style: CYLMenuStyle())
        missing.animationURL = resources.appendingPathComponent("missing.json")
        XCTAssertNil(missing.animationView, "Falls back to the image")
        XCTAssertFalse(missing.imageView.isHidden)
    }

    func testAnimationDemoPlaysEveryLibraryCopiedFromCYLTabBarController() {
        for name in ["home_normal", "home_highlight", "fishpond_normal", "message_highlight", "account_normal", "post_normal",
                     "gray_tabbar_home_animation_lottie_placeholder"] {
            XCTAssertNotNil(UIImage(named: name), "\(name) from CYLTabBarController's Example images")
        }
        let demo = CYLTagAnimationDemoViewController()
        showInNavigation(demo)
        demo.view.layoutIfNeeded()
        let list: CYLTagListView = demo.tagListView
        let tags = list.probe
        let sections = CYLTagAnimationDemoViewController.sectionIdentifiers()
        XCTAssertEqual(tags.collectionView.numberOfSections, sections.count)
        XCTAssertEqual(list.selectedIndexPaths.count, sections.count, "The first tag of every section is selected")
        captureScreen(named: "test-animation-demo")
        for section in 0..<sections.count {
            let indexPath = ip(0, section)
            tags.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            tags.layOut()
            let button = tags.tagButton(at: indexPath)
            XCTAssertNotNil(button, sections[section])
            if sections[section] == "images" {
                XCTAssertNil(button?.animationView)
                XCTAssertEqual(button?.imageView.image, UIImage(named: "home_highlight"), "The selected image")
            } else {
                XCTAssertNotNil(button?.animationView, "\(sections[section]) animated by CYLTabBarController's engine")
            }
        }
        demo.playSelectedAnimations()
        demo.changeSpeed()
        XCTAssertEqual(list.style.animationSpeed, 2, accuracy: 0.01)
        XCTAssertEqual(demo.navigationItem.leftBarButtonItem?.title, "2x")
        tags.tap(item: 1, section: 4)
        XCTAssertTrue(list.selectedIndexPaths.contains(ip(1, 4)))
        XCTAssertFalse(list.selectedIndexPaths.contains(ip(0, 4)), "One selected tag per section")
    }

    func testSectionStyleRestingFrameAndScrollingInTheAnimationDemo() {
        let demo = CYLTagAnimationDemoViewController()
        showInNavigation(demo)
        demo.view.layoutIfNeeded()
        let list: CYLTagListView = demo.tagListView
        let tags = list.probe
        let source = list.menuDataSource
        let sections = CYLTagAnimationDemoViewController.sectionIdentifiers()
        let riveIcons = sections.firstIndex(of: "rive-icons") ?? 0
        let pag = sections.firstIndex(of: "pag") ?? 0

        // icons.riv's white artboards on dark tags: the section's own style, over the list's.
        let dark = source?.menuStyle?(forSection: riveIcons)
        XCTAssertNotNil(dark)
        XCTAssertTrue(source?.menuStyle?(forSection: riveIcons) === dark, "The same object until the list's style changes")
        XCTAssertNil(source?.menuStyle?(forSection: pag), "Other sections use the list's style")
        XCTAssertEqual(dark?.itemHeight, list.style.itemHeight)
        list.scroll(toSection: riveIcons, animated: false)
        tags.layOut()
        let chat = ip(0, riveIcons), search = ip(1, riveIcons)
        let selected = tags.tagButton(at: chat)
        let normal = tags.tagButton(at: search)
        XCTAssertNotNil(normal?.animationView, "icons.riv artboard")
        XCTAssertTrue(normal?.layer.backgroundColor == dark?.normalAppearance.backgroundColor.cgColor, "Dark tag")
        XCTAssertTrue(selected?.layer.backgroundColor == dark?.selectedAppearance.backgroundColor.cgColor)
        XCTAssertTrue(CYLColorComponents(normal?.titleLabel.textColor).isWhite,
                      "White titles: \(String(describing: normal?.titleLabel.textColor))")
        XCTAssertTrue((tags.cell(at: chat)?.frame ?? .zero).intersects(tags.collectionView.bounds), "Scrolled to the section")
        captureScreen(named: "test-animation-dark-section")

        // 1.pag rests on its last frame; the others on their first.
        let restingItem = (source?.menuNumberOfItems(inSection: pag) ?? 0) - 1
        XCTAssertEqual(source?.menuAnimationRestingProgressForItem?(at: ip(restingItem, pag)), NSNumber(value: 1))
        XCTAssertNil(source?.menuAnimationRestingProgressForItem?(at: ip(0, pag)))
        list.scroll(toSection: pag, animated: false)
        tags.layOut()
        let resting = tags.tagButton(at: ip(restingItem, pag))
        XCTAssertEqual(resting?.animationRestingProgress ?? 0, 1, accuracy: 0.001)
        XCTAssertFalse(resting?.isSelected ?? true)
        let progress = ((resting?.animationPlayer as AnyObject?)?.value(forKey: "progress") as? NSNumber)?.doubleValue ?? 0
        XCTAssertEqual(progress, 1, accuracy: 0.01, "Shows its last frame")
        // truck.riv (rive-app/rive-ios) replaced confetti.riv, which draws nothing at rest.
        let rive = sections.firstIndex(of: "rive") ?? 0
        let truckItem = (source?.menuNumberOfItems(inSection: rive) ?? 0) - 1
        let truck = source?.menuAnimationURLForItem?(at: ip(truckItem, rive))
        XCTAssertEqual(truck?.lastPathComponent, "truck.riv")
        XCTAssertTrue(FileManager.default.fileExists(atPath: truck?.path ?? ""))
        list.scroll(toSection: rive, animated: false)
        tags.layOut()
        XCTAssertNotNil(tags.tagButton(at: ip(truckItem, rive))?.animationView, "truck.riv")
        for name in ["tab_home", "tab_health", "tab_moments", "tab_me"] {
            let path = (Bundle.main.resourcePath ?? "") + "/pag-ios/\(name).pag"
            XCTAssertTrue(FileManager.default.fileExists(atPath: path), "CYLTabBarController's PAG tab icon \(name)")
        }
    }

    /**
     * truck.riv ships with its red artboard background made transparent (alpha 0, one byte), as
     * CYLTableViewPlaceHolder's PR #22 did for CYLRefreshIcon.riv; see Animations/Rive/README.md.
     */
    func testTruckRiveDrawsNoBackgroundRectangle() throws {
        let bundle = try XCTUnwrap(Bundle.main.url(forResource: "CYLMenuExample", withExtension: "bundle"))
        let truck = bundle.appendingPathComponent("Animations/Rive/truck.riv")
        let data = try Data(contentsOf: truck)
        let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        XCTAssertEqual(digest, "c961c6c4853823ab058f7e114f2e3f3d6d7c9d68844a0e2e971daa2f1fa8b131", "The transparent version")
        // The artboard fill's color: property key 37 (0x25), then ARGB little-endian; the alpha byte is 0.
        XCTAssertEqual(Array(data[51...55]), [0x25, 0x60, 0x3a, 0xeb, 0x00])
    }

    /**
     * house.riv ships with its sky gradient and artboard fill made transparent (three alpha bytes), so its tag shows
     * the house without a square scene behind it; see Animations/Rive/README.md.
     */
    func testHouseRiveDrawsNoBackgroundSquare() throws {
        let bundle = try XCTUnwrap(Bundle.main.url(forResource: "CYLMenuExample", withExtension: "bundle"))
        let data = try Data(contentsOf: bundle.appendingPathComponent("Animations/Rive/house.riv"))
        let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        XCTAssertEqual(digest, "2e06b33ce5ff2d8863053b0dff1fcf2f62b537cc51e38c48e11a01b927e28c65", "The transparent version")
        for offset in [8770, 8780, 8795] {
            XCTAssertEqual(data[offset], 0, "alpha byte at \(offset)")
        }
    }
}
