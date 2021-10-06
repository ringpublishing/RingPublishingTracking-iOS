//
//  DecoratedEvent.swift
//  ReportedEvent
//
//  Created by Artur Rymarz on 14/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct DecoratedEvent {

    let clientId: String
    let eventType: String
    var data: [String: AnyHashable]
}

extension DecoratedEvent {
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

extension DecoratedEvent {
    mutating func decorate(using decorators: [Decorator]) {
        for decorator in decorators {
            decorator.parameters().forEach {
                data[$0.key] = $0.value
            }
        }
    }
}
