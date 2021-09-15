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

    func decode(data: Data) throws -> Response? {
        Response(value: "value")
    }
}

class APIServiceTests: XCTestCase {

    // MARK: Setup

    override func setUp() {
        super.setUp()
    }

    // MARK: Tests

    func testApiService_sendSimpleRequest_closureIsCalledWithSuccessResult() {
        // Given
        let config = Configuration(tenantId: "test",
                                   apiKey: "test_key",
                                   publicationsRootName: "test_root_name",
                                   apiUrl: URL(string: "https://test.com"))
        let sessionMock = NetworkSessionMock()
        sessionMock.data = Data()

        let service = APIService(configuration: config, session: sessionMock)
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
            }

            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertEqual(testResponse?.value, "value", "Value of decoded response should match")
    }
}
