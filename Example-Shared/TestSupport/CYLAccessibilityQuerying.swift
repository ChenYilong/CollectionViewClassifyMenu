//
//  CYLAccessibilityQuerying.swift
//  Example-Shared/TestSupport
//
//  Shared by the test targets of Example/ and Example-Swift/: finds views as VoiceOver and UI tests do.
//

import UIKit

/**
 * A view tree the tests search by accessibility identifier and label, never by coordinates.
 */
protocol CYLAccessibilityQuerying {
    /**
     * The view the search starts at (included in the results).
     */
    var accessibilityRoot: UIView { get }
}

extension CYLAccessibilityQuerying {

    /**
     * Every view under the root with this accessibility identifier, in depth-first order.
     */
    func views(withIdentifier identifier: String) -> [UIView] {
        Self.views(withIdentifier: identifier, in: accessibilityRoot)
    }

    /**
     * The first view with this identifier whose accessibility label is `label`.
     */
    func view(withIdentifier identifier: String, label: String) -> UIView? {
        views(withIdentifier: identifier).first { $0.accessibilityLabel == label }
    }

    private static func views(withIdentifier identifier: String, in root: UIView) -> [UIView] {
        (root.accessibilityIdentifier == identifier ? [root] : [])
            + root.subviews.flatMap { views(withIdentifier: identifier, in: $0) }
    }
}

extension UIView: CYLAccessibilityQuerying {
    var accessibilityRoot: UIView {
        self
    }
}
