//
//  VideoStreamFormat.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 05/07/2023.
//

import Foundation

/// Type of video stream format loaded into video player
public enum VideoStreamFormat {

    /// Flash Video
    case flv

    /// MPEG-4
    case mp4

    /// Manifest with video stream, for example .m3u8
    case manifest

    /// Manifest with live video stream, for example .m3u8
    case liveManifest

    /// 3GP (.3gp)
    case thirdGenerationPartnership

    /// HTTP Dynamic Streaming
    case hds

    /// HTTP Live Streaming
    case hls

    /// Real-Time Messaging Protocol
    case rtsp
}
