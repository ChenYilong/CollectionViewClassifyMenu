//
//  CYLReviewListViewController.swift
//  CYLMenuExample
//
//  场景一（评价页）：多选评价筛选，折叠为两行，旋转箭头展开/收起；每次选择后按全部所选条件（AND）
//  刷新下方评价列表。内存筛选、网络筛选与数据库筛选（SQLite）是三种场景，通过顶部开关切换。
//

import UIKit
import CollectionViewClassifyMenu

private let kReviewCellIdentifier = "ReviewCell"

final class CYLReviewListViewController: UIViewController {

    private(set) var filterView: CYLTagListView!
    private(set) var tableView = UITableView(frame: .zero, style: .plain)
    private(set) var modeControl: UISegmentedControl!
    /// The last tap and the query state, shown above the list.
    private(set) var statusLabel = UILabel()
    private(set) var mode: CYLReviewFilteringMode
    private(set) var query: CYLReviewQuerying
    private(set) var selectedFilters: [CYLReviewFilter] = []
    private(set) var visibleReviews: [CYLReview] = []
    private let spinner = UIActivityIndicatorView(style: .medium)
    private(set) var menuSource: CYLExampleMenuSource?
    private var filterHeight: NSLayoutConstraint?
    private let initialFilterIndex: Int
    private(set) var lastEvent: String?

    /// The orange review filter style, also used for the product page preview.
    static func reviewFilterStyle() -> CYLMenuStyle {
        let orange = UIColor(red: 1, green: 0.31, blue: 0, alpha: 1)
        let style = CYLMenuStyle()
        // Title and icon per state, as on a CYLFlatDesignTabBarItem.
        let font = UIFont.systemFont(ofSize: 12)
        style.setTitleTextAttributes([.font: font, .foregroundColor: UIColor(white: 0.3, alpha: 1)], for: .normal)
        style.setTitleTextAttributes([.font: font, .foregroundColor: UIColor.white], for: .selected)
        style.setTitleTextAttributes([.font: font, .foregroundColor: UIColor(white: 0.7, alpha: 1)], for: .disabled)
        style.imageSize = CGSize(width: 13, height: 13)
        style.imageTitleSpacing = 3
        // The box per state, as on a CYLBadgeView.
        for appearance in [style.normalAppearance, style.selectedAppearance, style.disabledAppearance] {
            appearance.cornerRadius = 2
            appearance.margin = 8
            appearance.borderWidth = 0.5
            appearance.backgroundColor = UIColor(white: 0.96, alpha: 1)
            appearance.borderColor = UIColor(white: 0.88, alpha: 1)
        }
        style.selectedAppearance.backgroundColor = orange
        style.selectedAppearance.borderColor = orange
        style.itemHeight = 28
        style.interitemSpacing = 8
        style.lineSpacing = 10
        style.sectionInsets = UIEdgeInsets(top: 10, left: 12, bottom: 6, right: 12)
        style.foldControlColor = UIColor(white: 0.45, alpha: 1)
        return style
    }

    /// Opens with the filter at `index` of CYLReviewStore.filters selected (0 is "全部"), filtering in memory.
    convenience init(selectedFilterIndex index: Int) {
        self.init(selectedFilterIndex: index, mode: .memory)
    }

