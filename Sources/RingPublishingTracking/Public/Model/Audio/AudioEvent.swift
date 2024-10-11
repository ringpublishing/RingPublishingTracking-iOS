//
//  AudioEvent.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 08/10/2024.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

public enum AudioEvent: String {

    /// Audio player instance started loading Audio data
    case start = "START"

    /// Audio player started audio playback (manually)
    case playingStart = "PLAYING_START"

    /// Audio player started audio playback (automatically)
    case autoPlayingStart = "PLAYING_AUTOSTART"

    /// Audio player was paused
    case paused = "PAUSED"

    /// Audio player was resumed after it was previously paused/stopped and it is playing audio material
    case playing = "PLAYING"

    /// Audio player is still playing material (after given period of time)
    case keepPlaying = "KEEP-PLAYING"

    /// Audio player finished playing Audio material
    case playingEnd = "PLAYING_END"
}
