//
//  CYLLocalizationTests.swift
//  CYLMenuExampleTests
//
//  The core's string bundle (one bundle, every language with the same keys) and the Example in English.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLLocalizationTests: CYLMenuExampleTestCase {

    func testComponentStringsComeFromOneBundleInEveryLanguage() {
        let bundle = CYLMenuResources.bundle()
        XCTAssertEqual(bundle.bundleURL.lastPathComponent, "CYLClassifyMenuResources.bundle")
        let languages = CYLMenuResources.availableLanguages()
        XCTAssertEqual(languages, ["en", "zh-Hans", "zh-Hant"])
        func keys(_ language: String) -> Set<String> {
            let table = bundle.path(forResource: "CYLClassifyMenu", ofType: "strings", inDirectory: nil, forLocalization: language)
                .flatMap { NSDictionary(contentsOfFile: $0) }
            return Set((table?.allKeys as? [String]) ?? [])
        }
        let englishKeys = keys("en")
        XCTAssertFalse(englishKeys.isEmpty)
        for language in languages {
            XCTAssertEqual(keys(language), englishKeys, "\(language) has the same keys as en")
        }
        XCTAssertEqual(CYLMenuResources.localizedString(forKey: "CYLMenuExpand", language: "en"), "More")
        XCTAssertEqual(CYLMenuResources.localizedString(forKey: "CYLMenuExpand", language: "zh-Hans"), "更多")
        XCTAssertEqual(CYLMenuResources.localizedString(forKey: "CYLMenuCollapse", language: "zh-Hant"), "收合")
        XCTAssertEqual(CYLMenuResources.localizedString(forKey: "CYLMenuExpand", language: "fr"), "More", "Unknown languages fall back to English")
        XCTAssertEqual(CYLMenuResources.localizedString(forKey: "NoSuchKey"), "NoSuchKey")

        CYLMenuResources.preferredLanguage = "en"
        XCTAssertEqual(CYLMenuResources.currentLanguage(), "en")
        XCTAssertEqual(CYLMenuStyle().expandTitle, "More")
        CYLMenuResources.preferredLanguage = "zh-Hant-TW"
        XCTAssertEqual(CYLMenuResources.currentLanguage(), "zh-Hant", "Regional variants match their language")
        XCTAssertEqual(CYLMenuStyle().collapseTitle, "收合")
    }

    func testExampleSwitchesLanguage() {
        CYLMenuResources.preferredLanguage = "en"
        let tabs = showRootTabBarController()
        XCTAssertEqual(tabs.fullTabTitles, ["Reviews", "Search", "Styles", "Animations"])
        captureScreen(named: "test-localization-root-english")

        let search = CYLSearchCategoryViewController()
        showInNavigation(search)
        XCTAssertEqual(search.categoryTabBarController.tabTitles, ["People", "Posts", "Gossip", "Jobs"])
        XCTAssertEqual(search.searchBar.placeholder, "Search people, titles, companies...")
        XCTAssertEqual(search.industryButton.accessibilityLabel, "Industry Internet")
        search.select(.jobs)
        search.layOutSelectedCategory()
        XCTAssertEqual(search.tagListView.menuDataSource?.menuTitle(forSection: 0), "Trending job keywords:")

        let reviews = CYLReviewListViewController(selectedFilterIndex: 0)
        showInNavigation(reviews)
        let filters = reviews.filterView.menuDataSource
        XCTAssertEqual(filters?.menuTitleForItem(at: ip(0, 0)), "All")
        XCTAssertTrue(filters?.menuTitleForItem(at: ip(1, 0)).hasPrefix("Positive(") ?? false)
        XCTAssertEqual(reviews.filterView.style.expandTitle, "More")
    }

    func testSearchDiscoverScreenInEnglish() {
        CYLMenuResources.preferredLanguage = "en"
        let screen = CYLSearchDiscoverViewController()
        screen.loadViewIfNeeded()
        XCTAssertEqual(screen.recentSource.menuTitle(forSection: 0), "Recent searches")
        XCTAssertEqual(screen.discoverSource.menuTitle(forSection: 0), "Discover")
        XCTAssertEqual(screen.searchButton.title(for: .normal), "Search")
        XCTAssertEqual(screen.hintLabel.text, "Hold to ask, answer all ✨")
        XCTAssertEqual(screen.hintLabel.accessibilityLabel, "Hold to ask, answer all")
        XCTAssertEqual(CYLMenuLocalizedString("CYLMenuMoreActions"), "More")
        // The data and the hot icon of the language.
        XCTAssertEqual(screen.recentSource.searches.first, "Swift concurrency")
        XCTAssertEqual(screen.discoverSource.topics.first?.title, "Spring camping gear checklist")
        XCTAssertEqual(screen.searchField.placeholder, "Spring camping gear checklist")
        let icon = CYLSearchDiscoverData.hotIcon()
        XCTAssertEqual(icon?.accessibilityLabel, "Hot")
        XCTAssertGreaterThan(icon?.size.width ?? 0, icon?.size.height ?? 0, "HOT is wider than 热")
        XCTAssertEqual(screen.discoverSource.menuAccessibilityLabelForMoreButton(inSection: 0), "Refresh topics")
        XCTAssertEqual(screen.discoverSource.menuAccessibilityHintForItem(at: ip(0, 0)), "Double-tap to search")
    }

    func testSearchDiscoverScreenInTraditionalChinese() throws {
        CYLMenuResources.preferredLanguage = "zh-Hant"
        let data = try CYLSearchDiscoverData.bundled()
        XCTAssertEqual(data.recentSearches.first, "swift 並行")
        XCTAssertEqual(data.discover.first?.title, "春季露營裝備清單")
        XCTAssertEqual(data.discover.count, 24, "The same topics in every language")
        XCTAssertEqual(data.discover.map(\.icon), try simplifiedChineseIcons(), "The same hot topics in every language")
        XCTAssertEqual(CYLSearchDiscoverData.hotIcon()?.accessibilityLabel, "熱門")
        XCTAssertEqual(CYLExampleLocalizedString("最近搜索"), "最近搜尋")
        XCTAssertEqual(CYLExampleLocalizedString("换一批"), "換一批")
    }

    private func simplifiedChineseIcons() throws -> [String?] {
        CYLMenuResources.preferredLanguage = "zh-Hans"
        defer { CYLMenuResources.preferredLanguage = "zh-Hant" }
        return try CYLSearchDiscoverData.bundled().discover.map(\.icon)
    }
}
