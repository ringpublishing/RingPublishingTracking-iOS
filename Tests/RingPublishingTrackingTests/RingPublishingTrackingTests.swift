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

    func testEventsReporting_sampleDataProvided_eventsReportedCrorectly() {
        // Given
        let expectation = XCTestExpectation(description: "Events Reported Crorectly")

        let eventsQueueManager = RingPublishingTracking.shared.eventsService?.eventsQueueManager
        RingPublishingTracking.shared.setOptOutMode(enabled: false)

        // When
        let event1 = Event(analyticsSystemName: "analyticsSystemName1",
                           eventName: "eventName1",
                           eventParameters: [:])
        RingPublishingTracking.shared.reportEvent(event1)

        RingPublishingTracking.shared.reportClick(selectedElementName: "element1")

        let publicationUrl1 = URL(string: "https://tests.example.com")! // swiftlint:disable:this force_unwrapping
        RingPublishingTracking.shared.reportContentClick(selectedElementName: "element2",
                                                         publicationUrl: publicationUrl1,
                                                         contentId: "contentId1")

        RingPublishingTracking.shared.reportUserAction(actionName: "actionName1",
                                                       actionSubtypeName: "subtype1",
                                                       parameters: ["key1": "value1"])

        RingPublishingTracking.shared.reportUserAction(actionName: "actionName2",
                                                       actionSubtypeName: "subtype2",
                                                       parameters: "param1")

        RingPublishingTracking.shared.reportPageView(currentStructurePath: ["path1"], partiallyReloaded: false)

        RingPublishingTracking.shared.reportPageView(currentStructurePath: ["path2"], partiallyReloaded: true)

        RingPublishingTracking.shared.reportPageView(currentStructurePath: ["path3"], partiallyReloaded: false)

        let publicationUrl2 = URL(string: "https://tests.example.com")! // swiftlint:disable:this force_unwrapping
        let contentMetadata1 = ContentMetadata(publicationId: "publicationId12",
                                               publicationUrl: publicationUrl2,
                                               sourceSystemName: "sourceSystemName1",
                                               contentWasPaidFor: true,
                                               contentId: "6789")
        RingPublishingTracking.shared.reportContentPageView(contentMetadata: contentMetadata1,
                                                            currentStructurePath: ["path4"],
                                                            partiallyReloaded: false,
                                                            contentKeepAliveDataSource: KeepAliveDataSourceStub())

        // No events since not enough time passed since starting keep alive event and no measurements taken
        RingPublishingTracking.shared.pauseContentKeepAliveTracking()
        RingPublishingTracking.shared.resumeContentKeepAliveTracking()
        RingPublishingTracking.shared.stopContentKeepAliveTracking()

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            XCTAssertEqual(eventsQueueManager?.events.allElements.count, 9, "Number of events in queue should be correct")

            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 10.0)
    }
}
