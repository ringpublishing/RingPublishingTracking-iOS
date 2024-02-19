//
//  AureusTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 18/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class AureusTests: XCTestCase {

    let ringPublishingTracking = RingPublishingTracking.shared

    // MARK: Setup

    override func setUp() {
        super.setUp()

        let configuration = RingPublishingTrackingConfiguration(tenantId: "tenantID", apiKey: "some_api_key", applicationRootPath: "/")
        ringPublishingTracking.eventsService =  EventsService(storage: StaticStorage(),
                                                              configuration: configuration,
                                                              eventsFactory: EventsFactory(),
                                                              operationMode: OperationMode())
    }

    override func tearDown() {
        super.tearDown()

        let allEvents = ringPublishingTracking.eventsService?.eventsQueueManager.events.allElements ?? []
        ringPublishingTracking.eventsService?.eventsQueueManager.events.removeItems(allEvents)
        ringPublishingTracking.eventsService = nil
    }

    // MARK: Tests
    func testReportAureusImpressionteasersAndContexProvided_properlyReportedEvent() {
        // Given
        let expectation = XCTestExpectation(description: "Report Aureus Offers Impressions")

        let teasers = [
            AureusTeaser(teaserId: "teaser_id_1", contentId: "content_id_1"),
            AureusTeaser(teaserId: "teaser_id_2", contentId: "content_id_2")
        ]
        let aureusContext = AureusEventContext(clientUuid: "581ad584-2333-4e69-8963-c105184cfd04",
                                               variantUuid: "0e8c860f-006a-49ef-923c-38b8cfc7ca57",
                                               batchId: "79935e2327",
                                               recommendationId: "e4b25216db",
                                               segmentId: "group1.segment1")

        // When
        ringPublishingTracking.reportAureusImpression(for: teasers, eventContext: aureusContext)

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            let request = self.ringPublishingTracking.eventsService?.buildEventRequest()
            let event = request?.events.first
            let params = event?.eventParameters

            let expectedItems = [
                ["content_id": "content_id_1", "teaser_id": "teaser_id_1"],
                ["teaser_id": "teaser_id_2", "content_id": "content_id_2"]
            ]

            XCTAssertEqual(params?["batch_id"], "79935e2327", "batch_id parameter should be correct")
            XCTAssertEqual(params?["variant_uuid"], "0e8c860f-006a-49ef-923c-38b8cfc7ca57", "variant_uuid parameter should be correct")
            XCTAssertEqual(params?["recommendation_id"], "e4b25216db", "recommendation_id parameter should be correct")
            XCTAssertEqual(params?["segment_id"], "group1.segment1", "recommendation_id parameter should be correct")
            XCTAssertEqual(params?["client_uuid"], "581ad584-2333-4e69-8963-c105184cfd04", "recommendation_id parameter should be correct")
            XCTAssertEqual(params?["displayed_items"], expectedItems, "recommendation_id parameter should be correct")

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
        let teaser = AureusTeaser(teaserId: "teaser_id_1", contentId: contentId.uuidString)
        let aureusContext = AureusEventContext(clientUuid: "581ad584-2333-4e69-8963-c105184cfd04",
                                               variantUuid: "0e8c860f-006a-49ef-923c-38b8cfc7ca57",
                                               batchId: "79935e2327",
                                               recommendationId: "e4b25216db",
                                               segmentId: "group1.segment1")

        // When
        ringPublishingTracking.reportContentClick(selectedElementName: selectedElementName,
                                                  publicationUrl: publicationUrl,
                                                  aureusOfferId: aureusOfferId,
                                                  teaser: teaser,
                                                  eventContext: aureusContext)

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
}
