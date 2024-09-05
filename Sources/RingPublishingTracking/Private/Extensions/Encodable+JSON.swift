//
//  Encodable+JSON.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 04/09/2024.
//

import Foundation

extension Encodable {

    // swiftlint:disable non_optional_string_data_conversion

    var jsonString: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        guard let data = try? encoder.encode(self),
              let jsonString = String(data: data, encoding: .utf8) else { return nil }

        return jsonString
    }

    // swiftlint:enable non_optional_string_data_conversion

    var jsonStringBase64: String? {
        guard let jsonString = jsonString else { return nil }

        return Data(jsonString.utf8).base64EncodedString()
    }
}
