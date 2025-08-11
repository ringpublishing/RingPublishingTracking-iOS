//
//  AureusEventContext+ECX.swift
//  RingPublishingTrackingTests
//
//  Created by Adam Szeremeta on 08/08/2025.
//  Copyright © 2025 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension AureusEventContext {

    /// ECX parameter
    ///
    /// Example:
    /// {"context":{"aureus":{
    /// "variant_uuid":"0e8c860f-006a-49ef-923c-38b8cfc7ca57","batch_id":"79935e2327",
    /// "recommendation_id":"e4b25216db","teaser_id":"_DEFAULT_","segment_id":"group1.segment1"}}}
    var ecxParameter: String? {
        let wrapper = AureusEventContextWrapper(context: AureusContext(aureus: AureusEventContextParams(context: self)))

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

    let aureus: AureusEventContextParams
}

private struct AureusEventContextParams: Encodable {

    let variantUuid: String
    let batchId: String
    let recommendationId: String
    let segmentId: String
    let teaserId: String?

    init(context: AureusEventContext) {
        self.variantUuid = context.variantUuid
        self.batchId = context.batchId
        self.recommendationId = context.recommendationId
        self.segmentId = context.segmentId
        self.teaserId = context.teaserId
    }
}
