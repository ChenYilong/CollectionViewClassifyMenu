//
//  CYLImageTagGroupView.swift
//  CollectionViewClassifyMenu
//
//  Geometry after shellljx/TagViewGroup (TagGroupUtils, Apache License 2.0).
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

// MARK: - Direction

/**
 * Where a tag goes from the dot (TagViewGroup's DIRECTION). "Straight" tags hang on a slanted line; the others on a
 * vertical line and then along their bottom edge.
 */
public enum CYLImageTagDirection: Int, CaseIterable, Sendable {
    case leftCenter = 0
    case leftTop
    case leftTopStraight
    case leftBottom
    case leftBottomStraight
    case rightCenter
    case rightTop
    case rightTopStraight
    case rightBottom
    case rightBottomStraight
    /**
     * Centered on the dot, without a line (the ripple).
     */
    case center

    /**
     * The next of the ten line directions, in declaration order (`center` is skipped), as the sample turns a tag on
     * each tap while editing.
     */
    public var next: CYLImageTagDirection {
        switch self {
        case .rightBottomStraight, .center:
            return .leftCenter
        default:
            return CYLImageTagDirection(rawValue: rawValue + 1) ?? .leftCenter
        }
    }

    var isLeft: Bool {
        rawValue <= CYLImageTagDirection.leftBottomStraight.rawValue
    }

    var isCenterLine: Bool {
        self == .leftCenter || self == .rightCenter
    }
}

// MARK: - Models

/**
 * One tag: a title, its direction and anything the host keeps with it (the sample's TagGroupModel.Tag).
 */
public final class CYLImageTag {

    /**
     * The text of the tag.
     */
    public var title: String

    /**
     * Where the tag goes from the dot.
     */
    public var direction: CYLImageTagDirection

    /**
     * A link of the tag (the sample's Tag.link), not opened by the view.
     */
    public var link: String?

    /**
     * Anything the host keeps with the tag.
     */
    public var userInfo: Any?

    /**
     * A tag with a title and a direction.
     */
    public init(title: String, direction: CYLImageTagDirection, link: String? = nil, userInfo: Any? = nil) {
        self.title = title
        self.direction = direction
        self.link = link
        self.userInfo = userInfo
    }

    /**
     * An independent copy (the user info is shared).
     */
    public func copy() -> CYLImageTag {
        CYLImageTag(title: title, direction: direction, link: link, userInfo: userInfo)
    }
}

/**
 * A group of tags at a point of the picture, as fractions of its size (the sample's TagGroupModel).
 */
public final class CYLImageTagGroup {

    /**
     * The tags, at most `CYLImageTagGroupView.maximumTagCount` of them are shown.
     */
    public var tags: [CYLImageTag]

    /**
     * The dot's place, as fractions of the picture's width and height.
     */
    public var percentPosition: CGPoint

    /**
     * A group of tags at a point of the picture.
     */
    public init(tags: [CYLImageTag], percentPosition: CGPoint) {
        self.tags = tags
        self.percentPosition = percentPosition
    }

    /**
     * Directions for `count` new tags, as the sample's edit dialog sets them: one tag right-center; two right-top and
     * right-bottom; three right-top, right-center and right-bottom; then left-top, left-center and left-bottom.
     */
    public static func defaultDirections(forTagCount count: Int) -> [CYLImageTagDirection] {
        switch count {
        case ..<1:
            return []
        case 1:
            return [.rightCenter]
        case 2:
            return [.rightTop, .rightBottom]
        default:
            let all: [CYLImageTagDirection] = [.rightTop, .rightCenter, .rightBottom, .leftTop, .leftCenter, .leftBottom]
            return Array(all.prefix(min(count, CYLImageTagGroupView.maximumTagCount)))
        }
    }

    /**
     * An independent copy, with copies of the tags.
     */
    public func copy() -> CYLImageTagGroup {
        CYLImageTagGroup(tags: tags.map { $0.copy() }, percentPosition: percentPosition)
    }
}

// MARK: - Tag views

/**
 * A view that can be a tag of a group (TagViewGroup's ITagView). The group sizes it with `sizeThatFits(_:)` and places
 * it.
 */
public protocol CYLImageTagItem: UIView {

    /**
     * Where the tag goes from the dot.
     */
    var tagDirection: CYLImageTagDirection { get set }
}

/**
 * The default tag view (TagViewGroup's TagTextView): white 13 pt text with a black glow, 12 × 4 pt padding.
 */
open class CYLImageTagLabel: UILabel, CYLImageTagItem {

    /**
     * Where the tag goes from the dot; `.rightCenter` by default.
     */
    open var tagDirection: CYLImageTagDirection = .rightCenter

