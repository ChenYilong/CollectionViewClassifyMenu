// swift-tools-version: 5.9
//
//  Package.swift
//  CollectionViewClassifyMenu
//
//  The core library as a Swift package: the sources and resources of CollectionViewClassifyMenu.podspec under
//  CollectionViewClassifyMenu/, without the demo app's files. The resources are the package's bundle (Bundle.module),
//  which CYLMenuResources.bundle returns under SwiftPM. TagCollectionView's CYLTagView is CocoaPods only for now.
//

import PackageDescription

let package = Package(
    name: "CollectionViewClassifyMenu",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "CollectionViewClassifyMenu", targets: ["CollectionViewClassifyMenu"])
    ],
    dependencies: [
        // CYLTagButton subclasses CYLTabBarController's CYLAnimatedItemView (the CocoaPods subspec
        // CYLTabBarController/CYLAnimatedItem; guide:
        // https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md),
        // pinned to the same commit as the Podfiles. CYLTabBarController's Swift package has one product, which also
        // contains its tab bar and its Lottie engine (SwiftPM cannot offer a Core-free variant there).
        .package(url: "https://github.com/ChenYilong/CYLTabBarController.git",
                 revision: "d875dd12ff4dfeea33b71e112d697d0eb25c49f8")
    ],
    targets: [
        .target(
            name: "CollectionViewClassifyMenu",
            dependencies: [
                .product(name: "CYLTabBarController", package: "CYLTabBarController")
            ],
            path: "CollectionViewClassifyMenu",
            exclude: [
                "Class/ClassifyMenu/Controller/CYLDemoDataSource.swift",
                "Class/ClassifyMenu/Controller/CYLFilterDemoViewController.swift",
                "Class/ClassifyMenu/Controller/CYLMainViewController.swift",
                "Class/Other/Symtem/CYLAppDelegate.swift",
                "Class/Other/Symtem/CYLDemoLocalization.swift",
                "Class/Other/Symtem/CYLClassifyMenuDemo.bundle",
                "Class/Other/Symtem/Base.lproj",
                "Class/Other/Symtem/Info.plist",
                "Class/Other/Tool/CYLDBManager.swift",
                "Class/Other/data.json"
            ],
            resources: [
                .process("Resources/Localization"),
                .copy("Resources/Privacy/PrivacyInfo.xcprivacy"),
                // The license and the third-party notices, in the package's bundle (AGENTS.md).
                .copy("Resources/License")
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Accelerate")
            ]
        )
    ]
)
