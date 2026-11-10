//
//  CYLFoldStylesViewController.swift
//  CYLTagEditorExample
//
//  折叠样式：the fold control and title styles of the core's CYLTagListView, each made with the
//  initialization parameters (CYLMenuFoldControl: position and content; the list's title and its
//  position), then the same from configuration files in four formats (JSON, plist, YAML, XML; YAML and
//  XML are read by CYLTabBarController's parser). Tags come from tags.json.
//

import UIKit
import CollectionViewClassifyMenu

/// Sections of tags for a demo list.
final class CYLFoldStyleMenuSource: NSObject, CYLMenuDataSource {
    let sections: [CYLTagGroup]

    init(sections: [CYLTagGroup]) {
        self.sections = sections
    }

    func numberOfSectionsInMenu() -> Int {
        sections.count
    }

    func menuNumberOfItems(inSection section: Int) -> Int {
        sections[section].tags.count
    }

    func menuTitle(forSection section: Int) -> String {
        sections[section].title
    }

    func menuTitleForItem(at indexPath: IndexPath) -> String {
        sections[indexPath.section].tags[indexPath.item]
    }
}

final class CYLFoldStylesViewController: UIViewController {

    /// One demo made in code.
    struct Demo {
        /// The list's title (nil: icon only).
        let title: String?
        let foldControl: CYLMenuFoldControl
        var titlePosition: CYLMenuTitlePosition = .topLeading
        /// The title's icon (an SF Symbol), nil for none.
        var titleImage: String?
        /// The title's text and icon color; nil keeps the default (the label color).
        var titleColor: UIColor?
        /// The icon after the title instead of before it.
        var titleImageTrailing = false
        var showsSectionHeaders = true
        let groups: [Int]
    }

    let data: CYLTagData
    private(set) var tagListViews: [CYLTagListView] = []
    /// Configuration files that could not be read (e.g. YAML without CYLTabBarController), with the reason.
    private(set) var configurationErrors: [String: Error] = [:]
    private var sources: [CYLFoldStyleMenuSource] = []
    let scrollView = UIScrollView()
    let stackView = UIStackView()

    static let configurationFiles = ["fold-styles.json", "fold-styles.plist", "fold-styles.yaml", "fold-styles.xml"]

    init(data: CYLTagData) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    static func fold(_ position: CYLMenuFoldControlPosition, _ content: CYLMenuFoldControlContent) -> CYLMenuFoldControl {
        CYLMenuFoldControl(position: position, content: content)
    }

    /// The demos made with the initialization parameters.
    /// The demos made with the initialization parameters: the fold control styles, then the title styles.
    func demos() -> [Demo] {
        [
            // Fold controls.
            Demo(title: CYLTagEditorLocalizedString("底部箭头（淘宝评价筛选）"), foldControl: Self.fold(.bottom, .icon),
                 titleImage: "star.bubble", showsSectionHeaders: false, groups: [0]),
            Demo(title: CYLTagEditorLocalizedString("底部：文字 + 箭头"), foldControl: Self.fold(.bottom, .iconAndTitle),
                 titleImage: "briefcase", showsSectionHeaders: false, groups: [2]),
            Demo(title: CYLTagEditorLocalizedString("底部：仅文字"), foldControl: Self.fold(.bottom, .title),
                 titleImage: "heart", showsSectionHeaders: false, groups: [3]),
            Demo(title: CYLTagEditorLocalizedString("右上角：文字 + 箭头（原分类菜单）"), foldControl: Self.fold(.topTrailing, .iconAndTitle),
                 titleImage: "square.grid.2x2", groups: [0, 2]),
            Demo(title: CYLTagEditorLocalizedString("右上角：仅箭头"), foldControl: Self.fold(.topTrailing, .icon),
                 titleImage: "chevron.down.square", groups: [1, 3]),
            Demo(title: CYLTagEditorLocalizedString("左上角：文字 + 箭头"), foldControl: Self.fold(.topLeading, .iconAndTitle),
                 titleImage: "arrow.left.square", groups: [2, 4]),
            Demo(title: CYLTagEditorLocalizedString("标题居中，右上角仅文字"), foldControl: Self.fold(.topTrailing, .title),
                 titlePosition: .topCenter, titleImage: "text.aligncenter", groups: [5, 0]),
            // Title styles: the title is a tag view (icon and/or title, horizontal).
            Demo(title: CYLTagEditorLocalizedString("标题：图标 + 文字（左上角）"), foldControl: Self.fold(.bottom, .icon),
                 titleImage: "tag", showsSectionHeaders: false, groups: [1]),
            Demo(title: nil, foldControl: Self.fold(.bottom, .icon), titleImage: "person.2", showsSectionHeaders: false, groups: [0]),
            Demo(title: CYLTagEditorLocalizedString("标题：仅文字（居中）"), foldControl: Self.fold(.bottom, .iconAndTitle),
                 titlePosition: .topCenter, showsSectionHeaders: false, groups: [4]),
            Demo(title: CYLTagEditorLocalizedString("标题：图标 + 文字（居中、绿色）"), foldControl: Self.fold(.bottom, .icon),
                 titlePosition: .topCenter, titleImage: "leaf", titleColor: CYLTagEditorViewController.green,
                 showsSectionHeaders: false, groups: [3]),
            Demo(title: CYLTagEditorLocalizedString("标题：文字 + 图标（图标在后）"), foldControl: Self.fold(.bottom, .icon),
                 titleImage: "chevron.right", titleImageTrailing: true, showsSectionHeaders: false, groups: [5]),
        ]
    }

