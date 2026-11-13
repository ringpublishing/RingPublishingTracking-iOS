//
//  MediaEventFields.swift
//  RingPublishingTracking
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// State of the content a MediaEvent belongs to
struct MediaPlaybackState {

    var monetizationType: MediaMonetizationType?
    var subscriptionTier: MediaSubscriptionTier?
    var userEngaged = false
    var durationSec: Double?
    var mediaContentType: MediaContentType?
    var mediaId: String?
    var playbackIntent: MediaPlaybackIntent?
    var mediaVariant: String?
    var mediaPremium: Bool?
    var mediaTier: MediaTier?
    var mediaContentSubtype: MediaContentSubtype?
    var adId: String?
    var adCampaignId: String?
    var adCreativeId: String?
    var adSlot: String?
    var relatedMediaId: String?
}

/// State of the session a MediaEvent belongs to
struct MediaSessionState {

    var mediaType: MediaType
    var playerVariant: String?
    var audioOutput = MediaAudioOutput.speaker
    var muted = true
    var playbackRate = 1.0
    var visibilityState = MediaVisibilityState.visible
    var eventOrdinal = 0
}

/// Everything a single MediaEvent consists of
struct MediaEventFields {

    let type: MediaEventType
    let sessionId: String
    let session: MediaSessionState
    let playback: MediaPlaybackState?

    var positionSec: Double?
    var startMode: MediaStartMode?
    var pauseReason: MediaPauseReason?
    var playbackEndReason: MediaPlaybackEndReason?
    var errorCode: String?
    var errorMessage: String?
}
