//
//  CYLTagCloudSample.swift
//  CYLMenuExample
//
//  kaedea/android-tagview's sample in Swift: MainActivity ("TagView Sample"), SubActivity (Activity Result),
//  ListViewActivity, RecyclerViewActivity, and the hot search screen of its README (YY). The core does the drawing;
//  these screens pass the data and the style values, and handle taps.
//

import UIKit
import CollectionViewClassifyMenu
import CYLSearchViewController

/// android-tagview's sample data (res/values/arrays.xml).
enum CYLTagCloudSampleData {
    static let continents = ["AFRICA", "EUROPE", "ASIA", "NORTH AMERICA", "SOUTH AMERICA", "ANTARCTICA", "AUSTRALIA"]
    static let colors = ["#00BFFF", "#E91E63", "#F44336", "#9C27B0", "#673AB7"]

    static func color(_ index: Int) -> UIColor? {
        CYLMenuColorFromString(colors[index])
    }

    /// The tags of MainActivity's onCreate, in order. Corner radii are android pixels divided by 3 (xxhdpi points).
    static func mainTags() -> [CYLTag] {
        var tags = continents.map { CYLTag(title: $0) }
        for index in 1..<colors.count {
            let tag = CYLTag(title: CYLExampleLocalizedString("彩色文字"))
            tag.textColor = color(index)
            tags.append(tag)
        }
        for index in 0..<colors.count {
            tags.append(CYLTag(title: CYLExampleLocalizedString("彩色背景"), backgroundColorHex: colors[index]))
        }
        let borders: [(CGFloat, UIColor?)] = [(1, nil), (2, color(1)), (3, color(3))]
        for (width, color) in borders {
            let tag = CYLTag(title: CYLExampleLocalizedString("边框"))
            tag.borderWidth = width
            tag.borderColor = color
            tags.append(tag)
        }
        for radius: CGFloat in [CYLTagCornerRadiusSquare, 20.0 / 3, 60.0 / 3] {
            let tag = CYLTag(title: CYLExampleLocalizedString("圆角"))
            tag.cornerRadius = radius
            tags.append(tag)
        }
        let deletable = CYLTag(title: CYLExampleLocalizedString("可删除"))
        deletable.isDeletable = true
        tags.append(deletable)
        let custom = CYLTag(title: CYLExampleLocalizedString("自定义背景"))
        custom.textColor = color(0)
        custom.backgroundImage = customBackground()
        tags.append(custom)
        let detail = CYLTag(title: CYLExampleLocalizedString("详情标签"))
        detail.textColor = .white
        detail.backgroundColor = CYLMenuColorFromString("#DDDDDD")
        detail.highlightedBackgroundColor = CYLMenuColorFromString("#555555")
        detail.cornerRadius = 20 / 3
        detail.textSize = 14
        detail.borderWidth = 1
        detail.borderColor = .white
        detail.isDeletable = true
        tags.append(detail)
        for (index, tag) in tags.enumerated() {
            tag.identifier = index
        }
        return tags
    }

    /// bg_tag: a white rounded rectangle, stretched.
    static func customBackground() -> UIImage {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 24, height: 24)).image { _ in
            UIColor.white.setFill()
            UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 24, height: 24), cornerRadius: 8).fill()
        }
        return image.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}

/// MainActivity.
final class CYLTagCloudSampleViewController: UIViewController {

    private(set) var tagListView: CYLTagListView!
    private(set) var textField: UITextField!
    /// Random numbers below the given bound; replaced in tests.
    var random: (Int) -> Int = { Int.random(in: 0..<$0) }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = CYLExampleLocalizedString("标签视图示例")
        view.backgroundColor = UIColor(white: 0.93, alpha: 1)
        let github = UIBarButtonItem(image: UIImage(systemName: "chevron.left.forwardslash.chevron.right"), primaryAction: UIAction { _ in
            if let url = URL(string: "https://github.com/kaedea/") {
                UIApplication.shared.open(url)
            }
        })
        github.accessibilityLabel = CYLExampleLocalizedString("在 GitHub 上查看")
        navigationItem.rightBarButtonItem = github

