//
//  DictionaryTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 21/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class DictionaryTests: XCTestCase {

    // MARK: Tests

    func testJsonSizeInBytes_sampleDictionaryCreated_returnedSizeInBytesIsCorrect() {
        // Given
        let emptyDictionary: [String: Any] = [:] // {}
        let dictionaryWithData: [String: Any] = [ // {"key":"value","key2":"value2"}
            "key": "value",
            "key2": "value2"
        ]

        // Then
        XCTAssertEqual(emptyDictionary.jsonSizeInBytes, 2, "Size in bytes should be correct")
        XCTAssertEqual(dictionaryWithData.jsonSizeInBytes, 31, "Size in bytes should be correct")
    }
}
