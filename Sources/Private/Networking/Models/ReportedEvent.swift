//
//  ReportedEvent.swift
//  ReportedEvent
//
//  Created by Artur Rymarz on 14/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct ReportedEvent {

    let clientId: String
    let eventType: String
    let data: [String: AnyHashable]
}

extension ReportedEvent {
    var dictionary: [String: Any] {
        [
            "ac": clientId,
            "et": eventType,
            "data": data
        ]
    }

    var sizeInBytes: UInt {
        dictionary.jsonSizeInBytes
    }
}
