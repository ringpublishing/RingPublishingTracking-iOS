//
//  ContentMetadata+DX.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 14/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension ContentMetadata {

    var dxParameter: String {
        let sourceSystem = sourceSystemName.trimmingCharacters(in: .whitespacesAndNewlines)
        let pubId = publicationId.trimmingCharacters(in: .whitespacesAndNewlines)
        let part = contentPartIndex
        let paid = contentWasPaidFor ? "t" : "f"

        return "PV_4,\(sourceSystem),\(pubId),\(part),\(paid)".replacingOccurrences(of: " ", with: "_")
    }
}
