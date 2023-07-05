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

    /// Video player instance was created
    case documentReady

    /// Video player instance was initialized
    case playerReady

    /// Video player instance started loading video data
    case start

    /// Video material licences were verified and video can be played
    case simpleLicenseAcquired

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

    /// Video player is still paused (after given period of time)
    case keepPaused

    /// Video player finished playing video material
    case playingEnd

    /// Video player progress seek started
    case seekStarted

    /// Video player progress seek stopped
    case seekStopped

    /// Bitrate of material played by video player was changed
    case bitrateChange

    /// Video player did start buffering video material
    case bufferingStart

    /// Video player did finish buffering video material
    case bufferingStop

    /// Video player started buffering ans is still in progress of buffering video material (after given period of time)
    case keepBuffering
}