        // activity_main.xml: lineMargin 5dp, tagMargin 3dp, textPadding 10dp × 3dp.
        let list = CYLTagListView()
        list.style = .tagCloud()
        list.lineSpacing = 5
        list.interitemSpacing = 3
        list.tagContentInsets = UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10)
        list.addTags(CYLTagCloudSampleData.mainTags())
        list.tagClickHandler = { [weak self] position, tag in
            self?.toast(CYLExampleLocalizedString("点击标签 id = %ld，位置 = %ld", tag.identifier, position))
        }
        list.tagDeleteHandler = { [weak self] position, tag in
            self?.toast(CYLExampleLocalizedString("删除标签 id = %ld，位置 = %ld", tag.identifier, position))
        }
        tagListView = list

        let field = CYLAndroidSample.textField(placeholder: CYLExampleLocalizedString("输入标签文字"),
                                             label: CYLExampleLocalizedString("标签文字"))
        textField = field
        let blue = CYLTagCloudSampleData.color(0) ?? .systemBlue
        let rows = [
            [CYLAndroidSample.button(CYLExampleLocalizedString("添加标签"), identifier: "sample.addTag", color: blue) { [weak self] in self?.addTag() },
             CYLAndroidSample.button(CYLExampleLocalizedString("页面返回结果"), identifier: "sample.activityResult", color: blue) { [weak self] in self?.openActivityResult() }],
            [CYLAndroidSample.button(CYLExampleLocalizedString("列表视图"), identifier: "sample.listView", color: blue) { [weak self] in
                self?.navigationController?.pushViewController(CYLTagCloudListViewController(), animated: true)
            },
             CYLAndroidSample.button(CYLExampleLocalizedString("回收视图"), identifier: "sample.recyclerView", color: blue) { [weak self] in
                self?.navigationController?.pushViewController(CYLTagCloudRecyclerViewController(), animated: true)
            }],
            [CYLAndroidSample.button(CYLExampleLocalizedString("YY 热门搜索"), identifier: "sample.hotSearch", color: .systemOrange) { [weak self] in
                self?.navigationController?.pushViewController(CYLHotSearchViewController(), animated: true)
            }],
        ].map { buttons -> UIStackView in
            let row = UIStackView(arrangedSubviews: buttons)
            row.spacing = 8
            row.distribution = .fillEqually
            return row
        }
        let controls = UIStackView(arrangedSubviews: [field] + rows)
        controls.axis = .vertical
        controls.spacing = 8
        // The tags take the room left above the controls.
        list.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        list.setContentCompressionResistancePriority(.defaultLow - 1, for: .vertical)
        controls.setContentHuggingPriority(.required, for: .vertical)
        for subview in [list, controls] as [UIView] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            list.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            list.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            list.bottomAnchor.constraint(equalTo: controls.topAnchor, constant: -8),
            controls.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            controls.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            controls.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -8),
        ])
    }

    /// tv_add: the typed text or "ADD A TAG", deletable half the time, one of the five colors.
    func addTag() {
        let text = textField.text ?? ""
        let tag = CYLTag(title: text.isEmpty ? CYLExampleLocalizedString("添加标签") : text)
        tag.isDeletable = random(2) == 0
        tag.backgroundColor = CYLTagCloudSampleData.color(random(5))
        tag.identifier = tagListView.tags.count
        tagListView.addTag(tag)
        tagListView.scrollToItem(at: IndexPath(item: tagListView.tags.count - 1, section: 0), animated: true)
    }

    /// startActivityForResult(SubActivity): its button adds a tag here.
    func openActivityResult() {
        let sub = CYLTagCloudSubViewController()
        sub.onResult = { [weak self] in
            self?.tagListView.addTag(CYLTag(title: CYLExampleLocalizedString("返回结果后添加")))
        }
        navigationController?.pushViewController(sub, animated: true)
    }

    private func toast(_ text: String) {
        CYLAndroidSample.toast(text, in: view)
    }
}

