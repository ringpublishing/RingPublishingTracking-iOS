//
//  VideoEvent+VE.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 05/07/2023.
//

import Foundation

extension VideoEvent {

    var veParameter: String {
        switch self {
        case .documentReady:
            return "DOCUMENT_READY"

        case .playerReady:
            return "PLAYER_READY"

        case .start:
            return "START"

        case .simpleLicenseAcquired:
            return "SIMPLE_LICENSE_ACQUIRED"

        case .playingStart:
            return "PLAYING_START"

        case .autoPlayingStart:
            return "PLAYING_AUTOSTART"

        case .paused:
            return "PAUSED"

        case .playing:
            return "PLAYING"

        case .keepPlaying:
            return "KEEP-PLAYING"

        case .keepPaused:
            return "KEEP-PAUSED"

        case .playingEnd:
            return "PLAYING_END"

        case .seekStarted:
            return "SEEK_STARTED"

        case .seekStopped:
            return "SEEK_STOPPED"

        case .bitrateChange:
            return "BITRATE_CHANGE"

        case .bufferingStart:
            return "BUFFERING_START"

        case .bufferingStop:
            return ", BUFFERING_STOP"

        case .keepBuffering:
            return "KEEP-BUFFERING"
        }
    }
}
