//
//  CYLTagButton.swift
//  CollectionViewClassifyMenu
//
//  One tag: CYLTabBarController's shared animated icon + title component, CYLAnimatedItemView (pod
//  CYLAnimatedItem, module CYLAnimatedItem, guide:
//  https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md), laid out
//  as a tag: the icon before, after, above or below the title, in a box drawn from the style's appearance for the
//  current state, with an optional delete indicator (the base class's accessory view) and an optional badge.
//  CYLTagListView puts one in every cell; the libraries built on this one (a search bar item) subclass it. The icon,
//  the title and the animated icon are the base class's: it plays any file of CYLTabBarController's animation engine
//  once the app adds an engine subspec (CYLAnimatedItem/LottieSwift, …/PAG, …/Rive, …/SVGA, …/GIF), and shows the static
//  image (or its placeholder) otherwise. The core links no engine.
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

// CocoaPods: the CYLAnimatedItem pod. Swift Package Manager still compiles the component into the CYLTabBarController
// module (CYLTabBarController's docs/Animated-Item.md, TODO 9).
// Re-exported, as CYLTabBarController re-exports it: CYLTagButton and its subclasses (CYLIndexPathButton,
// CYLRightImageButton) are CYLAnimatedItemViews in this module's public API, so a client that imports only
// CollectionViewClassifyMenu must load the base class's module too. Without the re-export an app target that never
// imports CYLAnimatedItem itself failed with explicit modules: "cannot inherit from class
// 'CYLClassifyMenuViewController' because it has overridable members that could not be loaded" (CI on b4d0e51).
#if canImport(CYLAnimatedItem)
@_exported import CYLAnimatedItem
#else
@_exported import CYLTabBarController
#endif
import UIKit

/**
 * One tag: an icon and a title side by side (the icon after, above or below the title with `imagePlacement`), in a box
 * drawn from the style's appearance for the current state, with an optional delete indicator, an optional badge and an
 * optional animated icon. Use it on its own with `init(title:image:)` or `init(title:image:animationURL:)`.
 *
 * It is a `CYLAnimatedItemView`: `title`, `image`, `selectedImage`, `imageView`, `titleLabel`, `animationURL`,
 * `animationSpeed`, `animationLoops`, `animationRestingProgress`, `animationView`, `playAnimation()`,
 * `restartAnimation()`, `stopAnimation()`, the accessory (the delete indicator) and the gesture `delegate` are the base
 * class's. So is the display priority: the animation when it can play; otherwise the static `image` /
 * `selectedImage`; the component's placeholder only when there is no static image (a file that cannot play: no engine
 * or library, an unknown type, a missing, empty or corrupted file, a failed download). A tag with a title and no icon
 * never shows a placeholder. While a remote file downloads, the static image shows.
 */
open class CYLTagButton: CYLAnimatedItemView {

    private static let states: [UIControl.State] = [.normal, .selected, .disabled]
    private static let disabledAnimationAlpha: CGFloat = 0.4
    /**
     * The badge's size: a dot's diameter, the minimum height of a badge with text, its text's side padding.
     */
    private static let badgeDotDiameter: CGFloat = 8
    private static let badgeMinimumHeight: CGFloat = 16
    private static let badgePadding: CGFloat = 4
    private static let badgeFontSize: CGFloat = 11

    /**
     * The label that draws the delete indicator (hidden unless `showsDeleteIndicator`). It is the base class's
     * `accessoryView`: a tap on it calls `CYLAnimatedItemViewDelegate.animatedItemViewDidTapAccessory(_:)`.
     */
    @objc public let deleteIndicatorLabel = UILabel()

    /**
     * The label that draws the badge (hidden while `badgeValue` is `nil`), at the top trailing corner of the icon.
     */
    @objc public let badgeLabel = UILabel()

    /**
     * The badge's text, as `UITabBarItem.badgeValue`: `nil` (the default) hides the badge, an empty string shows a dot,
     * any other text ("3", "99+", "New") a capsule with it. It sits at the top trailing corner of the icon, or of the
     * title when there is no icon, and VoiceOver reads it as the tag's value.
     */
    @objc open var badgeValue: String? {
        didSet {
            if oldValue != badgeValue {
                updateAppearance()
            }
        }
    }

