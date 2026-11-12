//
//  CYLWindowHosting.swift
//  Example-Shared/TestSupport
//
//  Shared by the test targets of Example/ and Example-Swift/: a test that shows its screens in a window of its own.
//

import UIKit

/**
 * Screen sizes the tests lay out in.
 */
enum CYLTestScreen {
    /**
     * iPhone SE / 8 points: the narrow screen most scenario tests use.
     */
    static let compact = CGSize(width: 375, height: 667)
    /**
     * iPhone 14 / 15 points: the tall screen of the search and tag editor screens.
     */
    static let tall = CGSize(width: 390, height: 844)
}

/**
 * A test that shows views in a key window it owns, and closes that window when it ends.
 *
 * Conformers only store the window; showing, embedding and closing come from the extension, so every test case lays
 * out its screens the same way.
 */
protocol CYLWindowHosting: AnyObject {
    /**
     * The window the test shows its screen in, or nil when nothing is shown.
     */
    var hostWindow: UIWindow? { get set }
}

extension CYLWindowHosting {

    /**
     * Shows `root` as the root view controller of a new key window and lays it out.
     */
    @discardableResult
    func show(_ root: UIViewController, size: CGSize = CYLTestScreen.compact) -> UIWindow {
        let window = Self.makeWindow()
        window.frame = CGRect(origin: .zero, size: size)
        window.rootViewController = root
        window.makeKeyAndVisible()
        hostWindow = window
        root.loadViewIfNeeded()
        root.view.layoutIfNeeded()
        return window
    }

    /**
     * Shows `controller` in a navigation controller, as the examples push their screens.
     */
    @discardableResult
    func showInNavigation(_ controller: UIViewController, size: CGSize = CYLTestScreen.compact) -> UINavigationController {
        let navigation = UINavigationController(rootViewController: controller)
        show(navigation, size: size)
        controller.loadViewIfNeeded()
        controller.view.layoutIfNeeded()
        return navigation
    }

    /**
     * Shows `view` alone, at `size`, in the root view of a new window.
     */
    func show(_ view: UIView, size: CGSize) {
        let controller = UIViewController()
        show(controller, size: size)
        view.frame = CGRect(origin: .zero, size: size)
        controller.view.addSubview(view)
    }

    /**
     * Hides and releases the window; call it from `tearDown()`.
     */
    func closeHostWindow() {
        hostWindow?.isHidden = true
        hostWindow = nil
    }

    /**
     * A window in the host app's scene: with the scene lifecycle, a window without a scene is never shown.
     */
    static func makeWindow() -> UIWindow {
        let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        return scene.map { UIWindow(windowScene: $0) } ?? UIWindow(frame: .zero)
    }

    /**
     * Lets the main run loop work for `seconds`, for UIKit work deferred to a later pass (appearance, pushes).
     */
    func runMainLoop(for seconds: TimeInterval) {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: seconds))
    }
}
