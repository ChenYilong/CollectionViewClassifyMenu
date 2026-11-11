//
//  CYLSearchDiscoverViewController.swift
//  CYLMenuExample
//
//  搜索历史与发现：a search app's search page. "最近搜索" is a CYLTagListView whose fold control is a tag cell
//  (CYLMenuFoldControlPositionInline: the chevron after the last visible tag, then after the last tag); "发现" is a
//  grid of two plain titles per row (CYLMenuStyle.gridStyle(itemsPerRow:)), long titles truncated, a "热" icon after a
//  title (title on the left, icon on the right: CYLTagImagePlacementTrailing, CYLTagContentAlignmentLeading), and
//  the core's More button, here refreshing the topics at random. The data comes from search-discover.json; this
//  screen only shows it and handles the taps.
//

import UIKit
import CollectionViewClassifyMenu

/**
 * The recent searches, one section.
 */
final class CYLRecentSearchSource: NSObject, CYLMenuDataSource {
    var searches: [String] = []
    /**
     * The trash button at the trailing edge of the section header.
     */
    let clearButton = UIButton(type: .system)

    func numberOfSectionsInMenu() -> Int {
        searches.isEmpty ? 0 : 1
    }

    func menuNumberOfItems(inSection section: Int) -> Int {
        searches.count
    }

    func menuTitle(forSection section: Int) -> String {
        CYLExampleLocalizedString("最近搜索")
    }

    func menuTitleForItem(at indexPath: IndexPath) -> String {
        searches[indexPath.item]
    }

    func menuAccessoryView(forSection section: Int) -> UIView? {
        clearButton
    }

    func menuAccessibilityHintForItem(at indexPath: IndexPath) -> String? {
        CYLExampleLocalizedString("轻点两下搜索")
    }
}

/**
 * The discover topics, one section with the core's More button.
 */
final class CYLDiscoverSource: NSObject, CYLMenuDataSource {
    var topics: [CYLDiscoverTopic] = []

    func numberOfSectionsInMenu() -> Int {
        1
    }

    func menuNumberOfItems(inSection section: Int) -> Int {
        topics.count
    }

    func menuTitle(forSection section: Int) -> String {
        CYLExampleLocalizedString("发现")
    }

    func menuTitleForItem(at indexPath: IndexPath) -> String {
        topics[indexPath.item].title
    }

    /**
     * The localized hot icon after a hot topic's title; VoiceOver reads its label as the tag's value.
     */
    func menuImageForItem(at indexPath: IndexPath) -> UIImage? {
        topics[indexPath.item].icon == "hot" ? CYLSearchDiscoverData.hotIcon() : nil
    }

    func menuAccessibilityHintForItem(at indexPath: IndexPath) -> String? {
        CYLExampleLocalizedString("轻点两下搜索")
    }

    func menuShowsMoreButton(inSection section: Int) -> Bool {
        true
    }

    /**
     * The More button refreshes the topics: VoiceOver says so instead of a generic "More".
     */
    func menuAccessibilityLabelForMoreButton(inSection section: Int) -> String? {
        CYLExampleLocalizedString("换一批")
    }
}

final class CYLSearchDiscoverViewController: UIViewController {

    private(set) var data: CYLSearchDiscoverData
    let recentSource = CYLRecentSearchSource()
    let discoverSource = CYLDiscoverSource()
    /**
     * Picks the refreshed topics; replaced in tests for a fixed order.
     */
    var randomGenerator = CYLAnyRandomNumberGenerator(SystemRandomNumberGenerator())

    let backButton = UIButton(type: .system)
    let searchField = UITextField()
    let cameraButton = UIButton(type: .system)
    let searchButton = UIButton(type: .system)
    let recentList = CYLTagListView(foldControl: CYLMenuFoldControl(position: .inline, content: .icon))
    let discoverList = CYLTagListView()
    let hintLabel = UILabel()
    let micButton = UIButton(type: .system)
    private let searchBar = UIView()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let bottomView = CYLAskBackgroundView()

    /**
     * The demo's data: the bundled JSON file, or an empty set when it cannot be read.
     */
    init(data: CYLSearchDiscoverData = (try? CYLSearchDiscoverData.bundled())
            ?? CYLSearchDiscoverData(version: 1, discoverCount: 6, recentSearches: [], discover: [])) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
        recentSource.searches = data.recentSearches
        discoverSource.topics = data.initialTopics
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // MARK: Styles

