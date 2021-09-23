//
//  LoggerTests.swift
//  AppTrackingTests
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
}
