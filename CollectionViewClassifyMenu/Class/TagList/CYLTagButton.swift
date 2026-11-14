//
//  CYLTagButton.swift
//  CollectionViewClassifyMenu
//
//  One tag: CYLFlatDesignTabBarButton (CYLTabBarController) laid out horizontally, the icon before the title, in a box
//  styled like a CYLBadgeView. CYLTagListView puts one in every cell; it can also be used on its own.
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * CYLTabBarController's animation engine, found at runtime so that the component does not depend on
 * CYLTabBarController; the libraries' animators register themselves with it, as for tab bar items.
 *
 * - `+[CYLTabBarItemAnimationFactory animationViewWithURL:size:contentMode:]` makes the view;
 * - `+[CYLTabBarItemAnimationFactory playerForView:]` returns its `CYLTabBarItemAnimationPlayer`, whose `play`,
 *   `showLastFrame`, `stop` and optional `animationSpeed` / `progress` the tag uses.
 */
private enum CYLTagAnimationEngine {

    typealias MakeView = @convention(c) (AnyObject, Selector, NSURL, CGSize, UIView.ContentMode) -> UIView?

    static let makeViewSelector = NSSelectorFromString("animationViewWithURL:size:contentMode:")
    static let playerSelector = NSSelectorFromString("playerForView:")

    /**
     * The factory class, when it is linked and answers both selectors.
     */
    static var factory: AnyClass? {
        guard let factory = NSClassFromString("CYLTabBarItemAnimationFactory"),
              class_getClassMethod(factory, makeViewSelector) != nil,
              class_getClassMethod(factory, playerSelector) != nil else {
            return nil
        }
        return factory
    }

    static func makeView(url: URL, size: CGSize) -> UIView? {
        guard let factory, let method = class_getClassMethod(factory, makeViewSelector) else {
            return nil
        }
        let make = unsafeBitCast(method_getImplementation(method), to: MakeView.self)
        return make(factory as AnyObject, makeViewSelector, url as NSURL, size, .scaleAspectFit)
    }

    static func player(for view: UIView) -> AnyObject? {
        guard let factory else {
            return nil
        }
        return (factory as AnyObject).perform(playerSelector, with: view)?.takeUnretainedValue()
    }

    static func send(_ name: String, to player: AnyObject?) {
        let selector = NSSelectorFromString(name)
        if let player, player.responds(to: selector) {
            _ = player.perform(selector)
        }
    }

    static func set(_ value: CGFloat, forKey key: String, of player: AnyObject?) {
        let setter = NSSelectorFromString("set" + key.prefix(1).uppercased() + key.dropFirst() + ":")
        if let player = player as? NSObject, player.responds(to: setter) {
            player.setValue(value, forKey: key)
        }
    }
}

/**
 * One tag: an icon and a title side by side (the icon after the title with `imagePlacement`), in a box drawn from the
 * style's appearance for the current state, with an optional delete indicator and an optional animated icon.
 */
open class CYLTagButton: UIControl {

    private static let states: [UIControl.State] = [.normal, .selected, .disabled]
    private static let disabledAnimationAlpha: CGFloat = 0.4

    /**
     * The icon.
     */
    @objc public let imageView = UIImageView()

    /**
     * The title.
     */
    @objc public let titleLabel = UILabel()

    /**
     * The label that draws the delete indicator (hidden unless `showsDeleteIndicator`).
     */
    public let deleteIndicatorLabel = UILabel()

    /**
     * The title.
     */
    open var title: String? {
        didSet {
            updateAppearance()
        }
    }

    /**
     * The icon.
     */
    open var image: UIImage? {
        didSet {
            updateAppearance()
        }
    }

    /**
     * Shown while selected; `nil` keeps `image` (as CYLFlatDesignTabBarItem.selectedImage).
     */
    open var selectedImage: UIImage? {
        didSet {
            updateAppearance()
        }
    }

