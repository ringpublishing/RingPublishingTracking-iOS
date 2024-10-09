//
//  AudioContentCategory.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 08/10/2024.
//  Copyright © 2024 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Audio content category in terms of paid access to it
public enum AudioContentCategory: String, Encodable {

    /// Free content
    case free

    /// Paid content
    case paid
}
