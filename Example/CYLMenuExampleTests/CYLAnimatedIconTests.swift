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
import CYLAnimatedItem
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

    /**
     * The five engines this example links (CYLAnimatedItem/LottieObjectiveC, PAG, Rive, SVGA, GIF) registered themselves
     * (CYLTabBarItemAnimatorRegistry), with no conflict, and the Animated icons screen lists each one as registered.
     */
    func testEveryLinkedEngineIsRegisteredAndListed() {
        let known = (CYLAnimationKnownTypes() as? [String]) ?? []
        XCTAssertEqual(known, ["Lottie", "PAG", "Rive", "SVGA", "GIF"])
        for type in known {
            XCTAssertTrue(CYLTabBarItemAnimatorRegistry.isAnimatorRegistered(withIdentifier: type), "\(type) engine registered")
        }
        XCTAssertTrue(CYLTabBarItemAnimatorRegistry.missingKnownIdentifiers().isEmpty)
        XCTAssertTrue(CYLTabBarItemAnimatorRegistry.conflictDescriptions().isEmpty,
                      CYLTabBarItemAnimatorRegistry.conflictDescriptions().joined(separator: "; "))
        XCTAssertFalse(CYLTabBarItemAnimatorRegistry.registrationReport().isEmpty)

        let demo = CYLTagAnimationDemoViewController()
        showInNavigation(demo)
        demo.view.layoutIfNeeded()
        let status = demo.statusLabel.text ?? ""
        for type in known {
            XCTAssertTrue(status.contains("✅ " + CYLExampleLocalizedString("%@ 已接入", type)), "\(type) in: \(status)")
        }
        XCTAssertFalse(status.contains("➖"), status)
        XCTAssertEqual(CYLTagAnimationDemoViewController.engineReportLines().count, known.count + 1, "A title and one line per engine")
        captureScreen(named: "test-animation-engine-report")
    }

    func testAnimatedIconsUseCYLTabBarControllerAnimationEngine() {
        XCTAssertTrue(CYLTagButton.isAnimationEngineAvailable, "The example adds the CYLAnimatedItem engine subspecs")
        let resources = Bundle.main.resourceURL!
        let files = [
            "GIF": "CYLMenuExample.bundle/Animations/GIF/tab_star.gif",
            "Lottie": "CYLMenuExample.bundle/Animations/Lottie/tab_home_animate.json",
            "PAG": "pag-ios/0.pag",
            "Rive": "CYLMenuExample.bundle/Animations/Rive/check.riv",
            "SVGA": "CYLMenuExample.bundle/Animations/SVGA/tab_home.svga",
        ]
        for (library, path) in files {
            let url = resources.appendingPathComponent(path)
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), "\(library) file in the app")
            let button = CYLMenuFixtures.tagButton(title: library, image: UIImage(systemName: "star"), style: CYLMenuStyle())
            button.animationURL = url
            button.layoutIfNeeded()
            XCTAssertNotNil(button.animationView, "\(library) view from CYLTabBarItemAnimationFactory")
            // `animationPlayer` is declared only when an engine is linked: read it by key.
            XCTAssertNotNil(button.value(forKey: "animationPlayer"), "\(library) player")
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
        // The playback controls: Play all, the speed slider and the loop switch act on the list at once.
        demo.playAllAnimations()
        demo.setSpeed(1.6)
        XCTAssertEqual(list.animationSpeed ?? 0, 1.5, accuracy: 0.01, "The slider moves in steps of 0.25")
        XCTAssertEqual(demo.speedLabel.text, "1.5×")
        XCTAssertEqual(demo.speedSlider.accessibilityLabel, CYLExampleLocalizedString("倍速"))
        XCTAssertEqual(demo.speedSlider.accessibilityValue, CYLExampleLocalizedString("%@ 倍", "1.5"))
        demo.setSpeed(100)
        XCTAssertEqual(list.animationSpeed ?? 0, 4, accuracy: 0.01, "Clamped to the slider's range")
        XCTAssertEqual(list.style.animationSpeed, 1, accuracy: 0.01, "The style is not replaced: the list is not reloaded")
        demo.setLoops(true)
        XCTAssertTrue(list.animationLoops)
        let visible = tags.collectionView.visibleCells.compactMap { ($0 as? CYLTagListCell)?.button }
        XCTAssertFalse(visible.isEmpty)
        XCTAssertTrue(visible.allSatisfy { $0.animationLoops && $0.animationSpeed == 4 }, "Applied to the tags on screen")
        demo.setLoops(false)
        XCTAssertTrue(visible.allSatisfy { !$0.animationLoops })
        XCTAssertEqual(demo.loopSwitch.accessibilityLabel, CYLExampleLocalizedString("循环播放"))
        XCTAssertNil(demo.navigationItem.leftBarButtonItem, "The speed button is replaced by the slider")
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
        XCTAssertEqual(CYLMenuFixtures.fillRGB(of: normal), CYLMenuFixtures.rgb(dark?.normalAppearance.backgroundColor), "Dark tag")
        XCTAssertEqual(CYLMenuFixtures.fillRGB(of: selected), CYLMenuFixtures.rgb(dark?.selectedAppearance.backgroundColor))
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
        let progress = ((resting?.value(forKey: "animationPlayer") as AnyObject?)?.value(forKey: "progress") as? NSNumber)?.doubleValue ?? 0
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
     * SVGA, one for one with Rive: a section of CYLTabBarController's SVGA tab icons and one on the same dark tags as
     * icons.riv; every file is in the app and gets a view from the SVGA animator.
     */
    func testSVGASectionsMirrorTheRiveSections() {
        let demo = CYLTagAnimationDemoViewController()
        showInNavigation(demo)
        demo.view.layoutIfNeeded()
        let list: CYLTagListView = demo.tagListView
        let tags = list.probe
        let source = list.menuDataSource
        let sections = CYLTagAnimationDemoViewController.sectionIdentifiers()
        guard let svga = sections.firstIndex(of: "svga"), let svgaDark = sections.firstIndex(of: "svga-dark"),
              let riveIcons = sections.firstIndex(of: "rive-icons") else {
            return XCTFail("SVGA sections in \(sections)")
        }
        XCTAssertEqual(svga, riveIcons + 1, "SVGA follows Rive")
        XCTAssertEqual(source?.numberOfSectionsInMenu(), sections.count)
        XCTAssertNil(source?.menuStyle?(forSection: svga), "The list's style")
        let dark = source?.menuStyle?(forSection: svgaDark)
        XCTAssertTrue(dark?.normalAppearance.backgroundColor.cgColor == source?.menuStyle?(forSection: riveIcons)?
            .normalAppearance.backgroundColor.cgColor, "The dark tags of icons.riv")
        for section in [svga, svgaDark] {
            let count = source?.menuNumberOfItems(inSection: section) ?? 0
            XCTAssertGreaterThan(count, 0)
            list.scroll(toSection: section, animated: false)
            tags.layOut()
            for item in 0..<count {
                let url = source?.menuAnimationURLForItem?(at: ip(item, section))
                XCTAssertEqual(url?.pathExtension, "svga")
                XCTAssertTrue(FileManager.default.fileExists(atPath: url?.path ?? ""), "\(String(describing: url))")
                XCTAssertNotNil(tags.tagButton(at: ip(item, section))?.animationView, "SVGA view for \(url?.lastPathComponent ?? "")")
            }
        }
        captureScreen(named: "test-animation-svga-sections")
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