    /**
     * The recent searches: white capsules with a light border, the inline chevron drawn the same way.
     */
    static func recentStyle() -> CYLMenuStyle {
        let style = CYLMenuStyle()
        for state in [UIControl.State.normal, .selected, .disabled] {
            let appearance = style.appearance(for: state)
            appearance.backgroundColor = .systemBackground
            appearance.borderColor = .separator
            appearance.borderWidth = 1
            appearance.cornerRadius = 0
            appearance.margin = 14
            appearance.font = .systemFont(ofSize: 17)
            appearance.textColor = .label
        }
        style.itemHeight = 36
        style.interitemSpacing = 12
        style.lineSpacing = 12
        style.sectionInsets = UIEdgeInsets(top: 4, left: 16, bottom: 24, right: 16)
        applyHeaderLook(to: style)
        return style
    }

    /**
     * The discover grid: two plain titles per row, truncated, with the core's More button.
     */
    static func discoverStyle() -> CYLMenuStyle {
        let style = CYLMenuStyle.gridStyle(itemsPerRow: 2)
        for state in [UIControl.State.normal, .selected, .disabled] {
            style.appearance(for: state).font = .systemFont(ofSize: 17, weight: .medium)
        }
        // The hot icon at its own size: square in Chinese (热, 熱), wider in English (HOT).
        style.imageSize = .zero
        style.itemHeight = 36
        style.lineSpacing = 16
        style.sectionInsets = UIEdgeInsets(top: 4, left: 16, bottom: 16, right: 16)
        applyHeaderLook(to: style)
        return style
    }

