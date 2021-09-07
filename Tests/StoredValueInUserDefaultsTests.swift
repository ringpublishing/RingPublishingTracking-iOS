//
//  StoredValueInUserDefaultsTests.swift
//  AppTrackingTests
//
//  Created by Adam Szeremeta on 07/09/2021.
//

import Foundation
import XCTest

class StoredValueInUserDefaultsTests: XCTestCase {

    @StoredValueInUserDefaults(key: "testString")
    var storedString: String?

    @StoredValueInUserDefaults(key: "testDate")
    var storedDate: Date?

    // MARK: Setup

    override func setUp() {
        super.setUp()

        storedString = nil
        storedDate = nil

        UserDefaults.resetStandardUserDefaults()
    }

    // MARK: Tests

    func testStoredValueWithString_setNewValue_valueIsAccessibleWithWrapper() {
        // Given
        let value = "This is a test"

        // When
        storedString = value

        // Then
        XCTAssertEqual(storedString, value, "Value should be accessible and stored")
    }

    func testStoredValueWithString_setNewValueAndRemoveIt_valueIsNotAccessibleWithWrapper() {
        // Given
        let value = "This is a test"
        storedString = value

        // When
        storedString = nil

        // Then
        XCTAssertEqual(storedString, nil, "Value should not be accessible and not stored")
    }

    func testStoredValueWithString_setNewValueAndUpdateIt_updatedValueIsAccessibleWithWrapper() {
        // Given
        let value = "This is a test"
        storedString = value

        // When
        let updatedValue = "This is updated vvalue"
        storedString = updatedValue

        // Then
        XCTAssertEqual(storedString, updatedValue, "Updated value should be accessible and stored")
    }

    func testStoredValueWithDate_setNewValue_valueIsAccessibleWithWrapper() {
        // Given
        let value = Date()

        // When
        storedDate = value

        // Then
        XCTAssertEqual(storedDate?.timeIntervalSince1970, value.timeIntervalSince1970, "Date should be accessible and stored")
    }

    func testStoredValueWithDate_setNewValueAndRemoveIt_valueIsNotAccessibleWithWrapper() {
        // Given
        let value = Date()
        storedDate = value

        // When
        storedDate = nil

        // Then
        XCTAssertEqual(storedDate, nil, "Date should not be accessible and not stored")
    }

    func testStoredValueWithDate_setNewValueAndUpdateIt_updatedValueIsAccessibleWithWrapper() {
        // Given
        let value = Date()
        storedDate = value

        // When
        let updatedValue = Date(timeIntervalSince1970: 12345)
        storedDate = updatedValue

        // Then
        XCTAssertEqual(storedDate, updatedValue, "Updated date should be accessible and stored")
    }
}
