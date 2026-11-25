//
//  CYLTagListSectionCard.swift
//  CollectionViewClassifyMenu
//
//  The section card of `CYLSectionStyle.insetGrouped`: a decoration view behind the section's tags, placed by the list's
//  layout from the tags' own frames (docs/tag-section-style.md).
//

import UIKit
// CYLAnimatedItemView draws the Liquid Glass (the module choice of CYLTagButton.swift, since Swift Package Manager does not see another
// file's imports).
#if canImport(CYLAnimatedItemViews)
import CYLAnimatedItem
import CYLAnimatedItemViews
#elseif canImport(CYLAnimatedItem)
import CYLAnimatedItem
#else
import CYLTabBarController
#endif

/**
 * What the layout needs to draw one section's card.
 */
struct CYLTagListCardSpec {

    /**
     * The section column: its x and width in the layout's coordinates (y and height are 0).
     */
    let column: CGRect

    /**
     * The padding between the card and the tags, top and bottom (left and right are inside `column`).
     */
    let padding: UIEdgeInsets
    /**
     * The flat card's color, as drawn where the glass is not.
     */
    let color: UIColor
    /**
     * The glass tint: `sectionBackgroundColor` when the app set it, else `nil` (an untinted, see-through glass).
     */
    let glassTint: UIColor?
    /**
     * Whether the card is Liquid Glass (`sectionBackgroundStyle`); flat where the system draws none.
     */
    let usesGlass: Bool
    let cornerRadius: CGFloat
}

/**
 * Layout attributes of a card: its color and corner radius travel with the frame.
 */
final class CYLTagListCardAttributes: UICollectionViewLayoutAttributes {

    var color: UIColor?
    var glassTint: UIColor?
    var usesGlass = false
    var cornerRadius: CGFloat = 0

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone)
        if let card = copy as? CYLTagListCardAttributes {
            card.color = color
            card.glassTint = glassTint
            card.usesGlass = usesGlass
            card.cornerRadius = cornerRadius
        }
        return copy
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CYLTagListCardAttributes else {
            return false
        }
        return super.isEqual(other) && other.color == color && other.glassTint == glassTint && other.usesGlass == usesGlass
            && other.cornerRadius == cornerRadius
    }
}

/**
 * A section card. Its colors are dynamic colors, resolved with this view's own traits, so a mode change updates a shown card. A glass
 * card is the library's Liquid Glass (a `CYLAnimatedItemView` with `itemBackgroundStyle = .liquidGlass`, as the glass tags are) with the
 * card's corner radius; where the system draws no glass the card is flat.
 */
final class CYLTagListCardView: UICollectionReusableView {

    /**
     * The glass behind the card's content, hidden while the card is flat.
     */
    @objc let glassHost = CYLAnimatedItemView()

