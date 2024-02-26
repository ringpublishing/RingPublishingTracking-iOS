//
//  AureusEventContext+ECX.swift
//  RingPublishingTrackingTests
//
//  Created by Adam Szeremeta on 19/02/2024.
//  Copyright © 2024 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension AureusEventContext {

    /// ECX parameter
    ///
    /// Example:
    /// {"context":{"aureus":{"client_uuid":"581ad584-2333-4e69-8963-c105184cfd04",
    /// "variant_uuid":"0e8c860f-006a-49ef-923c-38b8cfc7ca57","batch_id":"79935e2327",
    /// "recommendation_id":"e4b25216db","teaser_id":"_DEFAULT_","segment_id":"group1.segment1"}}}
    var ecxParameter: String? {
        let wrapper = AureusEventContextWrapper(context: AureusContext(aureus: self))

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = .sortedKeys

        guard let jsonData = try? encoder.encode(wrapper),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }

        return Data(jsonString.utf8).base64EncodedString()
    }
}

private struct AureusEventContextWrapper: Encodable {

    let context: AureusContext
}

private struct AureusContext: Encodable {

    let aureus: AureusEventContext
}
