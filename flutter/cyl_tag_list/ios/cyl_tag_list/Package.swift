// swift-tools-version: 5.9
//
//  Package.swift
//  cyl_tag_list
//
//  The plugin under Swift Package Manager: Flutter's FlutterFramework and the core library, this repository's
//  Package.swift (the repository root is four folders up). CocoaPods users keep cyl_tag_list.podspec.
//

import PackageDescription

let package = Package(
    name: "cyl_tag_list",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "cyl-tag-list", targets: ["cyl_tag_list"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(name: "CollectionViewClassifyMenu", path: "../../../..")
    ],
    targets: [
        .target(
            name: "cyl_tag_list",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "CollectionViewClassifyMenu", package: "CollectionViewClassifyMenu")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
