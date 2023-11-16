//
//  TrackingIdentifierArtemis.swift
//  RingPublishingTracking
//
//  Created by Adam Mordavsky on 15.11.23.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Tracking identifier wrapper for Artemis
public struct TrackingIdentifierArtemis {

    /// Identifier
    public let id: ArtemisID

    /// External Artemis models
    public let external: ArtemisExternal

    /// Expiration date
    public let expirationDate: Date
}
