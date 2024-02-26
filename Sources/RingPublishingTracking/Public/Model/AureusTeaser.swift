//
//  AureusTeaser.swift
//  RingPublishingTrackingTests
//
//  Created by Adam Szeremeta on 19/02/2024.
//  Copyright © 2024 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Represents a single item displayed to the user
public struct AureusTeaser: Encodable {

    /// Aureus teaser identifier
    public let teaserId: String

    /// Content identifier
    public let contentId: String

    // MARK: Init

    /// Initializer
    ///
    /// - Parameters:
    ///   - teaserId: Aureus teaser identifier
    ///   - contentId: Content identifier
    public init(teaserId: String, contentId: String) {
        self.teaserId = teaserId
        self.contentId = contentId
    }
}
