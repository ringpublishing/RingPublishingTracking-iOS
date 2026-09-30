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
                        operationMode: OperationMode = OperationMode()) throws -> EventsService {
        let service = EventsService(
            storage: storage,
            configuration: try XCTUnwrap(configuration),
            eventsFactory: EventsFactory(),
            operationMode: operationMode
        )

        if let identityRetryInterval {
            service.identityRetryInterval = identityRetryInterval
        }

        service.setup(delegate: nil, session: session)

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