    init(selectedFilterIndex index: Int, mode: CYLReviewFilteringMode) {
        initialFilterIndex = index
        self.mode = mode
        query = Self.query(for: mode)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    static func query(for mode: CYLReviewFilteringMode) -> CYLReviewQuerying {
        switch mode {
        case .network: return CYLNetworkReviewQuery()
        case .database: return CYLDatabaseReviewQuery()
        default: return CYLMemoryReviewQuery()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let store = CYLReviewStore.shared()
        // A pushed screen, not a tab's root: its title can be set.
        title = CYLExampleLocalizedString("评价(%lu)", UInt(store.reviews.count))
        view.backgroundColor = .systemBackground

        modeControl = UISegmentedControl(items: [CYLExampleLocalizedString("内存筛选"), CYLExampleLocalizedString("网络筛选"),
                                                 CYLExampleLocalizedString("数据库筛选")])
        modeControl.selectedSegmentIndex = mode.rawValue
        modeControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        navigationItem.titleView = modeControl

        var items: [CYLExampleMenuItem] = []
        for filter in store.filters {
            let item = CYLExampleMenuItem(title: store.title(for: filter))
            item.image = filter.image
            item.value = filter
            item.isEnabled = !store.reviewsMatching(filter).isEmpty
            item.isExclusive = filter.identifier == "all"
            items.append(item)
        }
        let source = CYLExampleMenuSource(sections: [CYLExampleMenuSection(title: CYLExampleLocalizedString("评价"), items: items)])
        menuSource = source

        // Multiple choice, folded to two rows behind a chevron that turns when it expands.
        // The shopping app's review filter: the chevron alone below the tags, turned 180° when expanded.
        let filterView = CYLTagListView(foldControl: CYLMenuFoldControl(position: .footer, content: .icon))
        self.filterView = filterView
        filterView.translatesAutoresizingMaskIntoConstraints = false
        filterView.style = Self.reviewFilterStyle()
        filterView.selectionMode = .multiple
        filterView.showsSectionHeaders = false
        filterView.defaultVisibleRows = 2
        filterView.isScrollEnabled = false
        filterView.menuDelegate = self
        filterView.menuDataSource = source
        filterView.reloadMenuData()

        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.adjustsFontForContentSizeCategory = true
        statusLabel.textColor = .secondaryLabel
        statusLabel.numberOfLines = 0
        spinner.hidesWhenStopped = true
        let status = UIStackView(arrangedSubviews: [spinner, statusLabel])
        status.spacing = 6
        status.alignment = .center
        status.isLayoutMarginsRelativeArrangement = true
        status.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 8, trailing: 12)
        status.backgroundColor = .secondarySystemBackground
        status.translatesAutoresizingMaskIntoConstraints = false

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kReviewCellIdentifier)

        for subview in [filterView, status, tableView] as [UIView] {
            view.addSubview(subview)
        }
        let height = filterView.heightAnchor.constraint(equalToConstant: 0)
        filterHeight = height
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            filterView.topAnchor.constraint(equalTo: safe.topAnchor),
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            height,
            status.topAnchor.constraint(equalTo: filterView.bottomAnchor),
            status.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            status.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: status.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let index = max(0, min(initialFilterIndex, items.count - 1))
        let selected = IndexPath(item: index, section: 0)
        filterView.selectedIndexPaths = [selected]
        // A preselected chip hidden by folding would be confusing, so show it.
        if index >= filterView.numberOfVisibleItems(inSection: 0) {
            filterView.setExpanded(true, forSection: 0, animated: false)
        }
        lastEvent = CYLExampleLocalizedString("点击「%@」", source.item(at: selected).title)
        refreshReviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateFilterHeight()
    }

    private func updateFilterHeight() {
        guard let filterView, let filterHeight else { return }
        let height = filterView.heightThatFitsWidth(view.bounds.width)
        if abs(filterHeight.constant - height) > 0.5 {
            filterHeight.constant = height
        }
    }

    // MARK: Mode

    @objc private func modeChanged() {
        setMode(CYLReviewFilteringMode(rawValue: modeControl.selectedSegmentIndex) ?? .memory)
    }

    func setMode(_ mode: CYLReviewFilteringMode) {
        self.mode = mode
        modeControl?.selectedSegmentIndex = mode.rawValue
        query = Self.query(for: mode)
        if isViewLoaded {
            refreshReviews()
        }
    }

    // MARK: Filtering

    /// Selects filters by index (as if tapped one after another) and refreshes the list.
    func selectFilterIndexes(_ indexes: [Int]) {
        loadViewIfNeeded()
        for index in indexes {
            let indexPath = IndexPath(item: index, section: 0)
            filterView.selectItem(at: indexPath)
            if let title = menuSource?.item(at: indexPath).title {
                lastEvent = CYLExampleLocalizedString("点击「%@」", title)
            }
        }
        refreshReviews()
    }

