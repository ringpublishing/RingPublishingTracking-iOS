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

    // MARK: - ClickEvent Tests

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

    // MARK: - UserActionEvent Tests

    func testCreateUserActionEvent_dictionaryParameterProvided_returnedEventIsDecorated() {
        // Given
        let parameters: [String: AnyHashable] = [
            "test": "value"
        ]
        let factory = EventsFactory()

        // Then
        let event = factory.createUserActionEvent(actionName: "name", actionSubtypeName: "subname", parameter: .parameters(parameters))
        let params = event.eventParameters

        XCTAssertEqual(params["VE"], "name", "VE should be correct")
        XCTAssertEqual(params["VC"], "subname", "VC should be correct")
        XCTAssertEqual(params["VM"], "{\"test\":\"value\"}", "VM should be correct")
    }

    func testCreateUserActionEvent_plainParameterProvided_returnedEventIsDecorated() {
        // Given
        let plainParameter = "test"
        let factory = EventsFactory()

        // Then
        let event = factory.createUserActionEvent(actionName: "name", actionSubtypeName: "subname", parameter: .plain(plainParameter))
        let params = event.eventParameters

        XCTAssertEqual(params["VE"], "name", "VE should be correct")
        XCTAssertEqual(params["VC"], "subname", "VC should be correct")
        XCTAssertEqual(params["VM"], plainParameter, "VM should be correct")
    }
}
