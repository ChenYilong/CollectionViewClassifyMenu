//
//  CYLImageTagView.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * The picture: an accessibility element whose activation is a tap on it.
 */
@objc(CYLImageTagPictureView)
final class CYLImageTagPictureView: UIImageView {

    var activationHandler: (() -> Void)?

    override func accessibilityActivate() -> Bool {
        guard let activationHandler else {
            return false
        }
        activationHandler()
        return true
    }
}

/**
 * A picture with groups of tags on it (`CYLImageTagGroupView`), each group at a position relative to the picture.
 * In edit mode the groups can be dragged and a tap on a tag turns it to the next direction.
 */
@objc(CYLImageTagView)
open class CYLImageTagView: UIView, CYLImageTagGroupViewDelegate {

    private static let groupSpacing: CGFloat = 4

    private var groups: [CYLImageTagGroup] = []
    private var views: [CYLImageTagGroupView] = []
    private let picture = CYLImageTagPictureView(frame: .zero)
    private var editingStorage = false

    /**
     * The picture's image view.
     */
    open var imageView: UIImageView {
        picture
    }

    /**
     * The picture.
     */
    open var image: UIImage? {
        get {
            imageView.image
        }
        set {
            imageView.image = newValue
            updatePictureAccessibility()
        }
    }

    /**
     * The groups, kept up to date while editing (getTagGroupModels). Setting it replaces them (setTagList).
     */
    open var tagGroups: [CYLImageTagGroup] {
        get {
            groups
        }
        set {
            removeAllTagGroups()
            for group in newValue {
                addTagGroup(group)
            }
        }
    }

    /**
     * The group views, in the order of `tagGroups`.
     */
    open var groupViews: [CYLImageTagGroupView] {
        views
    }

    /**
     * Edit mode (setEditMode): groups can be dragged, a tap on a tag turns it to the next direction, no ripples.
     * NO by default: groups show a ripple and toggle with an animation.
     */
    open var isEditing: Bool {
        get {
            editingStorage
        }
        set {
            editingStorage = newValue
            setNeedsLayout()
            for view in views {
                view.isDraggable = newValue
                view.showsRipple = !newValue
                applyAccessibility(to: view)
            }
        }
    }

    /**
     * Configures each group view after it is made (radii, colors, line lengths).
     */
    open var groupConfiguration: ((CYLImageTagGroupView, Int) -> Void)?

    // MARK: Events

    /**
     * A tap on the picture outside the tags (the sample toggles the tags).
     */
    open var imageTapHandler: (() -> Void)? {
        didSet {
            updatePictureAccessibility()
        }
    }

    /**
     * A tap on the circle of the group at this index.
     */
    open var circleTapHandler: ((Int) -> Void)?

    /**
     * After the turn of the tag while editing.
     */
    open var tagTapHandler: ((Int, Int, CYLImageTag) -> Void)?

    /**
     * A long press on the group at this index.
     */
    open var longPressHandler: ((Int) -> Void)?

    /**
     * The group at this index was dragged to a new position (relative to the picture).
     */
    open var dragHandler: ((Int, CGPoint) -> Void)?

    // MARK: Accessibility

    /**
     * The picture is an accessibility element: its label is the image's `accessibilityLabel`, else "图片" (core string
     * `CYLImageTagPicture`); it is also a button while `imageTapHandler` is set, and activating it runs the handler.
     * Set the hint here, such as "轻点两下显示或隐藏标签". In edit mode the tags get the hint "轻点两下改变方向"
     * (`CYLImageTagTurnHint`) and the groups the 上移 / 下移 / 左移 / 右移 actions.
     */
    open var imageAccessibilityHint: String? {
        didSet {
            updatePictureAccessibility()
        }
    }

    /**
     * The name of every group's long-press custom action (CYLImageTagGroupView.longPressAccessibilityActionName), such
     * as "删除标签组" in edit mode. nil: "长按".
     */
    open var longPressAccessibilityActionName: String? {
        didSet {
            for view in views {
                view.longPressAccessibilityActionName = longPressAccessibilityActionName
            }
        }
    }

    // MARK: - Initializers

