//
//  CYLExampleAppDelegate.swift
//  CYLMenuExample
//
//  The Example app. `-CYLExampleScreen <screen>[@<language>]` opens a screen directly and writes a
//  layout report ([CYLExampleLayout] lines in Documents/CYLExampleLayout.txt) for
//  scripts/example-screenshots.sh; `-CYLExampleLanguage <language>` switches the language.
//

import UIKit
import CollectionViewClassifyMenu
import CYLTabBarController

@main
final class CYLExampleAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    /// The app's root tab bar: 场景一（淘宝评价筛选）, 场景二（脉脉搜索分类）, 样式 and 动效, each in a
    /// navigation controller, with the plus button in the middle. Scenario 2 has a second tab bar for its
    /// categories, also at the bottom.
    static func makeRootTabBarController() -> CYLTabBarController {
        let reviews = UINavigationController(rootViewController: CYLProductViewController())
        let search = UINavigationController(rootViewController: CYLSearchHomeViewController())
        let attributes: [[AnyHashable: Any]] = [
            [CYLTabBarItemTitle: CYLExampleLocalizedString("场景一：评价筛选"),
             CYLTabBarItemImage: UIImage(systemName: "cart")!,
             CYLTabBarItemSelectedImage: UIImage(systemName: "cart.fill")!],
            [CYLTabBarItemTitle: CYLExampleLocalizedString("场景二：搜索分类"),
             CYLTabBarItemImage: UIImage(systemName: "magnifyingglass.circle")!,
             CYLTabBarItemSelectedImage: UIImage(systemName: "magnifyingglass.circle.fill")!],
            [CYLTabBarItemTitle: CYLExampleLocalizedString("样式"),
             CYLTabBarItemImage: UIImage(systemName: "paintbrush")!,
             CYLTabBarItemSelectedImage: UIImage(systemName: "paintbrush.fill")!],
            [CYLTabBarItemTitle: CYLExampleLocalizedString("动效"),
             CYLTabBarItemImage: UIImage(systemName: "sparkles")!,
             CYLTabBarItemSelectedImage: UIImage(systemName: "sparkles")!],
        ]
        let animations = UINavigationController(rootViewController: CYLTagAnimationDemoViewController())
        let styles = UINavigationController(rootViewController: CYLTagStyleDemoViewController())
        // The plus button in the middle opens the filter scenarios (CYLQueryScenariosViewController). Registered
        // again for every root tab bar so that each gets its own child view controller; the root tab bar has its
        // own context, so scenario 2's nested category tab bar has no plus button.
        CYLExamplePlusButton.register()
        return CYLTabBarController(viewControllers: [reviews, search, styles, animations],
                                   tabBarItemsAttributes: attributes,
                                   imageInsets: .zero,
                                   titlePositionAdjustment: .zero,
                                   context: CYLExampleRootTabBarContext)
    }

    /// Selects the tab whose root view controller is a `rootClass` and returns its navigation controller.
    /// (Indexes would move with the plus button's tab.)
    @discardableResult
    static func selectTab(withRootClass rootClass: UIViewController.Type, in tabs: CYLTabBarController) -> UINavigationController? {
        for controller in tabs.viewControllers ?? [] {
            if let navigation = controller as? UINavigationController,
               let root = navigation.viewControllers.first, type(of: root) == rootClass || root.isKind(of: rootClass) {
                tabs.selectedViewController = navigation
                return navigation
            }
        }
        return nil
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // `-CYLExampleLanguage en` (or a screen name ending in "@en") switches the language of the
        // component and the Example, as an in-app language setting would.
        var screen = UserDefaults.standard.string(forKey: "CYLExampleScreen") ?? ""
        var language = UserDefaults.standard.string(forKey: "CYLExampleLanguage")
        if let at = screen.firstIndex(of: "@") {
            language = String(screen[screen.index(after: at)...])
            screen = String(screen[..<at])
        }
        if let language, !language.isEmpty {
            CYLMenuResources.preferredLanguage = language
        }

        let window = UIWindow(frame: UIScreen.main.bounds)
        let tabs = Self.makeRootTabBarController()
        window.rootViewController = tabs
        window.makeKeyAndVisible()
        self.window = window

        // `-CYLExampleScreen <name>` opens a screen directly (used by scripts/example-screenshots.sh).
        Self.openScreen(screen, in: tabs)
        if !screen.isEmpty {
            try? FileManager.default.removeItem(at: Self.layoutReportURL)
            // Layout report for scripts/example-screenshots.sh, printed before the screenshot is taken.
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                Self.reportLayout(ofScreen: screen, in: tabs)
            }
        }
        return true
    }

    // MARK: Layout report

    static var layoutReportURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("CYLExampleLayout.txt")
    }

    /// Appends a line to Documents/CYLExampleLayout.txt, which scripts/example-screenshots.sh copies
    /// next to each screenshot.
    static func appendLayoutReport(_ line: String) {
        NSLog("%@", line)
        let existing = (try? String(contentsOf: layoutReportURL, encoding: .utf8)) ?? ""
        try? (existing + line + "\n").write(to: layoutReportURL, atomically: true, encoding: .utf8)
    }

    static func reportTagList(_ view: CYLTagListView, named name: String) {
        guard let collection = view.value(forKey: "collectionView") as? UICollectionView else { return }
        var line = String(format: "[CYLExampleLayout] %@ frame=%@ hidden=%d window=%d contentHeight=%.1f collection=%@ contentSize=%@ offset=%@ adjustedInset=%@ sections=%ld",
                          name, NSCoder.string(for: view.frame), view.isHidden ? 1 : 0, view.window != nil ? 1 : 0,
                          Double(view.contentHeight), NSCoder.string(for: collection.frame), NSCoder.string(for: collection.contentSize),
                          NSCoder.string(for: collection.contentOffset), NSCoder.string(for: collection.adjustedContentInset),
                          collection.numberOfSections)
        for section in 0..<collection.numberOfSections {
            line += " items[\(section)]=\(collection.numberOfItems(inSection: section))"
        }
        line += " visibleCells=\(collection.visibleCells.count)"
        if let first = collection.visibleCells.first {
            line += String(format: " firstCell=%@ inWindow=%@ alpha=%.2f hidden=%d", NSCoder.string(for: first.frame),
                           NSCoder.string(for: first.convert(first.bounds, to: nil)), Double(first.alpha), first.isHidden ? 1 : 0)
            for subview in first.contentView.subviews {
                line += " sub=\(NSStringFromClass(type(of: subview)))\(NSCoder.string(for: subview.frame))"
            }
        }
        line += String(format: " collectionHidden=%d alpha=%.2f bg=%@ superviews=", collection.isHidden ? 1 : 0, Double(collection.alpha),
                       String(describing: collection.backgroundColor))
        var ancestor = view.superview
        while let current = ancestor {
            line += "\(NSStringFromClass(type(of: current)))\(NSCoder.string(for: current.frame)),"
            ancestor = current.superview
        }
        appendLayoutReport(line)
    }

    static func reportLayout(ofScreen screen: String, in tabs: CYLTabBarController) {
        let navigation = tabs.selectedViewController as? UINavigationController
        let top = navigation?.topViewController
        appendLayoutReport("[CYLExampleLayout] screen=\(screen) top=\(top.map { NSStringFromClass(type(of: $0)) } ?? "(null)")")
        if let reviews = top as? CYLReviewListViewController {
            let status = (reviews.statusLabel.text ?? "").replacingOccurrences(of: "\n", with: " | ")
            appendLayoutReport("[CYLExampleLayout] table=\(NSCoder.string(for: reviews.tableView.frame)) rows=\(reviews.tableView.numberOfRows(inSection: 0)) status=\(status)")
            reportTagList(reviews.filterView, named: "reviewFilter")
        } else if let product = top as? CYLProductViewController {
            reportTagList(product.previewView, named: "productPreview")
        } else if let search = top as? CYLSearchCategoryViewController {
            let bar = search.categoryTabBarController.tabBar
            appendLayoutReport("[CYLExampleLayout] categoryTabBar=\(NSCoder.string(for: bar.convert(bar.bounds, to: nil)))")
            reportTagList(search.tagListView, named: "searchTags")
        } else if let styles = top as? CYLTagStyleDemoViewController {
            reportTagList(styles.tagListView, named: "styleTags")
        } else if let animations = top as? CYLTagAnimationDemoViewController {
            reportTagList(animations.tagListView, named: "animationTags")
        } else if let menu = top as? CYLMenuLinkageViewController {
            let footer = menu.menuFooterView.map { NSCoder.string(for: $0.frame) } ?? NSCoder.string(for: CGRect.zero)
            appendLayoutReport("[CYLExampleLayout] menuLinkage results=\(menu.results.count) footer=\(footer) sql=\(menu.lastQuery.displayString())")
        }
    }

    // MARK: Screens

    /// The plus button's tab: "plus" (scenario list), "plus-reviews-db" (review filter on SQLite, 好评 + 有图),
    /// "plus-menu" (ported classify menu, every condition), "plus-menu-filtered" (a tag, regions and dishes).
    static func openPlusScreen(_ screen: String, in tabs: CYLTabBarController) {
        guard let navigation = selectTab(withRootClass: CYLQueryScenariosViewController.self, in: tabs),
              let scenarios = navigation.viewControllers.first as? CYLQueryScenariosViewController else { return }
        if screen == "plus-reviews-db" {
            guard let reviews = scenarios.viewController(for: .reviewsDatabase) as? CYLReviewListViewController else { return }
            navigation.pushViewController(reviews, animated: false)
            reviews.selectFilterIndexes([1, 4])
        } else if screen.hasPrefix("plus-menu") {
            guard let menu = scenarios.viewController(for: .menuLinkage) as? CYLMenuLinkageViewController else { return }
            navigation.pushViewController(menu, animated: false)
            menu.loadViewIfNeeded()
            menu.resetConditions()
            if screen == "plus-menu-filtered" {
                // 吃 · 川菜, in 上海 or 深圳, dishes 川菜 or 特色火锅.
                menu.selectClassifyItem(at: IndexPath(item: 1, section: 0))
                menu.confirmFilterSelection([IndexPath(item: 2, section: 0), IndexPath(item: 4, section: 0),
                                             IndexPath(item: 2, section: 1), IndexPath(item: 3, section: 1)])
            }
        }
    }

    static func openScreen(_ screen: String, in tabs: CYLTabBarController) {
        if screen.hasPrefix("reviews") {
            guard let navigation = selectTab(withRootClass: CYLProductViewController.self, in: tabs) else { return }
            let mode: CYLReviewFilteringMode = screen == "reviews-network" ? .network : .memory
            let reviews = CYLReviewListViewController(selectedFilterIndex: 0, mode: mode)
            reviews.hidesBottomBarWhenPushed = true
            navigation.pushViewController(reviews, animated: false)
            if screen == "reviews-expanded" {
                reviews.loadViewIfNeeded()
                reviews.filterView.setExpanded(true, forSection: 0, animated: false)
            } else if screen == "reviews-multi" || screen == "reviews-network" {
                // 好评 + 有图: both conditions must match.
                reviews.selectFilterIndexes([1, 4])
            }
        } else if screen.hasPrefix("style") {
            guard let navigation = selectTab(withRootClass: CYLTagStyleDemoViewController.self, in: tabs),
                  let demo = navigation.viewControllers.first as? CYLTagStyleDemoViewController else { return }
            let actions: [String: [String]] = [
                // A capsule with a wider icon spacing, colored icons and a colored selection.
                "style-custom": ["cornerRadius", "imageTitleSpacing", "iconColor.normal", "backgroundColor.selected", "borderColor", "borderWidth"],
                "style-icon-only": ["content.iconOnly", "cornerRadius"],
                "style-title-uncentered": ["content.titleOnly", "layoutCentered"],
                "style-lottie": ["animation.lottie"],
                "style-pag": ["animation.pag"],
                "style-rive": ["animation.rive"],
                "style-gif": ["animation.gif"],
            ]
            for action in actions[screen] ?? [] {
                demo.performAction(action)
            }
        } else if screen.hasPrefix("animations") {
            guard let navigation = selectTab(withRootClass: CYLTagAnimationDemoViewController.self, in: tabs),
                  let demo = navigation.viewControllers.first as? CYLTagAnimationDemoViewController else { return }
            if screen == "animations-speed" {
                demo.loadViewIfNeeded()
                demo.changeSpeed()
            } else if screen == "animations-rive" {
                // PAG, Rive and icons.riv on dark tags, below the first screen.
                DispatchQueue.main.async {
                    demo.scroll(toSectionIdentifier: "pag")
                }
            }
        } else if screen == "config" {
            guard let navigation = selectTab(withRootClass: CYLTagStyleDemoViewController.self, in: tabs) else { return }
            navigation.pushViewController(CYLTagConfigurationDemoViewController(), animated: false)
        } else if screen == "search-home" {
            selectTab(withRootClass: CYLSearchHomeViewController.self, in: tabs)
        } else if screen.hasPrefix("plus") {
            openPlusScreen(screen, in: tabs)
        } else if screen.hasPrefix("search") {
            guard let navigation = selectTab(withRootClass: CYLSearchHomeViewController.self, in: tabs) else { return }
            let search = CYLSearchCategoryViewController()
            search.hidesBottomBarWhenPushed = true
            navigation.pushViewController(search, animated: false)
            if screen == "search-gossip" {
                search.select(.gossip)
            } else if screen == "search-jobs" {
                search.select(.jobs)
            }
        }
    }
}
