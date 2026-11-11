//
//  CYLScreenshotCapturing.swift
//  Example-Shared/TestSupport
//
//  Shared by the test targets of Example/ and Example-Swift/: screenshots of the states the tests check.
//

import UIKit
import XCTest

/**
 * A test that records screenshots of the states it checks.
 *
 * Every screenshot is attached to the test result (kept even when the test passes, so it shows in Xcode's report
 * and in the `.xcresult` bundle). When the environment variable `CYL_TEST_SCREENSHOTS_DIR` is set (pass
 * `TEST_RUNNER_CYL_TEST_SCREENSHOTS_DIR=<folder>` to `xcodebuild test`, as `scripts/unit-tests.sh` does), it is
 * also written there as `<name>.png`.
 */
protocol CYLScreenshotCapturing {}

/**
 * The environment variable that names the folder for the PNG files.
 */
let CYLTestScreenshotsDirectoryKey = "CYL_TEST_SCREENSHOTS_DIR"

extension CYLScreenshotCapturing where Self: XCTestCase {

    /**
     * Renders `view` (on screen, in a window) and records it as `name`.
     */
    @discardableResult
    func captureScreenshot(of view: UIView, named name: String) -> UIImage {
        view.layoutIfNeeded()
        let format = UIGraphicsImageRendererFormat.preferred()
        let image = UIGraphicsImageRenderer(bounds: view.bounds, format: format).image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        if let directory = ProcessInfo.processInfo.environment[CYLTestScreenshotsDirectoryKey], !directory.isEmpty,
           let data = image.pngData() {
            let folder = URL(fileURLWithPath: directory, isDirectory: true)
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try? data.write(to: folder.appendingPathComponent(name).appendingPathExtension("png"))
        }
        return image
    }
}
