//
//  CYLFilterDemoViewController.swift
//  CollectionViewClassifyMenu
//
//  The demo app's Filter tab: the multiple-choice filter (CYLMultipleFilterController) behind the left bar button,
//  sliding in from the left over most of the screen, with the places of the demo data (CYLDemoPlaces) that match
//  the selected regions and dishes listed on the page. The selection is stored in the user defaults; selections
//  archived by older versions (CYLFilterParamsTool) are migrated once. The plus button's page, CYLDemoAboutViewController,
//  is here too.
//

import UIKit
import CollectionViewClassifyMenu

/// The places of the demo data: every tag of data.json in some of the filter's regions, made as the example's
/// database makes its `places` table (CYLMenuExample's CYLExampleDatabase), so all demos show the same places.
struct CYLDemoPlace: Equatable {
    let name: String
    let category: String
    let tag: String
    let region: String
    let rating: Double
    let price: Int
}

enum CYLDemoPlaces {

    /// All places, sorted by rating (highest first), then in creation order.
    static let all: [CYLDemoPlace] = {
        var places: [(Int, CYLDemoPlace)] = []
        var tagIndex = 0
        for category in CYLDBManager.dataSource() {
            let type = category[CYLDemoDataSource.sectionTitleKey] as? String ?? ""
            for item in category[kDataSourceSectionKey] as? [[String: Any]] ?? [] {
                let tag = item[kDataSourceCellTextKey] as? String ?? ""
                for (region, regionName) in CYLDemoDataSource.regions().enumerated() where (tagIndex + region) % 3 != 2 {
                    let place = CYLDemoPlace(
                        name: "\(CYLDemoDataSource.shortTitle(forTitle: tag)) · \(CYLDemoDataSource.shortTitle(forTitle: regionName))",
                        category: type, tag: tag, region: regionName,
                        rating: 3.5 + Double((tagIndex * 7 + region * 3) % 16) / 10.0,
                        price: 30 + ((tagIndex * 37 + region * 53) % 270))
                    places.append((places.count, place))
                }
                tagIndex += 1
            }
        }
        return places.sorted { $0.1.rating != $1.1.rating ? $0.1.rating > $1.1.rating : $0.0 < $1.0 }.map(\.1)
    }()

    /// The places in `regions` (any when empty) with a tag in `dishes` (any when empty).
    static func places(regions: [String], dishes: [String]) -> [CYLDemoPlace] {
        all.filter { (regions.isEmpty || regions.contains($0.region)) && (dishes.isEmpty || dishes.contains($0.tag)) }
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
        results = CYLDemoPlaces.places(regions: regions, dishes: dishes)
        initLeftBarButtonItem()
        showResults()
    }

    private func showResults() {
        let all = CYLDemoLocalizedString("全部")
        let separator = CYLDemoLocalizedString("、")
        func names(_ values: [String]) -> String {
            values.isEmpty ? all : values.map(CYLDemoDataSource.shortTitle(forTitle:)).joined(separator: separator)
        }
        statusLabel.text = CYLDemoLocalizedString("地区：%@ · 菜品：%@ · 共 %ld / %ld 家", names(selectedRegions), names(selectedDishes),
                                                  results.count, CYLDemoPlaces.all.count)
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
