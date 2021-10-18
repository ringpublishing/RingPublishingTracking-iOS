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
    }

    // MARK: Tests
    func testReportAureusOffersImpressions_offerIdsProvided_properlyReportedEvent() {
        // Given
        let offerIds = ["a1", "b2", "c3", "d4"]

        // When
        ringPublishingTracking.reportAureusOffersImpressions(offerIds: offerIds)

        // Then
        let request = ringPublishingTracking.eventsService.buildEventRequest()
        let event = request.events.first
        let params = event?.eventParameters

        XCTAssertEqual(params?["VE"], "aureusOfferImpressions", "VE parameter should be correct")
        XCTAssertEqual(params?["VC"], "offerIds", "VC parameter should be correct")
        XCTAssertEqual(params?["VM"], "%5B%22a1%22,%22b2%22,%22c3%22,%22d4%22%5D", "VM parameter should be in correct format")
    }

    func testReportContentClick_requiredDataProvided_properlyReportedEvent() {
        // Given
        let selectedElementName = "element_name"
        let publicationUrl = URL(string: "https://example.com/article?id=1")! // swiftlint:disable:this force_unwrapping
        let publicationId = UUID()
        let aureusOfferId = "12345"

        // When
        ringPublishingTracking.reportContentClick(selectedElementName: selectedElementName,
                                                  publicationUrl: publicationUrl,
                                                  publicationId: publicationId.uuidString,
                                                  aureusOfferId: aureusOfferId)

        // Then
        let request = ringPublishingTracking.eventsService.buildEventRequest()
        let event = request.events.first
        let params = event?.eventParameters

        // Then
        XCTAssertEqual(params?["VE"], selectedElementName, "VE parameter should be correct")
        XCTAssertEqual(params?["VU"], publicationUrl.absoluteString, "VC parameter should be correct")
        XCTAssertEqual(params?["PU"], publicationId.uuidString, "PU parameter should be nil")
        XCTAssertEqual(params?["EI"], aureusOfferId, "EI parameter should be nil")
    }

    func testReportAureusOffersImpressions_noOfferIdsProvided_properlyReportedEvent() {
        // Given
        let offerIds: [String] = []

        // When
        ringPublishingTracking.reportAureusOffersImpressions(offerIds: offerIds)

        // Then
        let request = ringPublishingTracking.eventsService.buildEventRequest()
        let event = request.events.first
        let params = event?.eventParameters

        // Then
        XCTAssertEqual(params?["VE"], "aureusOfferImpressions", "VE parameter should be correct")
        XCTAssertEqual(params?["VC"], "offerIds", "VC parameter should be correct")
        XCTAssertNil(params?["VM"], "VM parameter should be nil")
    }
}
