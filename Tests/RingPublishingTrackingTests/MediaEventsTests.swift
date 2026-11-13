//
//  MediaEventsTests.swift
//  RingPublishingTrackingTests
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest
import Foundation

final class MediaEventsTests: XCTestCase {

    private let recorder = MediaEventRecorder()
    private var logs = [String]()

    override func setUp() {
        super.setUp()

        recorder.reset()
        logs = []
        RingPublishingTracking.shared.loggerOutput = { [weak self] message in
            self?.logs.append(message)
        }
    }

    override func tearDown() {
        RingPublishingTracking.shared.loggerOutput = nil

        super.tearDown()
    }

    // MARK: Fixture parity

    func testScenarioA_audio_matchesWebFixture() throws {
        let session = MediaScenarios.runAudio(recorder: recorder)

        try assertParity(of: recorder.events, with: MediaScenarioFixtures.audio, session: session)
        XCTAssertEqual(session.eventOrdinal, 13)
        XCTAssertFalse(session.isActive)
    }

    func testScenarioB_video_matchesWebFixture() throws {
        let session = MediaScenarios.runVideo(recorder: recorder)

        try assertParity(of: recorder.events, with: MediaScenarioFixtures.video, session: session)
        XCTAssertFalse(session.isActive)
    }

    func testScenarioC_ttsWithoutContent_sendsNothing() throws {
        let session = recorder.makeSession(mediaType: .tts)
        session.end()

        try assertParity(of: recorder.events, with: MediaScenarioFixtures.ttsEmpty, session: session)
        XCTAssertEqual(session.eventOrdinal, 0)
    }

    // MARK: Event shape

    func testEvent_isGenericMediaEventWithRT() throws {
        let session = recorder.makeSession(mediaType: .video)
        _ = session.createMediaContent()

        let event = try XCTUnwrap(recorder.events.first)
        XCTAssertEqual(event.analyticsSystemName, AnalyticsSystem.generic.rawValue)
        XCTAssertEqual(event.eventName, "MediaEvent")
        XCTAssertEqual(event.eventParameters["RT"], "MediaEvent")
        XCTAssertEqual(event.eventParameters["event_type"], "MEDIA_SESSION_START")
        XCTAssertNil(event.eventParameters["player_variant"])
        XCTAssertNil(event.eventParameters["media_id"])
        XCTAssertEqual(event.eventParameters["user_engaged"], false)
        XCTAssertEqual(event.eventParameters["muted"], true)
        XCTAssertEqual(event.eventParameters["audio_output"], "speaker")
        XCTAssertEqual(event.eventParameters["visibility_state"], "visible")
        XCTAssertEqual(event.eventParameters["playback_rate"], 1.0)
    }

    func testSession_sessionIdIsUUID() {
        let session = recorder.makeSession(mediaType: .audio)

        XCTAssertEqual(session.sessionId.count, 36)
        XCTAssertNotNil(UUID(uuidString: session.sessionId))
        XCTAssertEqual(session.sessionId, session.sessionId.lowercased())
        XCTAssertNotEqual(session.sessionId, recorder.makeSession(mediaType: .audio).sessionId)
    }

    func testPublicFactory_createsSessionWithInitialState() {
        let session = RingPublishingTracking.shared.createMediaSession(mediaType: .audio, playerVariant: "main")

        XCTAssertTrue(session.isActive)
        XCTAssertEqual(session.eventOrdinal, 0)
        XCTAssertTrue(session.muted)
        XCTAssertEqual(session.visibilityState, .visible)
        XCTAssertEqual(session.audioOutput, .speaker)
        XCTAssertEqual(session.playbackRate, 1.0)
    }

    func testPublicFactory_eventsGoThroughReportingPath() {
        let session = RingPublishingTracking.shared.createMediaSession(mediaType: .video)
        _ = session.createMediaContent()

        XCTAssertTrue(logs.contains { $0.contains("Reporting generic event: MediaEvent") })
    }

    // MARK: Playback rate

    func testUpdatePlaybackRate_changesLaterEventsAndSendsNothing() throws {
        let session = recorder.makeSession(mediaType: .audio)
        let content = session.createMediaContent()
        content.playingStart(MediaPlayingStartParameters(mediaId: "a1", durationSec: 60, mediaContentType: .main,
                                                         playbackIntent: .autoplay, positionSec: 0))
        let countBefore = recorder.events.count

        session.updatePlaybackRate(2.0)

        XCTAssertEqual(recorder.events.count, countBefore)
        XCTAssertEqual(session.playbackRate, 2.0)

        content.playingProgress(positionSec: 5)

        XCTAssertEqual(recorder.events.last?.eventParameters["playback_rate"], 2.0)
        XCTAssertEqual(recorder.events.first?.eventParameters["playback_rate"], 1.0)
    }