    /**
     * The badge's background color. Setting `nil` restores the default, `UIColor.systemRed`; the text is white.
     */
    @objc open var badgeColor: UIColor? {
        get {
            badgeColorStorage
        }
        set {
            badgeColorStorage = newValue ?? .systemRed
            updateAppearance()
        }
    }

    /**
     * The title (the base class's), shown through the style (`CYLMenuStyle.displayedTitle(forTitle:)`).
     */
    open override var title: String? {
        didSet {
            updateAppearance()
        }
    }

    /**
     * The static icon (the base class's): shown until an animation is ready, whenever none can play, and while a
     * remote file downloads.
     */
    open override var image: UIImage? {
        didSet {
            updateAppearance()
        }
    }

    /**
     * Shown while selected (the base class's); `nil` keeps `image` (as CYLFlatDesignTabBarItem.selectedImage).
     */
    open override var selectedImage: UIImage? {
        didSet {
            updateAppearance()
        }
    }

    /**
     * The frame (0...1) of the animated icon shown while not selected (the base class's). Default 0, the first frame.
     */
    open override var animationRestingProgress: CGFloat {
        didSet {
            if oldValue != animationRestingProgress {
                updateAnimationState()
            }
        }
    }

    /**
     * The playback speed of the animated icon (the base class's), applied at once, also to an animation that is
     * playing. Until it is set, the tag follows `style.animationSpeed`; `resetAnimationSpeed()` goes back to it.
     */
    open override var animationSpeed: CGFloat {
        didSet {
            if !isApplyingStyleAnimationSpeed {
                followsStyleAnimationSpeed = false
            }
        }
    }