    /// The title look of a demo: the core's default (bold headline) with the demo's color and icon placement.
    static func titleStyle(for demo: Demo) -> CYLMenuStyle {
        let style = CYLTagListView.defaultTitleStyle()
        if let color = demo.titleColor {
            for state in [UIControl.State.normal, .selected, .disabled] {
                style.appearance(for: state).textColor = color
                style.setIconColor(color, for: state)
            }
        }
        if demo.titleImageTrailing {
            style.imagePlacement = .trailing
            style.imageSize = CGSize(width: 14, height: 14)
        }
        return style
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // navigationItem, not title: a view controller's title would replace its tab's title.
        navigationItem.title = CYLTagEditorLocalizedString("折叠样式")
        view.backgroundColor = .systemGroupedBackground

        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -12),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
        ])

        let groups = data.groups ?? [CYLTagGroup(title: CYLTagEditorLocalizedString("我的标签"), tags: data.tags)]
        for demo in demos() {
            // The styles are given when the view is created; the title is the core's title view.
            let list = CYLTagListView(foldControl: demo.foldControl, title: demo.title,
                                      titleImage: demo.titleImage.flatMap { UIImage(systemName: $0) }, titlePosition: demo.titlePosition)
            list.titleStyle = Self.titleStyle(for: demo)
            if demo.title == nil {
                list.titleView.accessibilityLabel = CYLTagEditorLocalizedString("标题：仅图标")
            }
            let style = CYLTagEditorViewController.tagStyle()
            style.backgroundColor = .secondarySystemGroupedBackground
            list.style = style
            list.selectionMode = .multiple
            list.defaultVisibleRows = 1
            list.isScrollEnabled = false
            list.showsSectionHeaders = demo.showsSectionHeaders
            let source = CYLFoldStyleMenuSource(sections: demo.groups.compactMap { $0 < groups.count ? groups[$0] : nil })
            sources.append(source)
            list.menuDataSource = source
            add(list)
            list.reloadMenuData()
        }
        // The same parameters from configuration files of the current language.
        for file in Self.configurationFiles {
            guard let path = CYLTagEditorLocalization.resourceBundle.path(forResource: file, ofType: nil) else { continue }
            do {
                // Everything (fold control, title, style, sections) comes from the file.
                add(try CYLTagListView(configurationFile: path))
            } catch {
                configurationErrors[file] = error
                add(errorLabel(file: file, error: error))
            }
        }
    }

    private func add(_ list: CYLTagListView) {
        list.layer.cornerRadius = 10
        list.layer.masksToBounds = true
        tagListViews.append(list)
        let container = UIView()
        list.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(list)
        NSLayoutConstraint.activate([
            list.topAnchor.constraint(equalTo: container.topAnchor),
            list.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            list.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            list.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
        ])
        stackView.addArrangedSubview(container)
    }

    private func add(_ label: UILabel) {
        stackView.addArrangedSubview(label)
    }

    private func errorLabel(file: String, error: Error) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .systemRed
        label.text = "  \(file): \(error.localizedDescription)"
        return label
    }

    /// Expands the first section of every list, as tapping each fold control does.
    func expandAll() {
        for list in tagListViews where list.canFoldSection(0) {
            list.setExpanded(true, forSection: 0, animated: false)
        }
    }

    /// Scrolls to the lists made from configuration files.
    func scrollToConfigurationFiles() {
        view.layoutIfNeeded()
        let demosCount = demos().count
        guard stackView.arrangedSubviews.count > demosCount else { return }
        let target = stackView.arrangedSubviews[demosCount]
        let y = min(target.frame.minY, max(0, scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom))
        scrollView.setContentOffset(CGPoint(x: 0, y: y - scrollView.adjustedContentInset.top), animated: false)
    }
}
