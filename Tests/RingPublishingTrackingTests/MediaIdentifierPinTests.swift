//
//  MediaIdentifierPinTests.swift
//  RingPublishingTrackingTests
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest
import Foundation

/// Media events go through the real `EventsService` decoration, a page view changes `IP` and `IV` in between.
final class MediaIdentifierPinTests: XCTestCase {

    private let factory = EventsFactory()
    private lazy var service = Self.makeService(factory: factory)

    // MARK: Tests

    func testEventsOfContent_afterPageView_keepIdentifiersOfPlaybackStart() throws {
        let session = makeSession()
        let content = session.createMediaContent()
        content.playingStart(start("a1"))
        let screenA = try XCTUnwrap(lastIdentifiers())

        reportPageView()
        let screenB = try XCTUnwrap(lastIdentifiers())
        XCTAssertNotEqual(screenA.primary, screenB.primary)

        content.playingProgress(positionSec: 1)
        content.pause(positionSec: 2, reason: .userAction)
        content.resume(positionSec: 2)
        content.seekStart(positionSec: 2, targetSec: 10)
        content.seekEnd(positionSec: 10)
        content.mute(positionSec: 11)
        content.unmute(positionSec: 12)
        content.outputChange(positionSec: 13, audioOutput: .car)
        content.visibilityChange(positionSec: 14, visibilityState: .background)
        content.error(positionSec: 15, code: "E1", message: "failure")
        content.playingEnd(positionSec: 16, reason: .userStopped)
        reportUnrelatedEvent()

        let types = ["MEDIA_SESSION_START", "MEDIA_PLAYING_START", "PageView", "MEDIA_PLAYING_PROGRESS", "MEDIA_PAUSE", "MEDIA_RESUME",
                     "MEDIA_SEEK_START", "MEDIA_SEEK_END", "MEDIA_MUTE", "MEDIA_UNMUTE", "MEDIA_OUTPUT_CHANGE",
                     "MEDIA_VISIBILITY_CHANGE", "MEDIA_ERROR", "MEDIA_PLAYING_END", "UNRELATED"]
        XCTAssertEqual(labels(), types)

        // The session start was sent before the page view, so it carries the first screen as well
        for (index, type) in types.enumerated() {
            let expected = ["PageView", "UNRELATED"].contains(type) ? screenB : screenA
            assertIdentifiers(queued[index], expected, type)
        }
    }

    func testSessionStart_carriesCurrentIdentifiers() throws {
        reportPageView()
        let current = try XCTUnwrap(lastIdentifiers())

        let session = makeSession()
        _ = session.createMediaContent()

        assertIdentifiers(queued[1], current, "MEDIA_SESSION_START")
    }

    func testPartialReload_doesNotLeakIntoPinnedEvents() throws {
        let content = makeSession().createMediaContent()
        content.playingStart(start("a1"))
        let screenA = try XCTUnwrap(lastIdentifiers())

        reportPageView(partiallyReloaded: true)
        let reloaded = try XCTUnwrap(lastIdentifiers())
        XCTAssertEqual(screenA.primary, reloaded.primary)
        XCTAssertNotEqual(screenA.secondary, reloaded.secondary)

        content.playingProgress(positionSec: 1)

        assertIdentifiers(queued[queued.count - 1], screenA, "MEDIA_PLAYING_PROGRESS")
    }

    func testReplay_pinsIdentifiersOfTheNewPlayingStart() throws {
        let content = makeSession().createMediaContent()
        content.playingStart(start("a1"))
        let screenA = try XCTUnwrap(lastIdentifiers())
        reportPageView()
        content.playingEnd(positionSec: 5, reason: .userStopped)
        assertIdentifiers(queued[queued.count - 1], screenA, "MEDIA_PLAYING_END")

        reportPageView()
        let screenC = try XCTUnwrap(lastIdentifiers())
        content.playingStart(start("a1"))
        reportPageView()
        content.playingProgress(positionSec: 1)

        assertIdentifiers(queued[queued.count - 3], screenC, "MEDIA_PLAYING_START")
        assertIdentifiers(queued[queued.count - 1], screenC, "MEDIA_PLAYING_PROGRESS")
    }

    func testAdInterruption_adUsesItsOwnPinAndMainEventsKeepTheirs() throws {
        let session = makeSession(mediaType: .video)
        let main = session.createMediaContent()
        main.playingStart(start("v1"))
        let screenA = try XCTUnwrap(lastIdentifiers())

        reportPageView()
        let screenB = try XCTUnwrap(lastIdentifiers())
        let advert = session.createMediaContent()
        advert.playingStart(MediaPlayingStartParameters(mediaId: "ad1", durationSec: 10, mediaContentType: .ad,
                                                        playbackIntent: .autoplay, positionSec: 0, mediaContentSubtype: .midroll,
                                                        relatedMediaId: "v1"))
        advert.playingProgress(positionSec: 1)
        advert.playingEnd(positionSec: 10, reason: .naturalCompletion)

        let types = ["MEDIA_SESSION_START", "MEDIA_PLAYING_START", "PageView", "MEDIA_PAUSE", "MEDIA_PLAYING_START",
                     "MEDIA_PLAYING_PROGRESS", "MEDIA_PLAYING_END", "MEDIA_RESUME"]
        XCTAssertEqual(labels(), types)

        let expected = [screenB, screenA, screenB, screenA, screenB, screenB, screenB, screenA]
        for (index, type) in types.enumerated() where index != 0 {
            assertIdentifiers(queued[index], expected[index], "\(type)#\(index)")
        }
        XCTAssertEqual(queued[3].parameters["pause_reason"] as? String, "ad")
    }

