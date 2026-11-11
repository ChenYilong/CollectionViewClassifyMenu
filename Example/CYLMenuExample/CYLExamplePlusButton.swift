//
//  CYLExamplePlusButton.swift
//  CYLMenuExample
//
//  The root tab bar's plus button (CYLTabBarController's CYLPlusButton). It sits in the middle of the
//  bottom tab bar and opens the scenario list of the filter demos (CYLQueryScenariosViewController),
//  selected like the other tabs. It has its own tab bar context, so the category tab bar nested in
//  scenario 2 has no plus button.
//

import UIKit
import CYLTabBarController

/// The context of the Example's root tab bar controller and of its plus button.
let CYLExampleRootTabBarContext = "CYLMenuExampleRoot"

final class CYLExamplePlusButton: CYLPlusButton, CYLPlusButtonSubclassing {

    static func plusButton() -> Any {
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold)
        let image = UIImage(systemName: "plus.circle.fill", withConfiguration: configuration)?
            .withTintColor(.systemOrange, renderingMode: .alwaysOriginal)
        // An image only: with Liquid Glass, CYLTabBarController centers a plus button without a title in its own
        // tab (a titled one is laid out beside the other tabs). The title stays for VoiceOver.
        let button = CYLExamplePlusButton()
        button.setImage(image, for: .normal)
        button.setImage(image, for: .highlighted)
        button.sizeToFit()
        button.accessibilityLabel = CYLExampleLocalizedString("查询筛选")
        button.accessibilityHint = CYLExampleLocalizedString("按场景分组的筛选演示")
        return button
    }

    static func indexOfPlusButtonInTabBar() -> UInt {
        // In the middle of the four tabs.
        2
    }

    /// The plus button's tab: a navigation controller with the scenario list.
    static func plusNavigationController() -> UINavigationController {
        UINavigationController(rootViewController: CYLQueryScenariosViewController())
    }

    static func plusChildViewController() -> UIViewController {
        plusNavigationController()
    }

    static func shouldSelectPlusChildViewController() -> Bool {
        true
    }

    static func tabBarContext() -> String {
        CYLExampleRootTabBarContext
    }

    static func tabBarItemIdentifier() -> String {
        "plus"
    }
}