    /**
     * Space around the text. {4, 12, 4, 12} by default.
     */
    open var contentInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = .white
        // 13 pt at the default text size, scaled with Dynamic Type.
        font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: .systemFont(ofSize: 13))
        adjustsFontForContentSizeCategory = true
        numberOfLines = 0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 3.5
        layer.shadowOffset = .zero
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("CYLImageTagLabel is created in code")
    }

    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        // One line when it fits; wrapped to `size.width` otherwise (long titles, large Dynamic Type sizes).
        let horizontal = contentInsets.left + contentInsets.right
        let maximum = size.width > horizontal ? size.width - horizontal : .greatestFiniteMagnitude
        let text = super.sizeThatFits(CGSize(width: maximum, height: .greatestFiniteMagnitude))
        return CGSize(width: ceil(min(text.width, maximum) + horizontal),
                      height: ceil(text.height + contentInsets.top + contentInsets.bottom))
    }
}

/**
 * A pulsing circle (TagViewGroup's RippleView): it grows to `maximumRadius` and fades out, once a second.
 */
open class CYLImageTagRippleView: UIView, CYLImageTagItem {

    /**
     * Always `.center`: the ripple sits on the dot.
     */
    open var tagDirection: CYLImageTagDirection = .center

    /**
     * The largest radius of the circle.
     */
    open var maximumRadius = CYLImageTagGroupView.defaultRippleMaxRadius

    /**
     * The opacity at the start, 0...1. 100/255 by default.
     */
    open var startAlpha: CGFloat = 100 / 255

    /**
     * The circle's color, white by default.
     */
    open var color: UIColor = .white {
        didSet {
            setNeedsLayout()
        }
    }

    private let circleLayer = CAShapeLayer()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        circleLayer.opacity = 0
        layer.addSublayer(circleLayer)
        isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("CYLImageTagRippleView is created in code")
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        CGSize(width: 2 * maximumRadius, height: 2 * maximumRadius)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        circleLayer.frame = bounds
        circleLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        circleLayer.fillColor = color.cgColor
    }

    open override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            startAnimating()
        } else {
            stopAnimating()
        }
    }

    /**
     * Starts pulsing (not while Reduce Motion is on).
     */
    open func startAnimating() {
        guard !UIAccessibility.isReduceMotionEnabled else {
            return
        }
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0
        scale.toValue = 1
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = startAlpha
        fade.toValue = 0
        let group = CAAnimationGroup()
        group.animations = [scale, fade]
        group.duration = 1
        group.repeatCount = .infinity
        circleLayer.add(group, forKey: "ripple")
    }

    /**
     * Stops pulsing.
     */
    open func stopAnimating() {
        circleLayer.removeAnimation(forKey: "ripple")
    }
}

// MARK: - Data source and delegate

/**
 * TagViewGroup's TagAdapter: the views of the tags.
 */
public protocol CYLImageTagGroupViewDataSource: AnyObject {

    /**
     * How many tags the group shows (at most `CYLImageTagGroupView.maximumTagCount`).
     */
    func numberOfTags(in groupView: CYLImageTagGroupView) -> Int

    /**
     * The view of the tag at `index`.
     */
    func groupView(_ groupView: CYLImageTagGroupView, viewForTagAt index: Int) -> any CYLImageTagItem
}

/**
 * TagViewGroup's OnTagGroupClickListener and OnTagGroupDragListener. Every method has an empty default.
 */
public protocol CYLImageTagGroupViewDelegate: AnyObject {

    /**
     * The dot was tapped (or activated with VoiceOver).
     */
    func groupViewDidTapCircle(_ groupView: CYLImageTagGroupView)

    /**
     * The tag at `index` was tapped.
     */
    func groupView(_ groupView: CYLImageTagGroupView, didTapTagAt index: Int)

    /**
     * The group was long-pressed (or its long-press custom action was used).
     */
    func groupViewDidLongPress(_ groupView: CYLImageTagGroupView)

    /**
     * The user dragged the group (only while `isDraggable`); `percentPosition` is its new place.
     */
    func groupView(_ groupView: CYLImageTagGroupView, didDragToPercentPosition percentPosition: CGPoint)
}

public extension CYLImageTagGroupViewDelegate {
    func groupViewDidTapCircle(_ groupView: CYLImageTagGroupView) {}
    func groupView(_ groupView: CYLImageTagGroupView, didTapTagAt index: Int) {}
    func groupViewDidLongPress(_ groupView: CYLImageTagGroupView) {}
    func groupView(_ groupView: CYLImageTagGroupView, didDragToPercentPosition percentPosition: CGPoint) {}
}

// MARK: - Group view

/**
 * The dot as an accessibility element: its frame follows the dot, activating it taps the dot.
 */
