//
//  APIServiceTests.swift
//  APIServiceTests
//
//  Created by Artur Rymarz on 14/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

private struct TestEndpoint: Endpoint {

    struct Response: Decodable {

        let value: String
    }

    let path: String = "test"
    let method: HTTPMethod = .post

    func encodedBody() throws -> Data? {
        nil
    }

    func decode(data: Data) throws -> Response {
        Response(value: "value")
    }
}

class APIServiceTests: XCTestCase {

    // MARK: Setup

    override func setUp() {
        super.setUp()
    }

    // MARK: Tests

    func testCallEndpoint_simpleRequestCreated_closureIsCalledWithSuccessResult() {
        // Given
        let sessionMock = NetworkSessionMock()
        sessionMock.data = Data()

        let url = URL(string: "https://test.com")! // swiftlint:disable:this force_unwrapping

        let service = APIService(apiUrl: url, apiKey: "test_key", session: sessionMock)
        let endpoint = TestEndpoint()

        let expectation = self.expectation(description: "request made")

        // When
        var testResponse: TestEndpoint.Response?
        service.call(endpoint) { result in
            switch result {
            case .failure:
                break
            case .success(let response):
                testResponse = response

                expectation.fulfill()
            }
        }

        // Then
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertNotNil(testResponse, "Decoded response should not be nil")
    }
}
