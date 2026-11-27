//
//  MediaTestHelpers.swift
//  RingPublishingTrackingTests
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Collects events handed to the session sink
final class MediaEventRecorder {

    private let lock = NSLock()
    private var storage = [Event]()

    var events: [Event] {
        lock.lock()
        defer { lock.unlock() }

        return storage
    }

    func reset() {
        lock.lock()
        defer { lock.unlock() }

        storage = []
    }

    func makeSession(mediaType: MediaType, playerVariant: String? = nil) -> MediaSession {
        return MediaSession(mediaType: mediaType, playerVariant: playerVariant) { [self] event in
            lock.lock()
            defer { lock.unlock() }

            storage.append(event)
        }
    }
}

/// Call sequences of the contract scenarios
enum MediaScenarios {

    static func runAudio(recorder: MediaEventRecorder) -> MediaSession {
        let session = recorder.makeSession(mediaType: .audio, playerVariant: "main")
        let first = session.createMediaContent(MediaContentConfiguration(monetizationType: .subscription,
                                                                         muted: false,
                                                                         visibilityState: .background,
                                                                         playbackRate: 1.5,
                                                                         audioOutput: .bluetooth))
        first.playingStart(MediaPlayingStartParameters(mediaId: "a1", durationSec: 1800, mediaContentType: .main,
                                                       playbackIntent: .userInitiated, positionSec: 0, mediaVariant: "mp3",
                                                       userEngaged: true))
        first.playingProgress(positionSec: 15)
        first.pause(positionSec: 42, reason: .userAction)
        first.playingProgress(positionSec: 43)
        first.seekStart(positionSec: 42, targetSec: 100)
        first.resume(positionSec: 42)
        first.seekEnd(positionSec: 100)
        first.outputChange(positionSec: 110, audioOutput: .car)
        first.playingEnd(positionSec: 1800, reason: .naturalCompletion)
        first.pause(positionSec: 1800, reason: .userAction)

        let second = session.createMediaContent(MediaContentConfiguration(monetizationType: .free))
        second.playingStart(MediaPlayingStartParameters(mediaId: "a2", durationSec: 600, mediaContentType: .main,
                                                        playbackIntent: .continuation, positionSec: 0))
        second.visibilityChange(positionSec: 5, visibilityState: .visible)
        second.error(positionSec: 6, code: "E42", message: "decoder failure")
        session.end()
        second.resume(positionSec: 7)
        session.end()

        let third = session.createMediaContent()
        third.playingStart(MediaPlayingStartParameters(mediaId: "a3", durationSec: 1, mediaContentType: .main,
                                                       playbackIntent: .userInitiated, positionSec: 0))

        return session
    }

    static func runVideo(recorder: MediaEventRecorder) -> MediaSession {
        let session = recorder.makeSession(mediaType: .video, playerVariant: "inline")
        let main = session.createMediaContent(MediaContentConfiguration(monetizationType: .free))
        main.playingStart(MediaPlayingStartParameters(mediaId: "v1", durationSec: 120, mediaContentType: .main,
                                                      playbackIntent: .autoplay, positionSec: 0, startMode: .mutedStart))
        main.unmute(positionSec: 3)

        let advert = session.createMediaContent()
        advert.playingStart(MediaPlayingStartParameters(mediaId: "ad1", durationSec: 10, mediaContentType: .ad,
                                                    playbackIntent: .autoplay, positionSec: 0, mediaContentSubtype: .midroll,
                                                    adCampaignId: "camp1"))
        advert.playingEnd(positionSec: 10, reason: .naturalCompletion)

        main.seekEnd(positionSec: 30)
        main.mute(positionSec: 31)
        main.playingEnd(positionSec: 120, reason: .userStopped)
        main.playingStart(MediaPlayingStartParameters(mediaId: "v1", durationSec: 120, mediaContentType: .main,
                                                      playbackIntent: .userInitiated, positionSec: 0))
        main.seekStart(positionSec: 50, targetSec: 80)
        main.seekStart(positionSec: 55)
        session.end()

        return session
    }
}
