//
//  MediaDeliveryTests.swift
//  RingPublishingTrackingTests
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest
import Foundation

final class MediaDeliveryTests: XCTestCase {

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

    func testEventDelivery_doesNotHoldSessionLockWhileSinkIsBlocked() {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let storageLock = NSLock()
        var delivered = [Event]()
        var blocked = false

        let session = MediaSession(mediaType: .audio, playerVariant: nil) { event in
            storageLock.lock()
            let shouldBlock = event.eventParameters["event_type"] as? String == "MEDIA_PLAYING_PROGRESS" && !blocked
            blocked = blocked || shouldBlock
            storageLock.unlock()

            if shouldBlock {
                entered.signal()
                _ = release.wait(timeout: .now() + 5)
            }

            storageLock.lock()
            delivered.append(event)
            storageLock.unlock()
        }
        let content = session.createMediaContent()
        content.playingStart(MediaPlayingStartParameters(mediaId: "a1", durationSec: 60, mediaContentType: .main,
                                                         playbackIntent: .autoplay, positionSec: 0))

        let threadBDone = DispatchSemaphore(value: 0)
        let threadCDone = DispatchSemaphore(value: 0)

        DispatchQueue.global().async {
            content.playingProgress(positionSec: 5)
            threadBDone.signal()
        }

        XCTAssertEqual(entered.wait(timeout: .now() + 5), .success)

        DispatchQueue.global().async {
            content.mute(positionSec: 6)
            threadCDone.signal()
        }

        XCTAssertEqual(threadCDone.wait(timeout: .now() + 2), .success, "mute blocked while another thread delivers")

        release.signal()
        XCTAssertEqual(threadBDone.wait(timeout: .now() + 5), .success)

        storageLock.lock()
        let types = delivered.compactMap { $0.eventParameters["event_type"] as? String }
        let ordinals = delivered.compactMap { $0.eventParameters["event_ordinal"] as? Int }
        storageLock.unlock()

        XCTAssertEqual(types, ["MEDIA_SESSION_START", "MEDIA_PLAYING_START", "MEDIA_PLAYING_PROGRESS", "MEDIA_MUTE"])
        XCTAssertEqual(ordinals, [1, 2, 3, 4])
    }

    func testSinkCallingBackIntoSession_isQueuedAndDeliveredInOrder() {
        var delivered = [String]()
        var content: MediaContent?
        var reentered = false

        let session = MediaSession(mediaType: .audio, playerVariant: nil) { event in
            delivered.append(event.eventParameters["event_type"] as? String ?? "")

            if event.eventParameters["event_type"] as? String == "MEDIA_PLAYING_START", !reentered {
                reentered = true
                content?.mute(positionSec: 1)
                delivered.append("after-reentrant-call")
            }
        }
        content = session.createMediaContent()
        content?.playingStart(MediaPlayingStartParameters(mediaId: "a1", durationSec: 60, mediaContentType: .main,
                                                          playbackIntent: .autoplay, positionSec: 0))

        XCTAssertEqual(delivered, ["MEDIA_SESSION_START", "MEDIA_PLAYING_START", "after-reentrant-call", "MEDIA_MUTE"])
    }

    private func assertNoNonFiniteNumbers(in event: Event, file: StaticString = #filePath, line: UInt = #line) {
        for (key, value) in event.eventParameters {
            if let number = value as? Double {
                XCTAssertTrue(number.isFinite, "\(key) is not finite", file: file, line: line)
            }
        }
    }

    private func assertWarned(_ method: String, field: String, file: StaticString = #filePath, line: UInt = #line) {
        let matching = logs.filter { $0.contains("[MediaEvent] \(method): '\(field)' must be a finite number") }
        XCTAssertEqual(matching.count, 1, "Expected one warning for \(method)/\(field)", file: file, line: line)
    }

    private func startedContent(duration: Double = 60) -> (MediaSession, MediaContent) {
        let session = recorder.makeSession(mediaType: .audio)
        let content = session.createMediaContent()
        content.playingStart(MediaPlayingStartParameters(mediaId: "a1", durationSec: duration, mediaContentType: .main,
                                                         playbackIntent: .autoplay, positionSec: 10))
        logs = []

        return (session, content)
    }

