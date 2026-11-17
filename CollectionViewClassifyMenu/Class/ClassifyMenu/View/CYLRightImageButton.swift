//
//  CYLRightImageButton.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md). A CYLTagButton since 2026-11-17, so the menu's
//  "more" button draws its title and arrow with the same component as every tag (docs/issue-progress.md, "every icon +
//  title component is CYLTagButton").
//

import UIKit

/**
 * The "more" button of a menu section: a `CYLTagButton` showing `expandTitle` ("更多") or, while selected,
 * `collapseTitle` ("收起"), with the arrow after the title; never highlighted.
 */
@objc(CYLRightImageButton)
open class CYLRightImageButton: CYLTagButton {

    /**
     * The title while not selected (the section is folded).
     */
    @objc open var expandTitle = CYLMenuLocalizedString("CYLMenuExpand") {
        didSet {
            updateTitle()
        }
    }

    /**
     * The title while selected (the section is expanded).
     */
    @objc open var collapseTitle = CYLMenuLocalizedString("CYLMenuCollapse") {
        didSet {
            updateTitle()
        }
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
        let style = CYLMenuStyle.sectionTitle(fontSize: 12)
        style.contentAlignment = .center
        style.imagePlacement = .trailing
        style.imageTitleSpacing = 7
        self.style = style
        image = CYLMenuResources.image(named: "home_btn_more_normal")
        selectedImage = CYLMenuResources.image(named: "home_btn_more_selected")
        isAccessibilityElement = true
        accessibilityTraits = .button
        updateTitle()
    }

    open override var isSelected: Bool {
        didSet {
            updateTitle()
        }
    }

    /**
     * Never highlighted: the button toggles between its normal and selected looks only.
     */
    open override var isHighlighted: Bool {
        get {
            false
        }
        set {
            // Ignored, as the Objective-C version's empty -setHighlighted:.
        }
    }

    /**
     * The title as shown, unless a label was set.
     */
    open override var accessibilityLabel: String? {
        get {
            super.accessibilityLabel ?? title
        }
        set {
            super.accessibilityLabel = newValue
        }
    }

    private func updateTitle() {
        title = isSelected ? collapseTitle : expandTitle
    }
}
