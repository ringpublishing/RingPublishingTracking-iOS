//
//  RingPublishingTrackingTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 27/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

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

    func testDebugMode_optOutModeEnabledOrDisabled_moduleShouldDoNothing() {
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
        RingPublishingTracking.shared.setOptOutMode(enabled: true)
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

    // swiftlint:disable function_body_length
    func testEventsReporting_sampleDataProvided_eventsReportedCrorectly() {
        // Given
        let eventsQueueManager = RingPublishingTracking.shared.eventsService.eventsQueueManager
        RingPublishingTracking.shared.setOptOutMode(enabled: false)

        // When
        let event1 = Event(analyticsSystemName: "analyticsSystemName1",
                           eventName: "eventName1",
                           eventParameters: [:])
        RingPublishingTracking.shared.reportEvent(event1)

        // Then
        XCTAssertEqual(eventsQueueManager.events.allElements.count, 1, "Number of events in queue should be correct")

        // When
        RingPublishingTracking.shared.reportClick(selectedElementName: "element1")

        // Then
        XCTAssertEqual(eventsQueueManager.events.allElements.count, 2, "Number of events in queue should be correct")

        // When
        let publicationUrl1 = URL(string: "https://tests.example.com")! // swiftlint:disable:this force_unwrapping
        RingPublishingTracking.shared.reportContentClick(selectedElementName: "element2",
                                                         publicationUrl: publicationUrl1,
                                                         publicationId: "publicationId1")

        // Then
        XCTAssertEqual(eventsQueueManager.events.allElements.count, 3, "Number of events in queue should be correct")

        // When
        RingPublishingTracking.shared.reportUserAction(actionName: "actionName1",
                                                       actionSubtypeName: "subtype1",
                                                       parameters: ["key1": "value1"])

        // Then
        XCTAssertEqual(eventsQueueManager.events.allElements.count, 4, "Number of events in queue should be correct")

        // When
        RingPublishingTracking.shared.reportUserAction(actionName: "actionName2",
                                                       actionSubtypeName: "subtype2",
                                                       parameters: "param1")

        // Then
        XCTAssertEqual(eventsQueueManager.events.allElements.count, 5, "Number of events in queue should be correct")

        // When
        RingPublishingTracking.shared.reportPageView(currentStructurePath: ["path1"], partiallyReloaded: false)

        // Then
        XCTAssertEqual(eventsQueueManager.events.allElements.count, 6, "Number of events in queue should be correct")

        // When
        RingPublishingTracking.shared.reportPageView(currentStructurePath: ["path2"], partiallyReloaded: true)

        // Then
        XCTAssertEqual(eventsQueueManager.events.allElements.count, 7, "Number of events in queue should be correct")

        // When
        RingPublishingTracking.shared.reportPageView(currentStructurePath: ["path3"], partiallyReloaded: false)

        // Then
        XCTAssertEqual(eventsQueueManager.events.allElements.count, 8, "Number of events in queue should be correct")

        // When
        let publicationUrl2 = URL(string: "https://tests.example.com")! // swiftlint:disable:this force_unwrapping
        let contentMetadata1 = ContentMetadata(publicationId: "publicationId12",
                                               publicationUrl: publicationUrl2,
                                               sourceSystemName: "sourceSystemName1",
                                               contentWasPaidFor: true)
        RingPublishingTracking.shared.reportContentPageView(contentMetadata: contentMetadata1,
                                                            currentStructurePath: ["path4"],
                                                            partiallyReloaded: false,
                                                            contentKeepAliveDataSource: KeepAliveDataSourceStub())

        // No events since not enough time passed since starting keep alive event and no measurements taken
        RingPublishingTracking.shared.pauseContentKeepAliveTracking()
        RingPublishingTracking.shared.resumeContentKeepAliveTracking()
        RingPublishingTracking.shared.stopContentKeepAliveTracking()

        // Then
        XCTAssertEqual(eventsQueueManager.events.allElements.count, 9, "Number of events in queue should be correct")
    }
}
