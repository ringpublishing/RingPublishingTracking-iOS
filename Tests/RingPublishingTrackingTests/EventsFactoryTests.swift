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
        let rdlcnParam = "eyJwdWJsaWNhdGlvbiI6eyJwcmVtaXVtIjp0cnVlfSwic291cmNlIjp7ImlkIjoiOTEyMyIsInN5c3RlbSI6InN5c3RlbV9uYW1lIn19"

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
        let rdlcnParam = "eyJwdWJsaWNhdGlvbiI6eyJwcmVtaXVtIjpmYWxzZX0sInNvdXJjZSI6eyJpZCI6IjEyMzQ5Iiwic3lzdGVtIjoic3lzdGVtX25hbWUifX0="

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

    // MARK: - RDLCN object identifier

    func testCreatePageViewEvent_uuidContentIdentifier_rdlcnReportsContentObject() {
        // Given
        let factory = EventsFactory()
        let contentMetadata = ContentMetadata(publicationId: "12345",
                                              publicationUrl: URL(fileURLWithPath: "path"),
                                              sourceSystemName: "system_name",
                                              paidContent: false,
                                              contentId: "E0BE23E3-A100-4D4F-A347-0635DE46BFC4",
                                              contentSpaceUuid: "9123")
        // {"object":{"id":"e0be23e3-a100-4d4f-a347-0635de46bfc4"},"publication":{"premium":false},
        //  "source":{"id":"9123","system":"system_name"}}
        let rdlcnParam = "eyJvYmplY3QiOnsiaWQiOiJlMGJlMjNlMy1hMTAwLTRkNGYtYTM0Ny0wNjM1ZGU0NmJmYzQifSwi" +
            "cHVibGljYXRpb24iOnsicHJlbWl1bSI6ZmFsc2V9LCJzb3VyY2UiOnsiaWQiOiI5MTIzIiwic3lzdGVtIjoic3lzdGVtX25hbWUifX0="

        // When
        let event = factory.createPageViewEvent(contentIdentifier: contentMetadata.contentId,
                                                contentMetadata: contentMetadata)

        // Then
        XCTAssertEqual(event.eventParameters["RDLCN"], rdlcnParam, "RDLCN parameter should carry the content object")
    }

    /// Vectors shared with the Android SDK, which has to report the same `object.id` for the same content
    func testRDLCNObjectIdentifier_sharedTestVectors_sameIdentifierReportedByEveryEvent() throws {
        let canonicalIdentifier = "e0be23e3-a100-4d4f-a347-0635de46bfc4"
        let vectors: [(contentId: String, objectIdentifier: String?)] = [
            ("E0BE23E3-A100-4D4F-A347-0635DE46BFC4", canonicalIdentifier),
            ("  e0be23e3-a100-4d4f-a347-0635de46bfc4  ", canonicalIdentifier),
            ("e0be23e3-a100-4d4f-a347-0635de46bfc4", canonicalIdentifier),
            ("12345", nil),
            ("my-unique-content-id-1234", nil),
            ("e0be23e3a1004d4fa3470635de46bfc4", nil),
            ("", nil),
            ("   ", nil),
            ("\u{0085}e0be23e3-a100-4d4f-a347-0635de46bfc4\u{0085}", nil),
            ("e0be23e3-a100-4d4f-a347-0635de46bfc4\u{0085}", nil)
        ]

        for vector in vectors {
            // Given
            let factory = EventsFactory()
            let contentMetadata = ContentMetadata(publicationId: "12345",
                                                  publicationUrl: URL(fileURLWithPath: "path"),
                                                  sourceSystemName: "system_name",
                                                  paidContent: false,
                                                  contentId: vector.contentId,
                                                  contentSpaceUuid: "9123")
            let keepAliveMetadata = KeepAliveMetadata(keepAliveContentStatus: [], timings: [], hasFocus: [], keepAliveMeasureType: [])
            let effectivePageViewMetadata = EffectivePageViewMetadata(componentSource: "audio", triggerSource: "play", measurement: .zero)
            let supplierData = SupplierData(supplierAppId: "app", paywallSupplier: "piano")
            let metricsData = MetricsData(metricLimitName: "OnetMeter", freePageViewCount: 9, freePageViewLimit: 10)

            // When
            let pageView = factory.createPageViewEvent(contentIdentifier: contentMetadata.contentId, contentMetadata: contentMetadata)
            let effectivePageView = factory.createEffectivePageViewEvent(contentIdentifier: contentMetadata.contentId,
                                                                         contentMetadata: contentMetadata,
                                                                         metaData: effectivePageViewMetadata)
            let keepAlive = factory.createKeepAliveEvent(metaData: keepAliveMetadata, contentMetadata: contentMetadata)
            let showMetricLimit = factory.createShowMetricLimitEvent(contentMetadata: contentMetadata,
                                                                     supplierData: supplierData,
                                                                     metricsData: metricsData)

            // Then
            let events: [(name: String, event: Event?)] = [
                ("page view", pageView),
                ("effective page view", effectivePageView),
                ("keep alive", keepAlive),
                ("show metric limit", showMetricLimit)
            ]

            for (name, event) in events {
                let rdlcn = try decodedJSONParameter(XCTUnwrap(event).eventParameters["RDLCN"])
                let object = rdlcn["object"] as? [String: Any]

                XCTAssertEqual(object?["id"] as? String, vector.objectIdentifier, "\(name), content identifier '\(vector.contentId)'")
                XCTAssertEqual(rdlcn["object"] == nil, vector.objectIdentifier == nil, "\(name), content identifier '\(vector.contentId)'")
            }
        }
    }

    func testRDLCNObjectIdentifier_sameInvalidIdentifierInRepeatedEvents_warningIsLoggedOncePerIdentifier() {
        // Given
        let messages = LoggedMessages()
        let previousLoggerOutput = Logger.shared.loggerOutput
        Logger.shared.loggerOutput = { messages.append($0) }
        defer { Logger.shared.loggerOutput = previousLoggerOutput }

        let factory = EventsFactory()
        let keepAliveMetadata = KeepAliveMetadata(keepAliveContentStatus: [], timings: [], hasFocus: [], keepAliveMeasureType: [])
        let firstContent = contentMetadata(contentId: "invalid-content-identifier-1")
        let secondContent = contentMetadata(contentId: "invalid-content-identifier-2")

        // When
        for _ in 0..<3 {
            _ = factory.createKeepAliveEvent(metaData: keepAliveMetadata, contentMetadata: firstContent)
        }
        _ = factory.createPageViewEvent(contentIdentifier: firstContent.contentId, contentMetadata: firstContent)
        _ = factory.createKeepAliveEvent(metaData: keepAliveMetadata, contentMetadata: secondContent)

        // Then
        XCTAssertEqual(messages.count(containing: "'invalid-content-identifier-1' is not a UUID"), 1,
                       "Repeated events with the same invalid identifier should log it once")
        XCTAssertEqual(messages.count(containing: "'invalid-content-identifier-2' is not a UUID"), 1,
                       "Another invalid identifier should be logged again")
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

private extension EventsFactoryTests {

    func contentMetadata(contentId: String) -> ContentMetadata {
        ContentMetadata(publicationId: "12345",
                        publicationUrl: URL(fileURLWithPath: "path"),
                        sourceSystemName: "system_name",
                        paidContent: false,
                        contentId: contentId,
                        contentSpaceUuid: "9123")
    }
}

/// Collects module logs, which may arrive from any thread
private final class LoggedMessages {

    private let lock = NSLock()
    private var messages: [String] = []

    func append(_ message: String) {
        lock.lock()
        messages.append(message)
        lock.unlock()
    }

    func count(containing text: String) -> Int {
        lock.lock()
        defer { lock.unlock() }

        return messages.filter { $0.contains(text) }.count
    }
}
