//
//  AudioEvent.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 08/10/2024.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

public enum AudioEvent {

    /// Audio player instance started loading Audio data
    case start

    /// Audio player started audio playback (manually)
    case playingStart

    /// Audio player started audio playback (automatically)
    case autoPlayingStart

    /// Audio player was paused
    case paused

    /// Audio player was resumed after it was previously paused/stopped and it is playing audio material
    case playing

    /// Audio player is still playing material (after given period of time)
    case keepPlaying

    /// Audio player finished playing Audio material
    case playingEnd

    var text: String {
        switch self {
        case .start: return "START"
        case .playingStart: return "PLAYING_START"
        case .autoPlayingStart: return "PLAYING_AUTOSTART"
        case .paused: return "PAUSED"
        case .playing: return "PLAYING"
        case .keepPlaying: return "KEEP-PLAYING"
        case .playingEnd: return "PLAYING_END"
        }
    }
}
