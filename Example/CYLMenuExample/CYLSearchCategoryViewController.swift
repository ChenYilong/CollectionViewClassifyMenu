//
//  CYLSearchCategoryViewController.swift
//  CYLMenuExample
//
//  场景二（搜索页）：内嵌的分类 TabBar（CYLTabBarController，位于底部）切换「找人/动态/八卦/职位」，
//  每个 Tab 是一个标签页；职位页左侧是职位分类，分组右侧是宿主提供的行业选择按钮。
//

import UIKit
import CollectionViewClassifyMenu
import CYLTabBarController

@objc enum CYLSearchCategory: Int {
    case people = 0
    case feeds
    case gossip
    case jobs
}

private let kJobCategoryWidth: CGFloat = 90
private let kJobCategoryCell = "JobCategoryCell"

// MARK: - Category page

/// One tab of the category tab bar: a tag list, plus the job category sidebar on the 职位 page.
final class CYLSearchCategoryPageViewController: UIViewController {
    var category: CYLSearchCategory = .people
    var tagListView = CYLTagListView()
    var sidebar: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tagListView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tagListView)
        // The safe area ends above the tab bar at the bottom.
        let safe = view.safeAreaLayoutGuide
        var leading = view.leadingAnchor
        if let sidebar {
            sidebar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(sidebar)
            NSLayoutConstraint.activate([
                sidebar.topAnchor.constraint(equalTo: safe.topAnchor),
                sidebar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                sidebar.widthAnchor.constraint(equalToConstant: kJobCategoryWidth),
                sidebar.bottomAnchor.constraint(equalTo: safe.bottomAnchor),
            ])
            leading = sidebar.trailingAnchor
        }
        NSLayoutConstraint.activate([
            tagListView.topAnchor.constraint(equalTo: safe.topAnchor),
            tagListView.leadingAnchor.constraint(equalTo: leading),
            tagListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tagListView.bottomAnchor.constraint(equalTo: safe.bottomAnchor),
        ])
    }
}

// MARK: - Search screen

final class CYLSearchCategoryViewController: UIViewController {

    private(set) var searchBar = UISearchBar()
    /// The category tabs: a CYLTabBarController embedded in this screen, its bar at the bottom.
    private(set) var categoryTabBarController: CYLTabBarController!
    private(set) var jobCategoryTableView = UITableView(frame: .zero, style: .plain)
    private(set) var industryButton = UIButton(type: .system)
    private(set) var category: CYLSearchCategory = .people
    private(set) var industry: String = CYLSearchCategoryViewController.industries()[0]
    private(set) var pages: [CYLSearchCategoryPageViewController] = []
    /// One data source per tag list; the lists hold them weakly.
    private(set) var menuSources: [CYLSearchCategory: CYLExampleMenuSource] = [:]
    let jobCategories = ["开发", "测试", "运维/DBA", "硬件", "产品", "运营", "设计", "编辑/记者", "游戏", "市场BD"]
    private(set) var jobCategoryIndex = 0

    /// Tags of the selected category (the job keywords on the 职位 tab).
    var tagListView: CYLTagListView {
        tagListView(for: category)
    }

    static func industries() -> [String] {
        ["IT互联网", "金融", "教育培训", "医疗健康", "房地产"]
    }

    static let jobKeywords: [String: [String]] = [
        "开发": ["后端开发", "PHP", "Java", "Python", ".NET", "C#", "C/C++", "Ruby", "Hadoop", "Node.js",
               "Perl", "搜索算法", "推荐算法", "数据挖掘", "机器学习", "信息检索", "NLP", "语音算法",
               "视频算法", "图像算法", "全栈", "Linux", "广告算法", "GO", "ASP", "Shell", "VB",
               "Delphi", "前端开发", "Web前端", "Flash"],
        "测试": ["测试工程师", "自动化测试", "性能测试", "测试开发", "白盒测试", "游戏测试", "手机测试"],
        "运维/DBA": ["运维工程师", "DBA", "系统管理员", "网络工程师", "IT支持", "SRE"],
        "硬件": ["嵌入式", "单片机", "电路设计", "FPGA", "驱动开发", "射频工程师"],
        "产品": ["产品经理", "产品助理", "产品总监", "数据产品", "游戏策划", "移动产品"],
        "运营": ["内容运营", "用户运营", "活动运营", "新媒体", "社区运营", "数据运营", "SEO"],
        "设计": ["UI设计", "交互设计", "视觉设计", "平面设计", "用户研究", "动效设计"],
        "编辑/记者": ["编辑", "记者", "文案", "主编", "撰稿人"],
        "游戏": ["游戏开发", "游戏策划", "游戏美术", "Unity3D", "Cocos2d-x"],
        "市场BD": ["市场推广", "商务拓展", "品牌", "公关", "渠道", "大客户"],
    ]

