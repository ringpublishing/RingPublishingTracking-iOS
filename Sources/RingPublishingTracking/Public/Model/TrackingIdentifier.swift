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

    public struct EaUUID {
        /// Identifier
        public let identifier: String

        /// Expiration date
        public let expirationDate: Date
    }

    public struct Artemis {
        /// Identifier
        public let identifier: ArtemisIdentifier

        /// Expiration date
        public let expirationDate: Date
    }

    /// EaUUID identifier
    public let eaUUID: TrackingIdentifier.EaUUID

    /// Arthemis identifier
    public let artemisID: TrackingIdentifier.Artemis
}
