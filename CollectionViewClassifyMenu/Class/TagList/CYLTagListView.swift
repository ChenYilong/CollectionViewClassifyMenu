//
//  CYLTagListView.swift
//  CollectionViewClassifyMenu
//
//  A configurable, embeddable tag menu. The host owns the data (through CYLMenuDataSource) and reacts to taps
//  (through CYLMenuDelegate); the view owns only layout, folding and selection state.
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * How taps select items.
 */
@objc public enum CYLMenuSelectionMode: Int {
    /**
     * Items behave like buttons: taps are reported, nothing stays selected.
     */
    case none = 0
    /**
     * At most one selected item per section.
     */
    case single
    /**
     * Any number of selected items; exclusive items clear the others.
     */
    case multiple
}

/**
 * Where the list's title (`title`) is: above every section, at the leading edge or centered.
 */
@objc public enum CYLMenuTitlePosition: Int {
    /**
     * At the leading edge.
     */
    case topLeading = 0
    /**
     * Centered.
     */
    case topCenter
}

/**
 * The older way of choosing a fold control; `foldControl` gives the position and content separately.
 */
@objc public enum CYLMenuFoldStyle: Int {
    /**
     * Every row is always visible.
     */
    case none = 0
    /**
     * A "更多/收起" button at the trailing edge of the section header.
     */
    case headerButton
    /**
     * A chevron below the section, as in shopping review filters.
     */
    case footerChevron
    /**
     * Shows only `defaultVisibleRows` rows with no control, for previews; the host may still call
     * `setExpanded(_:forSection:animated:)`.
     */
    case truncate
}

// MARK: - Header

/**
 * A section header: an indicator bar, the icon and the title (one `CYLTagButton`, `titleButton`), an accessory view,
 * the fold control and the More button. The tests read `iconView`, `titleLabel` (the title button's own views) and
 * `foldButton` by key-value coding (`CYLTagListProbe`).
 */
private final class CYLTagListHeaderView: UICollectionReusableView {

    /**
     * The More button's touch target.
     */
    static let moreButtonSize: CGFloat = 44
    static let iconSize: CGFloat = 16

