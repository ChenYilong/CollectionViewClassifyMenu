//
//  CYLTagDemoAppDelegate.swift
//  TagCollectionView
//
//  Created by ak on 16/1/26.
//  Copyright © 2016年 (year 2016) AK. All rights reserved.
//

import UIKit

@main
@objc(CYLTagDemoAppDelegate)
final class CYLTagDemoAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        true
    }

    /// The demo's window in `scene` (apps built with the iOS 27 SDK must use the scene life cycle).
    func launch(in scene: UIWindowScene) -> UIWindow {
        let window = UIWindow(windowScene: scene)
        window.rootViewController = CYLTagDemoViewController()
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        self.window = window
        return window
    }
}

@objc(CYLTagDemoSceneDelegate)
final class CYLTagDemoSceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene, let app = UIApplication.shared.delegate as? CYLTagDemoAppDelegate else { return }
        window = app.launch(in: scene)
    }
}
