//
//  RingPublishingTracking+Audio.swift
//  RingPublishingTracking

//
//  Created by Bernard Bijoch on 08/10/2024.
//  Copyright © 2024 Ringier Axel Springer Tech. All rights reserved.
//

public extension RingPublishingTracking {

    /// Report Audio player event
    ///
    /// - Parameters:
    ///   - audioEvent: Type of Audio event to report
    ///   - audioMetadata: Audio material metadata
    ///   - audioState: Current Audio material state in audio player
    @available(*, deprecated, message: "Sends the legacy VidEvent. Use createMediaSession(mediaType:playerVariant:) to report MediaEvent.")
    func reportAudioEvent(audioEvent: AudioEvent, audioMetadata: AudioMetadata, audioState: AudioState) {
        reportEvent(eventsFactory.createAudioEvent(audioEvent: audioEvent, audioMetadata: audioMetadata, audioState: audioState))
    }
}
