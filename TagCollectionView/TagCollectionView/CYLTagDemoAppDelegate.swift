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
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = CYLTagDemoViewController()
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