/// SubActivity: "Add Tag" returns RESULT_OK.
final class CYLTagCloudSubViewController: UIViewController {
    var onResult: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = CYLExampleLocalizedString("子页面")
        view.backgroundColor = .systemBackground
        let button = CYLAndroidSample.button(CYLExampleLocalizedString("添加标签并返回"), identifier: "sample.finish",
                                             color: CYLTagCloudSampleData.color(0) ?? .systemBlue) { [weak self] in
            self?.finish()
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
        ])
    }

    func finish() {
        onResult?()
        navigationController?.popViewController(animated: true)
    }
}

/// A table cell with a tag list (item_list_tag.xml): the list does not scroll, the cell is as tall as its tags.
final class CYLTagCloudListCell: UITableViewCell {
    let tagListView = CYLTagListView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        tagListView.style = .tagCloud()
        tagListView.lineSpacing = 5
        tagListView.interitemSpacing = 3
        tagListView.tagContentInsets = UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10)
        tagListView.isScrollEnabled = false
        tagListView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tagListView)
        NSLayoutConstraint.activate([
            tagListView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tagListView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tagListView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tagListView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    /// The adapter's getView: removeAllTags, then the row's tags.
    func show(_ tags: [CYLTag]) {
        tagListView.replaceTags(tags)
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontal: UILayoutPriority,
                                          verticalFittingPriority vertical: UILayoutPriority) -> CGSize {
        CGSize(width: targetSize.width, height: tagListView.heightThatFitsWidth(targetSize.width))
    }
}

/// ListViewActivity: 51 rows, each with three tags of the row's text.
final class CYLTagCloudListViewController: UITableViewController {

    static func tags(forRow row: Int) -> [CYLTag] {
        ["#F06292", "#90CAF9", "#80DEEA"].map { CYLTag(title: CYLExampleLocalizedString("条目 %ld", row), backgroundColorHex: $0) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = CYLExampleLocalizedString("ListView 示例")
        tableView.register(CYLTagCloudListCell.self, forCellReuseIdentifier: "tags")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        51
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tags", for: indexPath) as! CYLTagCloudListCell
        cell.show(Self.tags(forRow: indexPath.row))
        return cell
    }
}

/// RecyclerViewActivity: 21 text rows and a footer row with two tags.
final class CYLTagCloudRecyclerViewController: UITableViewController {
    static var texts: [String] { Array(repeating: CYLExampleLocalizedString("文本"), count: 21) }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = CYLExampleLocalizedString("RecyclerView 示例")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "text")
        tableView.register(CYLTagCloudListCell.self, forCellReuseIdentifier: "tags")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Self.texts.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < Self.texts.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = Self.texts[indexPath.row]
            cell.contentConfiguration = content
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "tags", for: indexPath) as! CYLTagCloudListCell
        cell.show([1, 2].map { CYLTag(title: CYLExampleLocalizedString("页脚 %ld", $0)) })
        return cell
    }
}

/// The hot search screen of android-tagview's README (YY): an orange search bar with 取消, then 热门搜索 tags, some
/// with a 神 or 热 badge.
final class CYLHotSearchViewController: UIViewController {

    private(set) var searchBar: CYLSearchBarView!
    private(set) var tagListView: CYLTagListView!

    static let orange = UIColor(red: 0.95, green: 0.56, blue: 0.2, alpha: 1)
    static let blue = UIColor(red: 0.29, green: 0.64, blue: 0.94, alpha: 1)
    static let red = UIColor(red: 0.9, green: 0.31, blue: 0.29, alpha: 1)

    /// The badge before a hot search: 神 for hit songs (blue), 热 for trending (red).
    enum Badge {
        case song, trending

        /// The glyph in the badge (one character: 神 / 热 in Chinese).
        var text: String { CYLExampleLocalizedString(self == .song ? "神" : "热") }
        /// What VoiceOver reads after the title.
        var accessibilityLabel: String { CYLExampleLocalizedString(self == .song ? "神曲" : "热门") }
        var color: UIColor { self == .song ? CYLHotSearchViewController.blue : CYLHotSearchViewController.red }
    }

