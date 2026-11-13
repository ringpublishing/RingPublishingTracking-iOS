//
//  MediaEnums.swift
//  RingPublishingTracking
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Type of the media played in the session
public enum MediaType: String {

    /// Video player
    case video

    /// Audio player
    case audio

    /// Text-to-speech player
    case tts
}

/// Visibility of the player
public enum MediaVisibilityState: String {

    /// Player is visible to the user
    case visible

    /// Player is not visible (for example out of viewport)
    case hidden

    /// Playback continues while the app is in the background
    case background

    /// Player is shown in picture-in-picture mode
    case pip
}

/// Audio output used by the player
public enum MediaAudioOutput: String {

    /// Built-in speaker
    case speaker

    /// Wired headphones
    case headphones

    /// Bluetooth device
    case bluetooth

    /// Car system (for example CarPlay)
    case car

    /// Chromecast or other casting target
    case chromecast

    /// Other external output
    case external
}

/// Kind of the content which is played
public enum MediaContentType: String {

    /// Advertisement
    case ad // swiftlint:disable:this identifier_name

    /// Main content
    case main

    /// Teaser of the main content
    case teaser

    /// Outro
    case outro

    /// Bumper
    case bumper
}

/// Position of an advertisement relative to the main content
public enum MediaContentSubtype: String {

    /// Played before the main content
    case preroll

    /// Played in the middle of the main content
    case midroll

    /// Played after the main content
    case postroll
}

/// How the content is monetized
public enum MediaMonetizationType: String {

    /// Free content
    case free

    /// Content financed by advertisements
    case ad // swiftlint:disable:this identifier_name

    /// Content bought in a single transaction
    case transactional

    /// Content available with a subscription
    case subscription
}

/// Subscription tier of the user
public enum MediaSubscriptionTier: String {

    /// Free tier
    case free

    /// Basic tier
    case basic

    /// Premium tier
    case premium

    /// VIP tier
    case vip
}

/// Tier required to play the content
public enum MediaTier: String {

    /// Free tier
    case free

    /// Basic tier
    case basic

    /// Premium tier
    case premium

    /// Exclusive tier
    case exclusive
}

/// What triggered the playback
public enum MediaPlaybackIntent: String {

    /// Playback started automatically
    case autoplay

    /// Playback was started by the user
    case userInitiated = "user_initiated"

    /// Playback continues previous content (for example next episode)
    case continuation
}

/// Sound mode of the playback start
public enum MediaStartMode: String {

    /// Playback started muted
    case mutedStart = "muted_start"

    /// Playback started with sound
    case normalStart = "normal_start"
}

/// Reason of pausing the playback
public enum MediaPauseReason: String {

    /// User paused the playback
    case userAction = "user_action"

    /// Playback paused because of network conditions
    case network

    /// Playback paused by the application
    case programmatic

    /// Playback paused for an advertisement
    case ad // swiftlint:disable:this identifier_name
}

/// Reason of ending the playback
public enum MediaPlaybackEndReason: String {

    /// Content played to its end
    case naturalCompletion = "natural_completion"

    /// User stopped the playback
    case userStopped = "user_stopped"

    /// Playback ended because of an error
    case error

    /// Content was skipped
    case skipped
}
