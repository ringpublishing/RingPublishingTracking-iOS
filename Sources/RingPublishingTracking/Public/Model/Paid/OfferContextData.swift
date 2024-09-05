//
//  OfferContextData.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 04/09/2024.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Data for the offer context
public struct OfferContextData {

    /// Location where the offer was presented
    let source: String

    /// Percentage of offer being hidden by the paywall
    let closurePercentage: Int?

    public init(source: String, closurePercentage: Int?) {
        self.source = source
        self.closurePercentage = closurePercentage
    }
}