    /**
     * The section's icon and title: the same component as the tags, so a section icon can be anything a tag icon can.
     */
    @objc let titleButton = CYLTagButton(frame: .zero)
    @objc var iconView: UIImageView {
        titleButton.imageView
    }
    @objc var titleLabel: UILabel {
        titleButton.titleLabel
    }
    @objc let foldButton = CYLTagFoldButton(frame: .zero)
    /**
     * The More button (three dots) at the trailing edge, hidden unless the data source asks for it.
     */
    let moreButton = UIButton(type: .system)
    /**
     * CYLMenuStyle.headerIndicatorColor and size: a bar before the title.
     */
    let indicatorView = UIView()
    /**
     * The section's clear button (the bundle's trash icon, `CYLMenuDataSource.menuShowsClearButton(forSection:)`): its top
     * and bottom are the title's.
     */
    let clearButton = CYLTagListClearButton(type: .system)
    var clearHandler: ((Int) -> Void)?
    var moreHandler: ((Int) -> Void)?
    var foldHandler: ((Int) -> Void)?
    /**
     * The fold control's size, and whether it is at the leading edge (before the title).
     */
    var foldSize: CGSize = .zero
    var foldAtLeadingEdge = false
    /**
     * The distances from the header's leading and trailing edges to the title and the controls.
     */
    var leadingInset: CGFloat = 0
    var trailingInset: CGFloat = 0
    /**
     * The header band (`CYLMenuStyle.headerBackgroundColor`) and the divider, as distances from the header's own edges
     * (left, right); `nil`: not shown.
     */
    var bandEdges: (left: CGFloat, right: CGFloat)? {
        didSet {
            setNeedsLayout()
        }
    }
    var separatorEdges: (left: CGFloat, right: CGFloat)? {
        didSet {
            setNeedsLayout()
        }
    }
    var separatorThickness: CGFloat = 0
    @objc let bandView = UIView()
    @objc let separatorView = UIView()
    var indicatorSize: CGSize = .zero
    var section = 0
    var accessoryView: UIView? {
        didSet {
            guard oldValue !== accessoryView else {
                return
            }
            if oldValue?.superview === self {
                oldValue?.removeFromSuperview()
            }
            if let accessoryView {
                addSubview(accessoryView)
            }
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        titleButton.isUserInteractionEnabled = false
        titleButton.mirrorsContentInRightToLeft = true
        foldButton.mirrorsContentInRightToLeft = true
        titleButton.titleLabel.accessibilityTraits = .header
        foldButton.addTarget(self, action: #selector(foldTapped), for: .touchUpInside)
        moreButton.isHidden = true
        moreButton.accessibilityIdentifier = CYLTagListAccessibilityIdentifier.moreButton
        moreButton.accessibilityLabel = CYLMenuLocalizedString("CYLMenuMoreActions")
        moreButton.largeContentTitle = moreButton.accessibilityLabel
        moreButton.showsLargeContentViewer = true
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        clearButton.isHidden = true
        clearButton.accessibilityIdentifier = CYLTagListAccessibilityIdentifier.clearButton
        clearButton.imageView?.contentMode = .scaleAspectFit
        clearButton.contentHorizontalAlignment = .fill
        clearButton.contentVerticalAlignment = .fill
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        for decoration in [bandView, separatorView] {
            decoration.isHidden = true
            decoration.isAccessibilityElement = false
            decoration.isUserInteractionEnabled = false
            addSubview(decoration)
        }
        bandView.layer.cornerCurve = .continuous
        addSubview(clearButton)
        indicatorView.isHidden = true
        addSubview(indicatorView)
        addSubview(titleButton)
        addSubview(foldButton)
        addSubview(moreButton)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryView = nil
        foldHandler = nil
        moreHandler = nil
        clearHandler = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = bounds.width
        let height = bounds.height
        layOutLeadingToTrailing(width: width, height: height)
        guard effectiveUserInterfaceLayoutDirection == .rightToLeft else {
            return
        }
        // Everything above was placed from the left edge (the band's and the divider's `left` is the leading side): in a right-to-left
        // layout each view takes the mirrored position.
        for view in [bandView, separatorView, indicatorView, titleButton, foldButton, moreButton, clearButton, accessoryView]
            .compactMap({ $0 }) where !view.isHidden {
            view.frame.origin.x = width - view.frame.maxX
        }
    }

    private func layOutLeadingToTrailing(width: CGFloat, height: CGFloat) {
        layoutDecorations(width: width, height: height)
        var trailing = width - trailingInset
        var leading = leadingInset
        if !moreButton.isHidden {
            // A 44 pt touch target whose icon lines up with the trailing inset.
            let size = min(Self.moreButtonSize, height > 0 ? max(height, 30) : Self.moreButtonSize)
            let iconWidth = moreButton.currentImage?.size.width ?? 22
            trailing += floor((size - iconWidth) / 2)
            trailing -= size
            moreButton.frame = CGRect(x: trailing, y: floor((height - size) / 2), width: size, height: size)
            trailing -= 4
        }
        if !clearButton.isHidden {
            // A square as tall as a line of the title, at the trailing inset; aligned with the title text below.
            let side = min(height, ceil(titleButton.titleLabel.font?.lineHeight ?? 17))
            trailing -= side
            clearButton.frame = CGRect(x: trailing, y: floor((height - side) / 2), width: side, height: side)
            trailing -= 8
        }
        if !foldButton.isHidden {
            let size = CGSize(width: min(foldSize.width, width / 2), height: min(foldSize.height, height))
            let y = floor((height - size.height) / 2)
            // The control's own margin lines its content up with the title.
            if foldAtLeadingEdge {
                foldButton.frame = CGRect(x: leading - 6, y: y, width: size.width, height: size.height)
                leading += size.width - 6 + 4
            } else {
                trailing -= size.width - 6
                foldButton.frame = CGRect(x: trailing, y: y, width: size.width, height: size.height)
                trailing -= 8
            }
        }
        if let accessoryView {
            var size = accessoryView.sizeThatFits(CGSize(width: width / 2, height: height))
            size.width = min(size.width, width / 2)
            size.height = min(max(size.height, 1), height)
            trailing -= size.width
            accessoryView.frame = CGRect(x: trailing, y: floor((height - size.height) / 2), width: size.width,
                                         height: size.height)
            trailing -= 8
        }
        var x = leading
        if !indicatorView.isHidden {
            indicatorView.frame = CGRect(x: x, y: floor((height - indicatorSize.height) / 2),
                                         width: indicatorSize.width, height: indicatorSize.height)
            x += indicatorSize.width + 8
        }
        titleButton.frame = CGRect(x: x, y: 0, width: max(0, trailing - x), height: height)
        if !clearButton.isHidden {
            // The rule: the clear button's top and bottom are the title text's (the element to its left).
            titleButton.layoutIfNeeded()
            let text = titleButton.convert(titleButton.titleLabel.frame, to: self)
            if text.height > 0 {
                clearButton.frame = CGRect(x: clearButton.frame.maxX - text.height, y: text.minY, width: text.height,
                                           height: text.height)
            }
        }
    }

    /**
     * The band behind the title and the divider at the bottom edge, inside the header's height.
     */
    private func layoutDecorations(width: CGFloat, height: CGFloat) {
        bandView.isHidden = bandEdges == nil
        if let edges = bandEdges {
            bandView.frame = CGRect(x: edges.left, y: 0, width: max(0, width - edges.left - edges.right), height: height)
        }
        separatorView.isHidden = separatorEdges == nil
        if let edges = separatorEdges {
            let thickness = min(separatorThickness, height)
            separatorView.frame = CGRect(x: edges.left, y: height - thickness, width: max(0, width - edges.left - edges.right),
                                         height: thickness)
        }
        // Behind the title and the controls, the divider on the band.
        sendSubviewToBack(separatorView)
        sendSubviewToBack(bandView)
    }

    @objc private func clearTapped() {
        clearHandler?(section)
    }

    @objc private func moreTapped() {
        moreHandler?(section)
    }

    @objc private func foldTapped() {
        foldHandler?(section)
    }
}

// MARK: - Footer

/**
 * The fold control below a section (`CYLMenuFoldControlPosition.footer`), centered.
 */
private final class CYLTagListFooterView: UICollectionReusableView {

    @objc let foldButton = CYLTagFoldButton(frame: .zero)
    var foldSize: CGSize = .zero
    var section = 0
    var foldHandler: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        foldButton.addTarget(self, action: #selector(foldTapped), for: .touchUpInside)
        addSubview(foldButton)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        foldButton.addTarget(self, action: #selector(foldTapped), for: .touchUpInside)
        addSubview(foldButton)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        foldHandler = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = CGSize(width: min(foldSize.width, bounds.width), height: min(foldSize.height, bounds.height))
        foldButton.frame = CGRect(x: floor((bounds.width - size.width) / 2), y: floor((bounds.height - size.height) / 2),
                                  width: size.width, height: size.height)
    }

    @objc private func foldTapped() {
        foldHandler?(section)
    }
}

// MARK: - Tag list view

/**
 * A configurable, embeddable tag menu: sections of tags from `menuDataSource`, taps reported to `menuDelegate`,
 * folding, selection, a title, reordering and the android-tagview tag methods (`addTag(_:)`…).
 */
open class CYLTagListView: UIView {

    private enum ReuseIdentifier {
        static let cell = "CYLTagListCell"
        static let createCell = "CYLTagCreateCell"
        static let foldCell = "CYLTagFoldCell"
        static let header = "CYLTagListHeader"
        static let footer = "CYLTagListFooter"
    }

    private static let footerHeight: CGFloat = 28
    /**
     * Space above and below the list's title.
     */
    private static let titleVerticalInset: CGFloat = 10
    private static let longPressDuration: TimeInterval = 0.5
    /**
     * How far a press moves before it counts as a drag rather than a long press.
     */
    private static let dragThreshold: CGFloat = 8

    // MARK: Data source and delegate

    /**
     * The sections and items.
     */
    @objc open weak var menuDataSource: CYLMenuDataSource?

    /**
     * Receives taps, selection changes, folding and size changes.
     */
    @objc open weak var menuDelegate: CYLMenuDelegate?

    // MARK: Appearance

    /**
     * Appearance. Setting copies the style; set it again after changing it.
     */
    @objc open var style: CYLMenuStyle {
        get {
            styleStorage
        }
        set {
            styleStorage = newValue.cylCopy()
            tagDataSourceStorage?.baseStyle = styleStorage
            applyStyleColors()
            invalidateMeasurements()
        }
    }

    /**
     * How taps select items; `.single` by default.
     */
    @objc open var selectionMode: CYLMenuSelectionMode = .single {
        didSet {
            switch selectionMode {
            case .none:
                selection.removeAll()
            case .single:
                var seen = IndexSet()
                for indexPath in selectedIndexPaths {
                    if seen.contains(indexPath.section) {
                        selection.remove(indexPath)
                    }
                    seen.insert(indexPath.section)
                }
            case .multiple:
                break
            }
            refreshVisibleCells()
        }
    }

    /**
     * When false, a tap never removes the last selected item of a section. True by default.
     */
    @objc open var allowsEmptySelection = true

    /**
     * True by default. When false, sections are laid out back to back without titles.
     */
    @objc open var showsSectionHeaders = true {
        didSet {
            reloadLayout()
        }
    }

    /**
     * The fold control of a foldable section (more rows than `defaultVisibleRows`): where it is and what it shows.
     * Default: none. Setting copies it and also sets `foldStyle` (footer: `.footerChevron`, header: `.headerButton`,
     * none: `.none`, or `.truncate` when `foldStyle` was `.truncate`).
     */
    @objc open var foldControl: CYLMenuFoldControl {
        get {
            foldControlStorage
        }
        set {
            foldControlStorage = newValue.cylCopy()
            switch foldControlStorage.position {
            case .footer:
                foldStyleStorage = .footerChevron
            case .headerTrailing, .headerLeading:
                foldStyleStorage = .headerButton
            case .none:
                if foldStyleStorage != .truncate {
                    foldStyleStorage = .none
                }
            case .tail:
                // No legacy fold style matches a fold control among the tags.
                foldStyleStorage = .none
            }
            reloadLayout()
        }
    }

    /**
     * `.none` by default. Setting it also sets `foldControl`: `.headerButton` is a top trailing title ("更多"),
     * `.footerChevron` a bottom icon; `.none` and `.truncate` have none.
     */
    @objc open var foldStyle: CYLMenuFoldStyle {
        get {
            foldStyleStorage
        }
        set {
            foldStyleStorage = newValue
            switch newValue {
            case .headerButton:
                foldControlStorage = CYLMenuFoldControl(position: .headerTrailing, content: .title)
            case .footerChevron:
                foldControlStorage = CYLMenuFoldControl(position: .footer, content: .icon)
            case .none, .truncate:
                foldControlStorage = CYLMenuFoldControl()
            }
            reloadLayout()
        }
    }

    /**
     * Rows shown while a foldable section is collapsed. 0 shows every row. 1 by default.
     */
    @objc open var defaultVisibleRows = 1 {
        didSet {
            defaultVisibleRows = max(0, defaultVisibleRows)
            reloadLayout()
        }
    }

    // MARK: Title

    /**
     * A title above every section (`nil`, the default, for none), e.g. "评价". It is drawn by `titleView`, the same
     * tag view as the tags (`CYLTagButton`), laid out horizontally: an icon (`titleImage`), a title, or both. Neither:
     * no title area.
     */
    @objc open var title: String? {
        didSet {
            titleView.title = title
            titleDidChange()
        }
    }

    /**
     * The title's icon, before the title (or after it with `titleStyle.imagePlacement`); `nil` for none.
     */
    @objc open var titleImage: UIImage? {
        didSet {
            titleView.image = titleImage
            titleDidChange()
        }
    }

    /**
     * Where the title is.
     */
    @objc open var titlePosition: CYLMenuTitlePosition = .topLeading {
        didSet {
            setNeedsLayout()
        }
    }

    /**
     * The title's look (font, colors, icon size and color, spacing…). Default `defaultTitleStyle`: the bold headline
     * font in the label color, no box. Setting copies the style.
     */
    @objc open var titleStyle: CYLMenuStyle {
        get {
            titleStyleStorage
        }
        set {
            titleStyleStorage = newValue.cylCopy()
            titleView.style = titleStyleStorage
            titleDidChange()
        }
    }

    /**
     * The view that draws the title: every public API of `CYLTagButton` is available (e.g. an animated icon with
     * `animationURL`). Set the title, icon and style through the properties above.
     */
    @objc public let titleView = CYLTagButton(frame: .zero)

    /**
     * The title's label (`titleView.titleLabel`).
     */
    @objc open var titleLabel: UILabel {
        titleView.titleLabel
    }

    /**
     * The default title look: the headline font (bold, scaled with Dynamic Type) in the label color, an 18 pt icon in
     * the label color, no background or border.
     */
    @objc open class var defaultTitleStyle: CYLMenuStyle {
        let style = CYLMenuStyle()
        let font = UIFont.preferredFont(forTextStyle: .headline)
        for state in [UIControl.State.normal, .selected, .disabled] {
            let appearance = style.appearance(for: state)
            appearance.backgroundColor = .clear
            appearance.borderWidth = 0
            appearance.borderColor = nil
            appearance.margin = 0
            appearance.font = font
            appearance.textColor = .label
            style.setIconColor(.label, for: state)
        }
        style.imageSize = CGSize(width: 18, height: 18)
        style.imageTitleSpacing = 6
        style.layoutCentered = true
        style.adjustsFontForContentSizeCategory = true
        style.itemHeight = 24
        return style
    }

    // MARK: Size

    /**
     * Turn off to embed the view in another scroll view and size it with `contentHeight` or Auto Layout's intrinsic
     * content size. True by default.
     */
    @objc open var isScrollEnabled: Bool {
        get {
            collectionView.isScrollEnabled
        }
        set {
            collectionView.isScrollEnabled = newValue
            // An embedded, non-scrolling menu is laid out by its host: safe-area insets (for example under a
            // navigation bar in a table header) must not shift it.
            collectionView.contentInsetAdjustmentBehavior = newValue ? .automatic : .never
            if !newValue {
                resetContentOffset()
            }
        }
    }

    /**
     * Height needed to show the current content at the current width. Also reported as the intrinsic content height
     * and through `menu(_:didChangeContentHeight:)`.
     */
    @objc open private(set) var contentHeight: CGFloat = 0

    // MARK: Spacing (android-tagview's lineMargin, tagMargin and textPadding…)

    /**
     * The space between rows (`style.lineSpacing`, lineMargin). Like the other spacing shortcuts, it copies the
     * style, changes it and sets it again, and can be set in Interface Builder.
     */
    @IBInspectable open var lineSpacing: CGFloat {
        get {
            style.lineSpacing
        }
        set {
            updateStyle { $0.lineSpacing = newValue }
        }
    }

    /**
     * The space between tags in a row (`style.interitemSpacing`, tagMargin).
     */
    @IBInspectable open var interitemSpacing: CGFloat {
        get {
            style.interitemSpacing
        }
        set {
            updateStyle { $0.interitemSpacing = newValue }
        }
    }

    /**
     * The space inside every tag (`style.tagContentInsets`, textPaddingTop / Left / Bottom / Right).
     */
    @objc open var tagContentInsets: UIEdgeInsets {
        get {
            style.tagContentInsets
        }
        set {
            updateStyle { $0.tagContentInsets = newValue }
        }
    }

    /**
     * `tagContentInsets.top`, for Interface Builder.
     */
    @IBInspectable open var tagContentInsetTop: CGFloat {
        get {
            tagContentInsets.top
        }
        set {
            tagContentInsets.top = newValue
        }
    }

    /**
     * `tagContentInsets.left`, for Interface Builder.
     */
    @IBInspectable open var tagContentInsetLeft: CGFloat {
        get {
            tagContentInsets.left
        }
        set {
            tagContentInsets.left = newValue
        }
    }

    /**
     * `tagContentInsets.bottom`, for Interface Builder.
     */
    @IBInspectable open var tagContentInsetBottom: CGFloat {
        get {
            tagContentInsets.bottom
        }
        set {
            tagContentInsets.bottom = newValue
        }
    }

    /**
     * `tagContentInsets.right`, for Interface Builder.
     */
    @IBInspectable open var tagContentInsetRight: CGFloat {
        get {
            tagContentInsets.right
        }
        set {
            tagContentInsets.right = newValue
        }
    }

    // MARK: Animated icons

    /**
     * The playback speed of every animated icon, applied at once, also to animations that are playing, without
     * reloading the list. `nil` (the default) uses each tag's `style.animationSpeed`.
     */
    open var animationSpeed: CGFloat? {
        didSet {
            forEachVisibleTagButton { $0.cylApplyListAnimationSpeed(animationSpeed) }
        }
    }

    /**
     * `animationSpeed` for Objective-C, which cannot see an optional `CGFloat`: the speed as an `NSNumber`, or `nil`
     * for each tag's `style.animationSpeed`. Objective-C calls it `animationSpeed`; Swift uses `animationSpeed`.
     */
    @available(swift, obsoleted: 1, renamed: "animationSpeed")
    @objc(animationSpeed)
    open var animationSpeedNumber: NSNumber? {
        get {
            animationSpeed.map { NSNumber(value: Double($0)) }
        }
        set {
            animationSpeed = newValue.map { CGFloat($0.doubleValue) }
        }
    }

    /**
     * True repeats the animated icons after they start playing (a tap, `playAllAnimations()`) until it is set to
     * false; false (the default) plays them once (`CYLTagButton.animationLoops`).
     */
    @objc open var animationLoops = false {
        didSet {
            forEachVisibleTagButton { $0.animationLoops = animationLoops }
        }
    }

    /**
     * Plays the animated icon of every tag on screen from its start (progress 0), whatever its selection.
     */
    @objc open func playAllAnimations() {
        collectionView.layoutIfNeeded()
        forEachVisibleTagButton { $0.playAnimation() }
    }

    // MARK: Tags (android-tagview's TagView)

    /**
     * Called for every accepted tap on one of `tags` (android-tagview's OnTagClickListener), after the menu delegate.
     */
    open var tagClickHandler: ((Int, CYLTag) -> Void)?

    /**
     * Objective-C's `tagClickHandler`: called for the same taps as `tagClickHandler`, right after it, with the tag's
     * index and title (Swift uses `tagClickHandler`, whose `CYLTag` Objective-C cannot see).
     */
    @available(swift, obsoleted: 1, renamed: "tagClickHandler")
    @objc(tagClickHandler)
    open var objcTagClickHandler: ((Int, String) -> Void)? {
        get { objcTagClickHandlerStorage }
        set { objcTagClickHandlerStorage = newValue }
    }

    /**
     * The handler behind `objcTagClickHandler`, which Swift code cannot name.
     */
    private var objcTagClickHandlerStorage: ((Int, String) -> Void)?

    /**
     * Called after a tap on a tag's delete indicator removed it (android-tagview's OnTagDeleteListener), after the
     * menu delegate.
     */
    open var tagDeleteHandler: ((Int, CYLTag) -> Void)?

    // MARK: Container (AndroidTagView's TagContainerLayout)

    /**
     * The list's own border width (container_border_width); 0 by default. The background is `style.backgroundColor`.
     */
    @objc open var containerBorderWidth: CGFloat = 0 {
        didSet {
            containerBorderWidth = max(0, containerBorderWidth)
            layer.borderWidth = containerBorderWidth
        }
    }

    /**
     * The list's own border color (container_border_color); `nil` by default.
     */
    @objc open var containerBorderColor: UIColor? {
        didSet {
            updateContainerBorderColor()
        }
    }

    /**
     * The list's own corner radius (container_border_radius); 0 by default.
     */
    @objc open var containerCornerRadius: CGFloat = 0 {
        didSet {
            containerCornerRadius = max(0, containerCornerRadius)
            layer.cornerRadius = containerCornerRadius
            layer.masksToBounds = containerCornerRadius > 0
        }
    }

    /**
     * At most this many rows of each section (container_max_lines); 0 (the default) shows every row. Setting it sets
     * `foldStyle` to `.truncate` and `defaultVisibleRows` to it.
     */
    @objc open var maximumNumberOfRows: Int {
        get {
            foldStyle == .truncate ? defaultVisibleRows : 0
        }
        set {
            if newValue > 0 {
                foldStyle = .truncate
                defaultVisibleRows = newValue
            } else if foldStyle == .truncate {
                foldStyle = .none
            }
        }
    }

    /**
     * Colors every item that has no look of its own from a theme (tag_theme): `.none` (the default), random, pure cyan
     * or pure teal.
     */
    @objc open var colorTheme: CYLTagColorTheme = .none {
        didSet {
            themeStyles.removeAll()
            invalidateMeasurements()
        }
    }

    /**
     * False ignores taps on tags: no highlight, no selection, no callbacks (tag_clickable). Long presses still work.
     * True by default.
     */
    @objc open var allowsTapping = true

    /**
     * The icon of every item without one of its own (setDefaultImageDrawableID), e.g. an avatar. `nil` by default.
     */
    @objc open var defaultTagImage: UIImage?

    /**
     * False makes a tap on a delete indicator only report it (AndroidTagView's onTagCrossClick); the host removes the
     * item. True by default.
     */
    @objc open var removesItemsOnDelete = true

    // MARK: Long press and reordering

    /**
     * What a long press on an item does: `CYLTagLongPressActions.first([reorder, report])` by default (reordering where
     * the list can reorder, else the long press is reported). Set another built-in action, a combination or your own
     * (docs/tag-long-press-action.md). Setting it cancels a press in progress and hides the callout.
     */
    open var longPressAction: CYLTagLongPressAction = CYLTagLongPressActions.makeDefault() {
        didSet {
            oldValue.cancel(host: self)
            if isReordering {
                cancelReordering()
            }
            dismissCallout()
        }
    }

    /// The callout of a long press that shows now (`CYLTagLongPressHost.showCallout`).
    private var calloutView: CYLTagCalloutView?
    /// A tap anywhere in the window dismisses the callout (also on the list's empty area, the bars and other screens' views).
    private var calloutDismissTap: UITapGestureRecognizer?
    private let calloutTapDelegate = CYLTagCalloutTapDelegate()

    /**
     * A long press on an item without moving it: `menu(_:didLongPressItemAt:)`, then this (onTagLongClick).
     */
    open var tagLongPressHandler: ((Int, CYLTag) -> Void)? {
        didSet {
            refreshVisibleCells()
        }
    }

    /**
     * The name of the long-press custom action that VoiceOver, Voice Control and Switch Control users pick instead of
     * a long press (each tag gets it while `tagLongPressHandler` is set or the delegate handles long presses), such as
     * "删除". `nil`: "长按" (core string `CYLMenuLongPress`). While `allowsReordering`, tags also get 前移 / 后移
     * actions, which move them like a drag and announce the new position.
     */
    @objc open var longPressAccessibilityActionName: String? {
        didSet {
            refreshVisibleCells()
        }
    }

    /**
     * A long press and a move reorders the items of a section (container_enable_drag). Needs a data source that
     * implements `menuMoveItem(at:to:)` (`CYLTagDataSource` does). False by default.
     */
    @objc open var allowsReordering = false {
        didSet {
            updateLongPressDuration()
            refreshVisibleCells()
        }
    }

    /**
     * True: a finger dragged across the items selects them ("smearing", as in WeChat's 涂抹选择填入词): the drag starts on
     * an item and selects every item from it to the item under the finger, in item order, or deselects them when the
     * first item was already selected. A tap still toggles one item, so VoiceOver, Voice Control and Switch Control
     * select the same items. Needs `selectionMode == .multiple`; a drag that starts between items scrolls the list. The
     * delegate gets `menu(_:didChangeSelectedItems:)`. False by default; `CYLMenuStyle.wordPicker()` is the matching look.
     */
    @objc open var allowsSmearSelection = false {
        didSet {
            smearRecognizer.isEnabled = allowsSmearSelection
        }
    }

    /**
     * How quickly a press starts reordering (container_drag_sensitivity): the press lasts 0.5 s divided by it; a value
     * that is not positive is 1. 1 by default.
     */
    @objc open var reorderingSensitivity: CGFloat = 1 {
        didSet {
            if reorderingSensitivity <= 0 {
                reorderingSensitivity = 1
            }
            updateLongPressDuration()
        }
    }

    /**
     * Whether an item is being moved (getTagViewState).
     */
    @objc open private(set) var isReordering = false

    /// While a tag is dragged: its section, its original item and the item it is shown at (`measuredIndexPath(for:)`).
    private var movingItem: (section: Int, from: Int, to: Int)?

    /**
     * One of `tags` moved (after `menu(_:didMoveItemAt:to:)`).
     */
    @objc open var tagMoveHandler: ((Int, Int) -> Void)?

    /**
     * A selected tag started moving (onSelectedTagDrag), after `menu(_:didBeginDraggingSelectedItemAt:)`.
     */
    open var selectedTagDragHandler: ((Int, CYLTag) -> Void)?

    // MARK: Editing

    /**
     * Whether the list is in editing mode (`setEditing(_:animated:)`). While editing, the items of the editable sections
     * (`menuSectionAllowsEditing(_:)`, every section by default) show the delete indicator and can be dragged to
     * reorder; a tap no longer selects an item but still calls `menu(_:didSelectItemAt:)`, so the host can open the
     * item; folded sections show every item; and `addItemView` appears below the last section. False by default.
     */
    @objc open private(set) var isEditing = false

    /**
     * Shows `addItemView` below the last section while editing. True by default.
     */
    @objc open var showsAddItemViewWhileEditing = true {
        didSet {
            updateAddItemView()
        }
    }

    /**
     * The "add tag" control shown while editing: a text field and an Add button. A submitted name is reported through
     * `menu(_:didRequestNewItemWithName:at:)` with the index path after the last item of the first editable section.
     */
    @objc open private(set) lazy var addItemView: CYLTagListAddItemView = {
        let view = CYLTagListAddItemView()
        view.submitHandler = { [weak self] name in
            self?.requestNewItem(named: name)
        }
        return view
    }()

    /// The bottom inset added to the collection view for `addItemView`.
    private var addItemInset: CGFloat = 0

    /// The bottom inset added for the keyboard while editing (the part of the list it covers).
    private var keyboardInset: CGFloat = 0

    /**
     * The item being renamed in editing mode (its rename indicator was tapped); nil otherwise.
     */
    @objc open private(set) var renamingIndexPath: IndexPath?

    /**
     * In editing mode, a tap on a renamable item's title (outside its pencil and cross) renames it too, as the pencil
     * does; a tap elsewhere on the item still calls `menu(_:didSelectItemAt:)`. True by default; it needs the data
     * source's `menuRenameItem(at:to:)`.
     */
    /**
     * Your own editor for renaming (an editing bar above the keyboard, for example): when set, a pencil or title tap
     * calls it with the item and its title instead of filling `addItemView`; finish with `finishRenaming(to:)` or
     * `cancelRenaming()`. nil (the default): `addItemView` is the rename field.
     */
    @objc open var renameRequestHandler: ((IndexPath, String) -> Void)?

    /**
     * Called with the section when its clear button (the bundle's trash icon, shown for the sections the data source's
     * `menuShowsClearButton(forSection:)` names) is tapped, after `menu(_:didTapClearButtonInSection:)`.
     */
    @objc open var clearButtonHandler: ((Int) -> Void)?

    @objc open var renamesOnTitleTapWhileEditing = true {
        didSet {
            refreshVisibleCells()
        }
    }

    /**
     * Where the list saves its editable sections after an edit (a drag, a delete or an added tag in editing mode), so
     * the order survives a relaunch: `.none` (the default), a SQLite database, `NSUserDefaults` or a sandbox file. The
     * host restores it when it builds its data (`cachedTitles(inSection:)`). Setting it makes `cache` the built-in
     * store of the policy and `cacheName`.
     */
    @objc open var cachePolicy: CYLTagListCachePolicy = .none {
        didSet {
            cache = CYLTagListStore.cache(policy: cachePolicy, name: cacheName)
        }
    }

    /**
     * Separates the caches of different lists ("CYLTagListView" by default). Set it before `cachePolicy`, or set
     * `cachePolicy` again after changing it.
     */
    @objc open var cacheName = "CYLTagListView" {
        didSet {
            cache = CYLTagListStore.cache(policy: cachePolicy, name: cacheName)
        }
    }

    /**
     * The store the list saves to: the built-in store of `cachePolicy`, or one of yours. nil: no cache.
     */
    @objc open var cache: CYLTagListCache?

    /**
     * The server the sections are also kept on, for `loadSections(withKeys:completion:)`; nil: the cache only.
     */
    @objc open var remoteSource: CYLTagListRemoteSource?

    /**
     * How `loadSections(withKeys:completion:)` combines the cache and `remoteSource`: `.cacheThenNetwork` (the cache
     * at once, then a refresh from the server) by default.
     */
    @objc open var loadPolicy: CYLTagListLoadPolicy = .cacheThenNetwork

    /**
     * Called when editing ends (`setEditing(false, animated:)`) with the edited sections, by cache key, after
     * `menu(_:didFinishEditingWithTitles:)`: the place to upload them.
     */
    @objc open var editingFinishHandler: (([String: [String]]) -> Void)?

    /**
     * The titles saved for `section` (its index), in order; nil when nothing was saved or there is no cache.
     */
    @objc(cachedTitlesInSection:)
    open func cachedTitles(inSection section: Int) -> [String]? {
        cache?.cachedTitles(forSection: cacheKey(forSection: section))
    }

    /**
     * The key of `section` in the cache: the data source's `menuCacheKey(forSection:)`, else the section's index.
     */
    @objc(cacheKeyForSection:)
    open func cacheKey(forSection section: Int) -> String {
        menuDataSource?.menuCacheKey?(forSection: section) ?? String(section)
    }

    /**
     * Saves the current titles of every editable section to `cache` (the list calls it after each edit).
     */
    @objc open func saveEditableSectionsToCache() {
        guard let cache else {
            return
        }
        if cache.responds(to: #selector(CYLTagListCache.saveItems(_:forSection:))) {
            // With identifiers, so a renamed item stays the same item.
            for (key, items) in editableSectionItems() {
                cache.saveItems?(items, forSection: key)
            }
            return
        }
        for (key, titles) in editableSectionTitles() {
            cache.saveTitles(titles, forSection: key)
        }
    }

    /**
     * The items (identifier from `menuIdentifierForItem(at:)`, else the title; and title) of every editable section,
     * by cache key, without create items.
     */
    @objc open func editableSectionItems() -> [String: [CYLTagListCacheItem]] {
        guard let source = menuDataSource else {
            return [:]
        }
        var result: [String: [CYLTagListCacheItem]] = [:]
        for section in 0..<source.numberOfSectionsInMenu() where sectionAllowsEditing(section) {
            result[cacheKey(forSection: section)] = (0..<source.menuNumberOfItems(inSection: section)).compactMap { item in
                let indexPath = IndexPath(item: item, section: section)
                guard source.menuItemType?(at: indexPath) != .create else { return nil }
                let title = source.menuTitleForItem(at: indexPath)
                return CYLTagListCacheItem(identifier: source.menuIdentifierForItem?(at: indexPath) ?? title, title: title)
            }
        }
        return result
    }

    /**
     * Starts renaming `indexPath` (its rename indicator does this): `addItemView` shows the title with the keyboard up;
     * its submit renames the item through the data source's `menuRenameItem(at:to:)`.
     */
    @objc(beginRenamingItemAtIndexPath:)
    open func beginRenaming(at indexPath: IndexPath) {
        guard isValid(indexPath), isRenamable(at: indexPath) else {
            return
        }
        renamingIndexPath = indexPath
        let title = menuDataSource?.menuTitleForItem(at: indexPath) ?? ""
        if let renameRequestHandler {
            // The host's editor takes it.
            renameRequestHandler(indexPath, title)
            return
        }
        updateAddItemView()
        layoutIfNeeded()
        addItemView.beginRenaming(title: title)
        // The field is below the last section: bring it into view.
        collectionView.scrollRectToVisible(addItemView.frame.insetBy(dx: 0, dy: -8), animated: true)
    }

    /**
     * Ends renaming without a change.
     */
    @objc open func cancelRenaming() {
        guard renamingIndexPath != nil else {
            return
        }
        renamingIndexPath = nil
        addItemView.endRenaming()
        updateAddItemView()
    }

    /**
     * Adds an item named `name` from your own editor, as `addItemView`'s submit does: reported through
     * `menu(_:didRequestNewItemWithName:at:)` at the end of the first editable section, then the cache is saved.
     */
    @objc(submitNewItemNamed:)
    open func submitNewItem(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }
        cancelRenaming()
        requestNewItem(named: trimmed)
    }

    /**
     * Renames the item being renamed to `title` (trimmed; an empty or unchanged one only ends renaming): the data
     * source renames it, the list reloads, saves its cache and calls `menu(_:didRenameItemAt:to:)`.
     */
    @objc(finishRenamingToTitle:)
    open func finishRenaming(to title: String) {
        guard let indexPath = renamingIndexPath else {
            return
        }
        renamingIndexPath = nil
        addItemView.endRenaming()
        let name = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValid(indexPath), !name.isEmpty, name != menuDataSource?.menuTitleForItem(at: indexPath) else {
            updateAddItemView()
            return
        }
        menuDataSource?.menuRenameItem?(at: indexPath, to: name)
        reloadMenuData()
        saveEditableSectionsToCache()
        updateAddItemView()
        menuDelegate?.menu?(self, didRenameItemAt: indexPath, to: name)
    }

    /**
     * The titles of every editable section, by cache key (`cacheKey(forSection:)`), without create items: what the
     * list saves and what `menu(_:didFinishEditingWithTitles:)` reports.
     */
    @objc open func editableSectionTitles() -> [String: [String]] {
        guard let source = menuDataSource else {
            return [:]
        }
        var result: [String: [String]] = [:]
        for section in 0..<source.numberOfSectionsInMenu() where sectionAllowsEditing(section) {
            result[cacheKey(forSection: section)] = (0..<source.menuNumberOfItems(inSection: section)).compactMap { item in
                let indexPath = IndexPath(item: item, section: section)
                return source.menuItemType?(at: indexPath) == .create ? nil : source.menuTitleForItem(at: indexPath)
            }
        }
        return result
    }

    /**
     * Enters or leaves editing mode: the delete indicators, reordering, the selection rules, folding and `addItemView`
     * change together; then `menu(_:didChangeEditing:)` is called. The list itself does not move or open anything.
     */
    @objc(setEditing:animated:)
    open func setEditing(_ editing: Bool, animated: Bool) {
        guard editing != isEditing else {
            return
        }
        isEditing = editing
        // While editing, the keyboard (the add or rename field) must not cover the field.
        if editing {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)),
                                                   name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)),
                                                   name: UIResponder.keyboardWillHideNotification, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            setKeyboardInset(0)
        }
        if !editing {
            renamingIndexPath = nil
            addItemView.endRenaming()
            addItemView.textField.resignFirstResponder()
            // The edited sections, for the host to upload (the cache already has them).
            let titles = editableSectionTitles()
            menuDelegate?.menu?(self, didFinishEditingWithTitles: titles)
            menuDelegate?.menu?(self, didFinishEditingWithItems: editableSectionItems())
            editingFinishHandler?(titles)
        }
        updateLongPressDuration()
        updateAddItemView()
        let reload = {
            self.reloadMenuData()
        }
        if animated && window != nil {
            UIView.transition(with: self, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction],
                              animations: reload)
        } else {
            reload()
        }
        menuDelegate?.menu?(self, didChangeEditing: editing)
    }

    /**
     * Whether a section takes part in editing: the data source's `menuSectionAllowsEditing(_:)`, else true.
     */
    @objc(sectionAllowsEditing:)
    open func sectionAllowsEditing(_ section: Int) -> Bool {
        menuDataSource?.menuSectionAllowsEditing?(section) ?? true
    }

    // MARK: Private state

    /**
     * The tags' collection view; read by key-value coding in the tests (`CYLTagListProbe`).
     */
    @objc private let collectionView: UICollectionView
    private var styleStorage = CYLMenuStyle()
    private var titleStyleStorage = CYLMenuStyle()
    private var foldControlStorage = CYLMenuFoldControl()
    private var foldStyleStorage: CYLMenuFoldStyle = .none
    private var titles: [[String]] = []
    private var itemWidths: [[CGFloat]] = []
    /**
     * Each item's height: the list's item height, or more for an item whose own font needs it.
     */
    private var itemHeights: [[CGFloat]] = []
    private var rows: [[Int]] = []
    private var selection = Set<IndexPath>()
    private var expandedSections = IndexSet()
    private var measuredWidth: CGFloat = -1
    /**
     * The collection view's size at the last layout: any change (also the height, e.g. a host's height constraint
     * going from 0 to the content height) lays the tags out again.
     */
    private var laidOutSize: CGSize = .zero
    /**
     * Measured during the collection view's own layout (from `sizeForItemAt`), where `contentHeight` cannot be
     * updated: `layoutSubviews()` updates it.
     */
    private var contentHeightNeedsUpdate = false
    private var tagDataSourceStorage: CYLTagDataSource?
    /**
     * Theme styles (`colorTheme`): the base style each was made from, and the style.
     */
    private var themeStyles: [IndexPath: (base: CYLMenuStyle, style: CYLMenuStyle)] = [:]
    /**
     * The outlined look of "+ 新建标签" items and the style it was made from.
     */
    private var createItemStyle: CYLMenuStyle?
    private weak var createItemBaseStyle: CYLMenuStyle?
    private let longPressRecognizer = UILongPressGestureRecognizer()
    /**
     * `allowsSmearSelection`: the drag, and while it lasts the selection it began with, the item it began on and whether
     * it selects or deselects.
     */
    private let smearRecognizer = UIPanGestureRecognizer()
    private var smearStart: (selection: Set<IndexPath>, anchor: IndexPath, selects: Bool)?
    /**
     * Where the finger touched down for the current smear (in the collection view): the smear begins on that item, not
     * on the one under the finger once it has moved far enough to count as a drag (it may be in a gap by then).
     */
    var smearTouchDown: CGPoint?
    /**
     * The smear recognizer's delegate (gesture recognizers keep their delegate weakly).
     */
    private lazy var smearGestureDelegate: CYLTagListSmearGestureDelegate = {
        let delegate = CYLTagListSmearGestureDelegate()
        delegate.list = self
        return delegate
    }()
    /**
     * The item under the current long press, and whether the press moved it.
     */
    private var pressedIndexPath: IndexPath?
    private var pressMoved = false
    private var pressStart: CGPoint = .zero

    // MARK: - Initializers

    public override init(frame: CGRect) {
        collectionView = UICollectionView(frame: CGRect(origin: .zero, size: frame.size),
                                          collectionViewLayout: CYLTagListLayout())
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: CYLTagListLayout())
        super.init(coder: coder)
        commonInit()
    }

    /**
     * A tag list without a title, with its fold control (`nil`: none).
     */
    @objc(initWithFoldControl:)
    public convenience init(foldControl: CYLMenuFoldControl?) {
        self.init(foldControl: foldControl, title: nil)
    }

    /**
     * A tag list with its fold control and title, and an icon before the title (either may be `nil`: icon only, title
     * only). The styles are fixed at creation; both can change later.
     */
    @objc(initWithFoldControl:title:titleImage:titlePosition:)
    public convenience init(foldControl: CYLMenuFoldControl?, title: String?, titleImage: UIImage? = nil,
                            titlePosition: CYLMenuTitlePosition = .topLeading) {
        self.init(frame: .zero)
        // Through a method: an initializer of this class does not run the properties' observers.
        configure(foldControl: foldControl, title: title, titleImage: titleImage, titlePosition: titlePosition)
    }

    private func configure(foldControl: CYLMenuFoldControl?, title: String?, titleImage: UIImage?,
                           titlePosition: CYLMenuTitlePosition) {
        if let foldControl {
            self.foldControl = foldControl
        }
        self.titlePosition = titlePosition
        self.titleImage = titleImage
        self.title = title
    }

    /**
     * A tag list with a fold control at this position showing this content.
     */
    @objc(initWithFoldPosition:content:)
    public convenience init(foldPosition: CYLMenuFoldControlPosition, content: CYLMenuFoldControlContent) {
        self.init(foldControl: CYLMenuFoldControl(position: foldPosition, content: content))
    }

    /**
     * Objective-C's `-initWithFoldControl:title:titlePosition:` of the Objective-C core, without an icon; Swift uses
     * `init(foldControl:title:titleImage:titlePosition:)`.
     */
    @available(swift, obsoleted: 1, renamed: "init(foldControl:title:titleImage:titlePosition:)")
    @objc(initWithFoldControl:title:titlePosition:)
    public convenience init(objcFoldControl foldControl: CYLMenuFoldControl?, title: String?,
                            titlePosition: CYLMenuTitlePosition) {
        self.init(foldControl: foldControl, title: title, titleImage: nil, titlePosition: titlePosition)
    }

    /**
     * Objective-C's `+tagListViewWithFoldPosition:content:` of the Objective-C core; Swift uses
     * `init(foldPosition:content:)`.
     */
    @available(swift, obsoleted: 1, renamed: "init(foldPosition:content:)")
    @objc(tagListViewWithFoldPosition:content:)
    public class func objcTagListView(foldPosition: CYLMenuFoldControlPosition,
                                      content: CYLMenuFoldControlContent) -> CYLTagListView {
        CYLTagListView(foldPosition: foldPosition, content: content)
    }

    private func commonInit() {
        // Laid out in layoutSubviews(), below the title.
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(CYLTagListCell.self, forCellWithReuseIdentifier: ReuseIdentifier.cell)
        collectionView.register(CYLTagCreateCell.self, forCellWithReuseIdentifier: ReuseIdentifier.createCell)
        collectionView.register(CYLTagFoldCell.self, forCellWithReuseIdentifier: ReuseIdentifier.foldCell)
        collectionView.register(CYLTagListHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ReuseIdentifier.header)
        collectionView.register(CYLTagListFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: ReuseIdentifier.footer)
        (collectionView.collectionViewLayout as? CYLTagListLayout)?.cardProvider = { [weak self] section in
            self?.cardSpec(forSection: section)
        }
        addSubview(collectionView)
        longPressRecognizer.addTarget(self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPressRecognizer)
        smearRecognizer.addTarget(self, action: #selector(handleSmear(_:)))
        smearRecognizer.delegate = smearGestureDelegate
        smearRecognizer.maximumNumberOfTouches = 1
        smearRecognizer.isEnabled = false
        collectionView.addGestureRecognizer(smearRecognizer)
        // A drag that starts on an item smears; anywhere else the list scrolls.
        collectionView.panGestureRecognizer.require(toFail: smearRecognizer)
        // The list's title: a tag view (icon and/or title, horizontal), not tappable.
        titleStyleStorage = Self.defaultTitleStyle
        titleView.style = titleStyleStorage
        titleView.isUserInteractionEnabled = false
        titleView.isAccessibilityElement = true
        titleView.accessibilityTraits = .header
        titleView.accessibilityIdentifier = CYLTagListAccessibilityIdentifier.title
        titleView.isHidden = true
        addSubview(titleView)
        applyStyleColors()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshVisibleCells),
                                               name: UIAccessibility.darkerSystemColorsStatusDidChangeNotification,
                                               object: nil)
    }

    // MARK: - Data

    /**
     * Reads everything from the data source again. Selections and expanded sections that are still in range are kept.
     */
    @objc open func reloadMenuData() {
        dismissCallout()
        let source = menuDataSource
        if let tagSource = tagDataSourceStorage, source === tagSource {
            // A tag's look may have changed.
            tagSource.invalidateStyles()
        }
        let sections = source?.numberOfSectionsInMenu() ?? 0
        titles = (0..<max(0, sections)).map { section in
            (0..<max(0, source?.menuNumberOfItems(inSection: section) ?? 0)).map { item in
                let indexPath = IndexPath(item: item, section: section)
                let title = source?.menuTitleForItem(at: indexPath) ?? ""
                // "+ 新建标签": the title is the name to create; the item shows "新建标签：<name>".
                return itemType(at: indexPath) == .create ? CYLTagCreateCell.title(forName: title) : title
            }
        }
        selection = selection.filter(isValid)
        expandedSections = expandedSections.filteredIndexSet { $0 < sections }
        invalidateMeasurements()
    }

    /**
     * Height the content needs at `width` with the current data and fold state, without laying the view out.
     */
    @objc(heightThatFitsWidth:)
    open func heightThatFitsWidth(_ width: CGFloat) -> CGFloat {
        let available = contentWidth(forWidth: width)
        let measured = width == measuredWidth
        let sectionWidths = measured ? itemWidths : widths(forContentWidth: available)
        let sectionRows = measured ? rows : rows(forWidths: sectionWidths, contentWidth: available)
        let sectionHeights = measured ? itemHeights : measureItemHeights(widths: sectionWidths)
        let header = headerHeight()
        let insets = tagInsets(atWidth: width)
        var height: CGFloat = 0
        for section in sectionRows.indices {
            var rowCount = sectionRows[section].count
            let foldable = canFold(rowCount: rowCount)
            if foldable && !expandedSections.contains(section) {
                rowCount = defaultVisibleRows
            } else if foldable && foldControlIsInline {
                // Expanded, the inline fold cell follows the last item and may start a row of its own.
                let withFold = sectionWidths[section] + [inlineFoldSize(inSection: section, expanded: true).width]
                rowCount = rows(forWidths: [withFold], contentWidth: available).first?.count ?? 0
            }
            height += header + insets.top + insets.bottom
            height += heightOfRows(rowCount, rows: sectionRows[section],
                                   heights: section < sectionHeights.count ? sectionHeights[section] : [])
            if foldable && foldControlIsInFooter {
                height += footerHeight
            }
        }
        return ceil(height) + titleHeight(forWidth: width)
    }

    /**
     * The section column at the current width: the list width minus `sectionInsets` (x and width; y and height are 0). The card,
     * the header band and the divider span it.
     */
    open func contentColumn(inSection section: Int) -> CGRect {
        column(atWidth: collectionView.bounds.width)
    }

    /**
     * The column the tags are laid in: `contentColumn(inSection:)` narrowed by the card's padding under `.insetGrouped`. Tag
     * widths, rows, fold decisions, heights and frames all come from it.
     */
    open func tagColumn(inSection section: Int) -> CGRect {
        tagColumn(atWidth: collectionView.bounds.width)
    }

    // MARK: - Tags

    /**
     * The list's own tags, for a list filled the android-tagview way: create it, add `CYLTag` objects (or titles),
     * react to taps and deletions in closures. The first tag method makes `tagDataSource` the `menuDataSource` and, the
     * way android-tagview behaves, turns section headers off and sets `selectionMode` to `.none` (change them
     * afterwards to select tags). Every other API (styles, folding, selection, configuration) keeps working.
     */
    @objc open var tagDataSource: CYLTagDataSource {
        if let tagDataSourceStorage {
            return tagDataSourceStorage
        }
        let source = CYLTagDataSource()
        source.baseStyle = style
        tagDataSourceStorage = source
        return source
    }

    /**
     * The tags of `tagDataSource`, in order (android-tagview's getTags()).
     */
    open var tags: [CYLTag] {
        tagDataSourceStorage?.tags ?? []
    }

    /**
     * Adds a tag.
     */
    open func addTag(_ tag: CYLTag) {
        showTags().addTag(tag)
        reloadMenuData()
    }

    /**
     * Adds tags.
     */
    open func addTags(_ tags: [CYLTag]) {
        showTags().addTags(tags)
        reloadMenuData()
    }

    /**
     * Tags with these titles and the list's look (android-tagview's addTags(String[])).
     */
    @objc(addTagsWithTitles:)
    open func addTags(withTitles titles: [String]) {
        addTags(titles.map { CYLTag(title: $0) })
    }

    /**
     * Adds a tag with this title.
     */
    @objc(addTagWithTitle:)
    open func addTag(withTitle title: String) {
        addTag(CYLTag(title: title))
    }

    /**
     * Inserts a tag; selections at or after it move down. An index past the end adds it at the end.
     */
    open func insertTag(_ tag: CYLTag, at index: Int) {
        let source = showTags()
        let position = min(max(0, index), source.tags.count)
        source.insertTag(tag, at: position)
        shiftSelection(inSection: 0, fromItem: position, by: 1)
        reloadMenuData()
    }

    /**
     * Inserts a tag with this title.
     */
    @objc(insertTagWithTitle:atIndex:)
    open func insertTag(withTitle title: String, at index: Int) {
        insertTag(CYLTag(title: title), at: index)
    }

    /**
     * Removes a tag (android-tagview's remove(position)); selections after it move up. Out-of-range indexes are
     * ignored.
     */
    @objc(removeTagAtIndex:)
    open func removeTag(at index: Int) {
        let source = showTags()
        guard source.tags.indices.contains(index) else {
            return
        }
        source.removeTag(at: index)
        removeSelection(at: IndexPath(item: index, section: 0))
        reloadMenuData()
    }

    /**
     * Removes several tags (removeConsecutiveTags).
     */
    @objc(removeTagsAtIndexes:)
    open func removeTags(at indexes: IndexSet) {
        let source = showTags()
        for index in indexes.reversed() where source.tags.indices.contains(index) {
            source.removeTag(at: index)
            removeSelection(at: IndexPath(item: index, section: 0))
        }
        reloadMenuData()
    }

    /**
     * Removes every tag.
     */
    @objc open func removeAllTags() {
        showTags().removeAllTags()
        selection.removeAll()
        reloadMenuData()
    }

    /**
     * Replaces the tags (setTags).
     */
    open func replaceTags(_ tags: [CYLTag]) {
        showTags().tags = tags
        selection.removeAll()
        reloadMenuData()
    }

    /**
     * Replaces the tags with tags of these titles, and colors per tag, in order (setTags(List, List<int[]>)); tags past
     * the colors keep the list's look.
     */
    open func setTags(withTitles titles: [String], colors: [CYLTagColors] = []) {
        replaceTags(titles.enumerated().map { index, title in
            let tag = CYLTag(title: title)
            if index < colors.count {
                tag.colors = colors[index]
            }
            return tag
        })
    }

    /**
     * Objective-C's `-setTagsWithTitles:`: replaces the tags with tags of these titles and the list's look (Swift uses
     * `setTags(withTitles:colors:)`, whose `CYLTagColors` Objective-C cannot see).
     */
    @available(swift, obsoleted: 1, renamed: "setTags(withTitles:colors:)")
    @objc(setTagsWithTitles:)
    open func objcSetTags(withTitles titles: [String]) {
        setTags(withTitles: titles)
    }

    /**
     * Deletes a deletable item as a tap on its delete indicator does: the data source removes it
     * (`menuRemoveItem(at:)`), the list reloads and reports it. Does nothing for an item that is not deletable or not
     * enabled.
     */
    @objc(deleteItemAtIndexPath:)
    open func deleteItem(at indexPath: IndexPath) {
        guard isValid(indexPath), isDeletable(at: indexPath), isEnabled(at: indexPath) else {
            return
        }
        let deletedTag = tag(at: indexPath)
        if removesItemsOnDelete, let source = menuDataSource, source.responds(to: #selector(CYLMenuDataSource.menuRemoveItem(at:))) {
            source.menuRemoveItem?(at: indexPath)
            removeSelection(at: indexPath)
            reloadMenuData()
            UIAccessibility.post(notification: .layoutChanged, argument: nil)
        }
        menuDelegate?.menu?(self, didDeleteItemAt: indexPath)
        if isEditing {
            saveEditableSectionsToCache()
        }
        if let deletedTag {
            tagDeleteHandler?(indexPath.item, deletedTag)
        }
    }

    /**
     * The tag view of a shown item (getTagView), or `nil` when it is not on screen.
     */
    @objc(tagButtonAtIndexPath:)
    open func tagButton(at indexPath: IndexPath) -> CYLTagButton? {
        (collectionView.cellForItem(at: indexPath) as? CYLTagListCell)?.button
    }

    // MARK: - Selection

    /**
     * Selected items in ascending order. Setting applies the selection rules of `selectionMode`; it raises
     * `NSInvalidArgumentException` for an item outside the menu (validate before setting it from Swift, which cannot
     * catch the exception).
     */
    @objc open var selectedIndexPaths: [IndexPath] {
        get {
            selection.sorted()
        }
        set {
            selection.removeAll()
            if selectionMode != .none {
                for indexPath in newValue {
                    guard isValid(indexPath) else {
                        NSException(name: .invalidArgumentException, reason: "Invalid menu selection: \(indexPath)",
                                    userInfo: nil).raise()
                        return
                    }
                    if isSelectable(at: indexPath) {
                        applySelection(of: indexPath)
                    }
                }
            }
            refreshVisibleCells()
        }
    }

    /**
     * The titles of the selected items, in order (getSelectedTagViewText).
     */
    @objc open var selectedTitles: [String] {
        selectedIndexPaths.map { menuDataSource?.menuTitleForItem(at: $0) ?? "" }
    }

    /**
     * Applies the selection rules of `selectionMode` without calling the delegate.
     */
    @objc(selectItemAtIndexPath:)
    open func selectItem(at indexPath: IndexPath) {
        guard selectionMode != .none, isValid(indexPath), isSelectable(at: indexPath) else {
            return
        }
        applySelection(of: indexPath)
        refreshVisibleCells()
    }

    /**
     * Deselects an item without calling the delegate.
     */
    @objc(deselectItemAtIndexPath:)
    open func deselectItem(at indexPath: IndexPath) {
        selection.remove(indexPath)
        refreshVisibleCells()
    }

    /**
     * Deselects every item without calling the delegate.
     */
    @objc open func deselectAllItems() {
        selection.removeAll()
        refreshVisibleCells()
    }

    /**
     * Selects an unselected item or deselects a selected one (toggleSelectTagView). In `.none` mode, where taps never
     * select, it still selects (any number of items), as AndroidTagView's long press does.
     */
    @objc(toggleSelectionOfItemAtIndexPath:)
    open func toggleSelection(at indexPath: IndexPath) {
        if selection.contains(indexPath) {
            deselectItem(at: indexPath)
        } else if selectionMode == .none {
            // Taps never select in this mode; the host's toggle (a long press) adds any number of items.
            if isValid(indexPath) && isSelectable(at: indexPath) {
                applySelection(of: indexPath)
                refreshVisibleCells()
            }
        } else {
            selectItem(at: indexPath)
        }
    }

    // MARK: - Folding

    /**
     * Whether a section is expanded.
     */
    @objc(isSectionExpanded:)
    open func isSectionExpanded(_ section: Int) -> Bool {
        section >= 0 && expandedSections.contains(section)
    }

    /**
     * Expands or collapses a section and calls `menu(_:didChangeExpanded:inSection:)`.
     */
    @objc(setExpanded:forSection:animated:)
    open func setExpanded(_ expanded: Bool, forSection section: Int, animated: Bool) {
        guard titles.indices.contains(section), expanded != isSectionExpanded(section) else {
            return
        }
        if foldControlIsInline {
            setInlineExpanded(expanded, forSection: section, animated: animated)
            return
        }
        // Insert or delete only the rows beyond the folded ones, so the header and footer stay in place and their
        // fold control can animate.
        let before = collectionView.numberOfItems(inSection: section)
        if expanded {
            expandedSections.insert(section)
        } else {
            expandedSections.remove(section)
        }
        let after = numberOfVisibleItems(inSection: section)
        let changed = (min(before, after)..<max(before, after)).map { IndexPath(item: $0, section: section) }
        let update = {
            if after > before {
                self.collectionView.insertItems(at: changed)
            } else if after < before {
                self.collectionView.deleteItems(at: changed)
            }
        }
        // Reduce Motion: change the content without animating it.
        let animate = animated && window != nil && !UIAccessibility.isReduceMotionEnabled
        performUpdate(update, animated: animate)
        updateFoldControls(inSection: section, animated: animate)
        updateContentHeight()
        moveAccessibilityFocusToFoldControl(inSection: section)
        menuDelegate?.menu?(self, didChangeExpanded: expanded, inSection: section)
    }

    /**
     * Whether the section has more rows than `defaultVisibleRows` and can fold.
     */
    @objc(canFoldSection:)
    open func canFoldSection(_ section: Int) -> Bool {
        measureIfNeeded()
        // Without a known width every tag is laid out in a row of its own: that is no layout, so nothing can need a fold yet.
        guard collectionView.bounds.width > 0 else {
            return false
        }
        return rows.indices.contains(section) && canFold(rowCount: rows[section].count)
    }

    /**
     * Number of rows the section's items occupy at the current width.
     */
    @objc(numberOfRowsInSection:)
    open func numberOfRows(inSection section: Int) -> Int {
        measureIfNeeded()
        return rows.indices.contains(section) ? rows[section].count : 0
    }

    /**
     * Number of items currently shown in the section (fewer while collapsed).
     */
    @objc(numberOfVisibleItemsInSection:)
    open func numberOfVisibleItems(inSection section: Int) -> Int {
        measureIfNeeded()
        guard titles.indices.contains(section) else {
            return 0
        }
        let total = titles[section].count
        guard rows.indices.contains(section), canFoldSection(section), !isSectionExpanded(section) else {
            return total
        }
        var visible = 0
        var lastRowCount = 0
        for count in rows[section].prefix(defaultVisibleRows) {
            lastRowCount = count
            visible += count
        }
        visible = min(visible, total)
        if foldControlIsInline && lastRowCount > 0 && itemWidths.indices.contains(section) {
            // The inline fold cell ends the last visible row: hide the items it needs the room of.
            let widths = itemWidths[section]
            let spacing = style.interitemSpacing
            let available = contentWidth(forWidth: measuredWidth)
            let foldWidth = inlineFoldSize(inSection: section, expanded: false).width
            var used: CGFloat = 0
            for item in (visible - lastRowCount)..<visible {
                used += (item > visible - lastRowCount ? spacing : 0) + widths[item]
            }
            while lastRowCount > 1 && used + spacing + foldWidth > available {
                used -= widths[visible - 1] + spacing
                lastRowCount -= 1
                visible -= 1
            }
        }
        return visible
    }

    // MARK: - Scrolling

    /**
     * Scrolls so that the section (its header, or its first row) is at the top, as far as the content allows.
     */
    @objc(scrollToSection:animated:)
    open func scroll(toSection section: Int, animated: Bool) {
        guard section >= 0, section < collectionView.numberOfSections else {
            return
        }
        layoutIfNeeded()
        collectionView.layoutIfNeeded()
        let layout = collectionView.collectionViewLayout
        let indexPath = IndexPath(item: 0, section: section)
        var top: CGFloat?
        if let header = layout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                    at: indexPath),
           header.frame.height > 0 {
            top = header.frame.minY
        } else if collectionView.numberOfItems(inSection: section) > 0,
                  let item = layout.layoutAttributesForItem(at: indexPath) {
            top = item.frame.minY - tagInsets(atWidth: collectionView.bounds.width).top
        }
        guard let top else {
            return
        }
        let inset = collectionView.adjustedContentInset
        let maxOffset = max(-inset.top, layout.collectionViewContentSize.height + inset.bottom - collectionView.bounds.height)
        collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x,
                                                y: min(max(top - inset.top, -inset.top), maxOffset)),
                                        animated: animated)
    }

    /**
     * Scrolls so that the item is centered vertically, as far as the content allows (e.g. a tag just created, or the
     * last item). Does nothing for an item that is not shown (folded away).
     */
    @objc(scrollToItemAtIndexPath:animated:)
    open func scrollToItem(at indexPath: IndexPath, animated: Bool) {
        guard isValid(indexPath), indexPath.item < numberOfVisibleItems(inSection: indexPath.section) else {
            return
        }
        layoutIfNeeded()
        collectionView.layoutIfNeeded()
        let layout = collectionView.collectionViewLayout
        guard let attributes = layout.layoutAttributesForItem(at: indexPath) else {
            return
        }
        let inset = collectionView.adjustedContentInset
        let visibleHeight = collectionView.bounds.height - inset.top - inset.bottom
        let target = attributes.frame.midY - visibleHeight / 2 - inset.top
        let maxOffset = max(-inset.top, layout.collectionViewContentSize.height + inset.bottom - collectionView.bounds.height)
        collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x,
                                                y: min(max(target, -inset.top), maxOffset)),
                                        animated: animated)
    }

    // MARK: - Overrides

    open override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: contentHeight)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        // The list's title, then the sections.
        let width = bounds.width
        let titleAreaHeight = titleHeight(forWidth: width)
        titleView.frame = titleAreaHeight > 0 ? titleFrame(forWidth: width, height: titleAreaHeight) : .zero
        let collectionFrame = CGRect(x: 0, y: titleAreaHeight, width: width,
                                     height: max(0, bounds.height - titleAreaHeight))
        if collectionView.frame != collectionFrame {
            collectionView.frame = collectionFrame
        }
        if collectionView.bounds.width != measuredWidth {
            reloadLayout()
        } else if collectionView.bounds.size != laidOutSize {
            collectionView.collectionViewLayout.invalidateLayout()
        }
        if contentHeightNeedsUpdate {
            updateContentHeight()
        }
        layoutAddItemView()
        laidOutSize = collectionView.bounds.size
        if !collectionView.isScrollEnabled {
            resetContentOffset()
        }
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateContainerBorderColor()
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory
            || previousTraitCollection?.legibilityWeight != traitCollection.legibilityWeight {
            // Dynamic Type or Bold Text changed: measure every tag again.
            invalidateMeasurements()
        }
    }
}

