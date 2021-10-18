//
//  TrackingIdentifier.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 17/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Tracking identifier and its expiration date
public struct TrackingIdentifier {

    /// Identifier
    public let identifier: String

    /// Expiration date
    public let expirationDate: Date
}
