//
//  CYLTagLongPressAction.swift
//  CollectionViewClassifyMenu
//
//  What a long press on an item does (`CYLTagListView.longPressAction`). The list owns the gesture; an action owns the
//  behavior: reordering, a callout with the item's subtitle, or the host's own code. The events
//  (`menu(_:didLongPressItemAt:)`, `tagLongPressHandler`) stay notifications: the built-in actions report them, and they
//  never change the behavior. The same contract as HarmonyOS and Android (docs/tag-long-press-action.md).
//
//      list.longPressAction = CYLTagLongPressActions.first([CYLTagLongPressActions.reorder, CYLTagLongPressActions.callout])
//      list.longPressAction = CYLTagLongPressActions.handler { host, indexPath in host.showCallout("My text", at: indexPath) }
//
//  The default is `first([reorder, report])`: reordering where the list can reorder, else the long press is reported,
//  exactly as before this API existed.
//

import UIKit

/**
 * The list as an action sees it: the primitives the built-in and the custom actions are made of.
 */
public protocol CYLTagLongPressHost: AnyObject {

    /**
     * The item's subtitle from the data source (`menuSubtitleForItem(at:)`), or `nil`.
     */
    func subtitleForItem(at indexPath: IndexPath) -> String?

    /**
     * Shows a small callout with an arrow, pointing at the item, with `text`. Replaces a callout that is showing.
     */
    func showCallout(_ text: String, at indexPath: IndexPath)

    /**
     * Hides the callout.
     */
    func dismissCallout()

    /**
     * Whether the list can reorder its items now.
     */
    func canReorderItem(at indexPath: IndexPath) -> Bool

    /**
     * Starts reordering with the item picked up (a selected item's drag is reported). `false` when UIKit did not start
     * the interactive movement.
     */
    func beginReordering(at indexPath: IndexPath) -> Bool

    /**
     * Ends reordering: UIKit moves the item (the data source is told) when `moved`; a press that did not move is
     * reported as a long press.
     */
    func endReordering(destination: IndexPath?, moved: Bool)

    /**
     * Ends reordering without moving anything.
     */
    func cancelReordering()

    /**
     * Reports a long press: `menu(_:didLongPressItemAt:)`, then `tagLongPressHandler`.
     */
    func reportLongPress(at indexPath: IndexPath)
}

/**
 * What a long press on an item does.
 */
public protocol CYLTagLongPressAction: AnyObject {

    /**
     * Whether this action takes the press on this item (reorder: the list can reorder; callout: the item has a subtitle).
     */
    func canBegin(host: CYLTagLongPressHost, at indexPath: IndexPath) -> Bool

    /**
     * The press was recognized. Returns `true` to follow the finger; `end` or `cancel` then arrive.
     */
    func begin(host: CYLTagLongPressHost, at indexPath: IndexPath) -> Bool

    /**
     * The finger lifted over `destination` (`nil`: outside the list); `moved` tells whether it left the item.
     */
    func end(host: CYLTagLongPressHost, destination: IndexPath?, moved: Bool)

    /**
     * The gesture was cancelled.
     */
    func cancel(host: CYLTagLongPressHost)
}

public extension CYLTagLongPressAction {
    func end(host: CYLTagLongPressHost, destination: IndexPath?, moved: Bool) {}
    func cancel(host: CYLTagLongPressHost) {}
}

private final class CYLTagReorderAction: CYLTagLongPressAction {
    func canBegin(host: CYLTagLongPressHost, at indexPath: IndexPath) -> Bool {
        host.canReorderItem(at: indexPath)
    }

    func begin(host: CYLTagLongPressHost, at indexPath: IndexPath) -> Bool {
        if host.beginReordering(at: indexPath) {
            return true
        }
        // UIKit did not start the movement: the press is only a long press, as before.
        host.reportLongPress(at: indexPath)
        return false
    }

    func end(host: CYLTagLongPressHost, destination: IndexPath?, moved: Bool) {
        host.endReordering(destination: destination, moved: moved)
    }

    func cancel(host: CYLTagLongPressHost) {
        host.cancelReordering()
    }
}

private final class CYLTagReportAction: CYLTagLongPressAction {
    func canBegin(host: CYLTagLongPressHost, at indexPath: IndexPath) -> Bool {
        true
    }

    func begin(host: CYLTagLongPressHost, at indexPath: IndexPath) -> Bool {
        host.reportLongPress(at: indexPath)
        return false
    }
}

private final class CYLTagCalloutAction: CYLTagLongPressAction {
    func canBegin(host: CYLTagLongPressHost, at indexPath: IndexPath) -> Bool {
        !(host.subtitleForItem(at: indexPath) ?? "").isEmpty
    }

