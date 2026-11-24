//
//  MediaUserTypeTests.swift
//  RingPublishingTrackingTests
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest
import Foundation

final class MediaUserTypeTests: XCTestCase {

    private let userData = UserDataDecorator()
    private var events = [Event]()

    private func makeSession() -> MediaSession {
        let factory = EventsFactory { [userData] in userData.isActiveSubscriber }

        return MediaSession(mediaType: .audio, playerVariant: nil, eventsFactory: factory) { [weak self] event in
            self?.events.append(event)
        }
    }

    private func start() -> MediaPlayingStartParameters {
        return MediaPlayingStartParameters(mediaId: "a1", durationSec: 100, mediaContentType: .main,
                                           playbackIntent: .userInitiated, positionSec: 0)
    }

    func testActiveSubscriber_eventsCarrySubscriber() {
        userData.updateActiveSubscriber(true)

        makeSession().createMediaContent().playingStart(start())

        XCTAssertEqual(events.count, 2)
        events.forEach { XCTAssertEqual($0.eventParameters["user_type"] as? String, "subscriber") }
    }

    func testNotSubscriber_eventsHaveNoUserType() {
        userData.updateActiveSubscriber(false)

        makeSession().createMediaContent().playingStart(start())

        XCTAssertEqual(events.count, 2)
        events.forEach { XCTAssertNil($0.eventParameters["user_type"]) }
    }

    func testFlagNeverSet_eventsHaveNoUserType() {
        makeSession().createMediaContent().playingStart(start())

        XCTAssertEqual(events.count, 2)
        events.forEach { XCTAssertNil($0.eventParameters["user_type"]) }
    }

    func testFlagChangeBetweenEvents_showsInTheNextEvent() {
        userData.updateActiveSubscriber(false)
        let content = makeSession().createMediaContent()
        content.playingStart(start())

        userData.updateActiveSubscriber(true)
        content.pause(positionSec: 10, reason: .userAction)

        XCTAssertEqual(events.count, 3)
        XCTAssertNil(events[0].eventParameters["user_type"])
        XCTAssertNil(events[1].eventParameters["user_type"])
        XCTAssertEqual(events[2].eventParameters["user_type"] as? String, "subscriber")
    }

    func testPublicFactory_readsFlagFromTheSdkState() {
        let tracking = RingPublishingTracking.shared
        var logs = [String]()
        tracking.loggerOutput = { logs.append($0) }
        tracking.eventsService = EventsService(
            storage: StaticStorage(),
            configuration: RingPublishingTrackingConfiguration(tenantId: "tenantID", apiKey: "some_api_key", applicationRootPath: "/"),
            eventsFactory: EventsFactory(),
            operationMode: OperationMode()
        )
        defer {
            tracking.loggerOutput = nil
            tracking.eventsService = nil
        }

        let session = tracking.createMediaSession(mediaType: .audio)
        _ = session.createMediaContent()
        XCTAssertFalse(logs.joined().contains("user_type"))

        tracking.updateActiveSubscriber(true)
        session.end()
        XCTAssertTrue(logs.contains { $0.contains("\"user_type\": \"subscriber\"") })
    }
}
