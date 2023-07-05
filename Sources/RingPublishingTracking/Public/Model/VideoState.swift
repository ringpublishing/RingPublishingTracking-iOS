//
//  VideoState.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 05/07/2023.
//

import Foundation

/// Current state of the video material in video player
public struct VideoState {

    /// Current video material timestamp shown in video player
    public let currentTime: Int

    /// Current video material bitrate (in kbps)
    public let currentBitrate: Int

    /// Is video currently muted?
    public let isMuted: Bool

    // MARK: Init

    /// Initializer
    ///
    /// - Parameters:
    ///   - currentTime: Current video material timestamp shown in video player
    ///   - currentBitrate: Current video material bitrate (in kbps)
    ///   - isMuted:  Is video currently muted?
    public init(currentTime: Int, currentBitrate: Int, isMuted: Bool) {
        self.currentTime = currentTime
        self.currentBitrate = currentBitrate
        self.isMuted = isMuted
    }
}