private final class CYLImageTagCircleElement: UIAccessibilityElement {

    weak var groupView: CYLImageTagGroupView?

    override var accessibilityFrameInContainerSpace: CGRect {
        get {
            groupView?.circleAccessibilityFrame ?? .zero
        }
        set {
            // The frame always follows the dot.
        }
    }

    override func accessibilityActivate() -> Bool {
        guard let groupView else {
            return false
        }
        groupView.delegate?.groupViewDidTapCircle(groupView)
        return true
    }
}

/**
 * A group of tags around a dot on a picture (TagViewGroup's TagViewGroup): the dot, a line to each tag, the tags, an
 * optional ripple, show / hide animations, taps, a long press and dragging.
 */
open class CYLImageTagGroupView: UIView {

    // MARK: Defaults

    /**
     * 8: the dot's outer radius.
     */
    public static let defaultCircleRadius: CGFloat = 8

    /**
     * 4: the dot's inner radius.
     */
    public static let defaultCircleInnerRadius: CGFloat = 4

    /**
     * 28: the vertical distance of the lines.
     */
    public static let defaultVerticalDistance: CGFloat = 28

    /**
     * 20: the tilt distance of the slanted lines.
     */
    public static let defaultTiltDistance: CGFloat = 20

    /**
     * 1: the line width.
     */
    public static let defaultLineWidth: CGFloat = 1

    /**
     * 6: the most tags in one group.
     */
    public static let maximumTagCount = 6

    /**
     * 20: the ripple's largest radius.
     */
    public static let defaultRippleMaxRadius: CGFloat = 20

    /**
     * Animatable values of a group (TagViewGroup's CIRCLE_RADIUS, CIRCLE_INNER_RADIUS, LINES_RATIO, TAG_ALPHA
     * properties), for `animate(_:values:duration:completion:)`.
     */
    public enum AnimatableValue: CaseIterable, Sendable {
        case circleRadius
        case circleInnerRadius
        case linesProgress
        case tagAlpha
    }

    // MARK: Appearance

    /**
     * The dot's outer radius (TagViewGroup's radius), in points. When a tag is taller than `verticalDistance`, the
     * layout grows both distances by the difference, so tags in neighboring directions never overlap at large Dynamic
     * Type sizes; a tag wider than the room beside the dot wraps.
     */
    @IBInspectable open var circleRadius: CGFloat = defaultCircleRadius {
        didSet {
            circleRadius = max(0, circleRadius)
            setNeedsLayout()
            updateCircles()
        }
    }

    /**
     * The dot's inner radius (inner_radius).
     */
    @IBInspectable open var circleInnerRadius: CGFloat = defaultCircleInnerRadius {
        didSet {
            circleInnerRadius = max(0, circleInnerRadius)
            updateCircles()
        }
    }

    /**
     * The line width (line_width).
     */
    @IBInspectable open var lineWidth: CGFloat = defaultLineWidth {
        didSet {
            lineWidth = max(0, lineWidth)
            setNeedsLayout()
        }
    }

    /**
     * The vertical distance of the lines (v_distance).
     */
    @IBInspectable open var verticalDistance: CGFloat = defaultVerticalDistance {
        didSet {
            verticalDistance = max(0, verticalDistance)
            setNeedsLayout()
        }
    }

    /**
     * The tilt distance of the slanted lines (tilt_distance).
     */
    @IBInspectable open var tiltDistance: CGFloat = defaultTiltDistance {
        didSet {
            tiltDistance = max(0, tiltDistance)
            setNeedsLayout()
        }
    }

    /**
     * The ring's color: 0x30 black by default.
     */
    open var circleColor = UIColor(white: 0, alpha: 0x30 / 255) {
        didSet {
            updateCircles()
        }
    }

    /**
     * The dot's color: white by default.
     */
    open var circleInnerColor: UIColor = .white {
        didSet {
            updateCircles()
        }
    }

    /**
     * The lines' color: white by default.
     */
    open var lineColor: UIColor = .white {
        didSet {
            setNeedsLayout()
        }
    }

    // MARK: Position

    /**
     * The dot's place as fractions of the view's size (setPercent), clamped to 0...1; it moves inward when tags would
     * leave the view.
     */
    open var percentPosition = CGPoint(x: 0.5, y: 0.5) {
        didSet {
            percentPosition = CGPoint(x: min(1, max(0, percentPosition.x)), y: min(1, max(0, percentPosition.y)))
            setNeedsLayout()
        }
    }

    /**
     * The dot's center, in the view's coordinates (getCenterPoint), after the last layout.
     */
    public private(set) var centerPoint: CGPoint = .zero

