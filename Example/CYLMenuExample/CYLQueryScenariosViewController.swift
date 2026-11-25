//
//  CYLQueryScenariosViewController.swift
//  CYLMenuExample
//
//  PlusButton 的子控制器：按场景分组的筛选演示。
//  - 查询参数设置：淘宝评价默认显示全部，条件太多时由用户多选输入（标签列表的用途），分别用内存、网络、
//    数据库（SQLite）三种方式筛选；
//  - 菜单选择：移植 CollectionViewClassifyMenu 原 Demo 的分类菜单与多选筛选，并与数据库联动；
//  - 搜索历史与发现：最近搜索（折叠按钮作为最后一个标签）与两列的发现网格（右上角 More 按钮刷新）；
//  - 数据库：各表的行数。
//  The plus button's child view controller: the filter demos grouped by scenario.
//  The groups are one CYLTagListView (examples rule "Sectioned lists in demos use the tag list"): one section per
//  group, a tag shows its title and an SF Symbol, the detail line is the callout of a long press.
//

import UIKit
import CollectionViewClassifyMenu

@objc enum CYLQueryScenario: Int {
    case reviewsDatabase = 0
    case reviewsMemory
    case reviewsNetwork
    case menuLinkage
    case searchDiscover
}

final class CYLQueryScenariosViewController: UIViewController {

    /// Tag rows shown while a section is folded; a section with more rows gets the More / Less control.
    static let visibleRows = 2
    /// A title may wrap onto this many lines in its tag.
    static let titleMaxLines = 3
    /// The scenario sections, then the database section.
    static let databaseSection = 3
    /// The tables whose row counts the database section shows.
    static let databaseTables = ["reviews", "places", "selections"]
    private static let databaseSymbol = "tablecells"
    private static let detailSeparator = "\n"

    let database: CYLExampleDatabase
    let tagList = CYLTagListView(foldControl: CYLMenuFoldControl(position: .headerTrailing, content: .iconAndTitle))

    init(database: CYLExampleDatabase) {
        self.database = database
        super.init(nibName: nil, bundle: nil)
    }

