//
//  EventsService+Storage.swift
//  
//
//  Created by Adam Mordavsky on 15.11.23.
//

import Foundation

extension EventsService {

    /// Stores User Identifier
    ///
    /// - Parameter eaUUID: IdsWithLifetime?
    /// - Returns: True if identifier was stored, false otherwise
    func storeEaUUID(_ eaUUID: IdsWithLifetime?) -> EaUUID? {
        guard let eaUUID = eaUUID, let value = eaUUID.value, let lifetime = eaUUID.lifetime else {
            storage.eaUUID = nil
            storage.postInterval = nil
            Logger.log("Tracking identifier could not be stored. Missing in decoded response.", level: .error)
            return nil
        }
        let creationDate = Date()
        let eaUUIDObject = EaUUID(value: value, lifetime: lifetime, creationDate: creationDate)
        storage.eaUUID = eaUUIDObject
        return eaUUIDObject
    }

    /// Stores Post Interval
    func storePostInterval(_ postInterval: Int) {
        storage.postInterval = postInterval
    }

    /// Store artemis' object value.
    /// - Parameter object: Instance of the `Artemis` or `nil`.
    func storeArtemis(_ object: Artemis?) {
        storage.artemisID = object
    }
}
