//
//  EventsFactoryTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 08/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import XCTest

class EventsFactoryTests: XCTestCase {

    // MARK: Tests

    // MARK: - ClickEvent Tests

    func testCreateClickEvent_allParametersProvided_returnedEventIsDecorated() {
        // Given
        let elementName = "TestName"
        let sampleUrl = "https://test.com"
        let sampleId = "12345"
        let factory = EventsFactory()

        // Then
        let event = factory.createClickEvent(selectedElementName: elementName,
                                             publicationUrl: URL(string: sampleUrl),
                                             contentIdentifier: sampleId)
        let params = event.eventParameters

        XCTAssertEqual(params["VE"], elementName, "VE should be correct")
        XCTAssertEqual(params["VU"], sampleUrl, "VU should be correct")
        XCTAssertEqual(params["PU"], sampleId, "PU should be correct")
    }

    func testCreateClickEvent_noParametersProvided_returnedEventIsNotDecorated() {
        // Given
        let factory = EventsFactory()

        // Then
        let event = factory.createClickEvent(selectedElementName: nil,
                                             publicationUrl: nil,
                                             contentIdentifier: nil)
        let params = event.eventParameters

        XCTAssertNil(params["VE"], "VE should be empty")
        XCTAssertNil(params["VU"], "VU should be empty")
        XCTAssertNil(params["PU"], "PU should be empty")
        XCTAssertNil(params["EI"], "EI should be empty")
    }

    // MARK: - UserActionEvent Tests

    func testCreateUserActionEvent_dictionaryParameterProvided_returnedEventIsDecorated() {
        // Given
        let parameters: [String: AnyHashable] = [
            "test": "value"
        ]
        let factory = EventsFactory()

        // Then
        let event = factory.createUserActionEvent(actionName: "name", actionSubtypeName: "subname", parameter: .parameters(parameters))
        let params = event.eventParameters

        XCTAssertEqual(params["VE"], "name", "VE should be correct")
        XCTAssertEqual(params["VC"], "subname", "VC should be correct")
        XCTAssertEqual(params["VM"], "{\"test\":\"value\"}", "VM should be correct")
    }

    func testCreateUserActionEvent_plainParameterProvided_returnedEventIsDecorated() {
        // Given
        let plainParameter = "test"
        let factory = EventsFactory()

        // Then
        let event = factory.createUserActionEvent(actionName: "name", actionSubtypeName: "subname", parameter: .plain(plainParameter))
        let params = event.eventParameters

        XCTAssertEqual(params["VE"], "name", "VE should be correct")
        XCTAssertEqual(params["VC"], "subname", "VC should be correct")
        XCTAssertEqual(params["VM"], plainParameter, "VM should be correct")
    }

    // MARK: - PageViewEvent Tests

    func testCreatePageViewEvent_noParametersProvided_returnedEventIsDecorated() {
        // Given
        let factory = EventsFactory()

        // When
        let event = factory.createPageViewEvent(contentIdentifier: nil, contentMetadata: nil)
        let params = event.eventParameters

        // Then
        XCTAssertNil(params["PU"], "PU parameter should be empty")
        XCTAssertNil(params["DX"], "DX parameter should be empty")
    }

    func testCreatePageViewEvent_contentMetaDataWithPaidContentProvided_returnedEventIsDecorated() {
        // Given
        let factory = EventsFactory()
        let contentMetadata = ContentMetadata(publicationId: "12345",
                                              publicationUrl: URL(fileURLWithPath: "path"),
                                              sourceSystemName: "system_name",
                                              contentWasPaidFor: true,
                                              contentId: "6789")

        // When
        let event = factory.createPageViewEvent(contentIdentifier: contentMetadata.contentId,
                                                contentMetadata: contentMetadata)
        let params = event.eventParameters

        // Then
        XCTAssertEqual(params["PU"], contentMetadata.contentId, "PU parameter should be equal to content identifier")
        XCTAssertEqual(params["DX"], "PV_4,system_name,12345,1,t", "DX parameter should be in correct format")
    }

    func testCreatePageViewEvent_contentMetaDataWithUnpaidContentProvided_returnedEventIsDecorated() {
        // Given
        let factory = EventsFactory()
        let contentMetadata = ContentMetadata(publicationId: "12345",
                                              publicationUrl: URL(fileURLWithPath: "path"),
                                              sourceSystemName: "system_name",
                                              contentWasPaidFor: false,
                                              contentId: "6789")

        // When
        let event = factory.createPageViewEvent(contentIdentifier: contentMetadata.contentId,
                                                contentMetadata: contentMetadata)
        let params = event.eventParameters

        // Then
        XCTAssertEqual(params["PU"], contentMetadata.contentId, "PU parameter should be equal to content identifier")
        XCTAssertEqual(params["DX"], "PV_4,system_name,12345,1,f", "DX parameter should be in correct format")
    }

    // MARK: - ErrorEvent Tests

    func testCreateErrorEvent_incorrectEventProvided_returnedEventIsDecorated() {
        // Given
        let factory = EventsFactory()
        let incorrectEvent = factory.createClickEvent(selectedElementName: "test", publicationUrl: nil, contentIdentifier: nil)

        // When
        let event = factory.createErrorEvent(for: incorrectEvent, applicationRootPath: "Tests")
        let params = event.eventParameters

        // Then
        XCTAssertEqual(event.eventName, EventType.error.rawValue, "eventName should be correct")
        XCTAssertEqual(event.analyticsSystemName, AnalyticsSystem.kropkaMonitoring.rawValue, "analyticsSystemName should be proper")
        XCTAssertEqual(params["VE"], "AppError", "VE arameter should match")
        XCTAssertNotNil(params["VM"], "VM parameter should contain message")
    }
}