// MARK: - Data source queries

private extension CYLTagListView {

    func isValid(_ indexPath: IndexPath) -> Bool {
        titles.indices.contains(indexPath.section) && titles[indexPath.section].indices.contains(indexPath.item)
    }

    func isEnabled(at indexPath: IndexPath) -> Bool {
        menuDataSource?.menuItemIsEnabled?(at: indexPath) ?? true
    }

    func isDeletable(at indexPath: IndexPath) -> Bool {
        guard itemType(at: indexPath) != .create else {
            return false
        }
        if isEditing && sectionAllowsEditing(indexPath.section) {
            // Editing: every item of an editable section, unless the data source says otherwise.
            return menuDataSource?.menuItemIsDeletable?(at: indexPath) ?? true
        }
        return menuDataSource?.menuItemIsDeletable?(at: indexPath) == true
    }

    func isRenamable(at indexPath: IndexPath) -> Bool {
        isEditing && sectionAllowsEditing(indexPath.section) && itemType(at: indexPath) != .create && isDeletable(at: indexPath)
            && menuDataSource?.responds(to: #selector(CYLMenuDataSource.menuRenameItem(at:to:))) == true
    }

    func isExclusive(at indexPath: IndexPath) -> Bool {
        menuDataSource?.menuItemIsExclusive?(at: indexPath) == true
    }

    func isSelectable(at indexPath: IndexPath) -> Bool {
        // Editing: a tap reports the item (`menu(_:didSelectItemAt:)`) without changing the selection.
        !isEditing && itemType(at: indexPath) != .create && menuDataSource?.menuItemIsSelectable?(at: indexPath) != false
    }

    func itemType(at indexPath: IndexPath) -> CYLMenuItemType {
        menuDataSource?.menuItemType?(at: indexPath) ?? .tag
    }

    func image(at indexPath: IndexPath) -> UIImage? {
        if itemType(at: indexPath) == .create {
            return CYLTagCreateCell.plusImage
        }
        return menuDataSource?.menuImageForItem?(at: indexPath) ?? defaultTagImage
    }

    func selectedImage(at indexPath: IndexPath) -> UIImage? {
        menuDataSource?.menuSelectedImageForItem?(at: indexPath)
    }

    func animationURL(at indexPath: IndexPath) -> URL? {
        menuDataSource?.menuAnimationURLForItem?(at: indexPath)
    }

    func animationRestingProgress(at indexPath: IndexPath) -> CGFloat {
        CGFloat(menuDataSource?.menuAnimationRestingProgressForItem?(at: indexPath)?.doubleValue ?? 0)
    }

    /**
     * The item's own look, or its section's.
     */
    func style(forItemAt indexPath: IndexPath) -> CYLMenuStyle {
        if let style = menuDataSource?.menuStyleForItem?(at: indexPath) {
            return style
        }
        let sectionStyle = style(forSection: indexPath.section)
        if itemType(at: indexPath) != .create {
            return themeStyle(forItemAt: indexPath, baseStyle: sectionStyle)
        }
        // "+ 新建标签": outlined, made once per base style.
        if let createItemStyle, createItemBaseStyle === sectionStyle {
            return createItemStyle
        }
        let outlined = CYLTagCreateCell.outlinedStyle(from: sectionStyle)
        createItemStyle = outlined
        createItemBaseStyle = sectionStyle
        return outlined
    }

    /**
     * The section's own look, or the list's style.
     */
    func style(forSection section: Int) -> CYLMenuStyle {
        menuDataSource?.menuStyle?(forSection: section) ?? style
    }

    func showsMoreButton(inSection section: Int) -> Bool {
        menuDataSource?.menuShowsMoreButton?(inSection: section) == true
    }

    /**
     * The theme's colors over `baseStyle` (`colorTheme`), one cached style per item.
     */
    func themeStyle(forItemAt indexPath: IndexPath, baseStyle: CYLMenuStyle) -> CYLMenuStyle {
        if colorTheme == .none {
            return baseStyle
        }
        if let cached = themeStyles[indexPath], cached.base === baseStyle {
            return cached.style
        }
        let seed = indexPath.item + indexPath.section * 7
        let style = CYLTagColors(theme: colorTheme, seed: seed)?.styleByApplying(to: baseStyle) ?? baseStyle
        themeStyles[indexPath] = (baseStyle, style)
        return style
    }

    /**
     * One of `tags` when the list shows them.
     */
    func tag(at indexPath: IndexPath) -> CYLTag? {
        guard let source = tagDataSourceStorage, menuDataSource === source, indexPath.section == 0 else {
            return nil
        }
        let tags = source.tags
        return tags.indices.contains(indexPath.item) ? tags[indexPath.item] : nil
    }

    /**
     * Shows `tagDataSource`, the way android-tagview does the first time: no section headers, taps only.
     */
    func showTags() -> CYLTagDataSource {
        let source = tagDataSource
        if menuDataSource !== source {
            menuDataSource = source
            showsSectionHeaders = false
            selectionMode = .none
        }
        return source
    }
}

// MARK: - Appearance and title

private extension CYLTagListView {