    func testUpdatePlaybackRate_afterEnd_isIgnored() {
        let session = recorder.makeSession(mediaType: .audio)
        session.end()

        session.updatePlaybackRate(2.0)

        XCTAssertEqual(session.playbackRate, 1.0)
    }

    // MARK: Validation

    func testValidation_invalidValues_warnButStillSend() {
        let session = recorder.makeSession(mediaType: .video, playerVariant: String(repeating: "p", count: 65))
        let content = session.createMediaContent(MediaContentConfiguration(playbackRate: 20))

        content.playingStart(MediaPlayingStartParameters(mediaId: "",
                                                         durationSec: -1,
                                                         mediaContentType: .main,
                                                         playbackIntent: .autoplay,
                                                         positionSec: -5,
                                                         mediaVariant: String(repeating: "v", count: 65)))
        content.error(positionSec: 1, code: "123456789", message: "")

        XCTAssertEqual(recorder.events.map { $0.eventParameters["event_type"] },
                       ["MEDIA_SESSION_START", "MEDIA_PLAYING_START", "MEDIA_ERROR"])
        XCTAssertEqual(recorder.events[1].eventParameters["position_sec"], -5.0)
        XCTAssertEqual(recorder.events[2].eventParameters["error_code"], "123456789")

        let fields = ["player_variant", "playback_rate", "media_id", "duration_sec",
                      "position_sec", "media_variant", "error_code", "error_message"]

        for field in fields {
            XCTAssertTrue(logs.contains { $0.contains("[MediaEvent]") && $0.contains("'\(field)'") }, "No warning for \(field)")
        }
    }

    func testValidation_adWithoutSubtypeAndRelatedMedia_warnsAndSends() {
        let session = recorder.makeSession(mediaType: .video)
        let advert = session.createMediaContent()

        advert.playingStart(MediaPlayingStartParameters(mediaId: "ad1", durationSec: 5, mediaContentType: .ad,
                                                    playbackIntent: .autoplay, positionSec: 0))

        XCTAssertEqual(recorder.events.last?.eventParameters["event_type"], "MEDIA_PLAYING_START")
        XCTAssertNil(recorder.events.last?.eventParameters["related_media_id"])
        XCTAssertTrue(logs.contains { $0.contains("'media_content_subtype' is missing") })
        XCTAssertTrue(logs.contains { $0.contains("'related_media_id' is missing") })
    }

    func testValidation_validValues_noWarning() {
        let session = recorder.makeSession(mediaType: .video, playerVariant: "inline")
        let content = session.createMediaContent(MediaContentConfiguration(playbackRate: 16))

        content.playingStart(MediaPlayingStartParameters(mediaId: String(repeating: "m", count: 36), durationSec: 0,
                                                         mediaContentType: .main, playbackIntent: .autoplay, positionSec: 0))
        content.error(positionSec: 0, code: "12345678", message: "x")

        XCTAssertFalse(logs.contains { $0.contains("[MediaEvent]") })
    }

    func testIgnoredCall_isLoggedAndSendsNothing() {
        let session = recorder.makeSession(mediaType: .video)
        let content = session.createMediaContent()
        let countBefore = recorder.events.count

        content.playingProgress(positionSec: 1)

        XCTAssertEqual(recorder.events.count, countBefore)
        XCTAssertTrue(logs.contains { $0.contains("playingProgress ignored") })
    }

    func testIgnoredSeekStart_whenSeekIsOpen_logsSeekReason() {
        let session = recorder.makeSession(mediaType: .video)
        let content = session.createMediaContent()
        content.playingStart(MediaPlayingStartParameters(mediaId: "v1", durationSec: 100, mediaContentType: .main,
                                                         playbackIntent: .autoplay, positionSec: 0))
        content.seekStart(positionSec: 1)
        let countBefore = recorder.events.count

        content.seekStart(positionSec: 2)

        XCTAssertEqual(recorder.events.count, countBefore)
        XCTAssertTrue(logs.contains { $0.contains("seekStart ignored: a seek is already in progress") })
        XCTAssertFalse(logs.contains { $0.contains("seekStart ignored: not allowed in the current state") })
    }

    // MARK: State machine

