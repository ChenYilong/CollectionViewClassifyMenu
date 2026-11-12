//
//  CYLTabBarInspecting.swift
//  CYLMenuExampleTests
//
//  Reads the Example's tab bars (CYLTabBarController) in tests.
//

import UIKit
import ObjectiveC
import CYLTabBarController
@testable import CYLMenuExample

/**
 * A tab bar controller whose tabs the tests read by title and by root view controller.
 */
protocol CYLTabBarInspecting {
    var inspectedTabBarController: UITabBarController { get }
}

extension CYLTabBarInspecting {

    /**
     * The tab bar items' titles, in order.
     */
    var tabTitles: [String] {
        (inspectedTabBarController.tabBar.items ?? []).map { $0.title ?? "" }
    }

    /**
     * The tabs' full titles, without the plus button's tab.
     *
     * CYLTabBarController cuts long titles next to the plus button with "…" (so that the plus button keeps its slot)
     * and keeps the full title as the accessibility label.
     */
    var fullTabTitles: [String] {
        (inspectedTabBarController.viewControllers ?? [])
            .filter { !(($0 as? UINavigationController)?.viewControllers.first is CYLQueryScenariosViewController) }
            .map { $0.tabBarItem.accessibilityLabel ?? $0.tabBarItem.title ?? "" }
    }

    /**
     * The navigation controller of the tab whose root is a `rootClass`.
     */
    func navigationController(rootedIn rootClass: AnyClass) -> UINavigationController? {
        (inspectedTabBarController.viewControllers ?? [])
            .compactMap { $0 as? UINavigationController }
            .first { $0.viewControllers.first?.isKind(of: rootClass) ?? false }
    }
}

extension UITabBarController: CYLTabBarInspecting {
    var inspectedTabBarController: UITabBarController {
        self
    }
}

/**
 * CYLTabBarController's plus button class factories, called by selector so that the tests do not depend on how
 * Swift imports `+plusButtonForTabBarContext:` and `+plusChildViewControllerForTabBarContext:`.
 */
enum CYLPlusButtonFactory {

    static func plusButton(forContext context: String) -> CYLPlusButton? {
        callClassMethod("plusButtonForTabBarContext:", context: context) as? CYLPlusButton
    }

    static func plusChildViewController(forContext context: String) -> AnyObject? {
        callClassMethod("plusChildViewControllerForTabBarContext:", context: context)
    }

    private static func callClassMethod(_ name: String, context: String) -> AnyObject? {
        let plusClass: AnyClass = CYLPlusButton.self
        let selector = NSSelectorFromString(name)
        guard let implementation = class_getMethodImplementation(object_getClass(plusClass), selector) else { return nil }
        typealias ClassMethod = @convention(c) (AnyObject, Selector, NSString?) -> AnyObject?
        let method = unsafeBitCast(implementation, to: ClassMethod.self)
        return method(plusClass as AnyObject, selector, context as NSString)
    }
}
