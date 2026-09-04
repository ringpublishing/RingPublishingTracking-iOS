//
//  RingPublishingTrackingConfigurationTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 27/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class RingPublishingTrackingConfigurationTests: XCTestCase {

    // MARK: Tests

    func testInit_allParametersProvided_configurationCreatedProperly() {
        // Given
        let tenantId = "12345"
        let apiKey = "abcdef"
        let applicationRootPath = "RingPublishingTrackingTests"
        let applicationDefaultStructurePath = ["Default"]
        let applicationDefaultAdvertisementArea = "TestsAdvertisementArea"
        let apiUrl = URL(string: "https://tests.example.com")! // swiftlint:disable:this force_unwrapping

        // When
        let configuration = RingPublishingTrackingConfiguration(tenantId: tenantId,
                                                                apiKey: apiKey,
                                                                apiUrl: apiUrl,
                                                                applicationRootPath: applicationRootPath,
                                                                applicationDefaultStructurePath: applicationDefaultStructurePath,
                                                                applicationDefaultAdvertisementArea: applicationDefaultAdvertisementArea)

        // Then
        XCTAssertEqual(configuration.tenantId, tenantId)
        XCTAssertEqual(configuration.apiKey, apiKey)
        XCTAssertEqual(configuration.applicationRootPath, applicationRootPath)
        XCTAssertEqual(configuration.applicationDefaultStructurePath, applicationDefaultStructurePath)
        XCTAssertEqual(configuration.applicationDefaultAdvertisementArea, applicationDefaultAdvertisementArea)
        XCTAssertEqual(configuration.apiUrl?.absoluteString, apiUrl.absoluteString)
    }

    func testInit_requiredParametersProvided_configurationCreatedWithDefaultValues() {
        // Given
        let tenantId = "12345"
        let apiKey = "abcdef"
        let applicationRootPath = "RingPublishingTrackingTests"

        // When
        let configuration = RingPublishingTrackingConfiguration(tenantId: tenantId,
                                                                apiKey: apiKey,
                                                                applicationRootPath: applicationRootPath)

        // Then
        XCTAssertEqual(configuration.tenantId, tenantId)
        XCTAssertEqual(configuration.apiKey, apiKey)
        XCTAssertEqual(configuration.applicationRootPath, applicationRootPath)
        XCTAssertEqual(configuration.applicationDefaultStructurePath, Constants.applicationDefaultStructurePath)
        XCTAssertEqual(configuration.applicationDefaultAdvertisementArea, Constants.applicationDefaultAdvertisementArea)
        XCTAssertEqual(configuration.apiUrl?.absoluteString, nil)
    }
}
