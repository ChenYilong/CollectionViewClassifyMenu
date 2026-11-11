//
//  CYLQueryScenariosViewController.swift
//  CYLMenuExample
//
//  PlusButton 的子控制器：按场景分组的筛选演示。
//  - 查询参数设置：淘宝评价默认显示全部，条件太多时由用户多选输入（标签列表的用途），分别用内存、网络、
//    数据库（SQLite）三种方式筛选；
//  - 菜单选择：移植 CollectionViewClassifyMenu 原 Demo 的分类菜单与多选筛选，并与数据库联动；
//  - 数据库：各表的行数。
//  The plus button's child view controller: the filter demos grouped by scenario.
//

import UIKit
import CollectionViewClassifyMenu

@objc enum CYLQueryScenario: Int {
    case reviewsDatabase = 0
    case reviewsMemory
    case reviewsNetwork
    case menuLinkage
}

final class CYLQueryScenariosViewController: UITableViewController {

    private static let scenarioCell = "CYLQueryScenarioCell"

    let database: CYLExampleDatabase

    init(database: CYLExampleDatabase) {
        self.database = database
        super.init(style: .insetGrouped)
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.scenarioCell)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // The selections saved by the demos change the database section.
        tableView.reloadData()
    }

    // MARK: Scenarios

    func scenarios(inSection section: Int) -> [CYLQueryScenario] {
        switch section {
        case 0: return [.reviewsDatabase, .reviewsMemory, .reviewsNetwork]
        case 1: return [.menuLinkage]
        default: return []
        }
    }

    func title(for scenario: CYLQueryScenario) -> String {
        switch scenario {
        case .reviewsDatabase: return CYLExampleLocalizedString("评价筛选 · 数据库（SQLite）")
        case .reviewsMemory: return CYLExampleLocalizedString("评价筛选 · 内存")
        case .reviewsNetwork: return CYLExampleLocalizedString("评价筛选 · 网络")
        case .menuLinkage: return CYLExampleLocalizedString("分类菜单 + 多选筛选 · 数据库联动")
        }
    }

    func symbol(for scenario: CYLQueryScenario) -> String {
        switch scenario {
        case .reviewsDatabase: return "cylinder.split.1x2"
        case .reviewsMemory: return "memorychip"
        case .reviewsNetwork: return "network"
        case .menuLinkage: return "square.grid.3x2"
        }
    }

    /// The demo a row opens, with `hidesBottomBarWhenPushed`.
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
        }
        // A screen pushed from a tab hides the tab bar.
        controller.hidesBottomBarWhenPushed = true
        return controller
    }

    /// Pushes a demo, as tapping its row does.
    func open(_ scenario: CYLQueryScenario) {
        navigationController?.pushViewController(viewController(for: scenario), animated: false)
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 2 ? 3 : scenarios(inSection: section).count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return CYLExampleLocalizedString("场景：查询参数设置（多选）")
        case 1: return CYLExampleLocalizedString("场景：菜单选择（移植原 Demo）")
        default: return CYLExampleLocalizedString("数据库（SQLite）")
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0: return CYLExampleLocalizedString("淘宝评价默认显示全部；条件太多时，由用户多选输入筛选条件，标签列表就是为此而做。每次选择后按全部条件（AND）刷新列表。")
        case 1: return CYLExampleLocalizedString("原 Demo 只实现了筛选界面，没有筛选数据；现在每次选择都会生成 SQL、查询数据库并显示结果，选择也保存在数据库中。")
        default: return CYLExampleLocalizedString("每次启动时由 App 内的数据重新生成，selections 表保留各演示最后确认的条件。")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.scenarioCell, for: indexPath)
        var content: UIListContentConfiguration
        if indexPath.section == 2 {
            let table = ["reviews", "places", "selections"][indexPath.row]
            content = .valueCell()
            content.text = table
            content.textProperties.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
            content.secondaryText = CYLExampleLocalizedString("%ld 行", database.count(ofTable: table))
            cell.accessoryType = .none
            cell.selectionStyle = .none
        } else {
            let scenario = scenarios(inSection: indexPath.section)[indexPath.row]
            content = .cell()
            content.text = title(for: scenario)
            content.image = UIImage(systemName: symbol(for: scenario))
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        }
        cell.contentConfiguration = content
        return cell
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section < 2 {
            let scenario = scenarios(inSection: indexPath.section)[indexPath.row]
            navigationController?.pushViewController(viewController(for: scenario), animated: true)
        }
    }
}
