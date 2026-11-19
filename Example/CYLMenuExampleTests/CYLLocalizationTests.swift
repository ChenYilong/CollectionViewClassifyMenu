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
        let bundle = CYLMenuResources.bundle
        XCTAssertEqual(bundle.bundleURL.lastPathComponent, "CYLClassifyMenuResources.bundle")
        let languages = CYLMenuResources.availableLanguages
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
        XCTAssertEqual(CYLMenuResources.currentLanguage, "en")
        XCTAssertEqual(CYLMenuStyle().expandTitle, "More")
        CYLMenuResources.preferredLanguage = "zh-Hant-TW"
        XCTAssertEqual(CYLMenuResources.currentLanguage, "zh-Hant", "Regional variants match their language")
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

    // MARK: Every screen

    /// Text that stays as written in every language (marked NOLOCALIZE in the code): user-generated reviews and their
    /// keyword tags, a shop's product title, song and user names, a shoe listing, AndroidTagView's multilingual lists.
    private func untranslatedContent() -> [String] {
        var content = CYLReviewStore.mockReviews().flatMap { [$0.user, $0.text, $0.sku] + $0.keywords }
        content += ["潮牌电镀镜面MLGB字母iphone6手机壳苹果6plus手机壳情侣5S外壳潮", "手机套不错", "质量不错", "态度不错", "划算",
                    "颜色不错", "背面细节一般"]
        content += CYLHotSearchViewController.hotSearches.map(\.0)
        content += CYLImageTagSampleData.initialGroups().flatMap { $0.tags.map(\.title) }
        content += CYLTagContainerSampleData.list1 + CYLTagContainerSampleData.list3
        // The word picker's friend message (user content).
        content.append(CYLWordPickerDemoViewController.message)
        // The same, cut to tag_max_length (23: 20 characters and "...").
        content += CYLTagContainerSampleData.list1.map { String($0.prefix(20)) }
        return content
    }

    /// Every visible text of a view tree: labels, buttons, text fields and views, accessibility labels and values.
    private func visibleTexts(in view: UIView) -> [String] {
        guard !view.isHidden, view.alpha > 0.01 else { return [] }
        var texts: [String] = []
        if let label = view as? UILabel { texts.append(label.text ?? "") }
        if let button = view as? UIButton { texts.append(button.currentTitle ?? "") }
        if let field = view as? UITextField { texts += [field.text ?? "", field.placeholder ?? ""] }
        if let textView = view as? UITextView { texts.append(textView.text ?? "") }
        if let control = view as? UISegmentedControl {
            texts += (0..<control.numberOfSegments).compactMap { control.titleForSegment(at: $0) }
        }
        if view.isAccessibilityElement { texts += [view.accessibilityLabel ?? "", view.accessibilityValue ?? ""] }
        let kind = String(describing: type(of: view))
        return texts.filter { !$0.isEmpty }.map { "\(kind) \($0)" } + view.subviews.flatMap(visibleTexts(in:))
    }

    /// The text with the untranslated content removed, and a shown SQL statement (it holds the database's own values).
    private func translatedPart(of text: String, content: [String]) -> String {
        let lines = text.components(separatedBy: "\n").map { line in
            line.range(of: "SELECT ").map { String(line[..<$0.lowerBound]) } ?? line
        }
        return content.sorted { $0.count > $1.count }.reduce(lines.joined(separator: "\n")) {
            $0.replacingOccurrences(of: $1, with: "")
        }
    }

    /// Characters that exist only in Simplified Chinese, among the common ones of this Example.
    private static let simplifiedOnly = Set("这个们时后动标签选择删设图显语关开为对数据库网络页级务发说话读写认识门间问题区东车马鸟鱼风")

    private func screens() -> [(String, () -> UIViewController)] {
        [("Styles", { CYLTagStyleDemoViewController() }),
         ("Animations", { CYLTagAnimationDemoViewController() }),
         ("Configuration", { CYLTagConfigurationDemoViewController() }),
         ("Tag cloud", { CYLTagCloudDemoViewController() }),
         ("Search home", { CYLSearchHomeViewController() }),
         ("Search discover", { CYLSearchDiscoverViewController() }),
         ("Search categories", { CYLSearchCategoryViewController() }),
         ("Reviews", { CYLReviewListViewController(selectedFilterIndex: 0) }),
         ("Menu and database", { CYLMenuLinkageViewController() }),
         ("Query scenarios", { CYLQueryScenariosViewController() }),
         ("Product", { CYLProductViewController() }),
         ("Container sample", { CYLTagContainerSampleViewController() }),
         ("Tag cloud sample", { CYLTagCloudSampleViewController() }),
         ("Hot searches", { CYLHotSearchViewController() }),
         ("Image tags", { CYLImageTagSampleViewController() }),
         ("About", { CYLAndroidSamplesAboutViewController() }),
         ("Word picker", { CYLWordPickerDemoViewController() })]
    }

    /// Every screen of the Example in English and in Traditional Chinese: no Chinese text in English and no
    /// Simplified-only character in Traditional Chinese, apart from the untranslated content above; the search
    /// categories are checked one by one.
    func testEveryScreenIsInTheAppLanguage() {
        let content = untranslatedContent()
        var failures: [String] = []
        for language in ["en", "zh-Hant"] {
            CYLMenuResources.preferredLanguage = language
            for (name, make) in screens() {
                let controller = make()
                let navigation = showInNavigation(controller, size: CYLTestScreen.tall)
                controller.view.layoutIfNeeded()
                runMainLoop(for: 0.3)
                var views: [(String, UIView)] = [(name, navigation.view)]
                if let search = controller as? CYLSearchCategoryViewController {
                    for category in [CYLSearchCategory.people, .feeds, .gossip, .jobs] {
                        search.select(category)
                        search.layOutSelectedCategory()
                        views.append(("\(name) \(category.rawValue)", navigation.view))
                    }
                }
                for (where_, view) in views {
                    var texts = visibleTexts(in: view)
                    texts.append("title " + (controller.navigationItem.title ?? ""))
                    for text in texts {
                        let rest = translatedPart(of: text, content: content)
                        let wrong = language == "en"
                            ? rest.unicodeScalars.contains { (0x3400...0x9FFF).contains($0.value) }
                            : rest.contains { Self.simplifiedOnly.contains($0) }
                        if wrong { failures.append("\(language) \(where_): \(text)") }
                    }
                }
            }
        }
        XCTAssertEqual(failures, [], failures.joined(separator: "\n"))
    }
}
