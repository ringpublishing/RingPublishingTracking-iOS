//
//  AureusEventContext.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 19/02/2024.
//  Copyright © 2024 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Context for reported Aureus events
public struct AureusEventContext: Encodable {

    /// Aureus client UUID
    ///
    /// Corresponds to a purchase of Aureus service for a given website
    public let clientUuid: String

    /// Aureus variant UUID
    ///
    /// Corresponds to the unique 'recipe' which was used to generate this particular recommendation
    public let variantUuid: String

    /// Query identifier executed to Aureus
    public let batchId: String

    /// Identifier of single recommendation
    ///
    /// A batch contains one or more recommendations
    public let recommendationId: String

    /// Segment identifier of given end user
    public let segmentId: String

    /// Identifier of a teaser displayed to the user
    var teaserId: String?

    // MARK: Init

    /// Initializer
    ///
    /// - Parameters:
    ///   - clientUuid: Aureus client UUID
    ///   - variantUuid: Aureus variant UUID
    ///   - batchId: Query identifier executed to Aureus
    ///   - recommendationId: Identifier of single recommendation
    ///   - segmentId: Segment identifier of given end user
    public init(clientUuid: String, variantUuid: String, batchId: String, recommendationId: String, segmentId: String) {
        self.clientUuid = clientUuid
        self.variantUuid = variantUuid
        self.batchId = batchId
        self.recommendationId = recommendationId
        self.segmentId = segmentId
    }
}
