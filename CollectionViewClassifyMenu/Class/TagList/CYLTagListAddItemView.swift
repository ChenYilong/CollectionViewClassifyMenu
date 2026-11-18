//
//  CYLTagListAddItemView.swift
//  CollectionViewClassifyMenu
//
//  The "add tag" control CYLTagListView shows below its last section while it is editing (`isEditing`): a text field
//  and an Add button, like AndroidTagView's demo (an EditText and an "ADD TAG" button under the tags).
//

import UIKit

/**
 * The "add tag" control of `CYLTagListView` in editing mode: a text field and an Add button. The list places it below
 * its last section and reports a submitted name through `menu(_:didRequestNewItemWithName:at:)`; customize its field
 * and button (placeholder, fonts, colors) as needed.
 */
@objcMembers
open class CYLTagListAddItemView: UIView, UITextFieldDelegate {

    /**
     * The name field. Its placeholder is the localized "Tag name" (`CYLMenuAddTagPlaceholder`).
     */
    public let textField = UITextField()

    /**
     * The Add button (`CYLMenuAddTag`); it is enabled while the field has a name.
     */
    public let addButton = UIButton(type: .system)

    /**
     * Called with the trimmed name when the Add button or the keyboard's return key is tapped; the field is cleared.
     */
    open var submitHandler: ((String) -> Void)?

    /**
     * The height of the control; 44 points by default, larger with larger Dynamic Type.
     */
    open var preferredHeight: CGFloat {
        let field = textField.font?.lineHeight ?? 17
        let button = addButton.titleLabel?.font.lineHeight ?? 17
        return max(44, ceil(max(field, button)) + 20)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        textField.placeholder = CYLMenuLocalizedString("CYLMenuAddTagPlaceholder")
        textField.accessibilityLabel = CYLMenuLocalizedString("CYLMenuAddTagPlaceholder")
        textField.accessibilityIdentifier = CYLTagListAddItemView.textFieldIdentifier
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.borderStyle = .none
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 8
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.delegate = self
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        addSubview(textField)

        addButton.setTitle(CYLMenuLocalizedString("CYLMenuAddTag"), for: .normal)
        addButton.titleLabel?.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 17, weight: .semibold))
        addButton.titleLabel?.adjustsFontForContentSizeCategory = true
        addButton.accessibilityIdentifier = CYLTagListAddItemView.addButtonIdentifier
        addButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        addButton.isEnabled = false
        addSubview(addButton)
    }

    /**
     * The accessibility identifier of the text field ("CYLTagListAddItemField").
     */
    public static let textFieldIdentifier = "CYLTagListAddItemField"

    /**
     * The accessibility identifier of the Add button ("CYLTagListAddItemButton").
     */
    public static let addButtonIdentifier = "CYLTagListAddItemButton"

    open override func layoutSubviews() {
        super.layoutSubviews()
        let buttonWidth = ceil(addButton.intrinsicContentSize.width) + 24
        let spacing: CGFloat = 12
        textField.frame = CGRect(x: 0, y: 0, width: max(0, bounds.width - buttonWidth - spacing), height: bounds.height)
        addButton.frame = CGRect(x: bounds.width - buttonWidth, y: 0, width: buttonWidth, height: bounds.height)
    }

    /**
     * The trimmed name in the field.
     */
    open var name: String {
        (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    @objc private func textChanged() {
        addButton.isEnabled = !name.isEmpty
    }

    /**
     * Submits the name in the field (as the Add button does): calls `submitHandler` and clears the field. An empty
     * name does nothing.
     */
    @objc open func submit() {
        let name = self.name
        guard !name.isEmpty else {
            return
        }
        textField.text = ""
        addButton.isEnabled = false
        submitHandler?(name)
        UIAccessibility.post(notification: .announcement,
                             argument: String(format: CYLMenuLocalizedString("CYLMenuTagAdded"), name))
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if name.isEmpty {
            textField.resignFirstResponder()
        } else {
            submit()
        }
        return false
    }
}
