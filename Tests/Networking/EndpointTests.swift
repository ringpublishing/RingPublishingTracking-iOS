//
//  EndpointTests.swift
//  EndpointTests
//
//  Created by Artur Rymarz on 15/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class EndpointTests: XCTestCase {

    // MARK: Setup

    let config = Configuration(tenantId: "test",
                               apiKey: "test_key",
                               publicationsRootName: "test_root_name",
                               apiUrl: URL(string: "https://test.com"))

    override func setUp() {
        super.setUp()
    }

    // MARK: Tests

    func testIdentifyEndpoint_sendIdentifyRequest_responseIsProperlyDecoded() {
        // Given
        let endpoint = IdentifyEnpoint(body: nil)

        let sessionMock = NetworkSessionMock()
        sessionMock.data = """
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
        """.data(using: .utf8)

        let service: APIService = APIService(configuration: config, session: sessionMock)

        let expectation = self.expectation(description: "request made")

        // When
        var testResponse: IdentityResponse?
        service.call(endpoint) { result in
            switch result {
            case .failure:
                break
            case .success(let response):
                testResponse = response
            }

            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertEqual(testResponse?.postInterval, 30000, "postInterval of decoded response should match")
    }

    func testSendEventEndpoint_sendEventsRequest_responseIsProperlyDecoded() {
        // Given
        let body = EventRequest(ids: ["eaUUID": "12345678"],
                                user: User(adpConsent: nil, pubConsent: nil),
                                events: [
                                    ReportedEvent(clientId: "service", eventType: "pv", data: [
                                        "key": "value",
                                        "key2": 1
                                    ])
                                ])
        let endpoint = SendEventEnpoint(body: body)

        let sessionMock = NetworkSessionMock()
        sessionMock.data = """
        {
            "postInterval": 30000
        }
        """.data(using: .utf8)

        let service: APIService = APIService(configuration: config, session: sessionMock)

        let expectation = self.expectation(description: "request made")

        // When
        var testResponse: EventResponse?
        service.call(endpoint) { result in
            switch result {
            case .failure:
                break
            case .success(let response):
                testResponse = response
            }

            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertEqual(testResponse?.postInterval, 30000, "postInterval of decoded response should match")
    }

}
