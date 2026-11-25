//
//  CYLTagListDefaultFramesTests.swift
//  CYLMenuExampleTests
//
//  CYLTagListView: the frames of the default style, taken from the code before the section style (card, header band,
//  header divider) existed. The section style must never move a pixel of them.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLTagListDefaultFramesTests: CYLMenuExampleTestCase {

    /**
     * The header, every visible item and the footer of each section, and the heights, as text.
     */
    private func snapshot(of view: CYLTagListView) -> String {
        let tags = view.probe
        tags.layOut()
        let layout = tags.collectionView.collectionViewLayout
        func text(_ frame: CGRect?) -> String {
            guard let frame else { return "nil" }
            return String(format: "%.2f,%.2f,%.2f,%.2f", frame.minX, frame.minY, frame.width, frame.height)
        }
        var lines: [String] = []
        for section in 0..<tags.collectionView.numberOfSections {
            let header = layout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                     at: ip(0, section))?.frame
            let footer = layout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                                     at: ip(0, section))?.frame
            lines.append("s\(section) header \(text(header))")
            for item in 0..<tags.numberOfItems(inSection: section) {
                lines.append("s\(section) i\(item) \(text(tags.itemFrame(at: ip(item, section))))")
            }
            lines.append("s\(section) footer \(text(footer))")
        }
        lines.append(String(format: "contentHeight %.2f fits %.2f", view.contentHeight,
                            view.heightThatFitsWidth(view.bounds.width)))
        return lines.joined(separator: "\n")
    }

    private func shownSnapshot(width: CGFloat, style: UIUserInterfaceStyle, foldStyle: CYLMenuFoldStyle) -> String {
        let source = CYLExampleMenuSource(sections: (0..<3).map { section in
            CYLExampleMenuSection(title: "分组 \(section)", titles: (0..<(9 + section * 7)).map { item in
                item % 5 == 4 ? "一个比较长的标签 \(section)-\(item)" : "标签 \(section)-\(item) 🌟"
            })
        })
        let view = showTagList(source, width: width)
        hostWindow?.overrideUserInterfaceStyle = style
        view.defaultVisibleRows = 2
        view.foldStyle = foldStyle
        view.reloadMenuData()
        view.layoutIfNeeded()
        let text = snapshot(of: view)
        withExtendedLifetime(source) {}
        return text
    }

    private func assertDefaultFrames(width: CGFloat, foldStyle: CYLMenuFoldStyle, golden: String,
                                     file: StaticString = #filePath, line: UInt = #line) {
        let light = shownSnapshot(width: width, style: .light, foldStyle: foldStyle)
        closeHostWindow()
        let dark = shownSnapshot(width: width, style: .dark, foldStyle: foldStyle)
        XCTAssertEqual(dark, light, "Dark mode moves no frame", file: file, line: line)
        XCTAssertEqual(light, golden, "SNAPSHOT width \(width) \(foldStyle):\n\(light)", file: file, line: line)
    }

    func testDefaultFramesWithFooterChevronAt320() {
        assertDefaultFrames(width: 320, foldStyle: .footerChevron, golden: """
            s0 header 0.00,0.00,320.00,36.00
            s0 i0 16.00,46.00,100.00,30.00
            s0 i1 126.00,46.00,97.00,30.00
            s0 i2 16.00,86.00,99.00,30.00
            s0 i3 125.00,86.00,100.00,30.00
            s0 footer 0.00,126.00,320.00,28.00
            s1 header 0.00,154.00,320.00,36.00
            s1 i0 16.00,200.00,97.00,30.00
            s1 i1 123.00,200.00,95.00,30.00
            s1 i2 16.00,240.00,97.00,30.00
            s1 i3 123.00,240.00,97.00,30.00
            s1 footer 0.00,280.00,320.00,28.00
            s2 header 0.00,308.00,320.00,36.00
            s2 i0 16.00,354.00,99.00,30.00
            s2 i1 125.00,354.00,97.00,30.00
            s2 i2 16.00,394.00,99.00,30.00
            s2 i3 125.00,394.00,99.00,30.00
            s2 footer 0.00,434.00,320.00,28.00
            contentHeight 462.00 fits 462.00
            """)
    }

    func testDefaultFramesWithFooterChevronAt390() {
        assertDefaultFrames(width: 390, foldStyle: .footerChevron, golden: """
            s0 header 0.00,0.00,390.00,36.00
            s0 i0 16.00,46.00,100.00,30.00
            s0 i1 126.00,46.00,97.00,30.00
            s0 i2 233.00,46.00,99.00,30.00
            s0 i3 16.00,86.00,100.00,30.00
            s0 i4 126.00,86.00,159.00,30.00
            s0 footer 0.00,126.00,390.00,28.00
            s1 header 0.00,154.00,390.00,36.00
            s1 i0 16.00,200.00,97.00,30.00
            s1 i1 123.00,200.00,95.00,30.00
            s1 i2 228.00,200.00,97.00,30.00
            s1 i3 16.00,240.00,97.00,30.00
            s1 i4 123.00,240.00,157.00,30.00
            s1 footer 0.00,280.00,390.00,28.00
            s2 header 0.00,308.00,390.00,36.00
            s2 i0 16.00,354.00,99.00,30.00
            s2 i1 125.00,354.00,97.00,30.00
            s2 i2 232.00,354.00,99.00,30.00
            s2 i3 16.00,394.00,99.00,30.00
            s2 i4 125.00,394.00,159.00,30.00
            s2 footer 0.00,434.00,390.00,28.00
            contentHeight 462.00 fits 462.00
            """)
    }

    func testDefaultFramesWithHeaderButtonAt320() {
        assertDefaultFrames(width: 320, foldStyle: .headerButton, golden: """
            s0 header 0.00,0.00,320.00,36.00
            s0 i0 16.00,46.00,100.00,30.00
            s0 i1 126.00,46.00,97.00,30.00
            s0 i2 16.00,86.00,99.00,30.00
            s0 i3 125.00,86.00,100.00,30.00
            s0 footer nil
            s1 header 0.00,126.00,320.00,36.00
            s1 i0 16.00,172.00,97.00,30.00
            s1 i1 123.00,172.00,95.00,30.00
            s1 i2 16.00,212.00,97.00,30.00
            s1 i3 123.00,212.00,97.00,30.00
            s1 footer 0.00,126.00,0.00,0.00
            s2 header 0.00,252.00,320.00,36.00
            s2 i0 16.00,298.00,99.00,30.00
            s2 i1 125.00,298.00,97.00,30.00
            s2 i2 16.00,338.00,99.00,30.00
            s2 i3 125.00,338.00,99.00,30.00
            s2 footer 0.00,252.00,0.00,0.00
            contentHeight 378.00 fits 378.00
            """)
    }

    func testDefaultFramesWithHeaderButtonAt390() {
        assertDefaultFrames(width: 390, foldStyle: .headerButton, golden: """
            s0 header 0.00,0.00,390.00,36.00
            s0 i0 16.00,46.00,100.00,30.00
            s0 i1 126.00,46.00,97.00,30.00
            s0 i2 233.00,46.00,99.00,30.00
            s0 i3 16.00,86.00,100.00,30.00
            s0 i4 126.00,86.00,159.00,30.00
            s0 footer nil
            s1 header 0.00,126.00,390.00,36.00
            s1 i0 16.00,172.00,97.00,30.00
            s1 i1 123.00,172.00,95.00,30.00
            s1 i2 228.00,172.00,97.00,30.00
            s1 i3 16.00,212.00,97.00,30.00
            s1 i4 123.00,212.00,157.00,30.00
            s1 footer 0.00,126.00,0.00,0.00
            s2 header 0.00,252.00,390.00,36.00
            s2 i0 16.00,298.00,99.00,30.00
            s2 i1 125.00,298.00,97.00,30.00
            s2 i2 232.00,298.00,99.00,30.00
            s2 i3 16.00,338.00,99.00,30.00
            s2 i4 125.00,338.00,159.00,30.00
            s2 footer 0.00,252.00,0.00,0.00
            contentHeight 378.00 fits 378.00
            """)
    }
}
