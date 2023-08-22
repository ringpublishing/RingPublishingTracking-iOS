//
//  VideoStartMode.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 22/08/2023.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Mode in which video in video player was started playing / was changed to after
public enum VideoStartMode {

    /// Video was stared while muted
    case muted

    /// Video was started while unmuted
    case normal

    /// Video was started while muted but later was unmuted
    case wasMuted
}