    func testAd_pausesRelatedContentAndResumesItAtContentPosition() {
        let session = recorder.makeSession(mediaType: .video)
        let main = session.createMediaContent()
        main.playingStart(MediaPlayingStartParameters(mediaId: "v1", durationSec: 100, mediaContentType: .main,
                                                      playbackIntent: .autoplay, positionSec: 0, userEngaged: true))
        main.playingProgress(positionSec: 12)

        let advert = session.createMediaContent()
        advert.playingStart(MediaPlayingStartParameters(mediaId: "ad1", durationSec: 5, mediaContentType: .ad,
                                                    playbackIntent: .autoplay, positionSec: 0, mediaContentSubtype: .preroll))
        advert.playingEnd(positionSec: 5, reason: .naturalCompletion)

        let types = recorder.events.compactMap { $0.eventParameters["event_type"] as? String }
        XCTAssertEqual(types.suffix(4), ["MEDIA_PAUSE", "MEDIA_PLAYING_START", "MEDIA_PLAYING_END", "MEDIA_RESUME"])

        let pause = recorder.events[recorder.events.count - 4].eventParameters
        XCTAssertEqual(pause["pause_reason"], "ad")
        XCTAssertEqual(pause["position_sec"], 12.0)
        XCTAssertEqual(pause["user_engaged"], false)
        XCTAssertEqual(pause["media_id"], "v1")

        let adStart = recorder.events[recorder.events.count - 3].eventParameters
        XCTAssertEqual(adStart["related_media_id"], "v1")

        let resume = recorder.events[recorder.events.count - 1].eventParameters
        XCTAssertEqual(resume["position_sec"], 12.0)
        XCTAssertEqual(resume["media_id"], "v1")
        XCTAssertTrue(main.hasActiveContent)
    }

    func testPlayingEnd_whileSeeking_closesSeekAtTargetAndDropsHeldResume() {
        let session = recorder.makeSession(mediaType: .audio)
        let content = session.createMediaContent()
        content.playingStart(MediaPlayingStartParameters(mediaId: "a1", durationSec: 100, mediaContentType: .main,
                                                         playbackIntent: .autoplay, positionSec: 0))
        content.pause(positionSec: 10, reason: .userAction)
        content.seekStart(positionSec: 10, targetSec: 40)
        content.resume(positionSec: 10)
        XCTAssertTrue(content.isSeeking)

        content.playingEnd(positionSec: 40, reason: .userStopped)

        let tail = recorder.events.suffix(2)
        XCTAssertEqual(tail.compactMap { $0.eventParameters["event_type"] as? String }, ["MEDIA_SEEK_END", "MEDIA_PLAYING_END"])
        XCTAssertEqual(tail.first?.eventParameters["position_sec"], 40.0)
        XCTAssertFalse(content.isSeeking)
        XCTAssertFalse(content.hasActiveContent)
    }

    func testSessionEnd_whileSeeking_closesSeekBeforeSessionEnd() {
        let session = recorder.makeSession(mediaType: .audio)
        let content = session.createMediaContent()
        content.playingStart(MediaPlayingStartParameters(mediaId: "a1", durationSec: 100, mediaContentType: .main,
                                                         playbackIntent: .autoplay, positionSec: 0))
        content.seekStart(positionSec: 10)

        session.end()

        let types = recorder.events.suffix(2).compactMap { $0.eventParameters["event_type"] as? String }
        XCTAssertEqual(types, ["MEDIA_SEEK_END", "MEDIA_SESSION_END"])
        XCTAssertEqual(recorder.events.suffix(2).first?.eventParameters["position_sec"], 10.0)
        XCTAssertEqual(recorder.events.last?.eventParameters["media_id"], "a1")
    }

    func testMute_sendsEvenWhenStateDoesNotChange() {
        let session = recorder.makeSession(mediaType: .video)
        let content = session.createMediaContent()
        content.playingStart(MediaPlayingStartParameters(mediaId: "v1", durationSec: 10, mediaContentType: .main,
                                                         playbackIntent: .autoplay, positionSec: 0))

        content.mute(positionSec: 1)

        XCTAssertEqual(recorder.events.last?.eventParameters["event_type"], "MEDIA_MUTE")
        XCTAssertEqual(recorder.events.last?.eventParameters["user_engaged"], false)

        content.unmute(positionSec: 2)

        XCTAssertEqual(recorder.events.last?.eventParameters["event_type"], "MEDIA_UNMUTE")
        XCTAssertEqual(recorder.events.last?.eventParameters["user_engaged"], true)
        XCTAssertFalse(session.muted)
    }

    func testContentOnEndedSession_isInert() {
        let session = recorder.makeSession(mediaType: .video)
        session.end()

        let content = session.createMediaContent()
        content.playingStart(MediaPlayingStartParameters(mediaId: "v1", durationSec: 10, mediaContentType: .main,
                                                         playbackIntent: .autoplay, positionSec: 0))

        XCTAssertTrue(recorder.events.isEmpty)
        XCTAssertFalse(content.hasActiveContent)
    }

    // MARK: Concurrency