    static func sections(for category: CYLSearchCategory) -> [CYLExampleMenuSection] {
        switch category {
        case .people:
            return [CYLExampleMenuSection(title: CYLExampleLocalizedString("认识同行"), titles: ["百度研发", "腾讯工程师", "搜狗开发", "腾讯开发", "搜狗研究员"]),
                    CYLExampleMenuSection(title: CYLExampleLocalizedString("找投资"), titles: ["创投", "IDG资本", "晨兴资本", "合伙人", "投资经理"]),
                    CYLExampleMenuSection(title: CYLExampleLocalizedString("谈合作"), titles: ["CEO", "副总裁", "VP", "总经理", "总监"]),
                    CYLExampleMenuSection(title: CYLExampleLocalizedString("挖人才"), titles: ["Java", "Android", "JS", "C++", "HTML/CSS", "iOS", "PHP", "前端"])]
        case .feeds:
            return [CYLExampleMenuSection(title: CYLExampleLocalizedString("热门动态关键词"),
                                          titles: ["投资", "创业", "o2o", "社交", "招聘", "运营", "线下聚会", "脉脉", "融资", "在线教育", "硬件", "电商", "产品经理"])]
        case .gossip:
            return [CYLExampleMenuSection(title: CYLExampleLocalizedString("热门词"),
                                          titles: ["百度", "新浪", "程序猿", "离职", "阿里", "360", "创业", "工资", "跳槽", "小三", "裁员", "加班", "女同事", "产品经理", "投资人", "老板"]),
                    CYLExampleMenuSection(title: CYLExampleLocalizedString("我关注的标签"), titles: ["社交", "移动", "程序猿"])]
        case .jobs:
            return []
        }
    }

    static func placeholder(for category: CYLSearchCategory) -> String {
        let keys = ["搜人名,职位,公司...", "搜动态", "搜八卦", "搜职位"]
        return CYLExampleLocalizedString(keys[category.rawValue])
    }