    func applyStyleColors() {
        backgroundColor = styleStorage.resolvedBackgroundColor
        collectionView.backgroundColor = styleStorage.resolvedBackgroundColor
        if let layout = collectionView.collectionViewLayout as? CYLCollectionViewLeftAlignedLayout,
           layout.rowAlignment != styleStorage.rowAlignment {
            layout.rowAlignment = styleStorage.rowAlignment
            layout.invalidateLayout()
        }
        themeStyles.removeAll()
    }

    func updateStyle(_ change: (CYLMenuStyle) -> Void) {
        let copy = style.cylCopy()
        change(copy)
        style = copy
    }

    var hasTitle: Bool {
        !(title ?? "").isEmpty || titleImage != nil
    }

    func titleDidChange() {
        titleView.isHidden = !hasTitle
        let label = (title ?? "").isEmpty ? titleImage?.accessibilityLabel : title
        titleView.accessibilityLabel = label
        // An icon-only title without a label is decorative; give the title image an accessibilityLabel to announce it.
        titleView.isAccessibilityElement = !(label ?? "").isEmpty
        setNeedsLayout()
        updateContentHeight()
    }

    /**
     * The height of the title area, 0 without a title or an icon.
     */
    func titleHeight(forWidth width: CGFloat) -> CGFloat {
        guard hasTitle else {
            return 0
        }
        return ceil(CYLTagButton.height(for: titleStyle, traitCollection: traitCollection))
            + 2 * Self.titleVerticalInset
    }