    /**
     * The untinted glass of a card whose `sectionBackgroundColor` is unset: a plain `UIGlassEffect` view (`CYLAnimatedItemView` maps a nil
     * tint to the tags' default frosted tint, which the card must not have). A `UIVisualEffectView`, created on first use (iOS 26).
     */
    @objc private(set) var plainGlassView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        isAccessibilityElement = false
        layer.cornerCurve = .continuous
        glassHost.isHidden = true
        glassHost.isUserInteractionEnabled = false
        glassHost.isAccessibilityElement = false
        glassHost.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        glassHost.frame = bounds
        addSubview(glassHost)
    }

    /**
     * Draws the untinted glass (no `sectionBackgroundColor`): a `UIGlassEffect` view with the card's corner radius, clear of any
     * flat color. `false`: not this case (a tinted card, a flat card, or no glass on this system).
     */
    private func applyPlainGlass(_ card: CYLTagListCardAttributes) -> Bool {
        guard card.usesGlass, card.glassTint == nil, CYLAnimatedItemView.isLiquidGlassActive() else {
            return false
        }
        guard #available(iOS 26.0, *) else {
            return false
        }
        let view: UIVisualEffectView
        if let existing = plainGlassView as? UIVisualEffectView {
            view = existing
        } else {
            view = UIVisualEffectView(effect: UIGlassEffect())
            view.isUserInteractionEnabled = false
            view.isAccessibilityElement = false
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            insertSubview(view, at: 0)
            plainGlassView = view
        }
        view.frame = bounds
        view.cornerConfiguration = .corners(radius: .fixed(card.cornerRadius))
        view.isHidden = false
        glassHost.isHidden = true
        backgroundColor = nil
        return true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // The glass resolves its tint with its own traits when it lays out.
        glassHost.setNeedsLayout()
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let card = layoutAttributes as? CYLTagListCardAttributes else {
            return
        }
        layer.cornerRadius = card.cornerRadius
        if applyPlainGlass(card) {
            return
        }
        plainGlassView?.isHidden = true
        glassHost.isHidden = !card.usesGlass
        if card.usesGlass && card.glassTint != nil {
            glassHost.itemBackgroundStyle = .liquidGlass
            glassHost.itemBackgroundColor = card.glassTint
            glassHost.itemCornerRadius = card.cornerRadius
            glassHost.frame = bounds
            glassHost.layoutIfNeeded()
        }
        // Flat where the glass is not drawn.
        let drawsGlass = card.usesGlass && card.glassTint != nil && glassHost.resolvedItemBackgroundStyle == .liquidGlass
        glassHost.isHidden = !drawsGlass
        backgroundColor = drawsGlass ? nil : card.color
    }
}

/**
 * The left-aligned tag layout, plus one card per section behind its items.
 */
final class CYLTagListLayout: CYLCollectionViewLeftAlignedLayout {

    static let cardKind = "CYLTagListSectionCard"

    /**
     * The card of a section; `nil`: none (a plain list).
     */
    var cardProvider: ((Int) -> CYLTagListCardSpec?)?

    override init() {
        super.init()
        register(CYLTagListCardView.self, forDecorationViewOfKind: Self.cardKind)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        register(CYLTagListCardView.self, forDecorationViewOfKind: Self.cardKind)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var result = super.layoutAttributesForElements(in: rect)
        guard cardProvider != nil, let sections = collectionView?.numberOfSections else {
            return result
        }
        for section in 0..<sections {
            if let card = cardAttributes(forSection: section), card.frame.intersects(rect) {
                result?.append(card)
            }
        }
        return result
    }

    override func layoutAttributesForDecorationView(ofKind elementKind: String,
                                                    at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        elementKind == Self.cardKind ? cardAttributes(forSection: indexPath.section) : nil
    }

    /**
     * The card spans the column; vertically it runs from the first row's top to the last row's bottom of the tags, widened
     * by the padding. A section without items has no card.
     */
    private func cardAttributes(forSection section: Int) -> CYLTagListCardAttributes? {
        guard let spec = cardProvider?(section), let collectionView else {
            return nil
        }
        var top = CGFloat.greatestFiniteMagnitude
        var bottom = -CGFloat.greatestFiniteMagnitude
        for item in 0..<collectionView.numberOfItems(inSection: section) {
            guard let frame = layoutAttributesForItem(at: IndexPath(item: item, section: section))?.frame else {
                continue
            }
            top = min(top, frame.minY)
            bottom = max(bottom, frame.maxY)
        }
        guard top <= bottom else {
            return nil
        }
        let attributes = CYLTagListCardAttributes(forDecorationViewOfKind: Self.cardKind,
                                                  with: IndexPath(item: 0, section: section))
        attributes.frame = CGRect(x: spec.column.minX, y: top - spec.padding.top, width: spec.column.width,
                                  height: bottom - top + spec.padding.top + spec.padding.bottom)
        attributes.zIndex = -1
        attributes.color = spec.color
        attributes.glassTint = spec.glassTint
        attributes.usesGlass = spec.usesGlass
        attributes.cornerRadius = spec.cornerRadius
        return attributes
    }
}
