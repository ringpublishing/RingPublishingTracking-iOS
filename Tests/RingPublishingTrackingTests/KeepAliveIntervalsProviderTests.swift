//
//  KeepAliveIntervalsProviderTests.swift
//  RingPublishingTrackingTests
//
//  Created by Adam Szeremeta on 19/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

@testable import RingPublishingTracking
import XCTest

class KeepAliveIntervalsProviderTests: XCTestCase {

    let provider = KeepAliveIntervalsProvider()

    // MARK: Tests (Tracking)

    func testTrackingInterval_noElapsedTime_correctIntervalReturned() {
        // Given
        let elapsedTime: TimeInterval = 0

        // When
        let interval = provider.nextIntervalForContentMetaActivityTracking(for: elapsedTime)

        // Then
        XCTAssertEqual(1, interval, "Intervals should be equal")
    }

    func testTrackingInterval_smallElapsedTime_correctIntervalReturned() {
        // Given
        let elapsedTime: TimeInterval = 3

        // When
        let interval = provider.nextIntervalForContentMetaActivityTracking(for: elapsedTime)

        // Then
        XCTAssertEqual(1, interval, "Intervals should be equal")
    }

    func testTrackingInterval_elapsedTimeBetweenSteps_correctIntervalReturned() {
        // Given
        let elapsedTime: TimeInterval = 14.5

        // When
        let interval = provider.nextIntervalForContentMetaActivityTracking(for: elapsedTime)

        // Then
        XCTAssertEqual(3, interval, "Intervals should be equal")
    }

    func testTrackingInterval_maxElapsedTimes_correctIntervalReturned() {
        // Given
        let elapsedTime: TimeInterval = 51

        // When
        let interval = provider.nextIntervalForContentMetaActivityTracking(for: elapsedTime)

        // Then
        XCTAssertEqual(8, interval, "Intervals should be equal")
    }

    // MARK: Tests (Reporting)

    func testReportingInterval_noElapsedTime_correctIntervalReturned() {
        // Given
        let elapsedTime: TimeInterval = 0

        // When
        let interval = provider.nextIntervalForContentMetaActivitySending(for: elapsedTime)

        // Then
        XCTAssertEqual(5, interval, "Intervals should be equal")
    }

    func testReportingInterval_smallElapsedTime_correctIntervalReturned() {
        // Given
        let elapsedTime: TimeInterval = 40

        // When
        let interval = provider.nextIntervalForContentMetaActivitySending(for: elapsedTime)

        // Then
        XCTAssertEqual(20, interval, "Intervals should be equal")
    }

    func testReportingInterval_elapsedTimeBetweenSteps_correctIntervalReturned() {
        // Given
        let elapsedTime: TimeInterval = 190

        // When
        let interval = provider.nextIntervalForContentMetaActivitySending(for: elapsedTime)

        // Then
        XCTAssertEqual(60, interval, "Intervals should be equal")
    }

    func testReportingInterval_maxElapsedTime_correctIntervalReturned() {
        // Given
        let elapsedTime: TimeInterval = 901

        // When
        let interval = provider.nextIntervalForContentMetaActivitySending(for: elapsedTime)

        // Then
        XCTAssertEqual(300, interval, "Intervals should be equal")
    }

}
