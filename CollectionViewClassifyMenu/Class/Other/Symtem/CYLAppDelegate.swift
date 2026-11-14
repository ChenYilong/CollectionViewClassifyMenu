//
//  CYLAppDelegate.swift
//  CollectionViewClassifyMenu
//
//  Created by https://github.com/ChenYilong on 15/3/17.
//  Copyright (c)  http://weibo.com/luohanchenyilong/ . All rights reserved.
//

import UIKit
import CYLTabBarController

@main
@objc(CYLAppDelegate)
final class CYLAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tabBarController: CYLTabBarController?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // An opaque tint-colored bar with white titles (barTintColor alone is ignored by the bar appearances of
        // iOS 15 and later, which left white titles on a white bar).
        let bar = UINavigationBarAppearance()
        bar.configureWithOpaqueBackground()
        bar.backgroundColor = UIColor(red: 42 / 255.0, green: 185 / 255.0, blue: 160 / 255.0, alpha: 1)
        bar.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 18), .foregroundColor: UIColor.white]
        let buttons = UIBarButtonItemAppearance()
        buttons.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        bar.buttonAppearance = buttons
        bar.doneButtonAppearance = buttons
        let appearance = UINavigationBar.appearance()
        appearance.tintColor = .white
        appearance.standardAppearance = bar
        appearance.scrollEdgeAppearance = bar
        appearance.compactAppearance = bar
        initFilterSetting(restore: true)
        return true
    }

    /// The demo's tab bar, from the configuration file `tabbar.json` of CYLClassifyMenuDemo.bundle (one per language):
    /// the two features have a tab each, Classify (the single-choice classify menu, CYLMainViewController) and Filter
    /// (the multiple-choice filter, CYLFilterDemoViewController); the raised plus button's page is About.
    static func makeTabBarController() -> CYLTabBarController? {
        let pages: [String: () -> UIViewController] = [
            "classify": { CYLMainViewController() },
            "filter": { CYLFilterDemoViewController() },
            "about": { CYLDemoAboutViewController() },
        ]
        for (identifier, make) in pages {
            CYLTabBarPageRegistry.shared.register(factory: { _ in UINavigationController(rootViewController: make()) }, forPageIdentifier: identifier)
        }
        guard let path = CYLDemoLocalization.languageBundle?.path(forResource: "tabbar", ofType: "json") else {
            NSLog("[CYLClassifyMenuDemo] tabbar.json is missing from CYLClassifyMenuDemo.bundle")
            return nil
        }
        do {
            return try CYLTabBarController(configurationFile: path)
        } catch {
            NSLog("[CYLClassifyMenuDemo] Cannot read %@: %@", path, error.localizedDescription)
            return nil
        }
    }

    /// The demo's window in `scene` (apps built with the iOS 27 SDK must use the scene life cycle).
    func launch(in scene: UIWindowScene) -> UIWindow {
        let window = UIWindow(windowScene: scene)
        let tabBarController = Self.makeTabBarController()
        self.tabBarController = tabBarController
        window.rootViewController = tabBarController ?? UINavigationController(rootViewController: CYLMainViewController())
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        self.window = window
        if let screen = UserDefaults.standard.string(forKey: "CYLDemoScreen"), let tabBarController {
            Self.openScreen(screen, in: tabBarController)
        }
        return window
    }

    /// For screenshots (`-CYLDemoScreen <name>` at launch): "filter" selects the Filter tab, "filter-panel" also opens
    /// the filter, "about" opens the plus button's page.
    static func openScreen(_ screen: String, in tabs: CYLTabBarController) {
        let navigations = (tabs.viewControllers ?? []).compactMap { $0 as? UINavigationController }
        func select<T: UIViewController>(_ type: T.Type) -> T? {
            guard let index = navigations.firstIndex(where: { $0.viewControllers.first is T }) else { return nil }
            tabs.selectedIndex = (tabs.viewControllers ?? []).firstIndex(of: navigations[index]) ?? 0
            return navigations[index].viewControllers.first as? T
        }
        switch screen {
        case "filter":
            _ = select(CYLFilterDemoViewController.self)
        case "filter-panel":
            let filter = select(CYLFilterDemoViewController.self)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { filter?.leftBarButtonClicked(nil) }
        case "about":
            _ = select(CYLDemoAboutViewController.self)
        default:
            break
        }
    }

    /// Forgets the stored filter selection unless `restore`.
    func initFilterSetting(restore: Bool) {
        if !restore {
            UserDefaults.standard.removeObject(forKey: CYLFilterDemoViewController.filterSelectionKey)
        }
    }
}

@objc(CYLSceneDelegate)
final class CYLSceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene, let app = UIApplication.shared.delegate as? CYLAppDelegate else { return }
        window = app.launch(in: scene)
    }
}
