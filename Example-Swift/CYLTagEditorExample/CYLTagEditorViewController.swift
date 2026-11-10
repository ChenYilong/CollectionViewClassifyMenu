//
//  CYLTagEditorViewController.swift
//  CYLTagEditorExample
//
//  编辑标签：a sheet for choosing a contact's tags, as in a chat app, built on the core's
//  CYLTagListView (local pod).
//  - "最近使用" and "我的标签" (with "管理") list the tags; a selected tag is green, in both sections.
//  - "+ 新建标签" after the last tag adds a tag (it is an action, not a selectable tag).
//  - Typing in the search field shows "搜索结果" (case-insensitive) and "+ 新建标签：<text>" when
//    that exact tag does not exist yet; tapping it creates, selects and shows the tag.
//  - "完成" (green) returns the selection; it is off while searching.
//

import UIKit
import CollectionViewClassifyMenu

final class CYLTagEditorViewController: UIViewController {

    enum Item: Equatable {
        case tag(String)
        /// "+ 新建标签" (nil: asks for a name) or "+ 新建标签：<name>".
        case create(String?)
    }

    enum SectionKind: Equatable {
        case recent, mine, results
    }

    struct Section: Equatable {
        let kind: SectionKind
        let title: String
        let items: [Item]
    }

    let store: CYLTagStore
    let initialSelection: [String]
    /// The selected tags, in the order they were chosen.
    private(set) var selectedTags: [String]
    private(set) var query = ""
    /// In "管理" mode a tap on one of "我的标签" deletes the tag (after a confirmation).
    private(set) var isManaging = false
    private(set) var sections: [Section] = []

    var onDone: (([String]) -> Void)?
    var onCancel: (() -> Void)?

    let tagListView = CYLTagListView()
    let searchField = UISearchTextField()
    let cancelButton = UIButton(type: .system)
    let doneButton = UIButton(type: .system)
    let titleLabel = UILabel()
    private(set) lazy var manageButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.setTitleColor(CYLTagEditorViewController.linkColor, for: .normal)
        button.addTarget(self, action: #selector(toggleManaging), for: .touchUpInside)
        return button
    }()

    static let green = UIColor(red: 0.027, green: 0.757, blue: 0.376, alpha: 1)       // #07C160
    static let linkColor = UIColor(red: 0.341, green: 0.420, blue: 0.584, alpha: 1)   // #576B95

    /// The tags' look: gray tags, green selected tags.
    static func tagStyle() -> CYLMenuStyle {
        let style = CYLMenuStyle()
        let font = UIFont.systemFont(ofSize: 16)
        for state in [UIControl.State.normal, .selected, .disabled] {
            let appearance = style.appearance(for: state)
            appearance.font = font
            appearance.cornerRadius = 6
            appearance.borderWidth = 0
            appearance.margin = 14
        }
        style.normalAppearance.backgroundColor = .systemGray6
        style.normalAppearance.textColor = .label
        style.selectedAppearance.backgroundColor = green.withAlphaComponent(0.1)
        style.selectedAppearance.textColor = green
        style.itemHeight = 36
        style.interitemSpacing = 12
        style.lineSpacing = 12
        style.sectionInsets = UIEdgeInsets(top: 4, left: 16, bottom: 20, right: 16)
        style.headerHeight = 40
        style.headerFont = .systemFont(ofSize: 15)
        style.headerTextColor = .secondaryLabel
        style.headerHorizontalInset = 16
        style.backgroundColor = .systemBackground
        style.imageSize = CGSize(width: 14, height: 14)
        style.imageTitleSpacing = 6
        return style
    }

    /// "+ 新建标签": an outlined action among the tags (the core's per-item style).
    static func createStyle(from style: CYLMenuStyle) -> CYLMenuStyle {
        let create = style.copy() as! CYLMenuStyle
        create.normalAppearance.backgroundColor = .systemBackground
        create.normalAppearance.borderColor = .separator
        create.normalAppearance.borderWidth = 1
        create.normalAppearance.textColor = .secondaryLabel
        create.setIconColor(.tertiaryLabel, for: .normal)
        return create
    }

    private lazy var createStyle = CYLTagEditorViewController.createStyle(from: tagListView.style)

    init(store: CYLTagStore, selectedTags: [String]) {
        self.store = store
        self.initialSelection = selectedTags.filter(store.contains)
        self.selectedTags = initialSelection
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        cancelButton.setTitle(CYLTagEditorLocalizedString("取消"), for: .normal)
        cancelButton.setTitleColor(.label, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 17)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)

        titleLabel.text = CYLTagEditorLocalizedString("编辑标签")
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.accessibilityTraits = .header

