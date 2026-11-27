//
//  MediaEventType.swift
//  RingPublishingTracking
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Values of the `event_type` parameter of the MediaEvent
enum MediaEventType: String {

    case sessionStart = "MEDIA_SESSION_START"
    case sessionEnd = "MEDIA_SESSION_END"
    case playingStart = "MEDIA_PLAYING_START"
    case playingProgress = "MEDIA_PLAYING_PROGRESS"
    case playingEnd = "MEDIA_PLAYING_END"
    case pause = "MEDIA_PAUSE"
    case resume = "MEDIA_RESUME"
    case seekStart = "MEDIA_SEEK_START"
    case seekEnd = "MEDIA_SEEK_END"
    case mute = "MEDIA_MUTE"
    case unmute = "MEDIA_UNMUTE"
    case outputChange = "MEDIA_OUTPUT_CHANGE"
    case visibilityChange = "MEDIA_VISIBILITY_CHANGE"
    case error = "MEDIA_ERROR"
}
