//
//  CYLTagListCell.swift
//  CollectionViewClassifyMenu
//
//  The cell of CYLTagListView: it hosts one CYLTagButton (the tag view) and is the accessibility element.
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * The cell of `CYLTagListView`: one `CYLTagButton` (the tag view); the cell is the accessibility element, a button
 * whose label is the tag's title.
 */
open class CYLTagListCell: UICollectionViewCell {

    private static let rippleLayerName = "CYLTagRipple"

    /**
     * The tag view. The collection view handles taps, so it ignores touches.
     */
    @objc public let button = CYLTagButton(frame: .zero)

    /**
     * The list's style object last applied, so that a style is copied into the button only when it changes.
     */
    open weak var appliedStyle: CYLMenuStyle?

    /**
     * Shows the delete indicator ("×") and makes it tappable; also adds a VoiceOver "Delete" action. False by default.
     */
    open var isDeletable = false {
        didSet {
            button.showsDeleteIndicator = isDeletable
            deleteControl.isHidden = !isDeletable
            updateAccessibilityActions()
            setNeedsLayout()
        }
    }

    /**
     * Called when the delete indicator is tapped (or the VoiceOver action is used).
     */
    open var deleteHandler: (() -> Void)?

    /**
     * Custom actions after 删除 (the list's long-press and 前移 / 后移 actions); reset on reuse.
     */
    open var additionalAccessibilityActions: [UIAccessibilityCustomAction] = [] {
        didSet {
            updateAccessibilityActions()
        }
    }

    private let deleteControl = UIControl()

    // MARK: - Initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        button.frame = contentView.bounds
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        button.isUserInteractionEnabled = false
        contentView.addSubview(button)
        deleteControl.isHidden = true
        deleteControl.accessibilityIdentifier = CYLTagListAccessibilityIdentifier.deleteButton
        deleteControl.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        contentView.addSubview(deleteControl)
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    // MARK: - API

    /**
     * Plays `CYLMenuStyle`'s touch ripple (`rippleColor`) from `point`, in the tag's coordinates; a touch plays it
     * too.
     */
    open func showRipple(at point: CGPoint) {
        let style = button.style
        guard let rippleColor = style.rippleColor, !UIAccessibility.isReduceMotionEnabled else {
            return
        }
        // AndroidTagView's ripple: a circle from the touch point to the farthest corner, fading out.
        let bounds = button.bounds
        let dx = max(point.x, bounds.width - point.x)
        let dy = max(point.y, bounds.height - point.y)
        let radius = (dx * dx + dy * dy).squareRoot()
        let ripple = CAShapeLayer()
        ripple.name = Self.rippleLayerName
        ripple.frame = CGRect(x: point.x - radius, y: point.y - radius, width: 2 * radius, height: 2 * radius)
        ripple.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 2 * radius, height: 2 * radius)).cgPath
        ripple.fillColor = rippleColor.cgColor
        ripple.opacity = 0
        button.layer.addSublayer(ripple)
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0.05
        scale.toValue = 1
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = min(1, max(0, style.rippleAlpha))
        fade.toValue = 0
        let group = CAAnimationGroup()
        group.animations = [scale, fade]
        group.duration = style.rippleDuration > 0 ? style.rippleDuration : 1
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            ripple.removeFromSuperlayer()
        }
        ripple.add(group, forKey: "ripple")
        CATransaction.commit()
    }

    /**
     * Shows a tag: its title (also its accessibility label), icons, look and state. An icon's `accessibilityLabel`,
     * when it has one (such as a "hot" icon), is read by VoiceOver as the tag's value.
     */
    open func configure(title: String, image: UIImage?, selectedImage: UIImage?, animationURL: URL?,
                        style: CYLMenuStyle, isSelected: Bool, isEnabled: Bool) {
        if appliedStyle !== style {
            button.style = style
            appliedStyle = style
        }
        button.animationURL = animationURL
        button.title = title
        button.image = image
        button.selectedImage = selectedImage
        button.isEnabled = isEnabled
        button.isSelected = isSelected
        accessibilityLabel = title
        // An icon with a meaning of its own (such as a "hot" icon) is read as the value.
        accessibilityValue = image?.accessibilityLabel
        accessibilityIdentifier = CYLTagListAccessibilityIdentifier.item
        accessibilityHint = nil
        var traits: UIAccessibilityTraits = .button
        if isSelected {
            traits.insert(.selected)
        }
        if !isEnabled {
            traits.insert(.notEnabled)
        }
        accessibilityTraits = traits
    }

    // MARK: - Overrides

    open override var isHighlighted: Bool {
        didSet {
            // Pressed: CYLMenuStyle.highlightedBackgroundColor.
            button.isHighlighted = isHighlighted
        }
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            showRipple(at: touch.location(in: button))
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        button.layoutIfNeeded()
        deleteControl.frame = isDeletable ? button.convert(button.deleteIndicatorHitFrame, to: contentView) : .zero
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        deleteHandler = nil
        additionalAccessibilityActions = []
        isDeletable = false
    }

    // MARK: - Private

    private func updateAccessibilityActions() {
        var actions: [UIAccessibilityCustomAction] = []
        if isDeletable {
            actions.append(UIAccessibilityCustomAction(name: CYLMenuLocalizedString("CYLMenuDeleteTag")) { [weak self] _ in
                self?.deleteHandler?()
                return true
            })
        }
        actions.append(contentsOf: additionalAccessibilityActions)
        accessibilityCustomActions = actions.isEmpty ? nil : actions
    }

    @objc private func deleteTapped() {
        deleteHandler?()
    }
}