        let doneTitle = CYLTagEditorLocalizedString("完成")
        doneButton.configurationUpdateHandler = { button in
            // Green with white text when enabled, gray otherwise.
            var configuration = UIButton.Configuration.filled()
            var title = AttributedString(doneTitle)
            title.font = .systemFont(ofSize: 17, weight: .semibold)
            configuration.attributedTitle = title
            configuration.baseBackgroundColor = button.isEnabled ? CYLTagEditorViewController.green : .secondarySystemFill
            configuration.baseForegroundColor = button.isEnabled ? .white : .tertiaryLabel
            configuration.cornerStyle = .fixed
            configuration.background.cornerRadius = 4
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14)
            button.configuration = configuration
        }
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)

        searchField.placeholder = CYLTagEditorLocalizedString("搜索")
        searchField.returnKeyType = .search
        searchField.clearButtonMode = .whileEditing
        searchField.autocapitalizationType = .none
        searchField.autocorrectionType = .no
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)

        tagListView.style = CYLTagEditorViewController.tagStyle()
        tagListView.selectionMode = .multiple
        tagListView.allowsEmptySelection = true
        tagListView.menuDataSource = self
        tagListView.menuDelegate = self
        tagListView.keyboardDismissMode(.onDrag)

        for subview in [cancelButton, titleLabel, doneButton, searchField, tagListView] as [UIView] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor),
            doneButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchField.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 26),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 44),
            tagListView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 12),
            tagListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tagListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tagListView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        reload()
    }

    // MARK: Content

    /// The sections for the current query: "最近使用" and "我的标签", or "搜索结果".
    func makeSections() -> [Section] {
        if !query.isEmpty {
            var items = store.tags(matching: query).map(Item.tag)
            if store.canCreate(query) {
                items.append(.create(CYLTagStore.normalizedName(query)))
            }
            return [Section(kind: .results, title: CYLTagEditorLocalizedString("搜索结果"), items: items)]
        }
        var sections: [Section] = []
        if !store.recentTags.isEmpty {
            sections.append(Section(kind: .recent, title: CYLTagEditorLocalizedString("最近使用"), items: store.recentTags.map(Item.tag)))
        }
        sections.append(Section(kind: .mine, title: CYLTagEditorLocalizedString("我的标签"), items: store.tags.map(Item.tag) + [.create(nil)]))
        return sections
    }

    func reload() {
        sections = makeSections()
        manageButton.setTitle(CYLTagEditorLocalizedString(isManaging ? "退出管理" : "管理"), for: .normal)
        manageButton.sizeToFit()
        tagListView.reloadMenuData()
        syncSelection()
        updateDoneButton()
    }

    /// Shows every occurrence of a selected tag as selected ("创业" in both sections).
    func syncSelection() {
        var indexPaths: [IndexPath] = []
        for (section, content) in sections.enumerated() {
            for (item, element) in content.items.enumerated() {
                if case let .tag(tag) = element, selectedTags.contains(tag) {
                    indexPaths.append(IndexPath(item: item, section: section))
                }
            }
        }
        tagListView.selectedIndexPaths = indexPaths
    }

    /// "完成" is green with a selection or a change, and off while searching.
    var isDoneEnabled: Bool {
        query.isEmpty && (!selectedTags.isEmpty || Set(selectedTags) != Set(initialSelection))
    }

    func updateDoneButton() {
        doneButton.isEnabled = isDoneEnabled
        doneButton.setNeedsUpdateConfiguration()
    }

    func indexPath(of tag: String) -> IndexPath? {
        for (section, content) in sections.enumerated() {
            if let item = content.items.firstIndex(of: .tag(tag)) {
                return IndexPath(item: item, section: section)
            }
        }
        return nil
    }

    // MARK: Actions

    /// As typing in the search field.
    func setQuery(_ text: String) {
        searchField.text = text
        query = CYLTagStore.normalizedName(text)
        reload()
    }

    func select(_ tag: String) {
        if !selectedTags.contains(tag) {
            selectedTags.append(tag)
        }
        syncSelection()
        updateDoneButton()
    }

    func deselect(_ tag: String) {
        selectedTags.removeAll { $0 == tag }
        syncSelection()
        updateDoneButton()
    }

    /// Creates the tag (or finds it), selects it, leaves the search and scrolls to it.
    @discardableResult
    func createTag(named name: String) -> String? {
        guard let tag = store.createTag(named: name) else { return nil }
        if !selectedTags.contains(tag) {
            selectedTags.append(tag)
        }
        searchField.text = ""
        query = ""
        searchField.resignFirstResponder()
        reload()
        if let indexPath = indexPath(of: tag), sections[indexPath.section].kind == .mine {
            tagListView.scrollToItem(at: indexPath, animated: false)
        }
        UIAccessibility.post(notification: .announcement, argument: CYLTagEditorLocalizedString("已新建标签：%@", tag))
        return tag
    }

    /// "+ 新建标签": asks for the name.
    func promptForNewTag() {
        let alert = UIAlertController(title: CYLTagEditorLocalizedString("新建标签"), message: nil, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = CYLTagEditorLocalizedString("标签名称")
            field.clearButtonMode = .whileEditing
        }
        alert.addAction(UIAlertAction(title: CYLTagEditorLocalizedString("取消"), style: .cancel))
        alert.addAction(UIAlertAction(title: CYLTagEditorLocalizedString("确定"), style: .default) { [weak self, weak alert] _ in
            self?.createTag(named: alert?.textFields?.first?.text ?? "")
        })
        present(alert, animated: true)
    }

    @objc func toggleManaging() {
        isManaging.toggle()
        reload()
    }

    func confirmDeleting(_ tag: String) {
        let alert = UIAlertController(title: CYLTagEditorLocalizedString("删除标签「%@」？", tag), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: CYLTagEditorLocalizedString("取消"), style: .cancel))
        alert.addAction(UIAlertAction(title: CYLTagEditorLocalizedString("删除"), style: .destructive) { [weak self] _ in
            self?.deleteTag(tag)
        })
        present(alert, animated: true)
    }

    func deleteTag(_ tag: String) {
        store.deleteTag(tag)
        selectedTags.removeAll { $0 == tag }
        reload()
    }

    @objc func searchTextChanged() {
        query = CYLTagStore.normalizedName(searchField.text ?? "")
        reload()
    }

    @objc func cancel() {
        onCancel?()
        dismiss(animated: true)
    }

    @objc func done() {
        guard isDoneEnabled else { return }
        store.markUsed(selectedTags)
        onDone?(selectedTags)
        dismiss(animated: true)
    }
}