    func testSessionEnd_carriesPinOfTheLastPlayback() throws {
        let session = makeSession()
        let content = session.createMediaContent()
        content.playingStart(start("a1"))
        let screenA = try XCTUnwrap(lastIdentifiers())
        reportPageView()

        session.end()

        XCTAssertEqual(labels().last, "MEDIA_SESSION_END")
        assertIdentifiers(queued[queued.count - 1], screenA, "MEDIA_SESSION_END")
    }

    func testSessionEnd_withoutPlayback_carriesCurrentIdentifiers() throws {
        let session = makeSession()
        _ = session.createMediaContent()
        reportPageView()
        let current = try XCTUnwrap(lastIdentifiers())

        session.end()

        assertIdentifiers(queued[queued.count - 1], current, "MEDIA_SESSION_END")
    }

    func testSessions_arePinnedIndependently() throws {
        let first = makeSession().createMediaContent()
        first.playingStart(start("a1"))
        let screenA = try XCTUnwrap(lastIdentifiers())

        reportPageView()
        let second = makeSession().createMediaContent()
        second.playingStart(start("a2"))
        let screenB = try XCTUnwrap(lastIdentifiers())

        reportPageView()
        first.playingProgress(positionSec: 1)
        second.playingProgress(positionSec: 1)

        assertIdentifiers(queued[queued.count - 2], screenA, "first progress")
        assertIdentifiers(queued[queued.count - 1], screenB, "second progress")
    }

    func testOtherEvents_keepCurrentIdentifiers() throws {
        let content = makeSession().createMediaContent()
        content.playingStart(start("a1"))
        reportPageView()
        reportUnrelatedEvent()
        let current = try XCTUnwrap(lastIdentifiers())

        service.addEvents([factory.createPageViewEvent(contentIdentifier: nil, contentMetadata: nil)])

        assertIdentifiers(queued[queued.count - 1], current, "PageView")
    }

    // MARK: Helpers

    private struct Identifiers {
        let primary: String
        let secondary: String
    }

    private struct Queued {
        let name: String
        let parameters: [String: AnyHashable]
    }

    private var queued: [Queued] {
        return service.eventsQueueManager.events.allElements.map {
            Queued(name: $0.eventName, parameters: $0.eventParameters)
        }
    }

    private func labels() -> [String] {
        return queued.map { $0.parameters["event_type"] as? String ?? $0.name }
    }

    private func lastIdentifiers() -> Identifiers? {
        guard let last = queued.last,
              let primary = last.parameters["IP"] as? String,
              let secondary = last.parameters["IV"] as? String else { return nil }

        return Identifiers(primary: primary, secondary: secondary)
    }

    private func assertIdentifiers(_ event: Queued, _ expected: Identifiers, _ label: String,
                                   file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(event.parameters["IP"] as? String, expected.primary, "\(label) IP", file: file, line: line)
        XCTAssertEqual(event.parameters["IV"] as? String, expected.secondary, "\(label) IV", file: file, line: line)
    }

    private static func makeService(factory: EventsFactory) -> EventsService {
        let configuration = RingPublishingTrackingConfiguration(tenantId: "tenantID", apiKey: "key", applicationRootPath: "/")
        let service = EventsService(storage: StaticStorage(), configuration: configuration, eventsFactory: factory,
                                    operationMode: OperationMode())
        service.prepareDecorators()

        return service
    }

    private func makeSession(mediaType: MediaType = .audio) -> MediaSession {
        return MediaSession(mediaType: mediaType, playerVariant: nil) { [service] event in
            service.addEvents([event])
        }
    }

    private func start(_ mediaId: String) -> MediaPlayingStartParameters {
        return MediaPlayingStartParameters(mediaId: mediaId, durationSec: 60, mediaContentType: .main,
                                           playbackIntent: .autoplay, positionSec: 0)
    }

    private func reportPageView(partiallyReloaded: Bool = false) {
        service.updateUniqueIdentifier(partiallyReloaded: partiallyReloaded)
        service.addEvents([factory.createPageViewEvent(contentIdentifier: nil, contentMetadata: nil)])
    }

    private func reportUnrelatedEvent() {
        service.addEvents([Event(eventName: "UNRELATED", eventParameters: ["k": "v"])])
    }
}