    func begin(host: CYLTagLongPressHost, at indexPath: IndexPath) -> Bool {
        if let subtitle = host.subtitleForItem(at: indexPath), !subtitle.isEmpty {
            host.showCallout(subtitle, at: indexPath)
        }
        host.reportLongPress(at: indexPath)
        return false
    }
}

private final class CYLTagNoneAction: CYLTagLongPressAction {
    func canBegin(host: CYLTagLongPressHost, at indexPath: IndexPath) -> Bool {
        true
    }

    func begin(host: CYLTagLongPressHost, at indexPath: IndexPath) -> Bool {
        false
    }
}

private final class CYLTagHandlerAction: CYLTagLongPressAction {
    private let handler: (CYLTagLongPressHost, IndexPath) -> Void

    init(_ handler: @escaping (CYLTagLongPressHost, IndexPath) -> Void) {
        self.handler = handler
    }

    func canBegin(host: CYLTagLongPressHost, at indexPath: IndexPath) -> Bool {
        true
    }

    func begin(host: CYLTagLongPressHost, at indexPath: IndexPath) -> Bool {
        handler(host, indexPath)
        return false
    }
}

/// The first action of a list whose `canBegin` passes takes the press; it also receives the end and the cancel.
private final class CYLTagFirstAction: CYLTagLongPressAction {
    private let actions: [CYLTagLongPressAction]
    private var chosen: CYLTagLongPressAction?

    init(_ actions: [CYLTagLongPressAction]) {
        self.actions = actions
    }

    func canBegin(host: CYLTagLongPressHost, at indexPath: IndexPath) -> Bool {
        actions.contains { $0.canBegin(host: host, at: indexPath) }
    }

    func begin(host: CYLTagLongPressHost, at indexPath: IndexPath) -> Bool {
        chosen = nil
        for action in actions where action.canBegin(host: host, at: indexPath) {
            let follows = action.begin(host: host, at: indexPath)
            chosen = follows ? action : nil
            return follows
        }
        return false
    }

    func end(host: CYLTagLongPressHost, destination: IndexPath?, moved: Bool) {
        let action = chosen
        chosen = nil
        action?.end(host: host, destination: destination, moved: moved)
    }

    func cancel(host: CYLTagLongPressHost) {
        let action = chosen
        chosen = nil
        action?.cancel(host: host)
    }
}

/**
 * The built-in long-press actions, and the ways to combine them or write your own.
 */
public enum CYLTagLongPressActions {

    /**
     * Picks the item up to reorder it, where the list can reorder (UIKit moves the item, the data source is told).
     */
    public static let reorder: CYLTagLongPressAction = CYLTagReorderAction()

    /**
     * Only reports the long press (`menu(_:didLongPressItemAt:)`, `tagLongPressHandler`).
     */
    public static let report: CYLTagLongPressAction = CYLTagReportAction()

    /**
     * Shows the item's subtitle in a callout with an arrow, where the item has one, and reports the long press.
     */
    public static let callout: CYLTagLongPressAction = CYLTagCalloutAction()

    /**
     * Does nothing (not even a report).
     */
    public static let none: CYLTagLongPressAction = CYLTagNoneAction()

    /**
     * Runs `handler` instead of a built-in behavior; it can use the host's primitives, such as `showCallout(_:at:)`.
     */
    public static func handler(_ handler: @escaping (CYLTagLongPressHost, IndexPath) -> Void) -> CYLTagLongPressAction {
        CYLTagHandlerAction(handler)
    }

    /**
     * The first of `actions` that can begin takes the press, as "reorder where editable, a callout elsewhere".
     */
    public static func first(_ actions: [CYLTagLongPressAction]) -> CYLTagLongPressAction {
        CYLTagFirstAction(actions)
    }

    /**
     * The default of a list: `first([reorder, report])`, the behavior before this API existed.
     */
    public static func makeDefault() -> CYLTagLongPressAction {
        CYLTagFirstAction([reorder, report])
    }
}

/**
 * The callout of a long press: a small bubble with an arrow pointing at the tag.
 */
final class CYLTagCalloutView: UIView {

    private let label = UILabel()
    private let bubble = CAShapeLayer()
    private static let margin: CGFloat = 8
    private static let arrowHeight: CGFloat = 7
    private static let arrowHalfWidth: CGFloat = 7
    private static let maxWidth: CGFloat = 240
    private static let padding = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    private var arrowCenter: CGFloat = 0
    private var arrowUp = false

