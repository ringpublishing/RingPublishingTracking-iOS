//
//  TrackingIdentifierArtemis.swift
//
//
//  Created by Adam Mordavsky on 15.11.23.
//

import Foundation

/// Tracking identifier wrapper for Artemis
public struct TrackingIdentifierArtemis {

    /// Identifier
    public let id: ArtemisID

    public let external: ArtemisExternal

    /// Expiration date
    public let expirationDate: Date
}
