//
//  EventsServiceIdentityTests.swift
//  RingPublishingTrackingTests
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

/// The identity request (/me followed by /user) started by `setup`, and the events reported around it.
/// Storage is shared by reference, as `UserDefaultsStorage` is in production, so the events queue sees the
/// `postInterval` stored by the identify request.
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

    func testSetup_eventReportedWhileIdentityIsInFlight_isNotSentBeforeIdentityFinishes() throws {
        // Given
        let sessionMock = ManualNetworkSessionMock()
        let service = try startedService(storage: SharedStorage(), session: sessionMock)

        // When
        service.addEvents([Event.smallEvent()])

        // Then
        XCTAssertEqual(paths(of: sessionMock), [identifyPath], "Events should wait while the identifiers are fetched")
    }

    func testSetup_eventReportedWhileIdentityIsInFlight_isSentWithEaUUIDOnceIdentityFinishes() throws {
        // Given
        let sessionMock = ManualNetworkSessionMock()
        let service = try startedService(storage: SharedStorage(), session: sessionMock)
        service.addEvents([Event.smallEvent()])

        // When
        completeIdentity(sessionMock: sessionMock)

        // Then
        XCTAssertEqual(paths(of: sessionMock), [identifyPath, artemisPath, eventsPath], "Events should be sent once identity finishes")
        XCTAssertEqual(try sentIds(sessionMock: sessionMock)["eaUUID"], "ea-uuid", "Events should carry the eaUUID fetched meanwhile")
    }

    func testSetup_expiredIdentifierAndQueueReadyToSend_eventWaitsForNewIdentifier() throws {
        // Given: a relaunch with an expired eaUUID, while the stored post interval lets the queue send right away
        let sessionMock = ManualNetworkSessionMock()
        let storage = SharedStorage(eaUUID: eaUUID(createdHoursAgo: 48), artemisID: storedArtemis(), postInterval: 0)
        let service = try startedService(storage: storage, session: sessionMock)

        // When
        service.addEvents([Event.smallEvent()])
        let pathsWhileIdentityIsInFlight = paths(of: sessionMock)
        completeIdentity(sessionMock: sessionMock)

        // Then
        XCTAssertEqual(pathsWhileIdentityIsInFlight, [identifyPath], "Events should wait for the new identifier")
        XCTAssertEqual(try sentIds(sessionMock: sessionMock)["eaUUID"], "ea-uuid", "Events should carry the new eaUUID")
    }

    func testSetup_identifyRequestFails_identityIsRequestedAgainOnNextEvent() throws {
        // Given
        let sessionMock = ManualNetworkSessionMock()
        let service = try startedService(storage: SharedStorage(), session: sessionMock, identityRetryInterval: 0)
        sessionMock.completeOldestPendingRequest(error: URLError(.notConnectedToInternet))
        wait(for: 0.1)

        // When
        service.addEvents([Event.smallEvent()])
        completeIdentity(sessionMock: sessionMock)

        // Then
        XCTAssertFalse(service.isIdentifyMeRequestInProgress, "No identity request should be left in progress")
        XCTAssertEqual(paths(of: sessionMock), [identifyPath, identifyPath, artemisPath, eventsPath],
                       "Identity should be requested again after the failed identify request")
        XCTAssertEqual(try sentIds(sessionMock: sessionMock)["eaUUID"], "ea-uuid", "Events should carry the eaUUID fetched by the retry")
    }

    func testSetup_identifyRequestFails_identityIsNotRequestedForEveryEvent() throws {
        // Given
        let sessionMock = ManualNetworkSessionMock()
        let service = try startedService(storage: SharedStorage(), session: sessionMock)
        sessionMock.completeOldestPendingRequest(error: URLError(.notConnectedToInternet))
        wait(for: 0.1)

        // When
        service.addEvents([Event.smallEvent()])
        service.addEvents([Event.smallEvent()])
        service.addEvents([Event.smallEvent()])

        // Then
        let paths = paths(of: sessionMock)
        XCTAssertEqual(paths.filter { $0 == identifyPath }.count, 1, "Identity should not be requested again before the retry interval")
        XCTAssertTrue(paths.contains(eventsPath), "Events should still be sent while the identifiers are missing")
    }

    func testSetup_validStoredArtemisID_eventReportedBeforeIdentityFinishesCarriesStoredArtemisID() throws {
        // Given: a relaunch with valid stored identifiers
        let sessionMock = ManualNetworkSessionMock()
        let storage = SharedStorage(eaUUID: eaUUID(createdHoursAgo: 1), artemisID: storedArtemis(), postInterval: 0)
        let service = try startedService(storage: storage, session: sessionMock)

        // When
        service.addEvents([Event.smallEvent()])

        // Then
        XCTAssertEqual(paths(of: sessionMock), [identifyPath, eventsPath], "Events should not wait when valid identifiers are stored")
        let artemisID = try XCTUnwrap(sentUserData(sessionMock: sessionMock)["id"] as? [String: Any])
        XCTAssertEqual(artemisID["artemis"] as? String, "stored-artemis-id", "Events should carry the stored Artemis identifier")
    }

    func testSetup_debugModeEnabled_noRequestIsSent() throws {
        // Given
        let operationMode = OperationMode()
        operationMode.debugEnabled = true
        let sessionMock = ManualNetworkSessionMock()
        let service = try startedService(storage: SharedStorage(), session: sessionMock, operationMode: operationMode)

        // When
        service.addEvents([Event.smallEvent()])
        wait(for: 0.1)

        // Then
        XCTAssertEqual(sessionMock.callCount, 0, "Debug mode should not send any request")
        XCTAssertFalse(service.isIdentifyMeRequestInProgress, "Identity skipped in debug mode should not stay in progress")
    }

    func testSetup_identifyRequestFailsThenRetrySucceeds_trackingIdentifierIsPublished() throws {
        // Given
        let sessionMock = ManualNetworkSessionMock()
        let delegate = EventsServiceDelegateSpy()
        let service = try startedService(storage: SharedStorage(), session: sessionMock, identityRetryInterval: 0, delegate: delegate)
        sessionMock.completeOldestPendingRequest(error: URLError(.notConnectedToInternet))
        wait(for: 0.1)

        // When
        service.addEvents([Event.smallEvent()])
        completeIdentity(sessionMock: sessionMock)

        // Then
        XCTAssertEqual(delegate.failures.count, 1, "The failed identify request should be reported")
        XCTAssertEqual(delegate.retrievedIdentifiers.last?.eaUUID.value, "ea-uuid",
                       "The identifier fetched by the retry should be published")
    }

    func testSetup_retryFinishesOnNetworkQueueBeforePostInterval_eventIsStillSent() throws {
        // Given: a relaunch with an expired eaUUID and a stored post interval
        let sessionMock = ManualNetworkSessionMock()
        let storage = SharedStorage(eaUUID: eaUUID(createdHoursAgo: 48), artemisID: storedArtemis(), postInterval: 300)
        let service = try startedService(storage: storage, session: sessionMock, identityRetryInterval: 0)
        sessionMock.completeOldestPendingRequest(error: URLError(.notConnectedToInternet))
        wait(for: 0.1)
        service.addEvents([Event.smallEvent()])

        // When: the retried identity requests finish on a background thread, as URLSession completions do
        let completed = expectation(description: "Identity requests completed on a background thread")
        DispatchQueue.global().async {
            self.completeIdentityRequests(sessionMock: sessionMock, postInterval: 300)
            completed.fulfill()
        }
        wait(for: [completed], timeout: 1)
        wait(for: 1)

        // Then
        XCTAssertTrue(paths(of: sessionMock).contains(eventsPath), "Events should be sent once the post interval passes")
    }

    func testSetup_artemisRequestFailsWithoutAnswer_storedArtemisIDIsKept() throws {
        // Given: an offline relaunch with valid stored identifiers
        let sessionMock = ManualNetworkSessionMock()
        let storage = SharedStorage(eaUUID: eaUUID(createdHoursAgo: 1), artemisID: storedArtemis(), postInterval: 0)
        let service = try startedService(storage: storage, session: sessionMock)

        // When: /me fails, then /user, retried with the stored eaUUID, fails as well
        sessionMock.completeOldestPendingRequest(error: URLError(.notConnectedToInternet))
        sessionMock.completeOldestPendingRequest(error: URLError(.notConnectedToInternet))
        service.addEvents([Event.smallEvent()])

        // Then
        XCTAssertEqual(Array(paths(of: sessionMock).prefix(2)), [identifyPath, artemisPath],
                       "Artemis should be retried with the stored eaUUID")
        XCTAssertEqual(storage.artemisID?.id.artemis, "stored-artemis-id", "A request without an answer should keep the stored identifier")
        let artemisID = try XCTUnwrap(sentUserData(sessionMock: sessionMock)["id"] as? [String: Any])
        XCTAssertEqual(artemisID["artemis"] as? String, "stored-artemis-id", "Events should keep carrying the stored identifier")
    }

    func testSetup_artemisRequestRejectedByBackend_storedArtemisIDIsRemoved() throws {
        // Given
        let sessionMock = ManualNetworkSessionMock()
        let storage = SharedStorage(eaUUID: eaUUID(createdHoursAgo: 1), artemisID: storedArtemis(), postInterval: 0)
        let service = try startedService(storage: storage, session: sessionMock)
        _ = service

        // When: /me fails, then /user, retried with the stored eaUUID, is rejected
        sessionMock.completeOldestPendingRequest(error: URLError(.notConnectedToInternet))
        sessionMock.completeOldestPendingRequest(data: Data(), response: httpResponse(statusCode: 400))

        // Then
        XCTAssertNil(storage.artemisID, "An identifier request the backend rejects should remove the stored identifier")
    }

    func testSetup_identifyRequestFailsLaterThanRetryInterval_retryWaitsForTheIntervalAfterTheFailure() throws {
        // Given
        let sessionMock = ManualNetworkSessionMock()
        let service = try startedService(storage: SharedStorage(), session: sessionMock, identityRetryInterval: 0.3)

        // When: the identify request fails only after the retry interval
        wait(for: 0.5)
        sessionMock.completeOldestPendingRequest(error: URLError(.timedOut))
        wait(for: 0.1)
        service.addEvents([Event.smallEvent()])

        // Then
        XCTAssertEqual(paths(of: sessionMock).filter { $0 == identifyPath }.count, 1,
                       "Identity should not be retried right after a slow failure")
    }

    func testSetup_eventWaitingForIdentity_isSentOnceIdentifyAnswers() throws {
        // Given
        let sessionMock = ManualNetworkSessionMock()
        let service = try startedService(storage: SharedStorage(), session: sessionMock)
        service.addEvents([Event.smallEvent()])

        // When: /me answers while /user is still in flight
        sessionMock.completeOldestPendingRequest(data: identifyResponseData(postInterval: 0), response: httpResponse(statusCode: 200))
        wait(for: 0.1)

        // Then
        XCTAssertEqual(paths(of: sessionMock), [identifyPath, artemisPath, eventsPath], "Events should not wait for the Artemis identifier")
        XCTAssertEqual(try sentIds(sessionMock: sessionMock)["eaUUID"], "ea-uuid", "Events should carry the eaUUID")
    }
}

