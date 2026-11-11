//
//  CYLMenuFixtures.swift
//  CYLMenuExampleTests
//
//  Test data and test doubles of the Example's tests.
//

import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

/**
 * Data sources, styles and tag views made for tests.
 */
enum CYLMenuFixtures {

    /**
     * `sections` sections of `count` tags each, titled "标签 <section>-<item> 🌟" under "分组 <section>".
     */
    static func source(itemCount count: Int, sections: Int) -> CYLExampleMenuSource {
        CYLExampleMenuSource(sections: (0..<sections).map { section in
            CYLExampleMenuSection(title: "分组 \(section)", titles: (0..<count).map { "标签 \(section)-\($0) 🌟" })
        })
    }

    /**
     * A 160 × 30 tag view, laid out.
     */
    static func tagButton(title: String?, image: UIImage?, style: CYLMenuStyle,
                          size: CGSize = CGSize(width: 160, height: 30)) -> CYLTagButton {
        let button = CYLTagButton(frame: CGRect(origin: .zero, size: size))
        button.style = style
        button.title = title
        button.image = image
        button.layoutIfNeeded()
        return button
    }

    /**
     * A filled square, for an icon whose pixels the test controls.
     */
    static func squareImage(side: CGFloat = 18, color: UIColor = .systemRed) -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: side, height: side)).image { context in
            color.setFill()
            context.fill(CGRect(x: 0, y: 0, width: side, height: side))
        }
    }
}

/**
 * The red, green, blue and alpha components of a color, for comparisons across color spaces.
 *
 * Every component is -1 when the color has no RGB form (or is nil), so that no expectation passes by accident.
 */
struct CYLColorComponents: Equatable {
    var red: CGFloat = -1, green: CGFloat = -1, blue: CGFloat = -1, alpha: CGFloat = -1

    init(_ color: UIColor?) {
        _ = color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }

    var isWhite: Bool {
        red > 0.99 && green > 0.99 && blue > 0.99
    }
}

/**
 * A menu delegate that records what the list reports, and can veto one item.
 */
final class CYLRecordingMenuDelegate: NSObject, CYLMenuDelegate {

    /**
     * "select 1-0", "deselect 1-0", "expand 0", "collapse 0", in order (item-section, as the expectations read).
     */
    private(set) var events: [String] = []
    /**
     * The item `menu(_:shouldSelectItemAt:)` refuses.
     */
    var blockedIndexPath: IndexPath?
    private(set) var lastHeight: CGFloat = 0
    private(set) var changeCount = 0

    private func describe(_ indexPath: IndexPath) -> String {
        "\(indexPath.item)-\(indexPath.section)"
    }

    func menu(_ menu: Any, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        indexPath != blockedIndexPath
    }

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        events.append("select " + describe(indexPath))
    }

    func menu(_ menu: Any, didDeleteItemAt indexPath: IndexPath) {
        events.append("delete " + describe(indexPath))
    }

    func menu(_ menu: Any, didDeselectItemAt indexPath: IndexPath) {
        events.append("deselect " + describe(indexPath))
    }

    func menu(_ menu: Any, didChangeExpanded expanded: Bool, inSection section: Int) {
        events.append("\(expanded ? "expand" : "collapse") \(section)")
    }

    func menu(_ menu: Any, didChangeContentHeight height: CGFloat) {
        lastHeight = height
    }

    func menu(_ menu: Any, didChangeSelectedItems indexPaths: [IndexPath]) {
        changeCount += 1
    }
}
