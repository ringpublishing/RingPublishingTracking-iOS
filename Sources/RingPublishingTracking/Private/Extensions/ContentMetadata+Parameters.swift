//
//  ContentMetadata+Parameters.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 14/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension ContentMetadata {

    private static var encoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()

    var dxParameter: String {
        let sourceSystem = sourceSystemName.trimmingCharacters(in: .whitespacesAndNewlines)
        let pubId = publicationId.trimmingCharacters(in: .whitespacesAndNewlines)
        let part = contentPartIndex
        let paid = paidContent ? "t" : "f"

        return "PV_4,\(sourceSystem),\(pubId),\(part),\(paid)".replacingOccurrences(of: " ", with: "_")
    }

    // swiftlint:disable non_optional_string_data_conversion

    var rdlcnParameter: String? {
        let contentMarkAsPaid = ContentMarkAsPaid(contentMetadata: self)

        if let jsonData = try? Self.encoder.encode(contentMarkAsPaid),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return Data(jsonString.utf8).base64EncodedString()
        }

        return nil
    }

    // swiftlint:enable non_optional_string_data_conversion

}
