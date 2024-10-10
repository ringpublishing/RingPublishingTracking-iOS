//
//  AudioPlayerVisibilityState.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 08/10/2024.
//  Copyright © 2024 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Audio player visibility state
public enum AudioPlayerVisibilityState: String, Encodable {

    /// Audio player is visible
    case visible

    /// Audio player is in background
    case background
}
