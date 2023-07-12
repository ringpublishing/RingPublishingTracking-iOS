//
//  VideoEvent.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 05/07/2023.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Video event types
public enum VideoEvent {

    /// Video player instance started loading video data
    case start

    /// Video player started video playback (manually)
    case playingStart

    /// Video player started video playback (automatically)
    case autoPlayingStart

    /// Video player was paused
    case paused

    /// Video player was resumed after it was previously paused/stopped and it is playing video material
    case playing

    /// Video player is still playing material (after given period of time)
    case keepPlaying

    /// Video player finished playing video material
    case playingEnd
}
