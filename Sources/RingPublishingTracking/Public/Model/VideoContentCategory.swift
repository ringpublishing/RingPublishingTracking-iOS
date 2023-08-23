//
//  VideoContentCategory.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 23/08/2023.
//

import Foundation

/// Video content category in terms of paid access to it
public enum VideoContentCategory {

    /// Video content is free
    case free

    /// Video content was purchased by one time purchase
    case vodPayPerView

    /// Video content was purchased using premium subscription
    case vodSubscription
}
