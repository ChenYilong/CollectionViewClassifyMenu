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
    let tagsButton = UIButton(type: .system)
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
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.accessibilityTraits = .header

        nameField.placeholder = CYLTagEditorLocalizedString("备注名")
        nameField.borderStyle = .none
        nameField.backgroundColor = .systemGray6
        nameField.layer.cornerRadius = 8
        nameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        nameField.leftViewMode = .always

        var configuration = UIButton.Configuration.plain()
        configuration.title = CYLTagEditorLocalizedString("标签")
        configuration.image = UIImage(systemName: "chevron.right")
        configuration.imagePlacement = .trailing
        configuration.baseForegroundColor = .secondaryLabel
        configuration.contentInsets = .zero
        tagsButton.configuration = configuration
        tagsButton.contentHorizontalAlignment = .leading
        tagsButton.addTarget(self, action: #selector(editTags), for: .touchUpInside)
        tagsButton.accessibilityHint = CYLTagEditorLocalizedString("编辑标签")

        // The chosen tags, display only (taps open the editor).
        tagsView.style = CYLTagEditorViewController.tagStyle()
        tagsView.selectionMode = .none
        tagsView.showsSectionHeaders = false
        tagsView.scrollEnabled = false
        tagsView.menuDataSource = self
        tagsView.menuDelegate = self

        for subview in [titleLabel, nameField, tagsButton, tagsView] as [UIView] {
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
            tagsButton.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 24),
            tagsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tagsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tagsView.topAnchor.constraint(equalTo: tagsButton.bottomAnchor, constant: 4),
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

    @objc private func editTags() {
        editTags(animated: true)
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