    /**
     * The title view's frame: as wide as its content (no wider than the list), at the leading edge or centered.
     */
    func titleFrame(forWidth width: CGFloat, height titleHeight: CGFloat) -> CGRect {
        let inset = style.sectionInsets.left
        let available = max(0, width - 2 * inset)
        let contentWidth = min(available, ceil(CYLTagButton.width(forTitle: title, image: titleImage, style: titleStyle,
                                                                  traitCollection: traitCollection)))
        let rightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
        let x = titlePosition == .topCenter ? floor((width - contentWidth) / 2)
            : (rightToLeft ? width - inset - contentWidth : inset)
        return CGRect(x: x, y: Self.titleVerticalInset, width: contentWidth,
                      height: titleHeight - 2 * Self.titleVerticalInset)
    }

    func resetContentOffset() {
        let top = CGPoint(x: 0, y: -collectionView.contentInset.top)
        if collectionView.contentOffset != top {
            collectionView.contentOffset = top
        }
    }

    func updateContainerBorderColor() {
        layer.borderColor = containerBorderColor?.resolvedColor(with: traitCollection).cgColor
    }

    func updateLongPressDuration() {
        longPressRecognizer.minimumPressDuration = allowsReordering || isEditing
            ? Self.longPressDuration / reorderingSensitivity : Self.longPressDuration
    }
}

// MARK: - Measurement

private extension CYLTagListView {

    var itemHeight: CGFloat {
        CYLTagButton.height(for: style, traitCollection: traitCollection)
    }

    var foldControlIsInHeader: Bool {
        foldControl.position == .headerTrailing || foldControl.position == .headerLeading
    }

    var foldControlIsInFooter: Bool {
        foldControl.position == .footer
    }

    var foldControlIsInline: Bool {
        foldControl.position == .tail
    }

    /**
     * Whether a section shows the inline fold cell (it can fold: some items do not fit in the visible rows).
     */
    func showsInlineFoldCell(inSection section: Int) -> Bool {
        foldControlIsInline && canFoldSection(section)
    }

    /**
     * The inline fold cell comes right after the section's visible items.
     */
    func isInlineFoldCell(at indexPath: IndexPath) -> Bool {
        showsInlineFoldCell(inSection: indexPath.section)
            && indexPath.item == numberOfVisibleItems(inSection: indexPath.section)
    }

    /**
     * The fold control as shown: `CYLMenuStyle.foldChevronImage` replaces the default chevron.
     */
    var displayedFoldControl: CYLMenuFoldControl {
        guard let chevron = style.foldChevronImage, foldControl.usesDefaultImage else {
            return foldControl
        }
        let control = foldControl.cylCopy()
        control.image = chevron
        return control
    }

    func inlineFoldSize(inSection section: Int, expanded: Bool) -> CGSize {
        CYLTagFoldButton.inlineSize(for: displayedFoldControl, itemStyle: style(forSection: section), expanded: expanded,
                                    traitCollection: traitCollection)
    }

    /**
     * The fold control's size in a state.
     */
    func foldSize(expanded: Bool) -> CGSize {
        CYLTagFoldButton.size(for: foldControl, expanded: expanded, traitCollection: traitCollection)
    }

    var footerHeight: CGFloat {
        max(Self.footerHeight, foldSize(expanded: false).height)
    }

    func headerHeight() -> CGFloat {
        // A fold control at the top needs the header, also when section titles are hidden.
        let foldHeight = foldControlIsInHeader ? foldSize(expanded: false).height : 0
        guard showsSectionHeaders else {
            return foldHeight
        }
        let font = style.headerFont(for: traitCollection)
        return max(style.headerHeight, ceil(font.lineHeight) + 12, foldHeight)
    }

    /**
     * The one column function: the section column at the list width `width`, the list width minus `sectionInsets` (x and width; y and
     * height are 0). The card, the header band and the divider span it.
     */
    func column(atWidth width: CGFloat) -> CGRect {
        let insets = style.sectionInsets
        return CGRect(x: insets.left, y: 0, width: max(0, width - insets.left - insets.right), height: 0)
    }

    /**
     * The card's padding around the tags: `sectionContentInsets` under `.insetGrouped`, else none.
     */
    var cardInsets: UIEdgeInsets {
        style.sectionStyle == .insetGrouped ? style.sectionContentInsets : .zero
    }

    /**
     * The column the tags are laid in: the section column, narrowed by the card's padding. Every tag width, row count, fold decision,
     * height and frame takes its width and x from here.
     */
    func tagColumn(atWidth width: CGFloat) -> CGRect {
        let column = column(atWidth: width)
        let card = cardInsets
        return CGRect(x: column.minX + card.left, y: 0, width: max(0, column.width - card.left - card.right), height: 0)
    }

    /**
     * The flow layout's section insets: the tag column's edges, and the section's top and bottom insets plus the card's.
     */
    func tagInsets(atWidth width: CGFloat) -> UIEdgeInsets {
        let tagColumn = tagColumn(atWidth: width)
        let card = cardInsets
        return UIEdgeInsets(top: style.sectionInsets.top + card.top, left: tagColumn.minX,
                            bottom: style.sectionInsets.bottom + card.bottom, right: width - tagColumn.maxX)
    }

    func contentWidth(forWidth width: CGFloat) -> CGFloat {
        tagColumn(atWidth: width).width
    }

    func cardSpec(forSection section: Int) -> CYLTagListCardSpec? {
        guard style.sectionStyle == .insetGrouped else {
            return nil
        }
        return CYLTagListCardSpec(column: column(atWidth: collectionView.bounds.width), padding: cardInsets,
                                  color: style.resolvedSectionBackgroundColor, glassTint: style.sectionBackgroundColor,
                                  usesGlass: style.resolvedSectionBackgroundStyle == .liquidGlass, cornerRadius: style.sectionCornerRadius)
    }

    /**
     * The distances from the list's leading and trailing edges to a header's title and fold control: the tags' edges inside the card
     * (`.insetGrouped`), the band's edges plus `headerContentInsets` (a plain header with a band), else `headerHorizontalInset`.
     */
    func headerEdgeInsets(atWidth width: CGFloat) -> (leading: CGFloat, trailing: CGFloat) {
        let column = column(atWidth: width)
        let rest = max(0, width - column.maxX)
        if style.sectionStyle == .insetGrouped {
            let card = cardInsets
            return (column.minX + card.left, rest + card.right)
        }
        if style.headerBackgroundColor != nil {
            return (column.minX + style.headerContentInsets.left, rest + style.headerContentInsets.right)
        }
        return (style.headerHorizontalInset, style.headerHorizontalInset)
    }

