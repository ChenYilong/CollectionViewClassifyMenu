//
//  CYLTagGroup.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

/**
 * A group of `CYLTagView`: its name, its tags and whether it is open. Folded, it shows the tags of its first row.
 * (Objective-C names kept where the component's Objective-C tests use them.)
 */
@objc(CYLTagGroup)
public final class CYLTagGroup: NSObject {

    /**
     * The group's name, shown in its header.
     */
    @objc public var groupName = ""

    /**
     * The list's width the rows are computed for (0: the screen's width).
     */
    public var width: CGFloat = 0

    /**
     * The header's height.
     */
    public var height: CGFloat = 38

    /**
     * 标识这组是否需要展开 / Whether the group is open (all tags) or folded (the first row).
     */
    @objc(opened)
    public var isOpened: Bool {
        @objc(isOpened) get {
            opened
        }
        @objc(setOpened:) set {
            opened = newValue
        }
    }

    /**
     * The group's index in the list.
     */
    public var section = 0

    /**
     * The tags; setting them recomputes the rows.
     */
    @objc(itemArr)
    public var items: [CYLTagModel] = [] {
        didSet {
            cachedCellCountsPerRow = nil
        }
    }

    /**
     * 每行有几个item / How many tags each row holds, for the current `width`.
     */
    @objc(cellsCountArrayPerRowInSections)
    public var cellCountsPerRow: [Int] {
        if let cachedCellCountsPerRow {
            return cachedCellCountsPerRow
        }
        let counts = Self.cellCountsPerRow(of: items, contentWidth: defaultContentWidth)
        cachedCellCountsPerRow = counts
        return counts
    }

    private var opened = false
    private var cachedCellCountsPerRow: [Int]?

    /**
     * Forgets the computed rows, after the tags' sizes changed (a new text size).
     */
    public func invalidateRowCounts() {
        cachedCellCountsPerRow = nil
    }

    /**
     * The number of tags in the first row of a list `contentWidth` wide (at least one tag when there is one).
     */
    @objc(firstRowCellCountForContentWidth:)
    public func firstRowCellCount(forContentWidth contentWidth: CGFloat) -> Int {
        Self.cellCountsPerRow(of: items, contentWidth: max(0, contentWidth)).first ?? 0
    }

    private var defaultContentWidth: CGFloat {
        let listWidth = width > 0 ? width : UIScreen.main.bounds.width
        return max(0, listWidth - CYLTagView.sectionInset.left - CYLTagView.sectionInset.right)
    }

    /**
     * 分行规则 / Wrapping: adjacent tags are `CYLTagView.cellSpacing` apart, the edges need no spacing,
     * and a tag wider than the row is capped to it and takes a row of its own.
     */
    private static func cellCountsPerRow(of items: [CYLTagModel], contentWidth: CGFloat) -> [Int] {
        let spacing = CYLTagView.cellSpacing
        var counts: [Int] = []
        var used: CGFloat = 0
        var count = 0
        for model in items {
            let width = min(max(0, CGFloat(model.width)), contentWidth)
            if count > 0 && used + spacing + width > contentWidth {
                counts.append(count)
                count = 0
                used = 0
            }
            used += (count > 0 ? spacing : 0) + width
            count += 1
        }
        if count > 0 {
            counts.append(count)
        }
        return counts
    }
}
