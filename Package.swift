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
        // pinned to the same commit as the Podfiles. Its Swift package's `CYLAnimatedItem` product is the component on
        // its own (the view, its resources and the animation engine), without the tab bar.
        .package(url: "https://github.com/ChenYilong/CYLTabBarController.git",
                 revision: "43ad5f6af334b1560d30b62c8bbf9ae448d6e670")
    ],
    targets: [
        .target(
            name: "CollectionViewClassifyMenu",
            dependencies: [
                .product(name: "CYLAnimatedItem", package: "CYLTabBarController")
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
                // The core's images as a folder bundle (CYLMenuResources.imagesBundle).
                .copy("Resources/CYLClassifyMenuImages.bundle"),
                .copy("Resources/Privacy/PrivacyInfo.xcprivacy"),
                // The license and the third-party notices, in the package's bundle (AGENTS.md).
                .copy("Resources/License")
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Accelerate"),
                // The tag list cache's database store (CYLTagListCachePolicyDatabase) uses the system SQLite.
                .linkedLibrary("sqlite3")
            ]
        )
    ]
)