    convenience init() {
        self.init(database: CYLExampleDatabase.shared())
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // navigationItem, not title: a view controller's title would replace its tab's title.
        navigationItem.title = CYLExampleLocalizedString("查询筛选")
        view.backgroundColor = .systemBackground

        let style = CYLMenuStyle()
        style.titleMaxLines = Self.titleMaxLines
        tagList.style = style
        // A tap opens a screen and nothing stays selected. numberOfItemsPerRow stays 0: a tag is as wide as its title.
        tagList.selectionMode = .none
        tagList.defaultVisibleRows = Self.visibleRows
        // The old detail line is the callout of a long press (data source menuSubtitleForItem).
        tagList.longPressAction = CYLTagLongPressActions.callout
        tagList.menuDataSource = self
        tagList.menuDelegate = self
        tagList.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tagList)
        NSLayoutConstraint.activate([
            tagList.topAnchor.constraint(equalTo: view.topAnchor),
            tagList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tagList.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tagList.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        tagList.reloadMenuData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // The selections saved by the demos change the database section.
        tagList.reloadMenuData()
    }

    // MARK: Scenarios

    func scenarios(inSection section: Int) -> [CYLQueryScenario] {
        switch section {
        case 0: return [.reviewsDatabase, .reviewsMemory, .reviewsNetwork]
        case 1: return [.menuLinkage]
        case 2: return [.searchDiscover]
        default: return []
        }
    }

    func title(for scenario: CYLQueryScenario) -> String {
        switch scenario {
        case .reviewsDatabase: return CYLExampleLocalizedString("评价筛选 · 数据库（SQLite）")
        case .reviewsMemory: return CYLExampleLocalizedString("评价筛选 · 内存")
        case .reviewsNetwork: return CYLExampleLocalizedString("评价筛选 · 网络")
        case .menuLinkage: return CYLExampleLocalizedString("分类菜单 + 多选筛选 · 数据库联动")
        case .searchDiscover: return CYLExampleLocalizedString("最近搜索 + 发现")
        }
    }

    func symbol(for scenario: CYLQueryScenario) -> String {
        switch scenario {
        case .reviewsDatabase: return "cylinder.split.1x2"
        case .reviewsMemory: return "memorychip"
        case .reviewsNetwork: return "network"
        case .menuLinkage: return "square.grid.3x2"
        case .searchDiscover: return "magnifyingglass"
        }
    }

    /// The demo a tag opens, with `hidesBottomBarWhenPushed`.
    func viewController(for scenario: CYLQueryScenario) -> UIViewController {
        let controller: UIViewController
        switch scenario {
        case .reviewsDatabase:
            controller = CYLReviewListViewController(selectedFilterIndex: 0, mode: .database)
        case .reviewsMemory:
            controller = CYLReviewListViewController(selectedFilterIndex: 0, mode: .memory)
        case .reviewsNetwork:
            controller = CYLReviewListViewController(selectedFilterIndex: 0, mode: .network)
        case .menuLinkage:
            controller = CYLMenuLinkageViewController(database: database)
        case .searchDiscover:
            controller = CYLSearchDiscoverViewController()
        }
        // A screen pushed from a tab hides the tab bar.
        controller.hidesBottomBarWhenPushed = true
        return controller
    }

    /// Pushes a demo, as tapping its tag does.
    func open(_ scenario: CYLQueryScenario) {
        navigationController?.pushViewController(viewController(for: scenario), animated: false)
    }

    // MARK: Section texts

    func sectionTitle(_ section: Int) -> String {
        switch section {
        case 0: return CYLExampleLocalizedString("场景：查询参数设置（多选）")
        case 1: return CYLExampleLocalizedString("场景：菜单选择（移植原 Demo）")
        case 2: return CYLExampleLocalizedString("场景：搜索历史与发现")
        default: return CYLExampleLocalizedString("数据库（SQLite）")
        }
    }

    /// The old section footer: now part of the long-press callout of every tag of the section.
    func sectionDetail(_ section: Int) -> String {
        switch section {
        case 0: return CYLExampleLocalizedString("淘宝评价默认显示全部；条件太多时，由用户多选输入筛选条件，标签列表就是为此而做。每次选择后按全部条件（AND）刷新列表。")
        case 1: return CYLExampleLocalizedString("原 Demo 只实现了筛选界面，没有筛选数据；现在每次选择都会生成 SQL、查询数据库并显示结果，选择也保存在数据库中。")
        case 2: return CYLExampleLocalizedString("最近搜索折叠为两行，箭头是最后一个标签；发现每行两个，超出部分显示省略号，右上角的更多按钮随机刷新。数据来自本地 JSON。")
        default: return CYLExampleLocalizedString("每次启动时由 App 内的数据重新生成，selections 表保留各演示最后确认的条件。")
        }
    }

    /// The long-press text of a tag: for a database table its row count (the old detail line), then the section's detail.
    func detail(at indexPath: IndexPath) -> String {
        guard indexPath.section == Self.databaseSection else {
            return sectionDetail(indexPath.section)
        }
        let count = CYLExampleLocalizedString("%ld 行", database.count(ofTable: Self.databaseTables[indexPath.item]))
        return count + Self.detailSeparator + sectionDetail(indexPath.section)
    }
}

// MARK: CYLMenuDataSource

extension CYLQueryScenariosViewController: CYLMenuDataSource {

    func numberOfSectionsInMenu() -> Int {
        Self.databaseSection + 1
    }

    func menuNumberOfItems(inSection section: Int) -> Int {
        section == Self.databaseSection ? Self.databaseTables.count : scenarios(inSection: section).count
    }

    func menuTitle(forSection section: Int) -> String {
        sectionTitle(section)
    }

    func menuTitleForItem(at indexPath: IndexPath) -> String {
        if indexPath.section == Self.databaseSection {
            return Self.databaseTables[indexPath.item]
        }
        return title(for: scenarios(inSection: indexPath.section)[indexPath.item])
    }

    func menuImageForItem(at indexPath: IndexPath) -> UIImage? {
        if indexPath.section == Self.databaseSection {
            return UIImage(systemName: Self.databaseSymbol)
        }
        return UIImage(systemName: symbol(for: scenarios(inSection: indexPath.section)[indexPath.item]))
    }

    func menuSubtitleForItem(at indexPath: IndexPath) -> String? {
        detail(at: indexPath)
    }
}

// MARK: CYLMenuDelegate

extension CYLQueryScenariosViewController: CYLMenuDelegate {

    /// A tap pushes the demo, as the row did; a database table is not a link.
    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section < Self.databaseSection else {
            return
        }
        let scenario = scenarios(inSection: indexPath.section)[indexPath.item]
        navigationController?.pushViewController(viewController(for: scenario), animated: true)
    }
}
