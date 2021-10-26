//
//  EventsServiceTests.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 29/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class EventsServiceTests: XCTestCase {

    // MARK: Setup

    override func setUp() {
        super.setUp()
    }

    // MARK: Tests

    func testIsEaUuidValid_eaUuidDateIsSetInNearPast_theIdentifierIsValid() {
        // Given

        // Lifetime = 24h
        // Creation Date = 12 hours ago
        let creationDate = Date().addingTimeInterval(TimeInterval(-60 * 60 * 12))
        let eaUuid = EaUUID(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: creationDate)

        let storage = StaticStorage(eaUUID: eaUuid, trackingIds: nil, postInterval: nil)
        let service = EventsService(storage: storage, eventsFactory: EventsFactory())

        // Then
        XCTAssertTrue(service.isEaUuidValid, "The identifier should be valid")
    }

    func testIsEaUuidValid_eaUuidDateIsSetInFarPast_theIdentifierIsExpired() {
        // Given

        // Lifetime = 24h
        // Creation Date = 48 hours ago
        let creationDate = Date().addingTimeInterval(TimeInterval(-60 * 60 * 48))
        let eaUuid = EaUUID(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: creationDate)

        let storage = StaticStorage(eaUUID: eaUuid, trackingIds: nil, postInterval: nil)
        let service = EventsService(storage: storage, eventsFactory: EventsFactory())

        // Then
        XCTAssertFalse(service.isEaUuidValid, "The identifier should be expired")
    }

    func testIsEaUuidValid_eaUuidDateIsNotSet_theIdentifierIsInvalid() {
        // Given
        let storage = StaticStorage(eaUUID: nil, trackingIds: nil, postInterval: nil)
        let service = EventsService(storage: storage, eventsFactory: EventsFactory())

        // Then
        XCTAssertFalse(service.isEaUuidValid, "The identifier should be invalid")
    }

    func testStoredIds_sampleTrackingIdentifiersAddedToStorage_storedIdsAreProperlyLoaded() {
        // Given
        let creationDate = Date().addingTimeInterval(TimeInterval(-60 * 60 * 12))
        let eaUuid = EaUUID(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: creationDate)
        let storage = StaticStorage(eaUUID: eaUuid, trackingIds: [
            "key1": .init(value: "id1", lifetime: nil),
            "key2": .init(value: "id2", lifetime: nil),
            "key3": .init(value: "id3", lifetime: nil)
        ], postInterval: nil)
        let service = EventsService(storage: storage, eventsFactory: EventsFactory())

        // Then
        XCTAssertEqual(service.storedIds().count, 4, "Stored ids number should be correct")
    }

    func testAddEvents_eventsOverRequestBodySizeLimitAddedToQueue_builtRequestBodySizeIsBelowSizeLimit() {
        // Given
        let storage = StaticStorage(eaUUID: nil, trackingIds: [
            "key1": .init(value: "id1", lifetime: nil),
            "key2": .init(value: "id2", lifetime: nil),
            "key3": .init(value: "id3", lifetime: nil)
        ], postInterval: nil)
        let service = EventsService(storage: storage, eventsFactory: EventsFactory())

        let bodySizeLimit = Constants.requestBodySizeLimit
        let singleEventSize = Event.smallEvent().sizeInBytes

        // When
        let eventsAmount = Int(floor(Double(bodySizeLimit) / Double(singleEventSize))) + 1

        for _ in 0..<eventsAmount {
            service.addEvents([Event.smallEvent()])
        }

        let request = service.buildEventRequest()

        // Then
        XCTAssertLessThan(request.dictionary.jsonSizeInBytes,
                          bodySizeLimit,
                          "Event request body size should be below \(bodySizeLimit)")

        XCTAssertLessThan(request.events.count, eventsAmount, "Events above body size limit should not be added")
    }

    func testAddEvents_eventsWithInvalidAddedToQueue_invalidEventsAreNotAdded() {
        // Given
        let storage = StaticStorage(eaUUID: nil, trackingIds: nil, postInterval: nil)
        let service = EventsService(storage: storage, eventsFactory: EventsFactory())

        // When
        let incorrectEvent = Event(eventParameters: [
            "test": URL(string: "https://test.com") // incorrect event, URL is not allowed in JSONSerialization
        ])

        let correctEvent = Event(eventName: "name", eventParameters: ["test": "value"])

        service.addEvents([incorrectEvent, correctEvent])

        let request = service.buildEventRequest()

        // Then
        XCTAssertEqual(request.events.count, 1, "Incorrect event should not be added")
    }

    func testShouldRetryIdentifyRequest_allRequredDataStored_shouldNotRetry() {
        // Given
        let creationDate = Date().addingTimeInterval(TimeInterval(-60 * 60 * 12))
        let eaUuid = EaUUID(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: creationDate)
        let storage = StaticStorage(eaUUID: eaUuid, trackingIds: [
            "key1": .init(value: "id1", lifetime: nil),
            "key2": .init(value: "id2", lifetime: nil),
            "key3": .init(value: "id3", lifetime: nil)
        ], postInterval: 500)

        let service = EventsService(storage: storage, eventsFactory: EventsFactory())

        // Then
        XCTAssertFalse(service.shouldRetryIdentifyRequest, "Identify request should not be retried")
    }

    func testShouldRetryIdentifyRequest_eaUUIDIsMissing_shouldRetry() {
        // Given
        let storage = StaticStorage(eaUUID: nil, trackingIds: [
            "key1": .init(value: "id1", lifetime: nil),
            "key2": .init(value: "id2", lifetime: nil),
            "key3": .init(value: "id3", lifetime: nil)
        ], postInterval: 500)

        let service = EventsService(storage: storage, eventsFactory: EventsFactory())

        // Then
        XCTAssertTrue(service.shouldRetryIdentifyRequest, "Identify request should be retried")
    }

    func testShouldRetryIdentifyRequest_postIntervalIsMissing_shouldRetry() {
        // Given
        let creationDate = Date().addingTimeInterval(TimeInterval(-60 * 60 * 12))
        let eaUuid = EaUUID(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: creationDate)
        let storage = StaticStorage(eaUUID: eaUuid, trackingIds: [
            "key1": .init(value: "id1", lifetime: nil),
            "key2": .init(value: "id2", lifetime: nil),
            "key3": .init(value: "id3", lifetime: nil)
        ], postInterval: nil)

        let service = EventsService(storage: storage, eventsFactory: EventsFactory())

        // Then
        XCTAssertTrue(service.shouldRetryIdentifyRequest, "Identify request should be retried")
    }
}
