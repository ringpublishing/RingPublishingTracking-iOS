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

    var rdlcnParameter: String? {
        return ContentMarkAsPaid(contentMetadata: self).jsonStringBase64
    }
}
