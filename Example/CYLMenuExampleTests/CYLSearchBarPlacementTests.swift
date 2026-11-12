//
//  CYLSearchBarPlacementTests.swift
//  CYLMenuExampleTests
//
//  A search bar never covers any view: on every screen with a CYLSearchBarView, at the default and the largest text
//  size, its frame intersects no other visible view of the window (see CYLViewOverlapInspecting).
//

import XCTest
import UIKit
import CYLSearchViewController
@testable import CYLMenuExample

final class CYLSearchBarPlacementTests: CYLMenuExampleTestCase, CYLViewOverlapInspecting {

    func testCategorySearchBarCoversNoView() throws {
        let screen = CYLSearchCategoryViewController()
        let navigation = UINavigationController(rootViewController: UIViewController())
        show(navigation, size: CYLTestScreen.tall)
        navigation.pushViewController(screen, animated: false)
        try assertSearchBar({ screen.searchBar }, in: navigation, named: "category")
    }

    func testDiscoverSearchBarCoversNoView() throws {
        let screen = CYLSearchDiscoverViewController()
        let navigation = UINavigationController(rootViewController: UIViewController())
        show(navigation, size: CYLTestScreen.tall)
        navigation.pushViewController(screen, animated: false)
        try assertSearchBar({ screen.searchBar }, in: navigation, named: "discover")
    }

    func testHotSearchBarCoversNoView() throws {
        let screen = CYLHotSearchViewController()
        let navigation = UINavigationController(rootViewController: UIViewController())
        show(navigation, size: CYLTestScreen.tall)
        navigation.pushViewController(screen, animated: false)
        try assertSearchBar({ screen.searchBar }, in: navigation, named: "hot-search")
    }

    /**
     * `searchBarOfScreen` is read after the screen is loaded. Lays the screen out at the default and the largest accessibility text size and checks that `searchBar`
     * covers no view at either size.
     */
    private func assertSearchBar(_ searchBarOfScreen: () -> CYLSearchBarView?, in navigation: UINavigationController, named name: String,
                                 file: StaticString = #filePath, line: UInt = #line) throws {
        let sizes: [UIContentSizeCategory]
        if #available(iOS 17.0, *) {
            sizes = [.large, .accessibilityExtraExtraExtraLarge]
        } else {
            sizes = [.large]
        }
        for size in sizes {
            if #available(iOS 17.0, *) {
                navigation.view.window?.traitOverrides.preferredContentSizeCategory = size
            }
            runMainLoop(for: 0.3)
            navigation.view.setNeedsLayout()
            navigation.view.layoutIfNeeded()
            let searchBar = try XCTUnwrap(searchBarOfScreen(), "\(name): the screen has a search bar", file: file, line: line)
            XCTAssertNotNil(searchBar.window, "\(name): the search bar is shown", file: file, line: line)
            let covered = viewsCovered(by: searchBar)
            XCTAssertTrue(covered.isEmpty, "\(name) at \(size.rawValue): the search bar covers \(covered)", file: file, line: line)
            captureScreen(named: "test-search-bar-placement-\(name)-\(size == .large ? "default" : "largest")")
        }
        if #available(iOS 17.0, *) {
            navigation.view.window?.traitOverrides.preferredContentSizeCategory = .large
        }
    }
}
