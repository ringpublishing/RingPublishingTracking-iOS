//
//  StringTimestampIdentifierTests.swift
//  RingPublishingTrackingTests
//
//  Created by Marcin Nowacki on 07/09/2026.
//

import XCTest

class StringTimestampIdentifierTests: XCTestCase {

    func testTimestampIdentifier_dateAndFormatterProvided_datePartIsFormattedCorrectly() {
        // Given
        let date = Date(timeIntervalSince1970: 0)
        let formatter = makeFormatter(dateFormat: "yyyyMMddHHmmss")

        // When
        let identifier = String.timestampIdentifier(dateFormatter: formatter, randomPartLength: 0, date: date)

        // Then
        XCTAssertEqual(identifier, formatter.string(from: date))
    }

    func testTimestampIdentifier_randomPartLengthProvided_identifierHasCorrectLength() {
        // Given
        let dateFormat = "yyyyMMddHHmmss"
        let formatter = makeFormatter(dateFormat: dateFormat)
        let randomPartLength = 10

        // When
        let identifier = String.timestampIdentifier(dateFormatter: formatter, randomPartLength: randomPartLength, date: Date())

        // Then
        XCTAssertEqual(identifier.count, dateFormat.count + randomPartLength)
    }

    func testTimestampIdentifier_randomPartLengthProvided_randomPartContainsOnlyDigits() {
        // Given
        let date = Date(timeIntervalSince1970: 0)
        let formatter = makeFormatter(dateFormat: "yyyyMMdd")

        for _ in 0...100 {
            // When
            let identifier = String.timestampIdentifier(dateFormatter: formatter, randomPartLength: 10, date: date)
            let randomPart = identifier.dropFirst(8)

            // Then
            XCTAssertTrue(randomPart.allSatisfy(\.isNumber), "Random part should only contain digits")
        }
    }

    func testTimestampIdentifier_zeroRandomPartLengthProvided_identifierContainsOnlyDatePart() {
        // Given
        let date = Date(timeIntervalSince1970: 0)
        let formatter = makeFormatter(dateFormat: "yyyyMMdd")

        // When
        let identifier = String.timestampIdentifier(dateFormatter: formatter, randomPartLength: 0, date: date)

        // Then
        XCTAssertEqual(identifier, formatter.string(from: date))
    }

    func testTimestampIdentifier_calledTwice_generatedIdentifiersAreDifferent() {
        // Given
        let date = Date(timeIntervalSince1970: 0)
        let formatter = makeFormatter(dateFormat: "yyyyMMdd")

        // When
        let identifier1 = String.timestampIdentifier(dateFormatter: formatter, randomPartLength: 10, date: date)
        let identifier2 = String.timestampIdentifier(dateFormatter: formatter, randomPartLength: 10, date: date)

        // Then
        XCTAssertNotEqual(identifier1, identifier2)
    }
}

private extension StringTimestampIdentifierTests {
    
    func makeFormatter(dateFormat: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        return formatter
    }
}
