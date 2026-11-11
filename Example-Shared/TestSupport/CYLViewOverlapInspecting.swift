//
//  CYLViewOverlapInspecting.swift
//  Example-Shared/TestSupport
//
//  Shared by the test targets of Example/ and Example-Swift/: finds the views that a view (such as a search bar)
//  covers in its window.
//

import UIKit

/**
 * A test that checks that a view covers no other view of its window.
 *
 * "Covers" means the frames intersect in window coordinates, after clipping by ancestors that clip their bounds. Not counted: the view's own subviews, the views that
 * contain it, and the backgrounds of system bars (drawn behind their items). Every other visible view is counted:
 * labels, images, controls, text, scroll views, plain leaf views that draw something (a background, contents or a
 * border), and a view controller's view that is not an ancestor.
 */
protocol CYLViewOverlapInspecting {}

extension CYLViewOverlapInspecting {

    /**
     * The visible views of `view`'s window whose frames intersect `view`'s frame by more than `tolerance` points,
     * described as "<class> <frame> in <superview class>" for a failure message. Empty when `view` covers nothing.
     */
    func viewsCovered(by view: UIView, tolerance: CGFloat = 0.5) -> [String] {
        guard let window = view.window else {
            return ["\(type(of: view)) is not in a window"]
        }
        let frame = view.convert(view.bounds, to: window).insetBy(dx: tolerance, dy: tolerance)
        guard !frame.isNull, frame.width > 0, frame.height > 0 else {
            return []
        }
        var ancestors = Set<ObjectIdentifier>()
        var parent = view.superview
        while let current = parent {
            ancestors.insert(ObjectIdentifier(current))
            parent = current.superview
        }
        var covered: [String] = []
        func visit(_ candidate: UIView) {
            guard candidate !== view, !candidate.isHidden, candidate.alpha > 0.01 else {
                return
            }
            // A bar's own background (navigation bar, tab bar, toolbar) is drawn behind its items by design.
            if NSStringFromClass(type(of: candidate)).contains("BarBackground") {
                return
            }
            if !ancestors.contains(ObjectIdentifier(candidate)) && Self.isContent(candidate) {
                // Only the part left visible by ancestors that clip (a scroll view hides what lies outside it).
                var other = candidate.convert(candidate.bounds, to: window)
                var clip = candidate.superview
                while let current = clip, current !== window {
                    if current.clipsToBounds {
                        other = other.intersection(current.convert(current.bounds, to: window))
                    }
                    clip = current.superview
                }
                if !other.isNull, other.width > 0, other.height > 0, frame.intersects(other) {
                    let parent = candidate.superview.map { "\(type(of: $0))" } ?? "-"
                    covered.append("\(type(of: candidate)) \(NSCoder.string(for: other)) in \(parent)")
                }
            }
            candidate.subviews.forEach(visit)
        }
        window.subviews.forEach(visit)
        return covered
    }

    /**
     * Views a user reads or touches, and view controllers' views. Containers that only hold other views (and the
     * system's private bar backgrounds) are left out; their content is visited on its own.
     */
    private static func isContent(_ view: UIView) -> Bool {
        if view is UILabel || view is UIControl || view is UITextView || view is UIScrollView {
            return true
        }
        if let imageView = view as? UIImageView {
            return imageView.image != nil
        }
        if view.next is UIViewController {
            return true
        }
        // A plain leaf view counts when it draws something: a background, contents or a border.
        let name = NSStringFromClass(type(of: view))
        let draws = (view.backgroundColor.map { $0.cgColor.alpha > 0.01 } ?? false)
            || view.layer.contents != nil || view.layer.borderWidth > 0
        return view.subviews.isEmpty && !name.hasPrefix("_") && draws
    }
}
