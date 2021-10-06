//
//  EventRequest.swift
//  EventRequest
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Request body for send event endpoint
struct EventRequest {

    /// Stored tracking identifiers
    var ids: [String: String]

    /// Optional additional data used to track user
    var user: User?

    /// Not empty list of reported events to send
    var events: [Event]
}

extension EventRequest: Bodable {

    var dictionary: [String: Any] {
        var dictionary: [String: Any] = [
            "ids": ids,
            "events": events.map { $0.dictionary }
        ]

        dictionary["user"] = user?.dictionary

        return dictionary
    }

    func toBodyData() throws -> Data {
        try dictionary.dataUsingJSONSerialization()
    }
}
