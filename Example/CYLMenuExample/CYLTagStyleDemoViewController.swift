//
//  CYLTagStyleDemoViewController.swift
//  CYLMenuExample
//
//  样式演示（参照 CYLTabBarController 的 CYLFlatDesignTabBarDemoViewController）：上方为标签预览，
//  下方列表的每一行修改一个样式参数，点击后立即生效。标签的标题与图标参数参照
//  CYLFlatDesignTabBarItem，背景、边框、圆角参照 CYLBadgeView。
//

import UIKit
import CollectionViewClassifyMenu

@objc enum CYLTagStyleDemoContent: Int {
    case iconAndTitle = 0
    case iconOnly
    case titleOnly
}

final class CYLTagStyleDemoViewController: UIViewController {

    private static let styleCell = "StyleCell"

    private(set) var tagListView: CYLTagListView!
    private(set) var tableView: UITableView!
    /// The style being edited; applied to the preview after every action.
    private(set) var style: CYLMenuStyle = CYLTagStyleDemoViewController.demoStyle()
    private(set) var content: CYLTagStyleDemoContent = .iconAndTitle
    /// "lottie", "gif", "pag", "rive", or nil for static icons.
    private(set) var animationLibrary: String?
    private(set) var usesSelectedImage = true
    private var menuSource: CYLExampleMenuSource?
    private var previewHeight: NSLayoutConstraint!
    /// How many times each action ran, to cycle through its values.
    private var steps: [String: Int] = [:]

    // MARK: Actions

    /// Identifiers of the actions, in table order (e.g. "iconColor.normal", "cornerRadius").
    func actionIdentifiers() -> [[String]] {
        [
            ["iconColor.normal", "iconColor.selected", "titleColor.normal", "titleColor.selected", "font",
             "imageTitleSpacing", "imageSize", "imageInsets", "titlePositionAdjustment", "imagePositionAdjustment",
             "content.iconAndTitle", "content.iconOnly", "content.titleOnly", "layoutCentered", "selectedImage"],
            ["backgroundColor.normal", "backgroundColor.selected", "borderColor", "borderWidth", "cornerRadius", "margin"],
            ["animation.lottie", "animation.pag", "animation.rive", "animation.gif", "animation.off", "animationSpeed", "configuration"],
            ["reset"],
        ]
    }

    func title(forSection section: Int) -> String {
        [CYLExampleLocalizedString("标题与图标（参照 CYLFlatDesignTabBarItem）"),
         CYLExampleLocalizedString("背景、边框与圆角（参照 CYLBadgeView）"),
         CYLExampleLocalizedString("动效图标（CYLTabBarController 动效引擎）"),
         CYLExampleLocalizedString("其它")][section]
    }

    /// The localization keys of the action titles.
    private static let actionTitles: [String: String] = [
        "iconColor.normal": "设置 iconColor（normal）",
        "iconColor.selected": "设置 iconColor（selected）",
        "titleColor.normal": "设置文字颜色 titleTextAttributes（normal）",
        "titleColor.selected": "设置文字颜色 titleTextAttributes（selected）",
        "font": "设置字体 NSFontAttributeName",
        "imageTitleSpacing": "设置 icon 与文字间距 imageTitleSpacing",
        "imageSize": "设置 icon 大小 imageSize",
        "imageInsets": "设置 imageInsets",
        "titlePositionAdjustment": "设置 titlePositionAdjustment",
        "imagePositionAdjustment": "设置 imagePositionAdjustment",
        "content.iconAndTitle": "显示 icon + title",
        "content.iconOnly": "只显示 icon",
        "content.titleOnly": "只显示 title",
        "layoutCentered": "切换 layoutCentered（只有 icon 或 title 时居中）",
        "selectedImage": "切换选中图片 selectedImage",
        "backgroundColor.normal": "设置背景色 backgroundColor（normal）",
        "backgroundColor.selected": "设置背景色 backgroundColor（selected）",
        "borderColor": "设置边框颜色 borderColor",
        "borderWidth": "设置边框宽度 borderWidth",
        "cornerRadius": "设置圆角 cornerRadius（0 为胶囊）",
        "margin": "设置内边距 margin",
        "animation.lottie": "Lottie 动效图标",
        "animation.pag": "PAG 动效图标",
        "animation.rive": "Rive 动效图标",
        "animation.gif": "GIF 动效图标",
        "animation.off": "关闭动效（静态图标）",
        "animationSpeed": "设置动效速度 animationSpeed",
        "configuration": "配置文件 / 字典（map）初始化",
        "reset": "重置 reset",
    ]

