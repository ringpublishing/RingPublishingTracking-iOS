//
//  ArtemisID.swift
//  RingPublishingTracking
//
//  Created by Adam Mordavsky on 09.11.23.
//

import Foundation

public struct ArtemisObject: Codable {

    public struct ID: Codable {

        struct External: Codable {

            let model: String

            let models: String
        }

        let artemis: String

        let external: External
    }

    let id: ArtemisObject.ID

    /// The time in seconds of how long the identifier is valid for since the refresh's date
    let lifetime: Int

    /// Date when the identifier was created
    let creationDate: Date

    // MARK: Computed properties

    var expirationDate: Date {
        return creationDate.addingTimeInterval(TimeInterval(lifetime))
    }
}
