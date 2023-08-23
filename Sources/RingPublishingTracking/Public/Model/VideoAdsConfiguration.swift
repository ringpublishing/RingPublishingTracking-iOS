//
//  VideoAdsConfiguration.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 23/08/2023.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Video player video ads configuration
public enum VideoAdsConfiguration {

    /// Ads are enabled and can be played
    case enabled

    /// Ads are disabled by player configuration
    case disabledByConfiguration

    /// Ads are disabled for given video
    case disabledByVideoContent

    /// Ads are temporarily disabled
    case disabledWithGracePeriod
}