    func title(forAction identifier: String) -> String {
        CYLExampleLocalizedString(Self.actionTitles[identifier] ?? identifier)
    }

    /// A fixed palette, so that screenshots are stable.
    func color(atStep step: Int) -> UIColor {
        let palette: [UIColor] = [.systemOrange, .systemPurple, .systemTeal, .systemPink, .systemIndigo, .systemGreen]
        return palette[step % palette.count]
    }

    func lightColor(atStep step: Int) -> UIColor {
        color(atStep: step).withAlphaComponent(0.15)
    }

    private func nextStep(for identifier: String) -> Int {
        let step = steps[identifier] ?? 0
        steps[identifier] = step + 1
        return step
    }

    private var appearances: [CYLTagAppearance] {
        [style.normalAppearance, style.selectedAppearance, style.disabledAppearance]
    }

    /// Performs an action as a tap on its row does.
    func performAction(_ identifier: String) {
        loadViewIfNeeded()
        let style = self.style
        let step = nextStep(for: identifier)
        switch identifier {
        case "iconColor.normal":
            style.setIconColor(color(atStep: step), for: .normal)
        case "iconColor.selected":
            let colors: [UIColor] = [.systemYellow, .black, .white]
            style.setIconColor(colors[step % colors.count], for: .selected)
        case "titleColor.normal", "titleColor.selected":
            let state: UIControl.State = identifier.hasSuffix("selected") ? .selected : .normal
            var attributes = style.titleTextAttributes(for: state)
            attributes[.foregroundColor] = state == .selected ? UIColor(white: 1 - 0.15 * CGFloat(step % 3), alpha: 1) : color(atStep: step)
            style.setTitleTextAttributes(attributes, for: state)
        case "font":
            let fonts: [UIFont] = [.systemFont(ofSize: 16, weight: .semibold), .systemFont(ofSize: 12),
                                   .italicSystemFont(ofSize: 15), .systemFont(ofSize: 14)]
            for appearance in appearances {
                appearance.font = fonts[step % fonts.count]
            }
        case "imageTitleSpacing":
            let spacings: [CGFloat] = [10, 0, 4]
            style.imageTitleSpacing = spacings[step % 3]
        case "imageSize":
            let sides: [CGFloat] = [20, 10, 14]
            let side = sides[step % 3]
            style.imageSize = CGSize(width: side, height: side)
        case "imageInsets":
            let inset: CGFloat = step % 2 == 0 ? 3 : 0
            style.imageInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        case "titlePositionAdjustment":
            let offsets = [UIOffset(horizontal: 0, vertical: -4), UIOffset(horizontal: 4, vertical: 0), .zero]
            style.titlePositionAdjustment = offsets[step % offsets.count]
        case "imagePositionAdjustment":
            let offsets = [UIOffset(horizontal: 0, vertical: -4), UIOffset(horizontal: -4, vertical: 0), .zero]
            style.imagePositionAdjustment = offsets[step % offsets.count]
        case "content.iconAndTitle", "content.iconOnly", "content.titleOnly":
            content = identifier == "content.iconOnly" ? .iconOnly : identifier == "content.titleOnly" ? .titleOnly : .iconAndTitle
            reloadItems()
        case "layoutCentered":
            style.layoutCentered = !style.layoutCentered
        case "selectedImage":
            usesSelectedImage = !usesSelectedImage
            reloadItems()
        case "backgroundColor.normal":
            style.normalAppearance.backgroundColor = lightColor(atStep: step)
        case "backgroundColor.selected":
            style.selectedAppearance.backgroundColor = color(atStep: step)
            style.selectedAppearance.borderColor = color(atStep: step)
        case "borderColor":
            style.normalAppearance.borderColor = color(atStep: step)
        case "borderWidth":
            let widths: [CGFloat] = [2, 0, 1, 0.5]
            let width = widths[step % 4]
            for appearance in appearances {
                appearance.borderWidth = width
            }
        case "cornerRadius":
            let radii: [CGFloat] = [0, 8, 3]
            let radius = radii[step % 3]
            for appearance in appearances {
                appearance.cornerRadius = radius
            }
        case "margin":
            let margins: [CGFloat] = [18, 4, 10]
            let margin = margins[step % 3]
            for appearance in appearances {
                appearance.margin = margin
            }
        case "animation.lottie", "animation.pag", "animation.rive", "animation.gif", "animation.off":
            let library = String(identifier.dropFirst("animation.".count))
            animationLibrary = library == "off" ? nil : library
            reloadItems()
            // Show the animations: play the selected tag's icon.
            let collection = tagListView.value(forKey: "collectionView") as! UICollectionView
            for indexPath in tagListView.selectedIndexPaths {
                collection.layoutIfNeeded()
                (collection.cellForItem(at: indexPath) as? CYLTagListCell)?.button.playAnimation()
            }
        case "animationSpeed":
            let speeds: [CGFloat] = [0.5, 2, 1]
            style.animationSpeed = speeds[step % 3]
        case "configuration":
            navigationController?.pushViewController(CYLTagConfigurationDemoViewController(), animated: true)
            return
        case "reset":
            self.style = Self.demoStyle()
            content = .iconAndTitle
            animationLibrary = nil
            usesSelectedImage = true
            steps.removeAll()
            reloadItems()
        default:
            break
        }
        applyStyle()
    }

