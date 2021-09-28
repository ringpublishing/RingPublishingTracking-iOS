//
//  StoredValueInUserDefaultsTests.swift
//  RingPublishingTrackingTests
//
//  Created by Adam Szeremeta on 07/09/2021.
//

import Foundation
import XCTest

class StoredValueInUserDefaultsTests: XCTestCase {

    // MARK: Setup

    override func setUp() {
        super.setUp()

    }

    // MARK: Tests

    func testStoredValueInUserDefaults_setNewStringValue_valueIsAccessibleWithWrapper() {
        // Given
        let storedValue = StoredValueInUserDefaultsWrapper()
        let value = "This is a test"

        // When
        storedValue.storedString = value

        // Then
        XCTAssertEqual(storedValue.storedString, value, "Value should be accessible and stored")
    }

    func testStoredValueInUserDefaults_setNewStringValueAndRemoveIt_valueIsNotAccessibleWithWrapper() {
        // Given
        let storedValue = StoredValueInUserDefaultsWrapper()
        let value = "This is a test"

        // When
        storedValue.storedString = value
        storedValue.storedString = nil

        // Then
        XCTAssertEqual(storedValue.storedString, nil, "Value should not be accessible and not stored")
    }

    func testStoredValueInUserDefaults_setNewStringValueAndUpdateIt_updatedValueIsAccessibleWithWrapper() {
        // Given
        let storedValue = StoredValueInUserDefaultsWrapper()
        let value = "This is a test"

        // When
        storedValue.storedString = value

        let updatedValue = "This is updated vvalue"
        storedValue.storedString = updatedValue

        // Then
        XCTAssertEqual(storedValue.storedString, updatedValue, "Updated value should be accessible and stored")
    }

    func testStoredValueInUserDefaults_setNewDateValue_valueIsAccessibleWithWrapper() {
        // Given
        let storedValue = StoredValueInUserDefaultsWrapper()
        let value = Date()

        // When
        storedValue.storedDate = value

        // Then
        XCTAssertEqual(storedValue.storedDate?.timeIntervalSince1970, value.timeIntervalSince1970, "Date should be accessible and stored")
    }

    func testStoredValueInUserDefaults_setNewDateValueAndRemoveIt_valueIsNotAccessibleWithWrapper() {
        // Given
        let storedValue = StoredValueInUserDefaultsWrapper()
        let value = Date()

        // When
        storedValue.storedDate = value
        storedValue.storedDate = nil

        // Then
        XCTAssertEqual(storedValue.storedDate, nil, "Date should not be accessible and not stored")
    }

    func testStoredValueInUserDefaults_setNewDateValueAndUpdateIt_updatedValueIsAccessibleWithWrapper() {
        // Given
        let storedValue = StoredValueInUserDefaultsWrapper()
        let value = Date()

        // When
        storedValue.storedDate = value

        let updatedValue = Date(timeIntervalSince1970: 12345)
        storedValue.storedDate = updatedValue

        // Then
        XCTAssertEqual(storedValue.storedDate, updatedValue, "Updated date should be accessible and stored")
    }
}

// MARK: TestStorage

class TestStorage: Storage {

    private var storedObjects: [String: Any] = [:]

    // MARK: Methods

    func object(forKey defaultName: String) -> Any? {
        return storedObjects[defaultName]
    }

    func set(_ value: Any?, forKey defaultName: String) {
        storedObjects[defaultName] = value
    }
}

// MARK: StoredValueInUserDefaultsWrapper

class StoredValueInUserDefaultsWrapper {

    @StoredValueInUserDefaults(key: "testString", storage: TestStorage())
    var storedString: String?

    @StoredValueInUserDefaults(key: "testDate", storage: TestStorage())
    var storedDate: Date?
}
