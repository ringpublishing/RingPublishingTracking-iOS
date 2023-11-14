//
//  MD5Tests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 14/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class MD5Tests: XCTestCase {

    // MARK: Tests
    func testMd5_exampleEmailProvided_createdMD5HashIsCorrect() {
        // Given
        let email = "example.mail@onet.pl"

        // When
        let md5 = email.md5()

        // Then
        XCTAssertEqual(md5, "5281143ec814ea2c66a4b1914a0135b7", "Created MD5 hash should be correct")
    }
}