    /**
     * Gives a header its insets, band and divider.
     */
    func configureHeaderSectionStyle(_ header: CYLTagListHeaderView) {
        let width = collectionView.bounds.width
        let edges = headerEdgeInsets(atWidth: width)
        header.leadingInset = edges.leading
        header.trailingInset = edges.trailing
        let column = column(atWidth: width)
        let rest = max(0, width - column.maxX)
        if let color = style.headerBackgroundColor {
            header.bandEdges = (column.minX, rest)
            header.bandView.backgroundColor = color
            header.bandView.layer.cornerRadius = style.headerCornerRadius
        } else {
            header.bandEdges = nil
        }
        if style.headerSeparatorStyle == .line, style.headerSeparatorThickness > 0 {
            let insets = style.headerSeparatorInsets
            header.separatorEdges = (column.minX + insets.left, rest + insets.right)
            header.separatorThickness = style.headerSeparatorThickness
            header.separatorView.backgroundColor = style.resolvedHeaderSeparatorColor
        } else {
            header.separatorEdges = nil
        }
    }

    func widths(forContentWidth contentWidth: CGFloat) -> [[CGFloat]] {
        titles.enumerated().map { section, items in
            let perRow = Int(style(forSection: section).numberOfItemsPerRow)
            return items.enumerated().map { item, title in
                if perRow > 0 {
                    // The grid: every item the same width, a longer title truncated.
                    return min(gridItemWidth(forContentWidth: contentWidth, itemsPerRow: perRow), contentWidth)
                }
                let indexPath = IndexPath(item: item, section: section)
                let itemStyle = style(forItemAt: indexPath)
                let iconSize = CYLTagButton.iconSize(for: image(at: indexPath), animated: animationURL(at: indexPath) != nil,
                                                     style: itemStyle)
                let width = CYLTagButton.width(forTitle: title, iconSize: iconSize,
                                               showsDeleteIndicator: isDeletable(at: indexPath),
                                               showsRenameIndicator: isRenamable(at: indexPath), style: itemStyle,
                                               traitCollection: traitCollection)
                return min(width, contentWidth)
            }
        }
    }

    /**
     * Each item's height; an item whose style wraps its title (`CYLMenuStyle.titleWraps`) is measured at its width in
     * `widths`, so a long title that wraps gets a taller cell.
     */
    func measureItemHeights(widths: [[CGFloat]]) -> [[CGFloat]] {
        let listHeight = itemHeight
        return titles.enumerated().map { section, items in
            items.enumerated().map { item, title in
                let indexPath = IndexPath(item: item, section: section)
                let itemStyle = style(forItemAt: indexPath)
                if itemStyle.titleWraps, widths.indices.contains(section), widths[section].indices.contains(item) {
                    let iconSize = CYLTagButton.iconSize(for: image(at: indexPath), animated: animationURL(at: indexPath) != nil,
                                                         style: itemStyle)
                    return max(listHeight, CYLTagButton.height(forTitle: title, iconSize: iconSize, width: widths[section][item],
                                                               showsDeleteIndicator: isDeletable(at: indexPath),
                                                               style: itemStyle, traitCollection: traitCollection))
                }
                return itemStyle === style
                    ? listHeight : max(listHeight, CYLTagButton.height(for: itemStyle, traitCollection: traitCollection))
            }
        }
    }

    /**
     * The height of the first `rowCount` rows of a section: each row as tall as its tallest item. Rows past the
     * measured ones (the inline fold cell on a row of its own) are the list's item height.
     */
    func heightOfRows(_ rowCount: Int, rows: [Int], heights: [CGFloat]) -> CGFloat {
        var total: CGFloat = 0
        var item = 0
        for row in 0..<max(0, rowCount) {
            var rowHeight = itemHeight
            if row < rows.count {
                let count = rows[row]
                let end = min(item + count, heights.count)
                if end > item {
                    rowHeight = heights[item..<end].reduce(rowHeight, max)
                }
                item += count
            }
            total += rowHeight
        }
        return total + (rowCount > 0 ? CGFloat(rowCount - 1) * style.lineSpacing : 0)
    }

    /**
     * The width of a grid item: the content width minus the spacing, divided evenly.
     */
    func gridItemWidth(forContentWidth contentWidth: CGFloat, itemsPerRow: Int) -> CGFloat {
        let spacing = style.interitemSpacing
        return max(1, floor((contentWidth - spacing * CGFloat(itemsPerRow - 1)) / CGFloat(itemsPerRow)))
    }

    /**
     * Items per row, computed in a single pass.
     */
    func rows(forWidths widths: [[CGFloat]], contentWidth: CGFloat) -> [[Int]] {
        let spacing = style.interitemSpacing
        return widths.map { sectionWidths in
            var sectionRows: [Int] = []
            var used: CGFloat = 0
            var count = 0
            for width in sectionWidths {
                if count > 0 && used + spacing + width > contentWidth {
                    sectionRows.append(count)
                    used = 0
                    count = 0
                }
                used += (count > 0 ? spacing : 0) + width
                count += 1
            }
            if count > 0 {
                sectionRows.append(count)
            }
            return sectionRows
        }
    }

    func measureIfNeeded() {
        let width = collectionView.bounds.width
        guard width != measuredWidth else {
            return
        }
        measuredWidth = width
        let available = contentWidth(forWidth: width)
        itemWidths = widths(forContentWidth: available)
        itemHeights = measureItemHeights(widths: itemWidths)
        rows = rows(forWidths: itemWidths, contentWidth: available)
        contentHeightNeedsUpdate = true
        setNeedsLayout()
    }

    func invalidateMeasurements() {
        measuredWidth = -1
        reloadLayout()
    }

    func reloadLayout() {
        measureIfNeeded()
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        setNeedsLayout()
        updateContentHeight()
    }

    func updateContentHeight() {
        contentHeightNeedsUpdate = false
        var height: CGFloat
        if collectionView.bounds.width > 0 {
            collectionView.layoutIfNeeded()
            // Explicit insets only: safe-area adjustments belong to the host's layout.
            // The keyboard's inset is not content: it would change the list's height while typing.
            height = ceil(collectionView.collectionViewLayout.collectionViewContentSize.height
                          + collectionView.contentInset.top + collectionView.contentInset.bottom - keyboardInset)
                + titleHeight(forWidth: bounds.width)
        } else {
            height = heightThatFitsWidth(0)
        }
        guard abs(height - contentHeight) >= 0.5 else {
            return
        }
        contentHeight = height
        invalidateIntrinsicContentSize()
        menuDelegate?.menu?(self, didChangeContentHeight: height)
    }
}

// MARK: - Folding and selection

private extension CYLTagListView {

    func canFold(rowCount: Int) -> Bool {
        // Editing shows every item, so each one can be deleted or dragged.
        guard !isEditing else {
            return false
        }
        let folds = foldStyle == .truncate || foldControl.position != .none
        return folds && defaultVisibleRows > 0 && rowCount > defaultVisibleRows
    }

    func performUpdate(_ update: @escaping () -> Void, animated: Bool) {
        if animated {
            collectionView.performBatchUpdates(update, completion: nil)
        } else {
            UIView.performWithoutAnimation {
                collectionView.performBatchUpdates(update, completion: nil)
                collectionView.layoutIfNeeded()
            }
        }
    }

    /**
     * The inline fold cell moves with the items: reload the section (the chevron turns in its new place).
     */
    func setInlineExpanded(_ expanded: Bool, forSection section: Int, animated: Bool) {
        if expanded {
            expandedSections.insert(section)
        } else {
            expandedSections.remove(section)
        }
        let animate = animated && window != nil && !UIAccessibility.isReduceMotionEnabled
        performUpdate({ self.collectionView.reloadSections(IndexSet(integer: section)) }, animated: animate)
        updateContentHeight()
        moveAccessibilityFocusToFoldControl(inSection: section)
        menuDelegate?.menu?(self, didChangeExpanded: expanded, inSection: section)
    }

    /**
     * VoiceOver keeps its place after the section changes size: focus the section's fold control.
     */
    func moveAccessibilityFocusToFoldControl(inSection section: Int) {
        guard UIAccessibility.isVoiceOverRunning else {
            return
        }
        collectionView.layoutIfNeeded()
        UIAccessibility.post(notification: .layoutChanged, argument: foldControlView(inSection: section))
    }

    func footer(inSection section: Int) -> CYLTagListFooterView? {
        collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter,
                                         at: IndexPath(item: 0, section: section)) as? CYLTagListFooterView
    }

    func header(inSection section: Int) -> CYLTagListHeaderView? {
        collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader,
                                         at: IndexPath(item: 0, section: section)) as? CYLTagListHeaderView
    }

    /**
     * Updates the visible fold controls of a section without reloading it.
     */
    func updateFoldControls(inSection section: Int, animated: Bool) {
        let expanded = isSectionExpanded(section)
        if let footer = footer(inSection: section) {
            configureFoldButton(footer.foldButton, section: section, expanded: expanded, animated: animated)
            footer.foldSize = foldSize(expanded: expanded)
            footer.setNeedsLayout()
        }
        if let header = header(inSection: section), !header.foldButton.isHidden {
            configureFoldButton(header.foldButton, section: section, expanded: expanded, animated: animated)
            header.foldSize = foldSize(expanded: expanded)
            header.setNeedsLayout()
        }
    }

    /**
     * Shows the fold control in a state, with its VoiceOver label ("<section> 更多/收起") and hint.
     */
    func configureFoldButton(_ button: CYLTagFoldButton, section: Int, expanded: Bool, animated: Bool) {
        button.applyFoldControl(displayedFoldControl, color: style.resolvedFoldControlColor(inHeader: foldControlIsInHeader), expanded: expanded,
                                animated: animated)
        button.accessibilityLabel = foldAccessibilityLabel(forSection: section)
        button.accessibilityHint = expanded ? nil : CYLMenuLocalizedString("CYLMenuExpandHint")
    }

    func foldControlView(inSection section: Int) -> UIView? {
        if showsInlineFoldCell(inSection: section) {
            let foldPath = IndexPath(item: numberOfVisibleItems(inSection: section), section: section)
            return collectionView.cellForItem(at: foldPath)
        }
        if foldControlIsInFooter {
            return footer(inSection: section)?.foldButton
        }
        if foldControlIsInHeader, let header = header(inSection: section), !header.foldButton.isHidden {
            return header.foldButton
        }
        return nil
    }

    /**
     * "<section title> <expand or collapse title>", so a fold control says which section it changes.
     */
    func foldAccessibilityLabel(forSection section: Int) -> String {
        let titled = foldControl.position != .none
        let action: String
        if isSectionExpanded(section) {
            action = titled ? foldControl.collapseTitle : style.collapseTitle
        } else {
            action = titled ? foldControl.title : style.expandTitle
        }
        let title = menuDataSource?.menuTitle(forSection: section) ?? ""
        return title.isEmpty ? action : "\(title) \(action)"
    }

    func toggleSection(_ section: Int) {
        setExpanded(!isSectionExpanded(section), forSection: section, animated: true)
    }

    /**
     * Adds `indexPath` and removes the items that the selection mode excludes; returns the removed ones.
     */
    @discardableResult
    func applySelection(of indexPath: IndexPath) -> [IndexPath] {
        let exclusive = isExclusive(at: indexPath)
        var removed: [IndexPath] = []
        for other in selection where other.section == indexPath.section && other != indexPath {
            if selectionMode == .single || exclusive || isExclusive(at: other) {
                removed.append(other)
            }
        }
        selection.subtract(removed)
        selection.insert(indexPath)
        return removed
    }

    func selectedCount(inSection section: Int) -> Int {
        selection.filter { $0.section == section }.count
    }

    func handleTap(at indexPath: IndexPath) {
        dismissCallout()
        guard isEnabled(at: indexPath) else {
            return
        }
        let delegate = menuDelegate
        if delegate?.menu?(self, shouldSelectItemAt: indexPath) == false {
            return
        }
        if itemType(at: indexPath) == .create,
           let delegate, delegate.responds(to: #selector(CYLMenuDelegate.menu(_:didRequestNewItemWithName:at:))) {
            let name = menuDataSource?.menuTitleForItem(at: indexPath) ?? ""
            delegate.menu?(self, didRequestNewItemWithName: name, at: indexPath)
            return
        }
        var removed: [IndexPath] = []
        var selected = false
        let selectable = isSelectable(at: indexPath)
        switch selectable ? selectionMode : .none {
        case .none:
            selected = true
        case .single, .multiple:
            if selection.contains(indexPath) {
                if allowsEmptySelection || selectedCount(inSection: indexPath.section) > 1 {
                    selection.remove(indexPath)
                    removed.append(indexPath)
                }
            } else {
                removed = applySelection(of: indexPath)
                selected = true
            }
        }
        refreshVisibleCells()
        if selected {
            // A tapped tag plays its animated icon, as a tapped tab does.
            (collectionView.cellForItem(at: indexPath) as? CYLTagListCell)?.button.playAnimation()
        }
        for path in removed {
            delegate?.menu?(self, didDeselectItemAt: path)
        }
        if selected {
            delegate?.menu?(self, didSelectItemAt: indexPath)
        }
        if !removed.isEmpty || (selected && selectable && selectionMode != .none) {
            delegate?.menu?(self, didChangeSelectedItems: selectedIndexPaths)
        }
        if let tag = tag(at: indexPath) {
            tagClickHandler?(indexPath.item, tag)
            objcTagClickHandlerStorage?(indexPath.item, tag.title)
        }
    }

    /**
     * Moves selected items of a section at or after `item` by `offset`.
     */
    func shiftSelection(inSection section: Int, fromItem item: Int, by offset: Int) {
        selection = Set(selection.map { indexPath in
            indexPath.section == section && indexPath.item >= item
                ? IndexPath(item: indexPath.item + offset, section: section) : indexPath
        })
    }

    /**
     * An item was removed: it leaves the selection and the items after it move up.
     */
    func removeSelection(at indexPath: IndexPath) {
        selection.remove(indexPath)
        shiftSelection(inSection: indexPath.section, fromItem: indexPath.item + 1, by: -1)
    }
}

// MARK: - Cells

private extension CYLTagListView {

    func forEachVisibleTagButton(_ body: (CYLTagButton) -> Void) {
        for case let cell as CYLTagListCell in collectionView.visibleCells {
            body(cell.button)
        }
    }

    @objc func refreshVisibleCells() {
        for indexPath in collectionView.indexPathsForVisibleItems {
            if let cell = collectionView.cellForItem(at: indexPath) {
                configure(cell, at: indexPath)
            }
        }
    }

    func configureFoldCell(_ cell: CYLTagFoldCell, section: Int, animated: Bool) {
        let expanded = isSectionExpanded(section)
        cell.configure(foldControl: displayedFoldControl, itemStyle: style(forSection: section), expanded: expanded,
                       animated: animated)
        cell.accessibilityLabel = foldAccessibilityLabel(forSection: section)
        cell.accessibilityHint = expanded ? nil : CYLMenuLocalizedString("CYLMenuExpandHint")
    }

    func configure(_ cell: UICollectionViewCell, at indexPath: IndexPath) {
        if let foldCell = cell as? CYLTagFoldCell {
            configureFoldCell(foldCell, section: indexPath.section, animated: false)
            return
        }
        guard isValid(indexPath), let cell = cell as? CYLTagListCell else {
            return
        }
        if let createCell = cell as? CYLTagCreateCell {
            createCell.configure(name: menuDataSource?.menuTitleForItem(at: indexPath), style: style(forItemAt: indexPath),
                                 isEnabled: isEnabled(at: indexPath))
            return
        }
        let enabled = isEnabled(at: indexPath)
        cell.configure(title: titles[indexPath.section][indexPath.item], image: image(at: indexPath),
                       selectedImage: selectedImage(at: indexPath), animationURL: animationURL(at: indexPath),
                       style: style(forItemAt: indexPath), isSelected: selection.contains(indexPath), isEnabled: enabled)
        cell.button.animationRestingProgress = animationRestingProgress(at: indexPath)
        cell.button.cylApplyListAnimationSpeed(animationSpeed)
        cell.button.animationLoops = animationLoops
        let deletable = isDeletable(at: indexPath) && enabled
        cell.isDeletable = deletable
        cell.deleteHandler = deletable ? { [weak self] in
            self?.deleteItem(at: indexPath)
        } : nil
        let renamable = deletable && isRenamable(at: indexPath)
        cell.isRenamable = renamable
        cell.renamesOnTitleTap = renamable && renamesOnTitleTapWhileEditing
        cell.renameHandler = renamable ? { [weak self] in
            self?.beginRenaming(at: indexPath)
        } : nil
        cell.additionalAccessibilityActions = accessibilityActions(forItemAt: indexPath)
        if let source = menuDataSource,
           source.responds(to: #selector(CYLMenuDataSource.menuAccessibilityHintForItem(at:))) {
            cell.accessibilityHint = source.menuAccessibilityHintForItem?(at: indexPath)
        }
        // A screen-reader user rarely long-presses: the subtitle is the hint when the data source gives none.
        if cell.accessibilityHint == nil {
            cell.accessibilityHint = subtitleForItem(at: indexPath)
        }
    }

