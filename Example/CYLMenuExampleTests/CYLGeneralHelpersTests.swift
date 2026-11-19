//
//  CYLGeneralHelpersTests.swift
//  CYLMenuExampleTests
//
//  The core's general helpers that match Android: the UIView frame, border, corner, layer, tap and capture helpers
//  (UIView+CYLGeneral, Android CYLGeneralExtensions.kt), the multiple filter's state (CYLFilterParamsTool) and
//  CYLTag.resetColors().
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
@testable import CYLMenuExample

final class CYLGeneralHelpersTests: CYLMenuExampleTestCase {

    func testFrameHelpersSetAndReadTheFrame() {
        let view = UIView(frame: CGRect(x: 10, y: 20, width: 100, height: 40))
        XCTAssertEqual(view.cylX, 10)
        XCTAssertEqual(view.cylY, 20)
        XCTAssertEqual(view.cylWidth, 100)
        XCTAssertEqual(view.cylHeight, 40)
        XCTAssertEqual(view.cylMaxX, 110)
        XCTAssertEqual(view.cylMaxY, 60)
        view.cylSetWidth(80)
        view.cylSetHeight(30)
        XCTAssertEqual(view.frame, CGRect(x: 10, y: 20, width: 80, height: 30), "The origin stays")
        view.cylSetX(5)
        view.cylSetY(6)
        XCTAssertEqual(view.frame, CGRect(x: 5, y: 6, width: 80, height: 30), "The size stays")
        view.cylSetSize(CGSize(width: 50, height: 20))
        XCTAssertEqual(view.frame, CGRect(x: 5, y: 6, width: 50, height: 20))
    }

    func testCenteringHelpersRoundUpAsOnAndroid() {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 101, height: 51))
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        view.cylHorizontalCenter(withWidth: 101)
        view.cylVerticalCenter(withHeight: 51)
        XCTAssertEqual(view.frame.origin, CGPoint(x: 31, y: 16), "ceil((101 - 40) / 2), ceil((51 - 20) / 2)")
        let alone = UIView(frame: CGRect(x: 3, y: 4, width: 10, height: 10))
        alone.cylHorizontalCenterInSuperview()
        alone.cylVerticalCenterInSuperview()
        XCTAssertEqual(alone.frame.origin, CGPoint(x: 3, y: 4), "Nothing happens without a superview")
        container.addSubview(alone)
        alone.cylHorizontalCenterInSuperview()
        alone.cylVerticalCenterInSuperview()
        XCTAssertEqual(alone.frame.origin, CGPoint(x: 46, y: 21))
    }

    func testBorderCornerLayerTapAndSnapshotHelpers() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 44))
        view.cylSetBorderWidth(2, color: .red)
        XCTAssertEqual(view.layer.borderWidth, 2)
        XCTAssertEqual(view.layer.borderColor, UIColor.red.cgColor)
        view.cylSetBorderWidth(-1, color: .red)
        XCTAssertEqual(view.layer.borderWidth, 0, "A negative width is 0")
        view.cylSetCornerRadius(8)
        XCTAssertEqual(view.layer.cornerRadius, 8)
        XCTAssertTrue(view.clipsToBounds, "Rounded views clip, as Android's clipToOutline")
        view.cylSetCornerRadius(0)
        XCTAssertFalse(view.clipsToBounds)
        let line = view.cylAddLineLayer(frame: CGRect(x: 0, y: 43, width: 300, height: 1), color: .gray)
        XCTAssertTrue(line.superlayer === view.layer)
        XCTAssertEqual(line.frame.maxY, 44)
        view.cylAddTapTarget(self, action: #selector(tapped))
        XCTAssertTrue(view.gestureRecognizers?.contains { $0 is UITapGestureRecognizer } ?? false)
        XCTAssertEqual(view.cylSnapshot().size, CGSize(width: 270, height: 44), "270 points wide, as Android's cyl_capture")
        XCTAssertEqual(view.cylSnapshot(width: 120).size, CGSize(width: 120, height: 44))
    }

    @objc private func tapped() {}

    func testFilterParamsToolSelectsTheFirstItemOfEverySection() {
        let tool = CYLFilterParamsTool()
        tool.dataSources = [["全部", "北京", "上海"], ["全部", "川菜"]]
        XCTAssertEqual(tool.filterParamsArray, [[true, false, false], [true, false]])
        XCTAssertEqual(tool.filterParamsDictionary[kMultipleFilterSettingModified] as? Bool, false)
        XCTAssertEqual(tool.filterParamsDictionary[kMultipleFilterSetting] as? [[Bool]], tool.filterParamsArray)
        XCTAssertNotNil(tool.filterParamsContentDictionary["skilled"] as? [Any], "\"skilled\" by default")
        XCTAssertTrue(tool.filename.hasSuffix(kMultipleFilterSetting), "In the documents folder")
        tool.filterParamsArray = [[false, true, false], [true, false]]
        XCTAssertEqual(tool.filterParamsArray[0], [false, true, false], "Replaceable")
        tool.filename = "custom"
        XCTAssertEqual(tool.filename, "custom")
        let filter = CYLMultipleFilterController()
        XCTAssertTrue(filter.settingArray.isEmpty, "Free-form settings of a subclass, empty by default")
    }

    func testTagResetColorsGoesBackToTheListStyle() {
        let tag = CYLTag(title: "Swift", backgroundColor: .systemRed)
        tag.colors = CYLTagColors(backgroundColor: .systemRed, borderColor: .black, textColor: .white,
                                  selectedBackgroundColor: .systemBlue)
        XCTAssertTrue(tag.hasCustomStyle)
        tag.resetColors()
        XCTAssertNil(tag.backgroundColor)
        XCTAssertNil(tag.borderColor)
        XCTAssertNil(tag.textColor)
        XCTAssertNil(tag.selectedBackgroundColor)
        XCTAssertFalse(tag.hasCustomStyle, "Drawn with the list's style again, as Android's resetColors()")
    }
}