    private static func applyHeaderLook(to style: CYLMenuStyle) {
        style.backgroundColor = .systemBackground
        style.headerHeight = 44
        style.headerFont = .systemFont(ofSize: 20, weight: .bold)
        style.headerTextColor = .label
        style.headerHorizontalInset = 16
    }

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchBar()
        setUpLists()
        setUpAskArea()
        layOut()
        updateLayerColors()
        reloadLists()
        // Long presses on the icon-only buttons show them in the Large Content Viewer (large accessibility text sizes).
        view.addInteraction(UILargeContentViewerInteraction())
        NotificationCenter.default.addObserver(self, selector: #selector(contrastDidChange),
                                               name: UIAccessibility.darkerSystemColorsStatusDidChangeNotification, object: nil)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayerColors()
    }

    @objc private func contrastDidChange() {
        updateLayerColors()
    }

    /**
     * Layer colors are CGColors: resolve them again for dark mode and Increase Contrast (a visible outline then).
     */
    func updateLayerColors() {
        let contrast = UIAccessibility.isDarkerSystemColorsEnabled
        let border = contrast ? UIColor.label : UIColor.separator
        searchBar.layer.borderColor = border.resolvedColor(with: traitCollection).cgColor
        searchBar.layer.borderWidth = contrast ? 2 : 1
        micButton.layer.borderColor = border.resolvedColor(with: traitCollection).cgColor
        micButton.layer.borderWidth = contrast ? 2 : 0
    }

    /**
     * Makes an icon-only button readable in the Large Content Viewer, under its accessibility label.
     */
    private func showsLargeContent(_ button: UIButton) {
        button.showsLargeContentViewer = true
        button.largeContentTitle = button.accessibilityLabel
        button.largeContentImage = button.currentImage
        button.scalesLargeContentImage = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // The search bar replaces the navigation bar, as in the search apps this screen models.
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setUpSearchBar() {
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)), for: .normal)
        backButton.tintColor = .label
        backButton.accessibilityLabel = CYLExampleLocalizedString("返回")
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        searchBar.backgroundColor = .systemBackground
        searchBar.layer.cornerRadius = 22
        searchBar.layer.shadowColor = UIColor.black.cgColor
        searchBar.layer.shadowOpacity = 0.06
        searchBar.layer.shadowRadius = 6
        searchBar.layer.shadowOffset = CGSize(width: 0, height: 2)

        searchField.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 16))
        searchField.adjustsFontForContentSizeCategory = true
        searchField.returnKeyType = .search
        searchField.clearButtonMode = .whileEditing
        searchField.accessibilityLabel = CYLExampleLocalizedString("搜索")
        searchField.accessibilityIdentifier = "CYLSearchDiscoverField"
        searchField.delegate = self

        cameraButton.setImage(UIImage(systemName: "camera.viewfinder", withConfiguration: UIImage.SymbolConfiguration(pointSize: 19, weight: .regular)), for: .normal)
        cameraButton.tintColor = .label
        cameraButton.accessibilityLabel = CYLExampleLocalizedString("以图搜索")
        cameraButton.addTarget(self, action: #selector(searchByImage), for: .touchUpInside)
        showsLargeContent(cameraButton)
        showsLargeContent(backButton)

        let divider = UIView()
        divider.backgroundColor = .separator
        divider.isAccessibilityElement = false

        searchButton.setTitle(CYLExampleLocalizedString("搜索"), for: .normal)
        searchButton.setTitleColor(.label, for: .normal)
        searchButton.titleLabel?.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: .systemFont(ofSize: 17, weight: .semibold))
        searchButton.titleLabel?.adjustsFontForContentSizeCategory = true
        searchButton.accessibilityIdentifier = "CYLSearchDiscoverSearchButton"
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)

        for subview in [searchField, cameraButton, divider, searchButton] as [UIView] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            searchBar.addSubview(subview)
        }
        searchButton.setContentHuggingPriority(.required, for: .horizontal)
        searchButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            searchField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 14),
            searchField.topAnchor.constraint(equalTo: searchBar.topAnchor),
            searchField.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor),
            cameraButton.leadingAnchor.constraint(equalTo: searchField.trailingAnchor, constant: 4),
            cameraButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            cameraButton.widthAnchor.constraint(equalToConstant: 36),
            cameraButton.heightAnchor.constraint(equalToConstant: 36),
            divider.leadingAnchor.constraint(equalTo: cameraButton.trailingAnchor, constant: 8),
            divider.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 18),
            searchButton.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 10),
            searchButton.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -14),
            searchButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
        ])
    }

    private func setUpLists() {
        // 最近搜索: folded to two rows, the chevron as the last tag; the trash clears the list.
        recentList.style = Self.recentStyle()
        recentList.selectionMode = .none
        recentList.defaultVisibleRows = 2
        recentList.isScrollEnabled = false
        recentList.menuDataSource = recentSource
        recentList.menuDelegate = self
        recentSource.clearButton.setImage(UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)), for: .normal)
        recentSource.clearButton.tintColor = .secondaryLabel
        recentSource.clearButton.accessibilityLabel = CYLExampleLocalizedString("清空最近搜索")
        recentSource.clearButton.addTarget(self, action: #selector(clearRecentSearches), for: .touchUpInside)
        showsLargeContent(recentSource.clearButton)

        // 发现: two per row, the More button refreshes the topics.
        discoverList.style = Self.discoverStyle()
        discoverList.selectionMode = .none
        discoverList.isScrollEnabled = false
        discoverList.menuDataSource = discoverSource
        discoverList.menuDelegate = self
    }

    private func setUpAskArea() {
        showHint(CYLExampleLocalizedString("按住提问，有问必答"))
        hintLabel.font = UIFontMetrics(forTextStyle: .title3).scaledFont(for: .systemFont(ofSize: 20))
        hintLabel.adjustsFontForContentSizeCategory = true
        hintLabel.textColor = .secondaryLabel
        hintLabel.textAlignment = .center
        hintLabel.numberOfLines = 0

        let mic = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold))
        micButton.setImage(mic, for: .normal)
        micButton.tintColor = .systemRed
        micButton.backgroundColor = .systemBackground
        micButton.layer.cornerRadius = 26
        micButton.layer.shadowColor = UIColor.black.cgColor
        micButton.layer.shadowOpacity = 0.08
        micButton.layer.shadowRadius = 8
        micButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        micButton.accessibilityLabel = CYLExampleLocalizedString("按住提问")
        micButton.accessibilityHint = CYLExampleLocalizedString("按住说出问题，松开发送")
        micButton.accessibilityIdentifier = "CYLSearchDiscoverMicButton"
        let hold = UILongPressGestureRecognizer(target: self, action: #selector(holdToAsk(_:)))
        hold.minimumPressDuration = 0.2
        micButton.addGestureRecognizer(hold)
        // A tap (VoiceOver's double tap, Switch Control, Full Keyboard Access) explains how to ask.
        micButton.addTarget(self, action: #selector(micTapped), for: .touchUpInside)
        showsLargeContent(micButton)
    }

    /**
     * The hint above the mic button; the sparkles are decoration, so VoiceOver reads the text only.
     */
    private func showHint(_ text: String) {
        hintLabel.text = text + " ✨"
        hintLabel.accessibilityLabel = text
    }

    private func layOut() {
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.addArrangedSubview(recentList)
        stackView.addArrangedSubview(discoverList)
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag

        for subview in [backButton, searchBar, scrollView, bottomView, hintLabel, micButton] as [UIView] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            backButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            searchBar.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 2),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            searchBar.heightAnchor.constraint(greaterThanOrEqualToConstant: 46),

            scrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: hintLabel.topAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),

            hintLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            hintLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            hintLabel.bottomAnchor.constraint(equalTo: micButton.topAnchor, constant: -20),
            micButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            micButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -16),
            micButton.widthAnchor.constraint(equalToConstant: 68),
            micButton.heightAnchor.constraint(equalToConstant: 52),
            // The light curved area behind the mic button.
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.topAnchor.constraint(equalTo: micButton.topAnchor, constant: -22),
        ])
    }

    // MARK: Data

    /**
     * Shows the current data; the search field's placeholder is the first discover topic.
     */
    func reloadLists() {
        searchField.placeholder = discoverSource.topics.first?.title ?? CYLExampleLocalizedString("搜索")
        recentList.reloadMenuData()
        discoverList.reloadMenuData()
        view.setNeedsLayout()
    }

    /**
     * The More button's action: another random selection of topics.
     */
    func refreshDiscover() {
        discoverSource.topics = data.randomTopics(excluding: discoverSource.topics, using: &randomGenerator)
        reloadLists()
        UIAccessibility.post(notification: .layoutChanged, argument: discoverList)
    }

    /**
     * Searches `text`: shows it in the field and moves it to the front of the recent searches.
     */
    func search(for text: String) {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        searchField.text = query
        recentSource.searches.removeAll { $0 == query }
        recentSource.searches.insert(query, at: 0)
        reloadLists()
        UIAccessibility.post(notification: .announcement, argument: CYLExampleLocalizedString("正在搜索：%@", query))
    }

    /**
     * The Search button and the keyboard's search key: the typed text, else the placeholder topic.
     */
    @objc func searchTapped() {
        search(for: searchField.text?.isEmpty == false ? searchField.text ?? "" : searchField.placeholder ?? "")
    }

    @objc func clearRecentSearches() {
        recentSource.searches.removeAll()
        reloadLists()
        UIAccessibility.post(notification: .announcement, argument: CYLExampleLocalizedString("已清空最近搜索"))
    }

    /**
     * The camera button: not part of this demo, which says so instead of ignoring the tap.
     */
    @objc func searchByImage() {
        let alert = UIAlertController(title: CYLExampleLocalizedString("以图搜索"),
                                      message: CYLExampleLocalizedString("演示中暂不支持以图搜索。"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: CYLExampleLocalizedString("好"), style: .default))
        present(alert, animated: true)
    }

    @objc private func micTapped() {
        UIAccessibility.post(notification: .announcement, argument: CYLExampleLocalizedString("请按住麦克风按钮说出问题"))
    }

    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func holdToAsk(_ recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            showHint(CYLExampleLocalizedString("正在聆听…"))
            UIAccessibility.post(notification: .announcement, argument: CYLExampleLocalizedString("正在聆听…"))
        case .ended, .cancelled, .failed:
            showHint(CYLExampleLocalizedString("按住提问，有问必答"))
        default:
            break
        }
    }
}