    static func maimaiStyle() -> CYLMenuStyle {
        let style = CYLMenuStyle()
        style.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 14),
                                      .foregroundColor: UIColor(white: 0.35, alpha: 1)], for: .normal)
        style.normalAppearance.borderColor = UIColor(white: 0.8, alpha: 1)
        style.normalAppearance.borderWidth = 1
        style.normalAppearance.cornerRadius = 2
        style.normalAppearance.margin = 14
        style.itemHeight = 32
        style.interitemSpacing = 14
        style.lineSpacing = 14
        style.sectionInsets = UIEdgeInsets(top: 4, left: 24, bottom: 14, right: 16)
        style.headerHeight = 32
        style.headerFont = .systemFont(ofSize: 13)
        style.headerTextColor = UIColor(white: 0.6, alpha: 1)
        return style
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        navigationItem.titleView = searchBar

        jobCategoryTableView.dataSource = self
        jobCategoryTableView.delegate = self
        jobCategoryTableView.rowHeight = 50
        jobCategoryTableView.separatorStyle = .none
        jobCategoryTableView.backgroundColor = .secondarySystemBackground
        jobCategoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: kJobCategoryCell)

        // A header accessory supplied by the host, not drawn by the menu.
        industryButton.titleLabel?.font = .systemFont(ofSize: 13)
        industryButton.showsMenuAsPrimaryAction = true
        updateIndustryButton()

        let titles = ["找人", "动态", "八卦", "职位"]
        let symbols = ["person.2", "bubble.left.and.bubble.right", "flame", "briefcase"]
        var attributes: [[AnyHashable: Any]] = []
        var pages: [CYLSearchCategoryPageViewController] = []
        for index in titles.indices {
            let page = CYLSearchCategoryPageViewController()
            page.category = CYLSearchCategory(rawValue: index) ?? .people
            page.tagListView = makeTagListView()
            if page.category == .jobs {
                page.sidebar = jobCategoryTableView
            }
            pages.append(page)
            let image = UIImage(systemName: symbols[index]) ?? UIImage()
            attributes.append([
                CYLTabBarItemTitle: CYLExampleLocalizedString(titles[index]),
                CYLTabBarItemImage: image,
                CYLTabBarItemSelectedImage: UIImage(systemName: symbols[index] + ".fill") ?? image,
            ])
        }
        self.pages = pages
        for page in pages {
            reloadTags(for: page.category)
        }

        // The second tab bar of the app: the category tabs of this screen, at the bottom like
        // every tab bar. The root tab bar is hidden while this screen is pushed.
        let tabs = CYLTabBarController(viewControllers: pages, tabBarItemsAttributes: attributes)
        tabs.delegate = self
        categoryTabBarController = tabs
        addChild(tabs)
        tabs.view.frame = view.bounds
        tabs.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tabs.view)
        tabs.didMove(toParent: self)
        select(.people)
    }

    private func makeTagListView() -> CYLTagListView {
        let view = CYLTagListView()
        view.style = Self.maimaiStyle()
        view.selectionMode = .none
        view.menuDelegate = self
        return view
    }

    // MARK: Category

    func tagListView(for category: CYLSearchCategory) -> CYLTagListView {
        pages[category.rawValue].tagListView
    }

    func select(_ category: CYLSearchCategory) {
        loadViewIfNeeded()
        categoryTabBarController.selectedIndex = category.rawValue
        categoryDidChange(category)
    }

    private func categoryDidChange(_ category: CYLSearchCategory) {
        self.category = category
        searchBar.placeholder = Self.placeholder(for: category)
        if category == .jobs {
            jobCategoryTableView.reloadData()
            selectJobCategory(at: jobCategoryIndex)
        }
    }

    private func reloadTags(for category: CYLSearchCategory) {
        let sections: [CYLExampleMenuSection]
        if category == .jobs {
            let name = jobCategories[jobCategoryIndex]
            let section = CYLExampleMenuSection(title: CYLExampleLocalizedString("热搜职位关键词:"), titles: Self.jobKeywords[name] ?? [])
            section.accessoryView = industryButton
            sections = [section]
        } else {
            sections = Self.sections(for: category)
        }
        let source = CYLExampleMenuSource(sections: sections)
        menuSources[category] = source
        let view = tagListView(for: category)
        view.menuDataSource = source
        view.reloadMenuData()
    }

    func selectJobCategory(at index: Int) {
        jobCategoryIndex = min(max(index, 0), jobCategories.count - 1)
        let row = IndexPath(row: jobCategoryIndex, section: 0)
        jobCategoryTableView.selectRow(at: row, animated: false, scrollPosition: .none)
        reloadTags(for: .jobs)
    }

    func selectIndustry(_ industry: String) {
        self.industry = industry
        updateIndustryButton()
        tagListView(for: .jobs).reloadMenuData()
    }

    private func updateIndustryButton() {
        let industryName = CYLExampleLocalizedString(industry)
        industryButton.setTitle(CYLExampleLocalizedString("行业: %@ ▾", industryName), for: .normal)
        // Without the "▾" glyph, which VoiceOver would read aloud.
        industryButton.accessibilityLabel = CYLExampleLocalizedString("行业 %@", industryName)
        industryButton.accessibilityHint = CYLExampleLocalizedString("选择行业")
        industryButton.sizeToFit()
        let actions = Self.industries().map { industry in
            let action = UIAction(title: CYLExampleLocalizedString(industry)) { [weak self] _ in
                self?.selectIndustry(industry)
            }
            action.state = industry == self.industry ? .on : .off
            return action
        }
        industryButton.menu = UIMenu(title: CYLExampleLocalizedString("行业"), children: actions)
    }
}

// MARK: - CYLMenuDelegate

extension CYLSearchCategoryViewController: CYLMenuDelegate {

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        for (category, source) in menuSources where tagListView(for: category) === (menu as AnyObject) {
            searchBar.text = source.item(at: indexPath).title
        }
    }
}

// MARK: - UITabBarControllerDelegate

extension CYLSearchCategoryViewController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let page = viewController as? CYLSearchCategoryPageViewController {
            categoryDidChange(page.category)
        }
    }
}

// MARK: - UITableView

extension CYLSearchCategoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        jobCategories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kJobCategoryCell, for: indexPath)
        var content = UIListContentConfiguration.cell()
        content.text = CYLExampleLocalizedString(jobCategories[indexPath.row])
        content.textProperties.alignment = .center
        content.textProperties.font = .systemFont(ofSize: 15)
        // Longer translations ("Development") wrap or shrink instead of being cut off.
        content.textProperties.numberOfLines = 2
        content.textProperties.adjustsFontSizeToFitWidth = true
        content.textProperties.minimumScaleFactor = 0.7
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        let selected = UIView()
        selected.backgroundColor = .systemBackground
        cell.selectedBackgroundView = selected
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectJobCategory(at: indexPath.row)
    }
}

// MARK: - UISearchBarDelegate

extension CYLSearchCategoryViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
