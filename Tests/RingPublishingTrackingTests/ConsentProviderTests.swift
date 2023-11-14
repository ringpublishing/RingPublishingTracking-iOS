//
//  ConsentProviderTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 27/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class ConsentProviderTests: XCTestCase {

    // MARK: Tests
    func testtcfv2_IABTCF_TCStringNotFilled_noValueReturned() {
        // Given
        let provider = ConsentProvider()

        // When
        let tcfv2 = provider.tcfv2

        // Then
        XCTAssertNil(tcfv2, "tcfv2 should be nil")
    }
}