    func testNonFinite_positionInEveryMethod_isDroppedAndEventStillSent() {
        let values = [Double.nan, .infinity, -.infinity]

        for value in values {
            recorder.reset()
            logs = []
            let session = recorder.makeSession(mediaType: .audio)
            let content = session.createMediaContent()

            content.playingStart(MediaPlayingStartParameters(mediaId: "a1", durationSec: 60, mediaContentType: .main,
                                                             playbackIntent: .autoplay, positionSec: value))
            content.playingProgress(positionSec: value)
            content.pause(positionSec: value, reason: .userAction)
            content.resume(positionSec: value)
            content.seekStart(positionSec: value)
            content.seekEnd(positionSec: value)
            content.mute(positionSec: value)
            content.unmute(positionSec: value)
            content.outputChange(positionSec: value, audioOutput: .car)
            content.visibilityChange(positionSec: value, visibilityState: .background)
            content.error(positionSec: value, code: "E1", message: "boom")
            content.playingEnd(positionSec: value, reason: .userStopped)

            let types = recorder.events.compactMap { $0.eventParameters["event_type"] as? String }
            XCTAssertEqual(types, ["MEDIA_SESSION_START", "MEDIA_PLAYING_START", "MEDIA_PLAYING_PROGRESS", "MEDIA_PAUSE", "MEDIA_RESUME",
                                   "MEDIA_SEEK_START", "MEDIA_SEEK_END", "MEDIA_MUTE", "MEDIA_UNMUTE", "MEDIA_OUTPUT_CHANGE",
                                   "MEDIA_VISIBILITY_CHANGE", "MEDIA_ERROR", "MEDIA_PLAYING_END"])

            for event in recorder.events {
                XCTAssertNil(event.eventParameters["position_sec"])
                assertNoNonFiniteNumbers(in: event)
            }

            for method in ["playingStart", "playingProgress", "pause", "resume", "seekStart", "seekEnd", "mute", "unmute",
                           "outputChange", "visibilityChange", "error", "playingEnd"] {
                assertWarned(method, field: "position_sec")
            }

            XCTAssertFalse(logs.contains { $0.contains("must be at least 0") })
        }
    }

    func testNonFinite_position_leavesLastPositionUnchanged() {
        let (_, content) = startedContent()

        content.playingProgress(positionSec: 20)
        content.seekStart(positionSec: 20)
        content.playingProgress(positionSec: .nan)
        content.pause(positionSec: 21, reason: .userAction)
        content.seekEnd(positionSec: .nan)

        let seekEnd = recorder.events.last { $0.eventParameters["event_type"] as? String == "MEDIA_SEEK_END" }
        XCTAssertNotNil(seekEnd)
        XCTAssertNil(seekEnd?.eventParameters["position_sec"])

        let session = recorder.makeSession(mediaType: .video)
        let main = session.createMediaContent()
        main.playingStart(MediaPlayingStartParameters(mediaId: "v1", durationSec: 60, mediaContentType: .main,
                                                      playbackIntent: .autoplay, positionSec: 30))
        main.playingProgress(positionSec: .nan)
        let advert = session.createMediaContent()
        advert.playingStart(MediaPlayingStartParameters(mediaId: "ad1", durationSec: 10, mediaContentType: .ad, playbackIntent: .autoplay,
                                                        positionSec: 0, mediaContentSubtype: .preroll))
        let pause = recorder.events.last { $0.eventParameters["event_type"] as? String == "MEDIA_PAUSE" }

        XCTAssertEqual(pause?.eventParameters["position_sec"], 30.0)
    }

    func testNonFinite_duration_isLeftOutOfThisAndLaterEvents() {
        let session = recorder.makeSession(mediaType: .video)
        let content = session.createMediaContent()

        content.playingStart(MediaPlayingStartParameters(mediaId: "v1", durationSec: .nan, mediaContentType: .main,
                                                         playbackIntent: .autoplay, positionSec: 0))
        content.playingProgress(positionSec: 5)

        assertWarned("playingStart", field: "duration_sec")
        XCTAssertFalse(logs.contains { $0.contains("duration_sec") && $0.contains("must be at least 0") })

        for event in recorder.events.dropFirst() {
            XCTAssertNil(event.eventParameters["duration_sec"])
            assertNoNonFiniteNumbers(in: event)
        }

        XCTAssertEqual(recorder.events.count, 3)
    }

    func testNonFinite_seekTarget_isTreatedAsNotGiven() {
        let (_, content) = startedContent()

        content.seekStart(positionSec: 10, targetSec: .infinity)
        content.playingEnd(positionSec: 12, reason: .userStopped)

        assertWarned("seekStart", field: "target_sec")

        let types = recorder.events.compactMap { $0.eventParameters["event_type"] as? String }
        XCTAssertEqual(types.suffix(3), ["MEDIA_SEEK_START", "MEDIA_SEEK_END", "MEDIA_PLAYING_END"])
        XCTAssertEqual(recorder.events[recorder.events.count - 2].eventParameters["position_sec"], 10.0)
        recorder.events.forEach { assertNoNonFiniteNumbers(in: $0) }
    }

    func testNonFinite_playbackRate_leavesSessionRateUnchanged() {
        let session = recorder.makeSession(mediaType: .audio)
        session.updatePlaybackRate(1.5)
        logs = []

        let content = session.createMediaContent(MediaContentConfiguration(playbackRate: .nan))
        assertWarned("createMediaContent", field: "playback_rate")
        XCTAssertEqual(session.playbackRate, 1.5)

        session.updatePlaybackRate(.infinity)
        assertWarned("updatePlaybackRate", field: "playback_rate")
        XCTAssertEqual(session.playbackRate, 1.5)

        content.playingStart(MediaPlayingStartParameters(mediaId: "a1", durationSec: 60, mediaContentType: .main,
                                                         playbackIntent: .autoplay, positionSec: 0))

        XCTAssertEqual(recorder.events.count, 2)
        XCTAssertEqual(recorder.events.last?.eventParameters["playback_rate"], 1.5)
        recorder.events.forEach { assertNoNonFiniteNumbers(in: $0) }
        XCTAssertFalse(logs.contains { $0.contains("allowed: 0...16") })
    }
}
