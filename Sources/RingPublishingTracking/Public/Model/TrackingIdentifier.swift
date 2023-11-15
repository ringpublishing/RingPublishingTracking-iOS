//
//  TrackingIdentifier.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 17/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Wrapper around tracking identifiers
public struct TrackingIdentifier {

    /// EaUUID identifier
    public let eaUUID: TrackingIdentfierEaUUID

    /// Arthemis identifier
    public let artemisID: TrackingIdentifierArtemis
}
