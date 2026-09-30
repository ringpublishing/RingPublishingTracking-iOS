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

    /// Content identifier reported in `PU` by events built from the content metadata alone
    var normalizedContentId: String {
        contentId.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /// Builds `RDLCN` parameter
    ///
    /// - Parameter objectIdentifier: Content identifier reported as `PU` by the same event, sent as `object.id`.
    ///   `object` is omitted when the identifier is empty.
    /// - Returns: Base64 encoded parameter value
    func rdlcnParameter(objectIdentifier: String?) -> String? {
        return ContentMarkAsPaid(contentMetadata: self, objectIdentifier: objectIdentifier).jsonStringBase64
    }
}
