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
                                              paidContent: true,
                                              contentId: "6789",
                                              contentSpaceUuid: "9123")
        // swiftlint:disable:next line_length
        let rdlcnParam = "eyJvYmplY3QiOnsiaWQiOiI2Nzg5In0sInB1YmxpY2F0aW9uIjp7InByZW1pdW0iOnRydWV9LCJzb3VyY2UiOnsiaWQiOiI5MTIzIiwic3lzdGVtIjoic3lzdGVtX25hbWUifX0="

        // When
        let event = factory.createPageViewEvent(contentIdentifier: contentMetadata.contentId,
                                                contentMetadata: contentMetadata)
        let params = event.eventParameters

        // Then
        XCTAssertEqual(params["PU"], contentMetadata.contentId, "PU parameter should be equal to content identifier")
        XCTAssertEqual(params["DX"], "PV_4,system_name,12345,1,t", "DX parameter should be in correct format")
        XCTAssertEqual(params["RDLCN"], rdlcnParam, "RDLCN parameter should be in correct format")
    }

    func testCreatePageViewEvent_contentMetaDataWithUnpaidContentProvided_returnedEventIsDecorated() {
        // Given
        let factory = EventsFactory()
        let contentMetadata = ContentMetadata(publicationId: "12345",
                                              publicationUrl: URL(fileURLWithPath: "path"),
                                              sourceSystemName: "system_name",
                                              paidContent: false,
                                              contentId: "6789",
                                              contentSpaceUuid: "12349")
        // swiftlint:disable:next line_length
        let rdlcnParam = "eyJvYmplY3QiOnsiaWQiOiI2Nzg5In0sInB1YmxpY2F0aW9uIjp7InByZW1pdW0iOmZhbHNlfSwic291cmNlIjp7ImlkIjoiMTIzNDkiLCJzeXN0ZW0iOiJzeXN0ZW1fbmFtZSJ9fQ=="

        // When
        let event = factory.createPageViewEvent(contentIdentifier: contentMetadata.contentId,
                                                contentMetadata: contentMetadata)
        let params = event.eventParameters

        // Then
        XCTAssertEqual(params["PU"], contentMetadata.contentId, "PU parameter should be equal to content identifier")
        XCTAssertEqual(params["DX"], "PV_4,system_name,12345,1,f", "DX parameter should be in correct format")
        XCTAssertEqual(params["RDLCN"], rdlcnParam, "RDLCN parameter should be in correct format")
    }

    func testCreatePageViewEvent_clientDataProvided_clientDataIsReportedInRDLC() {
        // Given
        let factory = EventsFactory()
        let clientData = "eyJjbGllbnQiOnsidHlwZSI6Im5hdGl2ZV9hcHAiLCJ2aWV3VHlwZSI6InRleHQifX0="

        // When
        let event = factory.createPageViewEvent(contentIdentifier: nil, contentMetadata: nil, clientData: clientData)

        // Then
        XCTAssertEqual(event.eventParameters["RDLC"], clientData, "RDLC should be taken from provided client data")
    }

    func testCreatePageViewEvent_clientDataNotProvided_clientDataIsLeftToDecorator() {
        // Given
        let factory = EventsFactory()

        // When
        let event = factory.createPageViewEvent(contentIdentifier: nil, contentMetadata: nil)

        // Then
        XCTAssertNil(event.eventParameters["RDLC"], "RDLC should be left to the client decorator")
    }

    func testCreatePageViewEvent_contentIdentifierWithUppercaseLetters_rdlcnObjectIdentifierEqualsPU() throws {
        // Given
        let factory = EventsFactory()
        let contentMetadata = ContentMetadata(publicationId: "12345",
                                              publicationUrl: URL(fileURLWithPath: "path"),
                                              sourceSystemName: "system_name",
                                              paidContent: false,
                                              contentId: "E0BE23E3-A100-4D4F-A347-0635DE46BFC4",
                                              contentSpaceUuid: "9123")

        // When
        let event = factory.createPageViewEvent(contentIdentifier: contentMetadata.contentId,
                                                contentMetadata: contentMetadata)
        let params = event.eventParameters
        let rdlcn = try decodedJSONParameter(params["RDLCN"])
        let object = try XCTUnwrap(rdlcn["object"] as? [String: Any])

        // Then
        XCTAssertEqual(params["PU"], "e0be23e3-a100-4d4f-a347-0635de46bfc4", "PU parameter should be the lowercased content identifier")
        XCTAssertEqual(object["id"] as? String, params["PU"] as? String, "RDLCN object identifier should be equal to PU")
    }

    func testCreatePageViewEvent_blankContentIdentifier_rdlcnHasNoObject() throws {
        // Given
        let factory = EventsFactory()
        let contentMetadata = ContentMetadata(publicationId: "12345",
                                              publicationUrl: URL(fileURLWithPath: "path"),
                                              sourceSystemName: "system_name",
                                              paidContent: false,
                                              contentId: "  ",
                                              contentSpaceUuid: "9123")

        // When
        let event = factory.createPageViewEvent(contentIdentifier: contentMetadata.contentId,
                                                contentMetadata: contentMetadata)
        let rdlcn = try decodedJSONParameter(event.eventParameters["RDLCN"])

        // Then
        XCTAssertNil(rdlcn["object"], "RDLCN should have no object without a content identifier")
        XCTAssertNotNil(rdlcn["publication"], "RDLCN publication should be reported as before")
        XCTAssertNotNil(rdlcn["source"], "RDLCN source should be reported as before")
    }

    func testCreateEffectivePageViewEvent_contentIdentifierWithUppercaseLetters_rdlcnObjectIdentifierEqualsPU() throws {
        // Given
        let factory = EventsFactory()
        let contentMetadata = ContentMetadata(publicationId: "12345",
                                              publicationUrl: URL(fileURLWithPath: "path"),
                                              sourceSystemName: "system_name",
                                              paidContent: false,
                                              contentId: "E0BE23E3-A100-4D4F-A347-0635DE46BFC4",
                                              contentSpaceUuid: "9123")
        let metaData = EffectivePageViewMetadata(componentSource: "audio", triggerSource: "play", measurement: .zero)

        // When
        let event = try XCTUnwrap(factory.createEffectivePageViewEvent(contentIdentifier: contentMetadata.contentId,
                                                                       contentMetadata: contentMetadata,
                                                                       metaData: metaData))
        let params = event.eventParameters
        let object = try XCTUnwrap(decodedJSONParameter(params["RDLCN"])["object"] as? [String: Any])

        // Then
        XCTAssertEqual(object["id"] as? String, params["PU"] as? String, "RDLCN object identifier should be equal to PU")
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
