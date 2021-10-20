//
//  VendorManagerTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 07/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import XCTest

class VendorManagerTests: XCTestCase {

    // MARK: Setup

    override func setUp() {
        super.setUp()

    }

    // MARK: Tests

    func testRetrieveVendorIdentifier_mockedSourceProvided_identifierRetrieved() {
        // Given
        let mock = VendorIdentifierProviderMock()
        let manager = VendorManager(source: mock)

        let expectation = XCTestExpectation(description: "Vendor manager closure call")

        // When
        var uuid: UUID?
        manager.retrieveVendorIdentifier { result in
            switch result {
            case .failure:
                break
            case .success(let identifier):
                uuid = identifier
                expectation.fulfill()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            mock.fillIdentifier()
        }

        // Then
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(uuid, "Identifier should be filled")
    }
}
