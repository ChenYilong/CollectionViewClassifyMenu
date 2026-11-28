//
//  CYLWordPickerDemoViewController.swift
//  CYLMenuExample
//
//  The word picker (选词填入), as in a messaging app's contact request: a remark field, the sender's message with a
//  "pick words" link, and a sheet where the message is one cell per character; smearing a finger across cells selects
//  them, and "Fill in" writes the selected characters, in text order, into the field. The cells are a CYLTagListView
//  with CYLMenuStyle.wordPicker(), setTags(withCharactersOf:), allowsSmearSelection and selectedText.
//

import UIKit
import CollectionViewClassifyMenu

final class CYLWordPickerDemoViewController: UIViewController {

    /// The sample message, in the app's language: a greeting with a name to pick, an emoji and a space, so the word
    /// picker shows letters, Chinese characters, an emoji cell and a space cell.
    static var message: String {
        CYLExampleLocalizedString("你好，我是设计部的 Alex 👋")
    }
    /// The sender, and the name the demo's message lets you pick (a name, the same in every language).
    static let sender = "Alex"

    private(set) var remarkField: UITextField!
    private(set) var pickButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = CYLExampleLocalizedString("选词填入")
        view.backgroundColor = .systemBackground

        let remarkTitle = Self.caption(CYLExampleLocalizedString("备注"))
        let field = UITextField()
        field.placeholder = CYLExampleLocalizedString("添加备注")
        field.font = .preferredFont(forTextStyle: .title3)
        field.adjustsFontForContentSizeCategory = true
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 10
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        field.leftViewMode = .always
        field.clearButtonMode = .whileEditing
        field.accessibilityIdentifier = "wordPicker.field"
        field.heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true
        remarkField = field

        let sender = UILabel()
        sender.text = Self.sender
        sender.font = .preferredFont(forTextStyle: .headline)
        sender.adjustsFontForContentSizeCategory = true
        sender.textColor = .systemIndigo
        let message = UILabel()
        message.text = "\"\(Self.message)\""
        message.font = .preferredFont(forTextStyle: .body)
        message.adjustsFontForContentSizeCategory = true
        message.textColor = .secondaryLabel
        message.numberOfLines = 0
        let pick = UIButton(type: .system)
        pick.setTitle(CYLExampleLocalizedString("选词填入"), for: .normal)
        pick.titleLabel?.font = .preferredFont(forTextStyle: .body)
        pick.titleLabel?.adjustsFontForContentSizeCategory = true
        pick.contentHorizontalAlignment = .leading
        pick.accessibilityIdentifier = "wordPicker.pick"
        pick.addTarget(self, action: #selector(showPicker), for: .touchUpInside)
        pickButton = pick

        let stack = UIStackView(arrangedSubviews: [remarkTitle, field, sender, message, pick])
        stack.axis = .vertical
        stack.spacing = 10
        stack.setCustomSpacing(16, after: field)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
    }

    private static func caption(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.accessibilityTraits = .header
        return label
    }

    /// The sheet; "Fill in" writes the picked text into the remark field.
    @objc func showPicker() {
        let picker = CYLWordPickerSheetViewController(text: Self.message) { [weak self] picked in
            self?.remarkField.text = picked
        }
        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 16
        }
        present(picker, animated: true)
    }
}

/// The sheet of the word picker: Cancel, "Fill in" (enabled once something is selected), the hint and the cells.
final class CYLWordPickerSheetViewController: UIViewController, CYLMenuDelegate {

    let text: String
    let onFill: (String) -> Void
    private(set) var tagListView: CYLTagListView!
    private(set) var fillButton: UIButton!

    init(text: String, onFill: @escaping (String) -> Void) {
        self.text = text
        self.onFill = onFill
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let cancel = UIButton(type: .system)
        cancel.setTitle(CYLExampleLocalizedString("取消"), for: .normal)
        cancel.setTitleColor(.label, for: .normal)
        cancel.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        cancel.titleLabel?.adjustsFontForContentSizeCategory = true
        cancel.accessibilityIdentifier = "wordPicker.cancel"
        cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        var fillConfiguration = UIButton.Configuration.filled()
        fillConfiguration.title = CYLExampleLocalizedString("填入")
        fillConfiguration.cornerStyle = .medium
        fillConfiguration.baseBackgroundColor = .systemGreen
        let fill = UIButton(configuration: fillConfiguration)
        fill.accessibilityIdentifier = "wordPicker.fill"
        fill.addTarget(self, action: #selector(fillTapped), for: .touchUpInside)
        fillButton = fill

        let bar = UIStackView(arrangedSubviews: [cancel, UIView(), fill])
        bar.alignment = .center

        let hint = UILabel()
        hint.text = CYLExampleLocalizedString("涂抹选择填入词")
        hint.font = .preferredFont(forTextStyle: .headline)
        hint.adjustsFontForContentSizeCategory = true
        hint.accessibilityTraits = .header

        let list = CYLTagListView()
        list.style = .wordPicker()
        list.style.backgroundStyle = .liquidGlass
        list.colorTheme = CYLTagColorTheme.none
        list.selectionMode = .multiple
        list.allowsSmearSelection = true
        list.isScrollEnabled = false
        list.setTags(withCharactersOf: text)
        list.menuDelegate = self
        list.accessibilityIdentifier = "wordPicker.list"
        tagListView = list

        let stack = UIStackView(arrangedSubviews: [bar, hint, list])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            list.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
        ])
        updateFillButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // The list as tall as its cells.
        guard let list = tagListView, list.bounds.width > 0 else { return }
        let height = list.heightThatFitsWidth(list.bounds.width)
        if let constraint = list.constraints.first(where: { $0.firstAttribute == .height && $0.relation == .equal }) {
            if abs(constraint.constant - height) > 0.5 { constraint.constant = height }
        } else {
            list.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }

    /// "Fill in" only with something selected, as WeChat's.
    func updateFillButton() {
        fillButton.isEnabled = !tagListView.selectedIndexPaths.isEmpty
    }

    func menu(_ menu: Any, didChangeSelectedItems indexPaths: [IndexPath]) {
        updateFillButton()
    }

    @objc func cancelTapped() {
        dismiss(animated: true)
    }

    @objc func fillTapped() {
        let picked = tagListView.selectedText
        dismiss(animated: true)
        onFill(picked)
    }
}