// MARK: Helpers
private extension EventsServiceIdentityTests {

    var identifyPath: String { "/\(Constants.apiVersion)/me" }
    var artemisPath: String { "/\(Constants.apiVersion)/user" }
    var eventsPath: String { "/\(Constants.apiVersion)" }

    /// Builds an `EventsService` and runs `setup`, which starts the identity request the way `initialize` does
    func startedService(storage: SharedStorage,
                        session: ManualNetworkSessionMock,
                        identityRetryInterval: TimeInterval? = nil,
                        operationMode: OperationMode = OperationMode(),
                        delegate: EventsServiceDelegate? = nil) throws -> EventsService {
        let service = EventsService(
            storage: storage,
            configuration: try XCTUnwrap(configuration),
            eventsFactory: EventsFactory(),
            operationMode: operationMode
        )

        if let identityRetryInterval {
            service.identityRetryInterval = identityRetryInterval
        }

        service.setup(delegate: delegate, session: session)

        return service
    }

    /// Completes the pending identify (/me) and Artemis (/user) requests, then lets the waiting send run
    func completeIdentity(sessionMock: ManualNetworkSessionMock) {
        completeIdentityRequests(sessionMock: sessionMock, postInterval: 0)
        wait(for: 0.1)
    }

    /// Completes the pending identify (/me) and Artemis (/user) requests on the calling thread
    func completeIdentityRequests(sessionMock: ManualNetworkSessionMock, postInterval: Int) {
        let artemisResponse = """
        {"cfg": {"ttl": 3600}, "user": {"id": {"real": "artemis-id", "model": "model", "models": {"ats_ri": "ri"}}}}
        """

        sessionMock.completeOldestPendingRequest(data: identifyResponseData(postInterval: postInterval),
                                                 response: httpResponse(statusCode: 200))
        sessionMock.completeOldestPendingRequest(data: Data(artemisResponse.utf8), response: httpResponse(statusCode: 200))
    }