    func refreshReviews() {
        guard let menuSource else { return }
        selectedFilters = filterView.selectedIndexPaths.compactMap { indexPath in
            guard let filter = menuSource.item(at: indexPath).value as? CYLReviewFilter, filter.identifier != "all" else { return nil }
            return filter
        }
        query.fetchReviewsMatching(selectedFilters) { [weak self] reviews in
            self?.show(reviews)
        }
        if query.isLoading {
            spinner.startAnimating()
            tableView.alpha = 0.5
            updateStatus()
        }
    }

    private func show(_ reviews: [CYLReview]) {
        visibleReviews = reviews
        spinner.stopAnimating()
        tableView.alpha = 1
        tableView.reloadData()
        updateEmptyState()
        updateStatus()
    }

    private func updateEmptyState() {
        guard visibleReviews.isEmpty else {
            tableView.backgroundView = nil
            return
        }
        let empty = UILabel()
        empty.text = CYLExampleLocalizedString("没有匹配的评价")
        empty.textAlignment = .center
        empty.textColor = .secondaryLabel
        tableView.backgroundView = empty
    }

    private func updateStatus() {
        // Keyword names are sample data; the other filter names are keys of the Example's table.
        let names = selectedFilters.map { $0.isKeyword ? $0.name : CYLExampleLocalizedString($0.name) }
        let selection = names.isEmpty ? CYLExampleLocalizedString("全部") : names.joined(separator: CYLExampleLocalizedString("、"))
        var lines = ["\(lastEvent ?? "") · \(CYLExampleLocalizedString("已选：%@", selection))"]
        let count = UInt(visibleReviews.count)
        switch mode {
        case .network:
            let network = query as? CYLNetworkReviewQuery
            let url = network?.lastRequestURL
            let queryString = url?.query.flatMap { $0.isEmpty ? nil : "?" + ($0.removingPercentEncoding ?? $0) } ?? ""
            let request = "GET \(url?.path ?? "")\(queryString)"
            lines.append("\(CYLExampleLocalizedString("网络筛选：向服务器发送条件")) · \(request)")
            lines.append(network?.isLoading == true ? CYLExampleLocalizedString("加载中…") : CYLExampleLocalizedString("服务器返回 %lu 条", count))
        case .database:
            let database = query as? CYLDatabaseReviewQuery
            lines.append("\(CYLExampleLocalizedString("数据库筛选：条件生成 SQL，在 SQLite 中查询")) · \(CYLExampleLocalizedString("匹配 %lu 条", count))")
            lines.append(database?.lastQuery?.displayString() ?? "")
        default:
            lines.append("\(CYLExampleLocalizedString("内存筛选：在已加载的评价中立即匹配")) · \(CYLExampleLocalizedString("匹配 %lu 条", count))")
        }
        statusLabel.text = lines.joined(separator: "\n")
    }
}

// MARK: - CYLMenuDelegate

extension CYLReviewListViewController: CYLMenuDelegate {

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        if let title = menuSource?.item(at: indexPath).title {
            lastEvent = CYLExampleLocalizedString("点击「%@」", title)
        }
    }

    func menu(_ menu: Any, didDeselectItemAt indexPath: IndexPath) {
        if let title = menuSource?.item(at: indexPath).title {
            lastEvent = CYLExampleLocalizedString("取消「%@」", title)
        }
    }

    /// Every tap that changes the selection refreshes the list once.
    func menu(_ menu: Any, didChangeSelectedItems indexPaths: [IndexPath]) {
        if indexPaths.isEmpty {
            // Nothing selected means no condition: show "全部" as selected.
            filterView.selectItem(at: IndexPath(item: 0, section: 0))
        }
        refreshReviews()
    }

    func menu(_ menu: Any, didChangeContentHeight height: CGFloat) {
        updateFilterHeight()
    }
}

// MARK: - UITableViewDataSource

extension CYLReviewListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        visibleReviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kReviewCellIdentifier, for: indexPath)
        let review = visibleReviews[indexPath.row]
        var content = UIListContentConfiguration.subtitleCell()
        content.text = review.user
        content.secondaryText = "\(review.text)\n\(review.date) \(review.sku)"
        content.secondaryTextProperties.numberOfLines = 0
        content.secondaryTextProperties.color = .secondaryLabel
        content.image = UIImage(systemName: "person.crop.circle")
        cell.contentConfiguration = content
        return cell
    }
}