    /**
     * What VoiceOver, Voice Control and Switch Control users pick instead of a long press or a drag.
     */
    func accessibilityActions(forItemAt indexPath: IndexPath) -> [UIAccessibilityCustomAction] {
        var actions: [UIAccessibilityCustomAction] = []
        if canMoveItem(at: indexPath) {
            let count = numberOfVisibleItems(inSection: indexPath.section)
            if indexPath.item > 0 {
                actions.append(UIAccessibilityCustomAction(name: CYLMenuLocalizedString("CYLMenuMoveTagEarlier")) { [weak self] _ in
                    self?.accessibilityMoveItem(at: indexPath, by: -1) ?? false
                })
            }
            if indexPath.item + 1 < count {
                actions.append(UIAccessibilityCustomAction(name: CYLMenuLocalizedString("CYLMenuMoveTagLater")) { [weak self] _ in
                    self?.accessibilityMoveItem(at: indexPath, by: 1) ?? false
                })
            }
        }
        let reportsLongPress = menuDelegate?.responds(to: #selector(CYLMenuDelegate.menu(_:didLongPressItemAt:))) == true
            || (tagLongPressHandler != nil && tag(at: indexPath) != nil)
        if reportsLongPress {
            let custom = longPressAccessibilityActionName ?? ""
            let name = custom.isEmpty ? CYLMenuLocalizedString("CYLMenuLongPress") : custom
            actions.append(UIAccessibilityCustomAction(name: name) { [weak self] _ in
                self?.reportLongPress(at: indexPath)
                return true
            })
        }
        return actions
    }

    /**
     * 前移 / 后移: the same move as a drag, then the new position is announced.
     */
    func accessibilityMoveItem(at indexPath: IndexPath, by offset: Int) -> Bool {
        let target = indexPath.item + offset
        guard canReorder, target >= 0, target < numberOfVisibleItems(inSection: indexPath.section) else {
            return false
        }
        let destination = IndexPath(item: target, section: indexPath.section)
        if selection.contains(indexPath) {
            reportSelectedDrag(at: indexPath)
        }
        collectionView.moveItem(at: indexPath, to: destination)
        collectionView(collectionView, moveItemAt: indexPath, to: destination)
        let announcement = String(format: CYLMenuLocalizedString("CYLMenuTagMoved"), target + 1)
        // After the move has been laid out.
        DispatchQueue.main.async {
            UIAccessibility.post(notification: .layoutChanged, argument: self.collectionView.cellForItem(at: destination))
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
        return true
    }
}

// MARK: - Reordering

private extension CYLTagListView {

    var canReorder: Bool {
        (allowsReordering || isEditing)
            && menuDataSource?.responds(to: #selector(CYLMenuDataSource.menuMoveItem(at:to:))) == true
    }

    func canMoveItem(at indexPath: IndexPath) -> Bool {
        canReorder && isValid(indexPath) && !isInlineFoldCell(at: indexPath)
            && (allowsReordering || sectionAllowsEditing(indexPath.section)) && itemType(at: indexPath) != .create
    }

    /**
     * Reorders on a long press and a move; a long press that does not move is reported (onTagLongClick).
     */
    @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: collectionView)
        switch recognizer.state {
        case .began:
            guard let indexPath = collectionView.indexPathForItem(at: point), isValid(indexPath),
                  !isInlineFoldCell(at: indexPath) else {
                pressedIndexPath = nil
                return
            }
            pressedIndexPath = indexPath
            pressMoved = false
            pressStart = point
            dismissCallout()
            // The long-press action decides what this does (reordering picks the item up through beginReordering).
            let action = longPressAction
            if !action.canBegin(host: self, at: indexPath) || !action.begin(host: self, at: indexPath) {
                pressedIndexPath = nil
            }
        case .changed:
            if isReordering {
                if hypot(point.x - pressStart.x, point.y - pressStart.y) > Self.dragThreshold {
                    pressMoved = true
                }
                collectionView.updateInteractiveMovementTargetPosition(point)
            }
        case .ended:
            longPressAction.end(host: self, destination: collectionView.indexPathForItem(at: point), moved: pressMoved)
            pressedIndexPath = nil
        default:
            longPressAction.cancel(host: self)
            pressedIndexPath = nil
        }
    }

    public func reportLongPress(at indexPath: IndexPath) {
        menuDelegate?.menu?(self, didLongPressItemAt: indexPath)
        if let tag = tag(at: indexPath) {
            tagLongPressHandler?(indexPath.item, tag)
        }
    }

    func reportSelectedDrag(at indexPath: IndexPath) {
        menuDelegate?.menu?(self, didBeginDraggingSelectedItemAt: indexPath)
        if let tag = tag(at: indexPath) {
            selectedTagDragHandler?(indexPath.item, tag)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension CYLTagListView: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        titles.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // The inline fold cell follows the visible items.
        numberOfVisibleItems(inSection: section) + (showsInlineFoldCell(inSection: section) ? 1 : 0)
    }

    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isInlineFoldCell(at: indexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier.foldCell, for: indexPath)
            if let foldCell = cell as? CYLTagFoldCell {
                configureFoldCell(foldCell, section: indexPath.section, animated: false)
            }
            return cell
        }
        let identifier = itemType(at: indexPath) == .create ? ReuseIdentifier.createCell : ReuseIdentifier.cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        configure(cell, at: indexPath)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
        let section = indexPath.section
        if kind == UICollectionView.elementKindSectionFooter {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: ReuseIdentifier.footer,
                                                                       for: indexPath)
            if let footer = view as? CYLTagListFooterView {
                footer.section = section
                let expanded = isSectionExpanded(section)
                configureFoldButton(footer.foldButton, section: section, expanded: expanded, animated: false)
                footer.foldSize = foldSize(expanded: expanded)
                footer.setNeedsLayout()
                footer.foldHandler = { [weak self] tappedSection in
                    self?.toggleSection(tappedSection)
                }
            }
            return view
        }
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: ReuseIdentifier.header,
                                                                   for: indexPath)
        if let header = view as? CYLTagListHeaderView {
            configureHeader(header, section: section)
        }
        return view
    }

    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        canMoveItem(at: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath,
                               to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath, canReorder else {
            movingItem = nil
            return
        }
        menuDataSource?.menuMoveItem?(at: sourceIndexPath, to: destinationIndexPath)
        // The selection moves with the items.
        let from = sourceIndexPath.item
        let to = destinationIndexPath.item
        selection = Set(selection.map { indexPath in
            guard indexPath.section == sourceIndexPath.section else {
                return indexPath
            }
            var item = indexPath.item
            if item == from {
                item = to
            } else if from < to && item > from && item <= to {
                item -= 1
            } else if from > to && item >= to && item < from {
                item += 1
            }
            return IndexPath(item: item, section: indexPath.section)
        })
        menuDelegate?.menu?(self, didMoveItemAt: sourceIndexPath, to: destinationIndexPath)
        // The new order survives a relaunch when the list has a cache.
        saveEditableSectionsToCache()
        if let tagMoveHandler, let source = tagDataSourceStorage, menuDataSource === source {
            tagMoveHandler(from, to)
        }
        // The collection view has moved the cell; the measurements follow on the next pass.
        DispatchQueue.main.async {
            self.movingItem = nil
            self.reloadMenuData()
        }
    }

    /**
     * The index path whose measurement belongs at `indexPath`. While a tag is dragged (and until the measurements follow
     * the move), the collection view shows the items in the new order but the widths are still in the old one: without
     * this, every slot kept the width of the tag that was there before and the moved titles were cut ("Kot…").
     */
    func measuredIndexPath(for indexPath: IndexPath) -> IndexPath {
        guard let moving = movingItem, indexPath.section == moving.section, moving.from != moving.to else {
            return indexPath
        }
        var item = indexPath.item
        if item == moving.to {
            item = moving.from
        } else if moving.from < moving.to && item >= moving.from && item < moving.to {
            item += 1
        } else if moving.to < moving.from && item > moving.to && item <= moving.from {
            item -= 1
        }
        return IndexPath(item: item, section: indexPath.section)
    }

    /**
     * The look of a section's icon and title: the style's header font and color, a 16 pt icon 8 pt before the title,
     * at the leading edge.
     */
    private func headerTitleStyle() -> CYLMenuStyle {
        let titleStyle = CYLMenuStyle.sectionTitle(textColor: style.resolvedHeaderTextColor)
        for state in [UIControl.State.normal, .selected, .disabled] {
            titleStyle.appearance(for: state).font = style.headerFont
        }
        titleStyle.adjustsFontForContentSizeCategory = style.adjustsFontForContentSizeCategory
        titleStyle.imageSize = CGSize(width: CYLTagListHeaderView.iconSize, height: CYLTagListHeaderView.iconSize)
        titleStyle.imageTitleSpacing = 8
        return titleStyle
    }

    private func configureHeader(_ header: CYLTagListHeaderView, section: Int) {
        let source = menuDataSource
        header.section = section
        configureHeaderSectionStyle(header)
        header.indicatorView.isHidden = style.headerIndicatorColor == nil
        header.indicatorView.backgroundColor = style.headerIndicatorColor
        header.indicatorSize = style.headerIndicatorSize
        header.titleButton.style = headerTitleStyle()
        header.titleButton.title = source?.menuTitle(forSection: section)
        header.titleButton.image = source?.menuImage?(forSection: section)
        header.accessoryView = source?.menuAccessoryView?(forSection: section)
        let showsFoldButton = foldControlIsInHeader && canFoldSection(section)
        header.foldButton.isHidden = !showsFoldButton
        header.foldAtLeadingEdge = foldControl.position == .headerLeading
        if showsFoldButton {
            let expanded = isSectionExpanded(section)
            configureFoldButton(header.foldButton, section: section, expanded: expanded, animated: false)
            header.foldSize = foldSize(expanded: expanded)
        }
        // Section titles hidden: the header only holds the fold control.
        header.titleButton.isHidden = !showsSectionHeaders
        header.foldHandler = { [weak self] tappedSection in
            self?.toggleSection(tappedSection)
        }
        // The clear button: the bundle's trash icon (or the style's image), the host's action.
        let showsClear = source?.menuShowsClearButton?(forSection: section) == true
        header.clearButton.isHidden = !showsClear
        if showsClear {
            // A vector by default (an SF Symbol: sharp at every scale, a template tinted with the one dynamic color); the bundled raster is the fallback.
            let image = style.clearButtonImage ?? UIImage(systemName: "trash") ?? CYLMenuResources.image(named: "cyl_trash")
            header.clearButton.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
            header.clearButton.tintColor = style.clearButtonColor ?? style.resolvedHeaderTextColor
            let title = source?.menuTitle(forSection: section) ?? ""
            let clear = CYLMenuLocalizedString("CYLMenuClearSection")
            header.clearButton.accessibilityLabel = title.isEmpty ? clear : "\(clear) \(title)"
            header.clearButton.largeContentTitle = header.clearButton.accessibilityLabel
            header.clearHandler = { [weak self] tappedSection in
                guard let self else {
                    return
                }
                self.menuDelegate?.menu?(self, didTapClearButtonInSection: tappedSection)
                self.clearButtonHandler?(tappedSection)
            }
        }
        // The More button: the bundle's three dots (or the style's image), the host's action.
        let showsMore = showsMoreButton(inSection: section)
        header.moreButton.isHidden = !showsMore
        if showsMore {
            let image = style.moreButtonImage ?? UIImage(systemName: "ellipsis") ?? CYLMenuResources.image(named: "cyl_more")
            header.moreButton.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
            header.moreButton.tintColor = style.resolvedMoreButtonColor
            var label = source?.menuAccessibilityLabelForMoreButton?(inSection: section) ?? ""
            if label.isEmpty {
                let title = source?.menuTitle(forSection: section) ?? ""
                let more = CYLMenuLocalizedString("CYLMenuMoreActions")
                label = title.isEmpty ? more : "\(title) \(more)"
            }
            header.moreButton.accessibilityLabel = label
            header.moreButton.largeContentTitle = label
            header.moreHandler = { [weak self] tappedSection in
                guard let self else {
                    return
                }
                self.menuDelegate?.menu?(self, didTapMoreButtonInSection: tappedSection)
            }
        }
        header.setNeedsLayout()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CYLTagListView: UICollectionViewDelegateFlowLayout {

    /// A scroll hides the long-press callout.
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissCallout()
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if isInlineFoldCell(at: indexPath) {
            // The inline fold cell's built-in action.
            toggleSection(indexPath.section)
            return
        }
        if allowsTapping {
            handleTap(at: indexPath)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        allowsTapping || isInlineFoldCell(at: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView,
                               targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath,
                               atCurrentIndexPath currentIndexPath: IndexPath,
                               toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        // Within its section, among the shown items (not onto the inline fold cell).
        let last = max(0, numberOfVisibleItems(inSection: originalIndexPath.section) - 1)
        let item: Int
        if proposedIndexPath.section == originalIndexPath.section {
            item = min(proposedIndexPath.item, last)
        } else {
            item = proposedIndexPath.section < originalIndexPath.section ? 0 : last
        }
        // The layout now asks for the sizes in the order being shown (see `measuredIndexPath(for:)`).
        movingItem = (originalIndexPath.section, originalIndexPath.item, item)
        return IndexPath(item: item, section: originalIndexPath.section)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        measureIfNeeded()
        if isInlineFoldCell(at: indexPath) {
            return inlineFoldSize(inSection: indexPath.section, expanded: isSectionExpanded(indexPath.section))
        }
        let indexPath = measuredIndexPath(for: indexPath)
        var width: CGFloat = 0
        if itemWidths.indices.contains(indexPath.section),
           itemWidths[indexPath.section].indices.contains(indexPath.item) {
            width = itemWidths[indexPath.section][indexPath.item]
        }
        var height = itemHeight
        if itemHeights.indices.contains(indexPath.section),
           itemHeights[indexPath.section].indices.contains(indexPath.item) {
            height = itemHeights[indexPath.section][indexPath.item]
        }
        return CGSize(width: max(1, width), height: height)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        tagInsets(atWidth: collectionView.bounds.width)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        style.interitemSpacing
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        style.lineSpacing
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height = headerHeight()
        return height > 0 ? CGSize(width: collectionView.bounds.width, height: height) : .zero
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForFooterInSection section: Int) -> CGSize {
        let showsControl = foldControlIsInFooter && canFoldSection(section)
        return showsControl ? CGSize(width: collectionView.bounds.width, height: footerHeight) : .zero
    }
}

extension CYLTagButton {

    /**
     * The list's `animationSpeed`: a speed sets the tag's own, `nil` lets it follow its style again.
     */
    func cylApplyListAnimationSpeed(_ speed: CGFloat?) {
        if let speed {
            animationSpeed = speed
        } else {
            resetAnimationSpeed()
        }
    }
}

// MARK: - Editing: the add control

private extension CYLTagListView {

    /// The first section that takes part in editing, if any.
    var firstEditableSection: Int? {
        titles.indices.first { sectionAllowsEditing($0) }
    }

    /// Shows or hides `addItemView` and reserves its space below the last section.
    func updateAddItemView() {
        // Renaming needs the field even when the add control is hidden, unless the host's editor takes it.
        let shows = isEditing && (showsAddItemViewWhileEditing || (renamingIndexPath != nil && renameRequestHandler == nil))
        if shows && addItemView.superview !== collectionView {
            collectionView.addSubview(addItemView)
        } else if !shows {
            addItemView.removeFromSuperview()
        }
        let inset = shows ? addItemView.preferredHeight + style.sectionInsets.bottom : 0
        if inset != addItemInset {
            collectionView.contentInset.bottom += inset - addItemInset
            addItemInset = inset
        }
        setNeedsLayout()
        contentHeightNeedsUpdate = true
    }

    /// Places `addItemView` right below the sections, inside the collection view (it scrolls with the items).
    func layoutAddItemView() {
        guard addItemView.superview === collectionView else {
            return
        }
        let insets = style.sectionInsets
        let top = collectionView.collectionViewLayout.collectionViewContentSize.height
        addItemView.frame = CGRect(x: insets.left, y: top, width: max(0, collectionView.bounds.width - insets.left - insets.right),
                                   height: addItemView.preferredHeight)
    }

    /// A name submitted in `addItemView`: a rename while one is in progress, else a new item at the end of the first
    /// editable section.
    func requestNewItem(named name: String) {
        if renamingIndexPath != nil {
            finishRenaming(to: name)
            return
        }
        let section = firstEditableSection ?? 0
        let item = titles.indices.contains(section) ? titles[section].count : 0
        menuDelegate?.menu?(self, didRequestNewItemWithName: name, at: IndexPath(item: item, section: section))
        saveEditableSectionsToCache()
    }
}

// MARK: - Network sync

extension CYLTagListView {

    /**
     * Reads the sections saved under `keys` from the cache and `remoteSource`, in the order of `loadPolicy`, and calls
     * `completion` on the main queue with the titles by key and where they come from: once or twice
     * (`.cacheThenNetwork`: the cache at once, then the server). Downloaded sections are saved to the cache first.
     * Without a remote source it reads the cache only; nothing saved anywhere calls nothing.
     */
    @objc(loadSectionsWithKeys:completion:)
    open func loadSections(withKeys keys: [String], completion: @escaping ([String: [String]], CYLTagListDataOrigin) -> Void) {
        var cached: [String: [String]] = [:]
        for key in keys {
            if let titles = cache?.cachedTitles(forSection: key) {
                cached[key] = titles
            }
        }
        let fetch: (@escaping (Bool) -> Void) -> Void = { [weak self] done in
            guard let remote = self?.remoteSource else {
                done(false)
                return
            }
            remote.fetchSections(withKeys: keys) { sections, error in
                DispatchQueue.main.async {
                    guard let self, let sections, error == nil else {
                        done(false)
                        return
                    }
                    let downloaded = sections.filter { keys.contains($0.key) }
                    for (key, titles) in downloaded {
                        self.cache?.saveTitles(titles, forSection: key)
                    }
                    completion(downloaded, .network)
                    done(true)
                }
            }
        }
        switch loadPolicy {
        case .cacheThenNetwork:
            if !cached.isEmpty {
                completion(cached, .cache)
            }
            fetch { _ in }
        case .cacheFirst:
            if cached.count == keys.count {
                completion(cached, .cache)
            } else {
                fetch { ok in
                    if !ok && !cached.isEmpty {
                        completion(cached, .cache)
                    }
                }
            }
        case .networkFirst:
            fetch { ok in
                if !ok && !cached.isEmpty {
                    completion(cached, .cache)
                }
            }
        }
    }

    /**
     * `loadSections(withKeys:completion:)` with identifiers: the cache's items (`cachedItems(forSection:)`) and the
     * remote source's (`fetchItems(withKeys:completion:)`, else its titles, each its own identifier), in the order of
     * `loadPolicy`; downloaded items are saved to the cache first.
     */
    @objc(loadItemsWithKeys:completion:)
    open func loadItems(withKeys keys: [String],
                        completion: @escaping ([String: [CYLTagListCacheItem]], CYLTagListDataOrigin) -> Void) {
        var cached: [String: [CYLTagListCacheItem]] = [:]
        for key in keys {
            if let items = cache?.cachedItems?(forSection: key)
                ?? cache?.cachedTitles(forSection: key)?.map({ CYLTagListCacheItem(identifier: $0, title: $0) }) {
                cached[key] = items
            }
        }
        let fetch: (@escaping (Bool) -> Void) -> Void = { [weak self] done in
            guard let remote = self?.remoteSource else {
                done(false)
                return
            }
            let finish: ([String: [CYLTagListCacheItem]]?, Error?) -> Void = { items, error in
                DispatchQueue.main.async {
                    guard let self, let items, error == nil else {
                        done(false)
                        return
                    }
                    let downloaded = items.filter { keys.contains($0.key) }
                    for (key, sectionItems) in downloaded {
                        if self.cache?.saveItems?(sectionItems, forSection: key) == nil {
                            self.cache?.saveTitles(sectionItems.map(\.title), forSection: key)
                        }
                    }
                    completion(downloaded, .network)
                    done(true)
                }
            }
            if remote.responds(to: #selector(CYLTagListRemoteSource.fetchItems(withKeys:completion:))) {
                remote.fetchItems?(withKeys: keys, completion: finish)
            } else {
                remote.fetchSections(withKeys: keys) { sections, error in
                    finish(sections?.mapValues { $0.map { CYLTagListCacheItem(identifier: $0, title: $0) } }, error)
                }
            }
        }
        switch loadPolicy {
        case .cacheThenNetwork:
            if !cached.isEmpty {
                completion(cached, .cache)
            }
            fetch { _ in }
        case .cacheFirst:
            if cached.count == keys.count {
                completion(cached, .cache)
            } else {
                fetch { ok in
                    if !ok && !cached.isEmpty {
                        completion(cached, .cache)
                    }
                }
            }
        case .networkFirst:
            fetch { ok in
                if !ok && !cached.isEmpty {
                    completion(cached, .cache)
                }
            }
        }
    }
}

// MARK: - Editing: the keyboard

extension CYLTagListView {

    /// The keyboard moved: the list's bottom inset takes the part it covers, and an active add or rename field scrolls
    /// above it.
    @objc private func keyboardFrameChanged(_ notification: Notification) {
        guard isEditing, let window else {
            return
        }
        var overlap: CGFloat = 0
        if notification.name != UIResponder.keyboardWillHideNotification,
           let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboard = collectionView.convert(window.convert(frame, from: window.screen.coordinateSpace), from: window)
            let visibleBottom = collectionView.bounds.maxY
            overlap = max(0, visibleBottom - keyboard.minY)
        }
        setKeyboardInset(overlap)
        if overlap > 0, addItemView.textField.isFirstResponder {
            collectionView.layoutIfNeeded()
            collectionView.scrollRectToVisible(addItemView.frame.insetBy(dx: 0, dy: -8), animated: true)
        }
    }

    fileprivate func setKeyboardInset(_ inset: CGFloat) {
        guard inset != keyboardInset else {
            return
        }
        collectionView.contentInset.bottom += inset - keyboardInset
        collectionView.verticalScrollIndicatorInsets.bottom = collectionView.contentInset.bottom
        keyboardInset = inset
    }
}

/**
 * A section header's clear button: drawn as tall as the title's line, tapped in a 44 point area around it.
 */
final class CYLTagListClearButton: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let dx = min(0, (bounds.width - 44) / 2)
        let dy = min(0, (bounds.height - 44) / 2)
        return bounds.insetBy(dx: dx, dy: dy).contains(point)
    }
}

