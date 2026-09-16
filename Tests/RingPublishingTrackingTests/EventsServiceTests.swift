//
//  EventsServiceTests.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 29/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class EventsServiceTests: XCTestCase {

    var configuration: RingPublishingTrackingConfiguration?

    override func setUp() {
        super.setUp()
        configuration = RingPublishingTrackingConfiguration(tenantId: "tenantID", apiKey: "some_api_key", applicationRootPath: "/")
    }

    override func tearDown() {
        super.tearDown()
        configuration = nil
    }

    // MARK: Tests

    func testIsEaUuidValid_eaUuidDateIsSetInNearPast_theIdentifierIsValid() throws {
        // Given

        // Lifetime = 24h
        // Creation Date = 12 hours ago
        let creationDate = Date().addingTimeInterval(TimeInterval(-60 * 60 * 12))
        let eaUuid = EaUUID(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: creationDate)

        let storage = StaticStorage(eaUUID: eaUuid, trackingIds: nil, postInterval: nil)
        let configuration = try XCTUnwrap(configuration)
        let service = EventsService(
            storage: storage,
            configuration: configuration,
            eventsFactory: EventsFactory(),
            operationMode: OperationMode()
        )

        // Then
        XCTAssertTrue(service.isEaUuidValid, "The identifier should be valid")
    }

    func testIsEaUuidValid_eaUuidDateIsSetInFarPast_theIdentifierIsExpired() throws {
        // Given

        // Lifetime = 24h
        // Creation Date = 48 hours ago
        let creationDate = Date().addingTimeInterval(TimeInterval(-60 * 60 * 48))
        let eaUuid = EaUUID(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: creationDate)

        let storage = StaticStorage(eaUUID: eaUuid, trackingIds: nil, postInterval: nil)
        let configuration = try XCTUnwrap(configuration)
        let service = EventsService(
            storage: storage,
            configuration: configuration,
            eventsFactory: EventsFactory(),
            operationMode: OperationMode()
        )

        // Then
        XCTAssertFalse(service.isEaUuidValid, "The identifier should be expired")
    }

    func testIsEaUuidValid_eaUuidDateIsNotSet_theIdentifierIsInvalid() throws {
        // Given
        let storage = StaticStorage(eaUUID: nil, trackingIds: nil, postInterval: nil)
        let configuration = try XCTUnwrap(configuration)
        let service = EventsService(
            storage: storage,
            configuration: configuration,
            eventsFactory: EventsFactory(),
            operationMode: OperationMode()
        )

        // Then
        XCTAssertFalse(service.isEaUuidValid, "The identifier should be invalid")
    }

    func testStoredIds_sampleTrackingIdentifiersAddedToStorage_storedIdsAreProperlyLoaded() throws {
        // Given
        let creationDate = Date().addingTimeInterval(TimeInterval(-60 * 60 * 12))
        let eaUuid = EaUUID(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: creationDate)
        let storage = StaticStorage(eaUUID: eaUuid, trackingIds: [
            "key1": .init(value: "id1", lifetime: nil),
            "key2": .init(value: "id2", lifetime: nil),
            "key3": .init(value: "id3", lifetime: nil)
        ], postInterval: nil)
        let configuration = try XCTUnwrap(configuration)
        let service = EventsService(
            storage: storage,
            configuration: configuration,
            eventsFactory: EventsFactory(),
            operationMode: OperationMode()
        )

        // Then
        XCTAssertEqual(service.storedIds().count, 4, "Stored ids number should be correct")
    }

    func testAddEvents_eventsOverRequestBodySizeLimitAddedToQueue_builtRequestBodySizeIsBelowSizeLimit() throws {
        // Given
        let storage = StaticStorage(eaUUID: nil, trackingIds: [
            "key1": .init(value: "id1", lifetime: nil),
            "key2": .init(value: "id2", lifetime: nil),
            "key3": .init(value: "id3", lifetime: nil)
        ], postInterval: nil)
        let configuration = try XCTUnwrap(configuration)
        let service = EventsService(
            storage: storage,
            configuration: configuration,
            eventsFactory: EventsFactory(),
            operationMode: OperationMode()
        )

        let bodySizeLimit = Constants.requestBodySizeLimit
        let singleEventSize = Event.smallEvent().sizeInBytes

        // When
        let eventsAmount = Int(floor(Double(bodySizeLimit) / Double(singleEventSize))) + 1

        for _ in 0..<eventsAmount {
            service.addEvents([Event.smallEvent()])
        }

        let request = service.buildEventRequest()

        // Then
        XCTAssertLessThan(request.dictionary.jsonSizeInBytes,
                          bodySizeLimit,
                          "Event request body size should be below \(bodySizeLimit)")

        XCTAssertLessThan(request.events.count, eventsAmount, "Events above body size limit should not be added")
    }

    func testAddEvents_eventsWithInvalidAddedToQueue_invalidEventsAreNotAdded() throws {
        // Given
        let expectation = XCTestExpectation(description: "Events not added to queue")

        let storage = StaticStorage(eaUUID: nil, trackingIds: nil, postInterval: nil)
        let configuration = try XCTUnwrap(configuration)
        let service = EventsService(
            storage: storage,
            configuration: configuration,
            eventsFactory: EventsFactory(),
            operationMode: OperationMode()
        )

        // When
        let incorrectEvent = Event(eventParameters: [
            "test": URL(string: "https://test.com") // incorrect event, URL is not allowed in JSONSerialization
        ])

        let correctEvent = Event(eventName: "name", eventParameters: ["test": "value"])

        service.addEvents([incorrectEvent, correctEvent])

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            let request = service.buildEventRequest()
            XCTAssertEqual(request.events.count, 1, "Incorrect event should not be added")

            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 10.0)
    }

    func testShouldRetryIdentifyRequest_allRequiredDataStored_shouldNotRetry() throws {
        // Given
        let creationDate = Date().addingTimeInterval(TimeInterval(-60 * 60 * 12))
        let eaUuid = EaUUID(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: creationDate)
        let artemisExternal = ArtemisExternal(
            model: "202010190919497238108361",
            models: [
                "ats_ri": AnyCodable("202010190919497238108361")
            ]
        )
        let artemisID = ArtemisID(artemis: "202311081625290741208292", external: artemisExternal)
        let artemis = Artemis(id: artemisID, lifetime: 360, creationDate: Date())
        let storage = StaticStorage(eaUUID: eaUuid, artemisID: artemis, trackingIds: [
            "key1": .init(value: "id1", lifetime: nil),
            "key2": .init(value: "id2", lifetime: nil),
            "key3": .init(value: "id3", lifetime: nil)
        ], postInterval: 500)

        let configuration = try XCTUnwrap(configuration)
        let service = EventsService(
            storage: storage,
            configuration: configuration,
            eventsFactory: EventsFactory(),
            operationMode: OperationMode()
        )

        // Then
        XCTAssertFalse(service.shouldRetryIdentifyRequest, "Identify request should not be retried")
    }

    func testShouldRetryIdentifyRequest_eaUUIDIsMissing_shouldRetry() throws {
        // Given
        let storage = StaticStorage(eaUUID: nil, trackingIds: [
            "key1": .init(value: "id1", lifetime: nil),
            "key2": .init(value: "id2", lifetime: nil),
            "key3": .init(value: "id3", lifetime: nil)
        ], postInterval: 500)

        let configuration = try XCTUnwrap(configuration)
        let service = EventsService(
            storage: storage,
            configuration: configuration,
            eventsFactory: EventsFactory(),
            operationMode: OperationMode()
        )

        // Then
        XCTAssertTrue(service.shouldRetryIdentifyRequest, "Identify request should be retried")
    }

    func testShouldRetryIdentifyRequest_postIntervalIsMissing_shouldRetry() throws {
        // Given
        let creationDate = Date().addingTimeInterval(TimeInterval(-60 * 60 * 12))
        let eaUuid = EaUUID(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: creationDate)
        let storage = StaticStorage(eaUUID: eaUuid, trackingIds: [
            "key1": .init(value: "id1", lifetime: nil),
            "key2": .init(value: "id2", lifetime: nil),
            "key3": .init(value: "id3", lifetime: nil)
        ], postInterval: nil)

        let configuration = try XCTUnwrap(configuration)
        let service = EventsService(
            storage: storage,
            configuration: configuration,
            eventsFactory: EventsFactory(),
            operationMode: OperationMode()
        )

        // Then
        XCTAssertTrue(service.shouldRetryIdentifyRequest, "Identify request should be retried")
    }

    func testShouldRetryIdentifyRequest_artemisIdentifierMissing_shouldRetry() throws {
        // Given
        let creationDate = Date().addingTimeInterval(TimeInterval(-60 * 60 * 12))
        let eaUuid = EaUUID(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: creationDate)
        let artemisCreationDate = Date().addingTimeInterval(-380)
        let artemisExternal = ArtemisExternal(
            model: "202010190919497238108361",
            models: [
                "ats_ri": AnyCodable("202010190919497238108361")
            ]
        )
        let artemisID = ArtemisID(artemis: "202311081625290741208292", external: artemisExternal)
        let artemis = Artemis(id: artemisID, lifetime: 360, creationDate: artemisCreationDate)
        let storage = StaticStorage(eaUUID: eaUuid, artemisID: artemis, trackingIds: [
            "key1": .init(value: "id1", lifetime: nil),
            "key2": .init(value: "id2", lifetime: nil),
            "key3": .init(value: "id3", lifetime: nil)
        ], postInterval: nil)

        let configuration = try XCTUnwrap(configuration)
        let service = EventsService(
            storage: storage,
            configuration: configuration,
            eventsFactory: EventsFactory(),
            operationMode: OperationMode()
        )

        // Then
        XCTAssertTrue(service.shouldRetryIdentifyRequest, "Identify request should be retried")
    }

    // MARK: sendEvents

    func testSendEvents_successfulResponse_eventsAreRemovedFromQueueAndPostIntervalIsStored() throws {
        // Given
        let sessionMock = NetworkSessionMock()
        sessionMock.data = eventResponseData(postInterval: 1000)
        sessionMock.response = httpResponse(statusCode: 200)

        let service = try readyService(storage: validIdentityStorage(postInterval: 500), session: sessionMock)

        // When
        service.addEvents([Event.smallEvent()])

        // Then
        XCTAssertTrue(service.eventsQueueManager.events.allElements.isEmpty,
                      "Sent events should be removed from the queue on success")
        XCTAssertEqual(service.storage.postInterval, 1000, "New post interval from the response should be stored")
    }

    func testSendEvents_responseErrorStatusCode_eventsAreRemovedFromQueue() throws {
        // Given
        let sessionMock = NetworkSessionMock()
        sessionMock.data = Data()
        sessionMock.response = httpResponse(statusCode: 400)

        let service = try readyService(storage: validIdentityStorage(postInterval: 500), session: sessionMock)

        // When
        service.addEvents([Event.smallEvent()])

        // Then
        XCTAssertTrue(service.eventsQueueManager.events.allElements.isEmpty,
                      "Events rejected by the backend with a bad status code should be dropped instead of retried forever")
    }

    func testSendEvents_networkError_eventsRemainInQueueForRetry() throws {
        // Given
        let sessionMock = NetworkSessionMock()
        sessionMock.error = URLError(.notConnectedToInternet)

        let service = try readyService(storage: validIdentityStorage(postInterval: 500), session: sessionMock)

        // When
        service.addEvents([Event.smallEvent()])

        // Then
        XCTAssertEqual(service.eventsQueueManager.events.allElements.count, 1,
                       "Events should remain queued when the request fails for a reason other than a bad response status code")
    }

    func testSendEvents_firstSendInFlight_triggersExactlyOneRequest() throws {
        // Given
        let sessionMock = ManualNetworkSessionMock()
        let service = try readyService(storage: validIdentityStorage(postInterval: 0), session: sessionMock)

        // When: first send starts and stays in-flight (ManualNetworkSessionMock never completes it on its own)
        service.addEvents([Event(eventParameters: ["order": "first"])])

        // Then
        XCTAssertEqual(sessionMock.callCount, 1, "First send should trigger exactly one request")
    }

    func testSendEvents_secondSendRequestedWhileFirstInFlight_pendingFlagIsSet() throws {
        // Given
        let (service, _) = try serviceWithOverlappingSends()

        // Then
        XCTAssertTrue(service.eventsSendPending, "The overlapping send should be recorded as pending instead of being dropped")
    }

    func testSendEvents_secondSendRequestedWhileFirstInFlight_noNewRequestIsSent() throws {
        // Given
        let (_, sessionMock) = try serviceWithOverlappingSends()

        // Then
        XCTAssertEqual(sessionMock.callCount, 1,
                       "No new request should be sent while one is already in-flight, to avoid sending the same events twice")
    }

    func testSendEvents_secondSendRequestedWhileFirstInFlight_bothEventsRemainQueued() throws {
        // Given
        let (service, _) = try serviceWithOverlappingSends()

        // Then
        XCTAssertEqual(service.eventsQueueManager.events.allElements.count, 2, "Both events should still be queued")
    }

    func testSendEvents_inFlightRequestFinishes_pendingSendIsTriggeredAutomatically() throws {
        // Given
        // `service` kept alive: completion closures capture it weakly
        let (service, sessionMock) = try serviceWithOverlappingSends()
        _ = service

        // When
        sessionMock.completeOldestPendingRequest(data: eventResponseData(postInterval: 0), response: httpResponse(statusCode: 200))

        // Then
        XCTAssertEqual(sessionMock.callCount, 2,
                       "The pending send requested during the in-flight request should be executed automatically once it finishes")
    }

    func testSendEvents_inFlightRequestFinishes_pendingFlagIsCleared() throws {
        // Given
        let (service, sessionMock) = try serviceWithOverlappingSends()

        // When
        sessionMock.completeOldestPendingRequest(data: eventResponseData(postInterval: 0), response: httpResponse(statusCode: 200))

        // Then
        XCTAssertFalse(service.eventsSendPending, "The pending flag should be cleared once the pending send has been retried")
    }

    func testSendEvents_inFlightRequestFinishes_onlyItsOwnEventIsRemoved() throws {
        // Given
        let (service, sessionMock) = try serviceWithOverlappingSends()

        // When
        sessionMock.completeOldestPendingRequest(data: eventResponseData(postInterval: 0), response: httpResponse(statusCode: 200))

        // Then
        let remainingEvents = service.eventsQueueManager.events.allElements
        XCTAssertEqual(remainingEvents.count, 1, "Only the event included in the finished request should be removed")
        XCTAssertEqual(remainingEvents.first?.eventParameters["order"] as? String, "second",
                       "The event requested while the first one was in-flight should still be queued")
    }

    func testSendEvents_bothOverlappingRequestsFinish_queueEndsUpEmpty() throws {
        // Given
        let (service, sessionMock) = try serviceWithOverlappingSends()

        // When
        sessionMock.completeOldestPendingRequest(data: eventResponseData(postInterval: 0), response: httpResponse(statusCode: 200))
        sessionMock.completeOldestPendingRequest(data: eventResponseData(postInterval: 0), response: httpResponse(statusCode: 200))

        // Then
        XCTAssertTrue(service.eventsQueueManager.events.allElements.isEmpty, "Second event should be removed once its request finishes")
    }

    func testSendEvents_bothOverlappingRequestsFinish_noExtraRequestsAreMade() throws {
        // Given
        // `service` kept alive: completion closures capture it weakly
        let (service, sessionMock) = try serviceWithOverlappingSends()
        _ = service

        // When
        sessionMock.completeOldestPendingRequest(data: eventResponseData(postInterval: 0), response: httpResponse(statusCode: 200))
        sessionMock.completeOldestPendingRequest(data: eventResponseData(postInterval: 0), response: httpResponse(statusCode: 200))

        // Then
        XCTAssertEqual(sessionMock.callCount, 2, "No extra requests should have been made")
    }

    func testSendEvents_bothOverlappingRequestsFinish_isSendingEventsEndsUpFalse() throws {
        // Given
        let (service, sessionMock) = try serviceWithOverlappingSends()

        // When
        sessionMock.completeOldestPendingRequest(data: eventResponseData(postInterval: 0), response: httpResponse(statusCode: 200))
        sessionMock.completeOldestPendingRequest(data: eventResponseData(postInterval: 0), response: httpResponse(statusCode: 200))

        // Then
        XCTAssertFalse(service.isSendingEvents, "isSendingEvents should be reset once all in-flight/pending sends have finished")
    }
}