    func identifyResponseData(postInterval: Int) -> Data {
        Data("""
        {"ids": {"eaUUID": {"value": "ea-uuid", "lifetime": 3600}}, "profile": {}, "postInterval": \(postInterval)}
        """.utf8)
    }

    func paths(of sessionMock: ManualNetworkSessionMock) -> [String] {
        sessionMock.requests.map { $0.url?.path ?? "" }
    }

    func sentEventsBody(sessionMock: ManualNetworkSessionMock) throws -> [String: Any] {
        let request = try XCTUnwrap(sessionMock.requests.last { $0.url?.path == eventsPath }, "No events request was sent")
        let body = try XCTUnwrap(request.httpBody)

        return try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
    }

    func sentIds(sessionMock: ManualNetworkSessionMock) throws -> [String: String] {
        try XCTUnwrap(sentEventsBody(sessionMock: sessionMock)["ids"] as? [String: String])
    }

    func sentUserData(sessionMock: ManualNetworkSessionMock) throws -> [String: Any] {
        let events = try XCTUnwrap(sentEventsBody(sessionMock: sessionMock)["events"] as? [[String: Any]])
        let parameters = try XCTUnwrap(events.first?["data"] as? [String: Any])
        let rdlu = try XCTUnwrap(parameters["RDLU"] as? String)
        let userData = try XCTUnwrap(Data(base64Encoded: rdlu))

        return try XCTUnwrap(JSONSerialization.jsonObject(with: userData) as? [String: Any])
    }