// MARK: - Smear selection and the word picker

extension CYLTagListView {

    /**
     * Replaces the tags with one tag per character of `text`, in order: each grapheme (a letter, a Chinese character, an
     * emoji, a space) is one tag, as the word picker's cells (`CYLMenuStyle.wordPicker()`). Unlike the first
     * `setTags(withTitles:)`, it keeps `selectionMode` (a word picker selects several cells).
     */
    @objc(setTagsWithCharactersOfText:)
    open func setTags(withCharactersOf text: String) {
        let mode = selectionMode
        setTags(withTitles: text.map(String.init))
        selectionMode = mode
    }

    /**
     * The titles of the selected items joined in item order: the picked text (for a word picker, the characters the user
     * smeared, as they stand in the text).
     */
    @objc open var selectedText: String {
        selectedTitles.joined()
    }

    /**
     * Selects every selectable item from `start` through `end` (either order), in item order across sections, as a smear
     * over them does, without calling the delegate. Needs `selectionMode == .multiple`.
     */
    @objc(selectItemsFromIndexPath:throughIndexPath:)
    open func selectItems(from start: IndexPath, through end: IndexPath) {
        guard selectionMode == .multiple, isValid(start), isValid(end) else {
            return
        }
        selection = smearedSelection(from: selection, anchor: start, to: end, selects: true)
        refreshVisibleCells()
    }

    /**
     * Every item, in order across sections (the order a smear follows).
     */
    func itemIndexPathsInOrder() -> [IndexPath] {
        titles.enumerated().flatMap { section, items in items.indices.map { IndexPath(item: $0, section: section) } }
    }

    /**
     * `base` with the items from `anchor` to `end` (in item order) selected, or deselected when `selects` is false.
     */
    func smearedSelection(from base: Set<IndexPath>, anchor: IndexPath, to end: IndexPath, selects: Bool) -> Set<IndexPath> {
        let order = itemIndexPathsInOrder()
        guard let a = order.firstIndex(of: anchor), let b = order.firstIndex(of: end) else {
            return base
        }
        var result = base
        for indexPath in order[min(a, b)...max(a, b)] where isSelectable(at: indexPath) && itemType(at: indexPath) != .create {
            if selects {
                result.insert(indexPath)
            } else {
                result.remove(indexPath)
            }
        }
        return result
    }

    /**
     * The item a smear can start on or reach at `point` (in the collection view): a selectable tag, not the fold cell or
     * the "new tag" cell.
     */
    func smearableIndexPath(at point: CGPoint) -> IndexPath? {
        guard let indexPath = collectionView.indexPathForItem(at: point), isValid(indexPath),
              !isInlineFoldCell(at: indexPath), itemType(at: indexPath) != .create, isSelectable(at: indexPath) else {
            return nil
        }
        return indexPath
    }

    /**
     * Whether a smear may begin at `point`: smear selection on, multiple selection, a tag under the finger.
     */
    func shouldBeginSmear(at point: CGPoint) -> Bool {
        allowsSmearSelection && selectionMode == .multiple && !isEditing
            && smearableIndexPath(at: smearTouchDown ?? point) != nil
    }

    @objc func handleSmear(_ recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: collectionView)
        switch recognizer.state {
        case .began:
            guard allowsSmearSelection, selectionMode == .multiple,
                  let indexPath = smearableIndexPath(at: smearTouchDown ?? point) else {
                smearStart = nil
                return
            }
            smearStart = (selection, indexPath, !selection.contains(indexPath))
            menuDelegate?.menu?(self, didChangeSmearing: true)
            applySmear(to: indexPath)
            // The finger may already be over a later item.
            if let current = smearableIndexPath(at: point) {
                applySmear(to: current)
            }
        case .changed:
            if let indexPath = smearableIndexPath(at: point) {
                applySmear(to: indexPath)
            }
        default:
            if smearStart != nil {
                smearStart = nil
                menuDelegate?.menu?(self, didChangeSmearing: false)
            }
            smearTouchDown = nil
        }
    }

    /**
     * The selection the smear began with, with the items from its first item to `indexPath` changed; the delegate hears
     * of every change.
     */
    private func applySmear(to indexPath: IndexPath) {
        guard let start = smearStart else {
            return
        }
        let smeared = smearedSelection(from: start.selection, anchor: start.anchor, to: indexPath, selects: start.selects)
        guard smeared != selection else {
            return
        }
        selection = smeared
        refreshVisibleCells()
        menuDelegate?.menu?(self, didChangeSelectedItems: selectedIndexPaths)
    }
}

/**
 * Lets the smear recognizer begin only on a tag (`CYLTagListView.allowsSmearSelection`), so that a drag elsewhere
 * scrolls.
 */
final class CYLTagListSmearGestureDelegate: NSObject, UIGestureRecognizerDelegate {

    weak var list: CYLTagListView?

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Remember where the finger touched down: the smear starts on that item.
        list?.smearTouchDown = gestureRecognizer.view.map { touch.location(in: $0) }
        return true
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let list, let view = gestureRecognizer.view else {
            return false
        }
        return list.shouldBeginSmear(at: gestureRecognizer.location(in: view))
    }
}

// MARK: - Window

/*
 * [EN] Outside the private extension: an override of an open UIView method stays open, and an access modifier inside a
 *      private extension conflicts with the extension's default access (pod lint warning).
 * [CN] 放在 private 扩展之外：重写 UIView 的 open 方法仍为 open；private 扩展中的访问修饰符与扩展的默认访问级别冲突（pod lint 警告）。
 */
extension CYLTagListView {

    /**
     * Removed from its window in the middle of a drag or a smear: the gesture is over, so the delegate hears `false` and a
     * host that locked its scroll view unlocks it.
     */
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window == nil else {
            return
        }
        dismissCallout()
        if isReordering {
            isReordering = false
            movingItem = nil
            pressedIndexPath = nil
            collectionView.cancelInteractiveMovement()
            menuDelegate?.menu?(self, didChangeReordering: false)
        }
        if smearStart != nil {
            smearStart = nil
            smearTouchDown = nil
            menuDelegate?.menu?(self, didChangeSmearing: false)
        }
    }
}

// MARK: - CYLTagLongPressHost

extension CYLTagListView: CYLTagLongPressHost {

    public func subtitleForItem(at indexPath: IndexPath) -> String? {
        guard let source = menuDataSource,
              source.responds(to: #selector(CYLMenuDataSource.menuSubtitleForItem(at:))) else {
            return nil
        }
        return source.menuSubtitleForItem?(at: indexPath) ?? nil
    }

    public func showCallout(_ text: String, at indexPath: IndexPath) {
        dismissCallout()
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        let callout = CYLTagCalloutView(text: text)
        // In the window, so a list that clips its content does not clip the bubble above its first row.
        let container: UIView = window ?? self
        callout.present(pointingAt: collectionView.convert(cell.frame, to: container), in: container)
        calloutView = callout
        // Added after the finger lifted: it never sees the press that opened the callout.
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissCalloutFromTap))
        tap.cancelsTouchesInView = false
        tap.delegate = calloutTapDelegate
        container.addGestureRecognizer(tap)
        calloutDismissTap = tap
    }

    public func dismissCallout() {
        calloutView?.removeFromSuperview()
        calloutView = nil
        if let tap = calloutDismissTap {
            tap.view?.removeGestureRecognizer(tap)
            calloutDismissTap = nil
        }
    }

    @objc private func dismissCalloutFromTap() {
        dismissCallout()
    }

    public func canReorderItem(at indexPath: IndexPath) -> Bool {
        canReorder
    }

    public func beginReordering(at indexPath: IndexPath) -> Bool {
        guard collectionView.beginInteractiveMovementForItem(at: indexPath) else {
            return false
        }
        isReordering = true
        menuDelegate?.menu?(self, didChangeReordering: true)
        if selection.contains(indexPath) {
            reportSelectedDrag(at: indexPath)
        }
        return true
    }

    public func endReordering(destination: IndexPath?, moved: Bool) {
        guard isReordering else {
            return
        }
        isReordering = false
        collectionView.endInteractiveMovement()
        menuDelegate?.menu?(self, didChangeReordering: false)
        if !moved, let pressedIndexPath {
            reportLongPress(at: pressedIndexPath)
        }
    }

    public func cancelReordering() {
        guard isReordering else {
            return
        }
        isReordering = false
        movingItem = nil
        collectionView.cancelInteractiveMovement()
        menuDelegate?.menu?(self, didChangeReordering: false)
    }
}
