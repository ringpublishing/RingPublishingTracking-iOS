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
        let pubId = publicationId.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !pubId.isEmpty else { return "" }

        let sourceSystem = sourceSystemName.trimmingCharacters(in: .whitespacesAndNewlines)
        let part = contentPartIndex
        let paid = paidContent ? "t" : "f"

        return "PV_4,\(sourceSystem),\(pubId),\(part),\(paid)".replacingOccurrences(of: " ", with: "_")
    }

    /// Builds `RDLCN` parameter
    ///
    /// - Parameter invalidContentIdentifiers: Content identifiers already logged as not being a UUID
    /// - Returns: Base64 encoded parameter value
    func rdlcnParameter(invalidContentIdentifiers: InvalidContentIdentifiers) -> String? {
        return ContentMarkAsPaid(contentMetadata: self, invalidContentIdentifiers: invalidContentIdentifiers).jsonStringBase64
    }
}
