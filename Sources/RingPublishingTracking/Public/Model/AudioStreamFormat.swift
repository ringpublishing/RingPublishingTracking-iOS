//
//  AudioStreamFormat.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 08/10/2024.
//  Copyright © 2024 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Audio stream format
public enum AudioStreamFormat: String, Encodable {

    /// MP3 format
    case mp3

    /// HTTP Live Streaming
    case hls
}