    /**
     * Points added to the dot's place after it is computed from `percentPosition`, without changing
     * `percentPosition`. CYLImageTagView sets it to keep groups from covering each other; zero by default.
     */
    open var displayOffset: CGPoint = .zero {
        didSet {
            if displayOffset != oldValue {
                setNeedsLayout()
            }
        }
    }

    /**
     * The area the group draws in, in the view's coordinates: the dot and every tag, after the last layout.
     */
    public var occupiedFrame: CGRect {
        let radius = circleRadius
        let dot = CGRect(x: centerPoint.x - radius, y: centerPoint.y - radius, width: 2 * radius, height: 2 * radius)
        return itemViews.reduce(dot) { $0.union($1.frame) }
    }

    // MARK: Tags

    /**
     * Tags shown with CYLImageTagLabel views. Setting it replaces the data source's views.
     */
    open var tags: [CYLImageTag] = [] {
        didSet {
            reloadData()
        }
    }

    /**
     * Custom tag views instead (setTagAdapter); call `reloadData()` when they change (notifyDataSetChanged).
     */
    open weak var dataSource: CYLImageTagGroupViewDataSource?

    /**
     * The tag views, in order (getTagList), without the ripple.
     */
    public var tagViews: [any CYLImageTagItem] {
        itemViews
    }

    /**
     * Configures each CYLImageTagLabel the group makes (font, colors, insets).
     */
    open var tagLabelConfiguration: ((CYLImageTagLabel, CYLImageTag) -> Void)?

    // MARK: Ripple

    /**
     * A pulsing circle under the dot (addRipple, RippleView). False by default.
     */
    open var showsRipple = false {
        didSet {
            if showsRipple, rippleView == nil {
                let ripple = CYLImageTagRippleView(frame: .zero)
                insertSubview(ripple, at: 0)
                rippleView = ripple
            } else if !showsRipple {
                rippleView?.removeFromSuperview()
                rippleView = nil
            }
            rippleView?.maximumRadius = rippleMaxRadius
            rippleView?.startAlpha = rippleAlpha
            setNeedsLayout()
        }
    }

    /**
     * The ripple's largest radius.
     */
    open var rippleMaxRadius = defaultRippleMaxRadius {
        didSet {
            rippleMaxRadius = max(0, rippleMaxRadius)
            rippleView?.maximumRadius = rippleMaxRadius
            setNeedsLayout()
        }
    }

    /**
     * The ripple's opacity at the start, 0...1, 100/255 by default (ripple_alpha 100).
     */
    open var rippleAlpha: CGFloat = 100 / 255 {
        didSet {
            rippleAlpha = min(1, max(0, rippleAlpha))
            rippleView?.startAlpha = rippleAlpha
        }
    }

    /**
     * The ripple, while `showsRipple`.
     */
    public private(set) var rippleView: CYLImageTagRippleView?

    // MARK: Animation

    /**
     * How much of each line is drawn, 0...1 (setLinesRatio). 1 by default.
     */
    open var linesProgress: CGFloat = 1 {
        didSet {
            linesProgress = min(1, max(0, linesProgress))
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            for line in lineLayers {
                line.strokeEnd = linesProgress
            }
            CATransaction.commit()
        }
    }

    /**
     * The tags' opacity (setTagAlpha). 1 by default.
     */
    open var tagAlpha: CGFloat = 1 {
        didSet {
            tagAlpha = min(1, max(0, tagAlpha))
            for view in itemViews {
                view.alpha = tagAlpha
            }
        }
    }

    /**
     * Whether the group is hidden by `hide(animated:completion:)`.
     */
    public private(set) var isGroupHidden = false

    /**
     * A custom show animation (setShowAnimator): call the completion when done.
     */
    open var showAnimation: ((CYLImageTagGroupView, @escaping () -> Void) -> Void)?

    /**
     * A custom hide animation (setHideAnimator): call the completion when done.
     */
    open var hideAnimation: ((CYLImageTagGroupView, @escaping () -> Void) -> Void)?

    // MARK: Interaction

    /**
     * Taps, the long press and drags.
     */
    open weak var delegate: CYLImageTagGroupViewDelegate? {
        didSet {
            updateAccessibility()
        }
    }

    /**
     * Lets the user drag the group (setOnTagGroupDragListener). False by default.
     */
    open var isDraggable = false {
        didSet {
            updateAccessibility()
        }
    }

    // MARK: Accessibility

    /**
     * The dot as one VoiceOver / Voice Control / Switch Control element, before the tags. Its label is
     * "标签组：<the tag titles>" (core string `CYLImageTagGroup`); activating it is a tap on the dot. Its custom actions:
     * the long press (named by `longPressAccessibilityActionName`, while there is a delegate), and
     * 上移 / 下移 / 左移 / 右移 while `isDraggable` (each moves the group by `accessibilityMoveStep` and reports a drag).
     */
    public private(set) lazy var circleAccessibilityElement: UIAccessibilityElement = {
        let circle = CYLImageTagCircleElement(accessibilityContainer: self)
        circle.groupView = self
        circle.accessibilityTraits = .button
        return circle
    }()