// MARK: Helpers
private extension EventsServiceTests {

    /// Storage with valid identity data so `checkIfIdentityRequestShouldBePerformed` calls `sendEvents` directly,
    /// without going through the (unrelated) identify/vendor-id retry flow.
    func validIdentityStorage(postInterval: Int?) -> StaticStorage {
        let eaUuidCreationDate = Date().addingTimeInterval(TimeInterval(-60 * 60 * 12)) // 12h ago, lifetime 24h
        let eaUuid = EaUUID(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: eaUuidCreationDate)

        let artemisExternal = ArtemisExternal(model: "model", models: ["ats_ri": AnyCodable("model")])
        let artemisID = ArtemisID(artemis: "artemis", external: artemisExternal)
        let artemis = Artemis(id: artemisID, lifetime: 360, creationDate: Date())

        return StaticStorage(eaUUID: eaUuid, artemisID: artemis, trackingIds: nil, postInterval: postInterval)
    }

    /// Builds an `EventsService` wired for sending events, without going through `setup()`
    /// (which would also trigger the unrelated identify/vendor-id network flow)
    func readyService(storage: StaticStorage, session: NetworkSession) throws -> EventsService {
        let configuration = try XCTUnwrap(configuration)
        let service = EventsService(
            storage: storage,
            configuration: configuration,
            eventsFactory: EventsFactory(),
            operationMode: OperationMode()
        )

        let apiUrl = URL(string: "https://test.com")!
        service.apiService = APIService(apiUrl: apiUrl, apiKey: "test_key", session: session)
        service.eventsQueueManager.delegate = service

        return service
    }

    /// Arranges a service with two sends: the first stays in-flight (`ManualNetworkSessionMock` never completes
    /// it on its own), the second is requested while the first is still in-flight.
    func serviceWithOverlappingSends() throws -> (service: EventsService, sessionMock: ManualNetworkSessionMock) {
        let sessionMock = ManualNetworkSessionMock()
        let service = try readyService(storage: validIdentityStorage(postInterval: 0), session: sessionMock)

        service.addEvents([Event(eventParameters: ["order": "first"])])
        service.addEvents([Event(eventParameters: ["order": "second"])])

        // `sendEventsIfPossible()` only proceeds once real wall-clock time has passed since the last send
        // (`postInterval` of 0 still requires `Date() >`, not `>=`). Without this, completing the in-flight
        // request below can retry the pending send within the same clock tick and get deferred to a timer
        // that never fires during a synchronous test, making the retry assertions flaky.
        wait(for: 0.05)

        return (service, sessionMock)
    }

    func eventResponseData(postInterval: Int) -> Data {
        Data("{\"postInterval\": \(postInterval)}".utf8)
    }

    func httpResponse(statusCode: Int) -> HTTPURLResponse {
        // swiftlint:disable:next force_unwrapping
        HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