    func value(forAction identifier: String) -> String {
        let style = self.style
        switch identifier {
        case "imageTitleSpacing": return String(format: "%.0f", Double(style.imageTitleSpacing))
        case "imageSize": return NSCoder.string(for: style.imageSize)
        case "imageInsets": return NSCoder.string(for: style.imageInsets)
        case "titlePositionAdjustment": return NSCoder.string(for: style.titlePositionAdjustment)
        case "imagePositionAdjustment": return NSCoder.string(for: style.imagePositionAdjustment)
        case "layoutCentered": return style.layoutCentered ? "YES" : "NO"
        case "selectedImage": return usesSelectedImage ? "YES" : "NO"
        case "font": return String(format: "%@ %.0f", style.normalAppearance.font.fontName, Double(style.normalAppearance.font.pointSize))
        case "borderWidth": return String(format: "%.1f", Double(style.normalAppearance.borderWidth))
        case "cornerRadius": return String(format: "%.0f", Double(style.normalAppearance.cornerRadius))
        case "margin": return String(format: "%.0f", Double(style.normalAppearance.margin))
        case "animationSpeed": return String(format: "%.1f", Double(style.animationSpeed))
        default: break
        }
        if identifier.hasPrefix("animation.") {
            let library = String(identifier.dropFirst("animation.".count))
            let current = library == "off" ? animationLibrary == nil : library == (animationLibrary ?? "")
            return current ? "✓" : ""
        }
        if identifier.hasPrefix("content.") {
            let current = ["content.iconAndTitle", "content.iconOnly", "content.titleOnly"][content.rawValue]
            return identifier == current ? "✓" : ""
        }
        return ""
    }

    // MARK: Style and data

    static func demoStyle() -> CYLMenuStyle {
        let style = CYLMenuStyle()
        style.setIconColor(.systemBlue, for: .normal)
        style.setIconColor(.white, for: .selected)
        style.selectedAppearance.backgroundColor = .systemBlue
        style.selectedAppearance.borderColor = .systemBlue
        style.imageSize = CGSize(width: 16, height: 16)
        style.imageTitleSpacing = 4
        style.itemHeight = 34
        style.sectionInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        return style
    }

    func reloadItems() {
        // Title key, icon, selected icon.
        let samples: [(String, String, String)] = [
            ("首页", "house", "house.fill"),
            ("同城", "mappin.and.ellipse", "mappin.circle.fill"),
            ("消息", "message", "message.fill"),
            ("我的", "person", "person.fill"),
            ("一个很长很长的标签标题", "star", "star.fill"),
            ("已禁用", "nosign", "nosign"),
        ]
        var items: [CYLExampleMenuItem] = []
        for sample in samples {
            let iconOnly = content == .iconOnly
            let titleOnly = content == .titleOnly
            let item = CYLExampleMenuItem(title: iconOnly ? "" : CYLExampleLocalizedString(sample.0))
            item.image = titleOnly ? nil : UIImage(systemName: sample.1)
            item.selectedImage = (titleOnly || !usesSelectedImage) ? nil : UIImage(systemName: sample.2)
            item.isEnabled = sample.0 != "已禁用"
            if animationLibrary != nil && item.isEnabled && !titleOnly {
                item.animationURL = animationURL(forIndex: items.count)
            }
            items.append(item)
        }
        let source = CYLExampleMenuSource(sections: [CYLExampleMenuSection(title: "", items: items)])
        menuSource = source
        let selection = tagListView.selectedIndexPaths
        tagListView.menuDataSource = source
        tagListView.reloadMenuData()
        tagListView.selectedIndexPaths = selection.isEmpty ? [IndexPath(item: 0, section: 0)] : selection
    }

