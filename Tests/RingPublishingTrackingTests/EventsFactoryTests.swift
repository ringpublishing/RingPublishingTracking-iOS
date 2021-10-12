//
//  EventsFactoryTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 08/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import XCTest

class EventsFactoryTests: XCTestCase {

    // MARK: Setup

    override func setUp() {
        super.setUp()

    }

    // MARK: Tests

    // MARK: - ClickDecorator Tests

    func testCreateClickEvent_allParametersProvided_returnedEventIsDecorated() {
        // Given
        let elementName = "TestName"
        let sampleUrl = "https://test.com"
        let factory = EventsFactory()

        // Then
        let event = factory.createClickEvent(selectedElementName: elementName, publicationUrl: URL(string: sampleUrl))
        let params = event.eventParameters

        XCTAssertEqual(params["VE"], elementName, "VE should be correct")
        XCTAssertEqual(params["VU"], sampleUrl, "VE should be correct")
    }

    func testCreateClickEvent_noParametersProvided_returnedEventIsDecorated() {
        // Given
        let factory = EventsFactory()

        // Then
        let event = factory.createClickEvent(selectedElementName: nil, publicationUrl: nil)
        let params = event.eventParameters

        XCTAssertNil(params["VE"], "VE should be empty")
        XCTAssertNil(params["VU"], "VE should be empty")
    }
}
