//
//  CYLRemarkViewController.swift
//  CYLTagEditorExample
//
//  编辑备注：the screen the tag editor is presented from, as in a chat app's contact remarks. Its
//  "标签" row shows the chosen tags (a display-only CYLTagListView); tapping it opens 编辑标签.
//

import UIKit
import CollectionViewClassifyMenu

final class CYLRemarkViewController: UIViewController {

    let store: CYLTagStore
    private(set) var tags: [String]

    let titleLabel = UILabel()
    let nameField = UITextField()
    let tagsView = CYLTagListView()

    init(store: CYLTagStore, tags: [String]) {
        self.store = store
        self.tags = tags
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: CYLTagEditorLocalizedString("取消"), style: .plain, target: nil, action: nil)
        let done = UIBarButtonItem(title: CYLTagEditorLocalizedString("完成"), style: .done, target: nil, action: nil)
        done.isEnabled = false
        navigationItem.rightBarButtonItem = done
        navigationController?.navigationBar.tintColor = .label

        titleLabel.text = CYLTagEditorLocalizedString("编辑备注")
        titleLabel.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: .systemFont(ofSize: 28, weight: .bold))
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textAlignment = .center
        titleLabel.accessibilityTraits = .header

        nameField.placeholder = CYLTagEditorLocalizedString("备注名")
        nameField.accessibilityLabel = CYLTagEditorLocalizedString("备注名")
        nameField.font = .preferredFont(forTextStyle: .body)
        nameField.adjustsFontForContentSizeCategory = true
        nameField.borderStyle = .none
        nameField.backgroundColor = .systemGray6
        nameField.layer.cornerRadius = 8
        nameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        nameField.leftViewMode = .always

        // The chosen tags, display only (taps open the editor). "标签 ›" is the list's own title (the core's title
        // view): secondary color, regular weight, the chevron after the text.
        tagsView.title = CYLTagEditorLocalizedString("标签")
        tagsView.titleImage = UIImage(systemName: "chevron.right")
        let titleStyle = CYLTagListView.defaultTitleStyle()
        for state in [UIControl.State.normal, .selected, .disabled] {
            titleStyle.appearance(for: state).font = .preferredFont(forTextStyle: .subheadline)
            titleStyle.appearance(for: state).textColor = .secondaryLabel
            titleStyle.setIconColor(.tertiaryLabel, for: state)
        }
        titleStyle.imagePlacement = .trailing
        titleStyle.imageSize = CGSize(width: 12, height: 12)
        titleStyle.imageTitleSpacing = 4
        tagsView.titleStyle = titleStyle
        // A header that opens the editor: VoiceOver reads it as both.
        tagsView.titleView.accessibilityTraits = [.header, .button]
        tagsView.titleView.accessibilityHint = CYLTagEditorLocalizedString("编辑标签")
        // The title is not a control: a tap on it opens the editor too.
        let titleTap = UITapGestureRecognizer(target: self, action: #selector(tagsViewTapped(_:)))
        titleTap.cancelsTouchesInView = false
        tagsView.addGestureRecognizer(titleTap)
        tagsView.style = CYLTagEditorViewController.tagStyle()
        tagsView.selectionMode = .none
        tagsView.showsSectionHeaders = false
        tagsView.isScrollEnabled = false
        tagsView.menuDataSource = self
        tagsView.menuDelegate = self

        for subview in [titleLabel, nameField, tagsView] as [UIView] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 48),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 36),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameField.heightAnchor.constraint(equalToConstant: 48),
            tagsView.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 12),
            tagsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tagsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Its height is its intrinsic content height (CYLTagListView.contentHeight).
        ])
        tagsView.reloadMenuData()
    }

    /// Presents 编辑标签 as a sheet over this screen.
    @discardableResult
    func editTags(animated: Bool) -> CYLTagEditorViewController {
        let editor = CYLTagEditorViewController(store: store, selectedTags: tags)
        editor.onDone = { [weak self] tags in
            self?.updateTags(tags)
        }
        editor.modalPresentationStyle = .pageSheet
        if let sheet = editor.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom(identifier: .init("tags")) { context in context.maximumDetentValue * 0.78 }, .large()]
            } else {
                sheet.detents = [.large()]
            }
            sheet.preferredCornerRadius = 16
        }
        present(editor, animated: animated)
        return editor
    }

    @objc private func tagsViewTapped(_ recognizer: UITapGestureRecognizer) {
        if tagsView.titleView.bounds.contains(recognizer.location(in: tagsView.titleView)) {
            editTags(animated: true)
        }
    }

    func updateTags(_ tags: [String]) {
        self.tags = tags
        tagsView.reloadMenuData()
        view.setNeedsLayout()
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}

extension CYLRemarkViewController: CYLMenuDataSource, CYLMenuDelegate {

    func numberOfSectionsInMenu() -> Int {
        1
    }

    func menuNumberOfItems(inSection section: Int) -> Int {
        max(tags.count, 1)
    }

    func menuTitle(forSection section: Int) -> String {
        CYLTagEditorLocalizedString("标签")
    }

    func menuTitleForItem(at indexPath: IndexPath) -> String {
        tags.isEmpty ? CYLTagEditorLocalizedString("添加标签") : tags[indexPath.item]
    }

    func menuImageForItem(at indexPath: IndexPath) -> UIImage? {
        tags.isEmpty ? UIImage(systemName: "plus") : nil
    }

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        editTags(animated: true)
    }
}
