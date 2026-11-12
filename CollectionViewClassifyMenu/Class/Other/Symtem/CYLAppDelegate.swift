//
//  CYLAppDelegate.swift
//  CollectionViewClassifyMenu
//
//  Created by https://github.com/ChenYilong on 15/3/17.
//  Copyright (c)  http://weibo.com/luohanchenyilong/ . All rights reserved.
//

import UIKit

@main
@objc(CYLAppDelegate)
final class CYLAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let appearance = UINavigationBar.appearance()
        appearance.tintColor = .white
        appearance.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 18), .foregroundColor: UIColor.white]
        appearance.barTintColor = UIColor(red: 42 / 255.0, green: 185 / 255.0, blue: 160 / 255.0, alpha: 1)
        appearance.isTranslucent = false
        initFilterSetting(restore: true)
        return true
    }

    /// The demo's window in `scene` (apps built with the iOS 27 SDK must use the scene life cycle).
    func launch(in scene: UIWindowScene) -> UIWindow {
        let window = UIWindow(windowScene: scene)
        let classifyMenuViewController = CYLMainViewController()
        let navigationController = UINavigationController(rootViewController: classifyMenuViewController)
        self.navigationController = navigationController
        window.rootViewController = navigationController
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        self.window = window
        return window
    }

    /// Forgets the stored filter selection unless `restore`.
    func initFilterSetting(restore: Bool) {
        if !restore {
            UserDefaults.standard.removeObject(forKey: CYLMainViewController.filterSelectionKey)
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
