//
//  Event+API.swift
//  Event+API
//
//  Created by Artur Rymarz on 14/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Extension for creating a dictionary (used in JSON) from Event
extension Event {
    var dictionary: [String: Any] {
        [
            "ac": analyticsSystemName,
            "et": eventName,
            "data": eventParameters
        ]
    }

    var sizeInBytes: UInt {
        dictionary.jsonSizeInBytes
    }
}

/// Extension for decorating events
extension Event {

    func decorated(using decorators: [Decorator]) -> Self {
        var parameters = eventParameters

        for decorator in decorators {
            decorator.parameters().forEach {
                parameters[$0.key] = $0.value
            }
        }

        return Event(analyticsSystemName: analyticsSystemName, eventName: eventName, eventParameters: parameters)
    }
}
