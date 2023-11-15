//
//  IdentifyResponseTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 27/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class IdentifyResponseTests: XCTestCase {

    // MARK: Tests

    func testInit_allParametersProvided_configurationCreatedProperly() {
        // Given
        let value = "a1b2c3"
        let lifetime = 1000

        let response = IdentifyResponse(ids: [
            "eaUUID": .init(value: value, lifetime: lifetime)
        ],
                                        profile: .init(segments: nil),
                                        postInterval: 500)

        // When
        let eaUUID = response.eaUUID

        // Then
        XCTAssertEqual(eaUUID?.value, value)
        XCTAssertEqual(eaUUID?.lifetime, lifetime)
    }
}