// MARK: - CYLMenuDelegate

extension CYLSearchDiscoverViewController: CYLMenuDelegate {

    /**
     * A recent search or a discover topic is searched again.
     */
    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        if (menu as AnyObject) === recentList {
            search(for: recentSource.searches[indexPath.item])
        } else {
            search(for: discoverSource.topics[indexPath.item].title)
        }
    }

    func menu(_ menu: Any, didTapMoreButtonInSection section: Int) {
        refreshDiscover()
    }
}

// MARK: - UITextFieldDelegate

extension CYLSearchDiscoverViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTapped()
        textField.resignFirstResponder()
        return true
    }
}

/**
 * The light gray area behind the mic button, its top edge a wide arc.
 */
final class CYLAskBackgroundView: UIView {
    private let shape = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        isAccessibilityElement = false
        layer.addSublayer(shape)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath()
        let rise = min(bounds.height, 40)
        path.move(to: CGPoint(x: 0, y: rise))
        path.addQuadCurve(to: CGPoint(x: bounds.width, y: rise), controlPoint: CGPoint(x: bounds.midX, y: -rise))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        path.addLine(to: CGPoint(x: 0, y: bounds.height))
        path.close()
        shape.path = path.cgPath
        shape.fillColor = UIColor.secondarySystemBackground.cgColor
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        shape.fillColor = UIColor.secondarySystemBackground.cgColor
    }
}
