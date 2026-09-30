//
//  EventsServiceIdentityTests.swift
//  RingPublishingTrackingTests
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

/// Events reported before the identity requests (/me followed by /user) finish, which is what happens to the
/// first events after a fresh install
class EventsServiceIdentityTests: XCTestCase {

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

    func testSendEvents_eventReportedWhileIdentityIsInFlight_isNotSentBeforeIdentityFinishes() throws {
        // Given
        let sessionMock = ManualNetworkSessionMock()
        let service = try decoratedService(session: sessionMock)
        service.performSequentialIdentity(tenantID: "tenantID") { _ in }

        // When
        service.addEvents([Event.smallEvent()])

        // Then
        XCTAssertEqual(sessionMock.callCount, 1, "Only the identify request should be sent while the identifiers are missing")
    }

    func testSendEvents_eventReportedWhileIdentityIsInFlight_isSentWithIdentifiersOnceIdentityFinishes() throws {
        // Given
        let sessionMock = ManualNetworkSessionMock()
        let service = try decoratedService(session: sessionMock)
        service.performSequentialIdentity(tenantID: "tenantID") { _ in }
        service.addEvents([Event.smallEvent()])

        // When
        completeIdentity(sessionMock: sessionMock)

        // Then
        XCTAssertEqual(sessionMock.callCount, 3, "Events should be sent once the identify and Artemis requests finish")

        let body = try sentEventsBody(sessionMock: sessionMock)
        let ids = try XCTUnwrap(body["ids"] as? [String: String])
        XCTAssertEqual(ids["eaUUID"], "ea-uuid", "Events should be sent with the eaUUID returned by the identify request")

        let userData = try sentUserData(body: body)
        let artemisID = try XCTUnwrap(userData["id"] as? [String: Any])
        XCTAssertEqual(artemisID["artemis"] as? String, "artemis-id", "Event reported before the identifier was known should carry it")
    }

    func testSendEvents_eventReportedBeforeArtemisIDIsKnown_keepsUserDataCapturedWhenReported() throws {
        // Given
        let sessionMock = ManualNetworkSessionMock()
        let service = try decoratedService(session: sessionMock)
        service.updateSSO(ssoSystemName: "sso")
        service.updateUserData(userId: "user-1", email: "user@example.com")
        service.updateActiveSubscriber(true)
        service.performSequentialIdentity(tenantID: "tenantID") { _ in }
        service.addEvents([Event.smallEvent()])

        // When
        service.updateUserData(userId: "user-2", email: "other@example.com")
        service.updateActiveSubscriber(false)
        completeIdentity(sessionMock: sessionMock)

        // Then
        let userData = try sentUserData(body: sentEventsBody(sessionMock: sessionMock))
        let sso = try XCTUnwrap(userData["sso"] as? [String: Any])
        let logged = try XCTUnwrap(sso["logged"] as? [String: Any])
        XCTAssertEqual(logged["id"] as? String, "user-1", "User reported with the event should be kept when the identifier is added")
        XCTAssertEqual(userData["type"] as? String, "subscriber", "Subscriber type reported with the event should be kept")
        XCTAssertNotNil(userData["id"], "Artemis identifier should be added to the user data")
    }

    func testSendEvents_identityRequestFails_waitingEventIsStillSent() throws {
        // Given
        let sessionMock = ManualNetworkSessionMock()
        let service = try decoratedService(session: sessionMock)
        service.performSequentialIdentity(tenantID: "tenantID") { _ in }
        service.addEvents([Event.smallEvent()])

        // When
        sessionMock.completeOldestPendingRequest(error: URLError(.notConnectedToInternet))
        wait(for: 0.1)

        // Then
        XCTAssertEqual(sessionMock.callCount, 2, "A failed identify request should not leave the waiting events unsent")
    }

    func testAddEvents_debugModeEnabled_eventsAreNotKeptForArtemisCompletion() throws {
        // Given
        let operationMode = OperationMode()
        operationMode.debugEnabled = true
        let sessionMock = ManualNetworkSessionMock()
        let service = try decoratedService(session: sessionMock, operationMode: operationMode)

        // When
        service.addEvents([Event.smallEvent()])

        // Then
        XCTAssertTrue(service.eventsWithoutArtemisID.allElements.isEmpty, "Events which are never sent should not be kept")
        XCTAssertEqual(sessionMock.callCount, 0, "Debug mode should not send any request")
    }

