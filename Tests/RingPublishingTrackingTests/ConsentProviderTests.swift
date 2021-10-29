//
//  ConsentProviderTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 27/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class ConsentProviderTests: XCTestCase {

    // MARK: Setup

    override func setUp() {
        super.setUp()
    }

    // MARK: Tests
    func testAdpc_IABTCF_TCStringNotFilled_noValueReturned() {
        // Given
        let provider = ConsentProvider()

        // When
        let adpc = provider.adpc

        // Then
        XCTAssertNil(adpc, "adpc should be nil")
    }
}