    func testConcurrentCalls_giveUniqueGapFreeOrdinalsInDeliveryOrder() {
        let session = recorder.makeSession(mediaType: .audio)
        let content = session.createMediaContent()
        content.playingStart(MediaPlayingStartParameters(mediaId: "a1", durationSec: 1000, mediaContentType: .main,
                                                         playbackIntent: .autoplay, positionSec: 0))
        let perThread = 200
        let threads = 8

        DispatchQueue.concurrentPerform(iterations: threads) { thread in
            for index in 0..<perThread {
                switch index % 3 {
                case 0:
                    content.playingProgress(positionSec: Double(index))
                case 1:
                    session.updatePlaybackRate(Double(thread + 1))
                default:
                    _ = session.eventOrdinal
                }
            }
        }
        session.end()

        let ordinals = recorder.events.compactMap { $0.eventParameters["event_ordinal"] as? Int }
        XCTAssertEqual(ordinals.count, recorder.events.count)
        XCTAssertEqual(Set(ordinals).count, ordinals.count)
        XCTAssertEqual(ordinals, Array(1...ordinals.count))
        XCTAssertEqual(ordinals.count, 2 + threads * ((perThread + 2) / 3) + 1)
    }

    // MARK: Deprecated methods

    @available(*, deprecated)
    func testDeprecatedMethods_stillSendLegacyVidEvent() {
        let videoMetadata = VideoMetadata(publicationId: "pub1",
                                          contentId: "content1",
                                          isMainContentPiece: true,
                                          videoStreamFormat: .hls,
                                          videoDuration: 60,
                                          videoContentCategory: .free,
                                          videoAdsConfiguration: .enabled,
                                          videoPlayerVersion: "1.0.0")
        let videoState = VideoState(currentTime: 1, currentBitrate: "360", isMuted: false, visibility: .visible, startMode: .normal)
        let audioMetadata = AudioMetadata(contentId: "12167",
                                          contentTitle: "Title",
                                          contentSeriesId: "67",
                                          contentSeriesTitle: "Series",
                                          mediaType: .podcast,
                                          audioDuration: 3722,
                                          audioStreamFormat: .mp3,
                                          isContentFragment: false,
                                          audioContentCategory: .free,
                                          audioPlayerVersion: "1.0.0")
        let audioState = AudioState(currentTime: 10, currentBitrate: 360, visibilityState: .background, audioOutput: .bluetooth)
        let tracking = RingPublishingTracking.shared

        tracking.reportVideoEvent(.start, videoMetadata: videoMetadata, videoState: videoState)
        tracking.reportAudioEvent(audioEvent: .start, audioMetadata: audioMetadata, audioState: audioState)

        let reported = logs.filter { $0.contains("Reporting generic event:") }
        XCTAssertEqual(reported.count, 2)
        XCTAssertTrue(reported.allSatisfy { $0.contains("Reporting generic event: VidEvent") })
        XCTAssertFalse(logs.contains { $0.contains("MediaEvent") })
    }
}

// MARK: Helpers

private extension MediaEventsTests {

    func assertParity(of events: [Event],
                      with fixtureJSON: String,
                      session: MediaSession,
                      file: StaticString = #filePath,
                      line: UInt = #line) throws {
        let data = try XCTUnwrap(fixtureJSON.data(using: .utf8))
        let fixture = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [[String: Any]])

        XCTAssertEqual(events.count, fixture.count, "Event count", file: file, line: line)

        for (index, (event, expected)) in zip(events, fixture).enumerated() {
            let context = "event #\(index + 1) (\(expected["event_type"] ?? "?"))"
            let actual = event.eventParameters

            XCTAssertEqual(event.analyticsSystemName, AnalyticsSystem.generic.rawValue, context, file: file, line: line)
            XCTAssertEqual(event.eventName, "MediaEvent", context, file: file, line: line)
            XCTAssertEqual(Set(actual.keys), Set(expected.keys), "\(context): key set", file: file, line: line)

            for (key, expectedValue) in expected {
                guard let actualValue = actual[key] else { continue }

                if key == "media_session_id" {
                    XCTAssertEqual(actualValue as? String, session.sessionId, context, file: file, line: line)
                    XCTAssertEqual(session.sessionId.count, 36, context, file: file, line: line)
                    XCTAssertEqual(session.sessionId, session.sessionId.lowercased(), context, file: file, line: line)
                    XCTAssertNotNil(UUID(uuidString: session.sessionId), context, file: file, line: line)
                } else {
                    XCTAssertTrue(equal(actualValue.base, expectedValue), "\(context): \(key) \(actualValue) != \(expectedValue)",
                                  file: file, line: line)
                }
            }
        }
    }

    func equal(_ actual: Any, _ expected: Any) -> Bool {
        if let expected = expected as? String {
            return actual as? String == expected
        }

        guard let expectedNumber = expected as? NSNumber else { return false }

        if CFGetTypeID(expectedNumber) == CFBooleanGetTypeID() {
            return actual as? Bool == expectedNumber.boolValue
        }

        if let actual = actual as? Double {
            return actual == expectedNumber.doubleValue
        }

        if let actual = actual as? Int {
            return Double(actual) == expectedNumber.doubleValue
        }

        return false
    }
}
