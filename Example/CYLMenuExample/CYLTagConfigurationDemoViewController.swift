//
//  CYLTagConfigurationDemoViewController.swift
//  CYLMenuExample
//
//  标签的两种初始化方式（参照 CYLTabBarController 的 -initWithConfiguration: 与
//  -initWithConfigurationFile:error:）：配置文件（JSON）与字典（map）。图标使用
//  CYLTabBarController 的动效引擎（Lottie、PAG、Rive、GIF）。
//

import UIKit
import CollectionViewClassifyMenu

final class CYLTagConfigurationDemoViewController: UIViewController {

    /// Created with init(configurationFile:) from Configurations/animated-tags.json.
    private(set) var fileTagListView: CYLTagListView?
    /// Created with init(configuration:) from a dictionary.
    private(set) var mapTagListView: CYLTagListView!
    private(set) var configurationError: Error?
    private(set) var eventLabel: UILabel!

    /// Path of the configuration file in the app.
    static func configurationFilePath() -> String {
        "CYLMenuExample.bundle/Configurations/animated-tags.json"
    }

    static func animationNamed(_ name: String) -> URL? {
        let resource = ("CYLMenuExample.bundle/Animations" as NSString).appendingPathComponent((name as NSString).deletingPathExtension)
        return Bundle.main.url(forResource: resource, withExtension: (name as NSString).pathExtension)
    }

    /// An animation URL, or "" (as the Objective-C example's `?: @""`) when the file is missing.
    private static func animationValue(_ name: String) -> Any {
        if let url = animationNamed(name) {
            return url
        }
        return ""
    }

    /// The dictionary of the map example.
    static func mapConfiguration() -> [String: Any] {
        // In code, values keep their types (UIColor, NSValue, NSURL...); strings work too.
        let normal: [String: Any] = [CYLTagAppearanceKey.iconColor: UIColor.systemIndigo,
                                     CYLTagAppearanceKey.borderColor: UIColor.systemIndigo,
                                     CYLTagAppearanceKey.borderWidth: 1,
                                     CYLTagAppearanceKey.cornerRadius: 8]
        let selected: [String: Any] = [CYLTagAppearanceKey.backgroundColor: UIColor.systemIndigo,
                                       CYLTagAppearanceKey.borderColor: UIColor.systemIndigo,
                                       CYLTagAppearanceKey.iconColor: UIColor.white,
                                       CYLTagAppearanceKey.cornerRadius: 8]
        let style: [String: Any] = [
            CYLMenuStyleKey.imageSize: NSValue(cgSize: CGSize(width: 20, height: 20)),
            CYLMenuStyleKey.imageTitleSpacing: 4,
            CYLMenuStyleKey.itemHeight: 36,
            CYLMenuStyleKey.layoutCentered: true,
            CYLMenuStyleKey.normal: normal,
            CYLMenuStyleKey.selected: selected,
        ]
        let items: [Any] = [
            [CYLTagItemKey.title: "Lottie", CYLTagItemKey.animation: animationValue("Lottie/tab_me_animate.json")] as [String: Any],
            [CYLTagItemKey.title: "GIF", CYLTagItemKey.animation: animationValue("GIF/cyl_tab_sample_animated.gif")] as [String: Any],
            [CYLTagItemKey.title: "Rive", CYLTagItemKey.animation: animationValue("Rive/menu_button.riv")] as [String: Any],
            [CYLTagItemKey.image: "system:heart", CYLTagItemKey.selectedImage: "system:heart.fill"] as [String: Any],
            "Text only",
        ]
        let section: [String: Any] = [
            CYLTagSectionKey.title: CYLExampleLocalizedString("字典（map）初始化"),
            CYLTagSectionKey.items: items,
        ]
        return [
            CYLTagListKey.selectionMode: CYLMenuSelectionMode.multiple.rawValue,
            CYLTagListKey.foldControl: CYLMenuFoldControl(position: .none, content: .icon),
            CYLTagListKey.scrollEnabled: false,
            CYLTagListKey.selectedItems: [NSIndexPath(item: 1, section: 0)],
            CYLTagListKey.style: style,
            CYLTagListKey.sections: [section],
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = CYLExampleLocalizedString("配置初始化")
        view.backgroundColor = .systemGroupedBackground

        let fileTitle = caption(withText: CYLExampleLocalizedString("配置文件初始化：%@", Self.configurationFilePath()))
        do {
            let fileTagListView = try CYLTagListView(configurationFile: Self.configurationFilePath())
            fileTagListView.menuDelegate = self
            self.fileTagListView = fileTagListView
        } catch {
            configurationError = error
        }

        let mapTitle = caption(withText: CYLExampleLocalizedString("字典（map）初始化：-initWithConfiguration:"))
        let mapTagListView = CYLTagListView(configuration: Self.mapConfiguration())
        mapTagListView.menuDelegate = self
        self.mapTagListView = mapTagListView

        eventLabel = caption(withText: CYLTagButton.isAnimationEngineAvailable
                             ? CYLExampleLocalizedString("动效引擎：CYLTabBarItemAnimationFactory 已链接")
                             : CYLExampleLocalizedString("动效引擎未链接：显示静态图标"))

        var views: [UIView] = [fileTitle]
        if let fileTagListView {
            views.append(fileTagListView)
        } else {
            views.append(caption(withText: configurationError?.localizedDescription ?? "?"))
        }
        views += [mapTitle, mapTagListView, eventLabel]
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safe.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func caption(withText text: String) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        setText(text, ofCaption: label)
        return label
    }

    /// Footnote text inset by 16 pt, to line up with the tags.
    func setText(_ text: String?, ofCaption label: UILabel) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.firstLineHeadIndent = 16
        paragraph.headIndent = 16
        paragraph.tailIndent = -16
        label.attributedText = NSAttributedString(string: text ?? "", attributes: [
            .font: UIFont.preferredFont(forTextStyle: .footnote),
            .foregroundColor: UIColor.secondaryLabel,
            .paragraphStyle: paragraph,
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = view.bounds.width
        for list in [fileTagListView ?? mapTagListView!, mapTagListView!] {
            let height = list.heightThatFitsWidth(width)
            let existing = list.constraints.last { $0.firstAttribute == .height && $0.firstItem === list }
            if let constraint = existing {
                if abs(constraint.constant - height) > 0.5 {
                    constraint.constant = height
                }
            } else {
                list.heightAnchor.constraint(equalToConstant: height).isActive = true
            }
        }
    }
}

extension CYLTagConfigurationDemoViewController: CYLMenuDelegate {

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        guard let list = menu as? CYLTagListView else { return }
        let title = list.menuDataSource?.menuTitleForItem(at: indexPath) ?? ""
        setText(CYLExampleLocalizedString("点击「%@」", title), ofCaption: eventLabel)
    }

    func menu(_ menu: Any, didChangeContentHeight height: CGFloat) {
        view.setNeedsLayout()
    }
}
