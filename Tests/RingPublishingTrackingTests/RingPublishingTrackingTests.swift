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
                                               paidContent: true,
                                               contentId: "6789",
                                               contentSpaceUuid: "1290")
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

    func testReportedEvents_viewTypeProvidedForContent_onlyContentEventCarriesViewTypeInClientData() throws {
        // Given
        let queueManager = RingPublishingTracking.shared.eventsService?.eventsQueueManager
        let publicationUrl = URL(string: "https://tests.example.com")! // swiftlint:disable:this force_unwrapping
        let contentMetadata = ContentMetadata(publicationId: "publicationId",
                                              publicationUrl: publicationUrl,
                                              sourceSystemName: "sourceSystemName",
                                              paidContent: false,
                                              contentId: "contentId",
                                              contentSpaceUuid: "contentSpaceUuid")

        // When
        RingPublishingTracking.shared.reportContentPageView(contentMetadata: contentMetadata,
                                                            viewType: .smartshort,
                                                            currentStructurePath: ["article"],
                                                            partiallyReloaded: false,
                                                            contentKeepAliveDataSource: nil)

        // Then
        let contentEvent = try XCTUnwrap(queueManager?.events.allElements.last)
        XCTAssertEqual(try decodedClientData(from: contentEvent),
                       "{\"client\":{\"type\":\"native_app\",\"viewType\":\"smartshort\"}}",
                       "Reported content page view should carry view type")

        // When
        RingPublishingTracking.shared.reportPageView(currentStructurePath: ["list"], partiallyReloaded: false)

        // Then
        let pageViewEvent = try XCTUnwrap(queueManager?.events.allElements.last)
        XCTAssertEqual(try decodedClientData(from: pageViewEvent),
                       "{\"client\":{\"type\":\"native_app\"}}",
                       "Reported page view should not carry view type")
    }

    func testReportContentPageView_noKeepAliveDataSourceProvided_keepAliveTrackingDoesNotStart() {
        // Given
        var reportedLogs = [String]()
        RingPublishingTracking.shared.loggerOutput = { reportedLogs.append($0) }

        let publicationUrl = URL(string: "https://tests.example.com")! // swiftlint:disable:this force_unwrapping
        let contentMetadata = ContentMetadata(publicationId: "publicationId",
                                              publicationUrl: publicationUrl,
                                              sourceSystemName: "sourceSystemName",
                                              paidContent: false,
                                              contentId: "contentId",
                                              contentSpaceUuid: "contentSpaceUuid")

        // When
        RingPublishingTracking.shared.reportContentPageView(contentMetadata: contentMetadata,
                                                            viewType: .smartshort,
                                                            currentStructurePath: ["article"],
                                                            partiallyReloaded: false,
                                                            contentKeepAliveDataSource: nil)

        // Then
        XCTAssertFalse(reportedLogs.contains { $0.contains("Starting content keep alive tracking") },
                       "Keep alive tracking should not start")
    }

    // MARK: Helpers

    private func decodedClientData(from event: Event) throws -> String {
        let clientData = try XCTUnwrap(event.eventParameters["RDLC"] as? String)
        let data = try XCTUnwrap(Data(base64Encoded: clientData))

        return try XCTUnwrap(String(data: data, encoding: .utf8))
    }
}
