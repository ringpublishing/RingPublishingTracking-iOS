//
//  Encodable+JSON.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 04/09/2024.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension Encodable {

    var jsonString: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        guard let data = try? encoder.encode(self),
              let jsonString = String(data: data, encoding: .utf8) else { return nil }

        return jsonString
    }

    var jsonStringBase64: String? {
        guard let jsonString = jsonString else { return nil }

        return Data(jsonString.utf8).base64EncodedString()
    }
}
