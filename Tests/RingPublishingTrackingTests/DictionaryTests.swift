//
//  DictionaryTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 21/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

@testable import RingPublishingTracking
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

    func testJsonSizeInBytes_invalidDictionaryCreated_returnedSizeInBytesIsZero() {
        // Given
        let specialString = String(bytes: [0xD8, 0x00] as [UInt8],
                                   encoding: String.Encoding.utf16BigEndian)
        var dictionary: [String: Any] = [:]
        dictionary["key"] = specialString

        // Then
        XCTAssertEqual(dictionary.jsonSizeInBytes, 0, "Size in bytes should be correct")

    }
}
