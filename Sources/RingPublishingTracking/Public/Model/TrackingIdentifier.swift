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
    public let eaUUID: Identifier

    /// Artemis identifier
    public let artemisID: Identifier

    /// Session identifier ("IS"), the same value the module reports with every event
    public let sessionIdentifier: String
}
