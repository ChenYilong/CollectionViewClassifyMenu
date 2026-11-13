//
//  CYLTagAnimationDemoViewController.swift
//  CYLMenuExample
//
//  动效图标演示：CYLTabBarController Example 中的动效与图片资源（Lottie、PAG、Rive、GIF、静态图片），
//  每个分组一种动效库，点击标签播放，与 CYLTabBarController 的 Tab 图标相同。用字典（map）初始化。
//

import UIKit
import CollectionViewClassifyMenu

final class CYLTagAnimationDemoViewController: UIViewController {

    private(set) var tagListView: CYLTagListView!
    private(set) var statusLabel: UILabel!

    /// Section titles, one per library, in order.
    static func sectionIdentifiers() -> [String] {
        ["lottie", "lottie-images", "lottie-green", "pag", "rive", "rive-icons", "gif", "images"]
    }

    /// A file of CYLMenuExample.bundle/Animations (copied from CYLTabBarController's examples).
    static func animation(_ path: String) -> String {
        ("CYLMenuExample.bundle/Animations" as NSString).appendingPathComponent(path)
    }

    /// An item with a localized title (`title` is the key), an animation and/or an image.
    static func item(_ title: String, animation: String?, image: String?) -> [String: Any] {
        var item: [String: Any] = [CYLTagItemKey.title: CYLExampleLocalizedString(title)]
        if let animation { item[CYLTagItemKey.animation] = animation }
        if let image { item[CYLTagItemKey.image] = image }
        return item
    }

    static func item(_ title: String, rive name: String, options: [String: String]) -> [String: Any] {
        var item = self.item(title, animation: animation("Rive/\(name).riv"), image: nil)
        item[CYLTagItemKey.animationOptions] = options
        return item
    }

