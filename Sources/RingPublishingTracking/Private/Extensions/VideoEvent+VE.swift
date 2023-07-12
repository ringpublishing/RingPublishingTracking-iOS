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
        case .start:
            return "START"

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

        case .playingEnd:
            return "PLAYING_END"
        }
    }
}