    /**
     * An empty view (as Objective-C's `-init` → `-initWithFrame:CGRectZero`).
     */
    public convenience init() {
        self.init(frame: .zero)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        picture.frame = bounds
        picture.activationHandler = { [weak self] in
            self?.handleImageTap()
        }
        picture.isAccessibilityElement = true
        picture.contentMode = .scaleAspectFill
        picture.clipsToBounds = true
        picture.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(picture)
        clipsToBounds = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap)))
    }

    // MARK: - Groups

    /**
     * Adds a copy of the group and its view on top of the others.
     */
    open func addTagGroup(_ group: CYLImageTagGroup) {
        let model = group.copy()
        let view = CYLImageTagGroupView(frame: bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.delegate = self
        view.tags = model.tags
        view.percentPosition = model.percentPosition
        view.isDraggable = isEditing
        view.showsRipple = !isEditing
        applyAccessibility(to: view)
        groups.append(model)
        views.append(view)
        groupConfiguration?(view, views.count - 1)
        addSubview(view)
        setNeedsLayout()
    }

    /**
     * Removes the group at this index and its view; an index past the end does nothing.
     */
    open func removeTagGroup(at index: Int) {
        guard views.indices.contains(index) else {
            return
        }
        views[index].removeFromSuperview()
        views.remove(at: index)
        groups.remove(at: index)
    }

    /**
     * Removes every group and its view.
     */
    open func removeAllTagGroups() {
        for view in views {
            view.removeFromSuperview()
        }
        views.removeAll()
        groups.removeAll()
    }

    /**
     * Shows hidden groups and hides shown ones, animated (excuteTagsAnimation).
     */
    open func toggleTagGroups(animated: Bool) {
        for view in views {
            if view.isGroupHidden {
                view.show(animated: animated, completion: nil)
            } else {
                view.hide(animated: animated, completion: nil)
            }
        }
    }

    // MARK: - Layout

    open override func layoutSubviews() {
        super.layoutSubviews()
        separateGroups()
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setNeedsLayout()
    }

    /**
     * Keeps groups from covering each other (large Dynamic Type sizes make tags taller): each group that overlaps an
     * earlier one moves up or down by the smallest distance that clears every earlier group and stays inside the view.
     * Only the display moves (`displayOffset`); `percentPosition` and the groups' data do not change. While editing,
     * groups stay where they are dragged.
     */
    private func separateGroups() {
        var placed: [CGRect] = []
        let height = bounds.height
        for view in views {
            view.displayOffset = .zero
            view.layoutIfNeeded()
            if isEditing || view.isGroupHidden {
                placed.append(view.occupiedFrame)
                continue
            }
            let frame = view.occupiedFrame
            func isClear(_ dy: CGFloat) -> Bool {
                let moved = frame.offsetBy(dx: 0, dy: dy)
                if moved.minY < 0 || moved.maxY > height {
                    return false
                }
                return !placed.contains { moved.insetBy(dx: 0, dy: -Self.groupSpacing / 2).intersects($0) }
            }
            if isClear(0) {
                placed.append(frame)
                continue
            }
            var best = CGFloat.greatestFiniteMagnitude
            for other in placed {
                for dy in [other.maxY + Self.groupSpacing - frame.minY, other.minY - Self.groupSpacing - frame.maxY]
                    where abs(dy) < abs(best) && isClear(dy) {
                    best = dy
                }
            }
            if best != .greatestFiniteMagnitude {
                view.displayOffset = CGPoint(x: 0, y: best)
                view.layoutIfNeeded()
            }
            placed.append(view.occupiedFrame)
        }
    }

    // MARK: - CYLImageTagGroupViewDelegate

    open func groupViewDidTapCircle(_ groupView: CYLImageTagGroupView) {
        if let index = views.firstIndex(of: groupView) {
            circleTapHandler?(index)
        }
    }

    open func groupView(_ groupView: CYLImageTagGroupView, didTapTagAt tagIndex: Int) {
        guard let index = views.firstIndex(of: groupView), tagIndex >= 0, tagIndex < groups[index].tags.count else {
            return
        }
        let tag = groups[index].tags[tagIndex]
        if isEditing {
            // The sample's onTagClicked: the next direction.
            tag.direction = tag.direction.next
            groupView.tags = groups[index].tags
            // The tag views were remade: keep VoiceOver on the turned tag.
            if tagIndex < groupView.tagViews.count {
                UIAccessibility.post(notification: .layoutChanged, argument: groupView.tagViews[tagIndex])
            }
        }
        tagTapHandler?(index, tagIndex, tag)
    }

    open func groupViewDidLongPress(_ groupView: CYLImageTagGroupView) {
        if let index = views.firstIndex(of: groupView) {
            longPressHandler?(index)
        }
    }

    open func groupView(_ groupView: CYLImageTagGroupView, didDragToPercentPosition percentPosition: CGPoint) {
        guard let index = views.firstIndex(of: groupView) else {
            return
        }
        groups[index].percentPosition = percentPosition
        dragHandler?(index, percentPosition)
    }

    // MARK: - Private

    /**
     * The picture's label, traits and hint.
     */
    private func updatePictureAccessibility() {
        let label = imageView.image?.accessibilityLabel ?? ""
        imageView.accessibilityLabel = label.isEmpty ? CYLMenuLocalizedString("CYLImageTagPicture") : label
        imageView.accessibilityTraits = imageTapHandler != nil ? [.image, .button] : .image
        imageView.accessibilityHint = imageAccessibilityHint
    }

    /**
     * Edit mode: the tags turn on a tap, so they say so.
     */
    private func applyAccessibility(to view: CYLImageTagGroupView) {
        view.longPressAccessibilityActionName = longPressAccessibilityActionName
        view.tagAccessibilityHint = isEditing ? CYLMenuLocalizedString("CYLImageTagTurnHint") : nil
    }

    @objc private func handleImageTap() {
        imageTapHandler?()
    }
}
