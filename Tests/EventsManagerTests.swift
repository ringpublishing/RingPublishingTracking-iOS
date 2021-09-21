//
//  EventsManagerTests.swift
//  AppTrackingTests
//
//  Created by Artur Rymarz on 21/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class EventsManagerTests: XCTestCase {

    // MARK: Setup

    override func setUp() {
        super.setUp()
    }

    // MARK: Tests

    func testEventsManager_setEaUuidDateInNearFuture_theIdentifierIsValid() {
        // Given

        // Lifetime = 24h
        // Creation Date = 12 hours ago
        let creationDate = Date().addingTimeInterval(TimeInterval(-60 * 60 * 12))
        let eaUuid = EaUuid(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: creationDate)

        let storage = StaticStorage(eaUuid: eaUuid, trackingIds: nil, postInterval: nil)
        let manager = EventsManager(storage: storage)

        // Then
        XCTAssertTrue(manager.isEaUuidValid, "The identifier should be valid")
    }

    func testEventsManager_storeIds_storedIdsAreProperlyLoaded() {
        // Given
        let creationDate = Date().addingTimeInterval(TimeInterval(-60 * 60 * 12))
        let eaUuid = EaUuid(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: creationDate)
        let storage = StaticStorage(eaUuid: eaUuid, trackingIds: [
            "key1": .init(value: "id1", lifetime: nil),
            "key2": .init(value: "id2", lifetime: nil),
            "key3": .init(value: "id3", lifetime: nil)
        ], postInterval: nil)
        let manager = EventsManager(storage: storage)

        // Then
        XCTAssertEqual(manager.storedIds().count, 4, "Stored ids number should be correct")
    }

    func testEventsManager_doNotSetEaUuid_theIdentifierIsInvalid() {
        // Given
        let storage = StaticStorage(eaUuid: nil, trackingIds: nil, postInterval: nil)
        let manager = EventsManager(storage: storage)

        // Then
        XCTAssertFalse(manager.isEaUuidValid, "The identifier should be invalid")
    }

    func testEventsManager_add5EventsToTheQueue_builtRequestContains5Events() {
        // Given
        let manager = EventsManager(storage: StaticStorage())

        // When
        manager.addEvents([
            Event.smallEvent(),
            Event.smallEvent(),
            Event.smallEvent(),
            Event.smallEvent(),
            Event.smallEvent()
        ])

        let request = manager.buildEventRequest()
        let events = request.events

        // Then
        XCTAssertEqual(events.count, 5, "Event request should contain proper number of events")
    }

    func testEventsManager_add1TooBigEventToTheQueue_builtRequestContains0Events() {
        // Given
        let manager = EventsManager(storage: StaticStorage())

        // When
        manager.addEvents([Event.tooBigEvent()])

        let request = manager.buildEventRequest()
        let events = request.events

        // Then
        XCTAssertEqual(events.count, 0, "Event request should contain proper number of events")
    }

    func testEventsManager_addEventsOverRequestBodySizeLimit_builtRequestBodySizeIsBelow1MB() {
        // Given
        let manager = EventsManager(storage: StaticStorage())

        let bodySizeLimit = Constants.requestBodySizeLimit
        let singleEventSize = Event.smallEvent().toReportedEvent().sizeInBytes

        // When
        let eventsAmount = Int(floor(Double(bodySizeLimit) / Double(singleEventSize))) + 1

        for _ in 0..<eventsAmount {
            manager.addEvents([Event.smallEvent()])
        }

        let request = manager.buildEventRequest()

        // Then
        XCTAssertLessThan(request.dictionary.jsonSizeInBytes,
                          bodySizeLimit,
                          "Event request body size should be below \(bodySizeLimit)")

        XCTAssertLessThan(request.events.count, eventsAmount, "Events above body size limit should not be added")
    }
}

private extension Event {
    func toReportedEvent() -> ReportedEvent {
        ReportedEvent(clientId: analyticsSystemName, eventType: eventName, data: eventParameters)
    }

    static func smallEvent() -> Self { // 190 bytes
        Event(eventParameters: [
            "key1": "value",
            "key2": "value",
            "key3": "value",
            "key4": "value",
            "key5": "value",
            "key6": "value",
            "key7": "value",
            "key8": "value",
            "key9": "value",
            "key10": "value"
        ])
    }

    static func tooBigEvent() -> Self { // over 16000 bytes
        Event(eventParameters: [
            // swiftlint:disable line_length
            "key": "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"
        ])
    }
}
