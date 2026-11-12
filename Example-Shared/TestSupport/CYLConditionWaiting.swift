//
//  CYLConditionWaiting.swift
//  Example-Shared/TestSupport
//
//  Shared by the test targets of Example/ and Example-Swift/: waits for asynchronous work without fixed sleeps.
//

import XCTest

/**
 * A test that waits until a condition holds, polling it on the main run loop.
 */
protocol CYLConditionWaiting {}

extension CYLConditionWaiting where Self: XCTestCase {

    /**
     * Waits until `condition` returns true, failing after `timeout` seconds.
     */
    func waitUntil(timeout: TimeInterval = 10, _ condition: @escaping () -> Bool) {
        let predicate = NSPredicate { _, _ in condition() }
        wait(for: [XCTNSPredicateExpectation(predicate: predicate, object: nil)], timeout: timeout)
    }
}
