//
//  AureusTeaser.swift
//  RingPublishingTrackingTests
//
//  Created by Adam Szeremeta on 08/08/2025.
//  Copyright © 2025 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Represents a single item displayed to the user
public struct AureusTeaser {

    /// Aureus teaser identifier
    public let teaserId: String?

    /// Aureus offer identifier / offers batch id identifier
    public let offerId: String?

    /// Content identifier
    public let contentId: String?

    // MARK: Init

    /// Initializer
    /// Either teaserId or offerId must be provided. ContentId is optional.
    ///
    /// - Parameters:
    ///   - teaserId: Aureus teaser identifier
    ///   - offerId: Aureus offer identifier / offers batch id identifier
    ///   - contentId: Content identifier
    public init(teaserId: String?, offerId: String?, contentId: String?) {
        self.teaserId = teaserId
        self.offerId = offerId
        self.contentId = contentId
    }
}
