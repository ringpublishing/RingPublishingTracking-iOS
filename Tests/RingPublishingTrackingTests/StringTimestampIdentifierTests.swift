//
//  StringTimestampIdentifierTests.swift
//  RingPublishingTrackingTests
//
//  Created by Marcin Nowacki on 07/09/2026.
//

import XCTest

class StringTimestampIdentifierTests: XCTestCase {

    // MARK: Tests

    func testTimestampIdentifier_dateAndFormatProvided_datePartIsFormattedCorrectly() {
        // Given
        let date = Date(timeIntervalSince1970: 0)

        // When
        let identifier = String.timestampIdentifier(dateFormat: "yyyyMMddHHmmss", randomPartLength: 0, date: date)

        // Then
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"

        XCTAssertEqual(identifier, formatter.string(from: date))
    }

    func testTimestampIdentifier_randomPartLengthProvided_identifierHasCorrectLength() {
        // Given
        let dateFormat = "yyyyMMddHHmmss"
        let randomPartLength = 10

        // When
        let identifier = String.timestampIdentifier(dateFormat: dateFormat, randomPartLength: randomPartLength, date: Date())

        // Then
        XCTAssertEqual(identifier.count, dateFormat.count + randomPartLength)
    }

    func testTimestampIdentifier_randomPartLengthProvided_randomPartContainsOnlyDigits() {
        // Given
        let date = Date(timeIntervalSince1970: 0)

        for _ in 0...100 {
            // When
            let identifier = String.timestampIdentifier(dateFormat: "yyyyMMdd", randomPartLength: 10, date: date)
            let randomPart = identifier.dropFirst(8)

            // Then
            XCTAssertTrue(randomPart.allSatisfy(\.isNumber), "Random part should only contain digits")
        }
    }

    func testTimestampIdentifier_zeroRandomPartLengthProvided_identifierContainsOnlyDatePart() {
        // Given
        let date = Date(timeIntervalSince1970: 0)

        // When
        let identifier = String.timestampIdentifier(dateFormat: "yyyyMMdd", randomPartLength: 0, date: date)

        // Then
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"

        XCTAssertEqual(identifier, formatter.string(from: date))
    }

    func testTimestampIdentifier_calledTwice_generatedIdentifiersAreDifferent() {
        // Given
        let date = Date(timeIntervalSince1970: 0)

        // When
        let identifier1 = String.timestampIdentifier(dateFormat: "yyyyMMdd", randomPartLength: 10, date: date)
        let identifier2 = String.timestampIdentifier(dateFormat: "yyyyMMdd", randomPartLength: 10, date: date)

        // Then
        XCTAssertNotEqual(identifier1, identifier2)
    }
}
