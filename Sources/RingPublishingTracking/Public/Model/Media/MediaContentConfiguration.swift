//
//  MediaContentConfiguration.swift
//  RingPublishingTracking
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Configuration used when creating media content in a `MediaSession`
///
/// Values of `muted`, `visibilityState`, `playbackRate` and `audioOutput` are copied into the session state when they are not nil.
public struct MediaContentConfiguration {

    /// How the content is monetized
    public let monetizationType: MediaMonetizationType?

    /// Subscription tier of the user
    public let subscriptionTier: MediaSubscriptionTier?

    /// Whether the player is muted
    public let muted: Bool?

    /// Visibility of the player
    public let visibilityState: MediaVisibilityState?

    /// Playback rate (1.0 is normal speed)
    public let playbackRate: Double?

    /// Audio output used by the player
    public let audioOutput: MediaAudioOutput?

    /// Initializer
    ///
    /// - Parameters:
    ///   - monetizationType: How the content is monetized
    ///   - subscriptionTier: Subscription tier of the user
    ///   - muted: Whether the player is muted
    ///   - visibilityState: Visibility of the player
    ///   - playbackRate: Playback rate (1.0 is normal speed)
    ///   - audioOutput: Audio output used by the player
    public init(monetizationType: MediaMonetizationType? = nil,
                subscriptionTier: MediaSubscriptionTier? = nil,
                muted: Bool? = nil,
                visibilityState: MediaVisibilityState? = nil,
                playbackRate: Double? = nil,
                audioOutput: MediaAudioOutput? = nil) {
        self.monetizationType = monetizationType
        self.subscriptionTier = subscriptionTier
        self.muted = muted
        self.visibilityState = visibilityState
        self.playbackRate = playbackRate
        self.audioOutput = audioOutput
    }
}