// MARK: - CYLMenuDataSource

extension CYLTagEditorViewController: CYLMenuDataSource {

    func numberOfSectionsInMenu() -> Int {
        sections.count
    }

    func menuNumberOfItems(inSection section: Int) -> Int {
        sections[section].items.count
    }

    func menuTitle(forSection section: Int) -> String {
        sections[section].title
    }

    func menuTitleForItem(at indexPath: IndexPath) -> String {
        switch sections[indexPath.section].items[indexPath.item] {
        case let .tag(tag): return tag
        case let .create(name?): return CYLTagEditorLocalizedString("新建标签：%@", name)
        case .create(nil): return CYLTagEditorLocalizedString("新建标签")
        }
    }

    func menuImageForItem(at indexPath: IndexPath) -> UIImage? {
        if case .create = sections[indexPath.section].items[indexPath.item] {
            return UIImage(systemName: "plus")
        }
        return nil
    }

    func menuStyleForItem(at indexPath: IndexPath) -> CYLMenuStyle? {
        if case .create = sections[indexPath.section].items[indexPath.item] {
            return createStyle
        }
        return nil
    }

    func menuItemIsSelectable(at indexPath: IndexPath) -> Bool {
        if case .create = sections[indexPath.section].items[indexPath.item] {
            return false
        }
        return !isManaging
    }

    func menuAccessoryView(forSection section: Int) -> UIView? {
        sections[section].kind == .mine ? manageButton : nil
    }
}

// MARK: - CYLMenuDelegate

extension CYLTagEditorViewController: CYLMenuDelegate {

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        switch sections[indexPath.section].items[indexPath.item] {
        case let .create(name?):
            createTag(named: name)
        case .create(nil):
            promptForNewTag()
        case let .tag(tag):
            if isManaging {
                confirmDeleting(tag)
            } else {
                select(tag)
            }
        }
    }

    func menu(_ menu: Any, didDeselectItemAt indexPath: IndexPath) {
        if case let .tag(tag) = sections[indexPath.section].items[indexPath.item] {
            deselect(tag)
        }
    }
}

// MARK: - UITextFieldDelegate

extension CYLTagEditorViewController: UITextFieldDelegate {

    /// The keyboard's search key creates the tag typed when it does not exist yet.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if store.canCreate(query) {
            createTag(named: query)
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}

private extension CYLTagListView {
    /// The tags scroll in the list's own collection view; dragging it hides the keyboard.
    func keyboardDismissMode(_ mode: UIScrollView.KeyboardDismissMode) {
        for case let scrollView as UIScrollView in subviews {
            scrollView.keyboardDismissMode = mode
        }
    }
}