    init(text: String) {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        layer.addSublayer(bubble)
        label.text = text
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .label
        addSubview(label)
        isAccessibilityElement = true
        accessibilityLabel = text
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// The bubble's fill follows dark mode: white in light mode, a dark gray in dark mode.
    private var fillColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(white: 0.17, alpha: 1) : UIColor.white
        }
    }

    /// Whether `text` has a space or a line break, where it may wrap.
    private static func hasBreakOpportunity(_ text: String?) -> Bool {
        text?.contains { $0.isWhitespace } ?? false
    }

    /// The gap between the bubble's arrow tip and the tag.
    private static let gap: CGFloat = 4

    /**
     * Whether the callout goes below the tag (arrow up). Above first (the contract); below when it does not fit above
     * or when it would cover `header` (the section header above a first-row tag) and it fits below; above when neither
     * side is free of the header and below does not fit. Pure: all frames are in the container's coordinates.
     */
    static func placesBelow(target: CGRect, height: CGFloat, safeTop: CGFloat, bottomLimit: CGFloat, header: CGRect?) -> Bool {
        let aboveTop = target.minY - height - gap
        let fitsAbove = aboveTop >= safeTop
        let fitsBelow = target.maxY + gap + height <= bottomLimit
        guard fitsAbove else {
            return true
        }
        guard let header, !header.isEmpty else {
            return false
        }
        // The bubble is clamped horizontally and may be wider than the header's text: compare the vertical ranges only.
        let coversHeader = header.minY < aboveTop + height && header.maxY > aboveTop
        return coversHeader && fitsBelow
    }

    /**
     * Places the callout in `container` (the window), above `target` (the tag's frame in the container's coordinates),
     * below it when there is no room above or when the bubble would cover `header` (see `placesBelow`), clamped to the
     * container, its arrow at the tag's center.
     */
    func present(pointingAt target: CGRect, in container: UIView, avoiding header: CGRect? = nil) {
        // A text with no break opportunity (an API name such as `setIconAnimation(bundled:size:for:)`) is never split mid-word: it may use
        // the container's width, else UIKit breaks it by character and the closing `)` lands on a second line. Other text keeps `maxWidth`.
        let insets = Self.padding.left + Self.padding.right
        let widthLimit = Self.hasBreakOpportunity(label.text) ? Self.maxWidth : max(Self.maxWidth, container.bounds.width - 2 * Self.margin)
        let textSize = label.sizeThatFits(CGSize(width: widthLimit - insets, height: .greatestFiniteMagnitude))
        let width = ceil(textSize.width) + Self.padding.left + Self.padding.right
        let bodyHeight = ceil(textSize.height) + Self.padding.top + Self.padding.bottom
        let height = bodyHeight + Self.arrowHeight
        let bounds = container.bounds
        let safeTop = container.safeAreaInsets.top
        let x = max(Self.margin, min(bounds.width - Self.margin - width, target.midX - width / 2))
        arrowUp = Self.placesBelow(target: target, height: height, safeTop: safeTop,
                                   bottomLimit: bounds.height - container.safeAreaInsets.bottom, header: header)
        let y = arrowUp ? target.maxY + Self.gap : target.minY - height - Self.gap
        frame = CGRect(x: x, y: y, width: width, height: height)
        arrowCenter = target.midX - x
        label.frame = CGRect(x: Self.padding.left, y: Self.padding.top + (arrowUp ? Self.arrowHeight : 0),
                             width: width - Self.padding.left - Self.padding.right, height: ceil(textSize.height))
        updateBubble()
        container.addSubview(self)
        UIAccessibility.post(notification: .announcement, argument: label.text)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateBubble()
    }

    private func updateBubble() {
        let body = CGRect(x: 0, y: arrowUp ? Self.arrowHeight : 0, width: bounds.width, height: bounds.height - Self.arrowHeight)
        let path = UIBezierPath(roundedRect: body, cornerRadius: min(12, body.height / 2))
        let center = max(Self.arrowHalfWidth + 12, min(bounds.width - Self.arrowHalfWidth - 12, arrowCenter))
        let arrow = UIBezierPath()
        if arrowUp {
            arrow.move(to: CGPoint(x: center - Self.arrowHalfWidth, y: body.minY))
            arrow.addLine(to: CGPoint(x: center, y: body.minY - Self.arrowHeight))
            arrow.addLine(to: CGPoint(x: center + Self.arrowHalfWidth, y: body.minY))
        } else {
            arrow.move(to: CGPoint(x: center - Self.arrowHalfWidth, y: body.maxY))
            arrow.addLine(to: CGPoint(x: center, y: body.maxY + Self.arrowHeight))
            arrow.addLine(to: CGPoint(x: center + Self.arrowHalfWidth, y: body.maxY))
        }
        arrow.close()
        path.append(arrow)
        bubble.path = path.cgPath
        bubble.fillColor = fillColor.resolvedColor(with: traitCollection).cgColor
        layer.shadowPath = path.cgPath
    }
}

/**
 * Lets the window-wide tap that dismisses a callout run next to every other gesture, without taking a touch from them.
 */
final class CYLTagCalloutTapDelegate: NSObject, UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