    /**
     * The name of the long-press custom action of the dot, such as "删除标签组". nil: "长按" (core string
     * `CYLMenuLongPress`).
     */
    open var longPressAccessibilityActionName: String? {
        didSet {
            updateAccessibility()
        }
    }

    /**
     * The hint of every tag view, such as "轻点两下改变方向" in edit mode. nil by default.
     */
    open var tagAccessibilityHint: String? {
        didSet {
            for view in itemViews {
                view.accessibilityHint = tagAccessibilityHint
            }
        }
    }

    /**
     * How far one 上移 / 下移 / 左移 / 右移 action moves the group, as a fraction of the view. 0.05 by default.
     */
    open var accessibilityMoveStep: CGFloat = 0.05

    // MARK: Private state

    private var itemViews: [any CYLImageTagItem] = []
    private var lineLayers: [CAShapeLayer] = []
    private let outerCircleLayer = CAShapeLayer()
    private let innerCircleLayer = CAShapeLayer()
    private var displayLink: CADisplayLink?
    private var displayStep: ((CFTimeInterval) -> Void)?
    private var dragOffset: CGPoint = .zero
    /**
     * The distances of the last layout: at least the tallest tag, so that tags in neighboring directions never
     * overlap.
     */
    private var layoutVerticalDistance: CGFloat = 0
    private var layoutTiltDistance: CGFloat = 0

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
        backgroundColor = .clear
        layer.addSublayer(outerCircleLayer)
        layer.addSublayer(innerCircleLayer)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
        updateAccessibility()
    }

    deinit {
        displayLink?.invalidate()
    }

    // MARK: - Tags

    /**
     * Sets the dot's place as fractions of the view's size (setPercent).
     */
    open func setPercentPosition(x percentX: CGFloat, y percentY: CGFloat) {
        percentPosition = CGPoint(x: percentX, y: percentY)
    }

    /**
     * Makes the tag views again, from the data source or from `tags`.
     */
    open func reloadData() {
        for view in itemViews {
            view.removeFromSuperview()
        }
        itemViews.removeAll()
        let count = dataSource?.numberOfTags(in: self) ?? tags.count
        for index in 0..<min(max(0, count), Self.maximumTagCount) {
            let view: any CYLImageTagItem
            if let dataSource {
                view = dataSource.groupView(self, viewForTagAt: index)
            } else {
                let tag = tags[index]
                let label = CYLImageTagLabel(frame: .zero)
                label.text = tag.title
                label.accessibilityLabel = tag.title
                label.tagDirection = tag.direction
                tagLabelConfiguration?(label, tag)
                view = label
            }
            view.alpha = tagAlpha
            if let tagAccessibilityHint {
                view.accessibilityHint = tagAccessibilityHint
            }
            addSubview(view)
            itemViews.append(view)
        }
        updateAccessibility()
        setNeedsLayout()
    }

    // MARK: - Geometry (TagGroupUtils)

    /**
     * The space the dot and the tags need on each side of the center (getTagViewUsed).
     */
    open func tagSpaceUsed() -> UIEdgeInsets {
        tagSpaceUsed(for: itemSizes())
    }

    /**
     * The top-left corner of a tag view of `size` in `direction` (getStartPoint).
     */
    open func originForTag(of size: CGSize, direction: CYLImageTagDirection) -> CGPoint {
        let cx = centerPoint.x
        let cy = centerPoint.y
        let v = max(verticalDistance, layoutVerticalDistance)
        let t = max(tiltDistance, layoutTiltDistance)
        switch direction {
        case .rightTopStraight: return CGPoint(x: cx + t, y: cy - t - size.height)
        case .rightTop: return CGPoint(x: cx, y: cy - v - size.height)
        case .rightCenter: return CGPoint(x: cx, y: cy - size.height)
        case .rightBottom: return CGPoint(x: cx, y: cy + v - size.height)
        case .rightBottomStraight: return CGPoint(x: cx + t, y: cy + t - size.height)
        case .leftTop: return CGPoint(x: cx - size.width, y: cy - v - size.height)
        case .leftTopStraight: return CGPoint(x: cx - size.width - t, y: cy - t - size.height)
        case .leftCenter: return CGPoint(x: cx - size.width, y: cy - size.height)
        case .leftBottom: return CGPoint(x: cx - size.width, y: cy + v - size.height)
        case .leftBottomStraight: return CGPoint(x: cx - size.width - t, y: cy + t - size.height)
        case .center: return CGPoint(x: cx - size.width / 2, y: cy - size.height / 2)
        }
    }

    private func tagSpaceUsed(for sizes: [CGSize]) -> UIEdgeInsets {
        var left = circleRadius
        var top = circleRadius
        var right = circleRadius
        var bottom = circleRadius
        let tallest = sizes.map(\.height).max() ?? 0
        // Grown only when a tag is taller than the vertical distance (large text); the tilt grows by the same amount.
        let v = max(verticalDistance, tallest)
        let t = tiltDistance + (v - verticalDistance)
        layoutVerticalDistance = v
        layoutTiltDistance = t
        for (view, size) in zip(itemViews, sizes) {
            switch view.tagDirection {
            case .rightTopStraight: right = max(right, t + size.width); top = max(top, size.height + t)
            case .rightTop: right = max(right, size.width); top = max(top, size.height + v)
            case .rightCenter: right = max(right, size.width); top = max(top, max(v, size.height))
            case .rightBottom: right = max(right, size.width); bottom = max(bottom, v)
            case .rightBottomStraight: right = max(right, t + size.width); bottom = max(bottom, t)
            case .leftTop: left = max(left, size.width); top = max(top, size.height + v)
            case .leftTopStraight: left = max(left, size.width + t); top = max(top, size.height + t)
            case .leftCenter: left = max(left, size.width); top = max(top, max(v, size.height))
            case .leftBottom: left = max(left, size.width); bottom = max(bottom, v)
            case .leftBottomStraight: left = max(left, size.width + t); bottom = max(bottom, t)
            case .center: left = max(left, size.width / 2); bottom = max(bottom, size.height / 2)
            }
        }
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }

    private func itemSizes() -> [CGSize] {
        // A tag never needs more than the width beside the dot.
        let width = max(44, bounds.width - 2 * circleRadius - tiltDistance)
        return itemViews.map { $0.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)) }
    }

    // MARK: - Layout and drawing

    open override func layoutSubviews() {
        super.layoutSubviews()
        let sizes = itemSizes()
        let used = tagSpaceUsed(for: sizes)
        let width = bounds.width
        let height = bounds.height
        var cx = width * percentPosition.x
        var cy = height * percentPosition.y
        // TagViewGroup's checkBounds: move the dot inward when tags would leave the view.
        if used.right > width - cx { cx -= used.right - (width - cx) }
        if used.left > cx { cx += used.left - cx }
        if used.bottom > height - cy { cy -= used.bottom - (height - cy) }
        if used.top > cy { cy += used.top - cy }
        centerPoint = CGPoint(x: cx + displayOffset.x, y: cy + displayOffset.y)
        for line in lineLayers {
            line.removeFromSuperlayer()
        }
        lineLayers.removeAll()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for (view, size) in zip(itemViews, sizes) {
            view.frame = CGRect(origin: originForTag(of: size, direction: view.tagDirection), size: size)
            guard view.tagDirection != .center else {
                continue
            }
            let frame = view.frame
            let left = view.tagDirection.isLeft
            let path = UIBezierPath()
            path.move(to: centerPoint)
            if !view.tagDirection.isCenterLine {
                path.addLine(to: CGPoint(x: left ? frame.maxX : frame.minX, y: frame.maxY))
            }
            path.addLine(to: CGPoint(x: left ? frame.minX : frame.maxX, y: frame.maxY))
            let line = CAShapeLayer()
            line.path = path.cgPath
            line.fillColor = nil
            line.strokeColor = lineColor.cgColor
            line.lineWidth = lineWidth
            line.strokeEnd = linesProgress
            layer.insertSublayer(line, below: outerCircleLayer)
            lineLayers.append(line)
        }
        if let rippleView {
            let side = 2 * rippleMaxRadius
            rippleView.frame = CGRect(x: cx - side / 2, y: cy - side / 2, width: side, height: side)
        }
        updateCircles()
        CATransaction.commit()
    }

    private func updateCircles() {
        outerCircleLayer.path = UIBezierPath(arcCenter: centerPoint, radius: circleRadius, startAngle: 0,
                                             endAngle: 2 * .pi, clockwise: true).cgPath
        outerCircleLayer.fillColor = circleColor.cgColor
        innerCircleLayer.path = UIBezierPath(arcCenter: centerPoint, radius: circleInnerRadius, startAngle: 0,
                                             endAngle: 2 * .pi, clockwise: true).cgPath
        innerCircleLayer.fillColor = circleInnerColor.cgColor
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            setNeedsLayout()
        }
    }

    // MARK: - Accessibility

    open override var accessibilityElements: [Any]? {
        get {
            guard !isGroupHidden else {
                return []
            }
            var elements: [Any] = [circleAccessibilityElement]
            if tagAlpha > 0 {
                elements.append(contentsOf: itemViews)
            }
            return elements
        }
        set {
            // The elements always follow the dot and the tags.
        }
    }

    fileprivate var circleAccessibilityFrame: CGRect {
        let radius = max(circleRadius * 2, 22)
        let frame = CGRect(x: centerPoint.x - radius, y: centerPoint.y - radius, width: 2 * radius, height: 2 * radius)
        return frame
    }

    /**
     * The dot's label ("标签组：<titles>") and its custom actions.
     */
    private func updateAccessibility() {
        let titles: [String] = itemViews.compactMap { view in
            // A data source's label view may rely on its text.
            let title = view.accessibilityLabel?.isEmpty == false ? view.accessibilityLabel : (view as? UILabel)?.text
            return title?.isEmpty == false ? title : nil
        }
        let list = ListFormatter()
        list.locale = Locale(identifier: CYLMenuResources.currentLanguage)
        let joined = list.string(from: titles) ?? ""
        circleAccessibilityElement.accessibilityLabel = String(format: CYLMenuLocalizedString("CYLImageTagGroup"), joined)

        var actions: [UIAccessibilityCustomAction] = []
        if delegate != nil {
            let name = longPressAccessibilityActionName?.isEmpty == false ? longPressAccessibilityActionName ?? ""
                                                                           : CYLMenuLocalizedString("CYLMenuLongPress")
            actions.append(UIAccessibilityCustomAction(name: name) { [weak self] _ in
                guard let self else {
                    return false
                }
                self.delegate?.groupViewDidLongPress(self)
                return true
            })
        }
        if isDraggable {
            let moves: [(key: String, dx: CGFloat, dy: CGFloat)] = [
                ("CYLImageTagMoveUp", 0, -1), ("CYLImageTagMoveDown", 0, 1),
                ("CYLImageTagMoveLeft", -1, 0), ("CYLImageTagMoveRight", 1, 0),
            ]
            for move in moves {
                actions.append(UIAccessibilityCustomAction(name: CYLMenuLocalizedString(move.key)) { [weak self] _ in
                    self?.accessibilityMove(dx: move.dx, dy: move.dy) ?? false
                })
            }
        }
        circleAccessibilityElement.accessibilityCustomActions = actions
    }

    /**
     * 上移 / 下移 / 左移 / 右移: a drag by `accessibilityMoveStep`.
     */
    private func accessibilityMove(dx: CGFloat, dy: CGFloat) -> Bool {
        let old = percentPosition
        percentPosition = CGPoint(x: old.x + dx * accessibilityMoveStep, y: old.y + dy * accessibilityMoveStep)
        guard old != percentPosition else {
            return false
        }
        layoutIfNeeded()
        delegate?.groupView(self, didDragToPercentPosition: percentPosition)
        UIAccessibility.post(notification: .layoutChanged, argument: circleAccessibilityElement)
        return true
    }

    // MARK: - Touches

    /**
     * Only the dot and the tags take touches: groups lie over the picture and over each other.
     */
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard !isGroupHidden else {
            return false
        }
        return isPointOnCircle(point) || tagIndex(at: point) != nil
    }

    private func isPointOnCircle(_ point: CGPoint) -> Bool {
        let radius = max(circleRadius * 2, 22)
        return hypot(point.x - centerPoint.x, point.y - centerPoint.y) <= radius
    }

    private func tagIndex(at point: CGPoint) -> Int? {
        itemViews.firstIndex { $0.tagDirection != .center && $0.frame.contains(point) }
    }

    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        if let index = tagIndex(at: recognizer.location(in: self)) {
            delegate?.groupView(self, didTapTagAt: index)
        } else {
            delegate?.groupViewDidTapCircle(self)
        }
    }

    @objc private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            delegate?.groupViewDidLongPress(self)
        }
    }

    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer && gestureRecognizer.view === self {
            return isDraggable
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: self)
        if recognizer.state == .began {
            dragOffset = CGPoint(x: centerPoint.x - point.x, y: centerPoint.y - point.y)
            return
        }
        guard recognizer.state == .changed || recognizer.state == .ended else {
            return
        }
        let width = max(1, bounds.width)
        let height = max(1, bounds.height)
        percentPosition = CGPoint(x: (point.x + dragOffset.x) / width, y: (point.y + dragOffset.y) / height)
        layoutIfNeeded()
        delegate?.groupView(self, didDragToPercentPosition: percentPosition)
    }

    // MARK: - Animation

    /**
     * The current value of an animatable value.
     */
    public func value(of animatable: AnimatableValue) -> CGFloat {
        switch animatable {
        case .circleRadius: return circleRadius
        case .circleInnerRadius: return circleInnerRadius
        case .linesProgress: return linesProgress
        case .tagAlpha: return tagAlpha
        }
    }

    private func setValue(_ value: CGFloat, of animatable: AnimatableValue) {
        switch animatable {
        case .circleRadius: circleRadius = value
        case .circleInnerRadius: circleInnerRadius = value
        case .linesProgress: linesProgress = value
        case .tagAlpha: tagAlpha = value
        }
    }

    /**
     * Animates one value through `values`, decelerating (as an ObjectAnimator with a DecelerateInterpolator); with
     * Reduce Motion, no values or no duration it jumps to the last value.
     */
    open func animate(_ animatable: AnimatableValue, values: [CGFloat], duration: TimeInterval,
                      completion: (() -> Void)? = nil) {
        guard let last = values.last, duration > 0, !UIAccessibility.isReduceMotionEnabled else {
            if let last = values.last {
                setValue(last, of: animatable)
            }
            completion?()
            return
        }
        displayLink?.invalidate()
        displayStep = makeStep(animatable, values: values, last: last, duration: duration, completion: completion)
        let link = CADisplayLink(target: self, selector: #selector(step(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func makeStep(_ animatable: AnimatableValue, values: [CGFloat], last: CGFloat, duration: TimeInterval,
                          completion: (() -> Void)?) -> (CFTimeInterval) -> Void {
        var start: CFTimeInterval = 0
        return { [weak self] now in
            guard let self else {
                return
            }
            if start == 0 {
                start = now
            }
            let t = CGFloat(min(1, (now - start) / duration))
            // Decelerating, as the sample's DecelerateInterpolator; piecewise linear between the values.
            let eased = 1 - (1 - t) * (1 - t)
            let position = eased * CGFloat(values.count - 1)
            let index = min(Int(position.rounded(.down)), values.count - 1)
            let next = min(index + 1, values.count - 1)
            let fraction = position - CGFloat(index)
            self.setValue(values[index] + (values[next] - values[index]) * fraction, of: animatable)
            if t >= 1 {
                self.setValue(last, of: animatable)
                self.displayLink?.invalidate()
                self.displayLink = nil
                self.displayStep = nil
                completion?()
            }
        }
    }

    @objc private func step(_ link: CADisplayLink) {
        displayStep?(link.timestamp)
    }

    /**
     * The dot grows and shrinks back, 0.4 s (the sample's circleRadiusAnimator); one display link drives both radii.
     */
    private func bounceCircle(completion: @escaping () -> Void) {
        let radius = circleRadius
        let inner = circleInnerRadius
        guard !UIAccessibility.isReduceMotionEnabled else {
            completion()
            return
        }
        let innerStep = makeStep(.circleInnerRadius, values: [max(0, inner - 3), inner + 3, inner], last: inner,
                                 duration: 0.4, completion: nil)
        let outerStep = makeStep(.circleRadius, values: [max(0, radius - 3), radius + 3, radius], last: radius,
                                 duration: 0.4, completion: completion)
        displayLink?.invalidate()
        displayStep = { now in
            innerStep(now)
            outerStep(now)
        }
        let link = CADisplayLink(target: self, selector: #selector(step(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    /**
     * Shows the group: the dot bounces, the lines grow, the tags fade in (the sample's show animator), or runs
     * `showAnimation` when set.
     */
    open func show(animated: Bool, completion: (() -> Void)? = nil) {
        isGroupHidden = false
        isHidden = false
        if animated, let showAnimation {
            showAnimation(self) { completion?() }
            return
        }
        guard animated, !UIAccessibility.isReduceMotionEnabled else {
            linesProgress = 1
            tagAlpha = 1
            completion?()
            return
        }
        linesProgress = 0
        tagAlpha = 0
        bounceCircle { [weak self] in
            self?.animate(.linesProgress, values: [0, 1], duration: 0.3) {
                self?.animate(.tagAlpha, values: [0, 1], duration: 0.2, completion: completion)
            }
        }
    }

    /**
     * Hides it: the dot bounces, then the lines and tags fade together (the sample's hide animator), or
     * `hideAnimation`.
     */
    open func hide(animated: Bool, completion: (() -> Void)? = nil) {
        let finish = { [weak self] in
            self?.isGroupHidden = true
            self?.isHidden = true
            completion?()
        }
        if animated, let hideAnimation {
            hideAnimation(self, finish)
            return
        }
        guard animated, !UIAccessibility.isReduceMotionEnabled else {
            finish()
            return
        }
        bounceCircle { [weak self] in
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                self?.tagAlpha = 0
            })
            self?.animate(.linesProgress, values: [1, 0], duration: 0.4, completion: finish)
        }
    }
}
