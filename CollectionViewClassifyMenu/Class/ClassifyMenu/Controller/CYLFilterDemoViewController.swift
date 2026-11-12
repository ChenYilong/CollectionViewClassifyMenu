//
//  CYLFilterDemoViewController.swift
//  CollectionViewClassifyMenu
//
//  The demo app's Filter tab: the multiple-choice filter (CYLMultipleFilterController) behind the left bar button,
//  sliding in from the left over most of the screen; the selected regions and dishes query the shared example
//  database (CYLDemoPlaces, the same SQLite file as the Android example), shown with the SQL and the rows. The selection is stored in the user defaults; selections
//  archived by older versions (CYLFilterParamsTool) are migrated once. The plus button's page, CYLDemoAboutViewController,
//  is here too.
//

import UIKit
import SQLite3
import CollectionViewClassifyMenu

/// A place of the shared example database.
struct CYLDemoPlace: Equatable {
    let name: String
    let category: String
    let tag: String
    let region: String
    let rating: Double
    let price: Int
}

/// A statement and its arguments (`CYLExampleSQLQuery` of the example, `ClassifySQLQuery` on Android).
struct CYLDemoSQLQuery: Equatable {
    let sql: String
    let arguments: [String]

    /// The statement with its arguments inlined and quoted, for display.
    func displayString() -> String {
        let parts = sql.components(separatedBy: "?")
        var result = ""
        for (index, part) in parts.enumerated() {
            result += part
            if index + 1 < parts.count {
                result += "'\((index < arguments.count ? arguments[index] : "").replacingOccurrences(of: "'", with: "''"))'"
            }
        }
        return result
    }
}

/// The shared example database of every platform, `Example-Shared/Database/cyl_places.sqlite` (made by
/// `scripts/generate-places-db.py` from data.json, bundled by this app and by the Android example), opened read-only.
enum CYLDemoPlaces {

    private static let handle: OpaquePointer? = {
        guard let path = Bundle.main.path(forResource: "cyl_places", ofType: "sqlite") else {
            NSLog("[CYLClassifyMenuDemo] cyl_places.sqlite is missing from the app")
            return nil
        }
        var db: OpaquePointer?
        guard sqlite3_open_v2(path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else {
            NSLog("[CYLClassifyMenuDemo] Cannot open %@", path)
            sqlite3_close(db)
            return nil
        }
        return db
    }()

    /// `+queryForTag:regions:dishes:` of the menu linkage: tag = ?, region IN (…), tag IN (…), by rating.
    static func query(tag: String?, regions: [String], dishes: [String]) -> CYLDemoSQLQuery {
        var conditions: [String] = []
        var arguments: [String] = []
        if let tag, !tag.isEmpty {
            conditions.append("tag = ?")
            arguments.append(tag)
        }
        for (column, values) in [("region", regions), ("tag", dishes)] where !values.isEmpty {
            conditions.append("\(column) IN (\(Array(repeating: "?", count: values.count).joined(separator: ", ")))")
            arguments.append(contentsOf: values)
        }
        var sql = "SELECT name, category, tag, region, rating, price FROM places"
        if !conditions.isEmpty {
            sql += " WHERE \(conditions.joined(separator: " AND "))"
        }
        return CYLDemoSQLQuery(sql: sql + " ORDER BY rating DESC, id", arguments: arguments)
    }

    /// The rows of `query`.
    static func rows(for query: CYLDemoSQLQuery) -> [CYLDemoPlace] {
        guard let handle else { return [] }
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(handle, query.sql, -1, &statement, nil) == SQLITE_OK else {
            NSLog("[CYLClassifyMenuDemo] %@: %s", query.sql, sqlite3_errmsg(handle))
            return []
        }
        defer { sqlite3_finalize(statement) }
        let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        for (index, argument) in query.arguments.enumerated() {
            sqlite3_bind_text(statement, Int32(index + 1), argument, -1, transient)
        }
        func text(_ column: Int32) -> String { sqlite3_column_text(statement, column).map { String(cString: $0) } ?? "" }
        var places: [CYLDemoPlace] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            places.append(CYLDemoPlace(name: text(0), category: text(1), tag: text(2), region: text(3),
                                       rating: sqlite3_column_double(statement, 4), price: Int(sqlite3_column_int(statement, 5))))
        }
        return places
    }

