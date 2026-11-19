//
//  CYLTagCloudDemoViewController.swift
//  CYLMenuExample
//
//  标签云：android-tagview（kaede/android-tagview）的初始化方式。先创建 CYLTagListView，设置行距、标签间距与内边距
//  （lineSpacing、interitemSpacing、tagContentInsets，也可在 Interface Builder 中设置），再 addTags(withTitles:) 或
//  addTag(_:) 添加 CYLTag；点击与删除用 tagClickHandler、tagDeleteHandler 监听。下方是同样的标签，用配置字典
//  （CYLTagListKey.tags）创建。
//

import UIKit
import CollectionViewClassifyMenu

final class CYLTagCloudDemoViewController: UIViewController {

    /// Created the android-tagview way: init(), spacing, then tags.
    private(set) var codeTagListView: CYLTagListView!
    /// The same kind of tags from a configuration dictionary (CYLTagListKey.tags).
    private(set) var mapTagListView: CYLTagListView!
    private(set) var eventLabel: UILabel!

    /// The continents of android-tagview's sample.
    static let continents = ["Asia", "Africa", "North America", "South America", "Antarctica", "Europe", "Australia"]

    /// android-tagview's "add a tag in details": every look property of its Tag.
    static func detailedTag() -> CYLTag {
        let tag = CYLTag(identifier: 7, title: "Tag Text", backgroundColorHex: "#DDDDDD")
        tag.textColor = .white
        tag.highlightedBackgroundColor = UIColor(white: 0.33, alpha: 1)
        tag.cornerRadius = 20
        tag.textSize = 14
        tag.borderWidth = 1
        tag.borderColor = .white
        tag.isDeletable = true
        return tag
    }

    /// Tags that show the rest of android-tagview's Tag: deletable, a larger text, a background image, a delete icon.
    static func styledTags() -> [CYLTag] {
        let blue = CYLTag(title: CYLExampleLocalizedString("可删除"), backgroundColorHex: "#00BFFF")
        blue.textColor = .white
        blue.borderWidth = 0
        blue.isDeletable = true
        blue.highlightedBackgroundColor = UIColor(red: 0, green: 0.5, blue: 0.7, alpha: 1)
        let large = CYLTag(title: CYLExampleLocalizedString("大字号"), backgroundColor: .systemOrange)
        large.textColor = .white
        large.textSize = 22
        large.borderWidth = 0
        let image = CYLTag(title: CYLExampleLocalizedString("背景图"))
        image.backgroundImage = backgroundImage()
        image.textColor = .white
        image.borderWidth = 0
        let custom = CYLTag(title: CYLExampleLocalizedString("自定义删除"), backgroundColor: .systemPink)
        custom.textColor = .white
        custom.borderWidth = 0
        custom.isDeletable = true
        custom.deleteIndicatorTitle = "⊗"
        custom.deleteIndicatorColor = UIColor(white: 1, alpha: 0.8)
        custom.deleteIndicatorSize = 18
        return [blue, large, image, custom]
    }

    /// A horizontal gradient, as android-tagview's custom background drawable.
    static func backgroundImage() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 64, height: 32)).image { context in
            let colors = [UIColor.systemPurple.cgColor, UIColor.systemTeal.cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: nil) {
                context.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 64, y: 0), options: [])
            }
        }
    }

    /// The configuration of the lower list: the same kinds of tags, as strings and dictionaries.
    static func mapConfiguration() -> [String: Any] {
        let blue: [String: Any] = [CYLMenuStyleKey.normal: [CYLTagAppearanceKey.backgroundColor: "#00BFFF",
                                                        CYLTagAppearanceKey.textColor: "#FFFFFF",
                                                        CYLTagAppearanceKey.borderWidth: 0,
                                                        CYLTagAppearanceKey.cornerRadius: 0],
                                   CYLMenuStyleKey.highlightedBackgroundColor: "#88363636"]
        return [
            CYLTagListKey.style: [CYLMenuStyleKey.lineSpacing: 5, CYLMenuStyleKey.interitemSpacing: 3,
                                  CYLMenuStyleKey.tagContentInsets: "{3, 10, 3, 10}"],
            CYLTagListKey.scrollEnabled: false,
            CYLTagListKey.tags: ["Asia", "Europe",
                                 [CYLTagItemKey.title: "Africa", CYLTagItemKey.identifier: 3, CYLTagItemKey.deletable: true,
                                  CYLTagItemKey.style: blue] as [String: Any],
                                 [CYLTagItemKey.title: "Australia", CYLTagItemKey.image: "system:globe"] as [String: Any]],
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = CYLExampleLocalizedString("标签云（android-tagview）")
        view.backgroundColor = .systemGroupedBackground

        // android-tagview: TagView tagview2 = new TagView(this); tagview2.setLineMargin(20f); …
        let codeTagListView = CYLTagListView()
        codeTagListView.lineSpacing = 5
        codeTagListView.interitemSpacing = 3
        codeTagListView.tagContentInsets = UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10)
        codeTagListView.isScrollEnabled = false
        codeTagListView.addTags(withTitles: Self.continents)
        codeTagListView.addTag(Self.detailedTag())
        codeTagListView.addTags(Self.styledTags())
        codeTagListView.tagClickHandler = { [weak self] index, tag in
            self?.showEvent(CYLExampleLocalizedString("点击第 %ld 个「%@」", index, tag.title))
        }
        codeTagListView.tagDeleteHandler = { [weak self] index, tag in
            self?.showEvent(CYLExampleLocalizedString("删除第 %ld 个「%@」", index, tag.title))
            self?.view.setNeedsLayout()
        }
        self.codeTagListView = codeTagListView

        let mapTagListView = CYLTagListView(configuration: Self.mapConfiguration())
        mapTagListView.tagDeleteHandler = { [weak self] index, tag in
            self?.showEvent(CYLExampleLocalizedString("删除第 %ld 个「%@」", index, tag.title))
            self?.view.setNeedsLayout()
        }
        self.mapTagListView = mapTagListView

        eventLabel = caption(withText: CYLExampleLocalizedString("点击标签，或点 × 删除"))
        let views: [UIView] = [caption(withText: CYLExampleLocalizedString("代码初始化：addTags(withTitles:)、addTag(_:)")), codeTagListView,
                               caption(withText: CYLExampleLocalizedString("字典初始化：CYLTagListKey.tags")), mapTagListView, eventLabel]
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func showEvent(_ text: String) {
        setText(text, ofCaption: eventLabel)
    }

    private func caption(withText text: String) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        setText(text, ofCaption: label)
        return label
    }

    /// Footnote text inset by 16 pt, to line up with the tags.
    private func setText(_ text: String, ofCaption label: UILabel) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.firstLineHeadIndent = 16
        paragraph.headIndent = 16
        paragraph.tailIndent = -16
        label.attributedText = NSAttributedString(string: text, attributes: [
            .font: UIFont.preferredFont(forTextStyle: .footnote),
            .foregroundColor: UIColor.secondaryLabel,
            .paragraphStyle: paragraph,
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = view.bounds.width
        for list in [codeTagListView!, mapTagListView!] {
            let height = list.heightThatFitsWidth(width)
            if let constraint = list.constraints.last(where: { $0.firstAttribute == .height && $0.firstItem === list }) {
                if abs(constraint.constant - height) > 0.5 {
                    constraint.constant = height
                }
            } else {
                list.heightAnchor.constraint(equalToConstant: height).isActive = true
            }
        }
    }
}