    func testAddingArtemisID_eventWithoutUserData_userDataCarriesOnlyArtemisID() throws {
        // Given
        let event = Event.smallEvent()

        // When
        let completedEvent = event.addingArtemisID(artemisID())

        // Then
        let userData = try userData(of: completedEvent)
        XCTAssertEqual(Set(userData.keys), ["id"], "User data should carry only the Artemis identifier")
        XCTAssertEqual(completedEvent.eventParameters["key1"], event.eventParameters["key1"], "Other parameters should be kept")
        XCTAssertTrue(completedEvent.carriesArtemisID, "Completed event should carry the Artemis identifier")
    }

    func testAddingArtemisID_eventAlreadyCarryingArtemisID_eventIsUnchanged() {
        // Given
        let event = Event.smallEvent().addingArtemisID(artemisID())

        // When
        let completedEvent = event.addingArtemisID(ArtemisID(artemis: "other", external: artemisID().external))

        // Then
        XCTAssertEqual(completedEvent, event, "Event which already carries an Artemis identifier should not be changed")
    }
}

// MARK: Helpers
private extension EventsServiceIdentityTests {

    /// Builds an `EventsService` wired for sending events, with the generic decorators registered and no stored
    /// identifiers, as after a fresh install. `setup()` is not used, so no identity request starts on its own.
    func decoratedService(session: NetworkSession, operationMode: OperationMode = OperationMode()) throws -> EventsService {
        let configuration = try XCTUnwrap(configuration)
        let service = EventsService(
            storage: StaticStorage(),
            configuration: configuration,
            eventsFactory: EventsFactory(),
            operationMode: operationMode
        )

        // swiftlint:disable:next force_unwrapping
        let apiUrl = URL(string: "https://test.com")!
        service.apiService = APIService(apiUrl: apiUrl, apiKey: "test_key", session: session)
        service.eventsQueueManager.delegate = service
        service.prepareDecorators()

        return service
    }

    /// Completes the pending identify (/me) and Artemis (/user) requests, then lets the waiting send run
    func completeIdentity(sessionMock: ManualNetworkSessionMock) {
        let identifyResponse = """
        {"ids": {"eaUUID": {"value": "ea-uuid", "lifetime": 3600}}, "profile": {}, "postInterval": 0}
        """
        let artemisResponse = """
        {"cfg": {"ttl": 3600}, "user": {"id": {"real": "artemis-id", "model": "model", "models": {"ats_ri": "ri"}}}}
        """

        sessionMock.completeOldestPendingRequest(data: Data(identifyResponse.utf8), response: httpResponse(statusCode: 200))
        sessionMock.completeOldestPendingRequest(data: Data(artemisResponse.utf8), response: httpResponse(statusCode: 200))
        wait(for: 0.1)
    }

    func sentEventsBody(sessionMock: ManualNetworkSessionMock) throws -> [String: Any] {
        let request = try XCTUnwrap(sessionMock.requests.last)
        XCTAssertEqual(request.url?.path, "/\(Constants.apiVersion)", "The last request should send events")

        let body = try XCTUnwrap(request.httpBody)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
    }

    func sentUserData(body: [String: Any]) throws -> [String: Any] {
        let events = try XCTUnwrap(body["events"] as? [[String: Any]])
        let data = try XCTUnwrap(events.first?["data"] as? [String: Any])
        let rdlu = try XCTUnwrap(data["RDLU"] as? String)

        return try decodedUserData(rdlu)
    }

    func userData(of event: Event) throws -> [String: Any] {
        try decodedUserData(XCTUnwrap(event.eventParameters["RDLU"] as? String))
    }

    func decodedUserData(_ rdlu: String) throws -> [String: Any] {
        let data = try XCTUnwrap(Data(base64Encoded: rdlu))
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    func artemisID() -> ArtemisID {
        ArtemisID(artemis: "artemis-id", external: ArtemisExternal(model: "model", models: ["ats_ri": AnyCodable("ri")]))
    }

    func httpResponse(statusCode: Int) -> HTTPURLResponse {
        // swiftlint:disable:next force_unwrapping
        HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
