//
//  CYLTagGroupRowTests.swift
//  TagCollectionViewTests
//
//  In Swift since CYLTagModel is a Swift class (docs/Swift-Migration.md, step 6): Objective-C cannot subclass a Swift
//  class, and this test counts the width reads of a tag through a subclass.
//

import CollectionViewClassifyMenu
import XCTest

private final class CYLCountingTagModel: CYLTagModel {
    var widthReads = 0

    override var width: CGFloat {
        widthReads += 1
        return super.width
    }
}

final class CYLTagGroupRowTests: XCTestCase {

    func testRowCalculationIsLinearAndInvalidatedWhenItemsChange() {
        let model = CYLCountingTagModel(title: "长标签 😀")
        let items = Array(repeating: model as CYLTagModel, count: 1200)
        let group = CYLTagGroup()
        group.items = items
        model.widthReads = 0
        let rows = group.cellCountsPerRow
        XCTAssertEqual(rows.reduce(0, +), items.count)
        XCTAssertEqual(model.widthReads, items.count)
        group.items = [CYLTagModel(title: "替换后的数据 🌟")]
        XCTAssertEqual(group.cellCountsPerRow, [1])
    }
}
