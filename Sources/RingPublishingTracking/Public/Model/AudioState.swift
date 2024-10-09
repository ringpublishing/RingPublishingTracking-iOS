//
//  AudioState.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 08/10/2024.
//  Copyright © 2024 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

public struct AudioState {

    /// Current audio material timestamp shown in audio player
    public let currentTime: Int

    /// Current audio material bitrate (in kbps)
    public let currentBitrate: Int

    /// Current audio player visibility
    public let visibilityState: AudioPlayerVisibilityState

    /// Audio output type
    public let audioOutput: AudioOutput

    public init(currentTime: Int,
                currentBitrate: Int,
                visibilityState: AudioPlayerVisibilityState,
                audioOutput: AudioOutput) {
        self.currentTime = currentTime
        self.currentBitrate = currentBitrate
        self.visibilityState = visibilityState
        self.audioOutput = audioOutput
    }
}