    /**
     * Animated icon file (Lottie .json, .pag, .riv, .gif…). The view comes from CYLTabBarController's animation engine
     * (`CYLTabBarItemAnimationFactory`), found at runtime as CYLTabBarController's own Core does: add the library's
     * subspec to the app, e.g. `pod 'CYLTabBarController/Lottie'`. Without it, or when the file cannot be loaded,
     * `image` is shown.
     */
    open var animationURL: URL? {
        didSet {
            if oldValue == animationURL && (animationView != nil || animationURL == nil) {
                return
            }
            reloadAnimationView()
        }
    }

    /**
     * The frame (0...1) of the animated icon shown while not selected. Default 0, the first frame.
     */
    open var animationRestingProgress: CGFloat = 0 {
        didSet {
            if oldValue != animationRestingProgress {
                updateAnimationState()
            }
        }
    }

    /**
     * The animation view in the icon slot, or `nil`.
     */
    open private(set) var animationView: UIView?

    /**
     * Its `CYLTabBarItemAnimationPlayer` (play, showLastFrame, stop), whatever the library, or `nil`.
     */
    open private(set) var animationPlayer: AnyObject?

    /**
     * Shows the style's delete indicator ("×", `CYLMenuStyle.deleteIndicatorTitle`) after the title, as
     * android-tagview's deletable tags. False by default. `CYLTagListView` turns it on for deletable items and handles
     * taps on it.
     */
    open var showsDeleteIndicator = false {
        didSet {
            if oldValue != showsDeleteIndicator {
                updateAppearance()
            }
        }
    }

    /**
     * The area a tap on the delete indicator should cover, in the tag's coordinates: from the space before it to the
     * trailing edge, the tag's full height. `.zero` while it is hidden.
     */
    open private(set) var deleteIndicatorHitFrame: CGRect = .zero

    /**
     * The style the tag is drawn with. Setting copies it; set it again after changing it.
     */
    open var style: CYLMenuStyle {
        get {
            styleStorage
        }
        set {
            styleStorage = newValue.cylCopy()
            if animationView != nil && animationViewSize != animationSize {
                reloadAnimationView()
            } else {
                updateAnimationState()
            }
            updateAppearance()
        }
    }

    /**
     * Whether CYLTabBarController's animation engine is linked into the app.
     */
    public static var isAnimationEngineAvailable: Bool {
        CYLTagAnimationEngine.factory != nil
    }

