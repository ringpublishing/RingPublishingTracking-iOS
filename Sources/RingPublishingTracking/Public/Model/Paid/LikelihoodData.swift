//
//  LikelihoodData.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 04/09/2024.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// User likelihood data
public struct LikelihoodData: Encodable {

    enum CodingKeys: String, CodingKey {
        case likelihoodToSubscribe = "lts"
        case likelihoodToCancel = "ltc"
    }

    /// Likelihood to subscribe
    let likelihoodToSubscribe: Int?

    /// Likelihood to cancel
    let likelihoodToCancel: Int?

    /// LikelihoodData initializer
    ///
    /// Prameters:
    /// - likelihoodToSubscribe: Likelihood to subscribe
    /// - likelihoodToCancel: Likelihood to cancel
    public init(likelihoodToSubscribe: Int?, likelihoodToCancel: Int?) {
        self.likelihoodToSubscribe = likelihoodToSubscribe
        self.likelihoodToCancel = likelihoodToCancel
    }
}
