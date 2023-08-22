//
//  VideoState.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 05/07/2023.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Current state of the video material in video player
public struct VideoState {

    /// Current video material timestamp shown in video player
    public let currentTime: Int

    /// Current video material bitrate (in kbps)
    public let currentBitrate: String

    /// Is video currently muted?
    public let isMuted: Bool

    /// Video start mode
    public let startMode: VideoStartMode

    // MARK: Init

    /// Initializer
    ///
    /// - Parameters:
    ///   - currentTime: Current video material timestamp shown in video player
    ///   - currentBitrate: Current video material bitrate (in kbps)
    ///   - isMuted:  Is video currently muted?
    ///   - startMode: In which mode video was started / changed to?
    public init(currentTime: Int, currentBitrate: String, isMuted: Bool, startMode: VideoStartMode) {
        self.currentTime = currentTime
        self.currentBitrate = currentBitrate
        self.isMuted = isMuted
        self.startMode = startMode
    }
}
