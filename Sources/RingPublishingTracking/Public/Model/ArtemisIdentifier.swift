//
//  ArtemisIdentifier.swift
//  RingPublishingTracking
//
//  Created by Adam Mordavsky on 09.11.23.
//

import Foundation

public struct ArtemisIdentifier: Codable {

    let id: ArtemisID

    /// The time in seconds of how long the identifier is valid for since the refresh's date
    let lifetime: Int

    /// Date when the identifier was created
    let creationDate: Date

    // MARK: Computed properties

    var expirationDate: Date {
        return creationDate.addingTimeInterval(TimeInterval(lifetime))
    }
}