    /// Every place, by rating.
    static var all: [CYLDemoPlace] { rows(for: query(tag: nil, regions: [], dishes: [])) }

    /// The places in `regions` (any when empty) with a tag in `dishes` (any when empty).
    static func places(regions: [String], dishes: [String]) -> [CYLDemoPlace] {
        rows(for: query(tag: nil, regions: regions, dishes: dishes))
    }
}

@objc(CYLFilterDemoViewController)
final class CYLFilterDemoViewController: UIViewController {

    static let filterSelectionKey = "CYLDemoFilterSelection"

    var filterSource: CYLMenuDataSource?

    /// The conditions (empty for "全部") and the matching places.
    private(set) var selectedRegions: [String] = []

    private(set) var selectedDishes: [String] = []

    private(set) var results: [CYLDemoPlace] = []

    /// The last statement (shown with its rows, as on Android).
    private(set) var lastQuery = CYLDemoPlaces.query(tag: nil, regions: [], dishes: [])

    private(set) var statusLabel = UILabel()

    private let resultsStack = UIStackView()

    private var storedFilterController: CYLMultipleFilterController?

    var filterController: CYLMultipleFilterController {
        if let controller = storedFilterController {
            return controller
        }
        let controller = CYLMultipleFilterController()
        controller.delegate = self
        controller.menuDataSource = filterSource
        controller.menuDelegate = self
        controller.loadViewIfNeeded()
        storedFilterController = controller
        if let stored = UserDefaults.standard.array(forKey: Self.filterSelectionKey) ?? legacyFilterSelection() {
            if let paths = validatedSelection(stored) {
                controller.setSelectedIndexPaths(paths)
            } else {
                NSLog("Cannot restore demo filter settings: invalid selection.")
            }
        }
        return controller
    }

    func legacyFilterSelection() -> [Any]? {
        guard let filename = CYLFilterParamsTool().filename, FileManager.default.fileExists(atPath: filename) else {
            return nil
        }
        let data: Data
        do {
            data = try Data(contentsOf: URL(fileURLWithPath: filename))
        } catch {
            NSLog("Cannot read existing demo filter settings: %@", error.localizedDescription)
            return nil
        }
        guard let result = selection(fromLegacyArchiveData: data) else {
            return nil
        }
        UserDefaults.standard.set(result, forKey: Self.filterSelectionKey)
        return result
    }

