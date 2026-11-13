//
//  EventsFactory+Media.swift
//  RingPublishingTracking
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension EventsFactory {

    func createMediaEvent(parameters: [String: AnyHashable]) -> Event {
        return Event(analyticsSystemName: AnalyticsSystem.generic.rawValue,
                     eventName: EventType.media.rawValue,
                     eventParameters: parameters)
    }

    func createMediaEvent(fields: MediaEventFields) -> Event {
        var parameters: [String: AnyHashable] = [:]
        let playback = fields.playback

        parameters["RT"] = EventType.media.rawValue
        parameters["event_type"] = fields.type.rawValue
        parameters["event_ordinal"] = fields.session.eventOrdinal
        parameters["media_session_id"] = fields.sessionId

        parameters["media_type"] = fields.session.mediaType.rawValue
        parameters["player_variant"] = fields.session.playerVariant
        parameters["audio_output"] = fields.session.audioOutput.rawValue
        parameters["muted"] = fields.session.muted
        parameters["playback_rate"] = fields.session.playbackRate
        parameters["visibility_state"] = fields.session.visibilityState.rawValue

        parameters["ad_campaign_id"] = playback?.adCampaignId
        parameters["ad_creative_id"] = playback?.adCreativeId
        parameters["ad_id"] = playback?.adId
        parameters["ad_slot"] = playback?.adSlot
        parameters["duration_sec"] = playback?.durationSec
        parameters["media_content_subtype"] = playback?.mediaContentSubtype?.rawValue
        parameters["media_content_type"] = playback?.mediaContentType?.rawValue
        parameters["media_id"] = playback?.mediaId
        parameters["media_premium"] = playback?.mediaPremium
        parameters["media_tier"] = playback?.mediaTier?.rawValue
        parameters["media_variant"] = playback?.mediaVariant
        parameters["monetization_type"] = playback?.monetizationType?.rawValue
        parameters["playback_intent"] = playback?.playbackIntent?.rawValue
        parameters["related_media_id"] = playback?.relatedMediaId
        parameters["subscription_tier"] = playback?.subscriptionTier?.rawValue
        parameters["user_engaged"] = playback?.userEngaged ?? false

        parameters["position_sec"] = fields.positionSec
        parameters["start_mode"] = fields.startMode?.rawValue
        parameters["pause_reason"] = fields.pauseReason?.rawValue
        parameters["playback_end_reason"] = fields.playbackEndReason?.rawValue
        parameters["error_code"] = fields.errorCode
        parameters["error_message"] = fields.errorMessage

        return createMediaEvent(parameters: parameters)
    }
}
