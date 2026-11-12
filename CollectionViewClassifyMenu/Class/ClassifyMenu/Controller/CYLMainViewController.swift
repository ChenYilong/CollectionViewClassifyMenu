//
//  CYLMainViewController.swift
//  CollectionViewClassifyMenu
//
//  Created by https://github.com/ChenYilong on 15/4/26.
//  Copyright (c)  http://weibo.com/luohanchenyilong/ . All rights reserved.
//
//  The demo app's screen: the classify menu (data.json) with a header that switches between one and two
//  default rows, and the multiple-choice filter behind the left bar button. The filter selection is stored in
//  the user defaults; selections archived by older versions (CYLFilterParamsTool) are migrated once.
//

import UIKit
import CollectionViewClassifyMenu

@objc(CYLMainViewController)
final class CYLMainViewController: CYLClassifyMenuViewController {

    /// The user defaults key of the stored filter selection: an array of [section, item] pairs.
    static let filterSelectionKey = "CYLDemoFilterSelection"

    /// The data of the classify menu.
    var classifySource: CYLMenuDataSource?
    /// The data of the filter (an exclusive "全部" first in every section).
    var filterSource: CYLMenuDataSource?
    private(set) var titleLabel: UILabel?
    private(set) var rowsCountBydefaultSwitch: UISwitch?

    // MARK: Lazy load

    private var storedFilterController: CYLMultipleFilterController?

    /// The filter, created on first use with the stored (or migrated) selection.
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

    /// The selection archived by older versions of the demo, migrated to the user defaults.
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
        let classifySource = CYLDemoDataSource.classifyDataSource()
        self.classifySource = classifySource
        if filterSource == nil {
            filterSource = CYLDemoDataSource.filterDataSource()
        }
        menuDataSource = classifySource
        menuDelegate = self
        menuHeaderView = makeDemoHeaderView()
        super.viewDidLoad()
        initLeftBarButtonItem()
        initWithRightNavItem()
    }

    func makeDemoHeaderView() -> UIView {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 90))
        header.autoresizingMask = .flexibleWidth
        header.backgroundColor = .white

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.adjustsFontSizeToFitWidth = true
        title.minimumScaleFactor = 0.7
        title.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: .boldSystemFont(ofSize: 18))
        title.adjustsFontForContentSizeCategory = true
        title.accessibilityTraits = .header
        title.textColor = UIColor(red: 42 / 255.0, green: 185 / 255.0, blue: 160 / 255.0, alpha: 1)
        titleLabel = title
        header.addSubview(title)

        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(rowsCountBydefaultSwitchClicked(_:)), for: .valueChanged)
        toggle.accessibilityLabel = CYLDemoLocalizedString("默认显示两行")
        rowsCountBydefaultSwitch = toggle
        header.addSubview(toggle)

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.adjustsFontSizeToFitWidth = true
        subtitle.minimumScaleFactor = 0.7
        subtitle.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: .systemFont(ofSize: 12))
        subtitle.adjustsFontForContentSizeCategory = true
        subtitle.textColor = .secondaryLabel
        subtitle.text = CYLDemoLocalizedString("超出默认行数,出现\"更多\"按钮,点击展开.@iOS程序犭袁 出品")
        header.addSubview(subtitle)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            title.centerYAnchor.constraint(equalTo: toggle.centerYAnchor),
            title.trailingAnchor.constraint(lessThanOrEqualTo: toggle.leadingAnchor, constant: -8),
            toggle.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            toggle.topAnchor.constraint(equalTo: header.topAnchor, constant: 20),
            subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            subtitle.topAnchor.constraint(equalTo: toggle.bottomAnchor, constant: 8),
        ])
        rowsCountBydefaultSwitchClicked(toggle)
        return header
    }

    @objc func rowsCountBydefaultSwitchClicked(_ sender: UISwitch) {
        defaultVisibleRows = sender.isOn ? 2 : 1
        let title = sender.isOn ? CYLDemoLocalizedString("默认显示两行时的效果如下所示:") : CYLDemoLocalizedString("默认显示一行时的效果如下所示:")
        let highlight = sender.isOn ? CYLDemoLocalizedString("两行") : CYLDemoLocalizedString("一行")
        let text = NSMutableAttributedString(string: title)
        // The row count stands out in every language (found by text, not by a fixed range).
        let range = (title as NSString).range(of: highlight)
        if range.location != NSNotFound {
            text.addAttribute(.foregroundColor, value: UIColor.systemRed, range: range)
        }
        titleLabel?.attributedText = text
    }

    func initWithRightNavItem() {
        let item = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(rightBarButtonClicked(_:)))
        item.title = CYLDemoLocalizedString("重置筛选条件")
        item.accessibilityHint = CYLDemoLocalizedString("清除所有已选标签")
        navigationItem.rightBarButtonItem = item
    }

    /// The left bar button: the filter, highlighted when a selection other than "全部" is set.
    func initLeftBarButtonItem() {
        let modified = (filterController.selectedIndexPaths() ?? []).contains { $0.item != 0 }
        let name = modified
            ? "navigationbar_leftBarButtonItem_itis_multiple_choice_filter_params_modified"
            : "navigationbar_leftBarButtonItem_itis_multiple_choice_filter_params_normal"
        let image = CYLMenuResources.imageNamed(name)?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(leftBarButtonClicked(_:)))
    }

    // MARK: Actions

    @objc func rightBarButtonClicked(_ sender: Any?) {
        let filter = filterController
        filter.reloadMenuData()
        menu(filter, didConfirmSelectedItems: filter.selectedIndexPaths() ?? [])
        initLeftBarButtonItem()
        filterControllerDidComplete(nil)
    }

    @objc func leftBarButtonClicked(_ sender: Any?) {
        let filter = filterController
        filter.refreshFilterParams()
        filter.show(in: navigationController?.view ?? view)
    }
}

// MARK: - CYLFilterControllerDelegate, CYLMenuDelegate

extension CYLMainViewController: CYLFilterControllerDelegate, CYLMenuDelegate {

    func filterControllerDidComplete(_ controller: CYLFilterBaseController?) {
        initLeftBarButtonItem()
    }

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        if (menu as AnyObject) === self, let classifySource {
            navigationItem.title = classifySource.menuTitleForItem(at: indexPath)
        }
    }

    func menu(_ menu: Any, didConfirmSelectedItems indexPaths: [IndexPath]) {
        let stored = indexPaths.map { [$0.section, $0.item] }
        UserDefaults.standard.set(stored, forKey: Self.filterSelectionKey)
    }
}
