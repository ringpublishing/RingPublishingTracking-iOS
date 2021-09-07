//
//  AppTrackingTests.swift
//  AppTrackingTests
//
//  Created by Adam Szeremeta on 06/09/2021.
//

import XCTest

class AppTrackingTests: XCTestCase {

    // MARK: Tests

    func testWithPublicInterface() {
        // Given
        let appTracking = AppTracking()

        // When
        let publicValue = appTracking.samplePublicMethod()

        // Then
        XCTAssertEqual(publicValue, "Public", "Public value should match")
    }

    func testWithInternalInterface() {
        // Given
        let appTracking = AppTracking()

        // When
        let internalValue = appTracking.sampleInternalMethod()

        // Then
        XCTAssertEqual(internalValue, "Internal", "Internal value should match")
    }
}
