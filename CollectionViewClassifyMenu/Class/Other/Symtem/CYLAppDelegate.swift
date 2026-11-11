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

        let window = UIWindow(frame: UIScreen.main.bounds)
        let classifyMenuViewController = CYLMainViewController()
        let navigationController = UINavigationController(rootViewController: classifyMenuViewController)
        self.navigationController = navigationController
        window.rootViewController = navigationController
        window.addSubview(classifyMenuViewController.view)
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        self.window = window
        initFilterSetting(restore: true)
        return true
    }

    /// Forgets the stored filter selection unless `restore`.
    func initFilterSetting(restore: Bool) {
        if !restore {
            UserDefaults.standard.removeObject(forKey: CYLMainViewController.filterSelectionKey)
        }
    }
}
