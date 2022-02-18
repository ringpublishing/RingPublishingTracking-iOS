//
//  AtomicArrayTests.swift
//  RingPublishingTrackingTests
//
//  Created by Adam Szeremeta on 18/02/2022.
//  Copyright © 2022 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import XCTest

class AtomicArrayTests: XCTestCase {

    // MARK: Tests

    func testAppend_sampleEventsAddedToArray_allElementsAreReturned() {
        // Given
        let array = AtomicArray<Event>()
        let firstEvent = Event(analyticsSystemName: "a", eventName: "b", eventParameters: ["c": "d"])
        let secondEvent = Event(analyticsSystemName: "a", eventName: "b", eventParameters: ["c": "d"])

        // When
        array.append(firstEvent)
        array.append(secondEvent)

        // Then
        XCTAssertEqual(array.allElements.count, 2, "Two elements should be in the array")
    }

    func testRemoveItems_sampleEventsAddedToArrayAndOneIsRemoved_allElementsAreRemoved() {
        // Given
        let array = AtomicArray<Event>()
        let firstEvent = Event(analyticsSystemName: "a", eventName: "b", eventParameters: ["c": "d"])
        let secondEvent = Event(analyticsSystemName: "a", eventName: "b", eventParameters: ["c": "d"])

        array.append(firstEvent)
        array.append(secondEvent)

        // When
        array.removeItems([firstEvent])

        // Then
        XCTAssertEqual(array.allElements.count, 1, "Array should have one element")
        XCTAssertTrue(array.allElements.contains(secondEvent), "Second event should be in the array")
    }

    func testRemoveItems_sampleEventsAddedToArrayAndRemoved_allElementsAreRemoved() {
        // Given
        let array = AtomicArray<Event>()
        let firstEvent = Event(analyticsSystemName: "a", eventName: "b", eventParameters: ["c": "d"])
        let secondEvent = Event(analyticsSystemName: "a", eventName: "b", eventParameters: ["c": "d"])

        array.append(firstEvent)
        array.append(secondEvent)

        // When
        array.removeItems([firstEvent, secondEvent])

        // Then
        XCTAssertEqual(array.allElements.count, 0, "Array should be empty")
    }

    func testRemoveItems_sampleEventsAddedToArrayAndMoreItemsAreRemoved_allElementsAreRemoved() {
        // Given
        let array = AtomicArray<Event>()
        let firstEvent = Event(analyticsSystemName: "a", eventName: "b", eventParameters: ["c": "d"])
        let secondEvent = Event(analyticsSystemName: "a", eventName: "b", eventParameters: ["c": "d"])
        let thirdEvent = Event(analyticsSystemName: "a", eventName: "b", eventParameters: ["c": "d"])

        array.append(firstEvent)
        array.append(secondEvent)

        // When
        array.removeItems([firstEvent, secondEvent, thirdEvent])

        // Then
        XCTAssertEqual(array.allElements.count, 0, "Array should be empty")
    }
}