    /// The configuration (map) the tag list is created with.
    static func configuration() -> [String: Any] {
        // One literal per section keeps the type checker fast.
        var sections: [[String: Any]] = []
        sections.append([CYLTagSectionKey.title: "Lottie · pod 'CYLTabBarController/Lottie'", CYLTagSectionKey.items: [
                item("首页", animation: animation("Lottie/tab_home_animate.json"), image: nil),
                item("消息", animation: animation("Lottie/tab_message_animate.json"), image: nil),
                item("搜索", animation: animation("Lottie/tab_search_animate.json"), image: nil),
                item("我的", animation: animation("Lottie/tab_me_animate.json"), image: nil)]])
        // Lottie files with image assets next to them, and placeholder images for when no engine is linked.
        sections.append([CYLTagSectionKey.title: CYLExampleLocalizedString("Lottie（带图片资源与占位图）"), CYLTagSectionKey.items: [
                item("首页", animation: animation("Lottie/gray_tabbar_home_animation.json"), image: "gray_tabbar_home_animation_lottie_placeholder"),
                item("消息", animation: animation("Lottie/gray_tabbar_message_animation.json"), image: "gray_tabbar_message_animation_lottie_placeholder"),
                item("我的", animation: animation("Lottie/gray_tabbar_me_animation.json"), image: "gray_tabbar_me_animation_lottie_placeholder")]])
        sections.append([CYLTagSectionKey.title: CYLExampleLocalizedString("Lottie（绿色主题）"), CYLTagSectionKey.items: [
                item("首页", animation: animation("Lottie/green_lottie_tab_home.json"), image: nil),
                item("资讯", animation: animation("Lottie/green_lottie_tab_news.json"), image: nil),
                item("发现", animation: animation("Lottie/green_lottie_tab_discover.json"), image: nil),
                item("我的", animation: animation("Lottie/green_lottie_tab_mine.json"), image: nil)]])
        // The PAG tab icons of CYLTabBarController's Example-PAG (tab_*.pag, downloaded by `pod install`), and two
        // libpag samples. 1.pag's first frame is empty: while not selected it rests on its last frame instead.
        sections.append([CYLTagSectionKey.title: "PAG · pod 'CYLTabBarController/PAG'", CYLTagSectionKey.items: [
                item("首页", animation: "pag-ios/tab_home.pag", image: nil),
                item("健康", animation: "pag-ios/tab_health.pag", image: nil),
                item("动态", animation: "pag-ios/tab_moments.pag", image: nil),
                item("我的", animation: "pag-ios/tab_me.pag", image: nil),
                item("动效一", animation: "pag-ios/0.pag", image: nil),
                [CYLTagItemKey.title: CYLExampleLocalizedString("动效二"), CYLTagItemKey.animation: "pag-ios/1.pag",
                 CYLTagItemKey.animationRestingProgress: 1] as [String: Any]]])
        // The options CYLTabBarController's Rive examples use for each file (Example-SwiftUI-Rive): a Rive icon needs its
        // state machine and input (or animation), given with CYLTagItemKey.animationOptions. icons.riv follows, on dark tags.
        sections.append([CYLTagSectionKey.title: "Rive · pod 'CYLTabBarController/Rive'", CYLTagSectionKey.items: [
                item("首页", rive: "house", options: ["stateMachine": "State Machine 1"]),
                item("完成", rive: "check", options: ["stateMachine": "State Machine 1", "triggerInput": "Check"]),
                item("菜单", rive: "menu_button", options: ["stateMachine": "State Machine", "input": "isOpen", "duration": "0"]),
                item("按钮", rive: "button", options: ["animation": "active"]),
                item("形状", rive: "shapes", options: ["legacy": "1"]),
                // truck.riv from rive-app/rive-ios's examples, in place of confetti.riv (empty until its explosion plays).
                item("卡车", rive: "truck", options: ["legacy": "1"])]])
        // icons.riv, as on CYLTabBarController's dark Rive tab bar: its artboards are white strokes, so this
        // section's tags are dark (CYLTagSectionKey.style, over the list's style).
        sections.append([CYLTagSectionKey.title: CYLExampleLocalizedString("Rive · icons.riv（深色标签）"),
             CYLTagSectionKey.style: [
                CYLMenuStyleKey.normal: [CYLTagAppearanceKey.backgroundColor: "#17203A", CYLTagAppearanceKey.textColor: "#FFFFFF",
                                     CYLTagAppearanceKey.borderColor: "#17203A"],
                CYLMenuStyleKey.selected: [CYLTagAppearanceKey.backgroundColor: "#3A4E8C", CYLTagAppearanceKey.textColor: "#FFFFFF",
                                       CYLTagAppearanceKey.borderColor: "#6792FF"]],
             CYLTagSectionKey.items: [
                item("聊天", rive: "icons", options: ["artboard": "CHAT", "stateMachine": "CHAT_Interactivity", "input": "active"]),
                item("搜索", rive: "icons", options: ["artboard": "SEARCH", "stateMachine": "SEARCH_Interactivity", "input": "active"]),
                item("计时", rive: "icons", options: ["artboard": "TIMER", "stateMachine": "TIMER_Interactivity", "input": "active"]),
                item("提醒", rive: "icons", options: ["artboard": "BELL", "stateMachine": "BELL_Interactivity", "input": "active"]),
                item("我的", rive: "icons", options: ["artboard": "USER", "stateMachine": "USER_Interactivity", "input": "active"])]])
        sections.append([CYLTagSectionKey.title: "GIF · pod 'CYLTabBarController/GIF'", CYLTagSectionKey.items: [
                item("火焰", animation: animation("GIF/tab_fire.gif"), image: nil),
                item("火箭", animation: animation("GIF/tab_rocket.gif"), image: nil),
                item("星星", animation: animation("GIF/tab_star.gif"), image: nil),
                item("示例", animation: animation("GIF/cyl_tab_sample_animated.gif"), image: nil)]])
        // CYLTabBarController's tab images: normal and highlighted.
        sections.append([CYLTagSectionKey.title: CYLExampleLocalizedString("静态图片（CYLTabBarController Example）"), CYLTagSectionKey.items: [
                [CYLTagItemKey.title: CYLExampleLocalizedString("首页"), CYLTagItemKey.image: "home_normal", CYLTagItemKey.selectedImage: "home_highlight"],
                [CYLTagItemKey.title: CYLExampleLocalizedString("同城"), CYLTagItemKey.image: "fishpond_normal", CYLTagItemKey.selectedImage: "fishpond_highlight"],
                [CYLTagItemKey.title: CYLExampleLocalizedString("发布"), CYLTagItemKey.image: "post_normal", CYLTagItemKey.selectedImage: "post_highlight"],
                [CYLTagItemKey.title: CYLExampleLocalizedString("消息"), CYLTagItemKey.image: "message_normal", CYLTagItemKey.selectedImage: "message_highlight"],
                [CYLTagItemKey.title: CYLExampleLocalizedString("我的"), CYLTagItemKey.image: "account_normal", CYLTagItemKey.selectedImage: "account_highlight"]]])
        let selected = (0..<sections.count).map { "\($0)-0" }
        let style: [String: Any] = [
            CYLMenuStyleKey.imageSize: "{28, 28}",
            CYLMenuStyleKey.imageTitleSpacing: 6,
            CYLMenuStyleKey.itemHeight: 44,
            CYLMenuStyleKey.layoutCentered: true,
            CYLMenuStyleKey.sectionInsets: [6, 16, 14, 16],
            CYLMenuStyleKey.normal: [CYLTagAppearanceKey.cornerRadius: 0, CYLTagAppearanceKey.margin: 12,
                                 CYLTagAppearanceKey.borderColor: "#D1D1D6", CYLTagAppearanceKey.borderWidth: 1] as [String: Any],
            CYLMenuStyleKey.selected: [CYLTagAppearanceKey.cornerRadius: 0, CYLTagAppearanceKey.margin: 12,
                                   CYLTagAppearanceKey.backgroundColor: "#FFF1E6", CYLTagAppearanceKey.textColor: "#FF6A00",
                                   CYLTagAppearanceKey.borderColor: "#FF6A00", CYLTagAppearanceKey.borderWidth: 1] as [String: Any],
        ]
        return [
            CYLTagListKey.selectionMode: "single",
            CYLTagListKey.allowsEmptySelection: false,
            CYLTagListKey.selectedItems: selected,
            CYLTagListKey.style: style,
            CYLTagListKey.sections: sections,
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // navigationItem, not title: a view controller's title would replace its tab's title.
        navigationItem.title = CYLExampleLocalizedString("动效图标")
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: CYLExampleLocalizedString("全部播放"), style: .plain,
                                                            target: self, action: #selector(playSelectedAnimations))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "1x", style: .plain, target: self, action: #selector(changeSpeed))

        let statusLabel = UILabel()
        statusLabel.numberOfLines = 0
        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.adjustsFontForContentSizeCategory = true
        statusLabel.textColor = .secondaryLabel
        statusLabel.text = CYLTagButton.isAnimationEngineAvailable()
            ? CYLExampleLocalizedString("动效引擎：CYLTabBarItemAnimationFactory 已链接")
            : CYLExampleLocalizedString("动效引擎未链接：显示静态图标")
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        self.statusLabel = statusLabel

        let tagListView = CYLTagListView(configuration: Self.configuration())
        tagListView.translatesAutoresizingMaskIntoConstraints = false
        tagListView.menuDelegate = self
        view.addSubview(tagListView)
        self.tagListView = tagListView
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: safe.topAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            tagListView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 4),
            tagListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tagListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tagListView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    var collectionView: UICollectionView {
        tagListView.value(forKey: "collectionView") as! UICollectionView
    }

    /// Plays the animated icon of every selected tag, as the "全部播放" button does.
    @objc func playSelectedAnimations() {
        collectionView.layoutIfNeeded()
        for indexPath in tagListView.selectedIndexPaths {
            (collectionView.cellForItem(at: indexPath) as? CYLTagListCell)?.button.playAnimation()
        }
    }

    /// Cycles the animation speed (1x, 2x, 0.5x), as the speed button does.
    @objc func changeSpeed() {
        let style = tagListView.style.copy() as! CYLMenuStyle
        let speeds: [CGFloat] = [1, 2, 0.5]
        let next = speeds.firstIndex(of: style.animationSpeed).map { $0 + 1 } ?? 0
        style.animationSpeed = speeds[next % speeds.count]
        tagListView.style = style
        navigationItem.leftBarButtonItem?.title = String(format: "%gx", Double(style.animationSpeed))
        playSelectedAnimations()
    }

    /// Scrolls the tags to a section of sectionIdentifiers() (e.g. "pag").
    func scroll(toSectionIdentifier identifier: String) {
        guard let section = Self.sectionIdentifiers().firstIndex(of: identifier) else { return }
        loadViewIfNeeded()
        view.layoutIfNeeded()
        tagListView.scroll(toSection: section, animated: false)
    }
}

extension CYLTagAnimationDemoViewController: CYLMenuDelegate {
    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        let section = tagListView.menuDataSource?.menuTitle(forSection: indexPath.section) ?? ""
        let title = tagListView.menuDataSource?.menuTitleForItem(at: indexPath) ?? ""
        statusLabel.text = CYLExampleLocalizedString("点击「%@」", "\(section) · \(title)")
    }
}
