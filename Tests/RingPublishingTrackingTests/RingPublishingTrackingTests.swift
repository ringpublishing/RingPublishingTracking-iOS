//
//  RingPublishingTrackingTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 27/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class RingPublishingTrackingDelegateMock: RingPublishingTrackingDelegate {
    func ringPublishingTracking(_ ringPublishingTracking: RingPublishingTracking,
                                didAssignTrackingIdentifier identifier: TrackingIdentifier) {}
}

class RingPublishingTrackingTests: XCTestCase {
    let tenantId = "12345"
    let apiKey = "abcdef"
    let applicationRootPath = "RingPublishingTrackingTests"
    let applicationDefaultStructurePath = ["Default"]
    let applicationDefaultAdvertisementArea = "TestsAdvertisementArea"

    let ringPublishingTrackingDelegateMock = RingPublishingTrackingDelegateMock()

    // MARK: Setup

    override func setUp() {
        super.setUp()

        let configuration = RingPublishingTrackingConfiguration(tenantId: tenantId,
                                                                apiKey: apiKey,
                                                                apiUrl: nil,
                                                                applicationRootPath: applicationRootPath,
                                                                applicationDefaultStructurePath: applicationDefaultStructurePath,
                                                                applicationDefaultAdvertisementArea: applicationDefaultAdvertisementArea)

        RingPublishingTracking.shared.initialize(configuration: configuration, delegate: ringPublishingTrackingDelegateMock)
    }

    // MARK: Tests

    func testDebugMode_debugModeEnabledOrDisabled_logsShouldBeReported() {
        // Given
        let expectation1 = self.expectation(description: "log reported")
        expectation1.assertForOverFulfill = false

        // When
        RingPublishingTracking.shared.loggerOutput = { _ in
            expectation1.fulfill()
        }

        RingPublishingTracking.shared.updateApplicationAdvertisementArea(currentAdvertisementArea: "Test")

        // Then
        waitForExpectations(timeout: 1, handler: nil)

        // Given
        RingPublishingTracking.shared.setDebugMode(enabled: true)
        let expectation2 = self.expectation(description: "log reported")
        expectation2.assertForOverFulfill = false

        // When
        RingPublishingTracking.shared.loggerOutput = { _ in
            expectation2.fulfill()
        }

        RingPublishingTracking.shared.updateApplicationAdvertisementArea(currentAdvertisementArea: "Test")

        // Then
        waitForExpectations(timeout: 1, handler: nil)
    }
}
