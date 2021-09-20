//
//  EventRequest.swift
//  EventRequest
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct EventRequest: Bodable {

    let ids: [String: String]
    let user: User
    let events: [ReportedEvent]

    var dictionary: [String: Any] {
        [
            "ids": ids,
            "user": user.dictionary,
            "events": events.map { $0.dictionary }
        ]
    }

    func toBodyData() throws -> Data {
        try dictionary.dataUsingJSONSerialization()
    }
}
