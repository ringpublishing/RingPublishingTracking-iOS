//
//  ReportedEvent.swift
//  ReportedEvent
//
//  Created by Artur Rymarz on 14/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct ReportedEvent: Encodable {
    let clientId: String
    let eventType: String
    let data: [String: Encodable]

    enum CodingKeys: String, CodingKey {
        case clientId = "ac"
        case eventType = "et"
        case data
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(clientId, forKey: .clientId)
        try container.encode(eventType, forKey: .eventType)

        let json = try JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted, .sortedKeys])
        try container.encode(json, forKey: .data)
    }
}