    private var styleStorage = CYLMenuStyle()
    private var animationViewSize: CGSize = .zero
    private let backgroundImageView = UIImageView()
    /**
     * The cross of `CYLMenuStyle.deleteIndicatorLineWidth`.
     */
    private let crossLayer = CAShapeLayer()

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
        imageView.contentMode = .scaleAspectFit
        titleLabel.lineBreakMode = .byTruncatingTail
        backgroundImageView.isHidden = true
        deleteIndicatorLabel.textAlignment = .center
        deleteIndicatorLabel.isHidden = true
        deleteIndicatorLabel.isAccessibilityElement = false
        addSubview(backgroundImageView)
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(deleteIndicatorLabel)
        crossLayer.fillColor = nil
        crossLayer.lineCap = .round
        layer.addSublayer(crossLayer)
        layer.masksToBounds = true
        updateAppearance()
    }

    // MARK: - Animation

    /**
     * Plays the animated icon from the start, as a tab icon plays when the tab is tapped.
     */
    open func playAnimation() {
        if UIAccessibility.isReduceMotionEnabled {
            // Reduce Motion: jump to the end state instead of playing.
            updateAnimationState()
            return
        }
        CYLTagAnimationEngine.send("play", to: animationPlayer)
    }

    // MARK: - Measurement

    /**
     * Width a tag needs for its content in every state (so that selecting it does not resize it), before any limit on
     * the available width.
     */
    public static func width(forTitle title: String?, image: UIImage?, style: CYLMenuStyle,
                             traitCollection: UITraitCollection?) -> CGFloat {
        width(forTitle: title, iconSize: iconSize(for: image, style: style), style: style,
              traitCollection: traitCollection)
    }

    /**
     * The same for an icon of `iconSize` (`.zero` for none), e.g. an animated icon, with room for the delete indicator
     * when `showsDeleteIndicator`.
     */
    public static func width(forTitle title: String?, iconSize: CGSize, showsDeleteIndicator: Bool = false,
                             style: CYLMenuStyle, traitCollection: UITraitCollection?) -> CGFloat {
        let displayed = style.displayedTitle(forTitle: title)
        var width: CGFloat = 0
        for state in states {
            let appearance = style.appearance(for: state)
            let font = style.titleFont(for: state, traitCollection: traitCollection)
            let titleWidth = displayed.isEmpty ? 0 : ceil((displayed as NSString).size(withAttributes: [.font: font]).width)
            var content = titleWidth + iconSize.width
            if titleWidth > 0 && iconSize.width > 0 {
                content += style.imageTitleSpacing
            } else if titleWidth > 0 && !style.layoutCentered && style.contentAlignment == .center {
                // The title keeps its place after an empty icon slot.
                content += style.imageSize.width + style.imageTitleSpacing
            }
            if showsDeleteIndicator {
                content += style.imageTitleSpacing
                    + deleteIndicatorWidth(for: state, style: style, traitCollection: traitCollection)
            }
            width = max(width, ceil(content + appearance.contentInsets.left + appearance.contentInsets.right))
        }
        return width
    }

    /**
     * Size of the icon slot for an image, or for an animated icon when `animated` and the engine is linked.
     */
    public static func iconSize(for image: UIImage?, animated: Bool, style: CYLMenuStyle) -> CGSize {
        if animated && isAnimationEngineAvailable {
            return style.animationSize == .zero ? style.imageSize : style.animationSize
        }
        return iconSize(for: image, style: style)
    }

    /**
     * Tag height: `style.itemHeight`, or more when a line of the title font plus the appearance's top and bottom
     * content insets needs it.
     */
    public static func height(for style: CYLMenuStyle, traitCollection: UITraitCollection?) -> CGFloat {
        states.reduce(style.itemHeight) { height, state in
            let insets = style.appearance(for: state).contentInsets
            let font = style.titleFont(for: state, traitCollection: traitCollection)
            return max(height, ceil(font.lineHeight) + insets.top + insets.bottom)
        }
    }

    // MARK: - Overrides

    open override var isSelected: Bool {
        didSet {
            if oldValue != isSelected {
                updateAnimationState()
            }
            updateAppearance()
        }
    }

    open override var isEnabled: Bool {
        didSet {
            updateAppearance()
        }
    }

    open override var isHighlighted: Bool {
        didSet {
            updateAppearance()
        }
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateAppearance()
    }

    /**
     * CYLFlatDesignTabBarButton's `_updateLayout`, with the icon and title side by side.
     */
    open override func layoutSubviews() {
        super.layoutSubviews()
        var width = bounds.width
        let height = bounds.height
        let style = styleStorage
        let state = currentState
        let insets = style.appearance(for: state).contentInsets
        backgroundImageView.frame = bounds
        let deleteWidth = layOutDeleteIndicator(state: state, insets: insets)
        let indicatorFirst = showsDeleteIndicator && style.deleteIndicatorPlacement == .leading
        // The leading margin; `trailing` is the space after the content (the right inset and the delete indicator).
        let margin = insets.left + (indicatorFirst ? deleteWidth : 0)
        let trailing = insets.right + (indicatorFirst ? 0 : deleteWidth)
        let contentTop = insets.top
        let contentHeight = max(0, height - insets.top - insets.bottom)
        width -= trailing - margin
        let animated = animationView != nil
        let showsImage = animated || imageView.image != nil
        let showsTitle = !(titleLabel.text ?? "").isEmpty
        let iconSize = animated ? animationSize : Self.iconSize(for: imageView.image, style: style)
        let spacing = showsImage && showsTitle ? style.imageTitleSpacing : 0

        let available = max(0, width - 2 * margin - (showsImage ? iconSize.width + spacing : 0))
        let titleSize = showsTitle ? titleLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: height))
            : .zero
        var titleWidth = min(available, ceil(titleSize.width))
        let titleHeight = min(height, ceil(titleSize.height))

        var imageX: CGFloat = 0
        var titleX: CGFloat = 0
        let leading = style.contentAlignment == .leading
        if showsImage && showsTitle {
            let group = iconSize.width + spacing + titleWidth
            // Centered, or from the leading margin (the title truncated above, so the icon after it stays visible).
            let start = leading ? margin : floor((width - group) / 2)
            if style.imagePlacement == .trailing {
                titleX = start
                imageX = titleX + titleWidth + spacing
            } else {
                imageX = start
                titleX = imageX + iconSize.width + spacing
            }
        } else if showsImage && leading {
            imageX = margin
        } else if showsTitle && leading {
            titleX = margin
            titleWidth = min(titleWidth, max(0, width - 2 * margin))
        } else if showsImage {
            imageX = style.layoutCentered ? floor((width - iconSize.width) / 2) : margin
        } else if showsTitle {
            titleX = style.layoutCentered ? floor((width - titleWidth) / 2)
                : margin + style.imageSize.width + style.imageTitleSpacing
            titleWidth = min(titleWidth, max(0, width - margin - titleX))
        }

        if showsTitle {
            titleLabel.frame = CGRect(x: titleX + style.titlePositionAdjustment.horizontal,
                                      y: Self.centeredY(titleHeight, contentTop: contentTop, contentHeight: contentHeight,
                                                        height: height) + style.titlePositionAdjustment.vertical,
                                      width: titleWidth, height: titleHeight)
        } else {
            titleLabel.frame = .zero
        }
        if showsImage {
            var frame = CGRect(x: imageX + style.imagePositionAdjustment.horizontal,
                               y: Self.centeredY(iconSize.height, contentTop: contentTop, contentHeight: contentHeight,
                                                 height: height) + style.imagePositionAdjustment.vertical,
                               width: iconSize.width, height: iconSize.height)
            // Only the size changes; x and y stay, as CYLFlatDesignTabBarItem.imageInsets.
            let imageInsets = style.imageInsets
            frame.size.width = max(0, frame.width - imageInsets.left - imageInsets.right)
            frame.size.height = max(0, frame.height - imageInsets.top - imageInsets.bottom)
            if let animationView {
                animationView.frame = frame
                placeImageView(.zero)
            } else {
                placeImageView(frame)
            }
        } else {
            placeImageView(.zero)
        }
        // 0 is automatic: a capsule, as for CYLBadgeAppearance.
        let radius = style.appearance(for: state).cornerRadius
        layer.cornerRadius = radius > 0 ? (radius <= CYLTagCornerRadiusSquare ? 0 : min(radius, height / 2)) : height / 2
    }

    // MARK: - Private

    /**
     * The state used for the appearance: disabled wins over selected (as on UIControl).
     */
    private var currentState: UIControl.State {
        if !isEnabled {
            return .disabled
        }
        return isSelected ? .selected : .normal
    }

    private var animationSize: CGSize {
        let size = styleStorage.animationSize
        return size == .zero ? styleStorage.imageSize : size
    }

    private static func iconSize(for image: UIImage?, style: CYLMenuStyle) -> CGSize {
        guard let image else {
            return .zero
        }
        return style.imageSize == .zero ? image.size : style.imageSize
    }

    /**
     * The delete indicator's width, in a state.
     */
    private static func deleteIndicatorWidth(for state: UIControl.State, style: CYLMenuStyle,
                                             traitCollection: UITraitCollection?) -> CGFloat {
        if style.deleteIndicatorWidth > 0 {
            return style.deleteIndicatorWidth
        }
        let font = style.deleteIndicatorFont(for: state, traitCollection: traitCollection)
        if style.deleteIndicatorLineWidth > 0 {
            return ceil(font.lineHeight * 0.75) + 2 * style.deleteIndicatorPadding
        }
        return ceil((style.deleteIndicatorTitle as NSString).size(withAttributes: [.font: font]).width)
    }

    /**
     * The y that centers something `size` tall between the top and bottom content insets, or in the whole tag when it
     * does not fit between them.
     */
    private static func centeredY(_ size: CGFloat, contentTop: CGFloat, contentHeight: CGFloat, height: CGFloat) -> CGFloat {
        size <= contentHeight ? contentTop + floor((contentHeight - size) / 2) : floor((height - size) / 2)
    }

    /**
     * Bounds and center instead of frame, so that a transform (the fold chevron's 180° turn) is kept.
     */
    private func placeImageView(_ frame: CGRect) {
        imageView.bounds = CGRect(origin: .zero, size: frame.size)
        imageView.center = CGPoint(x: frame.midX, y: frame.midY)
    }

    /**
     * The delete indicator at the trailing (or leading) inset, its hit area and its cross; returns the width it takes
     * with the space before it (0 while hidden).
     */
    private func layOutDeleteIndicator(state: UIControl.State, insets: UIEdgeInsets) -> CGFloat {
        let style = styleStorage
        let width = bounds.width
        let height = bounds.height
        guard showsDeleteIndicator else {
            deleteIndicatorLabel.frame = .zero
            deleteIndicatorHitFrame = .zero
            crossLayer.path = nil
            return 0
        }
        let indicatorWidth = Self.deleteIndicatorWidth(for: state, style: style, traitCollection: traitCollection)
        let leadingIndicator = style.deleteIndicatorPlacement == .leading
        let indicatorX = leadingIndicator ? insets.left : max(insets.left, width - insets.right - indicatorWidth)
        let indicator = CGRect(x: indicatorX, y: insets.top, width: indicatorWidth,
                               height: max(0, height - insets.top - insets.bottom))
        deleteIndicatorLabel.frame = indicator
        if leadingIndicator {
            deleteIndicatorHitFrame = CGRect(x: 0, y: 0, width: min(width, indicator.maxX + style.imageTitleSpacing),
                                             height: height)
        } else {
            let hitX = max(0, indicatorX - style.imageTitleSpacing)
            deleteIndicatorHitFrame = CGRect(x: hitX, y: 0, width: width - hitX, height: height)
        }
        // A drawn cross: a square centered in the area, inset by the padding.
        var side = max(0, min(indicator.width, indicator.height) - 2 * style.deleteIndicatorPadding)
        if style.deleteIndicatorLineWidth > 0 && style.deleteIndicatorWidth <= 0 {
            side = max(0, indicator.width - 2 * style.deleteIndicatorPadding)
        }
        let square = CGRect(x: indicator.midX - side / 2, y: indicator.midY - side / 2, width: side, height: side)
        let cross = UIBezierPath()
        cross.move(to: square.origin)
        cross.addLine(to: CGPoint(x: square.maxX, y: square.maxY))
        cross.move(to: CGPoint(x: square.maxX, y: square.minY))
        cross.addLine(to: CGPoint(x: square.minX, y: square.maxY))
        crossLayer.frame = bounds
        crossLayer.path = cross.cgPath
        return indicatorWidth + style.imageTitleSpacing
    }

    private func reloadAnimationView() {
        animationView?.removeFromSuperview()
        animationView = nil
        animationPlayer = nil
        // A file that does not exist shows the image (some engines would create an empty view).
        if let url = animationURL, !(url.isFileURL && !FileManager.default.fileExists(atPath: url.path)) {
            let size = animationSize
            if let view = CYLTagAnimationEngine.makeView(url: url, size: size) {
                view.isUserInteractionEnabled = false
                addSubview(view)
                animationView = view
                animationViewSize = size
                animationPlayer = CYLTagAnimationEngine.player(for: view)
            }
        }
        updateAnimationState()
        updateAppearance()
    }

    /**
     * Selected: the last frame (a selected tab's icon); otherwise the first frame, or the resting progress.
     */
    private func updateAnimationState() {
        let player = animationPlayer
        CYLTagAnimationEngine.set(styleStorage.animationSpeed > 0 ? styleStorage.animationSpeed : 1,
                                  forKey: "animationSpeed", of: player)
        if isSelected {
            CYLTagAnimationEngine.send("showLastFrame", to: player)
        } else {
            CYLTagAnimationEngine.send("stop", to: player)
            let resting = min(1, max(0, animationRestingProgress))
            if resting > 0 {
                CYLTagAnimationEngine.set(resting, forKey: "progress", of: player)
            }
        }
    }

    private func updateAppearance() {
        let style = styleStorage
        let state = currentState
        let appearance = style.appearance(for: state)
        let icon = state == .selected && selectedImage != nil ? selectedImage : image
        // An animated icon takes the icon slot.
        imageView.image = animationView == nil ? icon : nil
        imageView.isHidden = animationView != nil
        animationView?.alpha = state == .disabled ? Self.disabledAnimationAlpha : 1
        imageView.tintColor = style.iconColor(for: state)
        titleLabel.text = style.displayedTitle(forTitle: title)
        titleLabel.font = style.titleFont(for: state, traitCollection: traitCollection)
        titleLabel.textColor = appearance.textColor

        let pressed = isHighlighted && state != .disabled && style.highlightedBackgroundColor != nil
        // Pressed, as android-tagview's layoutColorPress.
        let background = pressed ? style.highlightedBackgroundColor : appearance.backgroundColor
        layer.backgroundColor = background?.cgColor
        backgroundImageView.image = appearance.backgroundImage
        backgroundImageView.isHidden = appearance.backgroundImage == nil
            || (isHighlighted && style.highlightedBackgroundColor != nil)
        let drawsCross = style.deleteIndicatorLineWidth > 0
        deleteIndicatorLabel.isHidden = !showsDeleteIndicator || drawsCross
        deleteIndicatorLabel.text = showsDeleteIndicator && !drawsCross ? style.deleteIndicatorTitle : nil
        crossLayer.isHidden = !showsDeleteIndicator || !drawsCross
        crossLayer.lineWidth = style.deleteIndicatorLineWidth
        crossLayer.strokeColor = (style.deleteIndicatorColor ?? appearance.textColor)?.cgColor
        let imageRadius = style.imageCornerRadius
        imageView.layer.cornerRadius = imageRadius > 0
            ? min(imageRadius, min(style.imageSize.width, style.imageSize.height) / 2) : 0
        imageView.layer.masksToBounds = imageRadius > 0
        if imageRadius > 0 {
            imageView.contentMode = .scaleAspectFill
        }
        deleteIndicatorLabel.font = style.deleteIndicatorFont(for: state, traitCollection: traitCollection)
        deleteIndicatorLabel.textColor = style.deleteIndicatorColor ?? appearance.textColor
        var borderColor = appearance.borderColor
        var borderWidth = borderColor != nil ? appearance.borderWidth : 0
        if UIAccessibility.isDarkerSystemColorsEnabled {
            // Increase Contrast: a visible outline in the text color.
            borderColor = state == .selected ? (appearance.borderColor ?? appearance.textColor) : appearance.textColor
            borderWidth = max(1, appearance.borderWidth)
        }
        layer.borderColor = borderColor?.cgColor
        layer.borderWidth = borderWidth
        setNeedsLayout()
    }
}
