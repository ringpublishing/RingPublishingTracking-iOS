//
//  AureusTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 18/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

@testable import RingPublishingTracking
import XCTest

class AureusTests: XCTestCase {

    let ringPublishingTracking = RingPublishingTracking.shared

    // MARK: Setup

    override func setUp() {
        super.setUp()
        let configuration = RingPublishingTrackingConfiguration(tenantId: "tenantID", apiKey: "some_api_key", applicationRootPath: "/")
        ringPublishingTracking.eventsService =  EventsService(
            storage: StaticStorage(),
            configuration: configuration,
            eventsFactory: EventsFactory(),
            operationMode: OperationMode()
        )
    }

    override func tearDown() {
        super.tearDown()

        let allEvents = ringPublishingTracking.eventsService?.eventsQueueManager.events.allElements ?? []
        ringPublishingTracking.eventsService?.eventsQueueManager.events.removeItems(allEvents)
        ringPublishingTracking.eventsService = nil
    }

    // MARK: Tests
    func testReportAureusOffersImpressions_offerIdsProvided_properlyReportedEvent() {
        // Given
        let expectation = XCTestExpectation(description: "Report Aureus Offers Impressions")

        let offerIds = ["a1", "b2", "c3", "d4"]

        // When
        ringPublishingTracking.reportAureusOffersImpressions(offerIds: offerIds)

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            let request = self.ringPublishingTracking.eventsService?.buildEventRequest()
            let event = request?.events.first
            let params = event?.eventParameters

            XCTAssertEqual(params?["VE"], "aureusOfferImpressions", "VE parameter should be correct")
            XCTAssertEqual(params?["VC"], "offerIds", "VC parameter should be correct")
            XCTAssertEqual(params?["VM"], "%5B%22a1%22,%22b2%22,%22c3%22,%22d4%22%5D", "VM parameter should be in correct format")

            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 10.0)
    }

    func testReportContentClick_requiredDataProvided_properlyReportedEvent() {
        // Given
        let expectation = XCTestExpectation(description: "Report Content Click")

        let selectedElementName = "element_name"
        let publicationUrl = URL(string: "https://example.com/article?id=1")! // swiftlint:disable:this force_unwrapping
        let contentId = UUID()
        let aureusOfferId = "12345"

        // When
        ringPublishingTracking.reportContentClick(selectedElementName: selectedElementName,
                                                  publicationUrl: publicationUrl,
                                                  contentId: contentId.uuidString,
                                                  aureusOfferId: aureusOfferId)

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            let request = self.ringPublishingTracking.eventsService?.buildEventRequest()
            let event = request?.events.first
            let params = event?.eventParameters

            XCTAssertEqual(params?["VE"], selectedElementName, "VE parameter should be correct")
            XCTAssertEqual(params?["VU"], publicationUrl.absoluteString, "VC parameter should be correct")
            XCTAssertEqual(params?["PU"], contentId.uuidString, "PU parameter should be nil")
            XCTAssertEqual(params?["EI"], aureusOfferId, "EI parameter should be nil")

            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 10.0)
    }

    func testReportAureusOffersImpressions_noOfferIdsProvided_properlyReportedEvent() {
        // Given
        let expectation = XCTestExpectation(description: "Report Aureus Offers Impressions")

        let offerIds: [String] = []

        // When
        ringPublishingTracking.reportAureusOffersImpressions(offerIds: offerIds)

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            let request = self.ringPublishingTracking.eventsService?.buildEventRequest()
            let event = request?.events.first
            let params = event?.eventParameters

            XCTAssertEqual(params?["VE"], "aureusOfferImpressions", "VE parameter should be correct")
            XCTAssertEqual(params?["VC"], "offerIds", "VC parameter should be correct")
            XCTAssertNil(params?["VM"], "VM parameter should be nil")

            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 10.0)
    }
}
