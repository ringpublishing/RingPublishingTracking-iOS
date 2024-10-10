//
//  RingPublishingTracking+Audio.swift
//  RingPublishingTracking

//
//  Created by Bernard Bijoch on 08/10/2024.
//  Copyright © 2024 Ringier Axel Springer Tech. All rights reserved.
//

public extension RingPublishingTracking {

    func reportAudioEvent(audioEvent: AudioEvent, audioMetadata: AudioMetadata, audioState: AudioState) {
        reportEvent(eventsFactory.createAudioEvent(audioEvent: audioEvent, audioMetadata: audioMetadata, audioState: audioState))
    }
}
