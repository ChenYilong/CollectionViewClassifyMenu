//
//  CYLTagButtonStaticImageTests.swift
//  CYLTagEditorExampleTests
//
//  CYLTagButton without an animation engine: this example's Podfile adds CYLTabBarController without any
//  CYLAnimatedItem<Type> engine subspec, as an app that never animates. The tag inherits CYLAnimatedItemView's display
//  priority (https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md):
//  the static image when the animation cannot play, the component's placeholder only without a static image, nothing
//  for a title alone; the playback methods do nothing.
//

import XCTest
import UIKit
import CYLTabBarController
import CollectionViewClassifyMenu
@testable import CYLTagEditorExample

final class CYLTagButtonStaticImageTests: CYLTagEditorTestCase {

    private func animationFile() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("cyl-tag-static.json")
        try Data(#"{"v":"5.7.0","fr":30,"ip":0,"op":30,"w":24,"h":24,"layers":[]}"#.utf8).write(to: url)
        return url
    }

    func testWithoutAnEngineTheStaticImageShowsAndPlaybackDoesNothing() throws {
        XCTAssertFalse(CYLTagButton.isAnimationEngineAvailable, "No CYLAnimatedItem<Type> engine subspec in this example")
        let url = try animationFile()
        let image = UIImage(systemName: "house")
        let animated = CYLTagButton(title: "Home", image: image, animationURL: url)
        let plain = CYLTagButton(title: "Home", image: image)
        animated.layoutIfNeeded()
        plain.layoutIfNeeded()
        XCTAssertNil(animated.animationView, "No engine: no animation view")
        XCTAssertFalse(animated.isAnimationReady)
        XCTAssertTrue(animated.imageView.image === image, "The static image, not the placeholder")
        XCTAssertFalse(animated.imageView.isHidden)
        XCTAssertEqual(animated.intrinsicContentSize, plain.intrinsicContentSize, "The layout of the image alone")
        XCTAssertEqual(animated.imageView.frame, plain.imageView.frame)
        XCTAssertEqual(animated.titleLabel.frame, plain.titleLabel.frame)
        animated.playAnimation()
        animated.restartAnimation()
        animated.stopAnimation()
        animated.showAnimationLastFrame()
        animated.isSelected = true
        XCTAssertEqual(animated.animationURL, url, "Kept: it plays once an engine subspec is added")
    }

    func testAPlaceholderShowsOnlyWithoutAStaticImage() throws {
        let url = try animationFile()
        let image = UIImage(systemName: "star")
        let withImage = CYLTagButton(title: "Star", image: image, animationURL: url)
        XCTAssertTrue(withImage.imageView.image === image, "A static image wins over the placeholder")
        let withoutImage = CYLTagButton(title: "Star", image: nil, animationURL: url)
        withoutImage.layoutIfNeeded()
        if let placeholder = CYLAnimatedItemView.defaultPlaceholderImage {
            XCTAssertNotNil(withoutImage.imageView.image, "No static image: the component's placeholder")
            XCTAssertEqual(withoutImage.imageView.image?.size, placeholder.size)
            XCTAssertGreaterThan(withoutImage.imageView.frame.width, 0, "Laid out in the icon slot")
        }
        let titleOnly = CYLTagButton(title: "Star", image: nil)
        titleOnly.layoutIfNeeded()
        XCTAssertNil(titleOnly.imageView.image, "A title without an icon never shows a placeholder")
        XCTAssertEqual(titleOnly.imageView.frame.size, .zero)
    }

    func testTheDeleteIndicatorIsTheAccessory() {
        let tag = CYLTagButton(title: "Swift", image: nil)
        XCTAssertTrue(tag.accessoryView === tag.deleteIndicatorLabel)
        XCTAssertTrue(tag.deleteIndicatorLabel.isHidden)
        tag.showsDeleteIndicator = true
        tag.frame.size = tag.intrinsicContentSize
        tag.layoutIfNeeded()
        XCTAssertFalse(tag.deleteIndicatorLabel.isHidden)
        XCTAssertGreaterThan(tag.deleteIndicatorLabel.frame.minX, tag.titleLabel.frame.maxX)
        XCTAssertNotNil(tag.deleteIndicatorLabel.accessibilityLabel, "Named for the accessory's VoiceOver action")
        XCTAssertEqual(tag.accessibilityLabel, "Swift")
    }
}