    /**
     * Shows the style's delete indicator ("×", `CYLMenuStyle.deleteIndicatorTitle`) after the title, as
     * android-tagview's deletable tags. False by default. `CYLTagListView` turns it on for deletable items and handles
     * taps on it; a tag on its own reports them to `delegate` (`animatedItemViewDidTapAccessory(_:)`).
     */
    @objc open var showsDeleteIndicator = false {
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
    @objc open var style: CYLMenuStyle {
        get {
            styleStorage
        }
        set {
            styleStorage = newValue.cylCopy()
            applyStyleAnimationSpeed()
            let axis: CYLAnimatedItemAxis = styleStorage.imagePlacement.cylIsVertical ? .vertical : .horizontal
            if self.axis != axis {
                self.axis = axis
            }
            if self.iconSize != animationSize {
                // The base class makes the animation view at `iconSize`: a new size reloads it.
                self.iconSize = animationSize
            }
            updateAppearance()
        }
    }

    /**
     * Whether an animation engine is in the app (CYLTabBarController's `CYLTabBarItemAnimationFactory`, brought by an
     * engine subspec such as `CYLAnimatedItem/LottieSwift`). The core links none: without one, tags
     * show their static images.
     */
    @objc public static var isAnimationEngineAvailable: Bool {
        NSClassFromString("CYLTabBarItemAnimationFactory") != nil
    }

    private var styleStorage = CYLMenuStyle()
    private var badgeColorStorage: UIColor = .systemRed
    /**
     * True for a tag made with a convenience initializer: on its own, it is an accessibility element whose traits
     * follow its state (selected, not enabled).
     */
    private var addsStateTraits = false
    private var followsStyleAnimationSpeed = true
    private var isApplyingStyleAnimationSpeed = false
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

    /**
     * A tag for use on its own (a search bar item, a toolbar button): a title, an icon or both, sized to fit
     * (`intrinsicContentSize`), drawn with the default style, an accessibility element with the button trait.
     */
    @objc(initWithTitle:image:)
    public convenience init(title: String?, image: UIImage?) {
        self.init(title: title, image: image, animationURL: nil)
    }

    /**
     * The same with an animated icon (Lottie, PAG, Rive, SVGA, GIF…) in the icon slot; `image` is shown while no
     * engine is in the app, while the file downloads, or when it cannot be played.
     */
    @objc(initWithTitle:image:animationURL:)
    public convenience init(title: String?, image: UIImage?, animationURL: URL?) {
        self.init(frame: .zero)
        self.title = title
        self.image = image
        self.animationURL = animationURL
        isAccessibilityElement = true
        accessibilityTraits = .button
        addsStateTraits = true
        frame.size = intrinsicContentSize
    }

    private func commonInit() {
        // A tag in a list is not an accessibility element (its cell is); the convenience initializers make it one.
        isAccessibilityElement = false
        accessibilityTraits = []
        accessibilityIdentifier = nil
        // The style scales the fonts (`CYLMenuStyle.titleFont(for:traitCollection:)`) and places the title itself.
        titleLabel.adjustsFontForContentSizeCategory = false
        titleLabel.textAlignment = .natural
        titleLabel.lineBreakMode = .byTruncatingTail
        backgroundImageView.isHidden = true
        insertSubview(backgroundImageView, at: 0)
        deleteIndicatorLabel.textAlignment = .center
        deleteIndicatorLabel.isHidden = true
        // The accessory once: the base class adds its tap recognizer each time an accessory is set.
        accessoryView = deleteIndicatorLabel
        badgeLabel.textAlignment = .center
        badgeLabel.textColor = .white
        badgeLabel.isHidden = true
        badgeLabel.isAccessibilityElement = false
        badgeLabel.layer.masksToBounds = true
        addSubview(badgeLabel)
        crossLayer.fillColor = nil
        crossLayer.lineCap = .round
        layer.addSublayer(crossLayer)
        layer.masksToBounds = true
        self.iconSize = animationSize
        applyStyleAnimationSpeed()
        updateAppearance()
    }

    // MARK: - Inherited members for Objective-C

    // [EN] Redeclared so that they are in this module's generated Objective-C header: an Objective-C file that imports only
    //      CollectionViewClassifyMenu does not see CYLAnimatedItemView's own declarations (Clang shows a module's
    //      declarations only to a file that imports that module), and must not need to import CYLTabBarController.
    //      Each one only forwards to CYLAnimatedItemView.
    // [CN] 重新声明，使其出现在本模块生成的 Objective-C 头文件中：只导入 CollectionViewClassifyMenu 的 Objective-C 文件看不到
    //      CYLAnimatedItemView 自己的声明（Clang 只向导入了该模块的文件展示其声明），而它不应需要导入 CYLTabBarController。每个成员只转发给
    //      CYLAnimatedItemView。

    /**
     * The animation file the icon plays (any file of CYLTabBarController's animation engine), or nil.
     */
    open override var animationURL: URL? {
        get { super.animationURL }
        set { super.animationURL = newValue }
    }

    /**
     * Whether the animation repeats.
     */
    open override var animationLoops: Bool {
        get { super.animationLoops }
        set { super.animationLoops = newValue }
    }

    /**
     * The view playing `animationURL`, while ready; always nil without an animation engine.
     */
    open override var animationView: UIView? { super.animationView }

    /**
     * The icon's image view (the static image, else the placeholder, until the animation shows).
     */
    open override var imageView: UIImageView { super.imageView }

    /**
     * The title label.
     */
    open override var titleLabel: UILabel { super.titleLabel }

    /**
     * The accessory beside the content (the delete indicator).
     */
    open override var accessoryView: UIView? {
        get { super.accessoryView }
        set { super.accessoryView = newValue }
    }

    /**
     * Shown when there is no static image and `animationURL` cannot play; nil restores the default placeholder.
     */
    open override var placeholderImage: UIImage! {
        get { super.placeholderImage }
        set { super.placeholderImage = newValue }
    }

    /**
     * Plays the animation again from its first frame.
     */
    open override func restartAnimation() {
        super.restartAnimation()
    }

    /**
     * Stops the animation and goes back to its resting frame.
     */
    open override func stopAnimation() {
        super.stopAnimation()
    }

    // MARK: - Animation

    /**
     * Plays the animated icon, as a tab icon plays when the tab is tapped; with Reduce Motion it shows the state's
     * frame instead. Without an engine (or a file that cannot play) it does nothing.
     */
    open override func playAnimation() {
        if UIAccessibility.isReduceMotionEnabled {
            updateAnimationState()
            return
        }
        super.playAnimation()
    }

    /**
     * Builds the animation view again (a new file or size) and shows the state's frame.
     */
    open override func reloadAnimation() {
        super.reloadAnimation()
        updateAnimationState()
        updateAppearance()
    }

    /**
     * Goes back to `style.animationSpeed` after `animationSpeed` was set.
     */
    @objc open func resetAnimationSpeed() {
        followsStyleAnimationSpeed = true
        applyStyleAnimationSpeed()
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
            if style.imagePlacement.cylIsVertical {
                // Stacked: the wider of the two.
                content = max(titleWidth, iconSize.width)
            } else if titleWidth > 0 && iconSize.width > 0 {
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
     * Size of the icon slot for an image, or for an animated icon when `animated` and an engine is in the app; an
     * animated icon without an engine and without an image takes the size of the component's placeholder
     * (`CYLAnimatedItemView.defaultPlaceholderImage`), which the tag then shows.
     */
    public static func iconSize(for image: UIImage?, animated: Bool, style: CYLMenuStyle) -> CGSize {
        if animated && isAnimationEngineAvailable {
            return style.animationSize == .zero ? style.imageSize : style.animationSize
        }
        if animated && image == nil {
            return iconSize(for: CYLAnimatedItemView.defaultPlaceholderImage, style: style)
        }
        return iconSize(for: image, style: style)
    }

    /**
     * Tag height: `style.itemHeight`, or more when a line of the title font plus the appearance's top and bottom
     * content insets needs it; with the icon above or below the title, also the icon slot and the spacing.
     */
    public static func height(for style: CYLMenuStyle, traitCollection: UITraitCollection?) -> CGFloat {
        let iconHeight = style.imagePlacement.cylIsVertical ? max(style.imageSize.height, style.animationSize.height) : 0
        return states.reduce(style.itemHeight) { height, state in
            let insets = style.appearance(for: state).contentInsets
            let font = style.titleFont(for: state, traitCollection: traitCollection)
            let stacked = iconHeight > 0 ? iconHeight + style.imageTitleSpacing : 0
            return max(height, ceil(font.lineHeight) + stacked + insets.top + insets.bottom)
        }
    }

    /**
     * The height a tag needs for this title and an icon of `iconSize` (`.zero` for none) in every state: the tallest
     * of the two side by side, or both and the spacing when the icon is above or below the title; at least
     * `style.itemHeight`.
     */
    @objc(heightForTitle:iconSize:style:traitCollection:)
    public static func height(forTitle title: String?, iconSize: CGSize, style: CYLMenuStyle,
                              traitCollection: UITraitCollection?) -> CGFloat {
        let hasTitle = !style.displayedTitle(forTitle: title).isEmpty
        return states.reduce(style.itemHeight) { height, state in
            let insets = style.appearance(for: state).contentInsets
            let line = hasTitle ? ceil(style.titleFont(for: state, traitCollection: traitCollection).lineHeight) : 0
            var content = max(line, iconSize.height)
            if style.imagePlacement.cylIsVertical {
                content = line + iconSize.height + (hasTitle && iconSize.height > 0 ? style.imageTitleSpacing : 0)
            }
            return max(height, ceil(content + insets.top + insets.bottom))
        }
    }

    // MARK: - Overrides

    /**
     * The size the tag needs for its title, icon (or animated icon), delete indicator and style, in every state.
     */
    open override var intrinsicContentSize: CGSize {
        let icon = animationView != nil
            ? animationSize : Self.iconSize(for: image ?? selectedImage ?? imageView.image, style: styleStorage)
        return CGSize(width: Self.width(forTitle: title, iconSize: icon, showsDeleteIndicator: showsDeleteIndicator,
                                        style: styleStorage, traitCollection: traitCollection),
                      height: Self.height(forTitle: title, iconSize: icon, style: styleStorage,
                                          traitCollection: traitCollection))
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        intrinsicContentSize
    }

    /**
     * The content's size without the current appearance's content insets (the base class's measuring hook).
     */
    open override func contentSizeThatFits(_ size: CGSize) -> CGSize {
        let insets = styleStorage.appearance(for: currentState).contentInsets
        let size = intrinsicContentSize
        return CGSize(width: max(0, size.width - insets.left - insets.right),
                      height: max(0, size.height - insets.top - insets.bottom))
    }

    /**
     * The title (or the icon's `accessibilityLabel`) unless a label was set.
     */
    open override var accessibilityLabel: String? {
        get {
            super.accessibilityLabel ?? itemAccessibilityLabel()
        }
        set {
            super.accessibilityLabel = newValue
        }
    }

    /**
     * The title as shown, or the icon's `accessibilityLabel` for an icon-only tag.
     */
    open override func itemAccessibilityLabel() -> String? {
        let displayed = styleStorage.displayedTitle(forTitle: title)
        return displayed.isEmpty ? image?.accessibilityLabel : displayed
    }

    /**
     * The label, value and traits are computed when VoiceOver reads them (`accessibilityLabel`, `accessibilityValue`,
     * `accessibilityTraits`), so a label or traits set by the app are kept.
     */
    open override func updateItemAccessibility() {
        // Nothing to store: see the getters.
    }

    /**
     * The badge unless a value was set: its text, or "New" (localized) for a dot.
     */
    open override var accessibilityValue: String? {
        get {
            if let value = super.accessibilityValue {
                return value
            }
            guard let badgeValue else {
                return nil
            }
            return badgeValue.isEmpty ? CYLMenuLocalizedString("CYLTagBadgeDot") : badgeValue
        }
        set {
            super.accessibilityValue = newValue
        }
    }

    /**
     * For a tag made with a convenience initializer, the traits it was given plus selected and not enabled from its
     * state.
     */
    open override var accessibilityTraits: UIAccessibilityTraits {
        get {
            var traits = super.accessibilityTraits
            if addsStateTraits {
                if isSelected {
                    traits.insert(.selected)
                }
                if !isEnabled {
                    traits.insert(.notEnabled)
                }
            }
            return traits
        }
        set {
            super.accessibilityTraits = newValue
        }
    }

    open override var isSelected: Bool {
        didSet {
            if oldValue != isSelected {
                updateAnimationState()
            }
            updateAppearance()
        }
    }

    /**
     * The look of the state (selected, highlighted, enabled), from the style's appearance.
     */
    open override func itemStateDidChange() {
        super.itemStateDidChange()
        updateAppearance()
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateAppearance()
    }

    /**
     * CYLFlatDesignTabBarButton's `_updateLayout`, with the icon and title side by side (the base class's layout hook;
     * the insets come from the style's appearance for the current state). The image view and the animation view share
     * the icon frame: the base class shows the static image (or its placeholder) until the animation shows.
     */
    open override func layoutContent(in rect: CGRect) {
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
        var imageY = Self.centeredY(iconSize.height, contentTop: contentTop, contentHeight: contentHeight, height: height)
        var titleY = Self.centeredY(titleHeight, contentTop: contentTop, contentHeight: contentHeight, height: height)
        let leading = style.contentAlignment == .leading
        if style.imagePlacement.cylIsVertical {
            // Stacked: each centered (or at the leading margin), the group centered between the insets.
            titleWidth = min(ceil(titleSize.width), max(0, width - 2 * margin))
            imageX = leading ? margin : floor((width - iconSize.width) / 2)
            titleX = leading ? margin : floor((width - titleWidth) / 2)
            let group = (showsImage ? iconSize.height : 0) + spacing + (showsTitle ? titleHeight : 0)
            let top = Self.centeredY(group, contentTop: contentTop, contentHeight: contentHeight, height: height)
            if style.imagePlacement == .bottom {
                titleY = top
                imageY = top + (showsTitle ? titleHeight + spacing : 0)
            } else {
                imageY = top
                titleY = top + (showsImage ? iconSize.height + spacing : 0)
            }
        } else if showsImage && showsTitle {
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
                                      y: titleY + style.titlePositionAdjustment.vertical,
                                      width: titleWidth, height: titleHeight)
        } else {
            titleLabel.frame = .zero
        }
        if showsImage {
            var frame = CGRect(x: imageX + style.imagePositionAdjustment.horizontal,
                               y: imageY + style.imagePositionAdjustment.vertical,
                               width: iconSize.width, height: iconSize.height)
            // Only the size changes; x and y stay, as CYLFlatDesignTabBarItem.imageInsets.
            let imageInsets = style.imageInsets
            frame.size.width = max(0, frame.width - imageInsets.left - imageInsets.right)
            frame.size.height = max(0, frame.height - imageInsets.top - imageInsets.bottom)
            // The animation view and, under it, the static image (shown until the animation shows).
            animationView?.frame = frame
            placeImageView(frame)
            layOutBadge(anchor: frame)
        } else {
            placeImageView(.zero)
            layOutBadge(anchor: showsTitle ? titleLabel.frame : bounds.inset(by: insets))
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

    /**
     * The badge at the top trailing corner of `anchor` (the icon, or the title): the center of its leading cap on the
     * corner, kept inside the tag (which clips its content).
     */
    private func layOutBadge(anchor: CGRect) {
        guard let badgeValue else {
            badgeLabel.frame = .zero
            return
        }
        let isDot = badgeValue.isEmpty
        let lineHeight = ceil(badgeLabel.font.lineHeight)
        let badgeHeight = isDot ? Self.badgeDotDiameter : max(Self.badgeMinimumHeight, lineHeight + 2)
        let textWidth = isDot ? 0 : ceil((badgeValue as NSString).size(withAttributes: [.font: badgeLabel.font as Any]).width)
        let badgeWidth = isDot ? badgeHeight : max(badgeHeight, textWidth + 2 * Self.badgePadding)
        let x = max(0, min(anchor.maxX - badgeHeight / 2, bounds.width - badgeWidth))
        let y = max(0, min(anchor.minY - badgeHeight / 2, bounds.height - badgeHeight))
        badgeLabel.frame = CGRect(x: x, y: y, width: badgeWidth, height: badgeHeight)
        badgeLabel.layer.cornerRadius = badgeHeight / 2
        bringSubviewToFront(badgeLabel)
    }


    private func applyStyleAnimationSpeed() {
        guard followsStyleAnimationSpeed else {
            return
        }
        let speed = styleStorage.animationSpeed
        isApplyingStyleAnimationSpeed = true
        animationSpeed = speed > 0 ? speed : 1
        isApplyingStyleAnimationSpeed = false
    }

    /**
     * Selected: the last frame (a selected tab's icon); otherwise the resting progress (the first frame by default).
     */
    private func updateAnimationState() {
        guard animationView != nil else {
            return
        }
        if isSelected {
            showAnimationLastFrame()
        } else {
            stopAnimation()
        }
    }

    private func updateAppearance() {
        let style = styleStorage
        let state = currentState
        let appearance = style.appearance(for: state)
        // The base class chooses the icon (the image, the selected image or its placeholder) and hides it while the
        // animation shows; only a disabled selected tag shows `image`, as before (disabled wins over selected).
        if let shown = imageView.image, shown === image || shown === selectedImage {
            let icon = state == .selected && selectedImage != nil ? selectedImage : image
            if icon !== shown {
                imageView.image = icon
            }
        }
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
        // Kept visible (and empty) under a drawn cross, so that a tap on it still reaches the accessory.
        deleteIndicatorLabel.isHidden = !showsDeleteIndicator
        deleteIndicatorLabel.text = showsDeleteIndicator && !drawsCross ? style.deleteIndicatorTitle : nil
        deleteIndicatorLabel.accessibilityLabel = showsDeleteIndicator ? CYLMenuLocalizedString("CYLMenuDeleteTag") : nil
        let placement: CYLAnimatedItemAccessoryPlacement = style.deleteIndicatorPlacement == .leading ? .leading : .trailing
        if accessoryPlacement != placement {
            accessoryPlacement = placement
        }
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
        badgeLabel.isHidden = badgeValue == nil
        badgeLabel.text = badgeValue?.isEmpty == false ? badgeValue : nil
        badgeLabel.backgroundColor = badgeColorStorage
        let badgeFont = UIFont.boldSystemFont(ofSize: Self.badgeFontSize)
        badgeLabel.font = style.adjustsFontForContentSizeCategory
            ? UIFontMetrics(forTextStyle: .caption2).scaledFont(for: badgeFont, maximumPointSize: 2 * Self.badgeFontSize,
                                                                compatibleWith: traitCollection)
            : badgeFont
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }
}

extension CYLTagImagePlacement {

    /**
     * True for `.top` and `.bottom`: the icon and the title are stacked.
     */
    var cylIsVertical: Bool {
        self == .top || self == .bottom
    }
}
