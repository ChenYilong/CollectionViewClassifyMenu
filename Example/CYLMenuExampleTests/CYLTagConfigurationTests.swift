//
//  CYLTagConfigurationTests.swift
//  CYLMenuExampleTests
//
//  CYLTagListView+CYLConfiguration: lists made from a map and from a configuration file, as CYLTabBarController does.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLTagConfigurationTests: XCTestCase {

    func testDictionaryConfigurationCreatesAndStylesTheTags() {
        let view = CYLTagListView(configuration: CYLTagConfigurationDemoViewController.mapConfiguration())
        view.frame = CGRect(x: 0, y: 0, width: 375, height: 300)
        view.layoutIfNeeded()
        XCTAssertEqual(view.selectionMode, .multiple)
        XCTAssertFalse(view.isScrollEnabled)
        XCTAssertEqual(view.selectedIndexPaths, [ip(1, 0)])
        XCTAssertNotNil(view.configurationDataSource, "The view keeps the data source it built")
        XCTAssertTrue(view.menuDataSource === view.configurationDataSource)
        XCTAssertEqual(view.menuDataSource?.menuNumberOfItems(inSection: 0), 5)
        XCTAssertEqual(view.menuDataSource?.menuTitleForItem(at: ip(4, 0)), "Text only", "A string item is a title")
        XCTAssertNotNil(view.menuDataSource?.menuImageForItem?(at: ip(3, 0)), "system: images are SF Symbols")
        XCTAssertEqual(view.style.imageSize, CGSize(width: 20, height: 20))
        XCTAssertEqual(view.style.normalAppearance.cornerRadius, 8)
        XCTAssertEqual(view.style.normalAppearance.iconColor, UIColor.systemIndigo)
    }

    func testConfigurationStringValuesAreConverted() {
        let normal: [String: Any] = [
            CYLTagAppearanceKey.textColor: "#FF0000",
            CYLTagAppearanceKey.borderColor: "systemBlue",
            CYLTagAppearanceKey.font: ["size": 15, "weight": "bold"] as [String: Any],
            CYLTagAppearanceKey.margin: "6",
        ]
        let style: [String: Any] = [
            CYLMenuStyleKey.imageInsets: "{1, 2, 3, 4}",
            CYLMenuStyleKey.titlePositionAdjustment: [2, -1],
            CYLMenuStyleKey.imageSize: ["width": 18, "height": 16],
            CYLMenuStyleKey.layoutCentered: "no",
            CYLMenuStyleKey.normal: normal,
        ]
        let sections: [[String: Any]] = [
            [CYLTagSectionKey.title: "A", CYLTagSectionKey.items: ["x", "y"]],
            [CYLTagSectionKey.title: "B", CYLTagSectionKey.items: [[CYLTagItemKey.title: "z", CYLTagItemKey.enabled: "false"]]],
        ]
        let view = CYLTagListView(configuration: [
            CYLTagListKey.selectionMode: "single",
            CYLTagListKey.foldStyle: "footerChevron",
            CYLTagListKey.defaultVisibleRows: "2",
            CYLTagListKey.showsSectionHeaders: "false",
            CYLTagListKey.selectedItems: ["1-0"],
            CYLTagListKey.style: style,
            CYLTagListKey.sections: sections,
        ])
        XCTAssertEqual(view.selectionMode, .single)
        XCTAssertEqual(view.foldStyle, .footerChevron)
        XCTAssertEqual(view.defaultVisibleRows, 2)
        XCTAssertFalse(view.showsSectionHeaders)
        XCTAssertEqual(view.selectedIndexPaths, [ip(0, 1)], "\"section-item\"")
        XCTAssertEqual(view.style.imageInsets, UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4))
        XCTAssertEqual(view.style.titlePositionAdjustment, UIOffset(horizontal: 2, vertical: -1))
        XCTAssertEqual(view.style.imageSize, CGSize(width: 18, height: 16))
        XCTAssertFalse(view.style.layoutCentered)
        let text = CYLColorComponents(view.style.normalAppearance.textColor)
        XCTAssertEqual(text.red, 1, accuracy: 0.01)
        XCTAssertEqual(text.green, 0, accuracy: 0.01)
        XCTAssertEqual(view.style.normalAppearance.borderColor, UIColor.systemBlue)
        XCTAssertEqual(view.style.normalAppearance.font.pointSize, 15, accuracy: 0.01)
        XCTAssertTrue(view.style.normalAppearance.font.fontDescriptor.symbolicTraits.contains(.traitBold))
        XCTAssertEqual(view.style.normalAppearance.margin, 6)
        XCTAssertEqual(view.menuDataSource?.menuItemIsEnabled?(at: ip(0, 1)), false)
    }

    func testConfigurationFileCreatesAnimatedTags() throws {
        let file = CYLTagConfigurationDemoViewController.configurationFilePath()
        let configuration = try CYLTagListView.configuration(contentsOfFile: file)
        XCTAssertFalse(configuration.isEmpty)
        let view = try CYLTagListView(configurationFile: file)
        XCTAssertEqual(view.selectionMode, .single)
        XCTAssertFalse(view.allowsEmptySelection)
        XCTAssertEqual(view.foldStyle, .footerChevron)
        XCTAssertEqual(view.selectedIndexPaths, [ip(0, 0)])
        XCTAssertEqual(view.style.normalAppearance.cornerRadius, 0, "A capsule")
        for item in 0..<4 {
            let url = view.menuDataSource?.menuAnimationURLForItem?(at: ip(item, 0))
            XCTAssertNotNil(url, "item \(item)")
            XCTAssertTrue(FileManager.default.fileExists(atPath: url?.path ?? ""), "\(String(describing: url)) resolves next to the file or in the app")
        }
        XCTAssertThrowsError(try CYLTagListView(configurationFile: "missing.json")) { error in
            let error = error as NSError
            XCTAssertEqual(error.domain, CYLMenuConfigurationError.errorDomain)
            XCTAssertEqual(error.code, CYLMenuConfigurationError.Code.fileNotFound.rawValue)
        }
    }
}
