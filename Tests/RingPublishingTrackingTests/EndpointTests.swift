//
//  EndpointTests.swift
//  EndpointTests
//
//  Created by Artur Rymarz on 15/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class EndpointTests: XCTestCase {

    private let apiKey = "test_key"
    private let apiUrl = URL(string: "https://test.com")

    // MARK: Tests

    func testIdentifyRequestEncoding_sampleIdentifyEnpointCreated_encodedBodyIsReturned() {
        // Given
        let identifyRequest = IdentifyRequest(ids: [
            "id1": "value1",
            "id2": "value2"
        ], user: User(advertisementId: nil, deviceId: nil, tcfv2: nil))
        let endpoint = IdentifyEnpoint(body: identifyRequest)

        // When
        let encoded = try? endpoint.encodedBody()

        // Then
        XCTAssertNotNil(encoded)
    }

    func testIdentifyRequestDecoding_sampleIdentifyResponseDataCreated_decodedResponseIsReturned() {
        // Given
        let data = """
                {
                    "ids": {
                        "eaUUID": {
                            "value": "12345678",
                            "lifetime": 31536000
                        },
                        "tukanId": {
                            "value": null
                        }
                    },
                    "profile": {
                    },
                    "postInterval": 30000
                }
                """.data(using: .utf8)! // swiftlint:disable:this force_unwrapping

        // When
        let endpoint = IdentifyEnpoint(body: nil)
        let decoded = try? endpoint.decode(data: data)

        // Then
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.ids.count, 2, "number of ids of decoded response should match")
        XCTAssertNotNil(decoded?.profile, "profile of decoded response should be present")
        XCTAssertEqual(decoded?.postInterval, 30000, "postInterval of decoded response should match")
    }

    func testEventRequestEncoding_sampleSendEventEnpointCreated_encodedBodyIsReturned() {
        // Given
        let eventRequest = EventRequest(ids: [
            "id": "value"
        ], user: User(advertisementId: nil, deviceId: nil, tcfv2: nil), events: [
            Event(analyticsSystemName: "clientId", eventName: "eventType", eventParameters: ["key": "some value"])
        ])
        let endpoint = SendEventEnpoint(body: eventRequest)

        // When
        let encoded = try? endpoint.encodedBody()

        // Then
        XCTAssertNotNil(encoded)
    }

    func testEventRequestDecoding_sampleSendEventResponseDataCreated_decodedResponseIsReturned() {
        // Given
        let data = """
                {
                    "postInterval": 30000
                }
                """.data(using: .utf8)! // swiftlint:disable:this force_unwrapping

        // When
        let endpoint = SendEventEnpoint(body: .init(ids: [:], user: nil, events: []))
        let decoded = try? endpoint.decode(data: data)

        // Then
        XCTAssertEqual(decoded?.postInterval, 30000, "postInterval of decoded response should match")
    }
}
