//
//  UIView+CYLGeneral.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md): only the helpers the core uses, internal.
//

import UIKit

extension UIView {

    /**
     * Adds a filled sublayer (a line) of `color` at `frame` and returns it, to be laid out later.
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
     * Makes taps on the view call `action` on `target`.
     */
    func cylAddTapTarget(_ target: Any, action: Selector) {
        addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
    }

    /**
     * Captures the leading `width` points of the view at its full height.
     */
    func cylSnapshot(width: CGFloat) -> UIImage {
        let format = UIGraphicsImageRendererFormat.preferred()
        format.opaque = isOpaque
        let size = CGSize(width: max(1, width), height: max(1, bounds.height))
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            layer.render(in: context.cgContext)
        }
    }
}