    /// (title, badge); the titles are sample data, as in the screenshot.
    static let hotSearches: [(String, Badge?)] = [
        ("入戏太深混合串烧版", .song), ("他和她", .song), ("妤宸", nil), ("赛菲尔", nil), ("小西瓜", .trending),
        ("入戏太深", .song), ("小虾米", nil), ("羽冰", nil), ("梦梦", nil), ("神曲不跳转呀呀呀56567", .song),
    ]

    static func hotTags() -> [CYLTag] {
        hotSearches.map { title, badge in
            let tag = CYLTag(title: title)
            if let badge {
                tag.badgeText = badge.text
                tag.badgeAccessibilityLabel = badge.accessibilityLabel
                tag.textColor = badge.color
            }
            return tag
        }
    }

    static func hotStyle() -> CYLMenuStyle {
        let style = CYLMenuStyle()
        for appearance in [style.normalAppearance, style.selectedAppearance] {
            appearance.backgroundColor = .white
            appearance.borderColor = UIColor(white: 0.88, alpha: 1)
            appearance.borderWidth = 1
            appearance.textColor = UIColor(white: 0.13, alpha: 1)
            appearance.cornerRadius = 0
            appearance.font = .systemFont(ofSize: 16)
        }
        style.tagContentInsets = UIEdgeInsets(top: 9, left: 16, bottom: 9, right: 16)
        style.imageSize = CGSize(width: 18, height: 18)
        style.imageTitleSpacing = 6
        style.interitemSpacing = 8
        style.lineSpacing = 10
        style.highlightedBackgroundColor = UIColor(white: 0.94, alpha: 1)
        style.headerIndicatorColor = orange
        style.headerFont = .systemFont(ofSize: 18)
        style.headerTextColor = UIColor(white: 0.13, alpha: 1)
        style.headerHeight = 48
        style.backgroundColor = .white
        return style
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let bar = CYLSearchBarView()
        bar.backgroundColor = Self.orange
        bar.fieldBackgroundColor = UIColor(red: 0.99, green: 0.91, blue: 0.82, alpha: 1)
        bar.fieldCornerRadius = 4
        bar.placeholder = CYLExampleLocalizedString("主播昵称/直播间ID/神曲名")
        bar.placeholderColor = UIColor(white: 0.6, alpha: 1)
        bar.searchIconTintColor = UIColor(white: 0.6, alpha: 1)
        bar.showsCancelButton = true
        bar.cancelButtonTitle = CYLExampleLocalizedString("取消")
        bar.cancelButton.tintColor = .white
        bar.delegate = self
        searchBar = bar

        let list = CYLTagListView()
        list.style = Self.hotStyle()
        list.addTags(Self.hotTags())
        list.tagDataSource.sectionTitle = CYLExampleLocalizedString("热门搜索")
        list.showsSectionHeaders = true
        list.tagClickHandler = { [weak self] _, tag in
            self?.searchBar.text = tag.title
            if let view = self?.view {
                CYLAndroidSample.toast(CYLExampleLocalizedString("搜索「%@」", tag.title), in: view)
            }
        }
        tagListView = list

        let barBackground = UIView()
        barBackground.backgroundColor = Self.orange
        for subview in [barBackground, bar, list] as [UIView] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            barBackground.topAnchor.constraint(equalTo: view.topAnchor),
            barBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            barBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            barBackground.bottomAnchor.constraint(equalTo: bar.bottomAnchor),
            bar.topAnchor.constraint(equalTo: guide.topAnchor),
            bar.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            list.topAnchor.constraint(equalTo: bar.bottomAnchor),
            list.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            list.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension CYLHotSearchViewController: CYLSearchBarViewDelegate {

    func searchBarViewCancelButtonClicked(_ searchBarView: CYLSearchBarView) {
        navigationController?.popViewController(animated: true)
    }

    func searchBarViewSearchButtonClicked(_ searchBarView: CYLSearchBarView) {
        searchBarView.textField.resignFirstResponder()
    }
}
