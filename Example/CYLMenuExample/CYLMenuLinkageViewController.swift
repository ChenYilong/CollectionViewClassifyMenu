//
//  CYLMenuLinkageViewController.swift
//  CYLMenuExample
//
//  分类菜单 + 多选筛选 · 数据库联动：the original app's classify menu (single choice) and its
//  multiple-choice filter (regions and dishes) drive one SQL query on CYLExampleDatabase's `places`.
//  Both selections are saved in the database and restored on the next visit.
//

import UIKit
import CollectionViewClassifyMenu

/// Keys of the selections saved in CYLExampleDatabase.
let CYLMenuLinkageClassifyScenario = "menu.classify"
let CYLMenuLinkageFilterScenario = "menu.filter"

final class CYLMenuLinkageViewController: CYLClassifyMenuViewController {

    let database: CYLExampleDatabase
    /// The original app's data sources (CYLDemoDataSource, shared with the demo app).
    let classifySource = CYLDemoDataSource.classifyDataSource()
    let filterSource = CYLDemoDataSource.filterDataSource()

    /// The conditions: the classify menu's tag (nil for every tag), and the filter's regions and dishes
    /// (empty for "全部").
    private(set) var selectedTag: String?
    private(set) var selectedRegions: [String] = []
    private(set) var selectedDishes: [String] = []
    /// The last statement and its rows (name, category, tag, region, rating, price).
    private(set) var lastQuery = CYLMenuLinkageViewController.query(forTag: nil, regions: [], dishes: [])
    private(set) var results: [[String: Any]] = []
    /// Conditions, SQL and number of results, shown above the results.
    private(set) var statusLabel = UILabel()
    private let resultsStack = UIStackView()

    init(database: CYLExampleDatabase) {
        self.database = database
        super.init(nibName: nil, bundle: nil)
    }

