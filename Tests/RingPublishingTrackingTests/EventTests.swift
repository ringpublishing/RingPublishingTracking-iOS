//
//  EventTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 27/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class EventTests: XCTestCase {

    // MARK: Tests

    func testIsValidJSONObject_correctParameterProvided_jsonObjectIsValid() {
        // Given
        let event = Event(eventName: "name",
                          eventParameters: [
                            "correctValue": "value"
                          ])

        // When
        let isValid = event.isValidJSONObject

        // Then
        XCTAssertTrue(isValid)
    }

    func testSizeInBytes_sampleEventCreated_sizeInBytesIsCorrect() {
        // Given
        let event = Event(analyticsSystemName: "a", eventName: "b", eventParameters: ["c": "d"])

        // When
        let sizeInBytes = event.sizeInBytes

        // Then
        XCTAssertEqual(sizeInBytes, 36, "Size in bytes should be correct")
    }

    func testDecorated_sampleEventCreatedAndDecoratorProvided_eventIsDecorated() {
        // Given
        let event = Event(analyticsSystemName: "a", eventName: "b", eventParameters: ["c": "d"])
        let decorator = SizeDecorator()

        // When
        let decorated = event.decorated(using: [decorator])

        // Then
        let keys = decorated.eventParameters.keys
        XCTAssertTrue(keys.contains("CS"))
        XCTAssertTrue(keys.contains("CW"))
    }

    func testDecorated_eventProvidesParameterAlsoSetByDecorator_valueFromEventIsKept() {
        // Given
        let event = Event(analyticsSystemName: "a", eventName: "b", eventParameters: ["RDLC": "value from event"])
        let decorator = ClientDecorator()

        // When
        let decorated = event.decorated(using: [decorator])

        // Then
        XCTAssertEqual(decorated.eventParameters["RDLC"], "value from event", "Value provided by the event should win")
    }

    func testEquatable_twoEventsWithSameParameters_eventsAreNotEqual() {
        // Given
        let firstEvent = Event(analyticsSystemName: "a", eventName: "b", eventParameters: ["c": "d"])
        let secondEvent = Event(analyticsSystemName: "a", eventName: "b", eventParameters: ["c": "d"])

        // When
        let areEventsEqual = firstEvent == secondEvent

        // Then
        XCTAssertFalse(areEventsEqual)
    }
}
