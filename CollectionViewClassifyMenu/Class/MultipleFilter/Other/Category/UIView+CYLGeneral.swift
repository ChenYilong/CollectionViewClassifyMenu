//
//  UIView+CYLGeneral.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md). Frame, border and capture helpers, the same
//  set as Android's `CYLGeneralExtensions.kt` (`View.cyl_setWidth`…, docs/android-ios-api.md), with Swift names
//  without the underscore (AGENTS.md, "cyl_ methods"): `cyl_setWidth` is `cylSetWidth(_:)`, `cyl_width` is
//  `cylWidth`. Lengths are points (Android: dp).
//

import UIKit

public extension UIView {

    // MARK: Frame

    /**
     * Sets the frame's width, keeping its origin (Android `cyl_setWidth`).
     */
    func cylSetWidth(_ width: CGFloat) {
        frame.size.width = width
    }

    /**
     * Sets the frame's height, keeping its origin (Android `cyl_setHeight`).
     */
    func cylSetHeight(_ height: CGFloat) {
        frame.size.height = height
    }

    /**
     * Moves the frame to `x`, keeping its size (Android `cyl_setX`).
     */
    func cylSetX(_ x: CGFloat) {
        frame.origin.x = x
    }

    /**
     * Moves the frame to `y`, keeping its size (Android `cyl_setY`).
     */
    func cylSetY(_ y: CGFloat) {
        frame.origin.y = y
    }

    /**
     * Sets the frame's size, keeping its origin (Android `cyl_setSize`).
     */
    func cylSetSize(_ size: CGSize) {
        frame.size = size
    }

    /**
     * The frame's height (Android `cyl_height`).
     */
    var cylHeight: CGFloat {
        frame.height
    }

    /**
     * The frame's width (Android `cyl_width`).
     */
    var cylWidth: CGFloat {
        frame.width
    }

    /**
     * The frame's x (Android `cyl_x`).
     */
    var cylX: CGFloat {
        frame.minX
    }

    /**
     * The frame's y (Android `cyl_y`).
     */
    var cylY: CGFloat {
        frame.minY
    }

    /**
     * The frame's bottom edge (Android `cyl_maxY`).
     */
    var cylMaxY: CGFloat {
        frame.maxY
    }

    /**
     * The frame's trailing edge in left-to-right coordinates (Android `cyl_maxX`).
     */
    var cylMaxX: CGFloat {
        frame.maxX
    }

    /**
     * Centers the view horizontally in a width of `width` (Android `cyl_horizontalCenterWithWidth`, rounded up the
     * same way).
     */
    func cylHorizontalCenter(withWidth width: CGFloat) {
        cylSetX(ceil((width - cylWidth) / 2))
    }

    /**
     * Centers the view vertically in a height of `height` (Android `cyl_verticalCenterWithHeight`).
     */
    func cylVerticalCenter(withHeight height: CGFloat) {
        cylSetY(ceil((height - cylHeight) / 2))
    }

    /**
     * Centers the view vertically in its superview; does nothing without one (Android `cyl_verticalCenterInSuperView`).
     */
    func cylVerticalCenterInSuperview() {
        guard let superview else { return }
        cylVerticalCenter(withHeight: superview.bounds.height)
    }

    /**
     * Centers the view horizontally in its superview; does nothing without one
     * (Android `cyl_horizontalCenterInSuperView`).
     */
    func cylHorizontalCenterInSuperview() {
        guard let superview else { return }
        cylHorizontalCenter(withWidth: superview.bounds.width)
    }

    // MARK: Border and corners

    /**
     * A border of `width` in `color` (Android `cyl_setBorderWidth`); a negative width is 0.
     */
    func cylSetBorderWidth(_ width: CGFloat, color: UIColor) {
        layer.borderWidth = max(0, width)
        layer.borderColor = color.resolvedColor(with: traitCollection).cgColor
    }

    /**
     * Rounds the view with `radius` and clips its content to the rounded shape when the radius is above 0
     * (Android `cyl_setCornerRadius`).
     */
    func cylSetCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = max(0, radius)
        clipsToBounds = radius > 0
    }

    // MARK: Layers, taps and captures

    /**
     * Adds a filled sublayer (a line) of `color` at `frame` and returns it, to be moved later by its frame
     * (Android `cyl_addSubLayerWithFrame`).
     */
    @discardableResult
    func cylAddLineLayer(frame: CGRect, color: UIColor) -> CALayer {
        let line = CALayer()
        line.frame = frame
        line.backgroundColor = color.cgColor
        layer.addSublayer(line)
        return line
    }

    /**
     * Makes taps on the view call `action` on `target` (Android `cyl_setTarget`, which takes a closure).
     */
    func cylAddTapTarget(_ target: Any, action: Selector) {
        addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
    }

    /**
     * Captures the leading `width` points of the view at its full height (Android `cyl_captureWithWidth`).
     */
    func cylSnapshot(width: CGFloat) -> UIImage {
        let format = UIGraphicsImageRendererFormat.preferred()
        format.opaque = isOpaque
        let size = CGSize(width: max(1, width), height: max(1, bounds.height))
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            layer.render(in: context.cgContext)
        }
    }

    /**
     * Captures the leading 270 points of the view at its full height (Android `cyl_capture`).
     */
    func cylSnapshot() -> UIImage {
        cylSnapshot(width: 270)
    }

    // MARK: Tests and tools

    /**
     * This view and its descendants whose `accessibilityIdentifier` is `identifier`, depth first (Android
     * `cyl_viewsWithAccessibilityIdentifier`), for tests and tools.
     */
    @objc(cyl_viewsWithAccessibilityIdentifier:)
    func cyl_viewsWithAccessibilityIdentifier(_ identifier: String) -> [UIView] {
        var found: [UIView] = accessibilityIdentifier == identifier ? [self] : []
        for subview in subviews {
            found += subview.cyl_viewsWithAccessibilityIdentifier(identifier)
        }
        return found
    }
}
