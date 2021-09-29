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
        let eaUuid = EaUuid(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: creationDate)

        let storage = StaticStorage(eaUuid: eaUuid, trackingIds: nil, postInterval: nil)
        let service = EventsService(storage: storage)

        // Then
        XCTAssertTrue(service.isEaUuidValid, "The identifier should be valid")
    }

    func testIsEaUuidValid_eaUuidDateIsSetInFarPast_theIdentifierIsExpired() {
        // Given

        // Lifetime = 24h
        // Creation Date = 48 hours ago
        let creationDate = Date().addingTimeInterval(TimeInterval(-60 * 60 * 48))
        let eaUuid = EaUuid(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: creationDate)

        let storage = StaticStorage(eaUuid: eaUuid, trackingIds: nil, postInterval: nil)
        let service = EventsService(storage: storage)

        // Then
        XCTAssertFalse(service.isEaUuidValid, "The identifier should be expired")
    }

    func testIsEaUuidValid_eaUuidDateIsNotSet_theIdentifierIsInvalid() {
        // Given
        let storage = StaticStorage(eaUuid: nil, trackingIds: nil, postInterval: nil)
        let service = EventsService(storage: storage)

        // Then
        XCTAssertFalse(service.isEaUuidValid, "The identifier should be invalid")
    }

    func testStoredIds_sampleTrackingIdentifiersAddedToStorage_storedIdsAreProperlyLoaded() {
        // Given
        let creationDate = Date().addingTimeInterval(TimeInterval(-60 * 60 * 12))
        let eaUuid = EaUuid(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: creationDate)
        let storage = StaticStorage(eaUuid: eaUuid, trackingIds: [
            "key1": .init(value: "id1", lifetime: nil),
            "key2": .init(value: "id2", lifetime: nil),
            "key3": .init(value: "id3", lifetime: nil)
        ], postInterval: nil)
        let service = EventsService(storage: storage)

        // Then
        XCTAssertEqual(service.storedIds().count, 4, "Stored ids number should be correct")
    }
}
