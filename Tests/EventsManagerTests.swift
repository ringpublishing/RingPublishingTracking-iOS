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
}