    /// The demo's animated icons, from CYLTabBarController's examples (Lottie, GIF, Rive) and
    /// libpag/pag-ios (PAG, downloaded by `pod install`).
    func animationURL(forIndex index: Int) -> URL? {
        let files: [String: [String]] = [
            "lottie": ["CYLMenuExample.bundle/Animations/Lottie/tab_home_animate.json", "CYLMenuExample.bundle/Animations/Lottie/tab_me_animate.json"],
            "gif": ["CYLMenuExample.bundle/Animations/GIF/tab_star.gif", "CYLMenuExample.bundle/Animations/GIF/cyl_tab_sample_animated.gif"],
            "pag": ["pag-ios/0.pag", "pag-ios/1.pag"],
            "rive": ["CYLMenuExample.bundle/Animations/Rive/house.riv", "CYLMenuExample.bundle/Animations/Rive/menu_button.riv"],
        ]
        guard let library = animationLibrary, let names = files[library], !names.isEmpty else { return nil }
        var url = Bundle.main.resourceURL?.appendingPathComponent(names[index % names.count])
        if library == "rive" {
            // The state machines CYLTabBarController's Rive example plays for these files.
            url = CYLMenuAnimationURLWithOptions(url, index % 2 == 0
                ? ["stateMachine": "State Machine 1"]
                : ["stateMachine": "State Machine", "input": "isOpen", "duration": "0"])
        }
        return url
    }

    func applyStyle() {
        tagListView.style = style
        tableView.reloadData()
        view.setNeedsLayout()
    }

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // navigationItem, not title: a view controller's title would replace its tab's title.
        navigationItem.title = CYLExampleLocalizedString("标签样式")
        view.backgroundColor = .systemBackground
        steps = [:]
        style = Self.demoStyle()
        usesSelectedImage = true

        let tagListView = CYLTagListView()
        tagListView.translatesAutoresizingMaskIntoConstraints = false
        tagListView.selectionMode = .multiple
        tagListView.showsSectionHeaders = false
        tagListView.isScrollEnabled = false
        tagListView.menuDelegate = self
        view.addSubview(tagListView)
        self.tagListView = tagListView

        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.styleCell)
        view.addSubview(tableView)
        self.tableView = tableView

        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(separator)

        previewHeight = tagListView.heightAnchor.constraint(equalToConstant: 0)
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tagListView.topAnchor.constraint(equalTo: safe.topAnchor),
            tagListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tagListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewHeight,
            separator.topAnchor.constraint(equalTo: tagListView.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.0 / max(1, UIScreen.main.scale)),
            tableView.topAnchor.constraint(equalTo: separator.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        reloadItems()
        applyStyle()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = tagListView.heightThatFitsWidth(view.bounds.width)
        if abs(previewHeight.constant - height) > 0.5 {
            previewHeight.constant = height
        }
    }
}

extension CYLTagStyleDemoViewController: CYLMenuDelegate {
    func menu(_ menu: Any, didChangeContentHeight height: CGFloat) {
        view.setNeedsLayout()
    }
}

extension CYLTagStyleDemoViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        actionIdentifiers().count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        actionIdentifiers()[section].count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        title(forSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.styleCell, for: indexPath)
        let identifier = actionIdentifiers()[indexPath.section][indexPath.row]
        var content = UIListContentConfiguration.valueCell()
        content.text = title(forAction: identifier)
        content.textProperties.font = .preferredFont(forTextStyle: .subheadline)
        content.textProperties.numberOfLines = 0
        content.secondaryText = value(forAction: identifier)
        content.prefersSideBySideTextAndSecondaryText = true
        cell.contentConfiguration = content
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performAction(actionIdentifiers()[indexPath.section][indexPath.row])
    }
}