    func eaUUID(createdHoursAgo hours: Double) -> EaUUID {
        EaUUID(value: "stored-ea-uuid", lifetime: 60 * 60 * 24, creationDate: Date().addingTimeInterval(-hours * 60 * 60))
    }

    func storedArtemis() -> Artemis {
        let external = ArtemisExternal(model: "model", models: ["ats_ri": AnyCodable("ri")])
        return Artemis(id: ArtemisID(artemis: "stored-artemis-id", external: external), lifetime: 60 * 60, creationDate: Date())
    }

    func httpResponse(statusCode: Int) -> HTTPURLResponse {
        // swiftlint:disable:next force_unwrapping
        HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

/// Records what the service reports about the tracking identifier
private final class EventsServiceDelegateSpy: EventsServiceDelegate {

    private(set) var retrievedIdentifiers: [TrackingIdentifier] = []
    private(set) var failures: [ServiceError] = []

    func eventsService(_ eventsService: EventsService, didFailWhileRetrievingTrackingIdentifier error: ServiceError) {
        failures.append(error)
    }

    func eventsService(_ eventsService: EventsService, retrievedTrackingIdentifier identifier: TrackingIdentifier) {
        retrievedIdentifiers.append(identifier)
    }

    func eventsService(_ eventsService: EventsService, didAssignSessionIdentifier identifier: String) {}
}

/// Storage shared by reference, as `UserDefaultsStorage` is in production
private final class SharedStorage: TrackingStorage {

    var eaUUID: EaUUID?
    var artemisID: Artemis?
    var trackingIds: [String: IdsWithLifetime]?
    var postInterval: Int?
    var randomUniqueDeviceId: String?

    init(eaUUID: EaUUID? = nil, artemisID: Artemis? = nil, postInterval: Int? = nil) {
        self.eaUUID = eaUUID
        self.artemisID = artemisID
        self.postInterval = postInterval
    }
}