    /// The [section, item] pairs of the selected items of a legacy CYLFilterParamsTool archive, nil when it cannot
    /// be read or does not match the filter's sections and items.
    func selection(fromLegacyArchiveData data: Data) -> [[Int]]? {
        let archive: Any?
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            // Legacy archives were written without secure coding.
            unarchiver.requiresSecureCoding = false
            archive = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey)
            unarchiver.finishDecoding()
        } catch {
            NSLog("Cannot decode existing demo filter settings: %@", error.localizedDescription)
            return nil
        }
        guard let tool = archive as? CYLFilterParamsTool else {
            NSLog("Cannot migrate existing demo filter settings: unexpected archive type")
            return nil
        }
        guard let filterSource, let sections = tool.filterParamsArray as? [Any],
              sections.count == filterSource.numberOfSectionsInMenu() else {
            NSLog("Cannot migrate existing demo filter settings: section count changed.")
            return nil
        }
        var result: [[Int]] = []
        for (section, value) in sections.enumerated() {
            guard let states = value as? [Any], states.count == filterSource.menuNumberOfItems(inSection: section) else {
                NSLog("Cannot migrate existing demo filter settings: item count changed in section %ld.", section)
                return nil
            }
            for (item, state) in states.enumerated() {
                guard let number = state as? NSNumber else {
                    NSLog("Cannot migrate existing demo filter settings: invalid item state.")
                    return nil
                }
                if number.boolValue {
                    result.append([section, item])
                }
            }
        }
        guard validatedSelection(result) != nil else {
            NSLog("Cannot migrate existing demo filter settings: conflicting selection.")
            return nil
        }
        return result
    }

    /// The index paths of stored [section, item] pairs, nil when one is malformed, out of range, or conflicts
    /// with an exclusive item of its section.
    func validatedSelection(_ stored: [Any]) -> [IndexPath]? {
        guard let filterSource else { return nil }
        var paths: [IndexPath] = []
        var exclusiveSections = IndexSet()
        var otherSections = IndexSet()
        for value in stored {
            guard let pair = value as? [Any], pair.count == 2,
                  let sectionNumber = pair[0] as? NSNumber, let itemNumber = pair[1] as? NSNumber else {
                return nil
            }
            let section = sectionNumber.intValue, item = itemNumber.intValue
            guard section >= 0, item >= 0, section < filterSource.numberOfSectionsInMenu(),
                  item < filterSource.menuNumberOfItems(inSection: section) else {
                return nil
            }
            let path = IndexPath(item: item, section: section)
            let exclusive = filterSource.menuItemIsExclusive?(at: path) ?? false
            if (exclusive && (exclusiveSections.contains(section) || otherSections.contains(section)))
                || (!exclusive && exclusiveSections.contains(section)) {
                return nil
            }
            if exclusive {
                exclusiveSections.insert(section)
            } else {
                otherSections.insert(section)
            }
            paths.append(path)
        }
        return paths
    }

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        if filterSource == nil {
            filterSource = CYLDemoDataSource.filterDataSource()
        }
        navigationItem.title = CYLDemoLocalizedString("多选筛选")
        view.backgroundColor = .systemGroupedBackground
        let hint = UILabel()
        hint.numberOfLines = 0
        hint.font = .preferredFont(forTextStyle: .footnote)
        hint.adjustsFontForContentSizeCategory = true
        hint.textColor = .secondaryLabel
        hint.text = CYLDemoLocalizedString("点左上角按钮从左侧打开筛选，多选地区与菜品后确认，下方列出符合条件的商家。")
        statusLabel.numberOfLines = 0
        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.adjustsFontForContentSizeCategory = true
        statusLabel.textColor = .secondaryLabel
        resultsStack.axis = .vertical
        resultsStack.spacing = 1
        resultsStack.backgroundColor = .separator
        let stack = UIStackView(arrangedSubviews: [hint, statusLabel, resultsStack])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.addSubview(stack)
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -16),
        ])
        initWithRightNavItem()
        applyFilterSelection(filterController.selectedIndexPaths() ?? [])
    }

    func initWithRightNavItem() {
        let item = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(rightBarButtonClicked(_:)))
        item.title = CYLDemoLocalizedString("重置筛选条件")
        item.accessibilityHint = CYLDemoLocalizedString("清除所有已选标签")
        Self.removeGlassBubble(from: item)
        navigationItem.rightBarButtonItem = item
    }

    func initLeftBarButtonItem() {
        let modified = (filterController.selectedIndexPaths() ?? []).contains { $0.item != 0 }
        let name = modified
            ? "navigationbar_leftBarButtonItem_itis_multiple_choice_filter_params_modified"
            : "navigationbar_leftBarButtonItem_itis_multiple_choice_filter_params_normal"
        let image = CYLMenuResources.imageNamed(name)?.withRenderingMode(.alwaysOriginal)
        let item = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(leftBarButtonClicked(_:)))
        item.accessibilityLabel = CYLDemoLocalizedString("筛选条件")
        Self.removeGlassBubble(from: item)
        navigationItem.leftBarButtonItem = item
    }

    /// On iOS 26 and later a bar button sits in a light Liquid Glass bubble, which hides the white icons and titles of
    /// this tint-colored bar: show them on the bar itself.
    static func removeGlassBubble(from item: UIBarButtonItem) {
        if #available(iOS 26.0, *) {
            item.hidesSharedBackground = true
        }
    }

    @objc func rightBarButtonClicked(_ sender: Any?) {
        let filter = filterController
        filter.reloadMenuData()
        menu(filter, didConfirmSelectedItems: filter.selectedIndexPaths() ?? [])
        filterControllerDidComplete(nil)
    }

    /// The filter slides in from the left over the whole screen, tab bar included.
    @objc func leftBarButtonClicked(_ sender: Any?) {
        let filter = filterController
        filter.refreshFilterParams()
        filter.show(in: tabBarController?.view ?? navigationController?.view ?? view)
    }

    /// Regions and dishes from the filter's selection (section 0 and 1, without the exclusive "全部").
    func applyFilterSelection(_ indexPaths: [IndexPath]) {
        guard let filterSource else { return }
        var regions: [String] = []
        var dishes: [String] = []
        for indexPath in indexPaths where !(filterSource.menuItemIsExclusive?(at: indexPath) ?? false) {
            let title = filterSource.menuTitleForItem(at: indexPath)
            if indexPath.section == 0 {
                regions.append(title)
            } else {
                dishes.append(title)
            }
        }
        selectedRegions = regions
        selectedDishes = dishes
        lastQuery = CYLDemoPlaces.query(tag: nil, regions: regions, dishes: dishes)
        results = CYLDemoPlaces.rows(for: lastQuery)
        initLeftBarButtonItem()
        showResults()
    }

    private func showResults() {
        let all = CYLDemoLocalizedString("全部")
        let separator = CYLDemoLocalizedString("、")
        func names(_ values: [String]) -> String {
            values.isEmpty ? all : values.map(CYLDemoDataSource.shortTitle(forTitle:)).joined(separator: separator)
        }
        statusLabel.text = [
            CYLDemoLocalizedString("分类：%@ · 地区：%@ · 菜品：%@", all, names(selectedRegions), names(selectedDishes)),
            lastQuery.displayString(),
            CYLDemoLocalizedString("SQLite 返回 %ld 条（共 %ld 家）", results.count, CYLDemoPlaces.all.count),
        ].joined(separator: "\n")
        for view in resultsStack.arrangedSubviews {
            view.removeFromSuperview()
        }
        if results.isEmpty {
            resultsStack.addArrangedSubview(rowLabel(title: CYLDemoLocalizedString("没有符合条件的商家"), detail: nil))
        }
        for place in results {
            let detail = String(format: "%@ · %@ · %@ · ★%.1f · ¥%ld", place.category, CYLDemoDataSource.shortTitle(forTitle: place.tag),
                                CYLDemoDataSource.shortTitle(forTitle: place.region), place.rating, place.price)
            resultsStack.addArrangedSubview(rowLabel(title: place.name, detail: detail))
        }
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

extension CYLFilterDemoViewController: CYLFilterControllerDelegate, CYLMenuDelegate {

    func filterControllerDidComplete(_ controller: CYLFilterBaseController?) {
        initLeftBarButtonItem()
    }

    func menu(_ menu: Any, didConfirmSelectedItems indexPaths: [IndexPath]) {
        let stored = indexPaths.map { [$0.section, $0.item] }
        UserDefaults.standard.set(stored, forKey: Self.filterSelectionKey)
        applyFilterSelection(indexPaths)
    }
}

/// The plus button's page: what the demo shows.
@objc(CYLDemoAboutViewController)
final class CYLDemoAboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = CYLDemoLocalizedString("关于")
        view.backgroundColor = .systemBackground
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.text = CYLDemoLocalizedString("CollectionViewClassifyMenu 演示：分类标签页是单选可折叠菜单，筛选标签页是多选筛选；数据来自 data.json。")
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
}