    /// On CYLExampleDatabase.shared().
    convenience init() {
        self.init(database: CYLExampleDatabase.shared())
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // MARK: Life cycle

    override func viewDidLoad() {
        menuDataSource = classifySource
        menuDelegate = self
        defaultVisibleRows = 2
        menuHeaderView = makeHeaderView()
        menuFooterView = makeFooterView()
        super.viewDidLoad()
        // navigationItem, not title: CYLClassifyMenuViewController sets its own title.
        navigationItem.title = CYLExampleLocalizedString("菜单选择 · 数据库联动")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: CYLExampleLocalizedString("重置"), style: .plain,
                                                            target: self, action: #selector(resetConditions))
        restoreSavedSelection()
        runQuery()
    }

    private func makeHeaderView() -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 52))
        label.autoresizingMask = .flexibleWidth
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.textColor = .secondaryLabel
        label.backgroundColor = .systemBackground
        label.text = "  \(CYLExampleLocalizedString("点按分类标签（单选），左上角按钮多选地区与菜品"))\n"
            + "  \(CYLExampleLocalizedString("每次选择 → 生成 SQL → SQLite 查询 → 刷新下方结果"))"
        return label
    }

    private func makeFooterView() -> UIView {
        statusLabel.numberOfLines = 0
        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.adjustsFontForContentSizeCategory = true
        statusLabel.textColor = .secondaryLabel

        resultsStack.axis = .vertical
        resultsStack.spacing = 1
        resultsStack.backgroundColor = .separator

        let stack = UIStackView(arrangedSubviews: [statusLabel, resultsStack])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 16, trailing: 16)
        let footer = UIView()
        footer.backgroundColor = .secondarySystemBackground
        footer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: footer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: footer.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: footer.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: footer.bottomAnchor),
        ])
        return footer
    }

    // MARK: Filter

    private(set) lazy var filterController: CYLMultipleFilterController = {
        let controller = CYLMultipleFilterController()
        controller.delegate = self
        controller.menuDataSource = self.filterSource
        controller.menuDelegate = self
        controller.loadViewIfNeeded()
        return controller
    }()

    private func updateFilterButton() {
        let modified = !selectedRegions.isEmpty || !selectedDishes.isEmpty
        let name = modified ? "navigationbar_leftBarButtonItem_itis_multiple_choice_filter_params_modified"
                            : "navigationbar_leftBarButtonItem_itis_multiple_choice_filter_params_normal"
        let image = CYLMenuResources.image(named: name)?.withRenderingMode(.alwaysOriginal)
        let item = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(showFilter))
        item.accessibilityLabel = CYLExampleLocalizedString("多选筛选")
        item.accessibilityValue = modified ? CYLExampleLocalizedString("已修改") : nil
        navigationItem.leftBarButtonItem = item
    }

    /// Opens the multiple-choice filter, as the left bar button does.
    @objc func showFilter() {
        filterController.refreshFilterParams()
        filterController.show(in: navigationController?.view ?? view)
    }

    /// As choosing these filter items and tapping the filter's OK button.
    func confirmFilterSelection(_ indexPaths: [IndexPath]) {
        filterController.setSelectedIndexPaths(indexPaths)
        applyFilterSelection(filterController.selectedIndexPaths() ?? [], save: true)
    }

    /// Regions and dishes from the filter's selection: section 0 and 1, without the exclusive "全部".
    private func applyFilterSelection(_ indexPaths: [IndexPath], save: Bool) {
        var regions: [String] = []
        var dishes: [String] = []
        for indexPath in indexPaths where !filterSource.menuItemIsExclusive(at: indexPath) {
            let title = filterSource.menuTitleForItem(at: indexPath)
            if indexPath.section == 0 {
                regions.append(title)
            } else {
                dishes.append(title)
            }
        }
        selectedRegions = regions
        selectedDishes = dishes
        if save {
            database.saveSelection(indexPaths, forScenario: CYLMenuLinkageFilterScenario)
        }
        runQuery()
    }

    // MARK: Classify menu

    /// As a tap on the classify menu: selects the tag, or clears it when it is already selected.
    func selectClassifyItem(at indexPath: IndexPath) {
        let deselect = selectedIndexPath == indexPath
        selectedIndexPath = deselect ? nil : indexPath
        selectedTag = deselect ? nil : classifySource.menuTitleForItem(at: indexPath)
        database.saveSelection(selectedIndexPath.map { [$0] } ?? [], forScenario: CYLMenuLinkageClassifyScenario)
        runQuery()
    }

    /// Every tag, every region and dish ("重置筛选条件").
    @objc func resetConditions() {
        selectedIndexPath = nil
        selectedTag = nil
        database.saveSelection([], forScenario: CYLMenuLinkageClassifyScenario)
        let all = (0..<filterSource.numberOfSectionsInMenu()).map { IndexPath(item: 0, section: $0) }
        confirmFilterSelection(all)
    }

    private func contains(_ indexPath: IndexPath, in source: CYLDemoDataSource) -> Bool {
        indexPath.section < source.numberOfSectionsInMenu() && indexPath.item < source.menuNumberOfItems(inSection: indexPath.section)
    }

    /// Whether CYLMultipleFilterController accepts the selection (it raises an Objective-C exception, which
    /// Swift cannot catch, for an exclusive item such as "全部" together with another item of its section).
    private func isValidFilterSelection(_ indexPaths: [IndexPath]) -> Bool {
        var exclusiveSections = Set<Int>()
        var otherSections = Set<Int>()
        for indexPath in indexPaths {
            let exclusive = filterSource.menuItemIsExclusive(at: indexPath)
            if exclusive ? (exclusiveSections.contains(indexPath.section) || otherSections.contains(indexPath.section))
                         : exclusiveSections.contains(indexPath.section) {
                return false
            }
            if exclusive {
                exclusiveSections.insert(indexPath.section)
            } else {
                otherSections.insert(indexPath.section)
            }
        }
        return true
    }

    /// The selections saved in the database by the last visit, if they still fit the menus.
    private func restoreSavedSelection() {
        if let classify = database.savedSelection(forScenario: CYLMenuLinkageClassifyScenario)?.first,
           contains(classify, in: classifySource) {
            selectedIndexPath = classify
            selectedTag = classifySource.menuTitleForItem(at: classify)
        }
        let filter = (database.savedSelection(forScenario: CYLMenuLinkageFilterScenario) ?? []).filter { contains($0, in: filterSource) }
        if !filter.isEmpty {
            if isValidFilterSelection(filter) {
                filterController.setSelectedIndexPaths(filter)
            } else {
                // A selection saved for other filter data ("全部" with another item): start over.
                NSLog("[CYLMenuExample] Ignoring the saved filter selection: %@", filter.description)
                filterController.reloadMenuData()
            }
        }
        applyFilterSelection(filterController.selectedIndexPaths() ?? [], save: false)
    }

    // MARK: Query

    static func query(forTag tag: String?, regions: [String], dishes: [String]) -> CYLExampleSQLQuery {
        var conditions: [String] = []
        var arguments: [Any] = []
        if let tag, !tag.isEmpty {
            conditions.append("tag = ?")
            arguments.append(tag)
        }
        for (column, values) in [("region", regions), ("tag", dishes)] where !values.isEmpty {
            conditions.append("\(column) IN (\(Array(repeating: "?", count: values.count).joined(separator: ", ")))")
            arguments.append(contentsOf: values as [Any])
        }
        var sql = "SELECT name, category, tag, region, rating, price FROM places"
        if !conditions.isEmpty {
            sql += " WHERE \(conditions.joined(separator: " AND "))"
        }
        return CYLExampleSQLQuery(sql: sql + " ORDER BY rating DESC, id", arguments: arguments)
    }

    private func runQuery() {
        let query = Self.query(forTag: selectedTag, regions: selectedRegions, dishes: selectedDishes)
        lastQuery = query
        do {
            results = try database.rows(for: query)
        } catch {
            NSLog("[CYLMenuExample] %@: %@", query.sql, error.localizedDescription)
            results = []
        }
        updateFilterButton()
        showResults()
    }

    private func showResults() {
        let all = CYLExampleLocalizedString("全部")
        let separator = CYLExampleLocalizedString("、")
        func names(_ values: [String]) -> String {
            values.isEmpty ? all : values.map(CYLDemoDataSource.shortTitle(forTitle:)).joined(separator: separator)
        }
        let lines = [
            CYLExampleLocalizedString("分类：%@ · 地区：%@ · 菜品：%@",
                                      selectedTag.map(CYLDemoDataSource.shortTitle(forTitle:)) ?? all, names(selectedRegions), names(selectedDishes)),
            lastQuery.displayString(),
            CYLExampleLocalizedString("SQLite 返回 %lu 条（共 %ld 家）", UInt(results.count), database.countOfTable("places")),
        ]
        statusLabel.text = lines.joined(separator: "\n")

        for view in resultsStack.arrangedSubviews {
            view.removeFromSuperview()
        }
        if results.isEmpty {
            resultsStack.addArrangedSubview(rowLabel(title: CYLExampleLocalizedString("没有符合条件的商家"), detail: nil))
        }
        for row in results {
            let rating = (row["rating"] as? NSNumber)?.doubleValue ?? 0
            let detail = String(format: "%@ · %@ · %@ · ★%.1f · ¥%@",
                                "\(row["category"] ?? "")",
                                CYLDemoDataSource.shortTitle(forTitle: row["tag"] as? String ?? ""),
                                CYLDemoDataSource.shortTitle(forTitle: row["region"] as? String ?? ""),
                                rating, "\(row["price"] ?? "")")
            resultsStack.addArrangedSubview(rowLabel(title: row["name"] as? String ?? "", detail: detail))
        }
        updateMenuLayout()
    }

    private func rowLabel(title: String, detail: String?) -> UILabel {
        let text = NSMutableAttributedString(string: title, attributes: [
            .font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: UIColor.label])
        if let detail {
            text.append(NSAttributedString(string: "\n" + detail, attributes: [
                .font: UIFont.preferredFont(forTextStyle: .footnote), .foregroundColor: UIColor.secondaryLabel]))
        }
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = text
        label.adjustsFontForContentSizeCategory = true
        label.backgroundColor = .systemBackground
        label.isAccessibilityElement = true
        return label
    }
}

// MARK: - CYLMenuDelegate

extension CYLMenuLinkageViewController: CYLMenuDelegate {

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        if (menu as AnyObject) === self {
            selectClassifyItem(at: indexPath)
        }
    }

    func menu(_ menu: Any, didConfirmSelectedItems indexPaths: [IndexPath]) {
        if (menu as AnyObject) === filterController {
            applyFilterSelection(indexPaths, save: true)
        }
    }
}

// MARK: - CYLFilterControllerDelegate

extension CYLMenuLinkageViewController: CYLFilterControllerDelegate {

    func filterControllerDidComplete(_ controller: CYLFilterBaseController) {
        updateFilterButton()
    }
}
