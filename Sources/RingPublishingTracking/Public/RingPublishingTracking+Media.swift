//
//  RingPublishingTracking+Media.swift
//  RingPublishingTracking
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Functionality related to Media events (video, audio and TTS players)
public extension RingPublishingTracking {

    // MARK: Media events

    /// Creates a session of a video, audio or TTS player. Events of the session are reported as `MediaEvent`.
    ///
    /// Use it instead of the deprecated `reportVideoEvent` and `reportAudioEvent` methods.
    /// Create the content with `MediaSession.createMediaContent(_:)` and call `MediaSession.end()` when the player is finished.
    ///
    /// - Parameters:
    ///   - mediaType: Type of the media played in the session
    ///   - playerVariant: Variant of the player (up to 64 characters)
    /// - Returns: Media session
    func createMediaSession(mediaType: MediaType, playerVariant: String? = nil) -> MediaSession {
        return MediaSession(mediaType: mediaType, playerVariant: playerVariant) { [self] event in
            reportEvent(event)
        }
    }
}
