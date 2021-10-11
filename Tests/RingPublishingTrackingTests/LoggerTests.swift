//
//  LoggerTests.swift
//  RingPublishingTrackingTests
//
//  Created by Adam Szeremeta on 08/09/2021.
//

import Foundation
import XCTest

class LoggerTests: XCTestCase {

    // MARK: Setup

    override func setUp() {
        super.setUp()

    }

    // MARK: Tests

    func testLog_setClosureAsLoggerOutputAndLogMessage_closureIsCalledByLogger() {
        // Given
        let logger = Logger.shared
        let message = "Message to log"

        let expectation = XCTestExpectation(description: "Logger closure call")

        // When
        logger.loggerOutput = { _ in
            expectation.fulfill()
        }

        Logger.log(message)

        // Then
        wait(for: [expectation], timeout: 10.0)
    }

    func testLogable_noValueProvided_valueIsUnwrapperCorrectly() {
        let value: String? = nil

        XCTAssertEqual("\(value.logable)", "nil", "empty value should be logged as nil")
    }

    func testLogable_valueProvided_valueIsUnwrapperCorrectly() {
        let value: String? = "test"

        XCTAssertEqual("\(value.logable)", "test", "value should be logged correctly")
    }
}
