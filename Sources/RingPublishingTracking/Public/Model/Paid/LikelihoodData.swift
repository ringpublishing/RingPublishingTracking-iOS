//
//  LikelihoodData.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 04/09/2024.
//

import Foundation

public struct LikelihoodData: Encodable {

    enum CodingKeys: String, CodingKey {
        case likelihoodToSubscribe = "lts"
        case likelihoodToCancel = "ltc"
    }

    let likelihoodToSubscribe: Int?
    let likelihoodToCancel: Int?
}
