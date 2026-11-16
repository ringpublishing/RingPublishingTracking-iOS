//
//  MediaPlayingStartParameters.swift
//  RingPublishingTracking
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Parameters of `MediaContent.playingStart(_:)`
public struct MediaPlayingStartParameters {

    /// Id of the media (1 to 36 characters)
    public let mediaId: String

    /// Duration of the media in seconds
    public let durationSec: Double

    /// Kind of the content
    public let mediaContentType: MediaContentType

    /// What triggered the playback
    public let playbackIntent: MediaPlaybackIntent

    /// Playback position in seconds
    public let positionSec: Double

    /// Variant of the media, for example its format (up to 64 characters)
    public let mediaVariant: String?

    /// Sound mode of the playback start
    public let startMode: MediaStartMode?

    /// Whether the player is muted. When nil the session state is kept.
    public let muted: Bool?

    /// Whether the user is engaged. When nil the previous value is kept.
    public let userEngaged: Bool?

    /// Position of an advertisement relative to the main content
    public let mediaContentSubtype: MediaContentSubtype?

    /// Advertisement id (up to 36 characters)
    public let adId: String?

    /// Advertisement campaign id (up to 36 characters)
    public let adCampaignId: String?

    /// Advertisement creative id (up to 36 characters)
    public let adCreativeId: String?

    /// Advertisement slot (up to 128 characters)
    public let adSlot: String?

    /// Id of the media an advertisement relates to (up to 36 characters).
    /// For advertisements it defaults to the media id of the session's active content.
    public let relatedMediaId: String?

    /// Whether the media is premium
    public let mediaPremium: Bool?

    /// Tier required to play the media
    public let mediaTier: MediaTier?

    /// Initializer
    ///
    /// - Parameters:
    ///   - mediaId: Id of the media (1 to 36 characters)
    ///   - durationSec: Duration of the media in seconds
    ///   - mediaContentType: Kind of the content
    ///   - playbackIntent: What triggered the playback
    ///   - positionSec: Playback position in seconds
    ///   - mediaVariant: Variant of the media, for example its format (up to 64 characters)
    ///   - startMode: Sound mode of the playback start
    ///   - muted: Whether the player is muted. When nil the session state is kept.
    ///   - userEngaged: Whether the user is engaged. When nil the previous value is kept.
    ///   - mediaContentSubtype: Position of an advertisement relative to the main content
    ///   - adId: Advertisement id (up to 36 characters)
    ///   - adCampaignId: Advertisement campaign id (up to 36 characters)
    ///   - adCreativeId: Advertisement creative id (up to 36 characters)
    ///   - adSlot: Advertisement slot (up to 128 characters)
    ///   - relatedMediaId: Id of the media an advertisement relates to (up to 36 characters)
    ///   - mediaPremium: Whether the media is premium
    ///   - mediaTier: Tier required to play the media
    public init(mediaId: String,
                durationSec: Double,
                mediaContentType: MediaContentType,
                playbackIntent: MediaPlaybackIntent,
                positionSec: Double,
                mediaVariant: String? = nil,
                startMode: MediaStartMode? = nil,
                muted: Bool? = nil,
                userEngaged: Bool? = nil,
                mediaContentSubtype: MediaContentSubtype? = nil,
                adId: String? = nil,
                adCampaignId: String? = nil,
                adCreativeId: String? = nil,
                adSlot: String? = nil,
                relatedMediaId: String? = nil,
                mediaPremium: Bool? = nil,
                mediaTier: MediaTier? = nil) {
        self.mediaId = mediaId
        self.durationSec = durationSec
        self.mediaContentType = mediaContentType
        self.playbackIntent = playbackIntent
        self.positionSec = positionSec
        self.mediaVariant = mediaVariant
        self.startMode = startMode
        self.muted = muted
        self.userEngaged = userEngaged
        self.mediaContentSubtype = mediaContentSubtype
        self.adId = adId
        self.adCampaignId = adCampaignId
        self.adCreativeId = adCreativeId
        self.adSlot = adSlot
        self.relatedMediaId = relatedMediaId
        self.mediaPremium = mediaPremium
        self.mediaTier = mediaTier
    }
}
